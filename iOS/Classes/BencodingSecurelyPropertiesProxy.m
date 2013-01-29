/**
 * Securely Titanium Security Project
 * Copyright (c) 2009-2013 by Benjamin Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "BencodingSecurelyPropertiesProxy.h"
#import "BCPDKeychainBindings.h"
#import "JSONKit.h"
#import "TiUtils.h"
@implementation BencodingSecurelyPropertiesProxy

-(void)_initWithProperties:(NSDictionary*)properties
{
    [super _initWithProperties:properties];
    
    NSString *identifier = [properties objectForKey:@"identifier"];
    if (identifier != nil)
    {
        DebugLog(@"Created with a provieded identifier %@",identifier);
       [[BCPDKeychainBindings sharedKeychainBindings] setServiceName:identifier];
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
        [[BCPDKeychainBindings sharedKeychainBindings] setAccessGroup:accessGroup];
    }
#endif
}

#pragma Event APIs

-(void) triggerEvent:(NSString *)eventName actionType:(NSString *)actionType
{
    if ([self _hasListeners:@"changed"])
    {
        //DebugLog(@"Firing listener");

        NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:
                               eventName,@"source",
                               actionType,@"actionType",
                               nil
                               ];
        
		[self fireEvent:@"changed" withObject:event];
    }
//    else
//    {
//        DebugLog(@"No listener found");   
//    }
}


#pragma Public APIs

-(BOOL)propertyExists: (NSString *) key;
{
	if (![key isKindOfClass:[NSString class]]) return NO;
	return ([[BCPDKeychainBindings sharedKeychainBindings] objectForKey:key] != nil);
}

#define GETSPROP \
ENSURE_TYPE(args,NSArray);\
NSString *key = [args objectAtIndex:0];\
id defaultValue = [args count] > 1 ? [args objectAtIndex:1] : [NSNull null];\
if (![self propertyExists:key]) return defaultValue; \

-(id)getBool:(id)args
{
	GETSPROP
	return [NSNumber numberWithBool:[[BCPDKeychainBindings sharedKeychainBindings] boolForKey:key]];
}

-(id)getDouble:(id)args
{
	GETSPROP
	return [NSNumber numberWithDouble:[[BCPDKeychainBindings sharedKeychainBindings] doubleForKey:key]];
}

-(id)getInt:(id)args
{
	GETSPROP
	return [NSNumber numberWithInt:[[BCPDKeychainBindings sharedKeychainBindings] integerForKey:key]];
}

-(NSString *)getString:(id)args
{
    GETSPROP
    id result = [[BCPDKeychainBindings sharedKeychainBindings] stringForKey:key];
    return ((result ==nil) ? [NSNull null] : result);
    
}

-(id)getList:(id)args
{
	GETSPROP
	NSString *jsonValue = [[BCPDKeychainBindings sharedKeychainBindings] stringForKey:key];
    return ((jsonValue ==nil) ? [NSNull null] : [jsonValue objectFromJSONString]);
    
}

-(id)getObject:(id)args
{
    GETSPROP
	NSString *jsonValue = [[BCPDKeychainBindings sharedKeychainBindings] stringForKey:key];
    return ((jsonValue ==nil) ? [NSNull null] : [jsonValue objectFromJSONString]);
}

#define SETSPROP \
ENSURE_TYPE(args,NSArray);\
NSString *key = [args objectAtIndex:0];\
id value = [args count] > 1 ? [args objectAtIndex:1] : nil;\
if (value==nil || value==[NSNull null]) {\
[[BCPDKeychainBindings sharedKeychainBindings] removeObjectForKey:key];\
return;\
}\
if ([self propertyExists:key] && [ [[BCPDKeychainBindings sharedKeychainBindings] objectForKey:key] isEqual:value]) {\
return;\
}\


-(void)setBool:(id)args
{
	SETSPROP
	[[BCPDKeychainBindings sharedKeychainBindings]
     setObject:[NSString stringWithFormat:@"%d",[TiUtils boolValue:value]] forKey:key];
    [self triggerEvent:key actionType:@"modify"];
}

-(void)setDouble:(id)args
{
	SETSPROP
	[[BCPDKeychainBindings sharedKeychainBindings]
     setObject:[NSString stringWithFormat:@"%f",[TiUtils doubleValue:value]] forKey:key];
    [self triggerEvent:key actionType:@"modify"];
}

-(void)setInt:(id)args
{
	SETSPROP
	[[BCPDKeychainBindings sharedKeychainBindings]
     setObject:[NSString stringWithFormat:@"%i",[TiUtils intValue:value]] forKey:key];
    [self triggerEvent:key actionType:@"modify"];
}

-(void)setString:(id)args
{    
	SETSPROP
	[[BCPDKeychainBindings sharedKeychainBindings] setObject:[TiUtils stringValue:value] forKey:key];
    [self triggerEvent:key actionType:@"modify"];
}

-(void)setList:(id)args
{
	SETSPROP    
    NSString *jsonValue = [value JSONString];
	[[BCPDKeychainBindings sharedKeychainBindings] setObject:jsonValue forKey:key];
    //DebugLog(@"list JSON value  %@",jsonValue);
    [self triggerEvent:key actionType:@"modify"];
}

-(void)setObject:(id)args
{
    SETSPROP
    NSString *jsonValue = [value JSONString];
	[[BCPDKeychainBindings sharedKeychainBindings] setObject:jsonValue forKey:key];
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
	[[BCPDKeychainBindings sharedKeychainBindings] removeObjectForKey:[TiUtils stringValue:args]];
    [self triggerEvent:[TiUtils stringValue:args] actionType:@"remove"];
}


-(void)setIdentifier:(id)args
{
    ENSURE_SINGLE_ARG(args,NSString);
    [[BCPDKeychainBindings sharedKeychainBindings] setServiceName:[TiUtils stringValue:args]];
    [self triggerEvent:@"indentifier" actionType:@"modify"];
}

-(void)setAccessGroup:(id)args
{
#if TARGET_IPHONE_SIMULATOR

    DebugLog(@"Cannot set access group in simulator");
#else
    ENSURE_SINGLE_ARG(args,NSString);
    [[BCPDKeychainBindings sharedKeychainBindings] setAccessGroup:[TiUtils stringValue:args]];
    [self triggerEvent:@"AccountGroup" actionType:@"modify"];
#endif
    
}

-(void)removeAllProperties:(id)args
{
    [[BCPDKeychainBindings sharedKeychainBindings] removeAllItems];
    [self triggerEvent:@"NA" actionType:@"removeall"];
}

-(id)listProperties:(id)args
{
    id results = [[BCPDKeychainBindings sharedKeychainBindings] allKeys];
    return ((results ==nil) ? [NSNull null] : results);
}

-(void)setSecret:(id)args
{
    NSLog(@"setSecret is not used on iOS and is included for parity sake with Android");
}
@end
