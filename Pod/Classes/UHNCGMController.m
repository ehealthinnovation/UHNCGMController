//
//  UHNCGMController.m
//  CGM_Collector
//
//  Created by Nathaniel Hamming on 2015-01-07.
//  Copyright (c) 2015 eHealth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UHNCGMController.h"
#import "UHNBLEController.h"
#import "UHNDebug.h"
#import "NSData+CGMCommands.h"
#import "NSData+CGMParser.h"
#import "UHNRecordAccessControlPoint.h"

@interface UHNCGMController() <UHNBLEControllerDelegate>
@property(nonatomic,strong) UHNBLEController *bleController;
@property(nonatomic,strong) NSUUID *deviceIdentifier;
@property(nonatomic,strong) NSDate *sessionStartTime;
@property(nonatomic,strong) NSString *cgmDeviceName;
@property(nonatomic,assign) BOOL shouldBlockReconnect;
@property(nonatomic,assign) BOOL crcPresent;
@property(nonatomic,weak) id <UHNCGMControllerDelegate> delegate;
@end

@implementation UHNCGMController

#pragma mark - Initialization of a UHNCGMController

- (id)init;
{
    [NSException raise:NSInvalidArgumentException
                format:@"%s: Use %@ instead", __PRETTY_FUNCTION__, NSStringFromSelector(@selector(initWithDelegate:))];
    return nil;
}

- (id)initWithDelegate:(id<UHNCGMControllerDelegate>)delegate;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    return [self initWithDelegate:delegate requiredServices:@[kCGMServiceUUID, kDEVICE_INFO_SERVICE_UUID]];
}

- (instancetype)initWithDelegate:(id<UHNCGMControllerDelegate>)delegate requiredServices:(NSArray*)serviceUUIDs;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    
    // add the mandatory services, if they do not already exist
    BOOL didFindCGMS = NO;
    BOOL didFindDIS = NO;
    NSMutableArray *requiredServices = [serviceUUIDs mutableCopy];
    for (NSString *serviceUUID in serviceUUIDs) {
        if ([serviceUUID isEqualToString:kCGMServiceUUID]) {
            didFindCGMS = YES;
        } else if ([serviceUUID isEqualToString:kDEVICE_INFO_SERVICE_UUID]) {
            didFindDIS = YES;
        }
    }
    if (didFindCGMS == NO) {
        [requiredServices addObject:kCGMServiceUUID];
    }
    if (didFindDIS == NO) {
        [requiredServices addObject:kDEVICE_INFO_SERVICE_UUID];
    }
    
    if ((self = [super init])) {
        self.delegate = delegate;
        self.bleController = [[UHNBLEController alloc] initWithDelegate:self
                                                       requiredServices:requiredServices];
        self.shouldBlockReconnect = YES;
        self.crcPresent = NO;
    }
    return self;
}

#pragma mark - Connection Methods

- (BOOL)isConnected;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    return self.bleController.isPeripheralConnected;
}

- (void)tryToReconnect;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    if (self.deviceIdentifier)
    {
        DLog(@"trying to reconnect");
        [self.bleController reconnectToPeripheralWithUUID:self.deviceIdentifier];
    } else {
        // note: BTLE will automatically start scanning when manager BT is available.
        [self.bleController startConnection];
    }
}

- (void)connectToDevice:(NSString*)deviceName;
{
    [self.bleController connectToDiscoveredPeripheral:deviceName];
}

- (void)disconnect;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    if ([self.bleController isPeripheralConnected]) {
        DLog(@"going to cancel BTLE connection");
        self.shouldBlockReconnect = YES;
        [self.bleController cancelConnection];
    }
}

#pragma mark - CGM Basic Characteristic Methods

- (void)readFeatures;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    [self.bleController readValueFromCharacteristicUUID:kCGMCharacteristicUUIDFeature withServiceUUID:kCGMServiceUUID];
}

- (void)readSessionStartTime;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    [self.bleController readValueFromCharacteristicUUID:kCGMCharacteristicUUIDSessionStartTime withServiceUUID:kCGMServiceUUID];
}

- (void)sendCurrentTime;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    NSData *currentTimeValue = [NSData cgmCurrentTimeValue];
    [self.bleController writeValue: currentTimeValue toCharacteristicUUID:kCGMCharacteristicUUIDSessionStartTime withServiceUUID:kCGMServiceUUID];
}

