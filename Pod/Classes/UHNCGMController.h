//
//  UHNCGMController.h
//  CGM_Collector
//
//  Created by Nathaniel Hamming on 2015-01-07.
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
#import "UHNRACPConstants.h"

@protocol UHNCGMControllerDelegate;

/**
 The UHNCGMController provides an interface to a BLE peripheral that implements the Continuous Glucose Monitoring and Device Information services. Other optional services that may be supported include Bond Management, Battery, and Current Time services. Through the inteface and delegate protocol, one should be able to easily make requests of a CGM sensor.
 
 @warning Support for Device Information, Bond Management, Battery, and Current Time services will be included in a future release.
 
 */

@interface UHNCGMController : NSObject

///-----------------------------------------
/// @name Initialization of UHNCGMController
///-----------------------------------------

/**
 UHNCGMController is initialized with a delegate and optional required services. If only the CGM profile mandatory services are required, initialize using `initWithDelegate:`. Mandatory services include CGMS and DIS.

 @param delegate The delegate object that will received discovery, connectivity, and read/write events. This parameter is mandatory.

 @return Instance of a UHNCGMController

*/
- (instancetype)initWithDelegate:(id<UHNCGMControllerDelegate>)delegate;

/**
 UHNCGMController is initialized with a delegate and optional required services.

 @param delegate The delegate object that will received discovery, connectivity, and read/write events. This parameter is mandatory.
 @param serviceUUIDs The required services used to filter eligibility of discovered peripherals. Only peripherals that advertist all the required services will be deemed eligible and reported to the delegate. If `services` is `nil`, only the peripherals discovered with the mandatory CGM profile services will be reported to the delegate. Mandatory services include CGMS and DIS.

 @return Instance of a UHNCGMController 
 
*/
- (instancetype)initWithDelegate:(id<UHNCGMControllerDelegate>)delegate requiredServices:(NSArray*)serviceUUIDs;

///-------------------------
/// @name Connection Methods
///-------------------------
/**
 Determine if a CGM sensor is connected
 
 @return `YES` if a CGM sensor is connected, otherwise `NO`
 
 */
- (BOOL)isConnected;

/**
 Try to reconnect to the previously connected CGM sensor
 */
- (void)tryToReconnect;

/**
 Try to connect to the CGM sensor advertising the device name
 
 @param deviceName The name of the device with which a connection is desired. Device names are reported when the cgm sensors are discovered.
 
 */
- (void)connectToDevice:(NSString*)deviceName;

/** 
 Disconnect from the connected CGM sensor
 */
- (void)disconnect;

///----------------------------------
/// @name CGM Service Characteristics
///----------------------------------
/**
 Request a read of the supported features of the CGM sesnor

 @discussion If `readFeatures` is completed successfully, the delegete will receive the `cgmController:didReadFeatures:` notification
 
 */
- (void)readFeatures;

/**
 Request a read of the CGM sensor session start time
 
 @discussion If `readSessionStartTime` is completed successfully, the delegete will receive the `cgmController:didReadSessionStartTime:` notification

 */
- (void)readSessionStartTime;

/**
 Send the current time to the CGM sensor
 
 @discussion This command is required at least once after a new session is started
 
 @warning When `sendCurrentTime` is completed successfully, it triggers a read of the session start time to see if it was updated after sending the current time. The delegate should wait for the `cgmController:didReadSessionStartTime:` invocation before proceeding
 
 */
- (void)sendCurrentTime;

/**
 Request a read of the CGM sensor session run time 
 
 @discussion If `readSessionRunTime` is completed successfully, the delegete will receive the `cgmController:didReadSessionRunTime:` notification
 
 */
- (void)readSessionRunTime;

/**
 Request a read of the CGM sensor status
 
 @discussion If `readStatus` is completed successfully, the delegete will receive the `cgmController:didReadStatus:` notification
 
 */
- (void)readStatus;

/**
 Request that the measurement characteristic notifcations should be enabled or disabled
 
 @param enable If `YES` indicates that the notification should be enabled. `NO` indicates that the notification should be disabled
 
 @discussion If `enableNotificationMeasurement:` is completed successfully, the delegete will receive the `cgmController:notificationMeasurement:` notification
 
 */
- (void)enableNotificationMeasurement:(BOOL)enable;

/**
 Request that the RACP characteristic indicationss should be enabled or disabled
 
 @param enable If `YES` indicates that the indications should be enabled. `NO` indicates that the indications should be disabled
 
 @discussion If `enableNotificationRACP:` is completed successfully, the delegete will receive the `cgmController:notificationRACP:` notification
 
 @discussion The CGM RACP Characteristic needs to be enabled to conduct RACP procedures. Also some RACP procedures also require CGM Measurement Characteristic notification enabled
 
 */
