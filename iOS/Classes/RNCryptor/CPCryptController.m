//
//  CPCryptController.m
//  CryptPic
//
//  Created by Rob Napier on 8/9/11.
//  Copyright (c) 2011 Rob Napier. All rights reserved.
//

#import "CPCryptController.h"
#import "RNCryptManager.h"

static NSString * const kModeKey = @"mode";

@implementation CPCryptController
@synthesize encryptedData=encryptedData_;
@synthesize iv=iv_;
@synthesize salt=salt_;
@synthesize encryptionMode=encryptionMode_;

+ (CPCryptController *)sharedController {
  static CPCryptController *sSharedController;
  if (! sSharedController) {
    sSharedController = [[CPCryptController alloc] init];
  }
  return sSharedController;
}

- (BOOL)encryptDataInMemory:(NSData *)data password:(NSString *)password error:(NSError **)error {
  NSData *iv;
  NSData *salt;
  self.encryptedData = [RNCryptManager encryptedDataForData:data password:password iv:&iv salt:&salt error:error];
  self.iv = iv;
  self.salt = salt;
  return self.encryptedData ? YES : NO;
}


- (BOOL)encryptDataWithStream:(NSString *)inputFilePath withOutputFilePath:(NSString *)outputFilePath
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


- (BOOL)encryptWithPassword:(NSString *)inputFilePath withOutputFilePath:(NSString *)outputFilePath
           password:(NSString *)password error:(NSError **)error
{
    return [self encryptDataWithStream:inputFilePath
                    withOutputFilePath:outputFilePath password:password error:error];
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


@end