- (void)readSessionRunTime;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    [self.bleController readValueFromCharacteristicUUID:kCGMCharacteristicUUIDSessionRunTime withServiceUUID:kCGMServiceUUID];
}

- (void)readStatus;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    [self.bleController readValueFromCharacteristicUUID:kCGMCharacteristicUUIDStatus withServiceUUID:kCGMServiceUUID];
}

- (void)enableNotificationMeasurement:(BOOL)enable;
{
    [self.bleController setNotificationState:enable forCharacteristicUUID:kCGMCharacteristicUUIDMeasurement withServiceUUID:kCGMServiceUUID];
}

- (void)enableNotificationRACP:(BOOL)enable;
{
    [self.bleController setNotificationState:enable forCharacteristicUUID:kCGMCharacteristicUUIDRecordAccessControlPoint withServiceUUID:kCGMServiceUUID];
}

- (void)enableNotificationCGMCP:(BOOL)enable;
{
    [self.bleController setNotificationState:enable forCharacteristicUUID:kCGMCharacteristicUUIDSpecificOpsControlPoint withServiceUUID:kCGMServiceUUID];
}

#pragma mark - Specific Ops Control Point Methods

- (void)sendCGMCPCommand:(NSData*)command
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    if ([self isConnected]) {
        [self.bleController writeValue:command toCharacteristicUUID:kCGMCharacteristicUUIDSpecificOpsControlPoint withServiceUUID:kCGMServiceUUID];
    } else {
        [self displayMessage:@"CGM not connected."];
    }
}

- (void)sendCGMCPOpCode:(uint8_t)opCode;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    NSData *command = [NSData dataWithBytes:&opCode length:sizeof(uint8_t)];
    [self sendCGMCPCommand:command];
}

- (void)sendCGMCPOpCode:(uint8_t)opCode
            operandData:(NSData*)operand
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    NSMutableData *command = [NSMutableData dataWithBytes:&opCode length:sizeof(uint8_t)];
    [command appendData:operand];
    [self sendCGMCPCommand:command];
}

- (void)startSession;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    [self sendCGMCPOpCode:CGMCPOpCodeSessionStart];
}

- (void)stopSession;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    [self sendCGMCPOpCode:CGMCPOpCodeSessionStop];
}

- (void)resetDeviceSpecificAlert;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    [self sendCGMCPOpCode:CGMCPOpCodeAlertDeviceSpecificReset];
}

- (void)getCommunicationInterval;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    [self sendCGMCPOpCode:CGMCPOpCodeCommIntervalGet];
}

- (void)getMostCurrentCalibrationDataRecord;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    // write 0xFFFF to calibration get operation
    [self getCalibrationDataRecord:0xFFFF];
}

- (void)getCalibrationDataRecord:(uint16_t)recordNumber;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    NSData *operand = [NSData dataWithBytes:&recordNumber length:sizeof(uint16_t)];
    [self sendCGMCPOpCode:CGMCPOpCodeCalibrationValueGet operandData:operand];
}
- (void)getPatientAlertLevelHigh;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    [self sendCGMCPOpCode:CGMCPOpCodeAlertLevelPatientHighGet];
}

- (void)getPatientAlertLevelLow;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    [self sendCGMCPOpCode:CGMCPOpCodeAlertLevelPatientLowGet];
}

- (void)getAlertLevelHypo;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    [self sendCGMCPOpCode:CGMCPOpCodeAlertLevelHypoGet];
}

- (void)getAlertLevelHyper;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    [self sendCGMCPOpCode:CGMCPOpCodeAlertLevelHyperGet];
}

- (void)getAlertLevelRateDecrease;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    [self sendCGMCPOpCode:CGMCPOpCodeAlertLevelRateDecreaseGet];
}

- (void)getAlertLevelRateIncrease;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    [self sendCGMCPOpCode: CGMCPOpCodeAlertLevelRateIncreaseGet];
}

- (void)setCommunicationInterval:(uint8_t)intervalInMinutes;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    NSData *operand = [NSData dataWithBytes:&intervalInMinutes length:sizeof(uint8_t)];
    [self sendCGMCPOpCode:CGMCPOpCodeCalibrationValueGet operandData:operand];
}

