/**
 * Securely Titanium Security Project
 * Copyright (c) 2014 by Benjamin Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "BencodingSecurelyIVProxy.h"
#import <CommonCrypto/CommonKeyDerivation.h>
#import <CommonCrypto/CommonCryptor.h>
#import "BCXCryptoUtilities.h"
#import "TiUtils.h"

@implementation BencodingSecurelyIVProxy


-(NSString *)randomForIV:(id)args
{
    //AES block size (currently, only 128-bit blocks are supported).
    NSUInteger kAlgorithmIVSize = kCCBlockSizeAES128;

    NSMutableData *data = [NSMutableData dataWithLength:kAlgorithmIVSize];

    int result = SecRandomCopyBytes(kSecRandomDefault,
                                    kAlgorithmIVSize,
                                    data.mutableBytes);
    NSAssert(result == 0, @"Unable to generate random bytes: %d",
             errno);

    NSString *plainText = nil;

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
    plainText = [data base64EncodedStringWithOptions:0];
#else
    plainText = [data base64Encoding];
#endif

    //NSLog(@"[ERROR] plainText: %@", plainText);

    return plainText;
}

-(NSNumber*) isIVFormatValid:(NSString *)value
{
    return NUMBOOL([[BCXCryptoUtilities base64DataFromString:value] length] != kCCBlockSizeAES128);
}

@end
