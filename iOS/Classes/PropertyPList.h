/**
 * Securely Titanium Security Project
 * Copyright (c) 2014 by Benjamin Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import <Foundation/Foundation.h>
#import "Property.h"

@interface PropertyPList :NSObject<Property>{
@private
    NSUserDefaults* _defaultsObject;
    NSData *_defaultsNull;
    NSString* _secret;
}
@end
