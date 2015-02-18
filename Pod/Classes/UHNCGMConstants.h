//
//  UHNCGMConstants.h
//  CGM_Collector
//
//  Created by Nathaniel Hamming on 2015-01-27.
//  Copyright (c) 2015 University Health Network.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
// CGMS UUIDs can be found here: https://developer.bluetooth.org/gatt/services/Pages/ServiceViewer.aspx?u=org.bluetooth.service.cgm.xml

typedef struct shortFloat {
    char exponent : 4;
    short mantissa : 12;
} shortFloat;

#define kSecondsInHour 3600.
#define kSecondsInMinute 60.

#define kTestName @"NAT"
#define kCGMDeviceName @"CGM Sim"

#pragma mark - Keys
// Shared Keys
#define kCGMKeyTimeOffset @"CGMTimeOffset"

// Keys for Measurement Characteristic
#define kCGMMeasurementKeyDateTime @"CGMMeasurementDateTime"
#define kCGMMeasurementKeyGlucoseConcentration @"CGMGlucoseConcentration"
#define kCGMMeasurementKeyTrendInfo @"CGMTrendInformation"
#define kCGMMeasurementKeyQuality @"CGMMeasurementQuality"
#define kCGMMeasurementkeyCRCFailed @"CGMMeasurementCRCFailed"

// Keys for Status Characteristic
#define kCGMStatusKeySensorStatus @"CGMStatusOctets"
#define kCGMStatusKeyOctetStatus @"CGMStatusOctet"
#define kCGMStatusKeyOctetCalTemp @"CGMCalTempOctet"
#define kCGMStatusKeyOctetWarning @"CGMWarningOctet"

// Keys for Feature Characteristic
#define kCGMFeatureKeyFeatures @"CGMFeatures"
#define kCGMFeatureKeyFluidType @"CGMFluidType"
#define kCGMFeatureKeySampleLocation @"CGMSampleLocation"

// Keys for Specific Ops Control Point
#define kCGMCPKeyOpCode @"CGMCPOpCode"
#define kCGMCPKeyOperand @"CGMCPOperand"
#define kCGMCPKeyResponseDetails @"CGMCPResponseDetails"
#define kCGMCPKeyResponseRequestOpCode @"CGMCPResponseRequestOpCode"
#define kCGMCPKeyResponseCodeValue @"CGMCPResponseCodeValue"
#define kCGMCPKeyResponseCalibration  @"CGMCPCalibrationResponse"
#define kCGMCalibrationKeyValue @"CGMCalibrationValue"
#define kCGMCalibrationKeyTimeOffset @"CGMCalibrationTimeOffset"
#define kCGMCalibrationKeyFluidType @"CGMCalibrationFluidType"
#define kCGMCalibrationKeySampleLocation @"CGMCalibrationSampleLocation"
#define kCGMCalibrationKeyTimeOffsetNext @"CGMCalibrationTimeOffsetNext"
#define kCGMCalibrationKeyRecordNumber @"CGMCalibrationRecordNumber"
#define kCGMCalibrationKeyStatus @"CGMCalibrationStatus"

#pragma mark - Services
#define kCGMServiceUUID @"181F"
#define kGlucoseServiceUUID @"1808"

#pragma mark - Characteristics
#define kCGMCharacteristicUUIDMeasurement @"2AA7"
#define kCGMCharacteristicUUIDFeature @"2AA8"
#define kCGMCharacteristicUUIDStatus @"2AA9"
#define kCGMCharacteristicUUIDSessionStartTime @"2AAA"
#define kCGMCharacteristicUUIDSessionRunTime @"2AAB"
#define kCGMCharacteristicUUIDRecordAccessControlPoint @"2A52"
#define kCGMCharacteristicUUIDSpecificOpsControlPoint @"2AAC"

