//
//  NSDictionary+CGMExtensions.h
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

#import <Foundation/Foundation.h>
#import "UHNCGMConstants.h"

/**
 `NSDictionary+CGMExtensions` provides helper methods for interpreting the dictionary returned by the `[NSData+CGMParser]`
 */
@interface NSDictionary (CGMExtensions)

///--------------------------
/// @name Shared Values/Flags
///--------------------------
/** 
 Checks if the E2E-CRC included in the response failed
 
 @return `YES` if the E2E-CRC failed, otherwise `NO`
 
 */
- (BOOL)didCRCFail;

///-------------------------
/// @name Measurement Values
///-------------------------
/**
 Checks the measurement characteristic details for the glucose measurement date and time
 
 @return The date and time of the glucose measurement as calculated using the measurement time offset and session start time. If the date and time cannot be calculated, `nil` is returned.
 
 @discussion The glucose measurement date and time is only available if the CGM controller knows the session start time.
 
 */
- (NSDate*)measurementDateTime;

/**
 Checks the measurement characteristic details for the glucose measurement time offset
 
 @return The measurement time offset. Units is minutes
 
 @discussion The measurement time offset indicates the time of measurement as minutes from the session start time. Also, it can be considered a sequence number.
 
 */
- (NSNumber*)measurementTimeOffset;

/**
 Checks the measurement characteristic details for the glucose concentration value
 
 @return The glucose centration value. Units is mg/dl
 
 */
- (NSNumber*)glucoseValue;

/**
 Checks the measurement characteristic details for the glucose trend value
 
 @return The glucose trend value. Units is (mg/dl)/min
 
 @discussion If a trend value is not available, returns `nil`
 
 */
- (NSNumber*)trendValue;

/**
 Checks the measurement characteristic details for the glucose quality value
 
 @return The glucose quality value. Units is %
 
 @discussion If a quality value is not available, returns `nil`
 
 */
- (NSNumber*)qualityValue;

///---------------------------------
/// @name Sensor Status
///---------------------------------
/**
 Checks the status characteristic details for the sensor status date and time
 
 @return The date and time of the sensor status as calculated using the status time offset and session start time. If the date and time cannot be calculated, `nil` is returned.
 
 @discussion The sensor status date and time is only available if the CGM controller knows the session start time.
 
 */
- (NSDate*)statusDateTime;

/**
 Checks the status characteristic details for the sensor status time offset
 
 @return The sensor status time offset. Units is minutes
 
 @discussion The sensor status time offset indicates the time of the sensor status as minutes from the session start time.
 
 */
- (NSNumber*)statusTimeOffset;

///---------------------------------
/// @name Sensor Status Status Flags
///---------------------------------
/**
 Checks the status characteristic details for indication that the session has stopped
 
 @return `YES` if the session has stopped, otherwise `NO`
 
 */
- (BOOL)hasSessionStopped;

/**
 Checks the status characteristic details for indication that the device battery is low
 
 @return `YES` if the battery is low, otherwise `NO`
 
 */
- (BOOL)isDeviceBatteryLow;

/**
 Checks the status characteristic details for indication that the sensor type is incorrect
 
 @return `YES` if the sensor type is incorrect, otherwise `NO`
 
 */
- (BOOL)isSensorTypeIncorrect;

/**
 Checks the status characteristic details for indication that the device has malfunctioned
 
 @return `YES` if the device has malfunctioned, otherwise `NO`
 
 */
- (BOOL)didSensorMalfunction;

/**
 Checks the status characteristic details for indication that the device has had a specific alert
 
 @return `YES` if the device has had a specific alert, otherwise `NO`
 
 */
- (BOOL)hasDeviceSpecificAlert;

/**
 Checks the status characteristic details for indication that the device has had a general fault
 
 @return `YES` if the device has had a general fault, otherwise `NO`
 
 */
- (BOOL)hasGeneraldeviceFault;

///----------------------------------
/// @name Sensor Status Cal/Temp Flags
///----------------------------------
/**
 Checks the status characteristic details for indication that time synchronization is required between the sensor and collector
 
 @return `YES` if time synchronization is required, otherwise `NO`
 
 */
- (BOOL)isTimeSynchronizationRequired;

/**
 Checks the status characteristic details for indication that calibration is not allowed
 
 @return `YES` if calibration is not allowed, otherwise `NO`
 
 */
- (BOOL)isCalibrationNotAllowed;

/**
 Checks the status characteristic details for indication that calibration is recommended
 
 @return `YES` if calibration is recommended, otherwise `NO`
 
 */
- (BOOL)isCalibrationRecommended;

