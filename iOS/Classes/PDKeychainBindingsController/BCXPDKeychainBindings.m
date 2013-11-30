//
//  PDKeychainBindings.m
//  PDKeychainBindings
//
//  Created by Carl Brown on 7/10/11.
//  Copyright 2011 PDAgent, LLC. Released under MIT License.
//

#import "BCXPDKeychainBindings.h"
#import "BCXPDKeychainBindingsController.h"


@implementation BCXPDKeychainBindings



+ (BCXPDKeychainBindings *)sharedKeychainBindings
{
	return [[BCXPDKeychainBindingsController sharedKeychainBindingsController] keychainBindings];
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}


-(void) removeAllItems{
    [[BCXPDKeychainBindingsController sharedKeychainBindingsController] removeAllItems];
}

- (NSMutableArray *)allKeys{
    [[BCXPDKeychainBindingsController sharedKeychainBindingsController] allKeys];
}

- (void) setServiceName:(NSString*)newValue{
    [[BCXPDKeychainBindingsController sharedKeychainBindingsController] setServiceName:newValue];
}

- (void) setAccessGroup:(NSString*)newValue{
    [[BCXPDKeychainBindingsController sharedKeychainBindingsController] setAccessGroup:newValue];
}

- (BOOL)boolForKey:(NSString *)defaultName{
    id obj =[[BCXPDKeychainBindingsController sharedKeychainBindingsController] stringForKey:defaultName];
    return obj ? [obj boolValue] : 0;
}

- (double)doubleForKey:(NSString *)defaultName{
    id obj =[[BCXPDKeychainBindingsController sharedKeychainBindingsController] stringForKey:defaultName];
    return obj ? [obj doubleValue] : 0;
}

- (NSInteger)integerForKey:(NSString *)defaultName{
    id obj =[[BCXPDKeychainBindingsController sharedKeychainBindingsController] stringForKey:defaultName];
    return obj ? [obj intValue] : 0;
}

- (id)objectForKey:(NSString *)defaultName {
    //return [[[PDKeychainBindingsController sharedKeychainBindingsController] valueBuffer] objectForKey:defaultName];
    return [[BCXPDKeychainBindingsController sharedKeychainBindingsController] valueForKeyPath:[NSString stringWithFormat:@"values.%@",defaultName]];
}

- (void)setObject:(NSString *)value forKey:(NSString *)defaultName {
    [[BCXPDKeychainBindingsController sharedKeychainBindingsController] setValue:value forKeyPath:[NSString stringWithFormat:@"values.%@",defaultName]];
}

- (void)setString:(NSString *)value forKey:(NSString *)defaultName {
    [[BCXPDKeychainBindingsController sharedKeychainBindingsController] setValue:value forKeyPath:[NSString stringWithFormat:@"values.%@",defaultName]];
}

- (void)removeObjectForKey:(NSString *)defaultName {
    [[BCXPDKeychainBindingsController sharedKeychainBindingsController] setValue:nil forKeyPath:[NSString stringWithFormat:@"values.%@",defaultName]];
}


- (NSString *)stringForKey:(NSString *)defaultName {
    return (NSString *) [self objectForKey:defaultName];
}

@end
