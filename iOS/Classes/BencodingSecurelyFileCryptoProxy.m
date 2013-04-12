/**
 * Securely Titanium Security Project
 * Copyright (c) 2009-2013 by Benjamin Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "BencodingSecurelyFileCryptoProxy.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import "TiFile.h"
#import "TiBlob.h"
#import "TiFilesystemFileProxy.h"
#import "CPCryptController.h"
#import <CommonCrypto/CommonCryptor.h>
@implementation BencodingSecurelyFileCryptoProxy


-(NSString*)getNormalizedPath:(NSString*)source
{
	// NOTE: File paths may contain URL prefix as of release 1.7 of the SDK
	if ([source hasPrefix:@"file:/"]) {
		NSURL* url = [NSURL URLWithString:source];
		return [url path];
	}
    
	// NOTE: Here is where you can perform any other processing needed to
	// convert the source path. For example, if you need to handle
	// tilde, then add the call to stringByExpandingTildeInPath
    
	return source;
}



-(void) AESDecrypt:(id)args
{
    ENSURE_SINGLE_ARG(args,NSDictionary);
    ENSURE_TYPE(args,NSDictionary);
    
    if (![args objectForKey:@"password"]) {
		NSLog(@"[ERROR] decrypt password is required");
		return;
	}
    NSString* secret = [args objectForKey:@"password"];
    BOOL deleteSource = [TiUtils boolValue:[args objectForKey:@"deleteSource"] def:NO];
    NSString* fileEncryptedFile = [args objectForKey:@"from"];
	NSString* inputFilePath = [self getNormalizedPath:fileEncryptedFile];
    
    if (inputFilePath == nil) {
		NSLog(@"[ERROR] %@",[NSString stringWithFormat:@"Invalid encrypted file path provided [%@]", inputFilePath]);
		return;
	}
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:inputFilePath]){
 		NSLog(@"[ERROR] %@",[NSString stringWithFormat:@"Invalid encrypted file path provided [%@]", inputFilePath]);
		return;
    }
    
    NSString* fileDecryptedFile = [args objectForKey:@"to"];
	NSString* outputFile = [self getNormalizedPath:fileDecryptedFile];
    
    if (outputFile == nil) {
		NSLog(@"[ERROR] %@",[NSString stringWithFormat:@"Invalid decrypt file path provided [%@]", outputFile]);
		return;
	}
    
    if([[NSFileManager defaultManager] fileExistsAtPath:outputFile]){
        NSLog(@"[DEBUG] Output file already exists removing");
        NSError *errorD;
        BOOL deleted = [[NSFileManager defaultManager] removeItemAtPath:outputFile error:&errorD];
        if (!deleted) NSLog(@"[ERROR] %@", [errorD localizedDescription]);
    }
    
    if (![args objectForKey:@"completed"]) {
		NSLog(@"[ERROR] completed callback method is required");
		return;
	}
    
    KrollCallback *callback = [[args objectForKey:@"completed"] retain];
	ENSURE_TYPE(callback,KrollCallback);

    NSMutableDictionary *event = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  outputFile,@"to",
                                  inputFilePath,@"from",
                                  nil];
    
    NSError *error = nil;
    
    if (![[CPCryptController sharedController]
           decryptWithPassword:inputFilePath withOutputFilePath:outputFile
           password:secret error:&error] ){
        
        [event setObject:NUMBOOL(NO) forKey:@"success"];
        
        if ([error code] == kCCDecodeError) {
            NSLog(@"[ERROR] Incorrect password provided");

            [event setObject:@"Incorrect password provided" forKey:@"message"];
        }
        else {
            NSLog(@"[ERROR] Could not decrypt data: %@", error);
            [event setObject:[error localizedDescription] forKey:@"message"];
        }
        
    }else{
        [event setObject:NUMBOOL(YES) forKey:@"success"];
        if(deleteSource){
            if([[NSFileManager defaultManager] fileExistsAtPath:inputFilePath]){
                NSLog(@"[DEBUG] Removing source file");
                NSError *errorD2;
                BOOL deleted = [[NSFileManager defaultManager] removeItemAtPath:inputFilePath error:&errorD2];
                if (!deleted) NSLog(@"[ERROR] %@", [errorD2 localizedDescription]);
            }
        }
    }
    
    if(callback != nil ){
        [self _fireEventToListener:@"completed" withObject:event
                          listener:callback thisObject:nil];
        [callback autorelease];
    }
    
}
-(void) AESEncrypt:(id)args
{
    ENSURE_SINGLE_ARG(args,NSDictionary);
    ENSURE_TYPE(args,NSDictionary);

    if (![args objectForKey:@"password"]) {
		NSLog(@"[ERROR] encryption password is required");
		return;
	}
    NSString* secret = [args objectForKey:@"password"];
    BOOL deleteSource = [TiUtils boolValue:[args objectForKey:@"deleteSource"] def:NO];
    NSString* filePlainFile = [args objectForKey:@"from"];
	NSString* inputFilePath = [self getNormalizedPath:filePlainFile];

    if (inputFilePath == nil) {
		NSLog(@"[ERROR] %@",[NSString stringWithFormat:@"Invalid source file path provided [%@]", inputFilePath]);
		return;
	}
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:inputFilePath]){
 		NSLog(@"[ERROR] %@",[NSString stringWithFormat:@"Invalid source file path provided [%@]", inputFilePath]);
		return;
    }
    
    NSString* fileEncryptedFile = [args objectForKey:@"to"];
	NSString* outputFile = [self getNormalizedPath:fileEncryptedFile];

    if (outputFile == nil) {
		NSLog(@"[ERROR] %@",[NSString stringWithFormat:@"Invalid encryption file path provided [%@]", outputFile]);
		return;
	}

    if([[NSFileManager defaultManager] fileExistsAtPath:outputFile]){
        NSLog(@"[DEBUG] Output file already exists, removing");
        NSError *errorD;
        BOOL deleted = [[NSFileManager defaultManager] removeItemAtPath:outputFile error:&errorD];
        if (!deleted) NSLog(@"[ERROR] %@", [errorD localizedDescription]);
    }
    if (![args objectForKey:@"completed"]) {
		NSLog(@"[ERROR] completed callback method is required");
		return;
	}
    
    KrollCallback *callback = [[args objectForKey:@"completed"] retain];
	ENSURE_TYPE(callback,KrollCallback);
 
    NSMutableDictionary *event = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  outputFile,@"to",
                                  inputFilePath,@"from",
                                  nil];
        
    NSError *error;
    if (! [[CPCryptController sharedController]
           encryptWithPassword:inputFilePath withOutputFilePath:outputFile
                                               password:secret error:&error] )
    {
        NSLog(@"[ERROR] Could not encrypt data: %@", error);
        [event setObject:NUMBOOL(NO) forKey:@"success"];
        [event setObject:[error localizedDescription] forKey:@"message"];
    }else{
        [event setObject:NUMBOOL(YES) forKey:@"success"];
                
        if(deleteSource){
            if([[NSFileManager defaultManager] fileExistsAtPath:inputFilePath]){
                NSLog(@"[DEBUG] Removing source file");
                NSError *errorD2;
                BOOL deleted = [[NSFileManager defaultManager] removeItemAtPath:inputFilePath error:&errorD2];
                if (!deleted) NSLog(@"[ERROR] %@", [errorD2 localizedDescription]);
            }
        }    
    }
    
    if(callback != nil ){
        [self _fireEventToListener:@"completed" withObject:event
                          listener:callback thisObject:nil];
        [callback autorelease];
    }
}

@end
