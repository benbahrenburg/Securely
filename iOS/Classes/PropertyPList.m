/**
 * Securely Titanium Security Project
 * Copyright (c) 2014 by Benjamin Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "PropertyPList.h"
#import "TiUtils.h"
#import "NSData+Base64.h"
#import "NSString+Base64.h"
#import "NSData+CommonCrypto.h"
#import "PropertyCommon.h"
#import "JSONKit.h"

@implementation PropertyPList

-(id)initWithIdentifierAndOptions:(NSString *)identifier
                  withAccessGroup:(NSString*)accessGroup
               withEncryptedField:(BOOL)encryptFields
              withEncryptedValues:(BOOL)encryptedValues
                       withSecret:(NSString*)secret
{
    if (self = [super init]) {

        _defaultsObject = [NSUserDefaults standardUserDefaults];
        [_defaultsObject addSuiteNamed:identifier];
        _defaultsNull = [[NSData alloc] initWithBytes:"NULL" length:4];

        _encryptFields = encryptFields;

        if(secret == nil){
            NSLog(@"[ERROR] A secret is required when using PLIST Storage");
            NSLog(@"[ERROR] Since no secret provided BUNDLE ID will be used");
            secret = [[NSBundle mainBundle] bundleIdentifier];
        }
        _secret = secret;

    }

    return self;
}

#pragma private methods

-(NSString *)encrypt:(NSString*)plainText withSecret:(NSString*)secret
{
    NSData *encryptedData = [[plainText dataUsingEncoding:NSUTF8StringEncoding] AES256EncryptedDataUsingKey:[[secret dataUsingEncoding:NSUTF8StringEncoding] SHA256Hash] error:nil];

    NSString *encryptedString = [NSString base64StringFromData:encryptedData
                                                        length:[encryptedData length]];

    //NSLog(@"[DEBUG] Securely encrypt: plainTextValue: %@ encryptedString:%@ ",plainText,encryptedString);
    return encryptedString;
}

-(NSString *)decrypt:(NSString *)encryptedText withSecret:(NSString*)secret
{
    NSData *encryptedData = [NSData base64DataFromString:encryptedText];
    NSData *decryptedData = [encryptedData decryptedAES256DataUsingKey:[[secret dataUsingEncoding:NSUTF8StringEncoding] SHA256Hash] error:nil];
    NSString *plainText =  [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
    //NSLog(@"[DEBUG] Securely decrypt: plainTextValue: %@ encryptedString:%@ ",plainText,encryptedText);
    return plainText;
}

-(NSString*)decryptFromPList:(NSString*)key
{
    NSString* result =[_defaultsObject stringForKey:key];
    if(result ==nil){
        return nil;
    }else{
        return [self decrypt:result withSecret:_secret];
    }
}

#pragma Public APIs

- (id)objectForKey:(NSString *)key {
    return [_defaultsObject objectForKey:key];
}

-(BOOL)propertyExists: (NSString *) key
{
	if (![key isKindOfClass:[NSString class]]) return NO;
	[_defaultsObject synchronize];
	return ([_defaultsObject objectForKey:key] != nil);
}

-(id)getBool:(NSString*)key
{
    return [PropertyCommon decryptToBool:[self decryptFromPList:key]];
}

-(id)getDouble:(NSString*)key
{
    return [PropertyCommon decryptToDouble:[self decryptFromPList:key]];
}

-(id)getInt:(NSString*)key
{
    return [PropertyCommon decryptToInt:[self decryptFromPList:key]];
}

-(NSString *)getString:(NSString*)key
{
    return [self decryptFromPList:key];
}

-(id)getList:(NSString*)key
{
    return [self getObject:key];
}

-(id)getObject:(NSString*)key
{
    NSString *jsonValue = [self decryptFromPList:key];
    return ((jsonValue ==nil) ? [NSNull null] : [jsonValue objectFromJSONString]);
}

-(void)setBool:(BOOL)value withKey:(NSString*)key
{
    [self setString:[PropertyCommon boolToString:value] withKey:key];
}

-(void)setDouble:(double)value withKey:(NSString*)key
{
    [self setString:[PropertyCommon doubleToString:value] withKey:key];
}

-(void)setInt:(int)value withKey:(NSString*)key
{
    [self setString:[PropertyCommon intToString:value] withKey:key];
}

-(void)setString:(NSString*)value withKey:(NSString*)key
{
    [_defaultsObject setObject:[self encrypt:value withSecret:_secret] forKey:key];
	[_defaultsObject synchronize];
}

-(void)setList:(id)value withKey:(NSString*)key
{
    [self setObject:value withKey:key];
}

-(void)setObject:(id)value withKey:(NSString*)key
{
    [self setString:[value JSONString] withKey:key];
}

-(id)hasProperty:(NSString*)key
{
	return [NSNumber numberWithBool:[self propertyExists:key]];
}

-(void)removeProperty:(NSString*)key
{
    [_defaultsObject removeObjectForKey:key];
	[_defaultsObject synchronize];
}

-(void)removeAllProperties
{
	NSArray *keys = [[_defaultsObject dictionaryRepresentation] allKeys];
	for(NSString *key in keys) {
		[_defaultsObject removeObjectForKey:key];
	}
}

-(id)listProperties
{
    if(_encryptFields){
        return nil;
    }else{
        NSMutableArray *array = [NSMutableArray array];
        [array addObjectsFromArray:[[_defaultsObject dictionaryRepresentation] allKeys]];
        return array;
    }

}

@end
