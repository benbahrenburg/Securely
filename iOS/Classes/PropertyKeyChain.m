/**
 * Securely Titanium Security Project
 * Copyright (c) 2014 by Benjamin Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "PropertyKeyChain.h"

#import "JSONKit.h"
#import "TiUtils.h"
#import "NSData+Base64.h"
#import "NSString+Base64.h"
#import "NSData+CommonCrypto.h"
#import "PropertyCommon.h"

@implementation PropertyKeyChain


-(id)initWithIdentifierAndOptions:(NSString *)identifier
              withAccessibleLevel:(int)SecAttrAccessible
               withEncryptedField:(BOOL)encryptFields
              withEncryptedValues:(BOOL)encryptedValues
                       withSecret:(NSString*)secret
                withSyncAllowed:(BOOL)syncAllowed
{
    if (self = [super init]) {
        _encryptedValues = encryptedValues;
        _encryptFields = encryptFields;
        _secret = secret;
        _identifier = identifier;

        if(_identifier ==nil){
            NSLog(@"[ERROR] Identifer provided was null, using bundleIdentifier");
            _identifier = [[NSBundle mainBundle] bundleIdentifier];
        }

        _binder = [[BxSSkeychainBindings alloc] initWithIdentifierAndOptions:_identifier
                                                         withAccessibleLevel:SecAttrAccessible
                                                             withSyncAllowed:syncAllowed];

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
    NSString* result =[_binder stringForKey:key];
    if(result ==nil){
        return nil;
    }else{
        return [self decrypt:result withSecret:_secret];
    }
}


#pragma Public APIs

- (id)objectForKey:(NSString *)key {
    //return [[[PDKeychainBindingsController sharedKeychainBindingsController] valueBuffer] objectForKey:defaultName];
    return [_binder objectForKey:key];
}

-(BOOL)propertyExists: (NSString *) key
{
	if (![key isKindOfClass:[NSString class]]) return NO;
	return ([_binder objectForKey:key] != nil);
}

-(id)getBool:(NSString*)key
{
    return (_encryptedValues) ?
        [PropertyCommon decryptToBool:[self decryptFromKeyChain:key]] :
        [NSNumber numberWithBool:[_binder boolForKey:key]];
}


-(id)getDouble:(NSString*)key
{
    return (_encryptedValues) ?
        [PropertyCommon decryptToDouble:[self decryptFromKeyChain:key]] :
        [NSNumber numberWithDouble:[_binder doubleForKey:key]];

}

-(id)getInt:(NSString*)key
{
    return (_encryptedValues) ?
        [PropertyCommon decryptToInt:[self decryptFromKeyChain:key]] :
        [NSNumber numberWithInt:[_binder integerForKey:key]];
}

-(NSString*)getString:(NSString*)key
{
    NSString *result = (_encryptedValues) ?
    [self decryptFromKeyChain:key] :
    [_binder stringForKey:key];
    return (result ==nil) ? nil : result;
}

-(id)getList:(NSString*)key
{
	NSString *jsonValue = [_binder stringForKey:key];
    if(_encryptedValues){
        jsonValue = [self decrypt:jsonValue withSecret:_secret];
    }
    
    //NSLog(@"Provider getList : %@",jsonValue);
    return ((jsonValue ==nil) ? [NSNull null] : [jsonValue objectFromJSONString]);
}

-(id)getObject:(NSString*)key
{
    NSString *jsonValue = [_binder stringForKey:key];
    if(_encryptedValues){
        jsonValue = [self decrypt:jsonValue withSecret:_secret];
    }
    
    //NSLog(@"Provider getObject : %@",jsonValue);
    return ((jsonValue ==nil) ? [NSNull null] : [jsonValue objectFromJSONString]);
}

-(void)setBool:(BOOL)value withKey:(NSString*)key
{
    NSString *storageValue =  (_encryptedValues)?
        [self encrypt:[PropertyCommon boolToString:value] withSecret:_secret] :
        [PropertyCommon boolToString:value];

	[_binder setString:storageValue forKey:key];
}

-(void)setDouble:(double)value withKey:(NSString*)key
{
    NSString *storageValue =  (_encryptedValues)?
        [self encrypt:[PropertyCommon doubleToString:value] withSecret:_secret] :
    [PropertyCommon doubleToString:value];

	[_binder setString:storageValue forKey:key];
}

-(void)setInt:(int)value withKey:(NSString*)key
{
    NSString *storageValue =  (_encryptedValues)?
    [self encrypt:[PropertyCommon intToString:value] withSecret:_secret] :
    [PropertyCommon intToString:value];

	[_binder setString:storageValue forKey:key];
}

-(void)setString:(NSString*)value withKey:(NSString*)key
{
    NSString *storageValue =  (_encryptedValues)? [self encrypt:value withSecret:_secret] : value;

	[_binder setString:storageValue forKey:key];
}

-(void)setList:(id)value withKey:(NSString*)key
{
    NSLog(@"Provider setList : %@",value);
    NSString *storageValue =  (_encryptedValues)? [self encrypt:[value JSONString] withSecret:_secret] : [value JSONString];
    NSLog(@"storageValue : %@",storageValue);
 	[_binder setString:storageValue forKey:key];
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
	[_binder removeObjectForKey:key];
}

-(void)removeAllProperties
{
    [_binder removeAllItems];
}

-(id)listProperties
{
    if(_encryptFields){
        return nil;
    }else{
        id results = [_binder allKeys];
        return ((results ==nil) ? [NSNull null] : results);
    }
}

@end