/**
 Checks the status characteristic details for indication that calibration is required
 
 @return `YES` if calibration is required, otherwise `NO`
 
 */
- (BOOL)isCalibrationRequired;

/**
 Checks the status characteristic details for indication that the sensor temperature is too high to provide accurate glucose meaurements
 
 @return `YES` if the sensor temperature is too high, otherwise `NO`
 
 */
- (BOOL)isSensorTempTooHigh;

/**
 Checks the status characteristic details for indication that the sensor temperature is too low to provide accurate glucose meaurements
 
 @return `YES` if the sensor temperature is too low, otherwise `NO`
 
 */
- (BOOL)isSensorTempTooLow;

///----------------------------------
/// @name Sensor Status Warning Flags
///----------------------------------
/**
 Checks the status characteristic details for indication that the measurement value has exceeded the hypo alert level
 
 @return `YES` if the measurement value has exceeded the hypo alert level, otherwise `NO`
 
 */
- (BOOL)hasExceededLevelHypo;

/**
 Checks the status characteristic details for indication that the measurement value has exceeded the hyper alert level
 
 @return `YES` if the measurement value has exceeded the hyper alert level, otherwise `NO`
 
 */
- (BOOL)hasExceededLevelHyper;

/**
 Checks the status characteristic details for indication that the measurement value has exceeded the patient low alert level
 
 @return `YES` if the measurement value has exceeded the patient low alert level, otherwise `NO`
 
 */
- (BOOL)hasExceededLevelPatientLow;

/**
 Checks the status characteristic details for indication that the measurement value has exceeded the patient high alert level
 
 @return `YES` if the measurement value has exceeded the patient high alert level, otherwise `NO`
 
 */
- (BOOL)hasExceededLevelPatientHigh;

/**
 Checks the status characteristic details for indication that the measurement value has exceeded the rate of decrease alert level
 
 @return `YES` if the measurement value has exceeded the rate of decrease alert level, otherwise `NO`
 
 */
- (BOOL)hasExceededRateDecrease;

/**
 Checks the status characteristic details for indication that the measurement value has exceeded the rate of increase alert level
 
 @return `YES` if the measurement value has exceeded the rate of increase alert level, otherwise `NO`
 
 */
- (BOOL)hasExceededRateIncrease;

/**
 Checks the status characteristic details for indication that the measurement value has exceeded the device lower limit
 
 @return `YES` if the measurement value has exceeded the device lower limit, otherwise `NO`
 
 */
- (BOOL)hasExceededDeviceLimitLow;

/**
 Checks the status characteristic details for indication that the measurement value has exceeded the device upper limit
 
 @return `YES` if the measurement value has exceeded the device upper limit, otherwise `NO`
 
 */
- (BOOL)hasExceededDeviceLimitHigh;


///--------------------
/// @name Feature Flags
///--------------------
/**
 Checks the feature characteristic details for indication that the sensor supports calibration
 
 @return `YES` if the sensor supports calibration, otherwise `NO`
 
 */
- (BOOL)supportsCalibration;

/**
 Checks the feature characteristic details for indication that the sensor supports the patient low and high alert levels
 
 @return `YES` if the sensor supports the patient low and high alert levels, otherwise `NO`
 
 */
- (BOOL)supportsAlertLowHighPatient;

/**
 Checks the feature characteristic details for indication that the sensor supports the hypo alert level
 
 @return `YES` if the sensor supports the hypo alert level, otherwise `NO`
 
 */
- (BOOL)supportsAlertHypo;

/**
 Checks the feature characteristic details for indication that the sensor supports the hyper alert level
 
 @return `YES` if the sensor supports the hyper alert level, otherwise `NO`
 
 */
- (BOOL)supportsAlertHyper;

/**
 Checks the feature characteristic details for indication that the sensor supports the rate of increase and decrease alert levels
 
 @return `YES` if the sensor supports the rate of increase and decrease alert levels, otherwise `NO`
 
 */
- (BOOL)supportsAlertIncreaseDecreaseRate;

/**
 Checks the feature characteristic details for indication that the sensor supports the device specific alert
 
 @return `YES` if the sensor supports the device specifc alert, otherwise `NO`
 
 */
- (BOOL)supportsAlertDeviceSpecific;

/**
 Checks the feature characteristic details for indication that the sensor supports the detection of sensor malfunction
 
 @return `YES` if the sensor supports the detection of sensor malfunction, otherwise `NO`
 
 */
- (BOOL)supportsSensorDetectionMalfunction;

/**
 Checks the feature characteristic details for indication that the sensor supports the detection of sensor temperature too low or too high
 
 @return `YES` if the sensor supports the detection of sensor temperature too low or too high, otherwise `NO`
 
 */