#pragma mark - CGM Measurement 
/**********  CGM Measurement Format (Mandatory) ***************
 Size - uint8 (Mandatory)
 * Size of the measurement changes based on the flags field (Sensor Status Annunication, Trend, Quality) and the CGM features (E2E-CRC supported)
 
 Flags - 8 bit (Mandatory)
 - bit 0: Trend information present
 - bit 1: Quality Present
 - bit 2: RESERVED FOR FUTURE USE
 - bit 3: RESERVED FOR FUTURE USE
 - bit 4: RESERVED FOR FUTURE USE
 - bit 5: Sensor status annunciation field, Warning-Octet present
 - bit 6: Sensor status annunciation field, Cal/Temp-Octet present
 - bit 7: Sensor status annunciation field, Status-Octet present
 
 CGM Glucose Concentration - SFLOAT (Mandatory)
 - units in mg/dl
 
 Time Offset - uint16 (Mandatory)
 - units in minutes
 
 Sensor Status Annunication - 24 bit (Field exists if the flag bit 5, 6, or 7 is set to 1. Only indicated octets are included)
 - Status-Octet
 - bit 0: Session stopped
 - bit 1: Device battery low
 - bit 2: Sensor type incorrect for device
 - bit 3: Sensor malfunction
 - bit 4: Device specific alert
 - bit 5: General device fault has occurred in the sensor
 - bit 6: RESERVED FOR FUTURE USE
 - bit 7: RESERVED FOR FUTURE USE
 
 - Cal/Temp-Octet
 - bit 8: Time synchronization between sensor and collector required
 - bit 9: Calibration not allowed
 - bit 10: Calibration recommended
 - bit 11: Calibration required
 - bit 12: Sensor temperature too high for valid test/result at time of measurement
 - bit 13: Sensor temperature too low for valid test/result at time of measurement
 - bit 14: RESERVED FOR FUTURE USE
 - bit 15: RESERVED FOR FUTURE USE
 
 - Warning-Octet
 - bit 16: Sensor result lower than the Patient Low level
 - bit 17: Sensor result higher than the Patient High level
 - bit 18: Sensor result lower than the Hypo level
 - bit 19: Sensor result higher than the Hyper level
 - bit 20: Sensor rate of decrease exceeded
 - bit 21: Sensor rate of increase exceeded
 - bit 22: Sensor result lower than the device can process
 - bit 23: Sensor result higher than the device can process
 
 Trend Information - SFLOAT (Field exists if the flag bit 15 is set to 1)
 - units in (mg/dl)/min
 
 Quality - SFLOAT (Field exists if the flag bit 16 is set to 1)
 - units in %
 
 E2E-CRC - uint16 (Field exists if the CGM Feature characterist bi 12 is set to 1)
 **********************************************/

#define kCGMMeasurementFieldRangeSize                   {0,1}
#define kCGMMeasurementFieldRangeFlags                  {1,1}
#define kCGMMeasurementFieldRangeGlucoseConcentration   {2,2}
#define kCGMMeasurementFieldRangeTimeOffset             {4,2}
#define kCGMMeasurementFieldSizeTrendInfo               2
#define kCGMMeasurementFieldSizeQuality                 2
#define kCGMMeasurementFieldSizeCRC                     2

typedef NS_ENUM (uint8_t, CGMMeasurementFlagOption) {
    CGMMeasurementFlagsTrendInformationPresent  = (1 << 0),
    CGMMeasurementFlagsQualityPresent           = (1 << 1),
    CGMMeasurementFlagsStatusOctetPresent       = (1 << 5),
    CGMMeasurementFlagsCalTempOctetPresent      = (1 << 6),
    CGMMeasurementFlagsWarningOctetPresent      = (1 << 7),
};


#pragma mark - CGM Feature
/**********  CGM Feature Format (Mandatory) ***************
 Feature - 24 bit (Mandatory)
    - bit 0: Calibration supported
    - bit 1: Patient high/low alert supported
    - bit 2: Hypo alerts
    - bit 3: Hyper alerts
    - bit 4: Rate of increase/decrease alerts supported
    - bit 5: Device specific alert supported
    - bit 6: Sensor malfunction detection supported
    - bit 7: Sensor temperature high/low detection supported
    - bit 8: Sensor result high/low detection supported
    - bit 9: Low battery detection supported
    - bit 10: Sensor type error detection supported
    - bit 11: General device fault supported
    - bit 12: E2E-CRC supported
    - bit 13: Multiple bond supported
    - bit 14: Multiple sessions supported
    - bit 15: CGM trend information supported
    - bit 16: CGM quality supported
    - bit 17: RESERVED FOR FUTURE USE
    - bit 18: RESERVED FOR FUTURE USE
    - bit 19: RESERVED FOR FUTURE USE
    - bit 20: RESERVED FOR FUTURE USE
    - bit 21: RESERVED FOR FUTURE USE
    - bit 22: RESERVED FOR FUTURE USE
    - bit 23: RESERVED FOR FUTURE USE
 
 Type - nibble/4 bit (Mandatory)
    - value 0: RESERVED FOR FUTURE USE
    - value 1: Capillary Whole blood
    - value 2: Capillary Plasma
    - value 3: Venous Whole blood
    - value 4: Venous Plasma
    - value 5: Arterial Whole blood
    - value 6: Arterial Plasma
    - value 7: Undetermined Whole blood
    - value 8: Undetermined Plasma
    - value 9: Interstitial Fluid (ISF)
    - value 10: Control Solution
    - value 11-15: RESERVED FOR FUTURE USE
 
 Sample Location - nibble/4 bit (Mandatory)
    - value 0: RESERVED FOR FUTURE USE
    - value 1: Finger
    - value 2: Alternate Site Test (AST)
    - value 3: Earlobe
    - value 4: Control solution
    - value 5: Subcutaneous tissue
    - value 15: Sample Location value not available
    - value 6-14: RESERVED FOR FUTURE USE
 
 E2E-CRC - uint16 (Mandatory)
    - If E2E-CRC support is not indicated in the CGM Feature characteristic (bit 12), this field's value is 0xFFFF
 **********************************************/

