//
//  NSData+CGMCommands.h
//  CGM_Collector
//
//  Created by Nathaniel Hamming on 2015-01-08.
//  Copyright (c) 2015 eHealth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UHNCGMConstants.h"

@interface NSData (CGMCommands)

+ (NSData*)cgmCurrentTimeValue;
+ (NSData*)joinFluidType: (CGMTypeOption)type
          sampleLocation: (CGMLocationOption)location;
@end