- (void)enableNotificationRACP:(BOOL)enable;

/**
 Request that the CGMCP characteristic indicationss should be enabled or disabled
 
 @param enable If `YES` indicates that the indications should be enabled. `NO` indicates that the indications should be disabled
 
 @discussion If `enableNotificationCGMCP:` is completed successfully, the delegete will receive the `cgmController:notificationCGMCP:` notification
 
 @discussion The CGMCP Characteristic needs to be enabled to conduct CGMCP procedures.
 
 */
- (void)enableNotificationCGMCP:(BOOL)enable;

///---------------------------------
/// @name Specific Ops Control Point
///---------------------------------

/**
 Request the start of a new CGM session 
 
 @discussion If `startSession` is completed successfully, the delegete will receive the `cgmController:CGMCPOperationSuccessful:` and/or `cgmControllerDidStartSession:` notification (depending on which protocol methods are used). This is left up to the implementation.
 
 @discussion If 'startSession` is unsuccessful, the delegate will receive the `cgmController:CGMCPOperation:failed:` notification
 
 */
- (void)startSession;

/**
 Request the stop of a CGM session
 
 @discussion If `stopSession` is completed successfully, the delegete will receive the `cgmController:CGMCPOperationSuccessful:` and/or `cgmControllerDidStopSession:` notification (depending on which protocol methods are used). This is left up to the implementation.
 
 @discussion If 'stopSession` is unsuccessful, the delegate will receive the `cgmController:CGMCPOperation:failed:` notification
 
 */
- (void)stopSession;

/**
 Request the reset of the device specific alert
 
 @discussion If `resetDeviceSpecificAlert` is completed successfully, the delegete will receive the `cgmController:CGMCPOperationSuccessful:` and/or `cgmControllerDidResetDeviceSpecificAlert:` notification (depending on which protocol methods are used). This is left up to the implementation.
 
 @discussion If 'resetDeviceSpecificAlert` is unsuccessful, the delegate will receive the `cgmController:CGMCPOperation:failed:` notification.
 
 */
- (void)resetDeviceSpecificAlert;

/**
 Request the current communication interval from the CGM sensor
 
 @discussion If `getCommunicationInterval` is completed successfully, the delegete will receive the `cgmController:CGMCPResponseOpCode:didGetValue:` and/or `cgmController:didGetCommunicationInterval:` notification (depending on which protocol methods are used). This is left up to the implementation.
 
 @discussion If 'getCommunicationInterval` is unsuccessful, the delegate will receive the `cgmController:CGMCPOperation:failed:` notification.
 
 */
- (void)getCommunicationInterval;

/**
 Request the most current calibration data records from the CGM sensor
 
 @discussion If `getMostCurrentCalibrationValue` is completed successfully, the delegete will receive the `cgmController:didGetCalibrationDetails:`.
 
 @discussion If 'getMostCurrentCalibrationValue` is unsuccessful, the delegate will receive the `cgmController:CGMCPOperation:failed:` notification.
 
 */
- (void)getMostCurrentCalibrationDataRecord;

/**
 Request the calibration data record from the CGM sensor with specified record number
 
 @param recordNumber The record number of the requested calibration data record
 
 @discussion If `getCalibrationDataRecord:` is completed successfully, the delegete will receive the `cgmController:didGetCalibrationDetails:`.
 
 @discussion If 'getCalibrationDataRecord:` is unsuccessful, the delegate will receive the `cgmController:CGMCPOperation:failed:` notification.
 
 */
- (void)getCalibrationDataRecord:(uint16_t)recordNumber;

/**
 Request the current patient high alert level from the CGM sensor
 
 @discussion If `getPatientAlertLevelHigh` is completed successfully, the delegete will receive the `cgmController:CGMCPResponseOpCode:didGetValue:` and/or `cgmController:didGetPatientAlertLevelHigh:` notification (depending on which protocol methods are used). This is left up to the implementation.
 
 @discussion If 'getPatientAlertLevelHigh` is unsuccessful, the delegate will receive the `cgmController:CGMCPOperation:failed:` notification.
 
 */
- (void)getPatientAlertLevelHigh;

/**
 Request the current patient low alert level from the CGM sensor
 
 @discussion If `getPatientAlertLevelLow` is completed successfully, the delegete will receive the `cgmController:CGMCPResponseOpCode:didGetValue:` and/or `cgmController:didGetPatientAlertLevelLow:` notification (depending on which protocol methods are used). This is left up to the implementation.
 
 @discussion If 'getPatientAlertLevelLow` is unsuccessful, the delegate will receive the `cgmController:CGMCPOperation:failed:` notification.
 
 */
- (void)getPatientAlertLevelLow;

