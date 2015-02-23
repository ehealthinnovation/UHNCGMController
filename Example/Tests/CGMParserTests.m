//
//  UHNCGMParserTests.m
//  UHNCGMControllerTests
//
//  Created by Nathaniel Hamming on 02/17/2015.
//  Copyright (c) 2015 University Health Network.
//

#import <UHNCGMController/NSData+CGMParser.h>
#import <UHNBLEController/UHNBLETypes.h>
#import <UHNCGMController/NSData+CGMCommands.h>

SpecBegin(CGMParserSpecs)

describe(@"CGM measurement characteristic response parsing", ^{
    it(@"should parse a measurement with basic information", ^{
        uint8_t size = 6;
        uint8_t flag = 0x00;
        uint8_t glucose = 140;
        uint8_t timeOffset = 5;
        
        NSData *measurementData = [NSData dataWithBytes:(char[]){size, flag, glucose, 0x00, timeOffset, 0x00} length:size];
        NSDictionary *measurementDetails = [measurementData parseMeasurementCharacteristicDetails:NO];
        expect(measurementDetails[kCGMMeasurementKeyGlucoseConcentration]).to.equal(glucose);
        expect(measurementDetails[kCGMKeyTimeOffset]).to.equal(timeOffset);
    });

    it(@"should parse a measurement with status octet", ^{
        uint8_t size = 7;
        uint8_t flag = 0x80;
        uint8_t glucose = 141;
        uint8_t timeOffset = 10;
        uint8_t statusOctet = 0x03; // session stopped & battery low
        
        NSData *measurementData = [NSData dataWithBytes:(char[]){size, flag, glucose, 0x00, timeOffset, 0x00, statusOctet} length:size];
        NSDictionary *measurementDetails = [measurementData parseMeasurementCharacteristicDetails:NO];
        expect(measurementDetails[kCGMMeasurementKeyGlucoseConcentration]).to.equal(glucose);
        expect(measurementDetails[kCGMKeyTimeOffset]).to.equal(timeOffset);
        expect(measurementDetails[kCGMStatusKeySensorStatus][kCGMStatusKeyOctetStatus]).to.equal(statusOctet);
    });
    
    it(@"should parse a measurement with status and warning octet", ^{
        uint8_t size = 8;
        uint8_t flag = 0xA0;
        uint8_t glucose = 142;
        uint8_t timeOffset = 15;
        uint8_t statusOctet = 0x03; // session stopped & battery low
        uint8_t warningOctet = 0x05; // patient low & hypo
        
        NSData *measurementData = [NSData dataWithBytes:(char[]){size, flag, glucose, 0x00, timeOffset, 0x00, statusOctet, warningOctet} length:size];
        NSDictionary *measurementDetails = [measurementData parseMeasurementCharacteristicDetails:NO];
        expect(measurementDetails[kCGMMeasurementKeyGlucoseConcentration]).to.equal(glucose);
        expect(measurementDetails[kCGMKeyTimeOffset]).to.equal(timeOffset);
        expect(measurementDetails[kCGMStatusKeySensorStatus][kCGMStatusKeyOctetStatus]).to.equal(statusOctet);
        expect(measurementDetails[kCGMStatusKeySensorStatus][kCGMStatusKeyOctetWarning]).to.equal(warningOctet);
    });

    it(@"should parse a measurement with warning and cal/temp octet", ^{
        uint8_t size = 8;
        uint8_t flag = 0x60;
        uint8_t glucose = 143;
        uint8_t timeOffset = 20;
        uint8_t calTempOctet = 0x08; // calibration required
        uint8_t warningOctet = 0x05; // patient low & hypo
        
        NSData *measurementData = [NSData dataWithBytes:(char[]){size, flag, glucose, 0x00, timeOffset, 0x00, calTempOctet, warningOctet} length:size];
        NSDictionary *measurementDetails = [measurementData parseMeasurementCharacteristicDetails:NO];
        expect(measurementDetails[kCGMMeasurementKeyGlucoseConcentration]).to.equal(glucose);
        expect(measurementDetails[kCGMKeyTimeOffset]).to.equal(timeOffset);
        expect(measurementDetails[kCGMStatusKeySensorStatus][kCGMStatusKeyOctetCalTemp]).to.equal(calTempOctet);
        expect(measurementDetails[kCGMStatusKeySensorStatus][kCGMStatusKeyOctetWarning]).to.equal(warningOctet);
    });
    
    it(@"should parse a measurement with all status octets", ^{
        uint8_t size = 9;
        uint8_t flag = 0xE0;
        uint8_t glucose = 144;
        uint8_t timeOffset = 25;
        uint8_t statusOctet = 0x03; // session stopped & battery low
        uint8_t calTempOctet = 0x08; // calibration required
        uint8_t warningOctet = 0x05; // patient low & hypo
        
        NSData *measurementData = [NSData dataWithBytes:(char[]){size, flag, glucose, 0x00, timeOffset, 0x00, statusOctet, calTempOctet, warningOctet} length:size];
        NSDictionary *measurementDetails = [measurementData parseMeasurementCharacteristicDetails:NO];
        expect(measurementDetails[kCGMMeasurementKeyGlucoseConcentration]).to.equal(glucose);
        expect(measurementDetails[kCGMKeyTimeOffset]).to.equal(timeOffset);
        expect(measurementDetails[kCGMStatusKeySensorStatus][kCGMStatusKeyOctetStatus]).to.equal(statusOctet);
        expect(measurementDetails[kCGMStatusKeySensorStatus][kCGMStatusKeyOctetCalTemp]).to.equal(calTempOctet);
        expect(measurementDetails[kCGMStatusKeySensorStatus][kCGMStatusKeyOctetWarning]).to.equal(warningOctet);
    });
    
    it(@"should parse a measurement with trend", ^{
        uint8_t size = 8;
        uint8_t flag = 0x01;
        uint8_t glucose = 145;
        uint8_t timeOffset = 30;
        uint8_t trend = 9;
        
        NSData *measurementData = [NSData dataWithBytes:(char[]){size, flag, glucose, 0x00, timeOffset, 0x00, trend, 0x00} length:size];
        NSDictionary *measurementDetails = [measurementData parseMeasurementCharacteristicDetails:NO];
        expect(measurementDetails[kCGMMeasurementKeyGlucoseConcentration]).to.equal(glucose);
        expect(measurementDetails[kCGMKeyTimeOffset]).to.equal(timeOffset);
        expect(measurementDetails[kCGMMeasurementKeyTrendInfo]).to.equal(trend);
    });
    
    it(@"should parse a measurement with quality", ^{
        uint8_t size = 8;
        uint8_t flag = 0x02;
        uint8_t glucose = 146;
        uint8_t timeOffset = 35;
        uint8_t quality = 94;
        
        NSData *measurementData = [NSData dataWithBytes:(char[]){size, flag, glucose, 0x00, timeOffset, 0x00, quality, 0x00} length:size];
        NSDictionary *measurementDetails = [measurementData parseMeasurementCharacteristicDetails:NO];
        expect(measurementDetails[kCGMMeasurementKeyGlucoseConcentration]).to.equal(glucose);
        expect(measurementDetails[kCGMKeyTimeOffset]).to.equal(timeOffset);
        expect(measurementDetails[kCGMMeasurementKeyQuality]).to.equal(quality);
    });

    it(@"should parse a measurement with all information", ^{
        uint8_t size = 13;
        uint8_t flag = 0xE3;
        uint8_t glucose = 147;
        uint8_t timeOffset = 40;
        uint8_t statusOctet = 0x03; // session stopped & battery low
        uint8_t calTempOctet = 0x08; // calibration required
        uint8_t warningOctet = 0x05; // patient low & hypo
        uint8_t trend = 10;
        uint8_t quality = 95;
        
        NSData *measurementData = [NSData dataWithBytes:(char[]){size, flag, glucose, 0x00, timeOffset, 0x00, statusOctet, calTempOctet, warningOctet, trend, 0x00, quality, 0x00} length:size];
        NSDictionary *measurementDetails = [measurementData parseMeasurementCharacteristicDetails:NO];
        expect(measurementDetails[kCGMMeasurementKeyGlucoseConcentration]).to.equal(glucose);
        expect(measurementDetails[kCGMKeyTimeOffset]).to.equal(timeOffset);
        expect(measurementDetails[kCGMStatusKeySensorStatus][kCGMStatusKeyOctetStatus]).to.equal(statusOctet);
        expect(measurementDetails[kCGMStatusKeySensorStatus][kCGMStatusKeyOctetCalTemp]).to.equal(calTempOctet);
        expect(measurementDetails[kCGMStatusKeySensorStatus][kCGMStatusKeyOctetWarning]).to.equal(warningOctet);
        expect(measurementDetails[kCGMMeasurementKeyTrendInfo]).to.equal(trend);
        expect(measurementDetails[kCGMMeasurementKeyQuality]).to.equal(quality);
    });

});