- (void)disablePeriodicCommunication;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    // set communication interval to 0x00
    [self setCommunicationInterval:0x00];
}

- (void)setFastestCommunicationInterval;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    // set communication interval to 0xFF
    [self setCommunicationInterval:0xFF];
}

- (void)setCalibrationValue:(shortFloat)value
                  fluidType:(GlucoseFluidTypeOption)type
             sampleLocation:(GlucoseSampleLocationOption)location
                       date:(NSDate*)date;
{
    NSMutableData *operand = [NSMutableData dataWithBytes:&value length:sizeof(shortFloat)];
    uint16_t timeOffset = [self.sessionStartTime timeIntervalSinceDate:date] / kSecondsInMinute;
    [operand appendBytes:&timeOffset length:sizeof(uint16_t)];
    NSData *typeLocation = [NSData joinFluidType:type sampleLocation:location];
    [operand appendData:typeLocation];
    char ignoredBytes[] = {0x00, 0x00, 0x00, 0x00, 0x00};
    [operand appendBytes:ignoredBytes length:sizeof(ignoredBytes)];
    NSLog(@"operand is %@", operand);
    [self sendCGMCPOpCode:CGMCPOpCodeCalibrationValueSet operandData:operand];
}

- (void)setPatientHighLevel:(shortFloat)value;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    NSData *operand = [NSData dataWithBytes:&value length:sizeof(shortFloat)];
    [self sendCGMCPOpCode:CGMCPOpCodeAlertLevelPatientHighSet operandData:operand];
}

- (void)setPatientLowLevel:(shortFloat)value;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    NSData *operand = [NSData dataWithBytes:&value length:sizeof(shortFloat)];
    [self sendCGMCPOpCode:CGMCPOpCodeAlertLevelPatientLowSet operandData:operand];
}

- (void)setHypoLevel:(shortFloat)value;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    NSData *operand = [NSData dataWithBytes:&value length:sizeof(shortFloat)];
    [self sendCGMCPOpCode:CGMCPOpCodeAlertLevelHypoSet operandData:operand];
}

- (void)setHyperLevel:(shortFloat)value;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    NSData *operand = [NSData dataWithBytes:&value length:sizeof(shortFloat)];
    [self sendCGMCPOpCode:CGMCPOpCodeAlertLevelHyperSet operandData:operand];
}

- (void)setRateDecreaseLevel:(shortFloat)value;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    NSData *operand = [NSData dataWithBytes: &value length: sizeof(shortFloat)];
    [self sendCGMCPOpCode:CGMCPOpCodeAlertLevelRateDecreaseSet operandData:operand];
}

- (void)setRateIncreaseLevel: (shortFloat)value;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    NSData *operand = [NSData dataWithBytes: &value length: sizeof(shortFloat)];
    [self sendCGMCPOpCode:CGMCPOpCodeAlertLevelRateIncreaseSet operandData:operand];
}

#pragma mark - Record Access Control Point

- (void)sendRACPCommand:(NSData*)command
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    if ([self isConnected]) {
        [self.bleController writeValue:command toCharacteristicUUID:kCGMCharacteristicUUIDRecordAccessControlPoint withServiceUUID:kCGMServiceUUID];
    } else {
        [self displayMessage:@"CGM not connected."];
    }
}

- (void)getAllStoredRecords;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    NSData *command = [NSData reportAllStoredRecords];
    [self sendRACPCommand:command];
}

- (void)getStoredRecordsGreatThanEqualTo:(NSDate*)date;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    NSData *command = [NSData reportStoredRecordsGreaterThanOrEqualToTimeOffset:[self timeOffsetFromSessionStartTime:date]];
    [self sendRACPCommand:command];
}

- (void)getNumberOfStoredRecords;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    NSData *command = [NSData reportNumberOfAllStoredRecords];
    [self sendRACPCommand:command];
}

- (void)getNumberOfStoredRecordsGreatThanEqualTo:(NSDate*)date;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    NSData *command = [NSData reportNumberOfStoredRecordsGreaterThanOrEqualToTimeOffset:[self timeOffsetFromSessionStartTime:date]];
    [self sendRACPCommand:command];
}

