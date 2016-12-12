//
//  SSKeychain.m
//  SSKeychain
//
//  Created by Sam Soffes on 5/19/10.
//  Copyright (c) 2010-2014 Sam Soffes. All rights reserved.
//

#import "BxSSKeychain.h"

NSString *const kBxSSKeychainErrorDomain = @"com.samsoffes.sskeychain";
NSString *const kBxSSKeychainAccountKey = @"acct";
NSString *const kBxSSKeychainCreatedAtKey = @"cdat";
NSString *const kBxSSKeychainClassKey = @"labl";
NSString *const kBxSSKeychainDescriptionKey = @"desc";
NSString *const kBxSSKeychainLabelKey = @"labl";
NSString *const kBxSSKeychainLastModifiedKey = @"mdat";
NSString *const kBxSSKeychainWhereKey = @"svce";

#if __IPHONE_4_0 && TARGET_OS_IPHONE
	static CFTypeRef BxSSKeychainAccessibilityType = NULL;
#endif

static BOOL allowSync = NO;

@implementation BxSSKeychain


+ (NSString *)passwordForService:(NSString *)serviceName account:(NSString *)account error:(NSError *__autoreleasing *)error {
	BxSSKeychainQuery *query = [[BxSSKeychainQuery alloc] init];
	query.service = serviceName;
	query.account = account;
	[query fetch:error];
	return query.password;
}

+ (NSString *)passwordForService:(NSString *)serviceName account:(NSString *)account {
	return [self passwordForService:serviceName account:account error:nil];
}

+ (NSData *)passwordDataForService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error {
    BxSSKeychainQuery *query = [[BxSSKeychainQuery alloc] init];
    query.service = serviceName;
    query.account = account;
    [query fetch:error];
    return query.passwordData;
}

+ (BOOL)deletePasswordForService:(NSString *)serviceName account:(NSString *)account {
	return [self deletePasswordForService:serviceName account:account error:nil];
}

+ (BOOL)deletePasswordForService:(NSString *)serviceName account:(NSString *)account error:(NSError *__autoreleasing *)error {
	BxSSKeychainQuery *query = [[BxSSKeychainQuery alloc] init];
	query.service = serviceName;
	query.account = account;
	return [query deleteItem:error];
}


+ (BOOL)setPassword:(NSString *)password forService:(NSString *)serviceName account:(NSString *)account error:(NSError *__autoreleasing *)error {
	BxSSKeychainQuery *query = [[BxSSKeychainQuery alloc] init];
	query.service = serviceName;
	query.account = account;
	query.password = password;
	return [query save:error];
}

+ (BOOL)setPasswordData:(NSData *)password forService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error {
    BxSSKeychainQuery *query = [[BxSSKeychainQuery alloc] init];
    query.service = serviceName;
    query.account = account;
    query.passwordData = password;
    if(allowSync){
        query.synchronizationMode = BxSSKeychainQuerySynchronizationModeNo;
    }else{
        query.synchronizationMode = BxSSKeychainQuerySynchronizationModeYes;
    }

    return [query save:error];
}


+ (NSArray *)accountsForService:(NSString *)serviceName {
	BxSSKeychainQuery *query = [[BxSSKeychainQuery alloc] init];
	query.service = serviceName;
	return [query fetchAll:nil];
}

+ (void) allowSync:(BOOL)value
{
    allowSync = value;
}

#if __IPHONE_4_0 && TARGET_OS_IPHONE
+ (CFTypeRef)accessibilityType {

    if (!BxSSKeychainAccessibilityType) {
            BxSSKeychainAccessibilityType = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly;
     }

	return BxSSKeychainAccessibilityType;
}


+ (void)setAccessibilityType:(CFTypeRef)accessibilityType {
	CFRetain(accessibilityType);
	if (BxSSKeychainAccessibilityType) {
		CFRelease(BxSSKeychainAccessibilityType);
	}
	BxSSKeychainAccessibilityType = accessibilityType;
}
#endif

@end