/**
 Request the current hypo alert level from the CGM sensor
 
 @discussion If `getAlertLevelHypo` is completed successfully, the delegete will receive the `cgmController:CGMCPResponseOpCode:didGetValue:` and/or `cgmController:didGetAlertLevelHypo:` notification (depending on which protocol methods are used). This is left up to the implementation.
 
 @discussion If 'getAlertLevelHypo` is unsuccessful, the delegate will receive the `cgmController:CGMCPOperation:failed:` notification.
 
 */
- (void)getAlertLevelHypo;

/**
 Request the current hyper alert level from the CGM sensor
 
 @discussion If `getAlertLevelHyper` is completed successfully, the delegete will receive the `cgmController:CGMCPResponseOpCode:didGetValue:` and/or `cgmController:didGetAlertLevelHyper:` notification (depending on which protocol methods are used). This is left up to the implementation.
 
 @discussion If 'getAlertLevelHyper` is unsuccessful, the delegate will receive the `cgmController:CGMCPOperation:failed:` notification.
 
 */
- (void)getAlertLevelHyper;

/**
 Request the current rate of decrease alert level from the CGM sensor
 
 @discussion If `getAlertLevelRateDecrease` is completed successfully, the delegete will receive the `cgmController:CGMCPResponseOpCode:didGetValue:` and/or `cgmController:didGetAlertLevelRateDecrease:` notification (depending on which protocol methods are used). This is left up to the implementation.
 
 @discussion If 'getAlertLevelRateDecrease` is unsuccessful, the delegate will receive the `cgmController:CGMCPOperation:failed:` notification.
 
 */
- (void)getAlertLevelRateDecrease;

/**
 Request the current rate of increase alert level from the CGM sensor
 
 @discussion If `getAlertLevelRateIncrease` is completed successfully, the delegete will receive the `cgmController:CGMCPResponseOpCode:didGetValue:` and/or `cgmController:didGetAlertLevelRateIncrease:` notification (depending on which protocol methods are used). This is left up to the implementation.
 
 @discussion If 'getAlertLevelRateIncrease` is unsuccessful, the delegate will receive the `cgmController:CGMCPOperation:failed:` notification.
 
 */
- (void)getAlertLevelRateIncrease;

/**
 Request to set the current communication interval to the specified value
 
 @param intervalInMinutes The communication interval to set
 
 @discussion If `setCommunicationInterval:` is completed successfully, the delegete will receive the `cgmController:CGMCPOperationSuccessful:` and/or `cgmControllerDidSetCommunicationInterval:` notification (depending on which protocol methods are used). This is left up to the implementation.
 
 @discussion If 'setCommunicationInterval:` is unsuccessful, the delegate will receive the `cgmController:CGMCPOperation:failed:` notification.
 
 */
- (void)setCommunicationInterval:(uint8_t)intervalInMinutes;

/**
 Request to disable periodic communication with the CGM sensor
 
 @discussion If `disablePeriodicCommunication:` is completed successfully, the delegete will receive the `cgmController:CGMCPOperationSuccessful:` and/or `cgmControllerDidSetCommunicationInterval:` notification (depending on which protocol methods are used). This is left up to the implementation.
 
 @discussion If 'disablePeriodicCommunication:` is unsuccessful, the delegate will receive the `cgmController:CGMCPOperation:failed:` notification.
 
 */
- (void)disablePeriodicCommunication;

/**
 Request to set the fastest communication interval supported
 
 @discussion If `setFastestCommunicationInterval:` is completed successfully, the delegete will receive the `cgmController:CGMCPOperationSuccessful:` and/or `cgmControllerDidSetCommunicationInterval:` notification (depending on which protocol methods are used). This is left up to the implementation.
 
 @discussion If 'setFastestCommunicationInterval:` is unsuccessful, the delegate will receive the `cgmController:CGMCPOperation:failed:` notification.
 
 */
- (void)setFastestCommunicationInterval;

/**
 Request to set a calibration as specified
 
 @param value The glucose concentration value with which to calibration. The short float type is defined in `UHNBLETypes.h`
 @param type The fluid type with which the glucose concentration was measured
 @param location The sample location where the glucose concentration was measured
 @param date The date the glucose concentration was measured
 
 @discussion If `setCalibrationValue:fluidType:sampleLocation:date:` is completed successfully, the delegete will receive the `cgmController:CGMCPOperationSuccessful:` and/or `cgmControllerDidSetCalibration:` notification (depending on which protocol methods are used). This is left up to the implementation.
 
 @discussion If 'setCalibrationValue:fluidType:sampleLocation:date:` is unsuccessful, the delegate will receive the `cgmController:CGMCPOperation:failed:` notification.
 
 */
- (void)setCalibrationValue:(shortFloat)value
                  fluidType:(GlucoseFluidTypeOption)type
             sampleLocation:(GlucoseSampleLocationOption)location
                       date:(NSDate*)date;