- (NSInteger)timeOffsetFromSessionStartTime:(NSDate*)date
{
    if (self.sessionStartTime) {
        // divide by integer to convert from float to int
        return [date timeIntervalSinceDate:self.sessionStartTime] / 1;
    } else {
        [NSException raise:NSInvalidArgumentException
                    format:@"%s: Need to know the session start time to calculate a time offet", __PRETTY_FUNCTION__];
        return -1;
    }
}

#pragma mark - Battery Service Methods

//- (void) getBatteryLevel;
//{
//    DLog(@"%s", __PRETTY_FUNCTION__);
//    if ([self.bleController serviceForUUIDString: kBATT_SERVICE_UUID])
//    {
//        [self.bleController readValueFromCharacteristicUUID: kBATT_CHARACTERISTIC_LEVEL_UUID withServiceID: kBATT_SERVICE_UUID];
//    }
//}


#pragma mark - Private Methods

- (void)displayMessage:(NSString*)message {
    DLog(@"%s", __PRETTY_FUNCTION__);
#ifdef DEBUG
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Data Transmission Error",@"Error title")
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK",nil)
                                          otherButtonTitles:nil];
    [alert show];
#endif
}

#pragma mark - BTLE Controller Delegate Methods

- (void)bleController:(UHNBLEController*)controller didDiscoverPeripheral:(NSString*)deviceName services:(NSArray*)serviceUUIDs RSSI:(NSNumber*)RSSI;
{
    DLog(@"Did discover peripheral %@ (%@)", deviceName, RSSI);
    if ([self.delegate respondsToSelector: @selector(cgmController:didDiscoverCGMWithName:services:RSSI:)]) {
        [self.delegate cgmController:self didDiscoverCGMWithName:deviceName services:serviceUUIDs RSSI:RSSI];
    }
}

- (void)bleController:(UHNBLEController*)controller didDiscoverServices:(NSArray*)serviceUUIDs
{
    DLog(@"Did discover services %@", serviceUUIDs);
}

- (void)bleController:(UHNBLEController*)controller didConnectWithPeripheral:(NSString*)deviceName withServices:(NSArray*)services andUUID:(NSUUID*)uuid
{
    self.deviceIdentifier = uuid;
    self.cgmDeviceName = deviceName;
    self.shouldBlockReconnect = NO;
    DLog(@"Did connect with %@ with services: %@ and UUID: %@", deviceName, services, uuid.UUIDString);
}

- (void)bleController:(UHNBLEController*)controller didDisconnectFromPeripheral:(NSString*)deviceName
{
    DLog(@"Did cancel connection or disconnect with %@", deviceName);

    // try to reconnect
    if (!self.shouldBlockReconnect)
    {
        [self tryToReconnect];
    }
    self.shouldBlockReconnect = NO;
    
    if ([self.delegate respondsToSelector:@selector(cgmController:didDisconnectFromCGM:)])
    {
        [self.delegate cgmController:self didDisconnectFromCGM:self.cgmDeviceName];
    }
}

- (void)bleController:(UHNBLEController*)controller failedToConnectWithPeripheral:(NSString*)deviceName
{
    DLog(@"Failed to connect with %@", deviceName);
}

- (void)bleController:(UHNBLEController*)controller didDiscoverCharacteristics:(NSArray*)characteristicUUIDs forService:(NSString*)serviceUUID
{
    DLog(@"Characteristics %@ discovered for service %@", characteristicUUIDs, serviceUUID);

    if ([self.delegate respondsToSelector:@selector(cgmController:didConnectToCGMWithName:)])
    {
        [self.delegate cgmController:self didConnectToCGMWithName:self.cgmDeviceName];
    }
}