#define kCGMFeatureFieldRangeFeatures       {0,3}
#define kCGMFeatureFieldRangeTypeLocation   {3,1}
#define kCGMFeatureFieldRangeCRC            {4,2}

typedef NS_ENUM (uint32_t, CGMFeatureOption) {
    CGMFeatureSupportedCalibration                     = (1 << 0),
    CGMFeatureSupportedAlertLowHighPatient             = (1 << 1),
    CGMFeatureSupportedAlertHypo                       = (1 << 2),
    CGMFeatureSupportedAlertHyper                      = (1 << 3),
    CGMFeatureSupportedAlertIncreaseDecreaseRate       = (1 << 4),
    CGMFeatureSupportedAlertDeviceSpecific             = (1 << 5),
    CGMFeatureSupportedSensorDetectionMalfunction      = (1 << 6),
    CGMFeatureSupportedSensorDetectionLowHighTemp      = (1 << 7),
    CGMFeatureSupportedSensorDetectionLowHighResult    = (1 << 8),
    CGMFeatureSupportedLowBattery                      = (1 << 9),
    CGMFeatureSupportedSensorDetectionTypeError        = (1 << 10),
    CGMFeatureSupportedGeneralDeviceFault              = (1 << 11),
    CGMFeatureSupportedE2ECRC                          = (1 << 12),
    CGMFeatureSupportedMultipleBond                    = (1 << 13),
    CGMFeatureSupportedMultipleSession                 = (1 << 14),
    CGMFeatureSupportedCGMTrend                        = (1 << 15),
    CGMFeatureSupportedCGMQuality                      = (1 << 16),
};

typedef NS_ENUM (uint8_t, CGMTypeOption) {
    CGMTypeWholeBloodCapillary = 1,
    CGMTypePlasmaCapillary,
    CGMTypeWholeBloodVenous,
    CGMTypePlasmaVenous,
    CGMTypeWholeBloodArterial,
    CGMTypePlasmaArterial,
    CGMTypeWholeBloodUndetermined,
    CGMTypePlasmaUndetermined,
    CGMTypeISF,
    CGMTypeControlSolution,
};


typedef NS_ENUM (uint8_t, CGMLocationOption) {
    CGMSampleLocationFinger                = 1,
    CGMSampleLocationAlternativeSiteTest   = 2,
    CGMSampleLocationEarlobe               = 3,
    CGMSampleLocationControlSolution       = 4,
    CGMSampleLocationSubcutaneousTissue    = 5,
    CGMSampleLocationNotAvailable          = 15,
};


#pragma mark - CGM Status
/**********  CGM Status Format (Mandatory) ***************
 Time Offset - uint16 (Mandatory)
    - units in minutes

 Status - 24bit (Mandatory)
 - Status-Octet
    - bit 0: Session stopped
    - bit 1: Device battery low
    - bit 2: Sensor type incorrect for device
    - bit 3: Sensor malfunction
    - bit 4: Device specific alert
    - bit 5: Gerenal device fault has occurred in the sensor
    - bit 6: RESERVED FOR FUTURE USE
    - bit 7: RESERVED FOR FUTURE USE
 
 - Cal/Temp-Octet
    - bit 8: Time synchronization between sensor and collector required
    - bit 9: Calibration not allowed
    - bit 10: Calibration recommended
    - bit 11: Calibration required
    - bit 12: Sensor temperature too high for valid test/result at time of measurement
    - bit 13: Sensor temperature too low for valid test/result at time of measurement
    - bit 14: RESERVED FOR FUTURE USE
    - bit 15: RESERVED FOR FUTURE USE
 
 - Warning-Octet
    - bit 16: Sensor result lower than the Patient Low level
    - bit 17: Sensor result higher than the Patient High level
    - bit 18: Sensor result lower than the Hypo level
    - bit 19: Sensor result higher than the Hyper level
    - bit 20: Sensor rate of decrease exceeded
    - bit 21: Sensor rate of increase exceeded
    - bit 22: Sensor result lower than the device can process
    - bit 23: Sensor result higher than the device can process
 
 E2E-CRC - uint16 (Field exists if the CGM Feature characterist bi 12 is set to 1)
 **********************************************/

