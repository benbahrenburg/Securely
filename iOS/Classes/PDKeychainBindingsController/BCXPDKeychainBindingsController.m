//
//  PDKeychainBindingsController.m
//  PDKeychainBindingsController
//
//  Created by Carl Brown on 7/10/11.
//  Copyright 2011 PDAgent, LLC. Released under MIT License.
//

//  There's (understandably) a lot of controversy about how (and whether)
//   to use the Singleton pattern for Cocoa.  I am here because I'm 
//   trying to emulate existing Singleton (NSUserDefaults) behavior
//
//   and I'm using the singleton methodology from
//   http://www.duckrowing.com/2010/05/21/using-the-singleton-pattern-in-objective-c/
//   because it seemed reasonable


#import "BCXPDKeychainBindingsController.h"
#import <Security/Security.h>

static BCXPDKeychainBindingsController *sharedInstance = nil;

@implementation BCXPDKeychainBindingsController

#pragma mark -
#pragma mark Keychain Access

- (NSString*)serviceName {
    if(_serviceName == nil)
    {
        _serviceName = [[NSBundle mainBundle] bundleIdentifier];
    }
    return _serviceName;
}

- (void) setServiceName:(NSString*)newValue{
    _serviceName = newValue;
}

- (void) setAccessGroup:(NSString*)newValue{
    _accessGroup = newValue;
}

#pragma mark - Private

-(NSMutableDictionary *)_queryForService:(NSString *)service account:(NSString *)account {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:3];
	[dictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    
    if (service) {
		[dictionary setObject:service forKey:(__bridge id)kSecAttrService];
	}
    
    if (account) {
		[dictionary setObject:account forKey:(__bridge id)kSecAttrAccount];
	}
    
    return dictionary;
}



-(NSMutableArray *)accountsForService:(NSString *)service error:(NSError **)error {
    OSStatus status = -1001;
    NSMutableDictionary *query = [self _queryForService:service account:nil];
    
    [query setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnAttributes];
    [query setObject:(__bridge id)kSecMatchLimitAll forKey:(__bridge id)kSecMatchLimit];
    
	CFTypeRef result = NULL;
    
	status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    if (status != noErr && error != NULL) {
		*error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier] code:status userInfo:nil];
		return nil;
	}
	NSMutableArray * accountKeys = [[NSMutableArray alloc] init];
    NSArray * accounts = (__bridge NSArray *)result;
    
    for (id account in accounts) {
        //NSLog(@"account = %@", account);
        if([account objectForKey:@"acct"] !=nil)
        {
            if([account objectForKey:@"acct"]!=nil)
            {
                [accountKeys addObject:[account objectForKey:@"acct"]];
            }
        }
    }

    return (([accountKeys count] == 0 ) ? nil : accountKeys);
}

- (NSMutableArray *)allKeys {
    return [self accountsForService:[self serviceName] error:nil];
}

-(void) removeAllItems {

    NSMutableDictionary *query = [self _queryForService:[self serviceName] account:nil];
    SecItemDelete((__bridge CFDictionaryRef)query);
    //OSStatus status = SecItemDelete((CFDictionaryRef)query);
//    BOOL results = (status == errSecSuccess || status == errSecItemNotFound);
//    if(results)
//    {
//        NSLog(((results) ? @"Deleted" : @"No Delete"));
//    }
}

- (NSString*)stringForKey:(NSString*)key {
	OSStatus status;
#if TARGET_OS_IPHONE
    NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys:(id)kCFBooleanTrue, kSecReturnData,
                           kSecClassGenericPassword, kSecClass,
                           key, kSecAttrAccount,
                           [self serviceName], kSecAttrService,
                           nil];
	
    CFDataRef stringData = NULL;
    status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef*)&stringData);
#else //OSX
    //SecKeychainItemRef item = NULL;
    UInt32 stringLength;
    void *stringBuffer;
    status = SecKeychainFindGenericPassword(NULL, (uint) [[self serviceName] lengthOfBytesUsingEncoding:NSUTF8StringEncoding], [[self serviceName] UTF8String],
                                            (uint) [key lengthOfBytesUsingEncoding:NSUTF8StringEncoding], [key UTF8String],
                                            &stringLength, &stringBuffer, NULL);
    #endif
	if(status) return nil;
	
#if TARGET_OS_IPHONE
    NSString *string = [[NSString alloc] initWithData:(__bridge id)stringData encoding:NSUTF8StringEncoding];
    CFRelease(stringData);
#else //OSX
    NSString *string = [[[NSString alloc] initWithBytes:stringBuffer length:stringLength encoding:NSUTF8StringEncoding] autorelease];
    SecKeychainItemFreeAttributesAndData(NULL, stringBuffer);
#endif
	return string;	
}

