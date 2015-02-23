//
//  UHNCGMControllerTests.m
//  UHNCGMControllerTests
//
//  Created by Nathaniel Hamming on 02/17/2015.
//  Copyright (c) 2015 University Health Network.
//

#import <UHNCGMController/NSData+CGMCommands.h>
#import <UHNBLEController/NSData+ConversionExtensions.h>
#import <UHNBLEController/UHNBLETypes.h>

SpecBegin(CGMCommandSpecs)

describe(@"CGM command formatting", ^{
    
    it(@"should construct a current time command", ^{
        NSData *testCommand = [NSData cgmCurrentTimeValue];
        
        // get the actual values for a time of now.
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSUInteger const kComponentBits = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                                           | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitTimeZone);
        NSDateComponents *components = [cal components:kComponentBits fromDate: [NSDate date]];
        uint16_t year = components.year;
        uint8_t month = components.month;
        uint8_t day = components.day;
        uint8_t hour = components.hour;
        uint8_t minute = components.minute;
        uint8_t second = components.second;

        NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
        NSInteger secFromGMT = [localTimeZone secondsFromGMT];
        float hourFromGMT = secFromGMT / kSecondsInHour;
        uint8_t timeZoneValue = hourFromGMT * kCGMTimeZoneStepSizeMin60;
        
        NSTimeInterval daylightOffset = [localTimeZone daylightSavingTimeOffset];
        
        expect([testCommand unsignedIntegerAtRange:(NSRange){0,2}]).to.equal(year);
        expect([testCommand unsignedIntegerAtRange:(NSRange){2,1}]).to.equal(month);
        expect([testCommand unsignedIntegerAtRange:(NSRange){3,1}]).to.equal(day);
        expect([testCommand unsignedIntegerAtRange:(NSRange){4,1}]).to.equal(hour);
        expect([testCommand unsignedIntegerAtRange:(NSRange){5,1}]).to.equal(minute);
        expect([testCommand unsignedIntegerAtRange:(NSRange){6,1}]).to.equal(second);
        expect([testCommand unsignedIntegerAtRange:(NSRange){7,1}]).to.equal(timeZoneValue);
        expect([testCommand unsignedIntegerAtRange:(NSRange){8,1}]*kSecondsInHour).to.equal(daylightOffset);
    });
    
    it(@"should join glucose fluid type and sample location", ^{
        GlucoseSampleLocationOption location = GlucoseSampleLocationSubcutaneousTissue; // 0101 (5)
        GlucoseFluidTypeOption type = GlucoseFluidTypeISF; // 1001 (9)
        NSUInteger jointValue = 0x59;
        
        NSData *testCommand = [NSData joinFluidType:type sampleLocation:location];
        
        expect([testCommand unsignedIntegerAtRange:(NSRange){0,1}]).to.equal(jointValue);
    });

});

SpecEnd
