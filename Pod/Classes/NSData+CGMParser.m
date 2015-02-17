//
//  NSData+CGMParser.m
//  CGM_Collector
//
//  Created by Nathaniel Hamming on 2015-01-06.
//  Copyright (c) 2015 eHealth. All rights reserved.
//

#import "NSData+CGMParser.h"
#import "NSData+ConversionExtensions.h"
#import "UHNDebug.h"

@implementation NSData (CGMParser)

#pragma mark - General Methods
- (BOOL)comfirmCRC;
{
    return YES;
}

#pragma mark - CGM Measurement Characteristic
- (NSDictionary*)parseMeasurementCharacteristicDetails: (BOOL)crcPresent;
{
    // TODO add CRC checking
    BOOL crcFailed = NO;
    
    NSUInteger charSize = [self parseMeasurementCharacteristicSize];
    NSUInteger flags = [self parseMeasurementCharacteristicFlags];
    NSNumber *glucoseConcentration = [self parseGlucoseConcentration];
    NSUInteger timeOffset = [self parseMeasurementTimeOffest];
    NSMutableDictionary *measurementDetails = [NSMutableDictionary dictionaryWithObjectsAndKeys: glucoseConcentration, kCGMMeasurementKeyGlucoseConcentration, [NSNumber numberWithUnsignedInteger: timeOffset], kCGMKeyTimeOffset, nil];
    NSUInteger currentByteIndex = (NSRange)kCGMMeasurementFieldRangeTimeOffset.location + (NSRange)kCGMMeasurementFieldRangeTimeOffset.length;
    
    NSDictionary *measurementStatusDict = [self parseStatusStartByte: currentByteIndex
                                                 warningOctetPresent: (flags & kCGMMeasurementFlagsWarningOctetPresent)
                                                 calTempOctetPresent: (flags & kCGMMeasurementFlagsCalTempOctetPresent)
                                                  statusOctetPresent: (flags & kCGMMeasurementFlagsStatusOctetPresent)];
    if (measurementStatusDict && [measurementStatusDict count] != 0) {
        [measurementDetails setObject: measurementStatusDict forKey: kCGMStatusKeySensorStatus];
    }

    currentByteIndex += ((flags & kCGMMeasurementFlagsWarningOctetPresent) != 0) + ((flags & kCGMMeasurementFlagsCalTempOctetPresent) != 0) + ((flags & kCGMMeasurementFlagsStatusOctetPresent) != 0);
    if (flags & kCGMMeasurementFlagsTrendInformationPresent) {
        NSNumber *trendInfo = [self parseMeasurementTrendInformation: currentByteIndex];
        [measurementDetails setObject: trendInfo forKey: kCGMMeasurementKeyTrendInfo];
        currentByteIndex += kCGMMeasurementFieldSizeTrendInfo;
    }
    
    if (flags & kCGMMeasurementFlagsQualityPresent) {
        NSNumber *measurementQuality = [self parseMeasurementQuality: currentByteIndex];
        [measurementDetails setObject: measurementQuality forKey: kCGMMeasurementKeyQuality];
        currentByteIndex += kCGMMeasurementFieldSizeQuality;
    }
    
    if (crcPresent) {
        [measurementDetails setObject: [NSNumber numberWithBool: crcFailed] forKey: kCGMMeasurementkeyCRCFailed];
    }
    
    return measurementDetails;
}

- (NSUInteger)parseMeasurementCharacteristicSize;
{
    return [self unsignedIntegerAtRange: (NSRange)kCGMMeasurementFieldRangeSize];
}

- (NSUInteger)parseMeasurementCharacteristicFlags;
{
    return [self unsignedIntegerAtRange: (NSRange)kCGMMeasurementFieldRangeFlags];
}

- (NSNumber*)parseGlucoseConcentration;
{
    float glucoseConcentration = [self shortFloatAtRange: (NSRange)kCGMMeasurementFieldRangeGlucoseConcentration];
    return [NSNumber numberWithFloat: glucoseConcentration];
}

- (NSUInteger)parseMeasurementTimeOffest;
{
    return [self unsignedIntegerAtRange: (NSRange)kCGMMeasurementFieldRangeTimeOffset];
}