/**
 Request to set the patient high alert level
 
 @param value The value of the patient high alert level. The short float type is defined in `UHNBLETypes.h`
 
 @discussion If `setPatientHighLevel:` is completed successfully, the delegete will receive the `cgmController:CGMCPOperationSuccessful:` and/or `cgmControllerDidSetAlertLevelPatientHigh:` notification (depending on which protocol methods are used). This is left up to the implementation.
 
 @discussion If 'setPatientHighLevel:` is unsuccessful, the delegate will receive the `cgmController:CGMCPOperation:failed:` notification.
 
 */
- (void)setPatientHighLevel:(shortFloat)value;

/**
 Request to set the patient low alert level
 
 @param value The value of the patient low alert level. The short float type is defined in `UHNBLETypes.h`
 
 @discussion If `setPatientLowLevel:` is completed successfully, the delegete will receive the `cgmController:CGMCPOperationSuccessful:` and/or `cgmControllerDidSetAlertLevelPatientLow:` notification (depending on which protocol methods are used). This is left up to the implementation.
 
 @discussion If 'setPatientLowLevel:` is unsuccessful, the delegate will receive the `cgmController:CGMCPOperation:failed:` notification.
 
 */
- (void)setPatientLowLevel:(shortFloat)value;

/**
 Request to set the hypo alert level
 
 @param value The value of the hypo alert level. The short float type is defined in `UHNBLETypes.h`
 
 @discussion If `setHypoLevel:` is completed successfully, the delegete will receive the `cgmController:CGMCPOperationSuccessful:` and/or `cgmControllerDidSetAlertLevelHypo:` notification (depending on which protocol methods are used). This is left up to the implementation.
 
 @discussion If 'setHypoLevel:` is unsuccessful, the delegate will receive the `cgmController:CGMCPOperation:failed:` notification.
 
 */
- (void)setHypoLevel:(shortFloat)value;

/**
 Request to set the hyper alert level
 
 @param value The value of the hyper alert level. The short float type is defined in `UHNBLETypes.h`
 
 @discussion If `setHyperLevel:` is completed successfully, the delegete will receive the `cgmController:CGMCPOperationSuccessful:` and/or `cgmControllerDidSetAlertLevelHyper:` notification (depending on which protocol methods are used). This is left up to the implementation.
 
 @discussion If 'setHyperLevel:` is unsuccessful, the delegate will receive the `cgmController:CGMCPOperation:failed:` notification.
 
 */
- (void)setHyperLevel:(shortFloat)value;

/**
 Request to set the rate decrease alert level
 
 @param value The value of the rate decrease alert level. The short float type is defined in `UHNBLETypes.h`
 
 @discussion If `setRateDecreaseLevel:` is completed successfully, the delegete will receive the `cgmController:CGMCPOperationSuccessful:` and/or `cgmControllerDidSetAlertLevelRateDecrease:` notification (depending on which protocol methods are used). This is left up to the implementation.
 
 @discussion If 'setRateDecreaseLevel:` is unsuccessful, the delegate will receive the `cgmController:CGMCPOperation:failed:` notification.
 
 */
- (void)setRateDecreaseLevel:(shortFloat)value;

/**
 Request to set the rate increase alert level
 
 @param value The value of the rate increase alert level. The short float type is defined in `UHNBLETypes.h`
 
 @discussion If `setRateIncreaseLevel:` is completed successfully, the delegete will receive the `cgmController:CGMCPOperationSuccessful:` and/or `cgmControllerDidSetAlertLevelRateIncrease:` notification (depending on which protocol methods are used). This is left up to the implementation.
 
 @discussion If 'setRateIncreaseLevel:` is unsuccessful, the delegate will receive the `cgmController:CGMCPOperation:failed:` notification.
 
 */
- (void)setRateIncreaseLevel:(shortFloat)value;

///----------------------------------
/// @name Record Access Control Point
///----------------------------------
/**
 Request to get all stored records from the CGM sensor
 
 @discussion If `getAllStoredRecords` is completed successfully, the delegete will receive the `cgmController:RACPOperationSuccessful:` and/or `cgmControllerDidGetStoredRecords:` notification (depending on which protocol methods are used). This is left up to the implementation.
 
 @discussion If 'getAllStoredRecords` is unsuccessful, the delegate will receive the `cgmController:RACPOperation:failed:` notification.
 
 */
- (void)getAllStoredRecords;

/**
 Request to get stored records greater than or eqaul to the specified date
 
 @param date The date for which the requested records should be greater than or equal to
 
 @discussion If `getStoredRecordsGreatThanEqualTo:` is completed successfully, the delegete will receive the `cgmController:RACPOperationSuccessful:` and/or `cgmControllerDidGetStoredRecords:` notification (depending on which protocol methods are used). This is left up to the implementation.
 
 @discussion If 'getStoredRecordsGreatThanEqualTo:` is unsuccessful, the delegate will receive the `cgmController:RACPOperation:failed:` notification.
 
 */
