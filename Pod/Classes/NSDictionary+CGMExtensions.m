//
//  NSDictionary+CGMExtensions.m
//  CGM_Collector
//
//  Created by Nathaniel Hamming on 2015-01-27.
//  Copyright (c) 2015 University Health Network.
//

#import "NSDictionary+CGMExtensions.h"
#import "UHNCGMConstants.h"

@implementation NSDictionary (CGMExtensions)

#pragma mark - Shared Values/Flags

- (BOOL)didCRCFail;
{
    return [self[kCGMCRCFailed] boolValue];
}

#pragma mark - Measurement Values

- (NSDate*)measurementDateTime;
{
    return self[kCGMKeyDateTime];
}

- (NSNumber*)measurementTimeOffset;
{
    return self[kCGMKeyTimeOffset];
}

- (NSNumber*)glucoseValue;
{
    return self[kCGMMeasurementKeyGlucoseConcentration];
}

- (NSNumber*)trendValue;
{
    return self[kCGMMeasurementKeyTrendInfo];
}

- (NSNumber*)qualityValue;
{
    return self[kCGMMeasurementKeyQuality];
}

#pragma mark - Sensor Status

- (NSDate*)statusDateTime;
{
    return self[kCGMKeyDateTime];
}

- (NSNumber*)statusTimeOffset;
{
    return self[kCGMKeyTimeOffset];
}

#pragma mark - Status Flags

- (NSInteger)statusOctet
{
    return [self[kCGMStatusKeyOctetStatus] integerValue];
}

- (BOOL)hasSessionStopped;
{
    return ([self statusOctet] & CGMStatusStatusSessionStopped);
}

- (BOOL)isDeviceBatteryLow;
{
    return ([self statusOctet] & CGMStatusStatusDeviceBatteryLow);
}

- (BOOL)isSensorTypeIncorrect;
{
    return ([self statusOctet] & CGMStatusStatusSensorTypeIncorrect);
}

- (BOOL)didSensorMalfunction;
{
    return ([self statusOctet] & CGMStatusStatusSensorMalfunction);
}

- (BOOL)hasDeviceSpecificAlert;
{
    return ([self statusOctet] & CGMStatusStatusDeviceSpecificAlert);
}

- (BOOL)hasGeneraldeviceFault;
{
    return ([self statusOctet] & CGMStatusStatusGeneralDeviceFault);
}

#pragma mark - Calibration Temperature Flags

- (NSInteger)calTempOctet
{
    return [self[kCGMStatusKeyOctetCalTemp] integerValue];
}

- (BOOL)isTimeSynchronizationRequired;
{
    return ([self calTempOctet] & CGMStatusCalTempTimeSynchronizationRequired);
}

- (BOOL)isCalibrationNotAllowed;
{
    return ([self calTempOctet] & CGMStatusCalTempCalibrationNotAllowed);
}

- (BOOL)isCalibrationRecommended;
{
    return ([self calTempOctet] & CGMStatusCalTempCalibrationRecommended);
}

- (BOOL)isCalibrationRequired;
{
    return ([self calTempOctet] & CGMStatusCalTempCalibrationRequired);
}

- (BOOL)isSensorTempTooHigh;
{
    return ([self calTempOctet] & CGMStatusCalTempSensorTempTooHigh);
}

- (BOOL)isSensorTempTooLow;
{
    return ([self calTempOctet] & CGMStatusCalTempSensorTempTooLow);
}

#pragma mark - Warning Flags

- (NSInteger)warningOctet
{
    return [self[kCGMStatusKeyOctetWarning] integerValue];
}

- (BOOL)hasExceededLevelHypo;
{
    return ([self warningOctet] & CGMStatusWarningResultLowerThanHypo);
}

- (BOOL)hasExceededLevelHyper;
{
    return ([self warningOctet] & CGMStatusWarningResultHigherThanHyper);
}

- (BOOL)hasExceededLevelPatientLow;
{
    return ([self warningOctet] & CGMStatusWarningResultLowerThanPatientLow);
}

- (BOOL)hasExceededLevelPatientHigh;
{
    return ([self warningOctet] & CGMStatusWarningResultHigherThanPatientHigh);
}

- (BOOL)hasExceededRateDecrease;
{
    return ([self warningOctet] & CGMStatusWarningResultExceedRateDecrease);
}

