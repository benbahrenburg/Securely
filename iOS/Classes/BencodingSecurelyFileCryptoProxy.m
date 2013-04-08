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
    
    if (![args objectForKey:@"secret"]) {
		NSLog(@"[ERROR] decrypt secret is required");
		return;
	}
    NSString* secret = [args objectForKey:@"secret"];
    BOOL deleteSource = [TiUtils boolValue:[args objectForKey:@"deleteSource"] def:NO];
    NSString* fileEncryptedFile = [args objectForKey:@"from"];
	NSString* sourceFile = [self getNormalizedPath:fileEncryptedFile];
    
    if (sourceFile == nil) {
		NSLog(@"[ERROR] %@",[NSString stringWithFormat:@"Invalid encrypted file path provided [%@]", sourceFile]);
		return;
	}
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:sourceFile]){
 		NSLog(@"[ERROR] %@",[NSString stringWithFormat:@"Invalid encrypted file path provided [%@]", sourceFile]);
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
        NSError *error;
        BOOL deleted = [[NSFileManager defaultManager] removeItemAtPath:outputFile error:&error];
        if (!deleted) NSLog(@"Error: %@", [error localizedDescription]);
    }
    
    if (![args objectForKey:@"completed"]) {
		NSLog(@"[ERROR] completed callback method is required");
		return;
	}
    
    KrollCallback *callback = [[args objectForKey:@"completed"] retain];
	ENSURE_TYPE(callback,KrollCallback);

    NSMutableDictionary *event = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  outputFile,@"to",
                                  sourceFile,@"from",
                                  nil];
    
    // Make sure that this number is larger than the header + 1 block.
    // 33+16 bytes = 49 bytes. So it shouldn't be a problem.
    int blockSize = 32 * 1024;
    __block NSError *decryptionError = nil;
    
    NSInputStream *inputStream = [NSInputStream inputStreamWithFileAtPath:sourceFile];
    [inputStream open];
    NSOutputStream *outputStream = [NSOutputStream outputStreamToFileAtPath:outputFile append:NO];
    [outputStream open];
    
    __block dispatch_semaphore_t sem = dispatch_semaphore_create(0);  
    __block RNDecryptor *decryptor;
    __block NSMutableData *buffer = [NSMutableData dataWithLength:blockSize];

    dispatch_block_t readStreamBlock = ^{
        [buffer setLength:blockSize];
        NSInteger bytesRead = [inputStream read:[buffer mutableBytes] maxLength:blockSize];
        if (bytesRead < 0) {
            NSLog(@"[Error] reading block:%@", inputStream.streamError);
            [inputStream close];
            dispatch_semaphore_signal(sem);
        }
        else if (bytesRead == 0) {
            [inputStream close];
            [decryptor finish];
        }
        else {
            [buffer setLength:bytesRead];
            [decryptor addData:buffer];
            NSLog(@"[Debug] Sent %ld bytes to decryptor", (unsigned long)bytesRead);
        }
    };

    decryptor = [[RNDecryptor alloc] initWithPassword:secret handler:^(RNCryptor *cryptor, NSData *data) {
        NSLog(@"[Debug] Received %d bytes", data.length);
        [outputStream write:data.bytes maxLength:data.length];
        if (cryptor.isFinished) {
            [outputStream close];
            dispatch_semaphore_signal(sem);
        }
        else {
            readStreamBlock();
        }  }];
    
    readStreamBlock();
    
    long timedout = dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC));
    
    if(timedout){
        [event setObject:NUMBOOL(NO) forKey:@"success"];
        [event setObject:@"process timed out" forKey:@"message"];
    }else{
        if(decryptionError!=nil){
            [event setObject:NUMBOOL(NO) forKey:@"success"];
            [event setObject:[NSString stringWithFormat:@"Decrypt error: %@", decryptionError]
                      forKey:@"message"];

        }else{
            //Retrieve the decrypted data
            NSData *decryptedData = [outputStream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
            if([decryptedData length] == 0){
                [event setObject:NUMBOOL(NO) forKey:@"success"];
                [event setObject:@"Failed to decrypt" forKey:@"message"];
            }else{
                [event setObject:NUMBOOL(YES) forKey:@"success"];
            }
        }
    }
    
    if(deleteSource){
        if([[NSFileManager defaultManager] fileExistsAtPath:sourceFile]){
            NSLog(@"[Debug] Removing source file");
            NSError *error;
            BOOL deleted = [[NSFileManager defaultManager] removeItemAtPath:sourceFile error:&error];
            if (!deleted) NSLog(@"Error: %@", [error localizedDescription]);
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

    if (![args objectForKey:@"secret"]) {
		NSLog(@"[ERROR] encryption secret is required");
		return;
	}
    NSString* secret = [args objectForKey:@"secret"];
    BOOL deleteSource = [TiUtils boolValue:[args objectForKey:@"deleteSource"] def:NO];
    NSString* filePlainFile = [args objectForKey:@"from"];
	NSString* sourceFile = [self getNormalizedPath:filePlainFile];

    if (sourceFile == nil) {
		NSLog(@"[ERROR] %@",[NSString stringWithFormat:@"Invalid source file path provided [%@]", sourceFile]);
		return;
	}
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:sourceFile]){
 		NSLog(@"[ERROR] %@",[NSString stringWithFormat:@"Invalid source file path provided [%@]", sourceFile]);
		return;
    }
    
    NSString* fileEncryptedFile = [args objectForKey:@"to"];
	NSString* outputFile = [self getNormalizedPath:fileEncryptedFile];

    if (outputFile == nil) {
		NSLog(@"[ERROR] %@",[NSString stringWithFormat:@"Invalid encryption file path provided [%@]", outputFile]);
		return;
	}

    if([[NSFileManager defaultManager] fileExistsAtPath:outputFile]){
        NSLog(@"[Debug] Output file already exists, removing");
        NSError *error;
        BOOL deleted = [[NSFileManager defaultManager] removeItemAtPath:outputFile error:&error];
        if (!deleted) NSLog(@"Error: %@", [error localizedDescription]);
    }
    if (![args objectForKey:@"completed"]) {
		NSLog(@"[ERROR] completed callback method is required");
		return;
	}
    
    KrollCallback *callback = [[args objectForKey:@"completed"] retain];
	ENSURE_TYPE(callback,KrollCallback);
 
    NSMutableDictionary *event = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  outputFile,@"to",
                                  sourceFile,@"from",
                                  nil];
        
    __block int total = 0;
    int blockSize = 32 * 1024;
    __block NSError *encryptionError = nil;
    
    NSInputStream *inputStream = [NSInputStream inputStreamWithFileAtPath:sourceFile];
    [inputStream open];
    __block NSOutputStream *outputStream = [NSOutputStream outputStreamToFileAtPath:outputFile append:NO];
        [outputStream open];
    
    __block dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    __block RNEncryptor *encryptor;
    __block NSMutableData *buffer = [NSMutableData dataWithLength:blockSize];
    
    dispatch_block_t readStreamBlock = ^{
        [buffer setLength:blockSize];
        NSInteger bytesRead = [inputStream read:[buffer mutableBytes] maxLength:blockSize];
        if (bytesRead < 0) {
            NSLog(@"[Error] reading block:%@", inputStream.streamError);
            [inputStream close];
            dispatch_semaphore_signal(sem);
        }
        else if (bytesRead == 0) {
            [inputStream close];
            [encryptor finish];
        }
        else {
            [buffer setLength:bytesRead];
            [encryptor addData:buffer];
            NSLog(@"[Debug] Sent %ld bytes to encryptor", (unsigned long)bytesRead);
        }
    };
        
    encryptor = [[RNEncryptor alloc] initWithSettings:kRNCryptorAES256Settings
                              password:secret
                            handler:^(RNCryptor *cryptor, NSData *data) {
        NSLog(@"[DEBUG] Received %d bytes", data.length);
        [outputStream write:data.bytes maxLength:data.length];
        if (cryptor.isFinished) {
            [outputStream close];
            dispatch_semaphore_signal(sem);
        }
        else {
            readStreamBlock();
        }  }];
    
    readStreamBlock();
    
    long timedout = dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC));
    
    if(timedout){
        [event setObject:NUMBOOL(NO) forKey:@"success"];
        [event setObject:@"process timed out" forKey:@"message"];
    }else{
        if(encryptionError!=nil){
            [event setObject:NUMBOOL(NO) forKey:@"success"];
            [event setObject:[NSString stringWithFormat:@"Encryption error: %@", encryptionError]
                      forKey:@"message"];
            
        }else{
            //Retrieve the encrypted data
            NSData *encryptedData = [outputStream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
            if([encryptedData length] == 0){
                [event setObject:NUMBOOL(NO) forKey:@"success"];
                [event setObject:@"Failed to encrypt" forKey:@"message"];
            }else{
                [event setObject:NUMBOOL(YES) forKey:@"success"];
            }
        }
    }
    
    if(deleteSource){
        if([[NSFileManager defaultManager] fileExistsAtPath:sourceFile]){
            NSLog(@"[DEBUG] Removing source file");
            NSError *error;
            BOOL deleted = [[NSFileManager defaultManager] removeItemAtPath:sourceFile error:&error];
            if (!deleted) NSLog(@"Error: %@", [error localizedDescription]);
        }
    }
    
    if(callback != nil ){
        [self _fireEventToListener:@"completed" withObject:event
                          listener:callback thisObject:nil];
        [callback autorelease];
    }
}

@end
