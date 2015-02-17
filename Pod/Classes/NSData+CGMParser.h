//
//  NSData+CGMParser.h
//  CGM_Collector
//
//  Created by Nathaniel Hamming on 2015-01-06.
//  Copyright (c) 2015 eHealth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UHNCGMConstants.h"

@interface NSData (CGMParser)

/** Returns a dictionary with all the data of the measurement characteristic minus the flags, size, and E2E-CRC (if present). Keys and enumerations are defined in the CGMConstants.h file, which is imported with this category.
 *
 * @param crcPresent Indicates whether the characteristic includes the E2E-CRC field
 *
 * @return  All the data of the measurement characteristic minus the flags, size, and E2E-CRC (if present). Keys and enumerations are defined in the CGMConstants.h file, which is imported with this category.
 *
 * Here are the defined keys
 *
 * kCGMMeasurementKeyGlucoseConcentration:    Glucose concentration in mg/dl. Stored as NSNumber.
 * kCGMKeyTimeOffset:                         Time offset from the session start time in minutes. Stored as NSNumber.
 * kCGMStatusKeySensorStatus:                 Status details of the current measurement (if present). Stored as NSDictionary.
 * kCGMMeasurementKeyTrendInfo:               Trend information of the current glucose concentration in (mg/dl)/min (if present). Stored as NSNumber.
 * kCGMMeasurementKeyQuality:                 Measurement quality of the current glucose concentration in % (if present). Stored as NSNumber.
 * kCGMMeasurementkeyCRCFailed:               Boolean to indicate if the E2E-CRC failed. Only included if CRC is supported. Stored as NSNumber.
 *
 * Example:
 * {
 *    kCGMMeasurementKeyGlucoseConcentration: 75,
 *    kCGMKeyTimeOffset: 5,
 *    kCGMStatusKeySensorStatus:  {
 *        kCGMStatusKeyOctetStatus: 2, // device battery low
 *        kCGMStatusKeyOctetCalTemp: 4, // Calibration recommended
 *        kCGMStatusKeyOctetCalWarning: 10 // Result higher than Patient High Level & Hyper Level
 *    },
 *    kCGMMeasurementKeyTrendInfo: 3.5,
 *    kCGMMeasurementKeyQuality: 95,
 *    kCGMMeasurementkeyCRCFailed: 0,
 * }
 */
- (NSDictionary*)parseMeasurementCharacteristicDetails: (BOOL)crcPresent;



/** Returns a dictionary with the supported features and the glucose concentration fluid type and sample location. Keys, enumerations, and values are defined in the CGMConstants.h file, which is imported with this category.
 *
 * @return All the supported features and the glucose concentration fluid type and sample locaiton.
 *
 * Here are the defined keys
 *
 * kCGMFeatureKeyFeatures:            Features of the CGM service.
 * kCGMFeatureKeyFluidType:           Fluid type for glucose concentration
 * kCGMFeatureKeySampleLocation:      Sample location of glucose concentration
 *
 * Example:
 * {
 *   kCGMFeatureKeyFeatures: 3, // only calibration supported & patient high/low alerts supported
 *   kCGMFeatureKeyFluidType: 9, // Interstitial Fluid (ISF)
 *   kCGMFeatureKeySampleLocation: 5, // Subcutaneous tissue
 * }
 */
- (NSDictionary*)parseFeatureCharacteristicDetails;



/** Returns a dictionary with the current status of the CGM sensor. Structure is the same as in the measurement characteristic. Keys and enumerations are defined in the CGMConstants.h file, which is imported with this category.
 *
 * @param crcPresent crcPresent Indicates whether the characteristic includes the E2E-CRC field
 * 
 * @return The current status of the cgm sensor
 *
 * Here are the defined keys
 *
 * kCGMKeyTimeOffset:             Time offset from the session start time in minutes. Stored as NSNumber.
 * kCGMStatusKeySensorStatus:     Current status details of the CGM sensor. Stored as NSDictionary.
 * kCGMStatusKeyOctetStatus:      Status flags. Stored as NSNumber.
 * kCGMStatusKeyOctetCalTemp:     Cal/Temp flags. Stored as NSNumber.
 * kCGMStatusKeyOctetCalWarning:  Warning flags. Stored as NSnumber.
 *
 * Example:
 * {
 *    kCGMKeyTimeOffset: 5,
 *    kCGMStatusKeySensorStatus:  {
 *        kCGMStatusKeyOctetStatus: 2, // device battery low
 *        kCGMStatusKeyOctetCalTemp: 4, // Calibration recommended
 *        kCGMStatusKeyOctetCalWarning: 10 // Result higher than Patient High Level & Hyper Level
 *    },
 * }
 */
- (NSDictionary*)parseStatusCharacteristicDetails: (BOOL)crcPresent;



/** Session start time is the time the last session started 
 *
 * @param crcPresent crcPresent Indicates whether the characteristic includes the E2E-CRC field
 *
 * @return The date of the current CGM session start time
 *
 */
- (NSDate*)parseSessionStartTime: (BOOL)crcPresent;



/** Session run time is the time offset from the session start time when the sensor should be replaced 
 *
 * @param crcPresent crcPresent Indicates whether the characteristic includes the E2E-CRC field
 *
 * @return The time offset of the CGM sensor run time. Offset is from the CGM Session start time
 *
 */
- (NSTimeInterval)parseSessionRunTimeOffset: (BOOL)crcPresent;


/** Specific Ops Control Point OpCode indicates which command was sent.
 * 
 * @param crcPresent crcPresent Indicates whether the characteristic includes the E2E-CRC field
 * 
 * @return ???
 * 
 */
- (NSDictionary*)parseCGMCPResponse: (BOOL)crcPresent;

@end