- (BOOL)hasExceededRateIncrease;
{
    return ([self warningOctet] & CGMStatusWarningResultExceedRateIncrease);
}

- (BOOL)hasExceededDeviceLimitLow;
{
    return ([self warningOctet] & CGMStatusWarningSensorResultTooLow);
}

- (BOOL)hasExceededDeviceLimitHigh;
{
    return ([self warningOctet] & CGMStatusWarningSensorResultTooHigh);
}

#pragma mark - Feature Flags

- (NSInteger)featureFlags
{
    return [self[kCGMFeatureKeyFeatures] integerValue];
}

- (BOOL)supportsCalibration;
{
    return ([self featureFlags] & CGMFeatureSupportedCalibration);
}

- (BOOL)supportsAlertLowHighPatient;
{
    return ([self featureFlags] & CGMFeatureSupportedAlertLowHighPatient);
}
                
- (BOOL)supportsAlertHypo;
{
    return ([self featureFlags] & CGMFeatureSupportedAlertHypo);
}

- (BOOL)supportsAlertHyper;
{
    return ([self featureFlags] & CGMFeatureSupportedAlertHyper);
}

- (BOOL)supportsAlertIncreaseDecreaseRate;
{
    return ([self featureFlags] & CGMFeatureSupportedAlertIncreaseDecreaseRate);
}

- (BOOL)supportsAlertDeviceSpecific;
{
    return ([self featureFlags] & CGMFeatureSupportedAlertDeviceSpecific);
}

- (BOOL)supportsSensorDetectionMalfunction;
{
    return ([self featureFlags] & CGMFeatureSupportedSensorDetectionMalfunction);
}

- (BOOL)supportsSensorDetectionLowHighTemp;
{
    return ([self featureFlags] & CGMFeatureSupportedSensorDetectionLowHighTemp);
}

- (BOOL)supportsSensorDetectionLowHighResult;
{
    return ([self featureFlags] & CGMFeatureSupportedSensorDetectionLowHighResult);
}

- (BOOL)supportsSensorLowBattery;
{
    return ([self featureFlags] & CGMFeatureSupportedLowBattery);
}

- (BOOL)supportsSensorDetectionTypeError;
{
    return ([self featureFlags] & CGMFeatureSupportedSensorDetectionTypeError);
}

- (BOOL)supportsGeneralDeviceFault;
{
    return ([self featureFlags] & CGMFeatureSupportedGeneralDeviceFault);
}

- (BOOL)supportsE2ECRC;
{
    return ([self featureFlags] & CGMFeatureSupportedE2ECRC);
}

- (BOOL)supportsMultipleBond;
{
    return ([self featureFlags] & CGMFeatureSupportedMultipleBond);
}

- (BOOL)supportsMultipleSession;
{
    return ([self featureFlags] & CGMFeatureSupportedMultipleSession);
}

- (BOOL)supportsCGMTrend;
{
    return ([self featureFlags] & CGMFeatureSupportedCGMTrend);
}

- (BOOL)supportsCGMQuality;
{
    return ([self featureFlags] & CGMFeatureSupportedCGMQuality);
}

#pragma mark - CGM Specific Ops Control Point

- (CGMCPOpCode)responseOpCode;
{
    return [self[kCGMCPKeyOpCode] integerValue];
}

- (BOOL)isGeneralResponse;
{
    return ([self responseOpCode] & CGMCPOpCodeResponse);
}

- (BOOL)isCommunicationIntervalResponse;
{
    return ([self responseOpCode] & CGMCPOpCodeCommIntervalResponse);
}

- (BOOL)isAlertLevelPatientHighResponse;
{
    return ([self responseOpCode] & CGMCPOpCodeAlertLevelPatientHighResponse);
}

- (BOOL)isAlertLevelPatientLowResponse;
{
    return ([self responseOpCode] & CGMCPOpCodeAlertLevelPatientLowResponse);
}

- (BOOL)isAlertLevelHypoReponse;
{
    return ([self responseOpCode] & CGMCPOpCodeAlertLevelHypoReponse);
}

- (BOOL)isAlertLevelHyperReponse;
{
    return ([self responseOpCode] & CGMCPOpCodeAlertLevelHyperReponse);
}

