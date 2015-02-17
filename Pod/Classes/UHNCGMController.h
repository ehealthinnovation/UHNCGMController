//
//  UHNCGMController.h
//  CGM_Collector
//
//  Created by Nathaniel Hamming on 2015-01-07.
//  Copyright (c) 2015 eHealth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UHNCGMConstants.h"
#import "RACPConstants.h"

@class UHNCGMController;

@protocol UHNCGMControllerDelegate <NSObject>
- (void) cgmController: (UHNCGMController*)controller didDisconnectFromCGM: (NSString*)cgmDeviceName;
- (void) cgmController: (UHNCGMController*)controller didDiscoverCGMWithName: (NSString*)cgmDeviceName RSSI: (NSNumber*)RSSI;
- (void) cgmController: (UHNCGMController*)controller didConnectToCGMWithName: (NSString*)cgmDeviceName;
- (void) cgmController: (UHNCGMController*)controller currentMeasurementDetails: (NSDictionary*)measurementDetails;
- (void) cgmController: (UHNCGMController*)controller sessionStartTime: (NSDate*)sessionStartTime;

@optional
- (void) cgmController: (UHNCGMController*)controller notificationMeasurement: (BOOL)enabled;
- (void) cgmController: (UHNCGMController*)controller notificationRACP: (BOOL)enabled;
- (void) cgmController: (UHNCGMController*)controller notificationCGMCP: (BOOL)enabled;
- (void) cgmController: (UHNCGMController*)controller featuresDetails: (NSDictionary*)features;
- (void) cgmController: (UHNCGMController*)controller status: (NSDictionary*)status;
- (void) cgmController: (UHNCGMController*)controller sessionRunTime: (NSDate*)sessionRunTime;
- (void) cgmController: (UHNCGMController*)controller CGMCPOperation: (CGMCPOpCode)opCode failed: (CGMCPResponseCode)responseCode;
// instead include the specific details, not op code
// - just success and failed
- (void) cgmController: (UHNCGMController*)controller CGMCPOperationSuccessful: (CGMCPOpCode)opCode;
- (void) cgmController: (UHNCGMController*)controller didGetValue: (NSNumber*)value CGMCPResponseOpCode: (CGMCPOpCode)responseOpCode;
- (void) cgmController: (UHNCGMController*)controller RACPOperation: (RACPOpCode)opCode failed: (RACPResponseCode)responseCode;
- (void) cgmController: (UHNCGMController*)controller RACPOperationSuccessful: (RACPOpCode)opCode;
- (void) cgmController: (UHNCGMController*)controller didGetNumberOfStoredRecords: (NSNumber*)numOfRecords;
@end

@interface UHNCGMController : NSObject

- (instancetype) initWithDelegate:(id<UHNCGMControllerDelegate>)delegate;
- (instancetype) initWithDelegate:(id<UHNCGMControllerDelegate>)delegate requiredServices:(NSArray*)serviceUUIDs;
- (BOOL) isConnected;
- (void) tryToReconnect;
- (void) connectToDevice: (NSString*)deviceName;
- (void) disconnect;

// CGM Service
// characteristics
- (void) readFeatures;
- (void) readSessionStartTime;
- (void) setCurrentTime;
- (void) readSessionRunTime;
- (void) readStatus;
- (void) enableNotificationMeasurement: (BOOL)enable;
- (void) enableNotificationRACP: (BOOL)enable;
- (void) enableNotificationCGMCP: (BOOL)enable;

// Specific Ops Control Point
- (void) startSession;
- (void) stopSession;
- (void) resetDeviceSpecificAlert;

- (void) getCommunicationInterval;
- (void) getLastCalibrationValue;
- (void) getCalibrationValue: (uint16_t)recordNumber;
- (void) getPatientHighLevel;
- (void) getPatientLowLevel;
- (void) getHypoLevel;
- (void) getHyperLevel;
- (void) getRateDecreaseLevel;
- (void) getRateIncreaseLevel;

- (void) setCommunicationInterval: (uint8_t)intervalInMinutes;
- (void) disableCommunication; 
- (void) setFastestCommunicationInterval;
- (void) setCalibrationValue: (shortFloat)value
                   fluidType: (CGMTypeOption)type
              sampleLocation: (CGMLocationOption)location
                        date: (NSDate*)date;
- (void) setPatientHighLevel: (shortFloat)value;
- (void) setPatientLowLevel: (shortFloat)value;
- (void) setHypoLevel: (shortFloat)value;
- (void) setHyperLevel: (shortFloat)value;
- (void) setRateDecreaseLevel: (shortFloat)value;
- (void) setRateIncreaseLevel: (shortFloat)value;

// Record Access Control Point
- (void) getAllStoredRecords;

// Bond Management Service

// Device Information Service

// Battery Service
//- (void) getBatteryLevel;



@end
