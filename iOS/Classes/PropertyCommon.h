/**
 * Securely Titanium Security Project
 * Copyright (c) 2014 by Benjamin Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import <Foundation/Foundation.h>

@interface PropertyCommon : NSObject

+(id)decryptToBool:(id)value;
+(NSString*)boolToString:(BOOL)value;
+(id)decryptToDouble:(id)value;
+(NSString*)doubleToString:(double)value;
+(id)decryptToInt:(id)value;
+(NSString*)intToString:(int)value;


@end