- (void)getStoredRecordsGreatThanEqualTo:(NSDate*)date;

/**
 Request to get the number of all the stored records from the CGM sensor
 
 @discussion If `getNumberOfStoredRecords` is completed successfully, the delegete will receive the `cgmController:didGetNumberOfStoredRecords:` notification
 
 @discussion If 'getNumberOfStoredRecords` is unsuccessful, the delegate will receive the `cgmController:RACPOperation:failed:` notification.
 
 */
- (void)getNumberOfStoredRecords;

/**
 Request to get the number of stored records greater than or eqaul to the specified date
 
 @param date The date for which the requested records should be greater than or equal to
 
 @discussion If `getNumberOfStoredRecordsGreatThanEqualTo:` is completed successfully, the delegete will receive the `cgmController:didGetNumberOfStoredRecords:` notification
 
 @discussion If 'getNumberOfStoredRecordsGreatThanEqualTo:` is unsuccessful, the delegate will receive the `cgmController:RACPOperation:failed:` notification.
 
 */
- (void)getNumberOfStoredRecordsGreatThanEqualTo:(NSDate*)date;

///------------------------------
/// @name Bond Management Service
///------------------------------


///---------------------------------
/// @name Device Information Service
///---------------------------------


///----------------------
/// @name Battery Service
///----------------------
//- (void) getBatteryLevel;

///---------------------------
/// @name Current Time Service
///---------------------------

@end

/**
 The UHNCGMControllerDelegate protocol defines the methods that a delegate of a UHNCGMController object must adopt. The optional methods of the protocol allow the delegate to monitor, request, or command the CGM sensor. The required methods of the protocol indicates discovery, connectivity, and reporting current glucose measurements with the CGM sensor.
 
 */
@protocol UHNCGMControllerDelegate <NSObject>

/**
 Notifies the delegate when a CGM sensor has been discovered
 
 @param controller The `UHNCGMController` which with the CGM sensor was discovered
 @param cgmDeviceName The device name of the CGM sensor
 @param serviceUUIDs An array of `NSString` representing the UUID of the services available for the CGM sensor. This array includes all the provided required services and potentially additional services.
 @param RSSI The rssi power of the CGM Sensor

 @discussion This method is invoked when a CGM sensor with the required services is discovered. If required services were provided during instantiation, the only CGM sensors with all of those services will be notified to the delegate. If no required services were provided, all discovered CGM sensor offering the mandatory services will be notified to the delegate.
 
 */
- (void)cgmController:(UHNCGMController*)controller didDiscoverCGMWithName:(NSString*)cgmDeviceName services:(NSArray*)serviceUUIDs RSSI:(NSNumber*)RSSI;

/**
 Notifies the delegate when a CGM sensor did connect
 
 @param controller The `UHNCGMController` that is managing the CGM sensor
 @param cgmDeviceName The device name of the CGM sensor
 
 @discussion This method is invoked when a CGM sensor is connected
 
 */
- (void)cgmController:(UHNCGMController*)controller didConnectToCGMWithName:(NSString*)cgmDeviceName;

/**
 Notifies the delegate when a CGM sensor was disconnected
 
 @param controller The `UHNCGMController` that was managing the CGM sensor
 @param cgmDeviceName The device name of the peripheral
 
 @discussion This method is invoked when a CGM sensor is disconnected
 
 */
- (void)cgmController:(UHNCGMController*)controller didDisconnectFromCGM:(NSString*)cgmDeviceName;

/**
 Notifies the delegate when a CGM sensor has a measurement to report
 
 @param controller The `UHNCGMController` that was managing the CGM sensor
 @param measurementDetails A `NSDictionary` including all the measurement details
 
 @discussion This method is invoked when a CGM sensor has a measurement to report. This measurement may be the most current measurement or a stored measurement as requested by a RACP get stored records procedure. The time information in the measurement details may help determine the age of the measurement.
 
  @discussion Convenience methods for querying the contents of the measurement details dictionary are available with `NSDictionary+CGMExtensions.h`
 
 */
- (void)cgmController:(UHNCGMController*)controller measurementDetails:(NSDictionary*)measurementDetails;

/**
 Notifies the delegate when the CGM sensor session start time characteristic has been read
 
 @param controller The `UHNCGMController` which with the characteristic was read
 @param sessionStartTime A `NSDate` representing the session start time
 
 @discussion This method is invoked when the CGM Session Start Time Characteristic has been read successfully
 
 */
- (void)cgmController:(UHNCGMController*)controller didReadSessionStartTime:(NSDate*)sessionStartTime;

@optional

