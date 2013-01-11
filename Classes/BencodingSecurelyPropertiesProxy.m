/**
 * Securely Titanium Security Project
 * Copyright (c) 2009-2013 by Benjamin Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "BencodingSecurelyPropertiesProxy.h"
#import "PDKeychainBindings.h"
#import "JSONKit.h"
#import "TiUtils.h"
@implementation BencodingSecurelyPropertiesProxy

-(void)_initWithProperties:(NSDictionary*)properties
{
    [super _initWithProperties:properties];
    
    NSString *identifier = [properties objectForKey:@"identifier"];
    if (identifier != nil)
    {
        NSLog(@"Created with a provieded identifier %@",identifier);
       [[PDKeychainBindings sharedKeychainBindings] setServiceName:identifier];
    }
    
    NSString *accessGroup = [properties objectForKey:@"accessGroup"];
    
#if TARGET_IPHONE_SIMULATOR
    if(accessGroup !=nil)
    {
        NSLog(@"Cannot set access group in simulator");
    }
#else
    if(accessGroup !=nil)
    {
        NSLog(@"Created with a provieded accessGroup %@",accessGroup);
        [[PDKeychainBindings sharedKeychainBindings] setAccessGroup:accessGroup];
    }
#endif
}

#pragma Public APIs

-(BOOL)propertyExists: (NSString *) key;
{
	if (![key isKindOfClass:[NSString class]]) return NO;
	return ([[PDKeychainBindings sharedKeychainBindings] objectForKey:key] != nil);
}

#define GETSPROP \
ENSURE_TYPE(args,NSArray);\
NSString *key = [args objectAtIndex:0];\
id defaultValue = [args count] > 1 ? [args objectAtIndex:1] : [NSNull null];\
if (![self propertyExists:key]) return defaultValue; \

-(id)getBool:(id)args
{
	GETSPROP
	return [NSNumber numberWithBool:[[PDKeychainBindings sharedKeychainBindings] boolForKey:key]];
}

-(id)getDouble:(id)args
{
	GETSPROP
	return [NSNumber numberWithDouble:[[PDKeychainBindings sharedKeychainBindings] doubleForKey:key]];
}

-(id)getInt:(id)args
{
	GETSPROP
	return [NSNumber numberWithInt:[[PDKeychainBindings sharedKeychainBindings] integerForKey:key]];
}

-(NSString *)getString:(id)args
{
    GETSPROP
    return[[PDKeychainBindings sharedKeychainBindings] stringForKey:key];
    
}

-(id)getList:(id)args
{
	GETSPROP
	NSString *jsonValue = [[PDKeychainBindings sharedKeychainBindings] stringForKey:key];
    return [jsonValue objectFromJSONString];
    
}

-(id)getObject:(id)args
{
    GETSPROP
    id theObject = [[PDKeychainBindings sharedKeychainBindings] objectForKey:key];
    if ([theObject isKindOfClass:[NSData class]]) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:theObject];
    }
    else {
        return theObject;
    }
}

#define SETSPROP \
ENSURE_TYPE(args,NSArray);\
NSString *key = [args objectAtIndex:0];\
id value = [args count] > 1 ? [args objectAtIndex:1] : nil;\
if (value==nil || value==[NSNull null]) {\
[[PDKeychainBindings sharedKeychainBindings] removeObjectForKey:key];\
return;\
}\
if ([self propertyExists:key] && [ [[PDKeychainBindings sharedKeychainBindings] objectForKey:key] isEqual:value]) {\
return;\
}\


-(void)setBool:(id)args
{
	SETSPROP
	[[PDKeychainBindings sharedKeychainBindings]
     setObject:[NSString stringWithFormat:@"%d",[TiUtils boolValue:value]] forKey:key];
}

-(void)setDouble:(id)args
{
	SETSPROP
	[[PDKeychainBindings sharedKeychainBindings]
     setObject:[NSString stringWithFormat:@"%f",[TiUtils doubleValue:value]] forKey:key];
}

-(void)setInt:(id)args
{
	SETSPROP
	[[PDKeychainBindings sharedKeychainBindings]
     setObject:[NSString stringWithFormat:@"%i",[TiUtils intValue:value]] forKey:key];
}

-(void)setString:(id)args
{
	SETSPROP
	[[PDKeychainBindings sharedKeychainBindings] setObject:[TiUtils stringValue:value] forKey:key];
}

-(void)setList:(id)args
{
	SETSPROP    
    NSString *jsonValue = [value JSONString];
	[[PDKeychainBindings sharedKeychainBindings] setObject:jsonValue forKey:key];
    NSLog(@"list JSON value  %@",jsonValue);
}

-(void)setObject:(id)args
{
    SETSPROP
    NSData* encoded = [NSKeyedArchiver archivedDataWithRootObject:value];
    NSString *myString = [[[NSString alloc] initWithData:encoded encoding:NSUTF8StringEncoding] autorelease];
    [[PDKeychainBindings sharedKeychainBindings] setObject:myString forKey:key];
}

-(id)hasProperty:(id)args
{
	ENSURE_SINGLE_ARG(args,NSString);
	return [NSNumber numberWithBool:[self propertyExists:[TiUtils stringValue:args]]];
}
-(void)removeProperty:(id)args
{
	ENSURE_SINGLE_ARG(args,NSString);
	[[PDKeychainBindings sharedKeychainBindings] removeObjectForKey:[TiUtils stringValue:args]];
}


-(void)setIdentifier:(id)args
{
    ENSURE_SINGLE_ARG(args,NSString);
    [[PDKeychainBindings sharedKeychainBindings] setServiceName:[TiUtils stringValue:args]];
}

-(void)setAccessGroup:(id)args
{
    ENSURE_SINGLE_ARG(args,NSString);
    [[PDKeychainBindings sharedKeychainBindings] setAccessGroup:[TiUtils stringValue:args]];
}

-(void)removeAllProperties:(id)args
{
    [[PDKeychainBindings sharedKeychainBindings] removeAllItems];
}

-(id)listProperties:(id)args
{
    id results = [[PDKeychainBindings sharedKeychainBindings] allKeys];
    return ((results ==nil) ? [NSNull null] : results);
}

@end