- (BOOL)isAlertLevelRateDecreasedReponse;
{
    return ([self responseOpCode] & CGMCPOpCodeAlertLevelRateDecreaseResponse);
}

- (BOOL)isAlertLevelRateIncreasedReponse;
{
    return ([self responseOpCode] & CGMCPOpCodeAlertLevelRateIncreaseResponse);
}

- (CGMCPResponseCode)responseCode;
{
    if ([self isGeneralResponse]) {
        return [self[kCGMCPKeyResponseDetails][kCGMCPKeyResponseCodeValue] integerValue];
    } else {
        return 0;
    }
}

- (CGMCPOpCode)requestOpCode;
{
    if ([self isGeneralResponse]) {
        return [self[kCGMCPKeyResponseDetails][kCGMCPKeyResponseRequestOpCode] integerValue];
    } else {
        return 0;
    }
}

- (NSNumber*)responseValue;
{
    return self[kCGMCPKeyOperand];
}

#pragma mark - CGM Specific Ops Control Point - Calibration

- (BOOL)isCalibrationReponse;
{
    return ([self responseOpCode] & CGMCPOpCodeCalibrationValueResponse);
}

- (NSDictionary*)calibrationDetails
{
    return self[kCGMCPKeyResponseCalibration];
}

- (NSDate*)calibrationDateTime;
{
    if ([self isCalibrationReponse]) {
        return [self calibrationDetails][kCGMKeyDateTime];
    } else {
        return nil;
    }
}

- (NSNumber*)calibrationTimeOffset;
{
    if ([self isCalibrationReponse]) {
        return [self calibrationDetails][kCGMKeyTimeOffset];
    } else {
        return nil;
    }
}

- (GlucoseFluidTypeOption)calibrationFluidType;
{
    if ([self isCalibrationReponse]) {
        return [[self calibrationDetails][kCGMCalibrationKeyFluidType] integerValue];
    } else {
        return 0;
    }
}
- (GlucoseSampleLocationOption)calibrationSampleLocation;
{
    if ([self isCalibrationReponse]) {
        return [[self calibrationDetails][kCGMCalibrationKeySampleLocation] integerValue];
    } else {
        return 0;
    }
}

- (NSDate*)nextCalibrationDateTime;
{
    if ([self isCalibrationReponse]) {
        return [self calibrationDetails][kCGMKeyDateTimeNext];
    } else {
        return nil;
    }
}

- (NSNumber*)nextCalibrationTimeOffset;
{
    if ([self isCalibrationReponse]) {
        return [self calibrationDetails][kCGMKeyTimeOffsetNext];
    } else {
        return nil;
    }
}

- (NSNumber*)calibrationRecordNumber;
{
    if ([self isCalibrationReponse]) {
        return [self calibrationDetails][kCGMCalibrationKeyRecordNumber];
    } else {
        return nil;
    }
}

- (BOOL)wasCalibrationSuccessful;
{
    if ([self isCalibrationReponse]) {
        return (([[self calibrationDetails][kCGMCalibrationKeyStatus] integerValue] & CGMCPCalibrationStatusDataRejected) == NO &&
                ([[self calibrationDetails][kCGMCalibrationKeyStatus] integerValue] & CGMCPCalibrationStatusDataOutOfRange) == NO &&
                ([[self calibrationDetails][kCGMCalibrationKeyStatus] integerValue] & CGMCPCalibrationStatusProcessPending) == NO);
    } else {
        return nil;
    }
}
- (BOOL)wasCalibrationDataRejected;
{
    if ([self isCalibrationReponse]) {
        return ([[self calibrationDetails][kCGMCalibrationKeyStatus] integerValue] & CGMCPCalibrationStatusDataRejected);
    } else {
        return nil;
    }
}

- (BOOL)wasCalibrationDataOutOfRange;
{
    if ([self isCalibrationReponse]) {
        return ([[self calibrationDetails][kCGMCalibrationKeyStatus] integerValue] & CGMCPCalibrationStatusDataOutOfRange);
    } else {
        return nil;
    }
}

- (BOOL)isCalibrationProcessPending;
{
    if ([self isCalibrationReponse]) {
        return ([[self calibrationDetails][kCGMCalibrationKeyStatus] integerValue] & CGMCPCalibrationStatusProcessPending);
    } else {
        return nil;
    }
}

@end