/**
 Notifies the delegate when the CGM Measurement characteristic notification has been enabled or disabled
 
 @param controller The `UHNCGMController` which with the characteristic was read
 @param enabled If `YES` indicates that the notification was enabled. `NO` indicates that the notification was disabled
 
 @discussion This method is invoked when the CGM Measurement Characteristic notification has enabled or disabled
 
 @discussion The CGM Measurement Characteristic needs to be enabled to received glucose measurements
 
 */
- (void)cgmController:(UHNCGMController*)controller notificationMeasurement:(BOOL)enabled;

/**
 Notifies the delegate when the CGM RACP characteristic indication has been enabled or disabled
 
 @param controller The `UHNCGMController` which with the characteristic was read
 @param enabled If `YES` indicates that the indication was enabled. `NO` indicates that the notifications were disabled
 
 @discussion This method is invoked when the CGM RACP Characteristic indication has enabled or disabled
 
 @discussion The CGM RACP Characteristic needs to be enabled to conduct RACP procedures. Also some RACP procedures also require CGM Measurement Characteristic notification enabled
 
 */
- (void)cgmController:(UHNCGMController*)controller notificationRACP:(BOOL)enabled;

/**
 Notifies the delegate when the CGMCP characteristic indication has been enabled or disabled
 
 @param controller The `UHNCGMController` which with the characteristic was read
 @param enabled If `YES` indicates that the indication was enabled. `NO` indicates that the notifications were disabled
 
 @discussion This method is invoked when the CGMCP Characteristic indication has enabled or disabled
 
 @discussion The CGMCP Characteristic needs to be enabled to conduct CGMCP procedures.
 
 */
- (void)cgmController:(UHNCGMController*)controller notificationCGMCP:(BOOL)enabled;

/**
 Notifies the delegate when the CGM sensor features characteristic has been read
 
 @param controller The `UHNCGMController` which with the characteristic was read
 @param features A `NSDictionary` including all the support features of the CGM sensor
 
 @discussion This method is invoked when the CGM Feature Characteristic has been read successfully
 
 @discussion Convenience methods for querying the contents of the features dictionary are available with `NSDictionary+CGMExtensions.h`
 
 */
- (void)cgmController:(UHNCGMController*)controller didReadFeatures:(NSDictionary*)features;

/**
 Notifies the delegate when the CGM sensor session run time characteristic has been read
 
 @param controller The `UHNCGMController` which with the characteristic was read
 @param sessionRunTime A `NSDate` representing the session run time
 
 @discussion This method is invoked when the CGM Session Run Time Characteristic has been read successfully
 
 */
- (void)cgmController:(UHNCGMController*)controller didReadSessionRunTime:(NSDate*)sessionRunTime;

/**
 Notifies the delegate when the CGM sensor status characteristic has been read
 
 @param controller The `UHNCGMController` which with the characteristic was read
 @param status A `NSDictionary` including the status of the CGM sensor
 
 @discussion This method is invoked when the CGM Status Characteristic has been read successfully
 
 @discussion Convenience methods for querying the contents of the status dictionary are available with `NSDictionary+CGMExtensions.h`
 
 */
- (void)cgmController:(UHNCGMController*)controller didReadStatus:(NSDictionary*)status;

/**
 Notifies the delegate when a CGMCP operation has been completed successfully
 
 @param controller The `UHNCGMController` which with the CGMCP operation was executed
 @param opCode The requested operation that was completed successfully. The CGMCP op codes are defined in `UHNCGMConstants.h`
 
 @discussion This method is invoked when a CGMCP operation has been completed successfully
 
 */
- (void)cgmController:(UHNCGMController*)controller CGMCPOperationSuccessful:(CGMCPOpCode)opCode;

/**
 Notifies the delegate when a CGMCP operation has failed
 
 @param controller The `UHNCGMController` which with the CGMCP operation was executed
 @param opCode The requested operation that failed. The CGMCP op codes are defined in `UHNCGMConstants.h`
 @param responseCode The value of the response code to help determine the cause of the failed CGMCP operation
 
 @discussion This method is invoked when a CGMCP operation has failed
 
 */
- (void)cgmController:(UHNCGMController*)controller CGMCPOperation:(CGMCPOpCode)opCode failed:(CGMCPResponseCode)responseCode;

/**
 Notifies the delegate when a CGMCP get operations has been completed successfully
 
 @param controller The `UHNCGMController` which with the CGMCP operation was executed
 @param responseOpCode The Response Op Code related to the operation. The CGMCP op codes are defined in `UHNCGMConstants.h`
 @param value A `NSNumber` representing the value of the CGMCP response
 
 @discussion This method is invoked when a get CGMCP operation has been completed successfully. This is used for all CGMCP get operations, except the get calibration operation
 
 */
