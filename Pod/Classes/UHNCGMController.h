//
//  UHNCGMController.h
//  CGM_Collector
//
//  Created by Nathaniel Hamming on 2015-01-07.
//  Copyright (c) 2015 eHealth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UHNCGMConstants.h"
#import "UHNRACPConstants.h"
#import "UHNBLETypes.h"

@protocol UHNCGMControllerDelegate;

@interface UHNCGMController : NSObject

///-----------------------------------------
/// @name Initialization of UHNCGMController
///-----------------------------------------
- (instancetype)initWithDelegate:(id<UHNCGMControllerDelegate>)delegate;
- (instancetype)initWithDelegate:(id<UHNCGMControllerDelegate>)delegate requiredServices:(NSArray*)serviceUUIDs;

///----------------------------------
/// @name Connection Methods
///----------------------------------
- (BOOL)isConnected;
- (void)tryToReconnect;
- (void)connectToDevice:(NSString*)deviceName;
- (void)disconnect;

///----------------------------------
/// @name CGM Service Characteristics
///----------------------------------
- (void)readFeatures;
- (void)readSessionStartTime;
- (void)setCurrentTime;
- (void)readSessionRunTime;
- (void)readStatus;
- (void)enableNotificationMeasurement:(BOOL)enable;
- (void)enableNotificationRACP:(BOOL)enable;
- (void)enableNotificationCGMCP:(BOOL)enable;

///---------------------------------
/// @name Specific Ops Control Point
///---------------------------------
- (void)startSession;
- (void)stopSession;
- (void)resetDeviceSpecificAlert;

- (void)getCommunicationInterval;
- (void)getLastCalibrationValue;
- (void)getCalibrationValue: (uint16_t)recordNumber;
- (void)getPatientHighLevel;
- (void)getPatientLowLevel;
- (void)getHypoLevel;
- (void)getHyperLevel;
- (void)getRateDecreaseLevel;
- (void)getRateIncreaseLevel;

- (void)setCommunicationInterval:(uint8_t)intervalInMinutes;
- (void)disableCommunication;
- (void)setFastestCommunicationInterval;
- (void)setCalibrationValue:(shortFloat)value
                  fluidType:(CGMTypeOption)type
             sampleLocation:(CGMLocationOption)location
                       date:(NSDate*)date;
- (void)setPatientHighLevel:(shortFloat)value;
- (void)setPatientLowLevel:(shortFloat)value;
- (void)setHypoLevel:(shortFloat)value;
- (void)setHyperLevel:(shortFloat)value;
- (void)setRateDecreaseLevel:(shortFloat)value;
- (void)setRateIncreaseLevel:(shortFloat)value;

///----------------------------------
/// @name Record Access Control Point
///----------------------------------
- (void)getAllStoredRecords;

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

@end

@protocol UHNCGMControllerDelegate <NSObject>
- (void)cgmController:(UHNCGMController*)controller didDisconnectFromCGM:(NSString*)cgmDeviceName;
- (void)cgmController:(UHNCGMController*)controller didDiscoverCGMWithName:(NSString*)cgmDeviceName RSSI:(NSNumber*)RSSI;
- (void)cgmController:(UHNCGMController*)controller didConnectToCGMWithName:(NSString*)cgmDeviceName;
- (void)cgmController:(UHNCGMController*)controller currentMeasurementDetails:(NSDictionary*)measurementDetails;
- (void)cgmController:(UHNCGMController*)controller sessionStartTime:(NSDate*)sessionStartTime;

@optional
- (void)cgmController:(UHNCGMController*)controller notificationMeasurement:(BOOL)enabled;
- (void)cgmController:(UHNCGMController*)controller notificationRACP:(BOOL)enabled;
- (void)cgmController:(UHNCGMController*)controller notificationCGMCP:(BOOL)enabled;
- (void)cgmController:(UHNCGMController*)controller featuresDetails:(NSDictionary*)features;
- (void)cgmController:(UHNCGMController*)controller status:(NSDictionary*)status;
- (void)cgmController:(UHNCGMController*)controller sessionRunTime:(NSDate*)sessionRunTime;
- (void)cgmController:(UHNCGMController*)controller CGMCPOperation:(CGMCPOpCode)opCode failed:(CGMCPResponseCode)responseCode;
// instead include the specific details, not op code
// - just success and failed
- (void)cgmController:(UHNCGMController*)controller CGMCPOperationSuccessful:(CGMCPOpCode)opCode;
- (void)cgmController:(UHNCGMController*)controller didGetValue:(NSNumber*)value CGMCPResponseOpCode:(CGMCPOpCode)responseOpCode;
- (void)cgmController:(UHNCGMController*)controller didGetCalibrationDetails:(NSDictionary*)calibrationDetails;
- (void)cgmController:(UHNCGMController*)controller RACPOperation:(RACPOpCode)opCode failed:(RACPResponseCode)responseCode;
- (void)cgmController:(UHNCGMController*)controller RACPOperationSuccessful:(RACPOpCode)opCode;
- (void)cgmController:(UHNCGMController*)controller didGetNumberOfStoredRecords:(NSNumber*)numOfRecords;
@end

