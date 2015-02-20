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

#import "UHNBLETypes.h"

///----------------
/// @name RACP Keys
///----------------
#pragma mark - Keys

/**
 Keys shared between characteristic details
 */
#define kCGMKeyDateTime @"CGMDateTime"
#define kCGMKeyDateTimeNext @"CGMDateTimeNext"
#define kCGMKeyTimeOffset @"CGMTimeOffset"
#define kCGMKeyTimeOffsetNext @"CGMTimeOffsetNext"
#define kCGMCRCFailed @"CGMCRCFailed"

/**
 Keys for Measurement Characteristic
 */
#define kCGMMeasurementKeyGlucoseConcentration @"CGMGlucoseConcentration"
#define kCGMMeasurementKeyTrendInfo @"CGMTrendInformation"
#define kCGMMeasurementKeyQuality @"CGMMeasurementQuality"

/** 
 Keys for Status Characteristic
 */
#define kCGMStatusKeySensorStatus @"CGMSensorStatus"
#define kCGMStatusKeyOctetStatus @"CGMStatusOctet"
#define kCGMStatusKeyOctetCalTemp @"CGMCalTempOctet"
#define kCGMStatusKeyOctetWarning @"CGMWarningOctet"

/**
 Keys for Feature Characteristic
 */
#define kCGMFeatureKeyFeatures @"CGMFeatures"
#define kCGMFeatureKeyFluidType @"CGMFluidType"
#define kCGMFeatureKeySampleLocation @"CGMSampleLocation"

/**
 Keys for Specific Ops Control Point
 */
#define kCGMCPKeyOpCode @"CGMCPOpCode"
#define kCGMCPKeyOperand @"CGMCPOperand"
#define kCGMCPKeyResponseDetails @"CGMCPResponseDetails"
#define kCGMCPKeyResponseRequestOpCode @"CGMCPResponseRequestOpCode"
#define kCGMCPKeyResponseCodeValue @"CGMCPResponseCodeValue"
#define kCGMCPKeyResponseCalibration  @"CGMCPCalibrationResponse"
#define kCGMCalibrationKeyValue @"CGMCalibrationValue"
#define kCGMCalibrationKeyFluidType @"CGMCalibrationFluidType"
#define kCGMCalibrationKeySampleLocation @"CGMCalibrationSampleLocation"
#define kCGMCalibrationKeyRecordNumber @"CGMCalibrationRecordNumber"
#define kCGMCalibrationKeyStatus @"CGMCalibrationStatus"

///-----------------------
/// @name CGM Service UUID
///-----------------------
#pragma mark - CGM Service UUID
#define kCGMServiceUUID @"181F"

///-------------------------------
/// @name CGM Characteristic UUIDs
///-------------------------------
#pragma mark - Characteristic UUIDs
#define kCGMCharacteristicUUIDMeasurement @"2AA7"
#define kCGMCharacteristicUUIDFeature @"2AA8"
#define kCGMCharacteristicUUIDStatus @"2AA9"
#define kCGMCharacteristicUUIDSessionStartTime @"2AAA"
#define kCGMCharacteristicUUIDSessionRunTime @"2AAB"
#define kCGMCharacteristicUUIDRecordAccessControlPoint @"2A52"
#define kCGMCharacteristicUUIDSpecificOpsControlPoint @"2AAC"

///-------------------------------------
/// @name CGM Measurement Characteristic
///-------------------------------------
#pragma mark - CGM Measurement Characteristic
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


///------------------------------------------------------------
/// @name CGM Measurement Characteristic Field Ranges and Sizes
///------------------------------------------------------------
/**
 CGM measurement characteristic field ranges and sizes. Note that the ranges are type casted to make easy use in code
 */
#define kCGMMeasurementFieldRangeSize                   (NSRange){0,1}
#define kCGMMeasurementFieldRangeFlags                  (NSRange){1,1}
#define kCGMMeasurementFieldRangeGlucoseConcentration   (NSRange){2,2}
#define kCGMMeasurementFieldRangeTimeOffset             (NSRange){4,2}
#define kCGMMeasurementFieldSizeTrendInfo               2
#define kCGMMeasurementFieldSizeQuality                 2
#define kCGMMeasurementFieldSizeCRC                     2


///--------------------------------------------------
/// @name CGM Measurement Characteristic Enumerations
///--------------------------------------------------
/**
 All possible CGM measurement flags with their assigned bit position
 */
