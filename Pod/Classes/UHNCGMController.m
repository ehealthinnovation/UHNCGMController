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
#import "RecordAccessControlPoint.h"

@interface UHNCGMController() <UHNBLEControllerDelegate>
@property(nonatomic,strong) UHNBLEController *bleController;
@property(nonatomic,strong) NSUUID *deviceIdentifier;
@property(nonatomic,strong) NSDate *sessionStartTime;
@property(nonatomic,strong) NSString *cgmDeviceName;
@property(nonatomic,assign) BOOL shouldBlockReconnect;
@property(nonatomic,assign) BOOL crcPresent;
@property(nonatomic,assign) id <UHNCGMControllerDelegate> delegate;
@end

@implementation UHNCGMController

#pragma mark - initializing UHNCGMController methods

- (id)init;
{
    [NSException raise:NSInvalidArgumentException
                format:@"%s: Use %@ instead", __PRETTY_FUNCTION__, NSStringFromSelector(@selector(initWithDelegate:))];
    return nil;
}

- (id) initWithDelegate:(id<UHNCGMControllerDelegate>)delegate;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    return [self initWithDelegate:delegate requiredServices:@[kCGMServiceUUID, kDEVICE_INFO_SERVICE_UUID]];
}

- (instancetype) initWithDelegate:(id<UHNCGMControllerDelegate>)delegate requiredServices:(NSArray*)serviceUUIDs;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    if ((self = [super init])) {
        self.delegate = delegate;
        self.bleController = [[UHNBLEController alloc] initWithDelegate: self
                                                       requiredServices: serviceUUIDs];
        self.shouldBlockReconnect = YES;
        self.crcPresent = NO;
    }
    return self;
}

#pragma mark - Public Methods

- (BOOL) isConnected;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    return self.bleController.isPerpherialConnected;
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

- (void) connectToDevice: (NSString*)deviceName;
{
    [self.bleController connectToDiscoveredPeripheral: deviceName];
}

- (void) disconnect;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    if ([self.bleController isPerpherialConnected]) {
        DLog(@"going to cancel BTLE connection");
        self.shouldBlockReconnect = YES;
        [self.bleController cancelConnection];
    }
}

//- (void) getBatteryLevel;
//{
//    DLog(@"%s", __PRETTY_FUNCTION__);
//    if ([self.bleController serviceForUUIDString: kBATT_SERVICE_UUID])
//    {
//        [self.bleController readValueFromCharacteristicUUID: kBATT_CHARACTERISTIC_LEVEL_UUID withServiceID: kBATT_SERVICE_UUID];
//    }
//}

- (void) enableNotificationMeasurement: (BOOL)enable;
{
    [self.bleController setNotificationState: enable forCharacteristicUUID: kCGMCharacteristicUUIDMeasurement withServiceUUID: kCGMServiceUUID];
}

- (void) enableNotificationRACP: (BOOL)enable;
{
    [self.bleController setNotificationState: enable forCharacteristicUUID: kCGMCharacteristicUUIDRecordAccessControlPoint withServiceUUID: kCGMServiceUUID];
}

- (void) enableNotificationCGMCP: (BOOL)enable;
{
    [self.bleController setNotificationState: enable forCharacteristicUUID: kCGMCharacteristicUUIDSpecificOpsControlPoint withServiceUUID: kCGMServiceUUID];
}

- (void) readFeatures;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    [self.bleController readValueFromCharacteristicUUID: kCGMCharacteristicUUIDFeature withServiceUUID: kCGMServiceUUID];
}

- (void) readSessionStartTime;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    [self.bleController readValueFromCharacteristicUUID: kCGMCharacteristicUUIDSessionStartTime withServiceUUID: kCGMServiceUUID];
}

- (void) readSessionRunTime;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    [self.bleController readValueFromCharacteristicUUID: kCGMCharacteristicUUIDSessionRunTime withServiceUUID: kCGMServiceUUID];
}

- (void) readStatus;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    [self.bleController readValueFromCharacteristicUUID: kCGMCharacteristicUUIDStatus withServiceUUID: kCGMServiceUUID];
}