- (NSNumber*)parseMeasurementTrendInformation: (NSUInteger)startByte;
{
    NSRange trendRange = {startByte, 2};
    float trend = [self shortFloatAtRange: trendRange];
    
    return [NSNumber numberWithFloat: trend];
}
- (NSNumber*)parseMeasurementQuality: (NSUInteger)startByte;
{
    NSRange qualityRange = {startByte, 2};
    float quality = [self shortFloatAtRange: qualityRange];
    
    return [NSNumber numberWithFloat: quality];
}

#pragma mark - CGM Feature Characteristic
- (NSDictionary*)parseFeatureCharacteristicDetails;
{
    // TODO add CRC checking
    
    NSUInteger feature = [self parseFeatures];
    NSUInteger fluidType = [self parseFluidTypeWithRange: (NSRange)kCGMFeatureFieldRangeTypeLocation];
    NSUInteger sampleLocation = [self parseSampleLocationWithRange: (NSRange)kCGMFeatureFieldRangeTypeLocation];
    NSDictionary *featureDetails = @{kCGMFeatureKeyFeatures: [NSNumber numberWithUnsignedInteger: feature],
                                     kCGMFeatureKeyFluidType: [NSNumber numberWithUnsignedInteger: fluidType],
                                     kCGMFeatureKeySampleLocation: [NSNumber numberWithUnsignedInteger: sampleLocation]};
    return featureDetails;
}

- (NSUInteger)parseFeatures;
{
    return [self unsignedIntegerAtRange: (NSRange)kCGMFeatureFieldRangeFeatures];
}

- (NSUInteger)parseFluidTypeWithRange: (NSRange)range;
{
    NSUInteger typeAndLocation = [self unsignedIntegerAtRange: range];
    // Remove location using bit mask
    NSUInteger fluidType = typeAndLocation & 15;
    
    return fluidType;
}

- (NSUInteger)parseSampleLocationWithRange: (NSRange)range;
{
    NSUInteger typeAndLocation = [self unsignedIntegerAtRange: range];
    // Remove type using bit shifting
    NSUInteger sampleLocation = typeAndLocation >> 4;
    
    return sampleLocation;
}

#pragma mark - CGM Status
- (NSDictionary*)parseStatusCharacteristicDetails: (BOOL)crcPresent;
{
    // TODO add CRC checking
    
    NSUInteger timeOffset = [self parseStatusTimeOffest];
    NSDictionary *status = [self parseStatusStartByte: (NSRange)kCGMStatusFieldRangeStatus.location
                                  warningOctetPresent: YES
                                  calTempOctetPresent: YES
                                   statusOctetPresent: YES];
    NSDictionary *statusDetails = @{kCGMStatusKeySensorStatus: status,
                                    kCGMKeyTimeOffset: [NSNumber numberWithUnsignedInteger: timeOffset]};
    
    return statusDetails;
}

- (NSDictionary*)parseStatusStartByte: (NSUInteger)startByte
                  warningOctetPresent: (BOOL)warningPresent
                  calTempOctetPresent: (BOOL)calTempPresent
                   statusOctetPresent: (BOOL)statusPresent;
{
    NSMutableDictionary *statusDict = [NSMutableDictionary dictionary];
    
    if (statusPresent) {
        NSUInteger statusOctet = [self unsignedIntegerAtRange: (NSRange){startByte,1}];
        [statusDict setObject: [NSNumber numberWithInteger: statusOctet] forKey: kCGMStatusKeyOctetStatus];
        startByte++;
    }
    
    if (calTempPresent) {
        NSUInteger calTempOctet = [self unsignedIntegerAtRange: (NSRange){startByte,1}];
        [statusDict setObject: [NSNumber numberWithInteger: calTempOctet] forKey: kCGMStatusKeyOctetCalTemp];
        startByte++;
    }
    
    if (warningPresent) {
        NSUInteger warningOctet = [self unsignedIntegerAtRange: (NSRange){startByte,1}];
        [statusDict setObject: [NSNumber numberWithInteger: warningOctet] forKey: kCGMStatusKeyOctetWarning];
    }
    
    return statusDict;
}

- (NSUInteger)parseStatusTimeOffest;
{
    return [self unsignedIntegerAtRange: (NSRange)kCGMStatusFieldRangeTimeOffset];
}