typedef NS_ENUM (uint8_t, CGMMeasurementFlagOption) {
    /** Flag indicating that glucose trend information is present in the measurement */
    CGMMeasurementFlagsTrendInformationPresent  = (1 << 0),
    /** Flag indicating that glucose quality information is present in the measurement */
    CGMMeasurementFlagsQualityPresent           = (1 << 1),
    /** Flag indicating that the sensor status status details is present in the measurement */
    CGMMeasurementFlagsStatusOctetPresent       = (1 << 5),
    /** Flag indicating that the sensor status calibration and temperature details is present in the measurement */
    CGMMeasurementFlagsCalTempOctetPresent      = (1 << 6),
    /** Flag indicating that the sensor status warning details is present in the measurement */
    CGMMeasurementFlagsWarningOctetPresent      = (1 << 7),
};


///---------------------------------
/// @name CGM Feature Characteristic
///---------------------------------
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
 * field values are defined in UHNBLEController pod (UHNBLETypes.h)
 
 Sample Location - nibble/4 bit (Mandatory)
    - value 0: RESERVED FOR FUTURE USE
    - value 1: Finger
    - value 2: Alternate Site Test (AST)
    - value 3: Earlobe
    - value 4: Control solution
    - value 5: Subcutaneous tissue
    - value 15: Sample Location value not available
    - value 6-14: RESERVED FOR FUTURE USE
 * field values are defined in UHNBLEController pod (UHNBLETypes.h)
 
 E2E-CRC - uint16 (Mandatory)
    - If E2E-CRC support is not indicated in the CGM Feature characteristic (bit 12), this field's value is 0xFFFF
 **********************************************/


///----------------------------------------------
/// @name CGM Feature Characteristic Field Ranges
///----------------------------------------------
/**
 CGM feature characteristic field ranges. Note that they are type casted to make easy use in code
 */
#define kCGMFeatureFieldRangeFeatures               (NSRange){0,3}
#define kCGMFeatureFieldRangeTypeLocation           (NSRange){3,1}
#define kCGMFeatureFieldRangeCRC                    (NSRange){4,2}


///----------------------------------------------
/// @name CGM Feature Characteristic Enumerations
///----------------------------------------------
/**
 All possible CGM feature flags with their assigned bit position
 */
typedef NS_ENUM (uint32_t, CGMFeatureOption) {
    /** Flag indicating that calibration is supported by the CGM sensor */
    CGMFeatureSupportedCalibration                     = (1 << 0),
    /** Flag indicating that the patient low and high alert levels are supported by the CGM sensor */
    CGMFeatureSupportedAlertLowHighPatient             = (1 << 1),
    /** Flag indicating that the hypo alert level is supported by the CGM sensor */
    CGMFeatureSupportedAlertHypo                       = (1 << 2),
    /** Flag indicating that the hyper alert level is supported by the CGM sensor */
    CGMFeatureSupportedAlertHyper                      = (1 << 3),
    /** Flag indicating that the rate of increase and decrease alert levels are supported by the CGM sensor */
    CGMFeatureSupportedAlertIncreaseDecreaseRate       = (1 << 4),
    /** Flag indicating that the device specific alert is supported by the CGM sensor */
    CGMFeatureSupportedAlertDeviceSpecific             = (1 << 5),
    /** Flag indicating that the detection of sensor malfunctions is supported by the CGM sensor */
    CGMFeatureSupportedSensorDetectionMalfunction      = (1 << 6),
    /** Flag indicating that the detection of sensor temperature too low and too high for accurate measurement results is supported by the CGM sensor */
    CGMFeatureSupportedSensorDetectionLowHighTemp      = (1 << 7),
    /** Flag indicating that the detection of results outside of the sensor lower and upper limits is supported by the CGM sensor */
    CGMFeatureSupportedSensorDetectionLowHighResult    = (1 << 8),
    /** Flag indicating that low battery alert is supported by the CGM sensor */
    CGMFeatureSupportedLowBattery                      = (1 << 9),
    /** Flag indicating that the detection of incorrect sensor type is supported by the CGM sensor */
    CGMFeatureSupportedSensorDetectionTypeError        = (1 << 10),
    /** Flag indicating that general device fault alert is supported by the CGM sensor */
    CGMFeatureSupportedGeneralDeviceFault              = (1 << 11),
    /** Flag indicating that end-to-end CRC is supported by the CGM sensor */
    CGMFeatureSupportedE2ECRC                          = (1 << 12),
    /** Flag indicating that multiple bonds is supported by the CGM sensor */
    CGMFeatureSupportedMultipleBond                    = (1 << 13),
    /** Flag indicating that multiple sessions is supported by the CGM sensor */
    CGMFeatureSupportedMultipleSession                 = (1 << 14),
    /** Flag indicating that measurement trend is supported by the CGM sensor */
    CGMFeatureSupportedCGMTrend                        = (1 << 15),
    /** Flag indicating that measurement quality is supported by the CGM sensor */
    CGMFeatureSupportedCGMQuality                      = (1 << 16),
};