describe(@"CGM feature characteristic response parsing", ^{
    it(@"should parse features with basic support", ^{
        uint8_t size = 6;
        uint8_t feature1 = 0x01; // calibration supported
        uint8_t feature2 = 0x00;
        uint8_t feature3 = 0x00;
        GlucoseFluidTypeOption type = GlucoseFluidTypeISF;
        GlucoseSampleLocationOption location = GlucoseSampleLocationSubcutaneousTissue;
        uint8_t jointValue;
        [[NSData joinFluidType:type sampleLocation:location] getBytes:&jointValue];
        uint16_t crc = 0xFFFF;
        
        NSData *featureData = [NSData dataWithBytes:(char[]){feature1, feature2, feature3, jointValue, crc, (crc >> 8)} length:size];
        NSDictionary *featureDetails = [featureData parseFeatureCharacteristicDetails];
        expect(featureDetails[kCGMFeatureKeyFeatures]).to.equal(1);
        expect(featureDetails[kCGMFeatureKeyFluidType]).to.equal(type);
        expect(featureDetails[kCGMFeatureKeySampleLocation]).to.equal(location);
    });
    
    it(@"should parse features with full support", ^{
        uint8_t size = 6;
        uint8_t feature1 = 0xFF;
        uint8_t feature2 = 0xFF;
        uint8_t feature3 = 0x01;
        GlucoseFluidTypeOption type = GlucoseFluidTypePlasmaCapillary;
        GlucoseSampleLocationOption location = GlucoseSampleLocationFinger;
        uint8_t jointValue;
        [[NSData joinFluidType:type sampleLocation:location] getBytes:&jointValue];
        uint16_t crc = 0xFFFF;
        
        NSData *featureData = [NSData dataWithBytes:(char[]){feature1, feature2, feature3, jointValue, crc, (crc >> 8)} length:size];
        NSDictionary *featureDetails = [featureData parseFeatureCharacteristicDetails];
        expect(featureDetails[kCGMFeatureKeyFeatures]).to.equal(131071);
        expect(featureDetails[kCGMFeatureKeyFluidType]).to.equal(type);
        expect(featureDetails[kCGMFeatureKeySampleLocation]).to.equal(location);
    });
});