- (BOOL)supportsSensorDetectionLowHighTemp;

/**
 Checks the feature characteristic details for indication that the sensor supports the detection of glucose measurements exceeding the sensor's lower or upper limits
 
 @return `YES` if the sensor supports the detection of glucose measurements exceeding the sensor's lower or upper limits, otherwise `NO`
 
 */
- (BOOL)supportsSensorDetectionLowHighResult;

/**
 Checks the feature characteristic details for indication that the sensor supports the low battery alert
 
 @return `YES` if the sensor supports the low battery alert, otherwise `NO`
 
 */
- (BOOL)supportsSensorLowBattery;

/**
 Checks the feature characteristic details for indication that the sensor supports the detection of sensor type error
 
 @return `YES` if the sensor supports the detection of sensor type error, otherwise `NO`
 
 */
- (BOOL)supportsSensorDetectionTypeError;

/**
 Checks the feature characteristic details for indication that the sensor supports the general device fault
 
 @return `YES` if the sensor supports the general device fault, otherwise `NO`
 
 */
- (BOOL)supportsGeneralDeviceFault;

/**
 Checks the feature characteristic details for indication that the sensor supports the end-to-end CRC
 
 @return `YES` if the sensor supports the end-to-end CRC, otherwise `NO`
 
 */
- (BOOL)supportsE2ECRC;

/**
 Checks the feature characteristic details for indication that the sensor supports multiple bonds
 
 @return `YES` if the sensor supports multiple bonds, otherwise `NO`
 
 */
- (BOOL)supportsMultipleBond;

/**
 Checks the feature characteristic details for indication that the sensor supports multiple sessions
 
 @return `YES` if the sensor supports multiple sessions, otherwise `NO`
 
 */
- (BOOL)supportsMultipleSession;

/**
 Checks the feature characteristic details for indication that the sensor supports the glucose measurement trend feature
 
 @return `YES` if the sensor supports the glucose measurement trend feature, otherwise `NO`
 
 */
- (BOOL)supportsCGMTrend;

/**
 Checks the feature characteristic details for indication that the sensor supports the glucose measurement quality feature
 
 @return `YES` if the sensor supports the glucose measurement quality feature, otherwise `NO`
 
 */
- (BOOL)supportsCGMQuality;

///-------------------------------------
/// @name CGM Specific Ops Control Point
///-------------------------------------
/**
 Checks the CGMCP characteristic details that the response is a general response
 
 @return `YES` if the response was a general response, otherwise `NO`
 
 */
- (BOOL)isGeneralResponse;

/**
 Checks the CGMCP characteristic details that the response is a communication interval response
 
 @return `YES` if the response was a communication interval response, otherwise `NO`
 
 */
- (BOOL)isCommunicationIntervalResponse;

/**
 Checks the CGMCP characteristic details that the response is a patient high response
 
 @return `YES` if the response was a patient high response, otherwise `NO`
 
 */
- (BOOL)isAlertLevelPatientHighResponse;

/**
 Checks the CGMCP characteristic details that the response is a patient low response
 
 @return `YES` if the response was a patient low response, otherwise `NO`
 
 */
- (BOOL)isAlertLevelPatientLowResponse;

/**
 Checks the CGMCP characteristic details that the response is a hypo alert level response
 
 @return `YES` if the response was a hypo alert level response, otherwise `NO`
 
 */
- (BOOL)isAlertLevelHypoReponse;

/**
 Checks the CGMCP characteristic details that the response is a hyper alert level response
 
 @return `YES` if the response was a hyper alert level response, otherwise `NO`
 
 */
- (BOOL)isAlertLevelHyperReponse;

/**
 Checks the CGMCP characteristic details that the response is a rate decreased alert level response
 
 @return `YES` if the response was a rate decreased alert level response, otherwise `NO`
 
 */
- (BOOL)isAlertLevelRateDecreasedReponse;

/**
 Checks the CGMCP characteristic details that the response is a rate increased alert level response
 
 @return `YES` if the response was a rate increased alert level response, otherwise `NO`
 
 */
- (BOOL)isAlertLevelRateIncreasedReponse;

/**
 Get the CGMCP response code from a CGMCP general response
 
 @return The response code, as defined in `UHNCGMConstants.h`
 
 @discussion If a value of 0 is returned, no response code valuex was found
 
 */
- (CGMCPResponseCode)responseCode;

/**
 Get the CGMCP request op code from a CGMCP general response
 
 @return The request op code is the operation just completed by the CGMCP and for which these response details are related to. The values are defined in `UHNCGMConstants.h`
 
 @discussion If a value of 0 is returned, no request op code was found
 
 */