///--------------------------------
/// @name CGM Status Characteristic
///--------------------------------
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


///------------------------------------------------------------
/// @name CGM Status Characteristic Field Ranges and Sizes
///------------------------------------------------------------
/**
 CGM status characteristic field ranges and sizes. Note that the ranges are type casted to make easy use in code
 */
#define kCGMStatusFieldRangeTimeOffset              (NSRange){0,2}
#define kCGMStatusFieldRangeStatus                  (NSRange){2,3}
#define kCGMStatusFieldRangeCRC                     (NSRange){5,2}
#define kCGMStatusFieldSizeOctet                    1


///---------------------------------------------
/// @name CGM Sensor Status Characteristic Enumerations
///---------------------------------------------
/**
 All possible CGM sensor status flags with their assigned bit position
 */
typedef NS_ENUM (uint8_t, CGMStatusStatusOptions) {
    /** Flag indicating that the session has stopped */
    CGMStatusStatusSessionStopped                = (1 << 0),
    /** Flag indicating that the device battery is low */
    CGMStatusStatusDeviceBatteryLow              = (1 << 1),
    /** Flag indicating that the sensor type is incorrect */
    CGMStatusStatusSensorTypeIncorrect           = (1 << 2),
    /** Flag indicating that the sensor has malfunctioned */
    CGMStatusStatusSensorMalfunction             = (1 << 3),
    /** Flag indicating that the device had a specific alert */
    CGMStatusStatusDeviceSpecificAlert           = (1 << 4),
    /** Flag indicating that the device had a general fault */
    CGMStatusStatusGeneralDeviceFault            = (1 << 5),
};

/**
 All possible CGM sessor status calibration and temperature flags with their assigned bit position
 */
typedef NS_ENUM (uint8_t, CGMStatusCalTempOption) {
    /** Flag indicating that time synchronization between the sensor and collector is required */
    CGMStatusCalTempTimeSynchronizationRequired   = (1 << 0),
    /** Flag indicating that calibration is not allowed */
    CGMStatusCalTempCalibrationNotAllowed         = (1 << 1),
    /** Flag indicating that calibration is recommended */
    CGMStatusCalTempCalibrationRecommended        = (1 << 2),
    /** Flag indicating that calibration is required */
    CGMStatusCalTempCalibrationRequired           = (1 << 3),
    /** Flag indicating that sensor temperature is too high for accurate measurement results */
    CGMStatusCalTempSensorTempTooHigh             = (1 << 4),
    /** Flag indicating that sensor temperature is too low for accurate measurement results */
    CGMStatusCalTempSensorTempTooLow              = (1 << 5),
};

/**
 All possible CGM sessor status warning flags with their assigned bit position
 */
typedef NS_ENUM (uint8_t, CGMStatusWarningOption) {
    /** Flag indicating that glucose measurement exceeded the patient low alert level */
    CGMStatusWarningResultLowerThanPatientLow     = (1 << 0),
    /** Flag indicating that glucose measurement exceeded the patient high alert level */
    CGMStatusWarningResultHigherThanPatientHigh   = (1 << 1),
    /** Flag indicating that glucose measurement exceeded the hypo alert level */
    CGMStatusWarningResultLowerThanHypo           = (1 << 2),
    /** Flag indicating that glucose measurement exceeded the hyper alert level */
    CGMStatusWarningResultHigherThanHyper         = (1 << 3),
    /** Flag indicating that glucose measurement exceeded the rate of decrease alert level */
    CGMStatusWarningResultExceedRateDecrease      = (1 << 4),
    /** Flag indicating that glucose measurement exceeded the rate of increase alert level */
    CGMStatusWarningResultExceedRateIncrease      = (1 << 5),
    /** Flag indicating that glucose measurement exceeded the sensor lower limit */
    CGMStatusWarningSensorResultTooLow            = (1 << 6),
    /** Flag indicating that glucose measurement exceeded the sensor upper limit */
    CGMStatusWarningSensorResultTooHigh           = (1 << 7),
};

///--------------------------------------------
/// @name CGM Session Start Time Characteristic
///--------------------------------------------
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


///----------------------------------------------------------------------------
/// @name CGM Session Start Time Characteristic Field Ranges and Defined Values
///----------------------------------------------------------------------------
/**
 CGM session start time characteristic field ranges and defined values. Note that the ranges are type casted to make easy use in code
 */