- (void) setCurrentTime;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    NSData *currentTimeValue = [NSData cgmCurrentTimeValue];
    [self.bleController writeValue: currentTimeValue toCharacteristicUUID: kCGMCharacteristicUUIDSessionStartTime withServiceUUID: kCGMServiceUUID];
}

#pragma mark - Specific Ops Control Point Methods
- (void) sendCGMCPCommand: (NSData*)command
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    if ([self isConnected]) {
        [self.bleController writeValue: command toCharacteristicUUID: kCGMCharacteristicUUIDSpecificOpsControlPoint withServiceUUID: kCGMServiceUUID];
    } else {
        [self displayMessage:@"CGM not connected."];
    }
}

- (void) sendCGMCPOpCode: (uint8_t)opCode;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    NSData *command = [NSData dataWithBytes: &opCode length: sizeof(uint8_t)];
    [self sendCGMCPCommand: command];
}

- (void) sendCGMCPOpCode: (uint8_t)opCode
            operandData: (NSData*)operand
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    NSMutableData *command = [NSMutableData dataWithBytes: &opCode length: sizeof(uint8_t)];
    [command appendData: operand];
    [self sendCGMCPCommand: command];
}

- (void) startSession;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    [self sendCGMCPOpCode: kCGMCPOpCodeSessionStart];
}

- (void) stopSession;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    [self sendCGMCPOpCode: kCGMCPOpCodeSessionStop];
}

- (void) resetDeviceSpecificAlert;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    [self sendCGMCPOpCode: kCGMCPOpCodeAlertDeviceSpecificReset];
}

- (void) getCommunicationInterval;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    [self sendCGMCPOpCode: kCGMCPOpCodeCommIntervalGet];
}

- (void) getLastCalibrationValue;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    // write 0xFFFF to calibration get operation
    [self getCalibrationValue: 65535];
}

- (void) getCalibrationValue: (uint16_t)recordNumber;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    NSData *operand = [NSData dataWithBytes: &recordNumber length: sizeof(uint16_t)];
    [self sendCGMCPOpCode: kCGMCPOpCodeCalibrationValueGet operandData: operand];
}

- (void) getPatientHighLevel;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    [self sendCGMCPOpCode: kCGMCPOpCodeAlertLevelPatientHighGet];
}

- (void) getPatientLowLevel;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    [self sendCGMCPOpCode: kCGMCPOpCodeAlertLevelPatientLowGet];
}

- (void) getHypoLevel;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    [self sendCGMCPOpCode: kCGMCPOpCodeAlertLevelHypoGet];
}

- (void) getHyperLevel;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    [self sendCGMCPOpCode: kCGMCPOpCodeAlertLevelHyperGet];
}

- (void) getRateDecreaseLevel;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    [self sendCGMCPOpCode: kCGMCPOpCodeAlertLevelRateDecreaseGet];
}

- (void) getRateIncreaseLevel;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    [self sendCGMCPOpCode: kCGMCPOpCodeAlertLevelRateIncreaseGet];
}

- (void) setCommunicationInterval: (uint8_t)intervalInMinutes;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    NSData *operand = [NSData dataWithBytes: &intervalInMinutes length: sizeof(uint8_t)];
    [self sendCGMCPOpCode: kCGMCPOpCodeCalibrationValueGet operandData: operand];
}

- (void) disableCommunication;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    // set communication interval to 0x00
    [self setCommunicationInterval: 0];
}

- (void) setFastestCommunicationInterval;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    // set communication interval to 0xFF
    [self setCommunicationInterval: 255];
}

- (void) setCalibrationValue: (shortFloat)value
                   fluidType: (CGMTypeOption)type
              sampleLocation: (CGMLocationOption)location
                        date: (NSDate*)date;
{
    NSMutableData *operand = [NSMutableData dataWithBytes: &value length: sizeof(shortFloat)];
    uint16_t timeOffset = [self.sessionStartTime timeIntervalSinceDate: date] / kSecondsInMinute;
    [operand appendBytes: &timeOffset length: sizeof(uint16_t)];
    NSData *typeLocation = [NSData joinFluidType: type sampleLocation: location];
    [operand appendData: typeLocation];
    char ignoredBytes[] = {0x00, 0x00, 0x00, 0x00, 0x00};
    [operand appendBytes: ignoredBytes length: sizeof(ignoredBytes)];
    NSLog(@"operand is %@", operand);
    [self sendCGMCPOpCode: kCGMCPOpCodeCalibrationValueSet operandData: operand];
}

