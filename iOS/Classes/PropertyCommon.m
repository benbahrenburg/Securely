/**
 * Securely Titanium Security Project
 * Copyright (c) 2014 by Benjamin Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "PropertyCommon.h"

@implementation PropertyCommon

#pragma conversion methods

+(id)decryptToBool:(id)value
{
    if(value == [NSNull null]){
        return value;
    }else{
        return value ? [NSNumber numberWithBool:[value boolValue]] : [NSNumber numberWithBool:0];
    }
}

+(NSString*)boolToString:(BOOL)value
{
    return [NSString stringWithFormat:@"%d",value];
}

+(id)decryptToDouble:(id)value
{
    if(value == [NSNull null]){
        return value;
    }else{
        return value ? [NSNumber numberWithDouble:[value doubleValue]] : [NSNumber numberWithDouble:0];
    }
}

+(NSString*)doubleToString:(double)value
{
    return [NSString stringWithFormat:@"%f",value];
}

+(id)decryptToInt:(id)value
{
    if(value == [NSNull null]){
        return value;
    }else{
        return value ? [NSNumber numberWithInt:[value intValue]] : [NSNumber numberWithInt:0];
    }
}

+(NSString*)intToString:(int)value
{
    return [NSString stringWithFormat:@"%i",value];
}

@end