- (BOOL)storeString:(NSString*)string forKey:(NSString*)key {
    
    NSMutableDictionary *query = [NSMutableDictionary dictionaryWithCapacity:((_accessGroup == nil)?3 :4)];
    [query setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id<NSCopying>)(kSecClass)];
    [query setObject:key forKey:(__bridge id<NSCopying>)(kSecAttrAccount)];
    [query setObject:[self serviceName] forKey:(__bridge id<NSCopying>)(kSecAttrService)];
    
	if (!string)  {
		//Need to delete the Key 

#if TARGET_IPHONE_SIMULATOR
           
#else
        if (_accessGroup != nil)
		{
            [query setObject:_accessGroup forKey:(__bridge id<NSCopying>)(kSecAttrAccessGroup)];
        }
        
#endif
        return !SecItemDelete((__bridge CFDictionaryRef)query);
		
    } else {
        NSData *stringData = [string dataUsingEncoding:NSUTF8StringEncoding];
        
        if(!string) {
            return !SecItemDelete((__bridge CFDictionaryRef)query);
        }else if([self stringForKey:key]) {
            NSDictionary *update = [NSDictionary dictionaryWithObject:stringData forKey:(__bridge id)kSecValueData];
            return !SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)update);
        }else{
            NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:query];
            [data setObject:stringData forKey:(__bridge id)kSecValueData];
            return !SecItemAdd((__bridge CFDictionaryRef)data, NULL);
        }
    }
}

#pragma mark -
#pragma mark Singleton Stuff

+ (BCXPDKeychainBindingsController *)sharedKeychainBindingsController
{
	@synchronized (self) {
		if (sharedInstance == nil) {
			__unused id unused = [[self alloc] init]; // assignment not done here, see allocWithZone
		}
	}
	
	return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;  // assignment and return on first allocation
        }
    }
	
    return nil; //on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}
//
//- (id)retain
//{
//    return self;
//}
//
//- (oneway void)release
//{
//    //do nothing
//}
//
//- (id)autorelease
//{
//    return self;
//}
//
//- (NSUInteger)retainCount
//{
//    return NSUIntegerMax;  // This is sooo not zero
//}

- (id)init
{
	@synchronized(self) {
		self = [super init];
		return self;
	}
}

#pragma mark -
#pragma mark Business Logic

- (BCXPDKeychainBindings *) keychainBindings {
    if (_keychainBindings == nil) {
        _keychainBindings = [[BCXPDKeychainBindings alloc] init];
    }
    if (_valueBuffer==nil) {
        _valueBuffer = [[NSMutableDictionary alloc] init];
    }
    return _keychainBindings;
}

-(id) values {
    if (_valueBuffer==nil) {
        _valueBuffer = [[NSMutableDictionary alloc] init];
    }
    return _valueBuffer;
}

- (id)valueForKeyPath:(NSString *)keyPath {
    NSRange firstSeven=NSMakeRange(0, 7);
    if (NSEqualRanges([keyPath rangeOfString:@"values."],firstSeven)) {
        //This is a values keyPath, so we need to check the keychain
        NSString *subKeyPath = [keyPath stringByReplacingCharactersInRange:firstSeven withString:@""];
        NSString *retrievedString = [self stringForKey:subKeyPath];
        if (retrievedString) {
            if (![_valueBuffer objectForKey:subKeyPath] || ![[_valueBuffer objectForKey:subKeyPath] isEqualToString:retrievedString]) {
                //buffer has wrong value, need to update it
                [_valueBuffer setValue:retrievedString forKey:subKeyPath];
            }
        }
    }
    
    return [super valueForKeyPath:keyPath];
}


- (void)setValue:(id)value forKeyPath:(NSString *)keyPath {
    NSRange firstSeven=NSMakeRange(0, 7);
    if (NSEqualRanges([keyPath rangeOfString:@"values."],firstSeven)) {
        //This is a values keyPath, so we need to check the keychain
        NSString *subKeyPath = [keyPath stringByReplacingCharactersInRange:firstSeven withString:@""];
        NSString *retrievedString = [self stringForKey:subKeyPath];
        if (retrievedString) {
            if (![value isEqualToString:retrievedString]) {
                [self storeString:value forKey:subKeyPath];
            }
            if (![_valueBuffer objectForKey:subKeyPath] || ![[_valueBuffer objectForKey:subKeyPath] isEqualToString:value]) {
                //buffer has wrong value, need to update it
                [_valueBuffer setValue:value forKey:subKeyPath];
            }
        } else {
            //First time to set it
            [self storeString:value forKey:subKeyPath];
            [_valueBuffer setValue:value forKey:subKeyPath];
        }
    } 
    [super setValue:value forKeyPath:keyPath];
}

@end
