//
//  NSDictionary+CGMExtensions.m
//  CGM_Collector
//
//  Created by Nathaniel Hamming on 2015-01-27.
//  Copyright (c) 2015 eHealth. All rights reserved.
//

#import "NSDictionary+CGMExtensions.h"
#import "UHNCGMConstants.h"

@implementation NSDictionary (CGMExtensions)

- (NSNumber*)glucoseValue;
{
    return self[kCGMMeasurementKeyGlucoseConcentration];
}

- (NSNumber*)trendValue;
{
    return self[kCGMMeasurementKeyTrendInfo];
}

- (BOOL)hasExceededLevelHypo;
{
    return ([self[kCGMStatusKeyOctetWarning] integerValue] & kCGMMeasurementStatusResultLowerThanHypo);
}

- (BOOL)hasExceededLevelHyper;
{
    return ([self[kCGMStatusKeyOctetWarning] integerValue] & kCGMMeasurementStatusResultHigherThanHyper);
}

- (BOOL)hasExceededLevelPatientLow;
{
    return ([self[kCGMStatusKeyOctetWarning] integerValue] & kCGMMeasurementStatusResultLowerThanPatientLow);
}

- (BOOL)hasExceededLevelPatientHigh;
{
    return ([self[kCGMStatusKeyOctetWarning] integerValue] & kCGMMeasurementStatusResultHigherThanPatientHigh);
}

- (BOOL)hasExceededRateDecrease;
{
    return ([self[kCGMStatusKeyOctetWarning] integerValue] & kCGMMeasurementStatusResultExceedRateDecrease);
}

- (BOOL)hasExceededRateIncrease;
{
    return ([self[kCGMStatusKeyOctetWarning] integerValue] & kCGMMeasurementStatusResultExceedRateIncrease);
}

@end
