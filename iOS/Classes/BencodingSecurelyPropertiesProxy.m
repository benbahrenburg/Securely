/**
 * Securely Titanium Security Project
 * Copyright (c) 2009-2013 by Benjamin Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "BencodingSecurelyPropertiesProxy.h"
#import "BCXPDKeychainBindings.h"
#import "JSONKit.h"
#import "TiUtils.h"
@implementation BencodingSecurelyPropertiesProxy

-(void)_initWithProperties:(NSDictionary*)properties
{
    [super _initWithProperties:properties];
    
    NSString *identifier = [properties objectForKey:@"identifier"];
    if (identifier != nil)
    {
        DebugLog(@"Created with a provided identifier %@",identifier);
       [[BCXPDKeychainBindings sharedKeychainBindings] setServiceName:identifier];
    }
    
    NSString *accessGroup = [properties objectForKey:@"accessGroup"];
    
#if TARGET_IPHONE_SIMULATOR
    if(accessGroup !=nil)
    {
        DebugLog(@"Cannot set access group in simulator");
    }
#else
    if(accessGroup !=nil)
    {
        DebugLog(@"Created with a provieded accessGroup %@",accessGroup);
        [[BCXPDKeychainBindings sharedKeychainBindings] setAccessGroup:accessGroup];
    }
#endif
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
    NSLog(@"[DEBUG] hasFieldsEncrypted is not used on iOS this value will always be false");
    return NUMBOOL(NO);
}
-(BOOL)propertyExists: (NSString *) key;
{
	if (![key isKindOfClass:[NSString class]]) return NO;
	return ([[BCXPDKeychainBindings sharedKeychainBindings] objectForKey:key] != nil);
}

#define GETSPROP \
ENSURE_TYPE(args,NSArray);\
NSString *key = [args objectAtIndex:0];\
id defaultValue = [args count] > 1 ? [args objectAtIndex:1] : [NSNull null];\
if (![self propertyExists:key]) return defaultValue; \

-(id)getBool:(id)args
{
	GETSPROP
	return [NSNumber numberWithBool:[[BCXPDKeychainBindings sharedKeychainBindings] boolForKey:key]];
}

-(id)getDouble:(id)args
{
	GETSPROP
	return [NSNumber numberWithDouble:[[BCXPDKeychainBindings sharedKeychainBindings] doubleForKey:key]];
}

-(id)getInt:(id)args
{
	GETSPROP
	return [NSNumber numberWithInt:[[BCXPDKeychainBindings sharedKeychainBindings] integerForKey:key]];
}

-(NSString *)getString:(id)args
{
    GETSPROP
    id result = [[BCXPDKeychainBindings sharedKeychainBindings] stringForKey:key];
    return ((result ==nil) ? [NSNull null] : result);
    
}

-(id)getList:(id)args
{
	GETSPROP
	NSString *jsonValue = [[BCXPDKeychainBindings sharedKeychainBindings] stringForKey:key];
    return ((jsonValue ==nil) ? [NSNull null] : [jsonValue objectFromJSONString]);
    
}

-(id)getObject:(id)args
{
    GETSPROP
	NSString *jsonValue = [[BCXPDKeychainBindings sharedKeychainBindings] stringForKey:key];
    return ((jsonValue ==nil) ? [NSNull null] : [jsonValue objectFromJSONString]);
}

#define SETSPROP \
ENSURE_TYPE(args,NSArray);\
NSString *key = [args objectAtIndex:0];\
id value = [args count] > 1 ? [args objectAtIndex:1] : nil;\
if (value==nil || value==[NSNull null]) {\
[[BCXPDKeychainBindings sharedKeychainBindings] removeObjectForKey:key];\
return;\
}\
if ([self propertyExists:key] && [ [[BCXPDKeychainBindings sharedKeychainBindings] objectForKey:key] isEqual:value]) {\
return;\
}\


-(void)setBool:(id)args
{
	SETSPROP
	[[BCXPDKeychainBindings sharedKeychainBindings]
     setObject:[NSString stringWithFormat:@"%d",[TiUtils boolValue:value]] forKey:key];
    [self triggerEvent:key actionType:@"modify"];
}

-(void)setDouble:(id)args
{
	SETSPROP
	[[BCXPDKeychainBindings sharedKeychainBindings]
     setObject:[NSString stringWithFormat:@"%f",[TiUtils doubleValue:value]] forKey:key];
    [self triggerEvent:key actionType:@"modify"];
}

-(void)setInt:(id)args
{
	SETSPROP
	[[BCXPDKeychainBindings sharedKeychainBindings]
     setObject:[NSString stringWithFormat:@"%i",[TiUtils intValue:value]] forKey:key];
    [self triggerEvent:key actionType:@"modify"];
}

-(void)setString:(id)args
{    
	SETSPROP
	[[BCXPDKeychainBindings sharedKeychainBindings] setObject:[TiUtils stringValue:value] forKey:key];
    [self triggerEvent:key actionType:@"modify"];
}

-(void)setList:(id)args
{
	SETSPROP    
    NSString *jsonValue = [value JSONString];
	[[BCXPDKeychainBindings sharedKeychainBindings] setObject:jsonValue forKey:key];
    //DebugLog(@"list JSON value  %@",jsonValue);
    [self triggerEvent:key actionType:@"modify"];
}

-(void)setObject:(id)args
{
    SETSPROP
    NSString *jsonValue = [value JSONString];
	[[BCXPDKeychainBindings sharedKeychainBindings] setObject:jsonValue forKey:key];
    //DebugLog(@"list JSON value  %@",jsonValue);
    [self triggerEvent:key actionType:@"modify"];
}

-(id)hasProperty:(id)args
{
	ENSURE_SINGLE_ARG(args,NSString);
	return [NSNumber numberWithBool:[self propertyExists:[TiUtils stringValue:args]]];
}
-(void)removeProperty:(id)args
{
	ENSURE_SINGLE_ARG(args,NSString);
	[[BCXPDKeychainBindings sharedKeychainBindings] removeObjectForKey:[TiUtils stringValue:args]];
    [self triggerEvent:[TiUtils stringValue:args] actionType:@"remove"];
}


-(void)setIdentifier:(id)args
{
    ENSURE_SINGLE_ARG(args,NSString);
    [[BCXPDKeychainBindings sharedKeychainBindings] setServiceName:[TiUtils stringValue:args]];
    [self triggerEvent:@"indentifier" actionType:@"modify"];
}

-(void)setAccessGroup:(id)args
{
#if TARGET_IPHONE_SIMULATOR

    DebugLog(@"Cannot set access group in simulator");
#else
    ENSURE_SINGLE_ARG(args,NSString);
    [[BCXPDKeychainBindings sharedKeychainBindings] setAccessGroup:[TiUtils stringValue:args]];
    [self triggerEvent:@"AccountGroup" actionType:@"modify"];
#endif
    
}

-(void)removeAllProperties:(id)args
{
    [[BCXPDKeychainBindings sharedKeychainBindings] removeAllItems];
    [self triggerEvent:@"NA" actionType:@"removeall"];
}

-(id)listProperties:(id)args
{
    id results = [[BCXPDKeychainBindings sharedKeychainBindings] allKeys];
    return ((results ==nil) ? [NSNull null] : results);
}

-(void)setSecret:(id)args
{
    NSLog(@"setSecret is not used on iOS and is included for parity sake with Android");
}
@end
