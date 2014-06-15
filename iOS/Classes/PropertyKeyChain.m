/**
 * Securely Titanium Security Project
 * Copyright (c) 2014 by Benjamin Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "PropertyKeyChain.h"
#import "BCXPDKeychainBindings.h"
#import "JSONKit.h"
#import "TiUtils.h"
#import "BCXPDKeychainBindingsController.h"
#import "NSData+Base64.h"
#import "NSString+Base64.h"
#import "NSData+CommonCrypto.h"
#import "PropertyCommon.h"

@implementation PropertyKeyChain


-(id)initWithIdentifierAndOptions:(NSString *)identifier
                  withAccessGroup:(NSString*)accessGroup
               withEncryptedField:(BOOL)encryptFields
              withEncryptedValues:(BOOL)encryptedValues
                       withSecret:(NSString*)secret
{
    if (self = [super init]) {
        _encryptedValues = encryptedValues;
        _encryptFields = encryptFields;
        _secret = secret;
        _identifier = identifier;
        _accessGroup = accessGroup;

        if(_identifier ==nil){
            NSLog(@"[ERROR] Identifer provided was null, using bundleIdentifier");
            _identifier = [[NSBundle mainBundle] bundleIdentifier];
        }

        //NSLog(@"[DEBUG] Created with a provided identifer %@",_identifier);
        [[BCXPDKeychainBindings sharedKeychainBindings] setServiceName:_identifier];

#if TARGET_IPHONE_SIMULATOR
        if(accessGroup !=nil){
            NSLog(@"[DEBUG] Cannot set access group in simulator");
        }
#else
        if(accessGroup !=nil){
            //NSLog(@"[DEBUG] Created with a provided accessGroup %@",accessGroup);
            [[BCXPDKeychainBindings sharedKeychainBindings] setAccessGroup:accessGroup];
        }
#endif

    }

    return self;
}

#pragma private methods

-(NSString *)encrypt:(NSString*)plainTextValue withSecret:(NSString*)secret
{
    NSData *encryptedData = [[plainTextValue dataUsingEncoding:NSUTF8StringEncoding] AES256EncryptedDataUsingKey:[[secret dataUsingEncoding:NSUTF8StringEncoding] SHA256Hash] error:nil];

    NSString *encryptedString = [NSString base64StringFromData:encryptedData
                                                        length:[encryptedData length]];
    return encryptedString;
}

-(NSString *)decrypt:(NSString *)encryptedTextValue withSecret:(NSString*)secret
{
    NSData *encryptedData = [NSData base64DataFromString:encryptedTextValue];
    NSData *decryptedData = [encryptedData decryptedAES256DataUsingKey:[[secret dataUsingEncoding:NSUTF8StringEncoding] SHA256Hash] error:nil];
    NSString *plainText =  [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
    return plainText;
}

-(NSString*)decryptFromKeyChain:(NSString*)key
{
    NSString* result =[[BCXPDKeychainBindingsController sharedKeychainBindingsController] stringForKey:key];
    if(result ==nil){
        return nil;
    }else{
        return [self decrypt:result withSecret:_secret];
    }
}


#pragma Public APIs

- (id)objectForKey:(NSString *)defaultName {
    //return [[[PDKeychainBindingsController sharedKeychainBindingsController] valueBuffer] objectForKey:defaultName];
    return [[BCXPDKeychainBindingsController sharedKeychainBindingsController] valueForKeyPath:[NSString stringWithFormat:@"values.%@",defaultName]];
}

-(BOOL)propertyExists: (NSString *) key
{
	if (![key isKindOfClass:[NSString class]]) return NO;
	return ([[BCXPDKeychainBindings sharedKeychainBindings] objectForKey:key] != nil);
}

-(id)getBool:(NSString*)key
{
    return (_encryptedValues) ?
        [PropertyCommon decryptToBool:[self decryptFromKeyChain:key]] :
        [NSNumber numberWithBool:[[BCXPDKeychainBindings sharedKeychainBindings] boolForKey:key]];
}


-(id)getDouble:(NSString*)key
{
    return (_encryptedValues) ?
        [PropertyCommon decryptToDouble:[self decryptFromKeyChain:key]] :
        [NSNumber numberWithDouble:[[BCXPDKeychainBindings sharedKeychainBindings] doubleForKey:key]];

}

-(id)getInt:(NSString*)key
{
    return (_encryptedValues) ?
        [PropertyCommon decryptToInt:[self decryptFromKeyChain:key]] :
        [NSNumber numberWithInt:[[BCXPDKeychainBindings sharedKeychainBindings] integerForKey:key]];
}

-(NSString*)getString:(NSString*)key
{
    NSString *result = (_encryptedValues) ?
    [self decryptFromKeyChain:key] :
    [[BCXPDKeychainBindings sharedKeychainBindings] stringForKey:key];
    return (result ==nil) ? nil : result;
}

-(id)getList:(NSString*)key
{
	NSString *jsonValue = [[BCXPDKeychainBindings sharedKeychainBindings] stringForKey:key];
    if(_encryptedValues){
        jsonValue = [self decrypt:jsonValue withSecret:_secret];
    }
    return ((jsonValue ==nil) ? [NSNull null] : [jsonValue objectFromJSONString]);
}

-(id)getObject:(NSString*)key
{
	[self getList:key];
}

-(void)setBool:(BOOL)value withKey:(NSString*)key
{
    NSString *storageValue =  (_encryptedValues)?
        [self encrypt:[PropertyCommon boolToString:value] withSecret:_secret] :
        [PropertyCommon boolToString:value];

	[[BCXPDKeychainBindings sharedKeychainBindings] setObject:storageValue forKey:key];
}

-(void)setDouble:(double)value withKey:(NSString*)key
{
    NSString *storageValue =  (_encryptedValues)?
        [self encrypt:[PropertyCommon doubleToString:value] withSecret:_secret] :
    [PropertyCommon doubleToString:value];

	[[BCXPDKeychainBindings sharedKeychainBindings] setObject:storageValue forKey:key];
}

-(void)setInt:(int)value withKey:(NSString*)key
{
    NSString *storageValue =  (_encryptedValues)?
    [self encrypt:[PropertyCommon intToString:value] withSecret:_secret] :
    [PropertyCommon intToString:value];

	[[BCXPDKeychainBindings sharedKeychainBindings] setObject:storageValue forKey:key];
}

-(void)setString:(NSString*)value withKey:(NSString*)key
{
    NSString *storageValue =  (_encryptedValues)? [self encrypt:value withSecret:_secret] : value;

	[[BCXPDKeychainBindings sharedKeychainBindings] setObject:storageValue forKey:key];
}

-(void)setList:(id)value withKey:(NSString*)key
{
    //NSLog(@"Provider setList : %@",value);
    NSString *storageValue =  (_encryptedValues)? [self encrypt:[value JSONString] withSecret:_secret] : [value JSONString];
    //NSLog(@"storageValue : %@",storageValue);
 	[[BCXPDKeychainBindings sharedKeychainBindings] setObject:storageValue forKey:key];
}

-(void)setObject:(id)value withKey:(NSString*)key
{
    [self setList:value withKey:key];
}

-(id)hasProperty:(NSString*)key
{
	return [NSNumber numberWithBool:[self propertyExists:key]];
}

-(void)removeProperty:(NSString*)key
{
	[[BCXPDKeychainBindings sharedKeychainBindings] removeObjectForKey:key];
}

-(void)removeAllProperties
{
    [[BCXPDKeychainBindings sharedKeychainBindings] removeAllItems];
}

-(id)listProperties
{
    if(_encryptFields){
        return nil;
    }else{
        id results = [[BCXPDKeychainBindings sharedKeychainBindings] allKeys];
        return ((results ==nil) ? [NSNull null] : results);
    }
}

@end
