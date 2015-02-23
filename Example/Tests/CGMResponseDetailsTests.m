//
//  CGMResponseDetailsTests.m
//  UHNCGMControllerTests
//
//  Created by Nathaniel Hamming on 02/17/2015.
//  Copyright (c) 2015 University Health Network.
//

#import <UHNCGMController/NSData+CGMParser.h>
#import <UHNCGMController/NSDictionary+CGMExtensions.h>
#import <UHNBLEController/UHNBLETypes.h>
#import <UHNCGMController/NSData+CGMCommands.h>


SpecBegin(CGMResponseDetailsSpecs)

describe(@"CGM measurement details dictionary queries", ^{
    it(@"should query the measurement details for the basic information", ^{
        uint8_t size = 6;
        uint8_t flag = 0x00;
        uint8_t glucose = 140;
        uint8_t timeOffset = 5;
        
        NSData *measurementData = [NSData dataWithBytes:(char[]){size, flag, glucose, 0x00, timeOffset, 0x00} length:size];
        NSDictionary *measurementDetails = [measurementData parseMeasurementCharacteristicDetails:NO];
        expect([measurementDetails glucoseValue]).to.equal(glucose);
        expect([measurementDetails measurementTimeOffset]).to.equal(timeOffset);
        expect([measurementDetails didCRCFail]).to.beFalsy;
        expect([measurementDetails hasSessionStopped]).to.beFalsy;
        expect([measurementDetails isDeviceBatteryLow]).to.beFalsy;
        expect([measurementDetails hasExceededLevelPatientLow]).to.beFalsy;
        expect([measurementDetails hasExceededLevelHypo]).to.beFalsy;
        expect([measurementDetails isCalibrationRequired]).to.beFalsy;
        expect([measurementDetails trendValue]).to.equal(nil);
        expect([measurementDetails qualityValue]).to.equal(nil);
        expect([measurementDetails measurementDateTime]).to.equal(nil);
    });
    
    it(@"should query the measurement details for a status octet", ^{
        uint8_t size = 7;
        uint8_t flag = 0x80;
        uint8_t glucose = 141;
        uint8_t timeOffset = 10;
        uint8_t statusOctet = 0x03; // session stopped & battery low
        
        NSData *measurementData = [NSData dataWithBytes:(char[]){size, flag, glucose, 0x00, timeOffset, 0x00, statusOctet} length:size];
        NSDictionary *measurementDetails = [measurementData parseMeasurementCharacteristicDetails:NO];
        expect([measurementDetails glucoseValue]).to.equal(glucose);
        expect([measurementDetails measurementTimeOffset]).to.equal(timeOffset);
        expect([measurementDetails didCRCFail]).to.beFalsy;
        expect([measurementDetails hasSessionStopped]).to.beTruthy;
        expect([measurementDetails isDeviceBatteryLow]).to.beTruthy;
        expect([measurementDetails hasExceededLevelPatientLow]).to.beFalsy;
        expect([measurementDetails hasExceededLevelHypo]).to.beFalsy;
        expect([measurementDetails isCalibrationRequired]).to.beFalsy;
        expect([measurementDetails trendValue]).to.equal(nil);
        expect([measurementDetails qualityValue]).to.equal(nil);
        expect([measurementDetails measurementDateTime]).to.equal(nil);
    });
    
    it(@"should query the measurement details for a status and warning octet", ^{
        uint8_t size = 8;
        uint8_t flag = 0xA0;
        uint8_t glucose = 142;
        uint8_t timeOffset = 15;
        uint8_t statusOctet = 0x03; // session stopped & battery low
        uint8_t warningOctet = 0x05; // patient low & hypo
        
        NSData *measurementData = [NSData dataWithBytes:(char[]){size, flag, glucose, 0x00, timeOffset, 0x00, statusOctet, warningOctet} length:size];
        NSDictionary *measurementDetails = [measurementData parseMeasurementCharacteristicDetails:NO];
        expect([measurementDetails glucoseValue]).to.equal(glucose);
        expect([measurementDetails measurementTimeOffset]).to.equal(timeOffset);
        expect([measurementDetails didCRCFail]).to.beFalsy;
        expect([measurementDetails hasSessionStopped]).to.beTruthy;
        expect([measurementDetails isDeviceBatteryLow]).to.beTruthy;
        expect([measurementDetails hasExceededLevelPatientLow]).to.beTruthy;
        expect([measurementDetails hasExceededLevelHypo]).to.beTruthy;
        expect([measurementDetails isCalibrationRequired]).to.beFalsy;
        expect([measurementDetails trendValue]).to.equal(nil);
        expect([measurementDetails qualityValue]).to.equal(nil);
        expect([measurementDetails measurementDateTime]).to.equal(nil);
    });
    
    it(@"should query the measurement details for a warning and cal/temp octet", ^{
        uint8_t size = 8;
        uint8_t flag = 0x60;
        uint8_t glucose = 143;
        uint8_t timeOffset = 20;
        uint8_t calTempOctet = 0x08; // calibration required
        uint8_t warningOctet = 0x05; // patient low & hypo
        
        NSData *measurementData = [NSData dataWithBytes:(char[]){size, flag, glucose, 0x00, timeOffset, 0x00, calTempOctet, warningOctet} length:size];
        NSDictionary *measurementDetails = [measurementData parseMeasurementCharacteristicDetails:NO];
        expect([measurementDetails glucoseValue]).to.equal(glucose);
        expect([measurementDetails measurementTimeOffset]).to.equal(timeOffset);
        expect([measurementDetails didCRCFail]).to.beFalsy;
        expect([measurementDetails hasSessionStopped]).to.beFalsy;
        expect([measurementDetails isDeviceBatteryLow]).to.beFalsy;
        expect([measurementDetails hasExceededLevelPatientLow]).to.beTruthy;
        expect([measurementDetails hasExceededLevelHypo]).to.beTruthy;
        expect([measurementDetails isCalibrationRequired]).to.beTruthy;
        expect([measurementDetails trendValue]).to.equal(nil);
        expect([measurementDetails qualityValue]).to.equal(nil);
        expect([measurementDetails measurementDateTime]).to.equal(nil);
    });
    
    it(@"should query the measurement details for all status octets", ^{
        uint8_t size = 9;
        uint8_t flag = 0xE0;
        uint8_t glucose = 144;
        uint8_t timeOffset = 25;
        uint8_t statusOctet = 0x03; // session stopped & battery low
        uint8_t calTempOctet = 0x08; // calibration required
        uint8_t warningOctet = 0x05; // patient low & hypo
        
        NSData *measurementData = [NSData dataWithBytes:(char[]){size, flag, glucose, 0x00, timeOffset, 0x00, statusOctet, calTempOctet, warningOctet} length:size];
        NSDictionary *measurementDetails = [measurementData parseMeasurementCharacteristicDetails:NO];
        expect([measurementDetails glucoseValue]).to.equal(glucose);
        expect([measurementDetails measurementTimeOffset]).to.equal(timeOffset);
        expect([measurementDetails didCRCFail]).to.beFalsy;
        expect([measurementDetails hasSessionStopped]).to.beTruthy;
        expect([measurementDetails isDeviceBatteryLow]).to.beTruthy;
        expect([measurementDetails hasExceededLevelPatientLow]).to.beTruthy;
        expect([measurementDetails hasExceededLevelHypo]).to.beTruthy;
        expect([measurementDetails isCalibrationRequired]).to.beTruthy;
        expect([measurementDetails trendValue]).to.equal(nil);
        expect([measurementDetails qualityValue]).to.equal(nil);
        expect([measurementDetails measurementDateTime]).to.equal(nil);
    });
    
    it(@"should query the measurement details for a trend", ^{
        uint8_t size = 8;
        uint8_t flag = 0x01;
        uint8_t glucose = 145;
        uint8_t timeOffset = 30;
        uint8_t trend = 9;
        
        NSData *measurementData = [NSData dataWithBytes:(char[]){size, flag, glucose, 0x00, timeOffset, 0x00, trend, 0x00} length:size];
        NSDictionary *measurementDetails = [measurementData parseMeasurementCharacteristicDetails:NO];
        expect([measurementDetails glucoseValue]).to.equal(glucose);
        expect([measurementDetails measurementTimeOffset]).to.equal(timeOffset);
        expect([measurementDetails didCRCFail]).to.beFalsy;
        expect([measurementDetails hasSessionStopped]).to.beFalsy;
        expect([measurementDetails isDeviceBatteryLow]).to.beFalsy;
        expect([measurementDetails hasExceededLevelPatientLow]).to.beFalsy;
        expect([measurementDetails hasExceededLevelHypo]).to.beFalsy;
        expect([measurementDetails isCalibrationRequired]).to.beFalsy;
        expect([measurementDetails trendValue]).to.equal(trend);
        expect([measurementDetails qualityValue]).to.equal(nil);
        expect([measurementDetails measurementDateTime]).to.equal(nil);
    });
    
    it(@"should query the measurement details for a quality", ^{
        uint8_t size = 8;
        uint8_t flag = 0x02;
        uint8_t glucose = 146;
        uint8_t timeOffset = 35;
        uint8_t quality = 94;
        
        NSData *measurementData = [NSData dataWithBytes:(char[]){size, flag, glucose, 0x00, timeOffset, 0x00, quality, 0x00} length:size];
        NSDictionary *measurementDetails = [measurementData parseMeasurementCharacteristicDetails:NO];
        expect([measurementDetails glucoseValue]).to.equal(glucose);
        expect([measurementDetails measurementTimeOffset]).to.equal(timeOffset);
        expect([measurementDetails didCRCFail]).to.beFalsy;
        expect([measurementDetails hasSessionStopped]).to.beFalsy;
        expect([measurementDetails isDeviceBatteryLow]).to.beFalsy;
        expect([measurementDetails hasExceededLevelPatientLow]).to.beFalsy;
        expect([measurementDetails hasExceededLevelHypo]).to.beFalsy;
        expect([measurementDetails isCalibrationRequired]).to.beFalsy;
        expect([measurementDetails trendValue]).to.equal(nil);
        expect([measurementDetails qualityValue]).to.equal(quality);
        expect([measurementDetails measurementDateTime]).to.equal(nil);
    });
    
    it(@"should query the measurement details for all information", ^{
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
        expect([measurementDetails glucoseValue]).to.equal(glucose);
        expect([measurementDetails measurementTimeOffset]).to.equal(timeOffset);
        expect([measurementDetails didCRCFail]).to.beFalsy;
        expect([measurementDetails hasSessionStopped]).to.beTruthy;
        expect([measurementDetails isDeviceBatteryLow]).to.beTruthy;
        expect([measurementDetails hasExceededLevelPatientLow]).to.beTruthy;
        expect([measurementDetails hasExceededLevelHypo]).to.beTruthy;
        expect([measurementDetails isCalibrationRequired]).to.beTruthy;
        expect([measurementDetails trendValue]).to.equal(trend);
        expect([measurementDetails qualityValue]).to.equal(quality);
        expect([measurementDetails measurementDateTime]).to.equal(nil);
    });
});