describe(@"CGM status characteristic response parsing", ^{
    
    it(@"should parse status with status octet", ^{
        uint8_t size = 5;
        uint8_t timeOffset = 5;
        uint8_t statusOctet = 0x03; // session stopped & battery low
        uint8_t calTempOctet = 0x00;
        uint8_t warningOctet = 0x00;
        
        NSData *statusData = [NSData dataWithBytes:(char[]){timeOffset, 0x00, statusOctet, calTempOctet, warningOctet} length:size];
        NSDictionary *statusDetails = [statusData parseStatusCharacteristicDetails:NO];
        expect(statusDetails[kCGMKeyTimeOffset]).to.equal(timeOffset);
        expect(statusDetails[kCGMStatusKeySensorStatus][kCGMStatusKeyOctetStatus]).to.equal(statusOctet);
        expect(statusDetails[kCGMStatusKeySensorStatus][kCGMStatusKeyOctetCalTemp]).to.equal(calTempOctet);
        expect(statusDetails[kCGMStatusKeySensorStatus][kCGMStatusKeyOctetWarning]).to.equal(warningOctet);
    });
    
    it(@"should parse status with cal/temp octet", ^{
        uint8_t size = 5;
        uint8_t timeOffset = 10;
        uint8_t statusOctet = 0x00;
        uint8_t calTempOctet = 0x08; // calibration required
        uint8_t warningOctet = 0x00;
        
        NSData *statusData = [NSData dataWithBytes:(char[]){timeOffset, 0x00, statusOctet, calTempOctet, warningOctet} length:size];
        NSDictionary *statusDetails = [statusData parseStatusCharacteristicDetails:NO];
        expect(statusDetails[kCGMKeyTimeOffset]).to.equal(timeOffset);
        expect(statusDetails[kCGMStatusKeySensorStatus][kCGMStatusKeyOctetStatus]).to.equal(statusOctet);
        expect(statusDetails[kCGMStatusKeySensorStatus][kCGMStatusKeyOctetCalTemp]).to.equal(calTempOctet);
        expect(statusDetails[kCGMStatusKeySensorStatus][kCGMStatusKeyOctetWarning]).to.equal(warningOctet);
    });
    
    it(@"should parse status with warning octet", ^{
        uint8_t size = 5;
        uint8_t timeOffset = 15;
        uint8_t statusOctet = 0x00;
        uint8_t calTempOctet = 0x00;
        uint8_t warningOctet = 0x05; // patient low & hypo
        
        NSData *statusData = [NSData dataWithBytes:(char[]){timeOffset, 0x00, statusOctet, calTempOctet, warningOctet} length:size];
        NSDictionary *statusDetails = [statusData parseStatusCharacteristicDetails:NO];
        expect(statusDetails[kCGMKeyTimeOffset]).to.equal(timeOffset);
        expect(statusDetails[kCGMStatusKeySensorStatus][kCGMStatusKeyOctetStatus]).to.equal(statusOctet);
        expect(statusDetails[kCGMStatusKeySensorStatus][kCGMStatusKeyOctetCalTemp]).to.equal(calTempOctet);
        expect(statusDetails[kCGMStatusKeySensorStatus][kCGMStatusKeyOctetWarning]).to.equal(warningOctet);
    });
    
    it(@"should parse status with all information", ^{
        uint8_t size = 5;
        uint8_t timeOffset = 20;
        uint8_t statusOctet = 0x03; // session stopped & battery low
        uint8_t calTempOctet = 0x08; // calibration required
        uint8_t warningOctet = 0x05; // patient low & hypo
        
        NSData *statusData = [NSData dataWithBytes:(char[]){timeOffset, 0x00, statusOctet, calTempOctet, warningOctet} length:size];
        NSDictionary *statusDetails = [statusData parseStatusCharacteristicDetails:NO];
        expect(statusDetails[kCGMKeyTimeOffset]).to.equal(timeOffset);
        expect(statusDetails[kCGMStatusKeySensorStatus][kCGMStatusKeyOctetStatus]).to.equal(statusOctet);
        expect(statusDetails[kCGMStatusKeySensorStatus][kCGMStatusKeyOctetCalTemp]).to.equal(calTempOctet);
        expect(statusDetails[kCGMStatusKeySensorStatus][kCGMStatusKeyOctetWarning]).to.equal(warningOctet);
    });
});

