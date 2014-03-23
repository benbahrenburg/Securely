/**
 * Securely Titanium Security Project
 * Copyright (c) 2014 by Benjamin Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "PropertyPList.h"
#import "TiUtils.h"


@implementation PropertyPList

-(id)initWithIdentifierAndOptions:(NSString *)identifier
                  withAccessGroup:(NSString*)accessGroup
                 withEncryptedField:(BOOL)encryptFields
                       withSecret:(NSString*)secret
{
    if (self = [super init]) {
        _encryptFields = encryptFields;
        _secret = secret;
        _defaultsObject = [NSUserDefaults standardUserDefaults];
        _defaultsNull = [[NSData alloc] initWithBytes:"NULL" length:4];
        if(accessGroup !=nil){
            NSLog(@"[DEBUG] Access Group does not apply to PLIST Storage");
        }
    }

    return self;
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
	return [NSNumber numberWithBool:[_defaultsObject boolForKey:key]];
}

-(id)getDouble:(NSString*)key
{
	return [NSNumber numberWithDouble:[_defaultsObject doubleForKey:key]];
}

-(id)getInt:(NSString*)key
{
	return [NSNumber numberWithInt:[_defaultsObject integerForKey:key]];
}

-(NSString *)getString:(NSString*)key
{
    return [_defaultsObject stringForKey:key];
}

-(id)getList:(NSString*)key
{
	NSArray *value = [_defaultsObject arrayForKey:key];
	NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:[value count]];
	[(NSArray *)value enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if ([obj isKindOfClass:[NSData class]] && [_defaultsNull isEqualToData:obj]) {
			obj = [NSNull null];
		}
		[array addObject:obj];
	}];
	return array;
}

-(id)getObject:(NSString*)key
{
    id theObject = [_defaultsObject objectForKey:key];
    if ([theObject isKindOfClass:[NSData class]]) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:theObject];
    }
    else {
        return theObject;
    }
}

-(void)setBool:(BOOL)value withKey:(NSString*)key
{
	[_defaultsObject setBool:value forKey:key];
	[_defaultsObject synchronize];
}

-(void)setDouble:(double)value withKey:(NSString*)key
{
	[_defaultsObject setDouble:value forKey:key];
	[_defaultsObject synchronize];
}

-(void)setInt:(int)value withKey:(NSString*)key
{
    [_defaultsObject setInteger:value forKey:key];
	[_defaultsObject synchronize];
}

-(void)setString:(NSString*)value withKey:(NSString*)key
{
    [_defaultsObject setObject:value forKey:key];
	[_defaultsObject synchronize];
}

-(void)setList:(id)value withKey:(NSString*)key
{
	if ([value isKindOfClass:[NSArray class]]) {
		NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:[value count]];
		[(NSArray *)value enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			if ([obj isKindOfClass:[NSNull class]]) {
				obj = _defaultsNull;
			}
			[array addObject:obj];
		}];
		value = array;
	}
	[_defaultsObject setObject:value forKey:key];
	[_defaultsObject synchronize];
}

-(void)setObject:(id)value withKey:(NSString*)key
{
    NSData* encoded = [NSKeyedArchiver archivedDataWithRootObject:value];
    [_defaultsObject setObject:encoded forKey:key];
    [_defaultsObject synchronize];
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


-(void)setIdentifier:(NSString*)value
{
    NSLog(@"[DEBUG] Identifier does not apply to PLIST Storage");
}

-(void)setAccessGroup:(NSString*)value
{
    NSLog(@"[DEBUG] Access Group does not apply to PLIST Storage");
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
