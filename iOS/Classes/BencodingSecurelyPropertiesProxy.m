/**
 * Securely Titanium Security Project
 * Copyright (c) 2014 by Benjamin Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "BencodingSecurelyPropertiesProxy.h"
#import "PropertyKeyChain.h"
#import "PropertyPList.h"
#import "TiUtils.h"
#import "NSData+CommonCrypto.h"

@implementation BencodingSecurelyPropertiesProxy

-(void)_initWithProperties:(NSDictionary*)properties
{
    [super _initWithProperties:properties];

    _encryptFieldNames = [TiUtils boolValue:@"encryptFieldNames" properties:properties def:NO];
    NSString *identifier = [TiUtils stringValue:@"identifier" properties:properties];
    NSString *accessGroup = [TiUtils stringValue:@"accessGroup" properties:properties];
    NSString *storageType = [TiUtils stringValue:@"storageType" properties:properties def:@"keychain"];
    _secret = [TiUtils stringValue:@"secret" properties:properties def:[[NSBundle mainBundle] bundleIdentifier]];

    if(_encryptFieldNames == YES && _secret==nil){
        NSLog(@"[ERROR] Secret value is required if encrypting");
        NSLog(@"[ERROR] Since no secret provided BUNDLE ID used");
    }

    if(_secret==nil && [storageType caseInsensitiveCompare:@"PLIST"]==NSOrderedSame){
        NSLog(@"[ERROR] Secret value is required if encrypting");
        NSLog(@"[ERROR] Since no secret provided BUNDLE ID used");
    }

    if([storageType caseInsensitiveCompare:@"keychain"]==NSOrderedSame){
        _provider = [[PropertyKeyChain alloc] initWithIdentifierAndOptions:identifier
                                                           withAccessGroup:accessGroup
                                                                withSecret:_secret];
    }
    if([storageType caseInsensitiveCompare:@"PLIST"]==NSOrderedSame){
        _provider = [[PropertyPList alloc] initWithIdentifierAndOptions:identifier
                                                           withAccessGroup:accessGroup
                                                                withSecret:_secret];
    }
}

#pragma Private methods

-(NSString*)obtainKey:(NSString*)key
{
    if(_encryptFieldNames==YES){
        return [self composeSecret:key];
    }else{
        return key;
    }
}

-(NSString*)composeSecret:(NSString*)key
{
    NSString *seed = _secret;
    [seed stringByAppendingString:@"_"];
    [seed stringByAppendingString:key];
    return [NSString stringWithUTF8String:[[[seed dataUsingEncoding:NSUTF8StringEncoding] SHA512Hash] bytes]];
}


#pragma Event APIs

-(void) triggerEvent:(NSString *)eventName actionType:(NSString *)actionType
{
    if ([self _hasListeners:@"changed"])
    {
        NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:
                               eventName,@"source",
                               eventName,@"propertyName",
                               actionType,@"actionType",
                               nil
                               ];
        
		[self fireEvent:@"changed" withObject:event];
    }
}


#pragma Public APIs

-(NSNumber*)hasFieldsEncrypted: (id) unused;
{
    return NUMBOOL(_encryptFieldNames);
}
-(BOOL)propertyExists: (NSString *) key;
{
    return [_provider propertyExists:key];
}

#define GETSPROP \
ENSURE_TYPE(args,NSArray);\
NSString *key = [args objectAtIndex:0];\
id defaultValue = [args count] > 1 ? [args objectAtIndex:1] : [NSNull null];\
if (![self propertyExists:[self obtainKey:key]]) return defaultValue; \

-(id)getBool:(id)args
{
	GETSPROP
	return[_provider getBool:[self obtainKey:key]];
}

-(id)getDouble:(id)args
{
	GETSPROP
    return[_provider getDouble:[self obtainKey:key]];
}

-(id)getInt:(id)args
{
	GETSPROP
    return[_provider getInt:[self obtainKey:key]];
}

-(NSString *)getString:(id)args
{
    GETSPROP
    return[_provider getString:[self obtainKey:key]];
}

-(id)getList:(id)args
{
	GETSPROP
    return[_provider getList:[self obtainKey:key]];
}

-(id)getObject:(id)args
{
    GETSPROP
    return[_provider getObject:[self obtainKey:key]];
}

#define SETSPROP \
ENSURE_TYPE(args,NSArray);\
NSString *key = [args objectAtIndex:0];\
id value = [args count] > 1 ? [args objectAtIndex:1] : nil;\
if (value==nil || value==[NSNull null]) {\
[_provider removeProperty:key];\
return;\
}\
if ([self propertyExists:[self obtainKey:key]] && [[_provider objectForKey:[self obtainKey:key]] isEqual:value]) {\
return;\
}\


-(void)setBool:(id)args
{
	SETSPROP
    [_provider setBool:[TiUtils boolValue:args] withKey:[self obtainKey:key]];
    [self triggerEvent:key actionType:@"modify"];
}

-(void)setDouble:(id)args
{
	SETSPROP
    [_provider setDouble:[TiUtils doubleValue:value] withKey:[self obtainKey:key]];
    [self triggerEvent:key actionType:@"modify"];
}

-(void)setInt:(id)args
{
	SETSPROP
    [_provider setInt:[TiUtils intValue:value] withKey:[self obtainKey:key]];
    [self triggerEvent:key actionType:@"modify"];
}

-(void)setString:(id)args
{    
	SETSPROP
    [_provider setString:[TiUtils stringValue:value] withKey:[self obtainKey:key]];
    [self triggerEvent:key actionType:@"modify"];
}

-(void)setList:(id)args
{
	SETSPROP
    [_provider setList:args withKey:[self obtainKey:key]];
    [self triggerEvent:key actionType:@"modify"];
}

-(void)setObject:(id)args
{
    SETSPROP
    [_provider setObject:args withKey:[self obtainKey:key]];
    [self triggerEvent:key actionType:@"modify"];
}

-(id)hasProperty:(id)key
{
	ENSURE_SINGLE_ARG(key,NSString);
    return [_provider hasProperty:[self obtainKey:[TiUtils stringValue:key]]];
}
-(void)removeProperty:(id)key
{
	ENSURE_SINGLE_ARG(key,NSString);
    [_provider removeProperty:[TiUtils stringValue:[self obtainKey:[TiUtils stringValue:key]]]];
    [self triggerEvent:[TiUtils stringValue:key] actionType:@"remove"];
}


-(void)setIdentifier:(id)value
{
    ENSURE_SINGLE_ARG(value,NSString);
    [_provider setIdentifier:[TiUtils stringValue:value]];
    [self triggerEvent:@"indentifier" actionType:@"modify"];
}

-(void)setAccessGroup:(id)value
{
    ENSURE_SINGLE_ARG(value,NSString);
    [_provider setAccessGroup:[TiUtils stringValue:value]];
    [self triggerEvent:@"AccountGroup" actionType:@"modify"];    
}

-(void)removeAllProperties:(id)unused
{
    [_provider removeAllProperties];
    [self triggerEvent:@"NA" actionType:@"removeall"];
}

-(id)listProperties:(id)args
{
    return [_provider listProperties];
}

-(void)setSecret:(id)args
{
    NSLog(@"Secret needs to be set at creation of PROXY");
}
@end
