/**
 * Securely Titanium Security Project
 * Copyright (c) 2014 by Benjamin Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "BencodingSecurelyPropertiesProxy.h"
#import "BencodingSecurelyModule.h"
#import "PropertyKeyChain.h"
#import "PropertyPList.h"
#import "TiUtils.h"
#import "NSData+CommonCrypto.h"
#import "BCXCryptoUtilities.h"

@implementation BencodingSecurelyPropertiesProxy

-(id)init
{
    if (self = [super init]) {
        //Set a few flags on proxy creation
        _propertyToken = @"BXS.";
        _valuesEncrypted = NO;
        _fieldsEncrypted = NO;
        _keyCacheLimit = 500;
        _debug = NO;
        _keyCache = [[NSMutableDictionary alloc] init];
    }

    return self;
}

-(void)_initWithProperties:(NSDictionary*)properties
{
    int accessibleLevel = [TiUtils intValue:@"acessibleLevel" properties:properties def:kBCSecAttrAccessibleAfterFirstUnlockThisDeviceOnly];

    BOOL syncAllowed = [TiUtils  boolValue:@"allowSync" properties:properties def:NO];

    _debug = [TiUtils  boolValue:@"debug" properties:properties def:NO];

    NSString *identifier = [TiUtils stringValue:@"identifier" properties:properties];

    if (![properties objectForKey:@"securityLevel"]) {
        NSLog(@"[ERROR] securityLevel not provided, a default of MED will be used");
    }

    int storageType = [TiUtils intValue:@"storageType" properties:properties def:kBCXKeyChain_Storage];
    int securityLevel = [TiUtils intValue:@"securityLevel" properties:properties def:kBCXProperty_Security_Med];
    _secret = [TiUtils stringValue:@"secret" properties:properties];


    if(storageType!=kBCXPLIST_Storage && storageType!=kBCXKeyChain_Storage){
        NSLog(@"[ERROR] Invalid storageType provided, defaulting to KeyChain Storage");
        storageType = kBCXKeyChain_Storage;
    }

    if(storageType==kBCXPLIST_Storage && securityLevel == kBCXProperty_Security_Low){
         NSLog(@"[ERROR] PREFERENCE Storage required MED or HIGH securityLevel, increasing securityLevel to MED");
        securityLevel = kBCXProperty_Security_Med;
    }

    if((securityLevel == kBCXProperty_Security_Med ||
       securityLevel == kBCXProperty_Security_High ) && _secret == nil){
        NSLog(@"[ERROR] A secret is required for MED and HIGH securityLevel");
        NSLog(@"[ERROR] Since no secret provided BUNDLE ID will be used");
        _secret = [[NSBundle mainBundle] bundleIdentifier];
    }

    if(securityLevel == kBCXProperty_Security_Med ||
       securityLevel == kBCXProperty_Security_High ){
        _valuesEncrypted = YES;
    }

    if(securityLevel == kBCXProperty_Security_High ){
        _fieldsEncrypted = YES;
    }

    if(storageType == kBCXKeyChain_Storage && identifier == nil){
        NSLog(@"[ERROR] The identifier parameter is required for KeyChain Storage");
        NSLog(@"[ERROR] Since identifier was not provided BUNDLE ID will be used");
        identifier = [[NSBundle mainBundle] bundleIdentifier];
    }

    if(storageType == kBCXKeyChain_Storage){
        _provider = [[PropertyKeyChain alloc] initWithIdentifierAndOptions:identifier
                                                       withAccessibleLevel:accessibleLevel
                                                        withEncryptedField:_fieldsEncrypted
                                                       withEncryptedValues:_valuesEncrypted
                                                                withSecret:_secret
                                                           withSyncAllowed:syncAllowed];
        if(_debug){
            NSLog(@"[DEBUG] Securely : Using keychain storage");
        }
    }

    if(storageType == kBCXPLIST_Storage){
        _provider = [[PropertyPList alloc] initWithIdentifierAndOptions:_propertyToken
                                                    withAccessibleLevel:accessibleLevel
                                                     withEncryptedField:_fieldsEncrypted
                                                    withEncryptedValues:_valuesEncrypted
                                                                withSecret:_secret
                                                            withSyncAllowed:syncAllowed];
        if(_debug){
            NSLog(@"[DEBUG] Securely : Using PList storage");
        }
    }

    if(_debug){
        NSLog(@"[DEBUG] Securely : Fields Encrypted: %@",((_fieldsEncrypted) ? @"YES" : @"NO"));
        NSLog(@"[DEBUG] Securely : Values Encrypted: %@",((_valuesEncrypted) ? @"YES" : @"NO"));
        NSLog(@"[DEBUG] Securely all provided properties %@", properties);
    }

    [super _initWithProperties:properties];
}

#pragma Private methods

-(NSString*)obtainKey:(NSString*)key
{
    return (_fieldsEncrypted) ? [self composeSecret:key] : [_propertyToken stringByAppendingString:key];
}

-(void) manageKeyCache
{
    //Check if we've hit the key cache threshold
    //This should never happen, but added to guard against bad behavior
    if([_keyCache count] > _keyCacheLimit){
        [_keyCache removeAllObjects];
    }
}
-(NSString*)composeSecret:(NSString*)key
{

    [self manageKeyCache];

    //First check if the key is in cache, this avoids having to hash it more often
    if ([_keyCache objectForKey:key]){
        //if(_debug){
        //    NSLog(@"[DEBUG] Securely : key value found in case");
        //}
        return (NSString*)[_keyCache objectForKey:key];
    }else{
        //Create the seed
        NSString *seed = _secret;
        seed = [seed stringByAppendingString:@"_"];
        seed=  [seed stringByAppendingString:key];
        //Do the SHA hash
        NSString* hashValue = [BCXCryptoUtilities createSHA512:seed];
        //if(_debug){
        //    NSLog(@"[DEBUG] Securely secret key:%@ for user key: %@ ",hashValue,key);
        //}
        //Add the new key into our hash table for faster lookup next time
        [_keyCache setValue:hashValue forKey:key];

        return hashValue;
    }
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

//Allow the user to clear the name cache if they want
-(void)clearNameCache:(id) unused
{
    [_keyCache removeAllObjects];
}

//Set the threshold used in managing the key Cache dictionary
-(void)setNameCacheThreshold:(id) threshold
{
    _keyCacheLimit = [TiUtils intValue:threshold def:500];
    [self manageKeyCache];
}


-(NSNumber*)hasValuesEncrypted: (id) unused
{
    return NUMBOOL(_valuesEncrypted);
}

-(NSNumber*)hasFieldsEncrypted: (id) unused
{
    return NUMBOOL(_fieldsEncrypted);
}

-(BOOL)propertyExists: (NSString *) key
{
    if(_debug){
        NSLog(@"[DEBUG] Securely propertyExists: key: %@",key);
    }
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
    //NSString *realKey = [self obtainKey:key];
    //NSLog(@"[DEBUG] Securely getString: key: %@ realKey:%@ ",key,realKey);
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

-(BOOL)propertyDelta:(id)value withKey:(NSString*)key
{
    if([self propertyExists:[self obtainKey:key]]){
        return (_valuesEncrypted) ? NO : [[_provider objectForKey:[self obtainKey:key]] isEqual:value];
    }else{
        return NO;
    }
}

#define SETSPROP \
ENSURE_TYPE(args,NSArray);\
NSString *key = [args objectAtIndex:0];\
id value = [args count] > 1 ? [args objectAtIndex:1] : nil;\
if (value==nil || value==[NSNull null]) {\
[_provider removeProperty:[self obtainKey:key]];\
return;\
}\
if ([self propertyDelta:value withKey:key]) {\
return;\
}\

-(void)setBool:(id)args
{
	SETSPROP
    [_provider setBool:[TiUtils boolValue:value] withKey:[self obtainKey:key]];
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
    //NSString *realKey = [self obtainKey:key];
    //NSLog(@"[DEBUG] Securely setString: value: %@ realKey:%@ ",value,realKey);
    [_provider setString:[TiUtils stringValue:value] withKey:[self obtainKey:key]];
    [self triggerEvent:key actionType:@"modify"];
}

-(void)setList:(id)args
{
	SETSPROP
    [_provider setList:value withKey:[self obtainKey:key]];
    [self triggerEvent:key actionType:@"modify"];
}

-(void)setObject:(id)args
{
    SETSPROP
    [_provider setObject:value withKey:[self obtainKey:key]];
    [self triggerEvent:key actionType:@"modify"];
}

-(id)hasProperty:(id)field
{
    ENSURE_SINGLE_ARG(field,NSString);
    NSString *secureField = [self obtainKey:[TiUtils stringValue:field]];
    BOOL doesExist = [self propertyExists:secureField];
    return NUMBOOL(doesExist);
}

-(void)removeProperty:(id)key
{
	ENSURE_SINGLE_ARG(key,NSString);
    [_provider removeProperty:[self obtainKey:key]];
    [self triggerEvent:key actionType:@"remove"];
}

-(void)removeAllProperties:(id)unused
{
    [_provider removeAllProperties];
    [self triggerEvent:@"NA" actionType:@"removeall"];
}

-(id)listProperties:(id)args
{
    NSLog(@"[DEBUG] listProperties is not available in secure properties.");
    return nil;
}
@end

