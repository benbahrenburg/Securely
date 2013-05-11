/**
 * Securely Titanium Security Project
 * Copyright (c) 2009-2013 by Benjamin Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import <Foundation/Foundation.h>

@interface BCXCryptoUtilities : NSObject

+(NSString*)base64forData:(NSData*)theData;
+(NSString*)getNormalizedPath:(NSString*)source;
+(NSString *) hexStringtoString:(NSString *)hexString;
+(NSString *) stringToHex:(NSString *)str;
+(NSData *)dataFromHexString:(NSString *)string;
+(NSData *) randomByLength:(int)charLength;
+(NSString *) randomString:(int)len;
+(NSString *) encodeDataPBKtoString: (NSData *) data ofLength: (SInt32) len;

@end