- (void)bleController:(UHNBLEController*)controller didUpdateNotificationState:(BOOL)notify forCharacteristic:(NSString*)charUUID
{
    DLog(@"Characteristic %@ notification state is %d", charUUID, notify);
    if ([charUUID isEqualToString:kCGMCharacteristicUUIDMeasurement]) {
        if ([self.delegate respondsToSelector:@selector(cgmController:notificationMeasurement:)]) {
            [self.delegate cgmController:self notificationMeasurement:notify];
        }
    } else if ([charUUID isEqualToString:kCGMCharacteristicUUIDRecordAccessControlPoint]) {
        if ([self.delegate respondsToSelector:@selector(cgmController:notificationRACP:)]) {
            [self.delegate cgmController:self notificationRACP:notify];
        }
    } else if ([charUUID isEqualToString:kCGMCharacteristicUUIDSpecificOpsControlPoint]) {
        if ([self.delegate respondsToSelector:@selector(cgmController:notificationCGMCP:)]) {
            [self.delegate cgmController:self notificationCGMCP:notify];
        }
    }
}

- (void)bleController:(UHNBLEController*)controller didWriteValue:(NSData*)value toCharacteristic:(NSString*)charUUID
{
    DLog(@"Characteristic %@ was written %@", charUUID, value);
    
    if ([charUUID isEqualToString:kCGMCharacteristicUUIDSessionStartTime]) {
        [self.bleController readValueFromCharacteristicUUID:kCGMCharacteristicUUIDSessionStartTime withServiceUUID:kCGMServiceUUID];
    }
}