- (void) setPatientHighLevel: (shortFloat)value;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    NSData *operand = [NSData dataWithBytes: &value length: sizeof(shortFloat)];
    [self sendCGMCPOpCode: kCGMCPOpCodeAlertLevelPatientHighSet operandData: operand];
}

- (void) setPatientLowLevel: (shortFloat)value;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    NSData *operand = [NSData dataWithBytes: &value length: sizeof(shortFloat)];
    [self sendCGMCPOpCode: kCGMCPOpCodeAlertLevelPatientLowSet operandData: operand];
}

- (void) setHypoLevel: (shortFloat)value;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    NSData *operand = [NSData dataWithBytes: &value length: sizeof(shortFloat)];
    [self sendCGMCPOpCode: kCGMCPOpCodeAlertLevelHypoSet operandData: operand];
}

- (void) setHyperLevel: (shortFloat)value;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    NSData *operand = [NSData dataWithBytes: &value length: sizeof(shortFloat)];
    [self sendCGMCPOpCode: kCGMCPOpCodeAlertLevelHyperSet operandData: operand];
}

- (void) setRateDecreaseLevel: (shortFloat)value;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    NSData *operand = [NSData dataWithBytes: &value length: sizeof(shortFloat)];
    [self sendCGMCPOpCode: kCGMCPOpCodeAlertLevelRateDecreaseSet operandData: operand];
}

- (void) setRateIncreaseLevel: (shortFloat)value;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    NSData *operand = [NSData dataWithBytes: &value length: sizeof(shortFloat)];
    [self sendCGMCPOpCode: kCGMCPOpCodeAlertLevelRateIncreaseSet operandData: operand];
}

#pragma mark - Record Access Control Point
- (void) sendRACPCommand: (NSData*)command
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    if ([self isConnected]) {
        [self.bleController writeValue: command toCharacteristicUUID: kCGMCharacteristicUUIDRecordAccessControlPoint withServiceUUID: kCGMServiceUUID];
    } else {
        [self displayMessage:@"CGM not connected."];
    }
}

- (void) getAllStoredRecords;
{
    DLog(@"%s", __PRETTY_FUNCTION__);
    NSData *command = [NSData reportAllStoredRecords];
    [self sendRACPCommand: command];
}

#pragma mark - Private Methods

- (void) displayMessage:(NSString*)message {
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

- (void)bleController:(UHNBLEController*)controller didDiscoverPeripheral:(NSString*)deviceName services:(NSArray *)serviceUUIDs RSSI:(NSNumber *)RSSI;
{
    DLog(@"Did discover peripheral %@ (%@)", deviceName, RSSI);
    if ([self.delegate respondsToSelector: @selector(cgmController:didDiscoverCGMWithName:RSSI:)]) {
        [self.delegate cgmController: self didDiscoverCGMWithName: deviceName RSSI: RSSI];
    }
}

- (void)bleController:(UHNBLEController*)controller didDiscoverServices:(NSArray*)serviceUUIDs
{
    DLog(@"Did discover services %@", serviceUUIDs);
}

- (void)bleController:(UHNBLEController*)controller didConnectWithPeripheral:(NSString*)deviceName withServices:(NSArray*)services andUUID:(NSUUID *) uuid
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
    
    if ([self.delegate respondsToSelector: @selector(cgmController:didDisconnectFromCGM:)])
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

    if ([self.delegate respondsToSelector: @selector(cgmController:didConnectToCGMWithName:)])
    {
        [self.delegate cgmController:self didConnectToCGMWithName: self.cgmDeviceName];
    }
}

