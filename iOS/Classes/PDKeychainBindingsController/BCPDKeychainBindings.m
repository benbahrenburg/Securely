//
//  PDKeychainBindings.m
//  PDKeychainBindings
//
//  Created by Carl Brown on 7/10/11.
//  Copyright 2011 PDAgent, LLC. Released under MIT License.
//

#import "BCPDKeychainBindings.h"
#import "BCPDKeychainBindingsController.h"


@implementation BCPDKeychainBindings



+ (BCPDKeychainBindings *)sharedKeychainBindings
{
	return [[BCPDKeychainBindingsController sharedKeychainBindingsController] keychainBindings];
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
    [[BCPDKeychainBindingsController sharedKeychainBindingsController] removeAllItems];
}

- (NSMutableArray *)allKeys{
    [[BCPDKeychainBindingsController sharedKeychainBindingsController] allKeys];
}

- (void) setServiceName:(NSString*)newValue{
    [[BCPDKeychainBindingsController sharedKeychainBindingsController] setServiceName:newValue];
}

- (void) setAccessGroup:(NSString*)newValue{
    [[BCPDKeychainBindingsController sharedKeychainBindingsController] setAccessGroup:newValue];
}

- (BOOL)boolForKey:(NSString *)defaultName{
    id obj =[[BCPDKeychainBindingsController sharedKeychainBindingsController] stringForKey:defaultName];
    return obj ? [obj boolValue] : 0;
}

- (double)doubleForKey:(NSString *)defaultName{
    id obj =[[BCPDKeychainBindingsController sharedKeychainBindingsController] stringForKey:defaultName];
    return obj ? [obj doubleValue] : 0;
}

- (NSInteger)integerForKey:(NSString *)defaultName{
    id obj =[[BCPDKeychainBindingsController sharedKeychainBindingsController] stringForKey:defaultName];
    return obj ? [obj intValue] : 0;
}

- (id)objectForKey:(NSString *)defaultName {
    //return [[[PDKeychainBindingsController sharedKeychainBindingsController] valueBuffer] objectForKey:defaultName];
    return [[BCPDKeychainBindingsController sharedKeychainBindingsController] valueForKeyPath:[NSString stringWithFormat:@"values.%@",defaultName]];
}

- (void)setObject:(NSString *)value forKey:(NSString *)defaultName {
    [[BCPDKeychainBindingsController sharedKeychainBindingsController] setValue:value forKeyPath:[NSString stringWithFormat:@"values.%@",defaultName]];
}

- (void)setString:(NSString *)value forKey:(NSString *)defaultName {
    [[BCPDKeychainBindingsController sharedKeychainBindingsController] setValue:value forKeyPath:[NSString stringWithFormat:@"values.%@",defaultName]];
}

- (void)removeObjectForKey:(NSString *)defaultName {
    [[BCPDKeychainBindingsController sharedKeychainBindingsController] setValue:nil forKeyPath:[NSString stringWithFormat:@"values.%@",defaultName]];
}


- (NSString *)stringForKey:(NSString *)defaultName {
    return (NSString *) [self objectForKey:defaultName];
}

@end