describe(@"CGM feature details dictionary queries", ^{
    it(@"should query the feature details with no additional support", ^{
        uint8_t size = 6;
        uint8_t feature1 = 0x00;
        uint8_t feature2 = 0x00;
        uint8_t feature3 = 0x00;
        GlucoseFluidTypeOption type = GlucoseFluidTypeISF;
        GlucoseSampleLocationOption location = GlucoseSampleLocationSubcutaneousTissue;
        uint8_t jointValue;
        [[NSData joinFluidType:type sampleLocation:location] getBytes:&jointValue];
        uint16_t crc = 0xFFFF;
        
        NSData *featureData = [NSData dataWithBytes:(char[]){feature1, feature2, feature3, jointValue, crc, (crc >> 8)} length:size];
        NSDictionary *featureDetails = [featureData parseFeatureCharacteristicDetails];
        expect([featureDetails supportsCalibration]).to.beFalsy;
        expect([featureDetails supportsAlertLowHighPatient]).to.beFalsy;
        expect([featureDetails supportsAlertHypo]).to.beFalsy;
        expect([featureDetails supportsAlertHyper]).to.beFalsy;
        expect([featureDetails supportsAlertIncreaseDecreaseRate]).to.beFalsy;
        expect([featureDetails supportsAlertDeviceSpecific]).to.beFalsy;
        expect([featureDetails supportsSensorDetectionMalfunction]).to.beFalsy;
        expect([featureDetails supportsSensorDetectionLowHighTemp]).to.beFalsy;
        expect([featureDetails supportsSensorDetectionLowHighResult]).to.beFalsy;
        expect([featureDetails supportsSensorDetectionTypeError]).to.beFalsy;
        expect([featureDetails supportsSensorLowBattery]).to.beFalsy;
        expect([featureDetails supportsGeneralDeviceFault]).to.beFalsy;
        expect([featureDetails supportsE2ECRC]).to.beFalsy;
        expect([featureDetails supportsMultipleBond]).to.beFalsy;
        expect([featureDetails supportsMultipleSession]).to.beFalsy;
        expect([featureDetails supportsCGMTrend]).to.beFalsy;
        expect([featureDetails supportsCGMQuality]).to.beFalsy;
        expect([featureDetails glucoseFluidType]).to.equal(type);
        expect([featureDetails glucoseSampleLocation]).to.equal(location);
    });
    
    it(@"should query the feature details with full support", ^{
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
        expect([featureDetails supportsCalibration]).to.beTruthy;
        expect([featureDetails supportsAlertLowHighPatient]).to.beTruthy;
        expect([featureDetails supportsAlertHypo]).to.beTruthy;
        expect([featureDetails supportsAlertHyper]).to.beTruthy;
        expect([featureDetails supportsAlertIncreaseDecreaseRate]).to.beTruthy;
        expect([featureDetails supportsAlertDeviceSpecific]).to.beTruthy;
        expect([featureDetails supportsSensorDetectionMalfunction]).to.beTruthy;
        expect([featureDetails supportsSensorDetectionLowHighTemp]).to.beTruthy;
        expect([featureDetails supportsSensorDetectionLowHighResult]).to.beTruthy;
        expect([featureDetails supportsSensorDetectionTypeError]).to.beTruthy;
        expect([featureDetails supportsSensorLowBattery]).to.beTruthy;
        expect([featureDetails supportsGeneralDeviceFault]).to.beTruthy;
        expect([featureDetails supportsE2ECRC]).to.beTruthy;
        expect([featureDetails supportsMultipleBond]).to.beTruthy;
        expect([featureDetails supportsMultipleSession]).to.beTruthy;
        expect([featureDetails supportsCGMTrend]).to.beTruthy;
        expect([featureDetails supportsCGMQuality]).to.beTruthy;
        expect([featureDetails glucoseFluidType]).to.equal(type);
        expect([featureDetails glucoseSampleLocation]).to.equal(location);
    });
});