- (void)bleController:(UHNBLEController*)controller didUpdateValue:(NSData*)value forCharacteristic:(NSString*)charUUID
{
    DLog(@"Characteristic %@ did update %@", charUUID, value);
    
    if ([charUUID isEqualToString: kCGMCharacteristicUUIDMeasurement]) {
        NSMutableDictionary *measurementDetails = [[value parseMeasurementCharacteristicDetails:self.crcPresent] mutableCopy];
        
        // for convenience, add the measurement date/time as native NSDate, if possible
        if (self.sessionStartTime) {
            NSDate *measurementDate = [self.sessionStartTime dateByAddingTimeInterval:[measurementDetails[kCGMKeyTimeOffset] doubleValue]];
            measurementDetails[kCGMKeyDateTime] = measurementDate;
        }

        NSLog(@"measurement details %@", measurementDetails);
        if ([self.delegate respondsToSelector:@selector(cgmController:measurementDetails:)]) {
            [self.delegate cgmController:self measurementDetails:measurementDetails];
        }
    } else if ([charUUID isEqualToString:kCGMCharacteristicUUIDFeature]) {
        NSDictionary *cgmFeatures = [value parseFeatureCharacteristicDetails];
        
        // extract presence of CRC to use for future commands
        self.crcPresent = [cgmFeatures[kCGMFeatureKeyFeatures] unsignedIntegerValue] & CGMFeatureSupportedE2ECRC;
        
        if ([self.delegate respondsToSelector:@selector(cgmController:didReadFeatures:)]) {
            [self.delegate cgmController:self didReadFeatures:cgmFeatures];
        }
    } else if ([charUUID isEqualToString:kCGMCharacteristicUUIDStatus]) {
        NSMutableDictionary *cgmStatus = [[value parseStatusCharacteristicDetails:self.crcPresent] mutableCopy];

        // for convenience, add the status date/time as native NSDate, if possible
        if (self.sessionStartTime) {
            NSDate *statusDate = [self.sessionStartTime dateByAddingTimeInterval:[cgmStatus[kCGMKeyTimeOffset] doubleValue]];
            cgmStatus[kCGMKeyDateTime] = statusDate;
        }

        if ([self.delegate respondsToSelector:@selector(cgmController:didReadStatus:)]) {
            [self.delegate cgmController:self didReadStatus:cgmStatus];
        }
    } else if ([charUUID isEqualToString:kCGMCharacteristicUUIDSessionStartTime]) {
        NSDate *sessionStartTime = [value parseSessionStartTime:self.crcPresent];
        self.sessionStartTime = sessionStartTime;
        if ([self.delegate respondsToSelector:@selector(cgmController:didReadSessionStartTime:)]) {
            [self.delegate cgmController:self didReadSessionStartTime:sessionStartTime];
        }
    } else if ([charUUID isEqualToString:kCGMCharacteristicUUIDSessionRunTime]) {
        NSTimeInterval runtimeOffset = [value parseSessionRunTimeOffset:self.crcPresent];
        if ([self.delegate respondsToSelector: @selector(cgmController:didReadSessionRunTime:)]) {
            [self.delegate cgmController: self didReadSessionRunTime: [self.sessionStartTime dateByAddingTimeInterval:runtimeOffset]];
        }
    } else if ([charUUID isEqualToString:kCGMCharacteristicUUIDSpecificOpsControlPoint]) {
        NSDictionary *responseDict = [value parseCGMCPResponse:self.crcPresent];
        CGMCPOpCode responseOpCode = [responseDict[kCGMCPKeyOpCode] unsignedIntegerValue];
        
        switch (responseOpCode) {
            case CGMCPOpCodeResponse:
            {
                NSDictionary *responseDetails = responseDict[kCGMCPKeyResponseDetails];
                CGMCPResponseCode responseCode = [responseDetails[kCGMCPKeyResponseCodeValue] unsignedIntegerValue];
                CGMCPOpCode requestOpCode = [responseDetails[kCGMCPKeyResponseRequestOpCode] unsignedIntegerValue];
                if (responseCode == CGMCPSuccess) {
                    if ([self.delegate respondsToSelector:@selector(cgmController:CGMCPOperationSuccessful:)]) {
                        [self.delegate cgmController:self CGMCPOperationSuccessful:requestOpCode];
                    }
                    [self notifyDelegateCGMCPOpCodeSuccess: requestOpCode];
                } else {
                    if ([self.delegate respondsToSelector:@selector(cgmController:CGMCPOperation:failed:)]) {
                        [self.delegate cgmController:self CGMCPOperation:requestOpCode failed:responseCode];
                    }
                }
                break;
            }
            case CGMCPOpCodeCommIntervalResponse:
            {
                NSNumber *value = responseDict[kCGMCPKeyOperand];
                if ([self.delegate respondsToSelector:@selector(cgmController:didGetCommunicationInterval:)]) {
                    [self.delegate cgmController:self didGetCommunicationInterval:value];
                }
                [self notifyDelegateDidGetCGMCPValue:value responseOpCode:responseOpCode];
                break;
            }
            case CGMCPOpCodeAlertLevelPatientHighResponse:
            {
                NSNumber *value = responseDict[kCGMCPKeyOperand];
                if ([self.delegate respondsToSelector:@selector(cgmController:didGetPatientAlertLevelHigh:)]) {
                    [self.delegate cgmController:self didGetPatientAlertLevelHigh:value];
                }
                [self notifyDelegateDidGetCGMCPValue:value responseOpCode:responseOpCode];
                break;
            }
            case CGMCPOpCodeAlertLevelPatientLowResponse:
            {
                NSNumber *value = responseDict[kCGMCPKeyOperand];
                if ([self.delegate respondsToSelector:@selector(cgmController:didGetPatientAlertLevelLow:)]) {
                    [self.delegate cgmController:self didGetPatientAlertLevelLow:value];
                }
                [self notifyDelegateDidGetCGMCPValue:value responseOpCode:responseOpCode];
                break;
            }
            case CGMCPOpCodeAlertLevelHypoReponse:
            {
                NSNumber *value = responseDict[kCGMCPKeyOperand];
                if ([self.delegate respondsToSelector:@selector(cgmController:didGetAlertLevelHypo:)]) {
                    [self.delegate cgmController:self didGetAlertLevelHypo:value];
                }
                [self notifyDelegateDidGetCGMCPValue:value responseOpCode:responseOpCode];
                break;
            }
            case CGMCPOpCodeAlertLevelHyperReponse:
            {
                NSNumber *value = responseDict[kCGMCPKeyOperand];
                if ([self.delegate respondsToSelector:@selector(cgmController:didGetAlertLevelHyper:)]) {
                    [self.delegate cgmController:self didGetAlertLevelHyper:value];
                }
                [self notifyDelegateDidGetCGMCPValue:value responseOpCode:responseOpCode];
                break;
            }
            case CGMCPOpCodeAlertLevelRateDecreaseResponse:
            {
                NSNumber *value = responseDict[kCGMCPKeyOperand];
                if ([self.delegate respondsToSelector:@selector(cgmController:didGetAlertLevelRateDecrease:)]) {
                    [self.delegate cgmController:self didGetAlertLevelRateDecrease:value];
                }
                [self notifyDelegateDidGetCGMCPValue:value responseOpCode:responseOpCode];
                break;
            }
            case CGMCPOpCodeAlertLevelRateIncreaseResponse:
            {
                NSNumber *value = responseDict[kCGMCPKeyOperand];
                if ([self.delegate respondsToSelector:@selector(cgmController:didGetAlertLevelRateIncrease:)]) {
                    [self.delegate cgmController:self didGetAlertLevelRateIncrease:value];
                }
                [self notifyDelegateDidGetCGMCPValue:value responseOpCode:responseOpCode];
                break;
            }
            case CGMCPOpCodeCalibrationValueResponse:
            {
                if ([self.delegate respondsToSelector:@selector(cgmController:didGetCalibrationDetails:)]) {
                    NSMutableDictionary *calibrationDetails = [responseDict[kCGMCPKeyResponseCalibration] mutableCopy];
                
                    // for convenience, add the calibration date/time as native NSDate, if possible
                    if (self.sessionStartTime) {
                        NSDate *calibrationDate = [self.sessionStartTime dateByAddingTimeInterval:[calibrationDetails[kCGMKeyTimeOffset] doubleValue]];
                        NSDate *calibrationDateNext = [self.sessionStartTime dateByAddingTimeInterval:[calibrationDetails[kCGMKeyTimeOffsetNext] doubleValue]];
                        calibrationDetails[kCGMKeyDateTime] = calibrationDate;
                        calibrationDetails[kCGMKeyDateTimeNext] = calibrationDateNext;
                    }

                    [self.delegate cgmController:self didGetCalibrationDetails:calibrationDetails];
                }
                break;
            }
            default:
                break;
        }
    } else if ([charUUID isEqualToString:kCGMCharacteristicUUIDRecordAccessControlPoint]) {
        NSDictionary *responseDict= [value parseRACPResponse];
        RACPOpCode responseOpCode = [responseDict[kRACPKeyResponseOpCode] unsignedIntegerValue];
        
        switch (responseOpCode) {
            case RACPOpCodeResponse:
            {
                NSDictionary *responseDetails = responseDict[kRACPKeyResponseCodeDetails];
                RACPResponseCode responseCode = [responseDetails[kRACPKeyResponseCode] unsignedIntegerValue];
                RACPOpCode requestOpCode = [responseDetails[kRACPKeyRequestOpCode] unsignedIntegerValue];
                if (responseCode == RACPSuccess) {
                    if ([self.delegate respondsToSelector:@selector(cgmController:RACPOperationSuccessful:)]) {
                        [self.delegate cgmController:self RACPOperationSuccessful:requestOpCode];
                    }
                    [self notifyDelegateRACPOpCodeSuccess:requestOpCode];
                } else {
                    if ([self.delegate respondsToSelector:@selector(cgmController:RACPOperation:failed:)]) {
                        [self.delegate cgmController:self RACPOperation:requestOpCode failed:responseCode];
                    }
                }
                break;
            }
            case RACPOpCodeResponseStoredRecordsReportNumber:
            {
                if ([self.delegate respondsToSelector: @selector(cgmController:didGetNumberOfStoredRecords:)]) {
                    NSNumber *value = responseDict[kRACPKeyNumberOfRecords];
                    [self.delegate cgmController:self didGetNumberOfStoredRecords:value];
                }
                break;
            }
            default:
                break;
        }
    }
    
//    else if ([charUUID isEqualToCBUUID: [CBUUID UUIDWithString: kBATT_CHARACTERISTIC_LEVEL_UUID]])
//    {
//        NSUInteger batteryLevel = *(uint8_t*)[value bytes];
//        
//        if ([self.delegate respondsToSelector: @selector(deviceController:didGetBatteryLevel:)])
//        {
//            [self.delegate deviceController:self didGetBatteryLevel:batteryLevel];
//        }
//    }
//    else if ([charUUID isEqualToCBUUID: [CBUUID UUIDWithString: kDEVICE_INFO_FIRMWARE_VERSION_UUID]])
//    {
//        NSString *firmwareVersion = [NSString stringWithUTF8String: [value bytes]];
//        DLog(@"device firmware version is %@", firmwareVersion);
//        if ([firmwareVersion isEqualToString: kBLUGLU_LE_INFO_FIRMWARE_VERSION_1_1])
//        {
//            [self requestFastConnectionInterval];
//        }
//        else
//        {
//            [self startDataTransfer];
//        }
//    }
}