#pragma mark - CGM Session Start Time
- (NSDate*)parseSessionStartTime: (BOOL)crcPresent;
{
    // TODO add CRC checking
    
    NSUInteger year = [self unsignedIntegerAtRange: (NSRange)kCGMSessionStartTimeFieldRangeYear];
    NSUInteger month = [self unsignedIntegerAtRange: (NSRange)kCGMSessionStartTimeFieldRangeMonth];
    NSUInteger day = [self unsignedIntegerAtRange: (NSRange)kCGMSessionStartTimeFieldRangeDay];
    
    if (year == 0 || month == 0 || day == 0) {
        // Session start time is not known
        return nil;
    }
    
    NSUInteger hours = [self unsignedIntegerAtRange: (NSRange)kCGMSessionStartTimeFieldRangeHour];
    NSUInteger minutes = [self unsignedIntegerAtRange: (NSRange)kCGMSessionStartTimeFieldRangeMinute];
    NSUInteger seconds = [self unsignedIntegerAtRange: (NSRange)kCGMSessionStartTimeFieldRangeSecond];
    NSTimeInterval timeZoneOffsetInHours = [self integerAtRange: (NSRange)kCGMSessionStartTimeFieldRangeTimeZone] / kCGMTimeZoneStepSize;
    NSTimeZone *timeZone = [NSTimeZone timeZoneForSecondsFromGMT: (timeZoneOffsetInHours * kSecondsInHour)];
    NSInteger dstOffsetCode = [self unsignedIntegerAtRange: (NSRange)kCGMSessionStartTimeFieldRangeDSTOffset];
    
    NSTimeInterval dstOffsetInSeconds = 0.;
    if ((dstOffsetCode == kDSTStandardTime) && ([timeZone daylightSavingTimeOffset] == 0)) {
        dstOffsetInSeconds = [timeZone daylightSavingTimeOffset];
    } else if ((dstOffsetCode == kDSTPlusHourHalf) && ([timeZone daylightSavingTimeOffset] != (kSecondsInHour / 2.))) {
        dstOffsetInSeconds = [timeZone daylightSavingTimeOffset] - (kSecondsInHour / 2.);
    } else if ((dstOffsetCode == kDSTPlusHourOne) && ([timeZone daylightSavingTimeOffset] != kSecondsInHour)) {
        dstOffsetInSeconds = [timeZone daylightSavingTimeOffset] - kSecondsInHour;
    } else if ((dstOffsetCode == kDSTPlusHoursTwo) && ([timeZone daylightSavingTimeOffset] != (kSecondsInHour * 2))) {
        dstOffsetInSeconds = [timeZone daylightSavingTimeOffset] - (kSecondsInHour * 2);
    }
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setCalendar:calendar];
    [components setYear: year];
    [components setMonth: month];
    [components setDay: day];
    [components setHour: hours];
    [components setMinute: minutes];
    [components setSecond: seconds - dstOffsetInSeconds];
    [components setTimeZone: timeZone];
    
    NSDate *sessionStartTime = [calendar dateFromComponents:components];
    
    return sessionStartTime;
}

#pragma mark - CGM Session Run Time
- (NSTimeInterval)parseSessionRunTimeOffset: (BOOL)crcPresent;
{
    // TODO add CRC checking
    
    return [self unsignedIntegerAtRange: (NSRange)kCGMSessionRunTimeFieldRangeRunTime] * kSecondsInHour;
}

#pragma mark - CGM Specific Ops Control Point
- (NSDictionary*)parseCGMCPResponse: (BOOL)crcPresent;
{
    // TODO add CRC checking
    
    CGMCPOpCode opCode = [self parseCGMCPOpCode];
    NSMutableDictionary *responseDict = [NSMutableDictionary dictionaryWithObject: [NSNumber numberWithUnsignedInteger: opCode] forKey: kCGMCPKeyOpCode];
    switch (opCode) {
        case kCGMCPOpCodeResponse:
        {
            NSDictionary *responseDetails = [self parseCGMCPResponseDetails];
            [responseDict setObject: responseDetails forKey: kCGMCPKeyResponseDetails];
            break;
        }
        case kCGMCPOpCodeCommIntervalResponse:
        {
            NSUInteger commInterval = [self parseCommInterval];
            [responseDict setObject: [NSNumber numberWithUnsignedInteger: commInterval] forKey: kCGMCPKeyOperand];
            break;
        }
        case kCGMCPOpCodeAlertLevelPatientHighResponse:
        case kCGMCPOpCodeAlertLevelPatientLowResponse:
        case kCGMCPOpCodeAlertLevelHypoReponse:
        case kCGMCPOpCodeAlertLevelHyperReponse:
        case kCGMCPOpCodeAlertLevelRateDecreaseResponse:
        case kCGMCPOpCodeAlertLevelRateIncreaseResponse:
        {
            float operand = [self parseCGMCPShortFloatOperand];
            [responseDict setObject: [NSNumber numberWithFloat: operand] forKey: kCGMCPKeyOperand];
            break;
        }
        case kCGMCPOpCodeCalibrationValueResponse:
        {
            NSDictionary *calibrationDetails = [self parseCalibrationDetails];
            [responseDict setObject: calibrationDetails forKey: kCGMCPKeyResponseCalibration];
        }
        default:
            DLog(@"Do not know about CGMCP operation with code %d", opCode);
            break;
    }
    return responseDict;
}

