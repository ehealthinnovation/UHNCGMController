//
//  NSData+CGMParser.m
//  CGM_Collector
//
//  Created by Nathaniel Hamming on 2015-01-06.
//  Copyright (c) 2015 University Health Network.
//

#import "NSData+CGMParser.h"
#import "NSData+ConversionExtensions.h"
#import "UHNDebug.h"

#define kFluidTypeBitMask 0xF

@implementation NSData (CGMParser)

#pragma mark - General Methods

- (BOOL)comfirmCRC;
{
    return YES;
}

#pragma mark - CGM Measurement Characteristic

- (NSDictionary*)parseMeasurementCharacteristicDetails:(BOOL)crcPresent;
{
    // TODO add CRC checking
    BOOL crcFailed = NO;
    
//    NSUInteger charSize = [self parseMeasurementCharacteristicSize];
    NSUInteger flags = [self parseMeasurementCharacteristicFlags];
    NSNumber *glucoseConcentration = [self parseGlucoseConcentration];
    NSUInteger timeOffset = [self parseMeasurementTimeOffest];
    NSMutableDictionary *measurementDetails = [NSMutableDictionary dictionaryWithObjectsAndKeys: glucoseConcentration, kCGMMeasurementKeyGlucoseConcentration, @(timeOffset), kCGMKeyTimeOffset, nil];
    NSUInteger currentByteIndex = kCGMMeasurementFieldRangeTimeOffset.location + kCGMMeasurementFieldRangeTimeOffset.length;
    
    NSDictionary *measurementStatusDict = [self parseStatusStartByte: currentByteIndex
                                                 warningOctetPresent: (flags & CGMMeasurementFlagsWarningOctetPresent)
                                                 calTempOctetPresent: (flags & CGMMeasurementFlagsCalTempOctetPresent)
                                                  statusOctetPresent: (flags & CGMMeasurementFlagsStatusOctetPresent)];
    if (measurementStatusDict && [measurementStatusDict count] != 0) {
        measurementDetails[kCGMStatusKeySensorStatus] = measurementStatusDict;
    }

    currentByteIndex += ((flags & CGMMeasurementFlagsWarningOctetPresent) != NO) + ((flags & CGMMeasurementFlagsCalTempOctetPresent) != NO) + ((flags & CGMMeasurementFlagsStatusOctetPresent) != NO);
    if (flags & CGMMeasurementFlagsTrendInformationPresent) {
        NSNumber *trendInfo = [self parseMeasurementTrendInformation:currentByteIndex];
        measurementDetails[kCGMMeasurementKeyTrendInfo] = trendInfo;
        currentByteIndex += kCGMMeasurementFieldSizeTrendInfo;
    }
    
    if (flags & CGMMeasurementFlagsQualityPresent) {
        NSNumber *measurementQuality = [self parseMeasurementQuality:currentByteIndex];
        measurementDetails[kCGMMeasurementKeyQuality] = measurementQuality;
        currentByteIndex += kCGMMeasurementFieldSizeQuality;
    }
    
    
    //TODO update CRC calculation
    if (crcPresent) {
        measurementDetails[kCGMCRCFailed] = @(crcFailed);
    }
    
    return measurementDetails;
}

- (NSUInteger)parseMeasurementCharacteristicSize;
{
    return [self unsignedIntegerAtRange:kCGMMeasurementFieldRangeSize];
}

- (NSUInteger)parseMeasurementCharacteristicFlags;
{
    return [self unsignedIntegerAtRange:kCGMMeasurementFieldRangeFlags];
}

- (NSNumber*)parseGlucoseConcentration;
{
    float glucoseConcentration = [self shortFloatAtRange:kCGMMeasurementFieldRangeGlucoseConcentration];
    return @(glucoseConcentration);
}

- (NSUInteger)parseMeasurementTimeOffest;
{
    return [self unsignedIntegerAtRange:kCGMMeasurementFieldRangeTimeOffset];
}