- (void)bleController:(UHNBLEController*)controller didUpdateNotificationState:(BOOL)notify forCharacteristic:(NSString*)charUUID
{
    DLog(@"Characteristic %@ notification state is %d", charUUID, notify);
    if ([charUUID isEqualToString: kCGMCharacteristicUUIDMeasurement]) {
        if ([self.delegate respondsToSelector:@selector(cgmController:notificationMeasurement:)]) {
            [self.delegate cgmController: self notificationMeasurement: notify];
        }
    } else if ([charUUID isEqualToString: kCGMCharacteristicUUIDRecordAccessControlPoint]) {
        if ([self.delegate respondsToSelector:@selector(cgmController:notificationRACP:)]) {
            [self.delegate cgmController: self notificationRACP: notify];
        }
    } else if ([charUUID isEqualToString: kCGMCharacteristicUUIDSpecificOpsControlPoint]) {
        if ([self.delegate respondsToSelector:@selector(cgmController:notificationCGMCP:)]) {
            [self.delegate cgmController: self notificationCGMCP: notify];
        }
    }
}

- (void)bleController:(UHNBLEController*)controller didWriteValue:(NSData*)value toCharacteristic:(NSString*)charUUID
{
    DLog(@"Characteristic %@ was written %@", charUUID, value);
    
    if ([charUUID isEqualToString: kCGMCharacteristicUUIDSessionStartTime]) {
        [self.bleController readValueFromCharacteristicUUID: kCGMCharacteristicUUIDSessionStartTime withServiceUUID: kCGMServiceUUID];
    }
}