- (CGMCPOpCode)requestOpCode;

/**
 Get the CGMCP response value
 
 @return A `NSNumber` with the response value. Values will either be integers or floats, depending on the CGMCP request
 
 @discussion A value will be returned for the following response types, otherwise `nil`
    
    CGMCPOpCodeCommIntervalResponse             (integer)
    CGMCPOpCodeAlertLevelPatientHighResponse    (float)
    CGMCPOpCodeAlertLevelPatientLowResponse     (float)
    CGMCPOpCodeAlertLevelHypoReponse            (float)
    CGMCPOpCodeAlertLevelHyperReponse           (float)
    CGMCPOpCodeAlertLevelRateDecreaseResponse   (float)
    CGMCPOpCodeAlertLevelRateIncreaseResponse   (float)
 
 */
- (NSNumber*)responseValue;

///---------------------------------------------------
/// @name CGM Specific Ops Control Point - Calibration
///---------------------------------------------------
/**
 Checks the CGMCP characteristic details that the response is a calibration response
 
 @return `YES` if the response was a rate increased alert level response, otherwise `NO`
 
 */
- (BOOL)isCalibrationReponse;

/**
 Checks the calibration details for the calibration date and time
 
 @return The date and time of the calibration as calculated using the calibration time offset and session start time. If the date and time cannot be calculated, `nil` is returned.
 
 @discussion The calibration date and time is only available if the CGM controller knows the session start time.
 
 */
- (NSDate*)calibrationDateTime;

/**
 Checks the calibration details for the calibration time offset
 
 @return The calibration time offset. Units is minutes
 
 @discussion The calibration time offset indicates the time of calibration as minutes from the session start time.
 
 */
- (NSNumber*)calibrationTimeOffset;

/**
 Checks the calibration details for the calibration fluid type
 
 @return The calibration fluid type, as defined in `UHNCGMConstants.h`
 
 */
- (GlucoseFluidTypeOption)calibrationFluidType;

/**
 Checks the calibration details for the calibration sample location
 
 @return The calibration sample location, as defined in `UHNCGMConstants.h`
 
 */
- (GlucoseSampleLocationOption)calibrationSampleLocation;

/**
 Checks the calibration details for the next calibration date and time
 
 @return The date and time of the next calibration as calculated using the next calibration time offset and session start time. If the date and time cannot be calculated, `nil` is returned.
 
 @discussion The next calibration date and time is only available if the CGM controller knows the session start time.
 
 */
- (NSDate*)nextCalibrationDateTime;

/**
 Checks the calibration details for the next calibration time offset
 
 @return The next calibration time offset. Units is minutes
 
 @discussion The next calibration time offset indicates the time of the next calibration as minutes from the session start time.
 
 */
- (NSNumber*)nextCalibrationTimeOffset;

/**
 Checks the calibration details for the calibration record number
 
 @return The calibration record number
 
 */
- (NSNumber*)calibrationRecordNumber;

/**
 Checks the calibration details for indication that the calibration was successful
 
 @return `YES` if the calibration was successful, otherwise `NO`
 
 @discussion After a CGMCP general response indicating calibration was set successfully, one should check the status of the calibration by a read of the most current calibration data record. If the calibration data was rejected or was out-of-range, there may be the need for a new calibration.
 
 */
- (BOOL)wasCalibrationSuccessful;

/**
 Checks the calibration details for indication if the calibration data was rejected
 
 @return `YES` if the calibration data was rejected, otherwise `NO`
 
 @discussion After a CGMCP general response indicating calibration was set successfully, one should check the status of the calibration by a read of the most current calibration data record. If the calibration data was rejected or was out-of-range, there may be the need for a new calibration.
 
 */
- (BOOL)wasCalibrationDataRejected;

/**
 Checks the calibration details for indication if the calibration data was out-of-range
 
 @return `YES` if the calibration data was out-of-range, otherwise `NO`
 
 @discussion After a CGMCP general response indicating calibration was set successfully, one should check the status of the calibration by a read of the most current calibration data record. If the calibration data was rejected or was out-of-range, there may be the need for a new calibration.
 
 */
- (BOOL)wasCalibrationDataOutOfRange;

/**
 Checks the calibration details for indication if the calibration process is pending
 
 @return `YES` if the calibration process is pending, otherwise `NO`
 
 @discussion After a CGMCP general response indicating calibration was set successfully, one should check the status of the calibration by a read of the most current calibration data record. If the calibration data was rejected or was out-of-range, there may be the need for a new calibration.
 
 */
- (BOOL)isCalibrationProcessPending;



@end
