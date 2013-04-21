//
//  PDKeychainBindings.h
//  PDKeychainBindingsController
//
//  Created by Carl Brown on 7/10/11.
//  Copyright 2011 PDAgent, LLC. Released under MIT License.
//

#import <Foundation/Foundation.h>

@interface BCXPDKeychainBindings : NSObject {
@private
    
}

+ (BCXPDKeychainBindings *)sharedKeychainBindings;

- (void) setServiceName:(NSString*)newValue;
- (void) setAccessGroup:(NSString*)newValue;

- (BOOL)boolForKey:(NSString *)defaultName;
- (double)doubleForKey:(NSString *)defaultName;
- (NSInteger)integerForKey:(NSString *)defaultName;
- (id)objectForKey:(NSString *)defaultName;
- (void)setObject:(NSString *)value forKey:(NSString *)defaultName;
- (void)setString:(NSString *)value forKey:(NSString *)defaultName;
- (void)removeObjectForKey:(NSString *)defaultName;

- (NSString *)stringForKey:(NSString *)defaultName;
-(void) removeAllItems;
- (NSArray *)allKeys;

@end
