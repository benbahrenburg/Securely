/**
 * Securely Titanium Security Project
 * Copyright (c) 2014 by Benjamin Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "BencodingSecurelyFileCryptoProxy.h"
#import "TiUtils.h"
#import "RNCryptManager.h"
#import "BCXCryptoUtilities.h"
@implementation BencodingSecurelyFileCryptoProxy

- (BOOL)encryptDataWithPassword:(NSString *)inputFilePath withOutputFilePath:(NSString *)outputFilePath
                     password:(NSString *)password error:(NSError **)error {
    
    NSInputStream *inputStream = [NSInputStream inputStreamWithFileAtPath:inputFilePath];
    [inputStream open];
    
    NSOutputStream *outputStream = [NSOutputStream outputStreamToFileAtPath:outputFilePath
                                                                     append:NO];
    [outputStream open];
    
    BOOL result = [RNCryptManager encryptFromStream:inputStream
                                           toStream:outputStream
                                           password:password
                                              error:error];
    [inputStream close];
    [outputStream close];
    return result;
}

- (BOOL)decryptWithPassword:(NSString *)inputFilePath withOutputFilePath:(NSString *)outputFilePath
                   password:(NSString *)password error:(NSError **)error
{
    NSInputStream *inStream = [NSInputStream inputStreamWithFileAtPath:inputFilePath];
    [inStream open];
    
    NSOutputStream *outStream = [NSOutputStream outputStreamToMemory];
    [outStream open];
    
    BOOL success = [RNCryptManager decryptFromStream:inStream toStream:outStream
                                            password:password error:error];
    
    if (success) {
        //NSLog(@"[DEBUG] RNCryptManager returned true");
        NSData *data = [outStream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
        if([data length]>0)
        {
            NSError *writeError = nil;
            [data writeToFile:outputFilePath options:NSDataWritingFileProtectionComplete | NSDataWritingAtomic error:&writeError];
            
            //NSLog(@"[DEBUG] Error writing file");
            
            if(writeError != nil) {
                success = NO;
            }
            if (error != NULL) *error = writeError;
        }else{
            success = NO;
            if (error != NULL) *error = [NSError errorWithDomain:@"bencoding.securely"
                                                            code:100
                                                        userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"unable to decrypt file, check if password is correct  at %@", inputFilePath]  forKey:NSLocalizedDescriptionKey]];
            
        }
    }else{
        NSLog(@"[DEBUG] Encryption provider returned false");
    }
    
    [inStream close];
    [outStream close];
    
    return success;
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
	NSString* inputFilePath = [BCXCryptoUtilities getNormalizedPath:fileEncryptedFile];
    
    if (inputFilePath == nil) {
		NSLog(@"[ERROR] %@",[NSString stringWithFormat:@"Invalid encrypted file path provided [%@]", inputFilePath]);
		return;
	}
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:inputFilePath]){
 		NSLog(@"[ERROR] %@",[NSString stringWithFormat:@"Invalid encrypted file path provided [%@]", inputFilePath]);
		return;
    }
    
    NSString* fileDecryptedFile = [args objectForKey:@"to"];
	NSString* outputFile = [BCXCryptoUtilities getNormalizedPath:fileDecryptedFile];
    
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
    
    KrollCallback *callback = [args objectForKey:@"completed"];
	ENSURE_TYPE(callback,KrollCallback);

    NSMutableDictionary *event = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  outputFile,@"to",
                                  inputFilePath,@"from",
                                  nil];
    
    NSError *error = nil;
    
    if (![self decryptWithPassword:inputFilePath
                 withOutputFilePath:outputFile
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
                if(![[NSFileManager defaultManager] isDeletableFileAtPath:inputFilePath]){
                    NSLog(@"[ERROR] Unable to remove input file");
                }else{
                    NSLog(@"[DEBUG] Removing source file");
                    NSError *errorD2;
                    BOOL deleted = [[NSFileManager defaultManager] removeItemAtPath:inputFilePath error:&errorD2];
                    if (!deleted) NSLog(@"[ERROR] %@", [errorD2 localizedDescription]);
                }
            }
        }
    }
    
    if(callback != nil ){
        [self _fireEventToListener:@"completed" withObject:event
                          listener:callback thisObject:nil];
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
	NSString* inputFilePath = [BCXCryptoUtilities getNormalizedPath:filePlainFile];

    if (inputFilePath == nil) {
		NSLog(@"[ERROR] %@",[NSString stringWithFormat:@"Invalid source file path provided [%@]", inputFilePath]);
		return;
	}
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:inputFilePath]){
 		NSLog(@"[ERROR] %@",[NSString stringWithFormat:@"Invalid source file path provided [%@]", inputFilePath]);
		return;
    }
    
    NSString* fileEncryptedFile = [args objectForKey:@"to"];
	NSString* outputFile = [BCXCryptoUtilities getNormalizedPath:fileEncryptedFile];

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
    
    KrollCallback *callback = [args objectForKey:@"completed"];
	ENSURE_TYPE(callback,KrollCallback);
 
    NSMutableDictionary *event = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  outputFile,@"to",
                                  inputFilePath,@"from",
                                  nil];
        
    NSError *error;
    if (![self encryptDataWithPassword:inputFilePath
                   withOutputFilePath:outputFile
                   password:secret error:&error] )
    {
        NSLog(@"[ERROR] Could not encrypt data: %@", error);
        [event setObject:NUMBOOL(NO) forKey:@"success"];
        [event setObject:[error localizedDescription] forKey:@"message"];
    }else{
        [event setObject:NUMBOOL(YES) forKey:@"success"];
                
        if(deleteSource){
            if([[NSFileManager defaultManager] fileExistsAtPath:inputFilePath]){
                if(![[NSFileManager defaultManager] isDeletableFileAtPath:inputFilePath]){
                    NSLog(@"[ERROR] Unable to remove input file");
                }else{
                    NSLog(@"[DEBUG] Removing source file");
                    NSError *errorD2;
                    BOOL deleted = [[NSFileManager defaultManager] removeItemAtPath:inputFilePath error:&errorD2];
                    if (!deleted) NSLog(@"[ERROR] %@", [errorD2 localizedDescription]);
                }
            }
        }    
    }
    
    if(callback != nil ){
        [self _fireEventToListener:@"completed" withObject:event
                          listener:callback thisObject:nil];
    }
}

@end
