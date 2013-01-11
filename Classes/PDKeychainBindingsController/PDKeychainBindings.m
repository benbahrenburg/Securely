//
//  PDKeychainBindings.m
//  PDKeychainBindings
//
//  Created by Carl Brown on 7/10/11.
//  Copyright 2011 PDAgent, LLC. Released under MIT License.
//

#import "PDKeychainBindings.h"
#import "PDKeychainBindingsController.h"


@implementation PDKeychainBindings



+ (PDKeychainBindings *)sharedKeychainBindings
{
	return [[PDKeychainBindingsController sharedKeychainBindingsController] keychainBindings];
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

-(void) removeAllItems{
    [[PDKeychainBindingsController sharedKeychainBindingsController] removeAllItems];
}

- (NSMutableArray *)allKeys{
    [[PDKeychainBindingsController sharedKeychainBindingsController] allKeys];
}

- (void) setServiceName:(NSString*)newValue{
    [[PDKeychainBindingsController sharedKeychainBindingsController] setServiceName:newValue];
}

- (void) setAccessGroup:(NSString*)newValue{
    [[PDKeychainBindingsController sharedKeychainBindingsController] setAccessGroup:newValue];
}

- (BOOL)boolForKey:(NSString *)defaultName{
    id obj =[[PDKeychainBindingsController sharedKeychainBindingsController] stringForKey:defaultName];
    return obj ? [obj boolValue] : 0;
}

- (double)doubleForKey:(NSString *)defaultName{
    id obj =[[PDKeychainBindingsController sharedKeychainBindingsController] stringForKey:defaultName];
    return obj ? [obj doubleValue] : 0;
}

- (NSInteger)integerForKey:(NSString *)defaultName{
    id obj =[[PDKeychainBindingsController sharedKeychainBindingsController] stringForKey:defaultName];
    return obj ? [obj intValue] : 0;
}

- (id)objectForKey:(NSString *)defaultName {
    //return [[[PDKeychainBindingsController sharedKeychainBindingsController] valueBuffer] objectForKey:defaultName];
    return [[PDKeychainBindingsController sharedKeychainBindingsController] valueForKeyPath:[NSString stringWithFormat:@"values.%@",defaultName]];
}

- (void)setObject:(NSString *)value forKey:(NSString *)defaultName {
    [[PDKeychainBindingsController sharedKeychainBindingsController] setValue:value forKeyPath:[NSString stringWithFormat:@"values.%@",defaultName]];
}

- (void)setString:(NSString *)value forKey:(NSString *)defaultName {
    [[PDKeychainBindingsController sharedKeychainBindingsController] setValue:value forKeyPath:[NSString stringWithFormat:@"values.%@",defaultName]];
}

- (void)removeObjectForKey:(NSString *)defaultName {
    [[PDKeychainBindingsController sharedKeychainBindingsController] setValue:nil forKeyPath:[NSString stringWithFormat:@"values.%@",defaultName]];
}


- (NSString *)stringForKey:(NSString *)defaultName {
    return (NSString *) [self objectForKey:defaultName];
}

@end