- (NSUInteger)parseCGMCPOpCode;
{
    return [self unsignedIntegerAtRange: (NSRange)kCGMCPFieldRangeOpCode];
}

- (NSDictionary*)parseCGMCPResponseDetails;
{
    CGMCPOpCode requestOpCode = [self parseCGMCPRequestOpCode];
    CGMCPResponseCode responseValue = [self parseCGMCPResponseCodeValue];
    return @{kCGMCPKeyResponseRequestOpCode: [NSNumber numberWithUnsignedInteger: requestOpCode], kCGMCPKeyResponseCodeValue: [NSNumber numberWithUnsignedInteger: responseValue]};
}

- (CGMCPOpCode)parseCGMCPRequestOpCode;
{
    CGMCPOpCode requestOpCode = [self unsignedIntegerAtRange: (NSRange)kCGMCPFieldRangeResponseRequestOpCode];
    return requestOpCode;
}

- (CGMCPResponseCode)parseCGMCPResponseCodeValue;
{
    CGMCPResponseCode responseCode = [self unsignedIntegerAtRange: (NSRange)kCGMCPFieldRangeResponseCodeValue];
    return responseCode;
}

- (NSUInteger)parseCommInterval;
{
    return [self unsignedIntegerAtRange: (NSRange)kCGMCPFieldRangeCommIntervalResponse];
}

- (float)parseCGMCPShortFloatOperand;
{
    return [self shortFloatAtRange: (NSRange)kCGMCPFieldRangeSFloatResponse];
}

- (NSDictionary*)parseCalibrationDetails;
{
    float value = [self shortFloatAtRange: (NSRange)kCGMCPFieldRangeCalibrationGlucoseConcentration];
    NSUInteger timeOffet = [self unsignedIntegerAtRange: (NSRange)kCGMCPFieldRangeCalibrationTime];
    NSUInteger fluidType = [self parseFluidTypeWithRange: (NSRange)kCGMCPFieldRangeCalibrationTypeLocation];
    NSUInteger sampleLocation = [self parseSampleLocationWithRange: (NSRange)kCGMCPFieldRangeCalibrationTypeLocation];
    NSUInteger nextCalibrationTimeOffset = [self unsignedIntegerAtRange: (NSRange)kCGMCPFieldRangeCalibrationTimeNext];
    NSUInteger recordNumber = [self unsignedIntegerAtRange: (NSRange)kCGMCPFieldRangeCalibrationRecordNumber];
    NSUInteger status = [self unsignedIntegerAtRange: (NSRange)kCGMCPFieldRangeCalibrationStatus];
    NSDictionary *calibrationDetails = @{kCGMCalibrationKeyValue: [NSNumber numberWithFloat: value],
                                         kCGMCalibrationKeyTimeOffset: [NSNumber numberWithUnsignedInteger: timeOffet],
                                         kCGMCalibrationKeyFluidType: [NSNumber numberWithUnsignedInteger: fluidType],
                                         kCGMCalibrationKeySampleLocation: [NSNumber numberWithUnsignedInteger: sampleLocation],
                                         kCGMCalibrationKeyTimeOffsetNext: [NSNumber numberWithUnsignedInteger: nextCalibrationTimeOffset],
                                         kCGMCalibrationKeyRecordNumber: [NSNumber numberWithUnsignedInteger: recordNumber],
                                         kCGMCalibrationKeyStatus: [NSNumber numberWithUnsignedInteger: status]};
    
    return calibrationDetails;
}

@end
