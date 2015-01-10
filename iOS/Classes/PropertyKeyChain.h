/**
 * Securely Titanium Security Project
 * Copyright (c) 2014 by Benjamin Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import <Foundation/Foundation.h>
#import "Property.h"
#import "BxsskeychainBindings.h"

@interface PropertyKeyChain :NSObject<Property>{
@private
    NSString* _identifier;
    NSString *_secret;
    BOOL _encryptFields;
    BOOL _encryptedValues;
    BxSSkeychainBindings * _binder;
}

@end
