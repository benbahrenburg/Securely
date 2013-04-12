//
//  CPCryptController.h
//  CryptPic
//
//  Created by Rob Napier on 8/9/11.
//  Copyright (c) 2011 Rob Napier. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
  kEncryptionModeDisk = 0,
  kEncryptionModeMemory
} CPEncryptionMode;


@interface CPCryptController : NSObject

+ (CPCryptController *)sharedController;
@property (strong, nonatomic) NSData *encryptedData;
@property (strong, nonatomic) NSData *iv;
@property (strong, nonatomic) NSData *salt;
@property (assign, nonatomic) CPEncryptionMode encryptionMode;

- (BOOL)decryptWithPassword:(NSString *)inputFilePath withOutputFilePath:(NSString *)outputFilePath
                   password:(NSString *)password error:(NSError **)error;
- (BOOL)encryptWithPassword:(NSString *)inputFilePath withOutputFilePath:(NSString *)outputFilePath
                   password:(NSString *)password error:(NSError **)error;
@end
