//
//  BxsskeychainBindings.m
//  Securely
//
//  Created by Ben Bahrenburg on 6/16/14.
//
//

#import "BxsskeychainBindings.h"
#import "BxSSKeychain.h"
#import "BencodingSecurelyModule.h"

@implementation BxSSkeychainBindings


-(id)initWithIdentifierAndOptions:(NSString *)identifier
                 withAccessibleLevel:(int)SecAttrAccessible
                  withSyncAllowed:(BOOL)syncAllowed
{
    self = [super init];

    if (self) {
        _identifier = identifier;
        [BxSSKeychain setAccessibilityType:[self accessibilityTypeMap:SecAttrAccessible]];
        [BxSSKeychain allowSync:syncAllowed];
    }

    return self;
}

-(CFTypeRef)accessibilityTypeMap:(int)valueToMap
{
    if(valueToMap == kBCSecAttrAccessibleWhenUnlocked){
        return kSecAttrAccessibleWhenUnlocked;
    }

    if(valueToMap == kBCSecAttrAccessibleAfterFirstUnlock){
        return kSecAttrAccessibleAfterFirstUnlock;
    }

    if(valueToMap == kBCSecAttrAccessibleWhenUnlockedThisDeviceOnly){
        return kSecAttrAccessibleWhenUnlockedThisDeviceOnly;
    }

    if(valueToMap == kBCSecAttrAccessibleAfterFirstUnlockThisDeviceOnly){
        return kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly;
    }

    if(valueToMap == kBCSecAttrAccessibleAlwaysThisDeviceOnly){
        return kSecAttrAccessibleAlwaysThisDeviceOnly;
    }
    
    return kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly;

}
-(void) removeAllItems{
    NSArray *accounts = [self allKeys];
    for (int i = 0; i < accounts.count ; i++) {
        [BxSSKeychain deletePasswordForService:_identifier account:[accounts objectAtIndex:i]];
    }
}

- (NSArray *)allKeys{
    return [BxSSKeychain accountsForService:_identifier];
}

- (id)objectForKey:(NSString *)key
{
    return [BxSSKeychain passwordForService:_identifier account:key];
}

- (id)findForKey:(NSString*)key
{
    NSError *error = nil;
    NSString * value = [BxSSKeychain passwordForService:_identifier account:key error:&error];

    if (error && error.code != errSecItemNotFound) {
        NSLog(@"[ERROR] Unable to retrieve keychain value for key %@ error %@", key, error);
        return nil;
    }else{
        return value;
    }
}

- (BOOL)boolForKey:(NSString *)key{
    id obj = [self findForKey:key];
    return obj ? [obj boolValue] : 0;
}

- (double)doubleForKey:(NSString *)key{
    id obj = [self findForKey:key];
    return obj ? [obj doubleValue] : 0;
}

- (NSInteger)integerForKey:(NSString *)key{
    id obj = [self findForKey:key];
    return obj ? [obj intValue] : 0;
}

- (void)setString:(NSString *)value forKey:(NSString *)key {
    NSError *error = nil;
    BOOL success = [BxSSKeychain setPassword:value forService:_identifier account:key error:&error];
    if (!success) {
        NSLog(@"[ERROR] Unable to set value to keychain %@", error);
    }
}

- (void)removeObjectForKey:(NSString *)key {
    NSError *error = nil;
    BOOL success = [BxSSKeychain deletePasswordForService:_identifier account:key error:&error];
    if (!success) {
        NSLog(@"[ERROR] Unable to remove keychain value %@", error);
    }
}

- (NSString *)stringForKey:(NSString *)key {
    return (NSString *) [self findForKey:key];
}

@end
