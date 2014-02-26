/**
 * Securely Titanium Security Project
 * Copyright (c) 2009-2013 by Benjamin Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import <Foundation/Foundation.h>

#define BCXENCRYPT_ALGORITHM     kCCAlgorithmAES128
#define BCXENCRYPT_BLOCK_SIZE    kCCBlockSizeAES128
#define BCXENCRYPT_KEY_SIZE      kCCKeySizeAES256

@interface BCXCryptoUtilities : NSObject

+(NSString*)base64forData:(NSData*)theData;
+(NSData *)base64DataFromString: (NSString *)string;
+(NSString*)getNormalizedPath:(NSString*)source;
+(BOOL)fileIsValid:(NSString*)path;
+(NSString *) hexStringtoString:(NSString *)hexString;
+(NSString *) stringToHex:(NSString *)str;
+(NSData *)dataFromHexString:(NSString *)string;
+(NSData *) randomByLength:(int)charLength;
+(NSString *) randomString:(int)len;
+(NSString *) encodeDataPBKtoString: (NSData *) data ofLength: (SInt32) len;
+ (NSData*)encryptData:(NSData*)data key:(NSData*)key iv:(NSData*)iv;
+ (NSData*)decryptData:(NSData*)data key:(NSData*)key iv:(NSData*)iv;
@end
