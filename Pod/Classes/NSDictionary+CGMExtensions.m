//
//  NSDictionary+CGMExtensions.m
//  CGM_Collector
//
//  Created by Nathaniel Hamming on 2015-01-27.
//  Copyright (c) 2015 University Health Network.
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
    return ([self[kCGMStatusKeyOctetWarning] integerValue] & CGMMeasurementStatusResultLowerThanHypo);
}

- (BOOL)hasExceededLevelHyper;
{
    return ([self[kCGMStatusKeyOctetWarning] integerValue] & CGMMeasurementStatusResultHigherThanHyper);
}

- (BOOL)hasExceededLevelPatientLow;
{
    return ([self[kCGMStatusKeyOctetWarning] integerValue] & CGMMeasurementStatusResultLowerThanPatientLow);
}

- (BOOL)hasExceededLevelPatientHigh;
{
    return ([self[kCGMStatusKeyOctetWarning] integerValue] & CGMMeasurementStatusResultHigherThanPatientHigh);
}

- (BOOL)hasExceededRateDecrease;
{
    return ([self[kCGMStatusKeyOctetWarning] integerValue] & CGMMeasurementStatusResultExceedRateDecrease);
}

- (BOOL)hasExceededRateIncrease;
{
    return ([self[kCGMStatusKeyOctetWarning] integerValue] & CGMMeasurementStatusResultExceedRateIncrease);
}

@end