describe(@"CGM session start and run time characteristics response parsing", ^{
    it(@"should parse the session start time characteristic", ^{
        uint8_t size = 9;
        
        // get the actual values for a time of now.
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSUInteger const kComponentBits = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                                           | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitTimeZone);
        NSDateComponents *components = [cal components:kComponentBits fromDate: [NSDate date]];
        uint16_t year = components.year;
        uint8_t month = components.month;
        uint8_t day = components.day;
        uint8_t hour = components.hour;
        uint8_t minute = components.minute;
        uint8_t second = components.second;
        
        NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
        NSInteger secFromGMT = [localTimeZone secondsFromGMT];
        float hourFromGMT = secFromGMT / kSecondsInHour;
        uint8_t timeZoneValue = hourFromGMT * kCGMTimeZoneStepSizeMin60;
        
        NSTimeInterval daylightOffset = [localTimeZone daylightSavingTimeOffset];

        NSDate *date = [cal dateFromComponents:components];
        
        NSData *sessionStartTimeData = [NSData dataWithBytes:(char[]){year, (year >> 8), month, day, hour, minute, second, timeZoneValue, daylightOffset} length:size];
        NSDate *sessionStartTime = [sessionStartTimeData parseSessionStartTime:NO];
        expect(sessionStartTime).to.equal(date);
    });

    it(@"should parse the session run time characteristic", ^{
        uint8_t size = 2;
        uint16_t timeOffset = 7 * 24; // 1 week. units is hour
        NSTimeInterval timeOffsetInSecs = timeOffset * kSecondsInHour;
        
        NSData *sessionRunTimeData = [NSData dataWithBytes:(char[]){timeOffset, (timeOffset >> 8)} length:size];
        NSTimeInterval sessionRunTime = [sessionRunTimeData parseSessionRunTimeOffset:NO];
        expect(sessionRunTime).to.equal(timeOffsetInSecs);
    });
});

