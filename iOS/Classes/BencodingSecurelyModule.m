/**
 * Securely Titanium Security Project
 * Copyright (c) 2009-2013 by Benjamin Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */
#import "BencodingSecurelyModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import <CommonCrypto/CommonKeyDerivation.h>
#import "BCCryptoUtilities.h"
@implementation BencodingSecurelyModule

#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"36a465bb-c79d-4c6c-b90c-a5e14a7e817b";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"bencoding.securely";
}

#pragma mark Lifecycle

-(void)startup
{
	// this method is called when the module is first loaded
	// you *must* call the superclass
	[super startup];
	
	//NSLog(@"[INFO] %@ loaded",self);
}

-(void)shutdown:(id)sender
{
	// this method is called when the module is being unloaded
	// typically this is during shutdown. make sure you don't do too
	// much processing here or the app will be quit forceably
	
	// you *must* call the superclass
	[super shutdown:sender];
}

#pragma mark Cleanup 

-(void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
	[super dealloc];
}

#pragma mark Internal Memory Management

-(void)didReceiveMemoryWarning:(NSNotification*)notification
{
	// optionally release any resources that can be dynamically
	// reloaded once memory is available - such as caches
	[super didReceiveMemoryWarning:notification];
}


-(NSString *)generateRandomKey:(id)args
{
    int len = ([args count] > 0) ? [TiUtils intValue:[args objectAtIndex:0]] : 32;
    NSString* seed = [BCCryptoUtilities randomString:len];
    //NSLog(@"[ERROR] seed: %@", seed);
    NSString* output =  [self makeDerivedKey:seed];
    //NSLog(@"[ERROR] output: %@", output);
    return output;
}


-(NSString *) makeDerivedKey:(NSString *)seed
{
    int keySize = 32;
    NSData* myPassData = [seed dataUsingEncoding:NSUTF8StringEncoding];
    
    //Create Random SALT
    NSData* salt = [BCCryptoUtilities randomByLength:keySize];
    
    // How many rounds to use so that it takes 0.1s ?
    int rounds = CCCalibratePBKDF(kCCPBKDF2, myPassData.length, salt.length, kCCPRFHmacAlgSHA256, 32, 100);
    
    // Open CommonKeyDerivation.h for help
    unsigned char key[keySize];
    CCKeyDerivationPBKDF(kCCPBKDF2, myPassData.bytes, myPassData.length, salt.bytes, salt.length, kCCPRFHmacAlgSHA256, rounds, key, 32);
    NSData* keyData = [NSData dataWithBytes:key length:keySize];
    NSString *stringEncoded = [BCCryptoUtilities encodeDataPBKtoString:keyData ofLength:keySize];
    return stringEncoded;
}

-(NSString *)generateDerivedKey:(id)args
{
    ENSURE_ARG_COUNT(args,1);
    int keySize = 32;
    NSString* seed = [TiUtils stringValue:[args objectAtIndex:0]];
    return [self makeDerivedKey:seed];
}

-(NSNumber *) isProtectedDataAvailable:(id)unused
{
     BOOL available = [[UIApplication sharedApplication] isProtectedDataAvailable];
    
     return NUMBOOL(available);
        
}

-(void)_listenerAdded:(NSString *)type count:(int)count
{
	if (count == 1 && [type isEqualToString:@"protectedDataDidBecomeAvailable"])
	{
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(ProtectedDataDidBecomeAvailable:)
                                                     name:UIApplicationProtectedDataDidBecomeAvailable object:nil];
	}
	if (count == 1 && [type isEqualToString:@"protectedDataWillBecomeUnavailable"])
	{
        [[NSNotificationCenter defaultCenter] addObserver:self
          selector:@selector(ProtectedDataWillBecomeUnavailable:)
                   name:UIApplicationProtectedDataWillBecomeUnavailable object:nil];
	}
}

-(void)_listenerRemoved:(NSString *)type count:(int)count
{
	if (count == 0 && [type isEqualToString:@"protectedDataDidBecomeAvailable"])
	{
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIApplicationProtectedDataDidBecomeAvailable object:nil];
	}
	if (count == 0 && [type isEqualToString:@"protectedDataWillBecomeUnavailable"])
	{
        [[NSNotificationCenter defaultCenter] removeObserver:self
                        name:UIApplicationProtectedDataWillBecomeUnavailable object:nil];
	}
}

-(void)ProtectedDataDidBecomeAvailable:(NSNotification*)info
{
     if ([self _hasListeners:@"protectedDataDidBecomeAvailable"])
     {
         NSDictionary *notification = [info object];
         [self fireEvent:@"protectedDataDidBecomeAvailable" withObject:notification];
     }
}

-(void)ProtectedDataWillBecomeUnavailable:(NSNotification*)info
{
    if ([self _hasListeners:@"protectedDataWillBecomeUnavailable"])
    {
        NSDictionary *notification = [info object];
        [self fireEvent:@"protectedDataWillBecomeUnavailable" withObject:notification];
    }
}
    
@end