- (void)cgmController:(UHNCGMController*)controller CGMCPResponseOpCode:(CGMCPOpCode)responseOpCode didGetValue:(NSNumber*)value;

/**
 Notifies the delegate when the CGM sensor session has been started
 
 @param controller The `UHNCGMController` which with the CGMCP operation was executed
 
 @discussion This method is invoked when the CGMCP start session operation has been completed successfully
 
 */
- (void)cgmControllerDidStartSession:(UHNCGMController*)controller;

/**
 Notifies the delegate when the CGM sensor session has been stopped
 
 @param controller The `UHNCGMController` which with the CGMCP operation was executed
 
 @discussion This method is invoked when the CGMCP stop session operation has been completed successfully
 
 */
- (void)cgmControllerDidStopSession:(UHNCGMController*)controller;

/**
 Notifies the delegate when the CGM sensor session has been stopped
 
 @param controller The `UHNCGMController` which with the CGMCP operation was executed
 
 @discussion This method is invoked when the CGMCP stop session operation has been completed successfully
 
 */
- (void)cgmControllerDidResetDeviceSpecificAlert:(UHNCGMController*)controller;

/**
 Notifies the delegate when the CGM sensor communication interval has been successfully updated
 
 @param controller The `UHNCGMController` which with the CGMCP operation was executed
 
 @discussion This method is invoked when the CGMCP set communication interval operation has been completed successfully
 
 */
- (void)cgmControllerDidSetCommunicationInterval:(UHNCGMController*)controller;

/**
 Notifies the delegate when the CGM sensor calibration was been set successfully
 
 @param controller The `UHNCGMController` which with the CGMCP operation was executed
 
 @discussion This method is invoked when the CGMCP set calibration operation has been completed successfully
 
 @discussion After a CGMCP response indicating calibration was set successfully, one should check the status of the calibration by a read of the most current calibration data record. If the calibration data was rejected or was out-of-range, there may be the need for a new calibration.
 
 */
- (void)cgmControllerDidSetCalibration:(UHNCGMController*)controller;

/**
 Notifies the delegate when the patient high alert level was been set successfully
 
 @param controller The `UHNCGMController` which with the CGMCP operation was executed
 
 @discussion This method is invoked when the CGMCP set patient high alert level operation has been completed successfully
 
 */
- (void)cgmControllerDidSetAlertLevelPatientHigh:(UHNCGMController*)controller;

/**
 Notifies the delegate when the patient low alert level was been set successfully
 
 @param controller The `UHNCGMController` which with the CGMCP operation was executed
 
 @discussion This method is invoked when the CGMCP set patient low alert level operation has been completed successfully
 
 */
- (void)cgmControllerDidSetAlertLevelPatientLow:(UHNCGMController*)controller;

/**
 Notifies the delegate when the hypo alert level was been set successfully
 
 @param controller The `UHNCGMController` which with the CGMCP operation was executed
 
 @discussion This method is invoked when the CGMCP set hypo alert level operation has been completed successfully
 
 */
- (void)cgmControllerDidSetAlertLevelHypo:(UHNCGMController*)controller;

/**
 Notifies the delegate when the hyper alert level was been set successfully
 
 @param controller The `UHNCGMController` which with the CGMCP operation was executed
 
 @discussion This method is invoked when the CGMCP set hyper alert level operation has been completed successfully
 
 */
- (void)cgmControllerDidSetAlertLevelHyper:(UHNCGMController*)controller;

/**
 Notifies the delegate when the rate decrease alert level was been set successfully
 
 @param controller The `UHNCGMController` which with the CGMCP operation was executed
 
 @discussion This method is invoked when the CGMCP set rate decrease alert level operation has been completed successfully
 
 */
- (void)cgmControllerDidSetAlertLevelRateDecrease:(UHNCGMController*)controller;

/**
 Notifies the delegate when the rate increase alert level was been set successfully
 
 @param controller The `UHNCGMController` which with the CGMCP operation was executed
 
 @discussion This method is invoked when the CGMCP set rate increase alert level operation has been completed successfully
 
 */
- (void)cgmControllerDidSetAlertLevelRateIncrease:(UHNCGMController*)controller;

/**
 Notifies the delegate of the current communication interval of the CGM sensor
 
 @param controller The `UHNCGMController` which with the CGMCP operation was executed
 @param commInterval The current communication interval
 
 @discussion This method is invoked when the CGMCP get communication interval operation has been completed successfully
 
 */
- (void)cgmController:(UHNCGMController*)controller didGetCommunicationInterval:(NSNumber*)commInterval;

/**
 Notifies the delegate when the get calibration data record CGMCP operation has been completed successfully
 
 @param controller The `UHNCGMController` which with the CGMCP operation was executed
 @param calibrationDetails A `NSDictionary` including the calibration data record
 
 @discussion This method is invoked when the get calibration data record CGMCP operation has been read successfully
 
 @discussion Convenience methods for querying the contents of the calibration data record dictionary are available with `NSDictionary+CGMExtensions.h`
 
 */