#define kCGMSessionStartTimeFieldRangeYear          (NSRange){0,2}
#define kCGMSessionStartTimeFieldRangeMonth         (NSRange){2,1}
#define kCGMSessionStartTimeFieldRangeDay           (NSRange){3,1}
#define kCGMSessionStartTimeFieldRangeHour          (NSRange){4,1}
#define kCGMSessionStartTimeFieldRangeMinute        (NSRange){5,1}
#define kCGMSessionStartTimeFieldRangeSecond        (NSRange){6,1}
#define kCGMSessionStartTimeFieldRangeTimeZone      (NSRange){7,1}
#define kCGMSessionStartTimeFieldRangeDSTOffset     (NSRange){8,1}
#define kCGMSessionStartTimeFieldRangeCRC           (NSRange){9,2}

#define kCGMSessionStartTimeUnknownYear             0
#define kCGMSessionStartTimeUnknownMonth            0
#define kCGMSessionStartTimeUnknownDay              0
#define kCGMSessionStartTimeUnknownTimeZone         -128
#define kCGMTimeZoneStepSizeMin30                   2.
#define kCGMTimeZoneStepSizeMin60                   4.

///---------------------------------------------------------
/// @name CGM Session Start Time Characteristic Enumerations
///---------------------------------------------------------
/**
 All possible CGM session start time DST options with their assigned value
 */
typedef NS_ENUM (uint8_t, DSTOffsetOption) {
    /** DST option indicating standard time (no offset) */
    DSTStandardTime   = 0,
    /** DST option indicating standard time plus half hour offset */
    DSTPlusHourHalf   = 2,
    /** DST option indicating standard time plus hour offset */
    DSTPlusHourOne    = 4,
    /** DST option indicating standard time plus two hours offset */
    DSTPlusHoursTwo   = 8,
    /** DST option indicating the offset is unknown */
    DSTUnknown        = 255,
};

///--------------------------------------------
/// @name CGM Session Run Time Characteristic
///--------------------------------------------
#pragma mark - CGM Session Run Time
/**********  CGM Session Run Time Format (Mandatory) ***************
 Session Run Time - uint16 (Mandatory)
    - units in hour
    - relative time from the session start time
 
 E2E-CRC - uint16 (Field exists if the CGM Feature characterist bi 12 is set to 1)
 **********************************************/

///-------------------------------------------------------
/// @name CGM Session Run Time Characteristic Field Ranges
///-------------------------------------------------------
/**
 CGM session run time characteristic field ranges. Note that they are type casted to make easy use in code
 */
#define kCGMSessionRunTimeFieldRangeRunTime                 (NSRange){0,2}
#define kCGMSessionRunTimeFieldRangeCRC                     (NSRange){2,2}

///------------------------------------------------------------
/// @name CGM Specific Ops Control Point (CMGCP) Characteristic
///------------------------------------------------------------
#pragma mark - CGM Specific Ops Control Point


///----------------------------------------
/// @name CGMCP Characteristic Field Ranges
///----------------------------------------
/**
 CGMCP characteristic field ranges. Note that they are type casted to make easy use in code
 */
#define kCGMCPFieldRangeOpCode                              (NSRange){0,1}
#define kCGMCPFieldRangeResponseRequestOpCode               (NSRange){1,1}
#define kCGMCPFieldRangeResponseCodeValue                   (NSRange){2,1}
#define kCGMCPFieldRangeCommIntervalResponse                (NSRange){1,1}
#define kCGMCPFieldRangeSFloatResponse                      (NSRange){1,2}
#define kCGMCPFieldRangeCalibrationGlucoseConcentration     (NSRange){1,2}
#define kCGMCPFieldRangeCalibrationTime                     (NSRange){3,2}
#define kCGMCPFieldRangeCalibrationTypeLocation             (NSRange){5,1}
#define kCGMCPFieldRangeCalibrationTimeNext                 (NSRange){6,2}
#define kCGMCPFieldRangeCalibrationRecordNumber             (NSRange){8,2}
#define kCGMCPFieldRangeCalibrationStatus                   (NSRange){10,1}


///---------------------------------------------------------
/// @name CGMCP Characteristic Enumerations
///---------------------------------------------------------
/**
 All possible CGMCP Op Codes with their assigned value
 */