#define kCGMStatusFieldRangeTimeOffset  {0,2}
#define kCGMStatusFieldRangeStatus      {2,3}
#define kCGMStatusFieldRangeCRC         {5,2}

typedef NS_ENUM (uint8_t, CGMStatusStatusOptions) {
    CGMMeasurementStatusSessionStopped                = (1 << 0),
    CGMMeasurementStatusDeviceBatteryLow              = (1 << 1),
    CGMMeasurementStatusSensorTypeIncorrect           = (1 << 2),
    CGMMeasurementStatusSensorMalfunction             = (1 << 3),
    CGMMeasurementStatusDeviceSpecificAlert           = (1 << 4),
    CGMMeasurementStatusGeneralDeviceFault            = (1 << 5),
};

typedef NS_ENUM (uint8_t, CGMStatusCalTempOption) {
    CGMMeasurementStatusTimeSynchronizationRequired   = (1 << 0),
    CGMMeasurementStatusCalibrationNotAllowed         = (1 << 1),
    CGMMeasurementStatusCalibrationRecommended        = (1 << 2),
    CGMMeasurementStatusCalibrationRequired           = (1 << 3),
    CGMMeasurementStatusSensorTooHighTemp             = (1 << 4),
    CGMMeasurementStatusSensorTooLowTemp              = (1 << 5),
};

typedef NS_ENUM (uint8_t, CGMStatusWarningOption) {
    CGMMeasurementStatusResultLowerThanPatientLow     = (1 << 0),
    CGMMeasurementStatusResultHigherThanPatientHigh   = (1 << 1),
    CGMMeasurementStatusResultLowerThanHypo           = (1 << 2),
    CGMMeasurementStatusResultHigherThanHyper         = (1 << 3),
    CGMMeasurementStatusResultExceedRateDecrease      = (1 << 4),
    CGMMeasurementStatusResultExceedRateIncrease      = (1 << 5),
    CGMMeasurementStatusSensorTooLowResult            = (1 << 6),
    CGMMeasurementStatusSensorTooHighResult           = (1 << 7),
};


#pragma mark - CGM Session Start Time
/**********  CGM Session Start Time Format (Mandatory) ***************
 Session Start Time - org.bluetooth.characteristic.date_time (Mandatory)
 - year uint16 (Mandatory)
    - Min 1582
    - Max 9999
    - value 0: unknown
 - month uint8 (Mandatory)
    - Min 0
    - Max 12
    - value 0: unknown
 - day uint8 (Mandatory)
    - Min 0
    - Max 31
    - value 0: unkonwn
 - hours uint8 (Mandatory)
    - Min 0
    - Max 23
 - minutes uint8 (Mandatory)
    - Min 0
    - Max 60
 - seconds uint8 (Mandatory)
    - Min 0
    - Max 60
 
 Time Zone - org.bluetooth.characteristic.time_zone/sint8 (Mandatory)
    - Min -48
    - Max 56
    - value 0: UTC+0:00
    - +/- 2 step: 0:30
    - +/- 4 step: 1:00
    - value -128: time zone offset is not known
 
 DST Offset - org.bluetooth.characteristic.dst_offset/uint8 (Mandatory)
    - value 0: Standard time
    - value 2: Half an hour daylight time (+0.5h)
    - value 4: Daylight time (+1h)
    - value 8: Double daylight time (+2h)
    - value 255: DST is not known
    - values 1, 3, 5-7, and 9-254: RESERVED FOR FUTURE USE
 
 E2E-CRC - uint16 (Field exists if the CGM Feature characterist bi 12 is set to 1)
 **********************************************/