- (void)cgmController:(UHNCGMController*)controller didGetCalibrationDetails:(NSDictionary*)calibrationDetails;

/**
 Notifies the delegate of the current patient high alert level of the CGM sensor
 
 @param controller The `UHNCGMController` which with the CGMCP operation was executed
 @param highLevel The current patient high alert level
 
 @discussion This method is invoked when the CGMCP get patient high alert level operation has been completed successfully
 
 */
- (void)cgmController:(UHNCGMController*)controller didGetPatientAlertLevelHigh:(NSNumber*)highLevel;

/**
 Notifies the delegate of the current patient low alert level of the CGM sensor
 
 @param controller The `UHNCGMController` which with the CGMCP operation was executed
 @param lowLevel The current patient low alert level
 
 @discussion This method is invoked when the CGMCP get patient low alert level operation has been completed successfully
 
 */
- (void)cgmController:(UHNCGMController*)controller didGetPatientAlertLevelLow:(NSNumber*)lowLevel;

/**
 Notifies the delegate of the current hypo alert level of the CGM sensor
 
 @param controller The `UHNCGMController` which with the CGMCP operation was executed
 @param hypoLevel The current hypo alert level
 
 @discussion This method is invoked when the CGMCP get hypo alert level operation has been completed successfully
 
 */
- (void)cgmController:(UHNCGMController*)controller didGetAlertLevelHypo:(NSNumber*)hypoLevel;

/**
 Notifies the delegate of the current hyper alert level of the CGM sensor
 
 @param controller The `UHNCGMController` which with the CGMCP operation was executed
 @param hyperLevel The current hyper alert level
 
 @discussion This method is invoked when the CGMCP get hyper alert level operation has been completed successfully
 
 */
- (void)cgmController:(UHNCGMController*)controller didGetAlertLevelHyper:(NSNumber*)hyperLevel;

/**
 Notifies the delegate of the current rate of decrease alert level of the CGM sensor
 
 @param controller The `UHNCGMController` which with the CGMCP operation was executed
 @param decreaseLevel The current rate of decrease alert level
 
 @discussion This method is invoked when the CGMCP get rate of decrease alert level operation has been completed successfully
 
 */
- (void)cgmController:(UHNCGMController*)controller didGetAlertLevelRateDecrease:(NSNumber*)decreaseLevel;

/**
 Notifies the delegate of the current rate of increase alert level of the CGM sensor
 
 @param controller The `UHNCGMController` which with the CGMCP operation was executed
 @param increaseLevel The current rate of increase alert level
 
 @discussion This method is invoked when the CGMCP get rate of increase alert level operation has been completed successfully
 
 */
- (void)cgmController:(UHNCGMController*)controller didGetAlertLevelRateIncrease:(NSNumber*)increaseLevel;

/**
 Notifies the delegate when a RACP procedure has been completed successfully
 
 @param controller The `UHNCGMController` which with the RACP procedure was executed
 @param opCode The requested procedure that was completed successfully. The RACP op codes are defined in `UHNRACPConstants.h` in the `UHNBLEController` pod
 
 @discussion This method is invoked when a RACP procedure has been completed successfully
 
 */
- (void)cgmController:(UHNCGMController*)controller RACPOperationSuccessful:(RACPOpCode)opCode;

/**
 Notifies the delegate when a RAACP procedure has failed
 
 @param controller The `UHNCGMController` which with the RACP procedure was executed
 @param opCode The requested procedure that failed. The RACP op codes are defined in `UHNRACPConstants.h` in the `UHNBLEController` pod
 @param responseCode The value of the response code to help determine the cause of the failed RACP procedure
 
 @discussion This method is invoked when a RACP procedure has failed
 
 */
- (void)cgmController:(UHNCGMController*)controller RACPOperation:(RACPOpCode)opCode failed:(RACPResponseCode)responseCode;

/**
 Notifies the delegate that the requested get of stored records has been completed successfully
 
 @param controller The `UHNCGMController` which with the RACP procedure was executed
 
 @discussion This method is invoked when any of the RACP get stored records procedures has been completed successfully
 
 */
- (void)cgmControllerDidGetStoredRecords:(UHNCGMController*)controller;

/**
 Notifies the delegate that the requested get number of stored records has been completed successfully
 
 @param controller The `UHNCGMController` which with the RACP procedure was executed
 @param numOfRecords The number of stored records
 
 @discussion This method is invoked when any of the RACP get number of stored records procedures has been completed successfully
 
 */
- (void)cgmController:(UHNCGMController*)controller didGetNumberOfStoredRecords:(NSNumber*)numOfRecords;

@end