describe(@"CGM status details dictionary queries", ^{
    it(@"should query the status details for a status octet", ^{
        uint8_t size = 5;
        uint8_t timeOffset = 5;
        uint8_t statusOctet = 0x03; // session stopped & battery low
        uint8_t calTempOctet = 0x00;
        uint8_t warningOctet = 0x00;
        
        NSData *statusData = [NSData dataWithBytes:(char[]){timeOffset, 0x00, statusOctet, calTempOctet, warningOctet} length:size];
        NSDictionary *statusDetails = [statusData parseStatusCharacteristicDetails:NO];
        expect([statusDetails statusDateTime]).to.equal(nil);
        expect([statusDetails statusTimeOffset]).to.equal(timeOffset);
        expect([statusDetails hasSessionStopped]).to.beTruthy;
        expect([statusDetails isDeviceBatteryLow]).to.beTruthy;
        expect([statusDetails hasExceededLevelPatientLow]).to.beFalsy;
        expect([statusDetails hasExceededLevelHypo]).to.beFalsy;
        expect([statusDetails isCalibrationRequired]).to.beFalsy;
    });
    
    it(@"should query the status details for a cal/temp octet", ^{
        uint8_t size = 5;
        uint8_t timeOffset = 10;
        uint8_t statusOctet = 0x00;
        uint8_t calTempOctet = 0x08; // calibration required
        uint8_t warningOctet = 0x00;
        
        NSData *statusData = [NSData dataWithBytes:(char[]){timeOffset, 0x00, statusOctet, calTempOctet, warningOctet} length:size];
        NSDictionary *statusDetails = [statusData parseStatusCharacteristicDetails:NO];
        expect([statusDetails statusDateTime]).to.equal(nil);
        expect([statusDetails statusTimeOffset]).to.equal(timeOffset);
        expect([statusDetails hasSessionStopped]).to.beFalsy;
        expect([statusDetails isDeviceBatteryLow]).to.beFalsy;
        expect([statusDetails hasExceededLevelPatientLow]).to.beFalsy;
        expect([statusDetails hasExceededLevelHypo]).to.beFalsy;
        expect([statusDetails isCalibrationRequired]).to.beTruthy;
    });
    
    it(@"should query the status details for a warning octet", ^{
        uint8_t size = 5;
        uint8_t timeOffset = 15;
        uint8_t statusOctet = 0x00;
        uint8_t calTempOctet = 0x00;
        uint8_t warningOctet = 0x05; // patient low & hypo
        
        NSData *statusData = [NSData dataWithBytes:(char[]){timeOffset, 0x00, statusOctet, calTempOctet, warningOctet} length:size];
        NSDictionary *statusDetails = [statusData parseStatusCharacteristicDetails:NO];
        expect([statusDetails statusDateTime]).to.equal(nil);
        expect([statusDetails statusTimeOffset]).to.equal(timeOffset);
        expect([statusDetails hasSessionStopped]).to.beFalsy;
        expect([statusDetails isDeviceBatteryLow]).to.beFalsy;
        expect([statusDetails hasExceededLevelPatientLow]).to.beTruthy;
        expect([statusDetails hasExceededLevelHypo]).to.beTruthy;
        expect([statusDetails isCalibrationRequired]).to.beFalsy;
    });
    
    it(@"should query the status details for all information", ^{
        uint8_t size = 5;
        uint8_t timeOffset = 20;
        uint8_t statusOctet = 0x03; // session stopped & battery low
        uint8_t calTempOctet = 0x08; // calibration required
        uint8_t warningOctet = 0x05; // patient low & hypo
        
        NSData *statusData = [NSData dataWithBytes:(char[]){timeOffset, 0x00, statusOctet, calTempOctet, warningOctet} length:size];
        NSDictionary *statusDetails = [statusData parseStatusCharacteristicDetails:NO];
        expect([statusDetails statusDateTime]).to.equal(nil);
        expect([statusDetails statusTimeOffset]).to.equal(timeOffset);
        expect([statusDetails hasSessionStopped]).to.beTruthy;
        expect([statusDetails isDeviceBatteryLow]).to.beTruthy;
        expect([statusDetails hasExceededLevelPatientLow]).to.beTruthy;
        expect([statusDetails hasExceededLevelHypo]).to.beTruthy;
        expect([statusDetails isCalibrationRequired]).to.beTruthy;
    });

});

