//
//  BCCryptoUtilities.h
//  Securely
//
//  Created by Ben on 4/14/13.
//
//

#import <Foundation/Foundation.h>

@interface BCCryptoUtilities : NSObject

+(NSString *) hexStringtoString:(NSString *)hexString;
+(NSString *) stringToHex:(NSString *)str;
+(NSData *)dataFromHexString:(NSString *)string;
+(NSData *) randomByLength:(int)charLength;
+(NSString *) randomString:(int)len;
+(NSString *) encodeDataPBKtoString: (NSData *) data ofLength: (SInt32) len;

@end