#define kCGMSessionStartTimeFieldRangeYear          {0,2}
#define kCGMSessionStartTimeFieldRangeMonth         {2,1}
#define kCGMSessionStartTimeFieldRangeDay           {3,1}
#define kCGMSessionStartTimeFieldRangeHour          {4,1}
#define kCGMSessionStartTimeFieldRangeMinute        {5,1}
#define kCGMSessionStartTimeFieldRangeSecond        {6,1}
#define kCGMSessionStartTimeFieldRangeTimeZone      {7,1}
#define kCGMSessionStartTimeFieldRangeDSTOffset     {8,1}
#define kCGMSessionStartTimeFieldRangeCRC           {9,2}

#define kCGMSessionStartTimeUnknownYear     0
#define kCGMSessionStartTimeUnknownMonth    0
#define kCGMSessionStartTimeUnknownDay      0
#define kCGMSessionStartTimeUnknownTimeZone -128
#define kCGMTimeZoneStepSize                4.

typedef NS_ENUM (uint8_t, DSTOffsetOption) {
    DSTStandardTime   = 0,
    DSTPlusHourHalf   = 2,
    DSTPlusHourOne    = 4,
    DSTPlusHoursTwo   = 8,
    DSTUnknown        = 255,
};


#pragma mark - CGM Session Run Time
/**********  CGM Session Run Time Format (Mandatory) ***************
 Session Run Time - uint16 (Mandatory)
    - units in hour
    - relative time from the session start time
 
 E2E-CRC - uint16 (Field exists if the CGM Feature characterist bi 12 is set to 1)
 **********************************************/

#define kCGMSessionRunTimeFieldRangeRunTime     {0,2}
#define kCGMSessionRunTimeFieldRangeCRC         {2,2}


#pragma mark - CGM Specific Ops Control Point
#define kCGMCPFieldRangeOpCode                            {0,1}
#define kCGMCPFieldRangeResponseRequestOpCode             {1,1}
#define kCGMCPFieldRangeResponseCodeValue                 {2,1}
#define kCGMCPFieldRangeCommIntervalResponse              {1,1}
#define kCGMCPFieldRangeSFloatResponse                    {1,2}
#define kCGMCPFieldRangeCalibrationGlucoseConcentration   {1,2}
#define kCGMCPFieldRangeCalibrationTime                   {3,2}
#define kCGMCPFieldRangeCalibrationTypeLocation           {5,1}
#define kCGMCPFieldRangeCalibrationTimeNext               {6,2}
#define kCGMCPFieldRangeCalibrationRecordNumber           {8,2}
#define kCGMCPFieldRangeCalibrationStatus                 {10,1}

typedef NS_ENUM (uint8_t, CGMCPOpCode) {
    CGMCPOpCodeCommIntervalSet = 1,
    CGMCPOpCodeCommIntervalGet,
    CGMCPOpCodeCommIntervalResponse,
    CGMCPOpCodeCalibrationValueSet,
    CGMCPOpCodeCalibrationValueGet,
    CGMCPOpCodeCalibrationValueResponse,
    CGMCPOpCodeAlertLevelPatientHighSet,
    CGMCPOpCodeAlertLevelPatientHighGet,
    CGMCPOpCodeAlertLevelPatientHighResponse,
    CGMCPOpCodeAlertLevelPatientLowSet,
    CGMCPOpCodeAlertLevelPatientLowGet,
    CGMCPOpCodeAlertLevelPatientLowResponse,
    CGMCPOpCodeAlertLevelHypoSet,
    CGMCPOpCodeAlertLevelHypoGet,
    CGMCPOpCodeAlertLevelHypoReponse,
    CGMCPOpCodeAlertLevelHyperSet,
    CGMCPOpCodeAlertLevelHyperGet,
    CGMCPOpCodeAlertLevelHyperReponse,
    CGMCPOpCodeAlertLevelRateDecreaseSet,
    CGMCPOpCodeAlertLevelRateDecreaseGet,
    CGMCPOpCodeAlertLevelRateDecreaseResponse,
    CGMCPOpCodeAlertLevelRateIncreaseSet,
    CGMCPOpCodeAlertLevelRateIncreaseGet,
    CGMCPOpCodeAlertLevelRateIncreaseResponse,
    CGMCPOpCodeAlertDeviceSpecificReset,
    CGMCPOpCodeSessionStart,
    CGMCPOpCodeSessionStop,
    CGMCPOpCodeResponse,
};

typedef NS_ENUM (uint8_t, CGMCPResponseCode) {
    CGMCPSuccess = 1,
    CGMCPOpCodeNotSupported,
    CGMCPInvalidOperand,
    CGMCPProcedureNotCompleted,
    CGMCPParameterOutOfRange,
};