- (NSNumber*)parseMeasurementTrendInformation:(NSUInteger)startByte;
{
    NSRange trendRange = {startByte, 2};
    float trend = [self shortFloatAtRange:trendRange];
    
    return @(trend);
}
- (NSNumber*)parseMeasurementQuality:(NSUInteger)startByte;
{
    NSRange qualityRange = {startByte, 2};
    float quality = [self shortFloatAtRange:qualityRange];
    
    return @(quality);
}

#pragma mark - CGM Feature Characteristic

- (NSDictionary*)parseFeatureCharacteristicDetails;
{
    // TODO add CRC checking
    
    NSUInteger feature = [self parseFeatures];
    NSUInteger fluidType = [self parseFluidTypeWithRange:kCGMFeatureFieldRangeTypeLocation];
    NSUInteger sampleLocation = [self parseSampleLocationWithRange:kCGMFeatureFieldRangeTypeLocation];
    NSDictionary *featureDetails = @{kCGMFeatureKeyFeatures: @(feature),
                                     kCGMFeatureKeyFluidType: @(fluidType),
                                     kCGMFeatureKeySampleLocation: @(sampleLocation)};
    return featureDetails;
}

- (NSUInteger)parseFeatures;
{
    return [self unsignedIntegerAtRange:kCGMFeatureFieldRangeFeatures];
}

- (NSUInteger)parseFluidTypeWithRange:(NSRange)range;
{
    NSUInteger typeAndLocation = [self unsignedIntegerAtRange: range];
    // Remove location using bit mask
    NSUInteger fluidType = typeAndLocation & kFluidTypeBitMask;
    
    return fluidType;
}

- (NSUInteger)parseSampleLocationWithRange:(NSRange)range;
{
    NSUInteger typeAndLocation = [self unsignedIntegerAtRange: range];
    // Remove type using bit shifting
    NSUInteger sampleLocation = typeAndLocation >> 4;
    
    return sampleLocation;
}

#pragma mark - CGM Status

- (NSDictionary*)parseStatusCharacteristicDetails:(BOOL)crcPresent;
{
    // TODO add CRC checking
    
    NSUInteger timeOffset = [self parseStatusTimeOffest];
    NSDictionary *status = [self parseStatusStartByte:kCGMStatusFieldRangeStatus.location
                                  warningOctetPresent:YES
                                  calTempOctetPresent:YES
                                   statusOctetPresent:YES];
    NSDictionary *statusDetails = @{kCGMStatusKeySensorStatus: status,
                                    kCGMKeyTimeOffset: @(timeOffset)};
    
    return statusDetails;
}

- (NSDictionary*)parseStatusStartByte:(NSUInteger)startByte
                  warningOctetPresent:(BOOL)warningPresent
                  calTempOctetPresent:(BOOL)calTempPresent
                   statusOctetPresent:(BOOL)statusPresent;
{
    NSMutableDictionary *statusDict = [NSMutableDictionary dictionary];
    
    if (statusPresent) {
        NSUInteger statusOctet = [self unsignedIntegerAtRange:(NSRange){startByte,kCGMStatusFieldSizeOctet}];
        statusDict[kCGMStatusKeyOctetStatus] = @(statusOctet);
        startByte++;
    }
    
    if (calTempPresent) {
        NSUInteger calTempOctet = [self unsignedIntegerAtRange:(NSRange){startByte,kCGMStatusFieldSizeOctet}];
        statusDict[kCGMStatusKeyOctetCalTemp] = @(calTempOctet);
        startByte++;
    }
    
    if (warningPresent) {
        NSUInteger warningOctet = [self unsignedIntegerAtRange:(NSRange){startByte,kCGMStatusFieldSizeOctet}];
        statusDict[kCGMStatusKeyOctetWarning] = @(warningOctet);
    }
    
    return statusDict;
}

- (NSUInteger)parseStatusTimeOffest;
{
    return [self unsignedIntegerAtRange:kCGMStatusFieldRangeTimeOffset];
}

#pragma mark - CGM Session Start Time