typedef NS_ENUM (uint8_t, CGMCPOpCode) {
    /** CGMCP op code indicating a set communication interval request */
    CGMCPOpCodeCommIntervalSet = 1,
    /** CGMCP op code indicating a get communication interval request */
    CGMCPOpCodeCommIntervalGet,
    /** CGMCP op code indicating a get communication interval response */
    CGMCPOpCodeCommIntervalResponse,
    /** CGMCP op code indicating a set calibration value request */
    CGMCPOpCodeCalibrationValueSet,
    /** CGMCP op code indicating a get calibration value request */
    CGMCPOpCodeCalibrationValueGet,
    /** CGMCP op code indicating a get calibration value response */
    CGMCPOpCodeCalibrationValueResponse,
    /** CGMCP op code indicating a set patient high alert level request */
    CGMCPOpCodeAlertLevelPatientHighSet,
    /** CGMCP op code indicating a get patient high alert level request */
    CGMCPOpCodeAlertLevelPatientHighGet,
    /** CGMCP op code indicating a get patient high alert level response */
    CGMCPOpCodeAlertLevelPatientHighResponse,
    /** CGMCP op code indicating a set patient low alert level request */
    CGMCPOpCodeAlertLevelPatientLowSet,
    /** CGMCP op code indicating a get patient low alert level request */
    CGMCPOpCodeAlertLevelPatientLowGet,
    /** CGMCP op code indicating a get patient low alert level response */
    CGMCPOpCodeAlertLevelPatientLowResponse,
    /** CGMCP op code indicating a set hypo alert level request */
    CGMCPOpCodeAlertLevelHypoSet,
    /** CGMCP op code indicating a get hypo alert level request */
    CGMCPOpCodeAlertLevelHypoGet,
    /** CGMCP op code indicating a get hypo alert level response */
    CGMCPOpCodeAlertLevelHypoReponse,
    /** CGMCP op code indicating a set hyper alert level request */
    CGMCPOpCodeAlertLevelHyperSet,
    /** CGMCP op code indicating a get hyper alert level request */
    CGMCPOpCodeAlertLevelHyperGet,
    /** CGMCP op code indicating a get hyper alert level response */
    CGMCPOpCodeAlertLevelHyperReponse,
    /** CGMCP op code indicating a set rate of decrease alert level request */
    CGMCPOpCodeAlertLevelRateDecreaseSet,
    /** CGMCP op code indicating a get rate of decrease alert level request */
    CGMCPOpCodeAlertLevelRateDecreaseGet,
    /** CGMCP op code indicating a get rate of decrease alert level response */
    CGMCPOpCodeAlertLevelRateDecreaseResponse,
    /** CGMCP op code indicating a set rate of increase alert level request */
    CGMCPOpCodeAlertLevelRateIncreaseSet,
    /** CGMCP op code indicating a get rate of increase alert level request */
    CGMCPOpCodeAlertLevelRateIncreaseGet,
    /** CGMCP op code indicating a get rate of increase alert level response */
    CGMCPOpCodeAlertLevelRateIncreaseResponse,
    /** CGMCP op code indicating a device specific alert reset request */
    CGMCPOpCodeAlertDeviceSpecificReset,
    /** CGMCP op code indicating a start session request */
    CGMCPOpCodeSessionStart,
    /** CGMCP op code indicating a stop session request */
    CGMCPOpCodeSessionStop,
    /** CGMCP op code indicating a general response */
    CGMCPOpCodeResponse,
};

/**
 All possible CGMCP Response Codes for a general response with their assigned value
 */
typedef NS_ENUM (uint8_t, CGMCPResponseCode) {
    /** CGMCP response code indicating the request was successful */
    CGMCPSuccess = 1,
    /** CGMCP response code indicating the requested op code is not supported */
    CGMCPOpCodeNotSupported,
    /** CGMCP response code indicating the requested operand is invalid */
    CGMCPInvalidOperand,
    /** CGMCP response code indicating the requested procedure was not completed */
    CGMCPProcedureNotCompleted,
    /** CGMCP response code indicating the parameter sent with the request is out of the supported range of the sensor */
    CGMCPParameterOutOfRange,
};

/**
 All possible CGMCP Calibration Status options
 
 @discussion If none of the options are true, then the calibration data record was valid and accepted
 */
typedef NS_ENUM (uint8_t, CGMCPCalibrationStatusOption) {
    /** Calibration status indicating that the calibration data was rejected */
    CGMCPCalibrationStatusDataRejected = 0,
    /** Calibration status indicating that the calibration data was out-of-range */
    CGMCPCalibrationStatusDataOutOfRange,
    /** Calibration status indicating that the calibration process is still pending */
    CGMCPCalibrationStatusProcessPending,
};

///-----------------------
/// @name Time Definitions
///-----------------------
/**
 These time definitions are needed to help with time offset calculations, day light saving offet, and time zone offset
 */
#define kMinutesInHour 60.
#define kSecondsInMinute 60.
#define kSecondsInHour (kMinutesInHour * kSecondsInMinute)