describe(@"CGM specific ops control point details dictionary queries", ^{
    it(@"should query the CGMCP details for a general response with a successful reset device specific alert", ^{
        uint8_t size = 3;
        CGMCPOpCode responseOpCode = CGMCPOpCodeResponse;
        CGMCPOpCode requestedOpCode = CGMCPOpCodeAlertDeviceSpecificReset;
        CGMCPResponseCode responseCode = CGMCPSuccess;
        
        NSData *responseData = [NSData dataWithBytes:(char[]){responseOpCode, requestedOpCode, responseCode} length:size];
        NSDictionary *responseDetails = [responseData parseCGMCPResponse:NO];
        expect([responseDetails isCGMCPGeneralResponse]).to.beTruthy;
        expect([responseDetails CGMCPResponseCode]).to.equal(CGMCPSuccess);
        expect([responseDetails CGMCPRequestOpCode]).to.equal(CGMCPOpCodeAlertDeviceSpecificReset);
        
        expect([responseDetails isSuccessfulAlertDeviceSpecificReset]).to.beTruthy;
        expect([responseDetails isSuccessfulSessionStart]).to.beFalsy;
        expect([responseDetails isSuccessfulSessionStop]).to.beFalsy;
        expect([responseDetails isSuccessfulSetCommunicationInterval]).to.beFalsy;
        expect([responseDetails isSuccessfulSetCalibrationValue]).to.beFalsy;
        expect([responseDetails isSuccessfulSetAlertLevelPatientHigh]).to.beFalsy;
        expect([responseDetails isSuccessfulSetAlertLevelPatientLow]).to.beFalsy;
        expect([responseDetails isSuccessfulSetAlertLevelHypo]).to.beFalsy;
        expect([responseDetails isSuccessfulSetAlertLevelHyper]).to.beFalsy;
        expect([responseDetails isSuccessfulSetAlertLevelRateDecrease]).to.beFalsy;
        expect([responseDetails isSuccessfulSetAlertLevelRateIncrease]).to.beFalsy;
    });
    
    it(@"should query the CGMCP details for a general response with a successfull start session", ^{
        uint8_t size = 3;
        CGMCPOpCode responseOpCode = CGMCPOpCodeResponse;
        CGMCPOpCode requestedOpCode = CGMCPOpCodeSessionStart;
        CGMCPResponseCode responseCode = CGMCPSuccess;
        
        NSData *responseData = [NSData dataWithBytes:(char[]){responseOpCode, requestedOpCode, responseCode} length:size];
        NSDictionary *responseDetails = [responseData parseCGMCPResponse:NO];
        expect([responseDetails isCGMCPGeneralResponse]).to.beTruthy;
        expect([responseDetails CGMCPResponseCode]).to.equal(CGMCPSuccess);
        expect([responseDetails CGMCPRequestOpCode]).to.equal(CGMCPOpCodeSessionStart);
        
        expect([responseDetails isSuccessfulAlertDeviceSpecificReset]).to.beFalsy;
        expect([responseDetails isSuccessfulSessionStart]).to.beTruthy;
        expect([responseDetails isSuccessfulSessionStop]).to.beFalsy;
        expect([responseDetails isSuccessfulSetCommunicationInterval]).to.beFalsy;
        expect([responseDetails isSuccessfulSetCalibrationValue]).to.beFalsy;
        expect([responseDetails isSuccessfulSetAlertLevelPatientHigh]).to.beFalsy;
        expect([responseDetails isSuccessfulSetAlertLevelPatientLow]).to.beFalsy;
        expect([responseDetails isSuccessfulSetAlertLevelHypo]).to.beFalsy;
        expect([responseDetails isSuccessfulSetAlertLevelHyper]).to.beFalsy;
        expect([responseDetails isSuccessfulSetAlertLevelRateDecrease]).to.beFalsy;
        expect([responseDetails isSuccessfulSetAlertLevelRateIncrease]).to.beFalsy;
    });
    
    it(@"should query the CGMCP details for a general response with a successfull stop session", ^{
        uint8_t size = 3;
        CGMCPOpCode responseOpCode = CGMCPOpCodeResponse;
        CGMCPOpCode requestedOpCode = CGMCPOpCodeSessionStop;
        CGMCPResponseCode responseCode = CGMCPSuccess;
        
        NSData *responseData = [NSData dataWithBytes:(char[]){responseOpCode, requestedOpCode, responseCode} length:size];
        NSDictionary *responseDetails = [responseData parseCGMCPResponse:NO];
        expect([responseDetails isCGMCPGeneralResponse]).to.beTruthy;
        expect([responseDetails CGMCPResponseCode]).to.equal(CGMCPSuccess);
        expect([responseDetails CGMCPRequestOpCode]).to.equal(CGMCPOpCodeSessionStop);
        
        expect([responseDetails isSuccessfulAlertDeviceSpecificReset]).to.beFalsy;
        expect([responseDetails isSuccessfulSessionStart]).to.beFalsy;
        expect([responseDetails isSuccessfulSessionStop]).to.beTruthy;
        expect([responseDetails isSuccessfulSetCommunicationInterval]).to.beFalsy;
        expect([responseDetails isSuccessfulSetCalibrationValue]).to.beFalsy;
        expect([responseDetails isSuccessfulSetAlertLevelPatientHigh]).to.beFalsy;
        expect([responseDetails isSuccessfulSetAlertLevelPatientLow]).to.beFalsy;
        expect([responseDetails isSuccessfulSetAlertLevelHypo]).to.beFalsy;
        expect([responseDetails isSuccessfulSetAlertLevelHyper]).to.beFalsy;
        expect([responseDetails isSuccessfulSetAlertLevelRateDecrease]).to.beFalsy;
        expect([responseDetails isSuccessfulSetAlertLevelRateIncrease]).to.beFalsy;
    });
    
    it(@"should query the CGMCP details for a general response with a successfull set communication interval", ^{
        uint8_t size = 3;
        CGMCPOpCode responseOpCode = CGMCPOpCodeResponse;
        CGMCPOpCode requestedOpCode = CGMCPOpCodeCommIntervalSet;
        CGMCPResponseCode responseCode = CGMCPSuccess;
        
        NSData *responseData = [NSData dataWithBytes:(char[]){responseOpCode, requestedOpCode, responseCode} length:size];
        NSDictionary *responseDetails = [responseData parseCGMCPResponse:NO];
        expect([responseDetails isCGMCPGeneralResponse]).to.beTruthy;
        expect([responseDetails CGMCPResponseCode]).to.equal(CGMCPSuccess);
        expect([responseDetails CGMCPRequestOpCode]).to.equal(CGMCPOpCodeCommIntervalSet);
        
        expect([responseDetails isSuccessfulAlertDeviceSpecificReset]).to.beFalsy;
        expect([responseDetails isSuccessfulSessionStart]).to.beFalsy;
        expect([responseDetails isSuccessfulSessionStop]).to.beFalsy;
        expect([responseDetails isSuccessfulSetCommunicationInterval]).to.beTruthy;
        expect([responseDetails isSuccessfulSetCalibrationValue]).to.beFalsy;
        expect([responseDetails isSuccessfulSetAlertLevelPatientHigh]).to.beFalsy;
        expect([responseDetails isSuccessfulSetAlertLevelPatientLow]).to.beFalsy;
        expect([responseDetails isSuccessfulSetAlertLevelHypo]).to.beFalsy;
        expect([responseDetails isSuccessfulSetAlertLevelHyper]).to.beFalsy;
        expect([responseDetails isSuccessfulSetAlertLevelRateDecrease]).to.beFalsy;
        expect([responseDetails isSuccessfulSetAlertLevelRateIncrease]).to.beFalsy;
    });
    
    it(@"should query the CGMCP details for a general response with a successfull set calibration value", ^{
        uint8_t size = 3;
        CGMCPOpCode responseOpCode = CGMCPOpCodeResponse;
        CGMCPOpCode requestedOpCode = CGMCPOpCodeCalibrationValueSet;
        CGMCPResponseCode responseCode = CGMCPSuccess;
        
        NSData *responseData = [NSData dataWithBytes:(char[]){responseOpCode, requestedOpCode, responseCode} length:size];
        NSDictionary *responseDetails = [responseData parseCGMCPResponse:NO];
        expect([responseDetails isCGMCPGeneralResponse]).to.beTruthy;
        expect([responseDetails CGMCPResponseCode]).to.equal(CGMCPSuccess);
        expect([responseDetails CGMCPRequestOpCode]).to.equal(CGMCPOpCodeCalibrationValueSet);
        
        expect([responseDetails isSuccessfulAlertDeviceSpecificReset]).to.beFalsy;
        expect([responseDetails isSuccessfulSessionStart]).to.beFalsy;
        expect([responseDetails isSuccessfulSessionStop]).to.beFalsy;
        expect([responseDetails isSuccessfulSetCommunicationInterval]).to.beFalsy;
        expect([responseDetails isSuccessfulSetCalibrationValue]).to.beTruthy;
        expect([responseDetails isSuccessfulSetAlertLevelPatientHigh]).to.beFalsy;
        expect([responseDetails isSuccessfulSetAlertLevelPatientLow]).to.beFalsy;
        expect([responseDetails isSuccessfulSetAlertLevelHypo]).to.beFalsy;
        expect([responseDetails isSuccessfulSetAlertLevelHyper]).to.beFalsy;
        expect([responseDetails isSuccessfulSetAlertLevelRateDecrease]).to.beFalsy;
        expect([responseDetails isSuccessfulSetAlertLevelRateIncrease]).to.beFalsy;
    });
    
    it(@"should query the CGMCP details for a general response with a successfull set patient high alert level", ^{
        uint8_t size = 3;
        CGMCPOpCode responseOpCode = CGMCPOpCodeResponse;
        CGMCPOpCode requestedOpCode = CGMCPOpCodeAlertLevelPatientHighSet;
        CGMCPResponseCode responseCode = CGMCPSuccess;
        
        NSData *responseData = [NSData dataWithBytes:(char[]){responseOpCode, requestedOpCode, responseCode} length:size];
        NSDictionary *responseDetails = [responseData parseCGMCPResponse:NO];
        expect([responseDetails isCGMCPGeneralResponse]).to.beTruthy;
        expect([responseDetails CGMCPResponseCode]).to.equal(CGMCPSuccess);
        expect([responseDetails CGMCPRequestOpCode]).to.equal(CGMCPOpCodeAlertLevelPatientHighSet);
        
        expect([responseDetails isSuccessfulAlertDeviceSpecificReset]).to.beFalsy;
        expect([responseDetails isSuccessfulSessionStart]).to.beFalsy;
        expect([responseDetails isSuccessfulSessionStop]).to.beFalsy;
        expect([responseDetails isSuccessfulSetCommunicationInterval]).to.beFalsy;
        expect([responseDetails isSuccessfulSetCalibrationValue]).to.beFalsy;
        expect([responseDetails isSuccessfulSetAlertLevelPatientHigh]).to.beTruthy;
        expect([responseDetails isSuccessfulSetAlertLevelPatientLow]).to.beFalsy;
        expect([responseDetails isSuccessfulSetAlertLevelHypo]).to.beFalsy;
        expect([responseDetails isSuccessfulSetAlertLevelHyper]).to.beFalsy;
        expect([responseDetails isSuccessfulSetAlertLevelRateDecrease]).to.beFalsy;
        expect([responseDetails isSuccessfulSetAlertLevelRateIncrease]).to.beFalsy;
    });
    
    it(@"should query the CGMCP details for a general response with a successfull set patient low alert level", ^{
        uint8_t size = 3;
        CGMCPOpCode responseOpCode = CGMCPOpCodeResponse;
        CGMCPOpCode requestedOpCode = CGMCPOpCodeAlertLevelPatientLowSet;
        CGMCPResponseCode responseCode = CGMCPSuccess;
        
        NSData *responseData = [NSData dataWithBytes:(char[]){responseOpCode, requestedOpCode, responseCode} length:size];
        NSDictionary *responseDetails = [responseData parseCGMCPResponse:NO];
        expect([responseDetails isCGMCPGeneralResponse]).to.beTruthy;
        expect([responseDetails CGMCPResponseCode]).to.equal(CGMCPSuccess);
        expect([responseDetails CGMCPRequestOpCode]).to.equal(CGMCPOpCodeAlertLevelPatientLowSet);
        
        expect([responseDetails isSuccessfulAlertDeviceSpecificReset]).to.beFalsy;
        expect([responseDetails isSuccessfulSessionStart]).to.beFalsy;
        expect([responseDetails isSuccessfulSessionStop]).to.beFalsy;
        expect([responseDetails isSuccessfulSetCommunicationInterval]).to.beFalsy;
        expect([responseDetails isSuccessfulSetCalibrationValue]).to.beFalsy;
        expect([responseDetails isSuccessfulSetAlertLevelPatientHigh]).to.beFalsy;
        expect([responseDetails isSuccessfulSetAlertLevelPatientLow]).to.beTruthy;
        expect([responseDetails isSuccessfulSetAlertLevelHypo]).to.beFalsy;
        expect([responseDetails isSuccessfulSetAlertLevelHyper]).to.beFalsy;
        expect([responseDetails isSuccessfulSetAlertLevelRateDecrease]).to.beFalsy;
        expect([responseDetails isSuccessfulSetAlertLevelRateIncrease]).to.beFalsy;
    });
    
    it(@"should query the CGMCP details for a general response with a successfull set hypo alert level", ^{
        uint8_t size = 3;
        CGMCPOpCode responseOpCode = CGMCPOpCodeResponse;
        CGMCPOpCode requestedOpCode = CGMCPOpCodeAlertLevelHypoSet;
        CGMCPResponseCode responseCode = CGMCPSuccess;
        
        NSData *responseData = [NSData dataWithBytes:(char[]){responseOpCode, requestedOpCode, responseCode} length:size];
        NSDictionary *responseDetails = [responseData parseCGMCPResponse:NO];
        expect([responseDetails isCGMCPGeneralResponse]).to.beTruthy;
        expect([responseDetails CGMCPResponseCode]).to.equal(CGMCPSuccess);
        expect([responseDetails CGMCPRequestOpCode]).to.equal(CGMCPOpCodeAlertLevelHypoSet);
        
        expect([responseDetails isSuccessfulAlertDeviceSpecificReset]).to.beFalsy;
        expect([responseDetails isSuccessfulSessionStart]).to.beFalsy;
        expect([responseDetails isSuccessfulSessionStop]).to.beFalsy;
        expect([responseDetails isSuccessfulSetCommunicationInterval]).to.beFalsy;
        expect([responseDetails isSuccessfulSetCalibrationValue]).to.beFalsy;
        expect([responseDetails isSuccessfulSetAlertLevelPatientHigh]).to.beFalsy;
        expect([responseDetails isSuccessfulSetAlertLevelPatientLow]).to.beFalsy;
        expect([responseDetails isSuccessfulSetAlertLevelHypo]).to.beTruthy;
        expect([responseDetails isSuccessfulSetAlertLevelHyper]).to.beFalsy;
        expect([responseDetails isSuccessfulSetAlertLevelRateDecrease]).to.beFalsy;
        expect([responseDetails isSuccessfulSetAlertLevelRateIncrease]).to.beFalsy;
    });
    
    it(@"should query the CGMCP details for a general response with a successfull set hyper alert level", ^{
        uint8_t size = 3;
        CGMCPOpCode responseOpCode = CGMCPOpCodeResponse;
        CGMCPOpCode requestedOpCode = CGMCPOpCodeAlertLevelHyperSet;
        CGMCPResponseCode responseCode = CGMCPSuccess;
        
        NSData *responseData = [NSData dataWithBytes:(char[]){responseOpCode, requestedOpCode, responseCode} length:size];
        NSDictionary *responseDetails = [responseData parseCGMCPResponse:NO];
        expect([responseDetails isCGMCPGeneralResponse]).to.beTruthy;
        expect([responseDetails CGMCPResponseCode]).to.equal(CGMCPSuccess);
        expect([responseDetails CGMCPRequestOpCode]).to.equal(CGMCPOpCodeAlertLevelHyperSet);
        
        expect([responseDetails isSuccessfulAlertDeviceSpecificReset]).to.beFalsy;
        expect([responseDetails isSuccessfulSessionStart]).to.beFalsy;
        expect([responseDetails isSuccessfulSessionStop]).to.beFalsy;
        expect([responseDetails isSuccessfulSetCommunicationInterval]).to.beFalsy;
        expect([responseDetails isSuccessfulSetCalibrationValue]).to.beFalsy;
        expect([responseDetails isSuccessfulSetAlertLevelPatientHigh]).to.beFalsy;
        expect([responseDetails isSuccessfulSetAlertLevelPatientLow]).to.beFalsy;
        expect([responseDetails isSuccessfulSetAlertLevelHypo]).to.beFalsy;
        expect([responseDetails isSuccessfulSetAlertLevelHyper]).to.beTruthy;
        expect([responseDetails isSuccessfulSetAlertLevelRateDecrease]).to.beFalsy;
        expect([responseDetails isSuccessfulSetAlertLevelRateIncrease]).to.beFalsy;
    });
    
    it(@"should query the CGMCP details for a general response with a successfull set rate decrease alert level", ^{
        uint8_t size = 3;
        CGMCPOpCode responseOpCode = CGMCPOpCodeResponse;
        CGMCPOpCode requestedOpCode = CGMCPOpCodeAlertLevelRateDecreaseSet;
        CGMCPResponseCode responseCode = CGMCPSuccess;
        
        NSData *responseData = [NSData dataWithBytes:(char[]){responseOpCode, requestedOpCode, responseCode} length:size];
        NSDictionary *responseDetails = [responseData parseCGMCPResponse:NO];
        expect([responseDetails isCGMCPGeneralResponse]).to.beTruthy;
        expect([responseDetails CGMCPResponseCode]).to.equal(CGMCPSuccess);
        expect([responseDetails CGMCPRequestOpCode]).to.equal(CGMCPOpCodeAlertLevelRateDecreaseSet);
        
        expect([responseDetails isSuccessfulAlertDeviceSpecificReset]).to.beFalsy;
        expect([responseDetails isSuccessfulSessionStart]).to.beFalsy;
        expect([responseDetails isSuccessfulSessionStop]).to.beFalsy;
        expect([responseDetails isSuccessfulSetCommunicationInterval]).to.beFalsy;
        expect([responseDetails isSuccessfulSetCalibrationValue]).to.beFalsy;
        expect([responseDetails isSuccessfulSetAlertLevelPatientHigh]).to.beFalsy;
        expect([responseDetails isSuccessfulSetAlertLevelPatientLow]).to.beFalsy;
        expect([responseDetails isSuccessfulSetAlertLevelHypo]).to.beFalsy;
        expect([responseDetails isSuccessfulSetAlertLevelHyper]).to.beFalsy;
        expect([responseDetails isSuccessfulSetAlertLevelRateDecrease]).to.beTruthy;
        expect([responseDetails isSuccessfulSetAlertLevelRateIncrease]).to.beFalsy;
    });
    
    it(@"should query the CGMCP details for a general response with a successfull set rate increase alert level", ^{
        uint8_t size = 3;
        CGMCPOpCode responseOpCode = CGMCPOpCodeResponse;
        CGMCPOpCode requestedOpCode = CGMCPOpCodeAlertLevelRateIncreaseSet;
        CGMCPResponseCode responseCode = CGMCPSuccess;
        
        NSData *responseData = [NSData dataWithBytes:(char[]){responseOpCode, requestedOpCode, responseCode} length:size];
        NSDictionary *responseDetails = [responseData parseCGMCPResponse:NO];
        expect([responseDetails isCGMCPGeneralResponse]).to.beTruthy;
        expect([responseDetails CGMCPResponseCode]).to.equal(CGMCPSuccess);
        expect([responseDetails CGMCPRequestOpCode]).to.equal(CGMCPOpCodeAlertLevelRateIncreaseSet);
        
        expect([responseDetails isSuccessfulAlertDeviceSpecificReset]).to.beFalsy;
        expect([responseDetails isSuccessfulSessionStart]).to.beFalsy;
        expect([responseDetails isSuccessfulSessionStop]).to.beFalsy;
        expect([responseDetails isSuccessfulSetCommunicationInterval]).to.beFalsy;
        expect([responseDetails isSuccessfulSetCalibrationValue]).to.beFalsy;
        expect([responseDetails isSuccessfulSetAlertLevelPatientHigh]).to.beFalsy;
        expect([responseDetails isSuccessfulSetAlertLevelPatientLow]).to.beFalsy;
        expect([responseDetails isSuccessfulSetAlertLevelHypo]).to.beFalsy;
        expect([responseDetails isSuccessfulSetAlertLevelHyper]).to.beFalsy;
        expect([responseDetails isSuccessfulSetAlertLevelRateDecrease]).to.beFalsy;
        expect([responseDetails isSuccessfulSetAlertLevelRateIncrease]).to.beTruthy;
    });
    
    it(@"should query the CGMCP details for a general response with op code not supported", ^{
        uint8_t size = 3;
        CGMCPOpCode responseOpCode = CGMCPOpCodeResponse;
        CGMCPOpCode requestedOpCode = CGMCPOpCodeAlertLevelPatientHighSet;
        CGMCPResponseCode responseCode = CGMCPOpCodeNotSupported;
        
        NSData *responseData = [NSData dataWithBytes:(char[]){responseOpCode, requestedOpCode, responseCode} length:size];
        NSDictionary *responseDetails = [responseData parseCGMCPResponse:NO];
        expect([responseDetails isCGMCPGeneralResponse]).to.beTruthy;
        expect([responseDetails CGMCPResponseCode]).to.equal(CGMCPOpCodeNotSupported);
        expect([responseDetails CGMCPRequestOpCode]).to.equal(CGMCPOpCodeAlertLevelPatientHighSet);
    });
    
    it(@"should query the CGMCP details with a get communication interval response", ^{
        uint8_t size = 2;
        CGMCPOpCode responseOpCode = CGMCPOpCodeCommIntervalResponse;
        uint8_t operand = 10;
        
        NSData *responseData = [NSData dataWithBytes:(char[]){responseOpCode, operand} length:size];
        NSDictionary *responseDetails = [responseData parseCGMCPResponse:NO];
        expect([responseDetails isCGMCPGeneralResponse]).to.beFalsy;
        expect([responseDetails isCommunicationIntervalResponse]).to.beTruthy;
        expect([responseDetails CGMCPResponseValue]).to.equal(10);
    });
    
    it(@"should query the CGMCP details for an accepted and validated calibration value", ^{
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
        expect([responseDetails isCGMCPGeneralResponse]).to.beFalsy;
        expect([responseDetails isSuccessfulSetCalibrationValue]).to.beFalsy;
        expect([responseDetails isCalibrationReponse]).to.beTruthy;
        expect([responseDetails calibrationGlucoseValue]).to.equal(glucose);
        expect([responseDetails calibrationFluidType]).to.equal(type);
        expect([responseDetails calibrationSampleLocation]).to.equal(location);
        expect([responseDetails calibrationRecordNumber]).to.equal(recordNumber);
        expect([responseDetails calibrationTimeOffset]).to.equal(calibrationTime);
        expect([responseDetails calibrationDateTime]).to.equal(nil);
        expect([responseDetails calibrationTimeOffsetNext]).to.equal(calibrationTimeNext);
        expect([responseDetails calibrationDateTimeNext]).to.equal(nil);

        expect([responseDetails wasCalibrationSuccessful]).to.beTruthy;
        expect([responseDetails wasCalibrationDataRejected]).to.beFalsy;
        expect([responseDetails wasCalibrationDataOutOfRange]).to.beFalsy;
        expect([responseDetails isCalibrationProcessPending]).to.beFalsy;
    });
    
    it(@"should query the CGMCP details for a rejected calibration value", ^{
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
        expect([responseDetails isCGMCPGeneralResponse]).to.beFalsy;
        expect([responseDetails isSuccessfulSetCalibrationValue]).to.beFalsy;
        expect([responseDetails isCalibrationReponse]).to.beTruthy;
        expect([responseDetails calibrationGlucoseValue]).to.equal(glucose);
        expect([responseDetails calibrationFluidType]).to.equal(type);
        expect([responseDetails calibrationSampleLocation]).to.equal(location);
        expect([responseDetails calibrationRecordNumber]).to.equal(recordNumber);
        expect([responseDetails calibrationTimeOffset]).to.equal(calibrationTime);
        expect([responseDetails calibrationDateTime]).to.equal(nil);
        expect([responseDetails calibrationTimeOffsetNext]).to.equal(calibrationTimeNext);
        expect([responseDetails calibrationDateTimeNext]).to.equal(nil);
        
        expect([responseDetails wasCalibrationSuccessful]).to.beFalsy;
        expect([responseDetails wasCalibrationDataRejected]).to.beTruthy;
        expect([responseDetails wasCalibrationDataOutOfRange]).to.beFalsy;
        expect([responseDetails isCalibrationProcessPending]).to.beFalsy;
    });
    
    it(@"should query the CGMCP details for an out-of-range calibration value", ^{
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
        expect([responseDetails isCGMCPGeneralResponse]).to.beFalsy;
        expect([responseDetails isSuccessfulSetCalibrationValue]).to.beFalsy;
        expect([responseDetails isCalibrationReponse]).to.beTruthy;
        expect([responseDetails calibrationGlucoseValue]).to.equal(glucose);
        expect([responseDetails calibrationFluidType]).to.equal(type);
        expect([responseDetails calibrationSampleLocation]).to.equal(location);
        expect([responseDetails calibrationRecordNumber]).to.equal(recordNumber);
        expect([responseDetails calibrationTimeOffset]).to.equal(calibrationTime);
        expect([responseDetails calibrationDateTime]).to.equal(nil);
        expect([responseDetails calibrationTimeOffsetNext]).to.equal(calibrationTimeNext);
        expect([responseDetails calibrationDateTimeNext]).to.equal(nil);
        
        expect([responseDetails wasCalibrationSuccessful]).to.beFalsy;
        expect([responseDetails wasCalibrationDataRejected]).to.beFalsy;
        expect([responseDetails wasCalibrationDataOutOfRange]).to.beTruthy;
        expect([responseDetails isCalibrationProcessPending]).to.beFalsy;
    });
    
    it(@"should query the CGMCP details for a process pending calibration value", ^{
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
        expect([responseDetails isCGMCPGeneralResponse]).to.beFalsy;
        expect([responseDetails isSuccessfulSetCalibrationValue]).to.beFalsy;
        expect([responseDetails isCalibrationReponse]).to.beTruthy;
        expect([responseDetails calibrationGlucoseValue]).to.equal(glucose);
        expect([responseDetails calibrationFluidType]).to.equal(type);
        expect([responseDetails calibrationSampleLocation]).to.equal(location);
        expect([responseDetails calibrationRecordNumber]).to.equal(recordNumber);
        expect([responseDetails calibrationTimeOffset]).to.equal(calibrationTime);
        expect([responseDetails calibrationDateTime]).to.equal(nil);
        expect([responseDetails calibrationTimeOffsetNext]).to.equal(calibrationTimeNext);
        expect([responseDetails calibrationDateTimeNext]).to.equal(nil);
        
        expect([responseDetails wasCalibrationSuccessful]).to.beFalsy;
        expect([responseDetails wasCalibrationDataRejected]).to.beFalsy;
        expect([responseDetails wasCalibrationDataOutOfRange]).to.beFalsy;
        expect([responseDetails isCalibrationProcessPending]).to.beTruthy;
    });
    
    it(@"should query the CGMCP details for a get patient high alert level response", ^{
        uint8_t size = 3;
        CGMCPOpCode responseOpCode = CGMCPOpCodeAlertLevelPatientHighResponse;
        uint8_t operand = 180;
        
        NSData *responseData = [NSData dataWithBytes:(char[]){responseOpCode, operand, 0x00} length:size];
        NSDictionary *responseDetails = [responseData parseCGMCPResponse:NO];
        expect([responseDetails isCGMCPGeneralResponse]).to.beFalsy;
        expect([responseDetails isAlertLevelPatientHighResponse]).to.beTruthy;
        expect([responseDetails CGMCPResponseValue]).to.equal(operand);
    });
    
    it(@"should query the CGMCP details for a get patient low alert level response", ^{
        uint8_t size = 3;
        CGMCPOpCode responseOpCode = CGMCPOpCodeAlertLevelPatientLowResponse;
        uint8_t operand = 80;
        
        NSData *responseData = [NSData dataWithBytes:(char[]){responseOpCode, operand, 0x00} length:size];
        NSDictionary *responseDetails = [responseData parseCGMCPResponse:NO];
        expect([responseDetails isCGMCPGeneralResponse]).to.beFalsy;
        expect([responseDetails isAlertLevelPatientLowResponse]).to.beTruthy;
        expect([responseDetails CGMCPResponseValue]).to.equal(operand);
    });
    
    it(@"should query the CGMCP details for a get hypo alert level response", ^{
        uint8_t size = 3;
        CGMCPOpCode responseOpCode = CGMCPOpCodeAlertLevelHypoReponse;
        uint8_t operand = 40;
        
        NSData *responseData = [NSData dataWithBytes:(char[]){responseOpCode, operand, 0x00} length:size];
        NSDictionary *responseDetails = [responseData parseCGMCPResponse:NO];
        expect([responseDetails isCGMCPGeneralResponse]).to.beFalsy;
        expect([responseDetails isAlertLevelHypoReponse]).to.beTruthy;
        expect([responseDetails CGMCPResponseValue]).to.equal(operand);
    });
    
    it(@"should query the CGMCP details for a get hyper alert level response", ^{
        uint8_t size = 3;
        CGMCPOpCode responseOpCode = CGMCPOpCodeAlertLevelHyperReponse;
        uint8_t operand = 250;
        
        NSData *responseData = [NSData dataWithBytes:(char[]){responseOpCode, operand, 0x00} length:size];
        NSDictionary *responseDetails = [responseData parseCGMCPResponse:NO];
        expect([responseDetails isCGMCPGeneralResponse]).to.beFalsy;
        expect([responseDetails isAlertLevelHyperReponse]).to.beTruthy;
        expect([responseDetails CGMCPResponseValue]).to.equal(operand);
    });
    
    it(@"should query the CGMCP details for a get rate decrease alert level response", ^{
        uint8_t size = 3;
        CGMCPOpCode responseOpCode = CGMCPOpCodeAlertLevelRateDecreaseResponse;
        uint8_t operand = 20;
        
        NSData *responseData = [NSData dataWithBytes:(char[]){responseOpCode, operand, 0x00} length:size];
        NSDictionary *responseDetails = [responseData parseCGMCPResponse:NO];
        expect([responseDetails isCGMCPGeneralResponse]).to.beFalsy;
        expect([responseDetails isAlertLevelRateDecreasedReponse]).to.beTruthy;
        expect([responseDetails CGMCPResponseValue]).to.equal(operand);
    });
    
    it(@"should query the CGMCP details get rate increase alert level response", ^{
        uint8_t size = 3;
        CGMCPOpCode responseOpCode = CGMCPOpCodeAlertLevelRateIncreaseResponse;
        uint8_t operand = 30;
        
        NSData *responseData = [NSData dataWithBytes:(char[]){responseOpCode, operand, 0x00} length:size];
        NSDictionary *responseDetails = [responseData parseCGMCPResponse:NO];
        expect([responseDetails isCGMCPGeneralResponse]).to.beFalsy;
        expect([responseDetails isAlertLevelRateIncreasedReponse]).to.beTruthy;
        expect([responseDetails CGMCPResponseValue]).to.equal(operand);
    });
});

SpecEnd