describe(@"CGM specific ops control point characteristic response parsing", ^{
   it(@"should parse a CGMCP general response with success", ^{
       uint8_t size = 3;
       CGMCPOpCode responseOpCode = CGMCPOpCodeResponse;
       CGMCPOpCode requestedOpCode = CGMCPOpCodeSessionStart;
       CGMCPResponseCode responseCode = CGMCPSuccess;

       NSData *responseData = [NSData dataWithBytes:(char[]){responseOpCode, requestedOpCode, responseCode} length:size];
       NSDictionary *responseDetails = [responseData parseCGMCPResponse:NO];
       expect(responseDetails[kCGMCPKeyOpCode]).to.equal(responseOpCode);
       expect(responseDetails[kCGMCPKeyResponseDetails][kCGMCPKeyResponseRequestOpCode]).to.equal(requestedOpCode);
       expect(responseDetails[kCGMCPKeyResponseDetails][kCGMCPKeyResponseCodeValue]).to.equal(responseCode);
   });

    it(@"should parse a CGMCP general response with op code not supported", ^{
        uint8_t size = 3;
        CGMCPOpCode responseOpCode = CGMCPOpCodeResponse;
        CGMCPOpCode requestedOpCode = CGMCPOpCodeAlertLevelPatientHighSet;
        CGMCPResponseCode responseCode = CGMCPOpCodeNotSupported;
        
        NSData *responseData = [NSData dataWithBytes:(char[]){responseOpCode, requestedOpCode, responseCode} length:size];
        NSDictionary *responseDetails = [responseData parseCGMCPResponse:NO];
        expect(responseDetails[kCGMCPKeyOpCode]).to.equal(responseOpCode);
        expect(responseDetails[kCGMCPKeyResponseDetails][kCGMCPKeyResponseRequestOpCode]).to.equal(requestedOpCode);
        expect(responseDetails[kCGMCPKeyResponseDetails][kCGMCPKeyResponseCodeValue]).to.equal(responseCode);
    });

    it(@"should parse a CGMCP general response with invalid operand", ^{
        uint8_t size = 3;
        CGMCPOpCode responseOpCode = CGMCPOpCodeResponse;
        CGMCPOpCode requestedOpCode = CGMCPOpCodeAlertLevelPatientLowSet;
        CGMCPResponseCode responseCode = CGMCPInvalidOperand;
        
        NSData *responseData = [NSData dataWithBytes:(char[]){responseOpCode, requestedOpCode, responseCode} length:size];
        NSDictionary *responseDetails = [responseData parseCGMCPResponse:NO];
        expect(responseDetails[kCGMCPKeyOpCode]).to.equal(responseOpCode);
        expect(responseDetails[kCGMCPKeyResponseDetails][kCGMCPKeyResponseRequestOpCode]).to.equal(requestedOpCode);
        expect(responseDetails[kCGMCPKeyResponseDetails][kCGMCPKeyResponseCodeValue]).to.equal(responseCode);
    });

    it(@"should parse a CGMCP general response with procedure not completed", ^{
        uint8_t size = 3;
        CGMCPOpCode responseOpCode = CGMCPOpCodeResponse;
        CGMCPOpCode requestedOpCode = CGMCPOpCodeSessionStop;
        CGMCPResponseCode responseCode = CGMCPProcedureNotCompleted;
        
        NSData *responseData = [NSData dataWithBytes:(char[]){responseOpCode, requestedOpCode, responseCode} length:size];
        NSDictionary *responseDetails = [responseData parseCGMCPResponse:NO];
        expect(responseDetails[kCGMCPKeyOpCode]).to.equal(responseOpCode);
        expect(responseDetails[kCGMCPKeyResponseDetails][kCGMCPKeyResponseRequestOpCode]).to.equal(requestedOpCode);
        expect(responseDetails[kCGMCPKeyResponseDetails][kCGMCPKeyResponseCodeValue]).to.equal(responseCode);
    });
    
    it(@"should parse a CGMCP general response with parameter out of range", ^{
        uint8_t size = 3;
        CGMCPOpCode responseOpCode = CGMCPOpCodeResponse;
        CGMCPOpCode requestedOpCode = CGMCPOpCodeAlertLevelRateIncreaseSet;
        CGMCPResponseCode responseCode = CGMCPParameterOutOfRange;
        
        NSData *responseData = [NSData dataWithBytes:(char[]){responseOpCode, requestedOpCode, responseCode} length:size];
        NSDictionary *responseDetails = [responseData parseCGMCPResponse:NO];
        expect(responseDetails[kCGMCPKeyOpCode]).to.equal(responseOpCode);
        expect(responseDetails[kCGMCPKeyResponseDetails][kCGMCPKeyResponseRequestOpCode]).to.equal(requestedOpCode);
        expect(responseDetails[kCGMCPKeyResponseDetails][kCGMCPKeyResponseCodeValue]).to.equal(responseCode);
    });
    
    it(@"should parse a CGMCP get communication interval", ^{
        uint8_t size = 2;
        CGMCPOpCode responseOpCode = CGMCPOpCodeCommIntervalResponse;
        uint8_t operand = 10;
        
        NSData *responseData = [NSData dataWithBytes:(char[]){responseOpCode, operand} length:size];
        NSDictionary *responseDetails = [responseData parseCGMCPResponse:NO];
        expect(responseDetails[kCGMCPKeyOpCode]).to.equal(responseOpCode);
        expect(responseDetails[kCGMCPKeyOperand]).to.equal(operand);
    });
    
    it(@"should parse a CGMCP get an accepted and validated calibration value", ^{
        uint8_t size = 11;
        uint8_t glucose = 140;
        uint8_t calibrationTime = 50;
        uint8_t calibrationTimeNext = 250;
        uint8_t recordNumber = 1;
        uint8_t status = 0x00; // calibration was valid and accepted
        GlucoseFluidTypeOption type = GlucoseFluidTypePlasmaCapillary;
        GlucoseSampleLocationOption location = GlucoseSampleLocationFinger;
        uint8_t jointValue;
        [[NSData joinFluidType:type sampleLocation:location] getBytes:&jointValue];
        CGMCPOpCode responseOpCode = CGMCPOpCodeCalibrationValueResponse;
        
        NSData *responseData = [NSData dataWithBytes:(char[]){responseOpCode, glucose, 0x00, calibrationTime, 0x00, jointValue, calibrationTimeNext, 0x00, recordNumber, 0x00, status} length:size];
        NSDictionary *responseDetails = [responseData parseCGMCPResponse:NO];
        expect(responseDetails[kCGMCPKeyOpCode]).to.equal(responseOpCode);
        expect(responseDetails[kCGMCPKeyResponseCalibration][kCGMCalibrationKeyValue]).to.equal(glucose);
        expect(responseDetails[kCGMCPKeyResponseCalibration][kCGMCalibrationKeyFluidType]).to.equal(type);
        expect(responseDetails[kCGMCPKeyResponseCalibration][kCGMCalibrationKeySampleLocation]).to.equal(location);
        expect(responseDetails[kCGMCPKeyResponseCalibration][kCGMCalibrationKeyRecordNumber]).to.equal(recordNumber);
        expect(responseDetails[kCGMCPKeyResponseCalibration][kCGMCalibrationKeyStatus]).to.equal(status);
        expect(responseDetails[kCGMCPKeyResponseCalibration][kCGMKeyTimeOffset]).to.equal(calibrationTime);
        expect(responseDetails[kCGMCPKeyResponseCalibration][kCGMKeyTimeOffsetNext]).to.equal(calibrationTimeNext);
    });
    
    it(@"should parse a CGMCP get a rejected calibration value", ^{
        uint8_t size = 11;
        uint8_t glucose = 141;
        uint8_t calibrationTime = 51;
        uint8_t calibrationTimeNext = 251;
        uint8_t recordNumber = 2;
        uint8_t status = 0x01; // calibration rejected
        GlucoseFluidTypeOption type = GlucoseFluidTypePlasmaCapillary;
        GlucoseSampleLocationOption location = GlucoseSampleLocationFinger;
        uint8_t jointValue;
        [[NSData joinFluidType:type sampleLocation:location] getBytes:&jointValue];
        CGMCPOpCode responseOpCode = CGMCPOpCodeCalibrationValueResponse;
        
        NSData *responseData = [NSData dataWithBytes:(char[]){responseOpCode, glucose, 0x00, calibrationTime, 0x00, jointValue, calibrationTimeNext, 0x00, recordNumber, 0x00, status} length:size];
        NSDictionary *responseDetails = [responseData parseCGMCPResponse:NO];
        expect(responseDetails[kCGMCPKeyOpCode]).to.equal(responseOpCode);
        expect(responseDetails[kCGMCPKeyResponseCalibration][kCGMCalibrationKeyValue]).to.equal(glucose);
        expect(responseDetails[kCGMCPKeyResponseCalibration][kCGMCalibrationKeyFluidType]).to.equal(type);
        expect(responseDetails[kCGMCPKeyResponseCalibration][kCGMCalibrationKeySampleLocation]).to.equal(location);
        expect(responseDetails[kCGMCPKeyResponseCalibration][kCGMCalibrationKeyRecordNumber]).to.equal(recordNumber);
        expect(responseDetails[kCGMCPKeyResponseCalibration][kCGMCalibrationKeyStatus]).to.equal(status);
        expect(responseDetails[kCGMCPKeyResponseCalibration][kCGMKeyTimeOffset]).to.equal(calibrationTime);
        expect(responseDetails[kCGMCPKeyResponseCalibration][kCGMKeyTimeOffsetNext]).to.equal(calibrationTimeNext);
    });
    
    it(@"should parse a CGMCP get a out-of-range calibration value", ^{
        uint8_t size = 11;
        uint8_t glucose = 142;
        uint8_t calibrationTime = 52;
        uint8_t calibrationTimeNext = 252;
        uint8_t recordNumber = 3;
        uint8_t status = 0x02; // calibration out-of-range
        GlucoseFluidTypeOption type = GlucoseFluidTypePlasmaCapillary;
        GlucoseSampleLocationOption location = GlucoseSampleLocationFinger;
        uint8_t jointValue;
        [[NSData joinFluidType:type sampleLocation:location] getBytes:&jointValue];
        CGMCPOpCode responseOpCode = CGMCPOpCodeCalibrationValueResponse;
        
        NSData *responseData = [NSData dataWithBytes:(char[]){responseOpCode, glucose, 0x00, calibrationTime, 0x00, jointValue, calibrationTimeNext, 0x00, recordNumber, 0x00, status} length:size];
        NSDictionary *responseDetails = [responseData parseCGMCPResponse:NO];
        expect(responseDetails[kCGMCPKeyOpCode]).to.equal(responseOpCode);
        expect(responseDetails[kCGMCPKeyResponseCalibration][kCGMCalibrationKeyValue]).to.equal(glucose);
        expect(responseDetails[kCGMCPKeyResponseCalibration][kCGMCalibrationKeyFluidType]).to.equal(type);
        expect(responseDetails[kCGMCPKeyResponseCalibration][kCGMCalibrationKeySampleLocation]).to.equal(location);
        expect(responseDetails[kCGMCPKeyResponseCalibration][kCGMCalibrationKeyRecordNumber]).to.equal(recordNumber);
        expect(responseDetails[kCGMCPKeyResponseCalibration][kCGMCalibrationKeyStatus]).to.equal(status);
        expect(responseDetails[kCGMCPKeyResponseCalibration][kCGMKeyTimeOffset]).to.equal(calibrationTime);
        expect(responseDetails[kCGMCPKeyResponseCalibration][kCGMKeyTimeOffsetNext]).to.equal(calibrationTimeNext);
    });
    
    it(@"should parse a CGMCP get a process pending calibration value", ^{
        uint8_t size = 11;
        uint8_t glucose = 143;
        uint8_t calibrationTime = 53;
        uint8_t calibrationTimeNext = 253;
        uint8_t recordNumber = 4;
        uint8_t status = 0x04; // calibration process pending
        GlucoseFluidTypeOption type = GlucoseFluidTypePlasmaCapillary;
        GlucoseSampleLocationOption location = GlucoseSampleLocationFinger;
        uint8_t jointValue;
        [[NSData joinFluidType:type sampleLocation:location] getBytes:&jointValue];
        CGMCPOpCode responseOpCode = CGMCPOpCodeCalibrationValueResponse;
        
        NSData *responseData = [NSData dataWithBytes:(char[]){responseOpCode, glucose, 0x00, calibrationTime, 0x00, jointValue, calibrationTimeNext, 0x00, recordNumber, 0x00, status} length:size];
        NSDictionary *responseDetails = [responseData parseCGMCPResponse:NO];
        expect(responseDetails[kCGMCPKeyOpCode]).to.equal(responseOpCode);
        expect(responseDetails[kCGMCPKeyResponseCalibration][kCGMCalibrationKeyValue]).to.equal(glucose);
        expect(responseDetails[kCGMCPKeyResponseCalibration][kCGMCalibrationKeyFluidType]).to.equal(type);
        expect(responseDetails[kCGMCPKeyResponseCalibration][kCGMCalibrationKeySampleLocation]).to.equal(location);
        expect(responseDetails[kCGMCPKeyResponseCalibration][kCGMCalibrationKeyRecordNumber]).to.equal(recordNumber);
        expect(responseDetails[kCGMCPKeyResponseCalibration][kCGMCalibrationKeyStatus]).to.equal(status);
        expect(responseDetails[kCGMCPKeyResponseCalibration][kCGMKeyTimeOffset]).to.equal(calibrationTime);
        expect(responseDetails[kCGMCPKeyResponseCalibration][kCGMKeyTimeOffsetNext]).to.equal(calibrationTimeNext);
    });

    it(@"should parse a CGMCP get patient high alert level", ^{
        uint8_t size = 3;
        CGMCPOpCode responseOpCode = CGMCPOpCodeAlertLevelPatientHighResponse;
        uint8_t operand = 180;
        
        NSData *responseData = [NSData dataWithBytes:(char[]){responseOpCode, operand, 0x00} length:size];
        NSDictionary *responseDetails = [responseData parseCGMCPResponse:NO];
        expect(responseDetails[kCGMCPKeyOpCode]).to.equal(responseOpCode);
        expect(responseDetails[kCGMCPKeyOperand]).to.equal(operand);
    });
    
    it(@"should parse a CGMCP get patient low alert level", ^{
        uint8_t size = 3;
        CGMCPOpCode responseOpCode = CGMCPOpCodeAlertLevelPatientLowResponse;
        uint8_t operand = 80;
        
        NSData *responseData = [NSData dataWithBytes:(char[]){responseOpCode, operand, 0x00} length:size];
        NSDictionary *responseDetails = [responseData parseCGMCPResponse:NO];
        expect(responseDetails[kCGMCPKeyOpCode]).to.equal(responseOpCode);
        expect(responseDetails[kCGMCPKeyOperand]).to.equal(operand);
    });
    
    it(@"should parse a CGMCP get hypo alert level", ^{
        uint8_t size = 3;
        CGMCPOpCode responseOpCode = CGMCPOpCodeAlertLevelHypoReponse;
        uint8_t operand = 40;
        
        NSData *responseData = [NSData dataWithBytes:(char[]){responseOpCode, operand, 0x00} length:size];
        NSDictionary *responseDetails = [responseData parseCGMCPResponse:NO];
        expect(responseDetails[kCGMCPKeyOpCode]).to.equal(responseOpCode);
        expect(responseDetails[kCGMCPKeyOperand]).to.equal(operand);
    });
    
    it(@"should parse a CGMCP get hyper alert level", ^{
        uint8_t size = 3;
        CGMCPOpCode responseOpCode = CGMCPOpCodeAlertLevelHyperReponse;
        uint8_t operand = 250;
        
        NSData *responseData = [NSData dataWithBytes:(char[]){responseOpCode, operand, 0x00} length:size];
        NSDictionary *responseDetails = [responseData parseCGMCPResponse:NO];
        expect(responseDetails[kCGMCPKeyOpCode]).to.equal(responseOpCode);
        expect(responseDetails[kCGMCPKeyOperand]).to.equal(operand);
    });
    
    it(@"should parse a CGMCP get rate decrease alert level", ^{
        uint8_t size = 3;
        CGMCPOpCode responseOpCode = CGMCPOpCodeAlertLevelRateDecreaseResponse;
        uint8_t operand = 20;
        
        NSData *responseData = [NSData dataWithBytes:(char[]){responseOpCode, operand, 0x00} length:size];
        NSDictionary *responseDetails = [responseData parseCGMCPResponse:NO];
        expect(responseDetails[kCGMCPKeyOpCode]).to.equal(responseOpCode);
        expect(responseDetails[kCGMCPKeyOperand]).to.equal(operand);
    });
    
    it(@"should parse a CGMCP get rate increase alert level", ^{
        uint8_t size = 3;
        CGMCPOpCode responseOpCode = CGMCPOpCodeAlertLevelRateIncreaseResponse;
        uint8_t operand = 30;
        
        NSData *responseData = [NSData dataWithBytes:(char[]){responseOpCode, operand, 0x00} length:size];
        NSDictionary *responseDetails = [responseData parseCGMCPResponse:NO];
        expect(responseDetails[kCGMCPKeyOpCode]).to.equal(responseOpCode);
        expect(responseDetails[kCGMCPKeyOperand]).to.equal(operand);
    });
});

SpecEnd