- (void)bleController:(UHNBLEController*)controller didUpdateValue:(NSData*)value forCharacteristic:(NSString*)charUUID
{
    DLog(@"Characteristic %@ did update %@", charUUID, value);
    
    if ([charUUID isEqualToString: kCGMCharacteristicUUIDMeasurement]) {
        NSMutableDictionary *measurementDetails = [[value parseMeasurementCharacteristicDetails: self.crcPresent] mutableCopy];
        
        // for convenience, add the measurement date/time as native NSDate
        if (self.sessionStartTime) {
            NSDate *measurementDate = [self.sessionStartTime dateByAddingTimeInterval: [measurementDetails[kCGMKeyTimeOffset] doubleValue]];
            [measurementDetails setObject: measurementDate forKey: kCGMMeasurementKeyDateTime];
        }

        NSLog(@"measurement details %@", measurementDetails);
        if ([self.delegate respondsToSelector: @selector(cgmController:currentMeasurementDetails:)]) {
            [self.delegate cgmController: self currentMeasurementDetails: measurementDetails];
        }
    } else if ([charUUID isEqualToString: kCGMCharacteristicUUIDFeature]) {
        NSDictionary *cgmFeatures = [value parseFeatureCharacteristicDetails];
        
        // extract presence of CRC to use for future commands
        self.crcPresent = [cgmFeatures[kCGMFeatureKeyFeatures] unsignedIntegerValue] & kCGMFeatureSupportedE2ECRC;
        
        if ([self.delegate respondsToSelector: @selector(cgmController:featuresDetails:)]) {
            [self.delegate cgmController: self featuresDetails: cgmFeatures];
        }
    } else if ([charUUID isEqualToString: kCGMCharacteristicUUIDStatus]) {
        NSDictionary *cgmStatus = [value parseStatusCharacteristicDetails: self.crcPresent];
        if ([self.delegate respondsToSelector: @selector(cgmController:status:)]) {
            [self.delegate cgmController: self status: cgmStatus];
        }
    } else if ([charUUID isEqualToString: kCGMCharacteristicUUIDSessionStartTime]) {
        NSDate *sessionStartTime = [value parseSessionStartTime: self.crcPresent];
        self.sessionStartTime = sessionStartTime;
        if ([self.delegate respondsToSelector: @selector(cgmController:sessionStartTime:)]) {
            [self.delegate cgmController: self sessionStartTime: sessionStartTime];
        }
    } else if ([charUUID isEqualToString: kCGMCharacteristicUUIDSessionRunTime]) {
        NSTimeInterval runtimeOffset = [value parseSessionRunTimeOffset: self.crcPresent];
        if ([self.delegate respondsToSelector: @selector(cgmController:sessionRunTime:)]) {
            [self.delegate cgmController: self sessionRunTime: [self.sessionStartTime dateByAddingTimeInterval: runtimeOffset]];
        }
    } else if ([charUUID isEqualToString: kCGMCharacteristicUUIDSpecificOpsControlPoint]) {
        NSDictionary *responseDict = [value parseCGMCPResponse: self.crcPresent];
        CGMCPOpCode responseOpCode = [responseDict[kCGMCPKeyOpCode] unsignedIntegerValue];
        
        switch (responseOpCode) {
            case kCGMCPOpCodeResponse:
            {
                NSDictionary *responseDetails = responseDict[kCGMCPKeyResponseDetails];
                CGMCPResponseCode responseCode = [responseDetails[kCGMCPKeyResponseCodeValue] unsignedIntegerValue];
                CGMCPOpCode requestOpCode = [responseDetails[kCGMCPKeyResponseRequestOpCode] unsignedIntegerValue];
                if (responseCode == kCGMCPSuccess) {
                    if ([self.delegate respondsToSelector:@selector(cgmController:CGMCPOperationSuccessful:)]) {
                        [self.delegate cgmController: self CGMCPOperationSuccessful: requestOpCode];
                    }
                } else {
                    if ([self.delegate respondsToSelector:@selector(cgmController:CGMCPOperation:failed:)]) {
                        [self.delegate cgmController: self CGMCPOperation: requestOpCode failed: responseCode];
                    }
                }
                break;
            }
            case kCGMCPOpCodeCommIntervalResponse:
            case kCGMCPOpCodeAlertLevelPatientHighResponse:
            case kCGMCPOpCodeAlertLevelPatientLowResponse:
            case kCGMCPOpCodeAlertLevelHypoReponse:
            case kCGMCPOpCodeAlertLevelHyperReponse:
            case kCGMCPOpCodeAlertLevelRateDecreaseResponse:
            case kCGMCPOpCodeAlertLevelRateIncreaseResponse:
            {
                if ([self.delegate respondsToSelector:@selector(cgmController:didGetValue:CGMCPResponseOpCode:)]) {
                    NSNumber *value = responseDict[kCGMCPKeyOperand];
                    [self.delegate cgmController: self didGetValue: value CGMCPResponseOpCode: responseOpCode];
                }
                break;
            }
            default:
                break;
        }
    } else if ([charUUID isEqualToString: kCGMCharacteristicUUIDRecordAccessControlPoint]) {
        NSDictionary *responseDict= [value parseRACPResponse];
        RACPOpCode responseOpCode = [responseDict[kRACPKeyResponseOpCode] unsignedIntegerValue];
        
        switch (responseOpCode) {
            case kRACPOpCodeResponse:
            {
                NSDictionary *responseDetails = responseDict[kRACPKeyResponseCodeDetails];
                RACPResponseCode responseCode = [responseDetails[kRACPKeyResponseCode] unsignedIntegerValue];
                RACPOpCode requestOpCode = [responseDetails[kRACPKeyRequestOpCode] unsignedIntegerValue];
                if (responseCode == kRACPSuccess) {
                    if ([self.delegate respondsToSelector:@selector(cgmController:RACPOperationSuccessful:)]) {
                        [self.delegate cgmController: self RACPOperationSuccessful: requestOpCode];
                    }
                } else {
                    if ([self.delegate respondsToSelector:@selector(cgmController:RACPOperation:failed:)]) {
                        [self.delegate cgmController: self RACPOperation: requestOpCode failed: responseCode];
                    }
                }
                break;
            }
            case kRACPOpCodeResponseStoredRecordsReportNumber:
            {
                if ([self.delegate respondsToSelector: @selector(cgmController:didGetNumberOfStoredRecords:)]) {
                    NSNumber *value = responseDict[kRACPKeyNumberOfRecords];
                    [self.delegate cgmController: self didGetNumberOfStoredRecords: value];
                }
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

@end
