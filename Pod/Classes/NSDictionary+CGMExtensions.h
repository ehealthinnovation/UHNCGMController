//
//  NSDictionary+CGMExtensions.h
//  CGM_Collector
//
//  Created by Nathaniel Hamming on 2015-01-27.
//  Copyright (c) 2015 eHealth. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (CGMExtensions)

- (NSNumber*)glucoseValue;
- (NSNumber*)trendValue;
- (BOOL)hasExceededLevelHypo;
- (BOOL)hasExceededLevelHyper;
- (BOOL)hasExceededLevelPatientLow;
- (BOOL)hasExceededLevelPatientHigh;
- (BOOL)hasExceededRateDecrease;
- (BOOL)hasExceededRateIncrease;

@end
