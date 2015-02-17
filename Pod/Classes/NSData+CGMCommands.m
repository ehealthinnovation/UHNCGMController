//
//  NSData+CGMCommands.m
//  CGM_Collector
//
//  Created by Nathaniel Hamming on 2015-01-08.
//  Copyright (c) 2015 eHealth. All rights reserved.
//

#import "NSData+CGMCommands.h"

@implementation NSData (CGMCommands)

+ (NSData*)cgmCurrentTimeValue;
{
    NSDate *now = [NSDate date];
    // TODO get start time components (year, month, day, hour, min, sec)
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSUInteger const kComponentBits = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                                       | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitTimeZone);
    NSDateComponents *components = [cal components: kComponentBits fromDate: now];
    uint16_t year = components.year;
    uint8_t month = components.month;
    uint8_t day = components.day;
    uint8_t hour = components.hour;
    uint8_t minute = components.minute;
    uint8_t second = components.second;
    
    NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
    NSTimeInterval daylightOffset = [localTimeZone daylightSavingTimeOffset];
    uint8_t dtsOffsetValue = kDSTUnknown;
    if (daylightOffset >= kSecondsInHour * 2) {
        dtsOffsetValue = kDSTPlusHoursTwo;
    } else if (daylightOffset >= kSecondsInHour) {
        dtsOffsetValue = kDSTPlusHourOne;
    } else if (daylightOffset >= kSecondsInHour / 2.) {
        dtsOffsetValue = kDSTPlusHourHalf;
    } else if (daylightOffset == 0.) {
        dtsOffsetValue = kDSTStandardTime;
    }
    
    NSInteger secFromGMT = [localTimeZone secondsFromGMT];
    float hourFromGMT = secFromGMT / kSecondsInHour;
    uint8_t timeZoneValue = hourFromGMT * kCGMTimeZoneStepSize;

    char cgmCurrentTimeBytes[] = {year, (year >> 8), month, day, hour, minute, second, timeZoneValue, dtsOffsetValue};
    NSData *cgmCurrentTimeValue = [NSData dataWithBytes: cgmCurrentTimeBytes length: sizeof(cgmCurrentTimeBytes)];
    
    return cgmCurrentTimeValue;
}

+ (NSData*)joinFluidType: (CGMTypeOption)type
          sampleLocation: (CGMLocationOption)location;
{
    uint8_t typeLocation = type | (location << 4);
    return [NSData dataWithBytes: &typeLocation length:sizeof(uint8_t)];
}


@end