- (NSDate*)parseSessionStartTime:(BOOL)crcPresent;
{
    // TODO add CRC checking
    
    NSUInteger year = [self unsignedIntegerAtRange:kCGMSessionStartTimeFieldRangeYear];
    NSUInteger month = [self unsignedIntegerAtRange:kCGMSessionStartTimeFieldRangeMonth];
    NSUInteger day = [self unsignedIntegerAtRange:kCGMSessionStartTimeFieldRangeDay];
    
    if (year == 0 || month == 0 || day == 0) {
        // Session start time is not known
        return nil;
    }
    
    NSUInteger hours = [self unsignedIntegerAtRange:kCGMSessionStartTimeFieldRangeHour];
    NSUInteger minutes = [self unsignedIntegerAtRange:kCGMSessionStartTimeFieldRangeMinute];
    NSUInteger seconds = [self unsignedIntegerAtRange:kCGMSessionStartTimeFieldRangeSecond];
    NSTimeInterval timeZoneOffsetInHours = [self integerAtRange:kCGMSessionStartTimeFieldRangeTimeZone] / kCGMTimeZoneStepSizeMin60;
    NSTimeZone *timeZone = [NSTimeZone timeZoneForSecondsFromGMT:(timeZoneOffsetInHours * kSecondsInHour)];
    NSInteger dstOffsetCode = [self unsignedIntegerAtRange:kCGMSessionStartTimeFieldRangeDSTOffset];
    
    NSTimeInterval dstOffsetInSeconds = 0.;
    if ((dstOffsetCode == DSTStandardTime) && ([timeZone daylightSavingTimeOffset] == 0)) {
        dstOffsetInSeconds = [timeZone daylightSavingTimeOffset];
    } else if ((dstOffsetCode == DSTPlusHourHalf) && ([timeZone daylightSavingTimeOffset] != (kSecondsInHour / 2.))) {
        dstOffsetInSeconds = [timeZone daylightSavingTimeOffset] - (kSecondsInHour / 2.);
    } else if ((dstOffsetCode == DSTPlusHourOne) && ([timeZone daylightSavingTimeOffset] != kSecondsInHour)) {
        dstOffsetInSeconds = [timeZone daylightSavingTimeOffset] - kSecondsInHour;
    } else if ((dstOffsetCode == DSTPlusHoursTwo) && ([timeZone daylightSavingTimeOffset] != (kSecondsInHour * 2))) {
        dstOffsetInSeconds = [timeZone daylightSavingTimeOffset] - (kSecondsInHour * 2);
    }
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setCalendar:calendar];
    [components setYear:year];
    [components setMonth:month];
    [components setDay:day];
    [components setHour:hours];
    [components setMinute:minutes];
    [components setSecond:seconds - dstOffsetInSeconds];
    [components setTimeZone:timeZone];
    
    NSDate *sessionStartTime = [calendar dateFromComponents:components];
    
    return sessionStartTime;
}

#pragma mark - CGM Session Run Time

- (NSTimeInterval)parseSessionRunTimeOffset: (BOOL)crcPresent;
{
    // TODO add CRC checking
    
    return [self unsignedIntegerAtRange:kCGMSessionRunTimeFieldRangeRunTime] * kSecondsInHour;
}

#pragma mark - CGM Specific Ops Control Point