- (void)notifyDelegateCGMCPOpCodeSuccess:(CGMCPOpCode)requestOpCode
{
    switch (requestOpCode) {
        case CGMCPOpCodeCommIntervalSet:
            if ([self.delegate respondsToSelector:@selector(cgmControllerDidSetCommunicationInterval:)]) {
                [self.delegate cgmControllerDidSetCommunicationInterval:self];
            }
            break;
        case CGMCPOpCodeCalibrationValueSet:
            if ([self.delegate respondsToSelector:@selector(cgmControllerDidSetCalibration:)]) {
                [self.delegate cgmControllerDidSetCalibration:self];
            }
            break;
        case CGMCPOpCodeAlertLevelPatientHighSet:
            if ([self.delegate respondsToSelector:@selector(cgmControllerDidSetAlertLevelPatientHigh:)]) {
                [self.delegate cgmControllerDidSetAlertLevelPatientHigh:self];
            }
            break;
        case CGMCPOpCodeAlertLevelPatientLowSet:
            if ([self.delegate respondsToSelector:@selector(cgmControllerDidSetAlertLevelPatientLow:)]) {
                [self.delegate cgmControllerDidSetAlertLevelPatientLow:self];
            }
            break;
        case CGMCPOpCodeAlertLevelHypoSet:
            if ([self.delegate respondsToSelector:@selector(cgmControllerDidSetAlertLevelHypo:)]) {
                [self.delegate cgmControllerDidSetAlertLevelHypo:self];
            }
            break;
        case CGMCPOpCodeAlertLevelHyperSet:
            if ([self.delegate respondsToSelector:@selector(cgmControllerDidSetAlertLevelHyper:)]) {
                [self.delegate cgmControllerDidSetAlertLevelHyper:self];
            }
            break;
        case CGMCPOpCodeAlertLevelRateDecreaseSet:
            if ([self.delegate respondsToSelector:@selector(cgmControllerDidSetAlertLevelRateDecrease:)]) {
                [self.delegate cgmControllerDidSetAlertLevelRateDecrease:self];
            }
            break;
        case CGMCPOpCodeAlertLevelRateIncreaseSet:
            if ([self.delegate respondsToSelector:@selector(cgmControllerDidSetAlertLevelRateIncrease:)]) {
                [self.delegate cgmControllerDidSetAlertLevelRateIncrease:self];
            }
            break;
        case CGMCPOpCodeSessionStart:
            if ([self.delegate respondsToSelector:@selector(cgmControllerDidStartSession:)]) {
                [self.delegate cgmControllerDidStartSession:self];
            }
            break;
        case CGMCPOpCodeSessionStop:
            if ([self.delegate respondsToSelector:@selector(cgmControllerDidStopSession:)]) {
                [self.delegate cgmControllerDidStopSession:self];
            }
            break;
        case CGMCPOpCodeAlertDeviceSpecificReset:
            if ([self.delegate respondsToSelector:@selector(cgmControllerDidResetDeviceSpecificAlert:)]) {
                [self.delegate cgmControllerDidResetDeviceSpecificAlert:self];
            }
            break;
        default:
            DLog(@"I do not know about requested CGMCP op code %d", requestOpCode);
            break;
    }
}

- (void)notifyDelegateDidGetCGMCPValue:(NSNumber*)value responseOpCode:(CGMCPOpCode)responseOpCode
{
    if ([self.delegate respondsToSelector:@selector(cgmController:CGMCPResponseOpCode:didGetValue:)]) {
        [self.delegate cgmController:self CGMCPResponseOpCode:responseOpCode didGetValue:value];
    }
}

- (void)notifyDelegateRACPOpCodeSuccess:(RACPOpCode)requestOpCode
{
    switch (requestOpCode) {
        case RACPOpCodeStoredRecordsReport:
            if ([self.delegate respondsToSelector:@selector(cgmControllerDidGetStoredRecords:)]) {
                [self.delegate cgmControllerDidGetStoredRecords:self];
            }
            break;
        default:
            DLog(@"I do not know about requested RACP op code %d", requestOpCode);
            break;
    }
}

@end
