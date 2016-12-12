//
//  BxsskeychainBindings.h
//  Securely
//
//  Created by Ben Bahrenburg on 6/16/14.
//
//

#import <Foundation/Foundation.h>

@interface BxSSkeychainBindings : NSObject{
@private
NSString* _identifier;

}

-(id)initWithIdentifierAndOptions:(NSString *)identifier
              withAccessibleLevel:(int)SecAttrAccessible
                  withSyncAllowed:(BOOL)syncAllowed;

- (BOOL)boolForKey:(NSString *)key;
- (double)doubleForKey:(NSString *)key;
- (int)integerForKey:(NSString *)key;
- (id)objectForKey:(NSString *)key;
- (void)setString:(NSString *)value forKey:(NSString *)key;
- (void)removeObjectForKey:(NSString *)key;
- (NSString *)stringForKey:(NSString *)key;
-(void) removeAllItems;
- (NSArray *)allKeys;
@end