- (NSDictionary*)parseCGMCPResponse: (BOOL)crcPresent;
{
    // TODO add CRC checking
    
    CGMCPOpCode opCode = [self parseCGMCPOpCode];
    NSMutableDictionary *responseDict = [NSMutableDictionary dictionaryWithObject:@(opCode) forKey:kCGMCPKeyOpCode];
    switch (opCode) {
        case CGMCPOpCodeResponse:
        {
            NSDictionary *responseDetails = [self parseCGMCPResponseDetails];
            responseDict[kCGMCPKeyResponseDetails] = responseDetails;
            break;
        }
        case CGMCPOpCodeCommIntervalResponse:
        {
            NSUInteger commInterval = [self parseCommInterval];
            responseDict[kCGMCPKeyOperand] = @(commInterval);
            break;
        }
        case CGMCPOpCodeAlertLevelPatientHighResponse:
        case CGMCPOpCodeAlertLevelPatientLowResponse:
        case CGMCPOpCodeAlertLevelHypoReponse:
        case CGMCPOpCodeAlertLevelHyperReponse:
        case CGMCPOpCodeAlertLevelRateDecreaseResponse:
        case CGMCPOpCodeAlertLevelRateIncreaseResponse:
        {
            float operand = [self parseCGMCPShortFloatOperand];
            responseDict[kCGMCPKeyOperand] = @(operand);
            break;
        }
        case CGMCPOpCodeCalibrationValueResponse:
        {
            NSDictionary *calibrationDetails = [self parseCalibrationDetails];
            responseDict[kCGMCPKeyResponseCalibration] = calibrationDetails;
            break;
        }
        default:
            DLog(@"Do not know about CGMCP operation with code %d", opCode);
            break;
    }
    return responseDict;
}

- (NSUInteger)parseCGMCPOpCode;
{
    return [self unsignedIntegerAtRange:kCGMCPFieldRangeOpCode];
}

- (NSDictionary*)parseCGMCPResponseDetails;
{
    CGMCPOpCode requestOpCode = [self parseCGMCPRequestOpCode];
    CGMCPResponseCode responseValue = [self parseCGMCPResponseCodeValue];
    return @{kCGMCPKeyResponseRequestOpCode: @(requestOpCode), kCGMCPKeyResponseCodeValue: @(responseValue)};
}

- (CGMCPOpCode)parseCGMCPRequestOpCode;
{
    CGMCPOpCode requestOpCode = [self unsignedIntegerAtRange:kCGMCPFieldRangeResponseRequestOpCode];
    return requestOpCode;
}

- (CGMCPResponseCode)parseCGMCPResponseCodeValue;
{
    CGMCPResponseCode responseCode = [self unsignedIntegerAtRange:kCGMCPFieldRangeResponseCodeValue];
    return responseCode;
}

- (NSUInteger)parseCommInterval;
{
    return [self unsignedIntegerAtRange:kCGMCPFieldRangeCommIntervalResponse];
}

- (float)parseCGMCPShortFloatOperand;
{
    return [self shortFloatAtRange:kCGMCPFieldRangeSFloatResponse];
}

- (NSDictionary*)parseCalibrationDetails;
{
    float value = [self shortFloatAtRange:kCGMCPFieldRangeCalibrationGlucoseConcentration];
    NSUInteger timeOffet = [self unsignedIntegerAtRange:kCGMCPFieldRangeCalibrationTime];
    NSUInteger fluidType = [self parseFluidTypeWithRange:kCGMCPFieldRangeCalibrationTypeLocation];
    NSUInteger sampleLocation = [self parseSampleLocationWithRange:kCGMCPFieldRangeCalibrationTypeLocation];
    NSUInteger nextCalibrationTimeOffset = [self unsignedIntegerAtRange:kCGMCPFieldRangeCalibrationTimeNext];
    NSUInteger recordNumber = [self unsignedIntegerAtRange:kCGMCPFieldRangeCalibrationRecordNumber];
    NSUInteger status = [self unsignedIntegerAtRange:kCGMCPFieldRangeCalibrationStatus];
    NSDictionary *calibrationDetails = @{kCGMCalibrationKeyValue: @(value),
                                         kCGMKeyTimeOffset: @(timeOffet),
                                         kCGMCalibrationKeyFluidType: @(fluidType),
                                         kCGMCalibrationKeySampleLocation: @(sampleLocation),
                                         kCGMKeyTimeOffsetNext: @(nextCalibrationTimeOffset),
                                         kCGMCalibrationKeyRecordNumber: @(recordNumber),
                                         kCGMCalibrationKeyStatus: @(status)};
    
    return calibrationDetails;
}

@end
