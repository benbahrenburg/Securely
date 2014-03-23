/**
 * Securely Titanium Security Project
 * Copyright (c) 2014 by Benjamin Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiProxy.h"
#import "Property.h"
@interface BencodingSecurelyPropertiesProxy : TiProxy {
@private
    id<Property> _provider;
    BOOL _fieldsEncrypted;
    BOOL _valuesEncrypted;
    NSString* _secret;
    int _storageType;
    int _securityLevel;
    NSMutableDictionary* _keyCache;
    int _keyCacheLimit;
    NSString *_propertyToken;
}

@end
