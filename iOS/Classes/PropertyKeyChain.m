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
        
#if TARGET_IPHONE_SIMULATOR
        if(accessGroup !=nil){
            NSLog(@"[DEBUG] Cannot set access group in simulator");
        }
#else
        if(accessGroup !=nil){
            NSLog(@"[DEBUG] Created with a provieded accessGroup %@",accessGroup);
            [[BCXPDKeychainBindings sharedKeychainBindings] setAccessGroup:accessGroup];
        }
#endif

    }

    return self;
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
	return [NSNumber numberWithBool:[[BCXPDKeychainBindings sharedKeychainBindings] boolForKey:key]];
}

-(id)getDouble:(NSString*)key
{
	return [NSNumber numberWithDouble:[[BCXPDKeychainBindings sharedKeychainBindings] doubleForKey:key]];
}

-(id)getInt:(NSString*)key
{
	return [NSNumber numberWithInt:[[BCXPDKeychainBindings sharedKeychainBindings] integerForKey:key]];
}

-(NSString *)getString:(NSString*)key
{
    id result = [[BCXPDKeychainBindings sharedKeychainBindings] stringForKey:key];
    return ((result ==nil) ? [NSNull null] : result);

}

-(id)getList:(NSString*)key
{
	NSString *jsonValue = [[BCXPDKeychainBindings sharedKeychainBindings] stringForKey:key];
    return ((jsonValue ==nil) ? [NSNull null] : [jsonValue objectFromJSONString]);
}

-(id)getObject:(NSString*)key
{
	NSString *jsonValue = [[BCXPDKeychainBindings sharedKeychainBindings] stringForKey:key];
    return ((jsonValue ==nil) ? [NSNull null] : [jsonValue objectFromJSONString]);
}


-(void)setBool:(BOOL)value withKey:(NSString*)key
{
	[[BCXPDKeychainBindings sharedKeychainBindings]
     setObject:[NSString stringWithFormat:@"%d",value] forKey:key];
}

-(void)setDouble:(double)value withKey:(NSString*)key
{
	[[BCXPDKeychainBindings sharedKeychainBindings]
     setObject:[NSString stringWithFormat:@"%f",value] forKey:key];
}

-(void)setInt:(int)value withKey:(NSString*)key
{
	[[BCXPDKeychainBindings sharedKeychainBindings]
     setObject:[NSString stringWithFormat:@"%i",value] forKey:key];
}

-(void)setString:(NSString*)value withKey:(NSString*)key
{
	[[BCXPDKeychainBindings sharedKeychainBindings] setObject:value forKey:key];
}

-(void)setList:(id)value withKey:(NSString*)key
{
    NSString *jsonValue = [value JSONString];
	[[BCXPDKeychainBindings sharedKeychainBindings] setObject:jsonValue forKey:key];
}

-(void)setObject:(id)value withKey:(NSString*)key
{
    NSString *jsonValue = [value JSONString];
	[[BCXPDKeychainBindings sharedKeychainBindings] setObject:jsonValue forKey:key];
}

-(id)hasProperty:(NSString*)key
{
	return [NSNumber numberWithBool:[self propertyExists:key]];
}

-(void)removeProperty:(NSString*)key
{
	[[BCXPDKeychainBindings sharedKeychainBindings] removeObjectForKey:key];
}

-(void)setIdentifier:(NSString*)value
{
    _identifier = value;
    [[BCXPDKeychainBindings sharedKeychainBindings] setServiceName:value];
}

-(void)setAccessGroup:(NSString*)value
{
    _accessGroup = value;

#if TARGET_IPHONE_SIMULATOR

    NSLog(@"[DEBUG] Cannot set access group in simulator");
#else
    [[BCXPDKeychainBindings sharedKeychainBindings] setAccessGroup:value];
#endif

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
