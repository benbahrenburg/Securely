/**
 * Securely Titanium Security Project
 * Copyright (c) 2009-2013 by Benjamin Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "BCXCryptoUtilities.h"
#import <CommonCrypto/CommonCryptor.h>

@implementation BCXCryptoUtilities

NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

+(NSString*)base64forData:(NSData*)theData
{
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
}

+(NSString*)getNormalizedPath:(NSString*)source
{
	// NOTE: File paths may contain URL prefix as of release 1.7 of the SDK
	if ([source hasPrefix:@"file:/"]) {
		NSURL* url = [NSURL URLWithString:source];
		return [url path];
	}
    
	return source;
}

+(NSString *) hexStringtoString:(NSString *)hexString
{
    NSMutableString * newString = [[[NSMutableString alloc] init] autorelease];
    int i = 0;
    while (i < [hexString length])
    {
        NSString * hexChar = [hexString substringWithRange: NSMakeRange(i, 2)];
        int value = 0;
        sscanf([hexChar cStringUsingEncoding:NSASCIIStringEncoding], "%x", &value);
        [newString appendFormat:@"%c", (char)value];
        i+=2;
    }
    return newString;
}

+(NSString *) stringToHex:(NSString *)str
{
    NSUInteger len = [str length];
    unichar *chars = malloc(len * sizeof(unichar));
    [str getCharacters:chars];
    
    NSMutableString *hexString = [[NSMutableString alloc] init];
    
    for(NSUInteger i = 0; i < len; i++ )
    {
        [hexString appendFormat:@"%02x", chars[i]]; 
    }
    free(chars);
    
    return [hexString autorelease];
}

+(NSData *)dataFromHexString:(NSString *)string
{
    string = [string lowercaseString];
    NSMutableData *data= [NSMutableData new];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    int i = 0;
    int length = string.length;
    while (i < length-1) {
        char c = [string characterAtIndex:i++];
        if (c < '0' || (c > '9' && c < 'a') || c > 'f')
            continue;
        byte_chars[0] = c;
        byte_chars[1] = [string characterAtIndex:i++];
        whole_byte = strtol(byte_chars, NULL, 16);
        [data appendBytes:&whole_byte length:1];
        
    }
    
    return [data autorelease];
}

+(NSData *) randomByLength:(int)charLength
{
    char data[charLength];
    for (int x=0;x<charLength;data[x++] = (char)('A' + (arc4random_uniform(26))));
    return [NSData dataWithBytes:(const void *)data length:sizeof(unsigned char)*charLength];
}

+(NSString *) randomString:(int)len
{
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    return randomString;
}

+(NSString *) encodeDataPBKtoString: (NSData *) data ofLength: (SInt32) len
{
    
	if (data == nil) {
		// Invalid data so return nil.
		return nil;
	}
    
    // Table for Base64 encoding
    NSString *base64_code[] = {
        @".", @"/", @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J",
        @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V",
        @"W", @"X", @"Y", @"Z", @"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h",
        @"i", @"j", @"k", @"l", @"m", @"n", @"o", @"p", @"q", @"r", @"s", @"t",
        @"u", @"v", @"w", @"x", @"y", @"z", @"0", @"1", @"2", @"3", @"4", @"5",
        @"6", @"7", @"8", @"9"
    };
	SInt32 off = 0;
	NSMutableString *rs = [NSMutableString stringWithCapacity: 100];
	SInt32 c1, c2;
    
	if (len <= 0 || len > [data length]) {
		// Invalid length
		return nil;
	}
    
	signed char *d = (signed char *) [data bytes];
    
	while (off < len) {
		c1 = d[off++] & 0xff;
		[rs appendString: base64_code[(c1 >> 2) & 0x3f]];
		c1 = (c1 & 0x03) << 4;
		if (off >= len) {
			[rs appendString: base64_code[c1 & 0x3f]];
			break;
		}
		c2 = d[off++] & 0xff;
		c1 |= (c2 >> 4) & 0x0f;
		[rs appendString: base64_code[c1 & 0x3f]];
		c1 = (c2 & 0x0f) << 2;
		if (off >= len) {
			[rs appendString: base64_code[c1 & 0x3f]];
			break;
		}
		c2 = d[off++] & 0xff;
		c1 |= (c2 >> 6) & 0x03;
		[rs appendString: base64_code[c1 & 0x3f]];
		[rs appendString: base64_code[c2 & 0x3f]];
	}
    
	return rs;
}

//METHODS MODIFIED FROM https://github.com/dev5tec/FBEncryptor
+ (NSData*)encryptData:(NSData*)data key:(NSData*)key iv:(NSData*)iv;
{
    NSData* result = nil;
    
    // setup key
    unsigned char cKey[BCXENCRYPT_KEY_SIZE];
	bzero(cKey, sizeof(cKey));
    [key getBytes:cKey length:BCXENCRYPT_KEY_SIZE];
	
    // setup iv
    char cIv[BCXENCRYPT_BLOCK_SIZE];
    bzero(cIv, BCXENCRYPT_BLOCK_SIZE);
    if (iv) {
        [iv getBytes:cIv length:BCXENCRYPT_BLOCK_SIZE];
    }
    
    // setup output buffer
	size_t bufferSize = [data length] + BCXENCRYPT_BLOCK_SIZE;
	void *buffer = malloc(bufferSize);
    
    // do encrypt
	size_t encryptedSize = 0;
	CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          BCXENCRYPT_ALGORITHM,
                                          kCCOptionPKCS7Padding,
                                          cKey,
                                          BCXENCRYPT_KEY_SIZE,
                                          cIv,
                                          [data bytes],
                                          [data length],
                                          buffer,
                                          bufferSize,
										  &encryptedSize);
	if (cryptStatus == kCCSuccess) {
		result = [NSData dataWithBytesNoCopy:buffer length:encryptedSize];
	} else {
        free(buffer);
        NSLog(@"[ERROR] failed to encrypt|CCCryptoStatus: %d", cryptStatus);
    }
	
	return result;
}

//METHODS MODIFIED FROM https://github.com/dev5tec/FBEncryptor
+ (NSData*)decryptData:(NSData*)data key:(NSData*)key iv:(NSData*)iv;
{
    NSData* result = nil;
    
    // setup key
    unsigned char cKey[BCXENCRYPT_KEY_SIZE];
	bzero(cKey, sizeof(cKey));
    [key getBytes:cKey length:BCXENCRYPT_KEY_SIZE];
    
    // setup iv
    char cIv[BCXENCRYPT_BLOCK_SIZE];
    bzero(cIv, BCXENCRYPT_BLOCK_SIZE);
    if (iv) {
        [iv getBytes:cIv length:BCXENCRYPT_BLOCK_SIZE];
    }
    
    // setup output buffer
	size_t bufferSize = [data length] + BCXENCRYPT_BLOCK_SIZE;
	void *buffer = malloc(bufferSize);
	
    // do decrypt
	size_t decryptedSize = 0;
	CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          BCXENCRYPT_ALGORITHM,
                                          kCCOptionPKCS7Padding,
										  cKey,
                                          BCXENCRYPT_KEY_SIZE,
                                          cIv,
                                          [data bytes],
                                          [data length],
                                          buffer,
                                          bufferSize,
                                          &decryptedSize);
	
	if (cryptStatus == kCCSuccess) {
		result = [NSData dataWithBytesNoCopy:buffer length:decryptedSize];
	} else {
        free(buffer);
        NSLog(@"[ERROR] failed to decrypt| CCCryptoStatus: %d", cryptStatus);
    }
    
	return result;
}

+ (NSData *)base64DataFromString: (NSString *)string
{
    unsigned long ixtext, lentext;
    unsigned char ch, inbuf[4], outbuf[3];
    short i, ixinbuf;
    Boolean flignore, flendtext = false;
    const unsigned char *tempcstring;
    NSMutableData *theData;
    
    if (string == nil){
        return [NSData data];
    }
    
    ixtext = 0;
    tempcstring = (const unsigned char *)[string UTF8String];
    lentext = [string length];
    theData = [NSMutableData dataWithCapacity: lentext];
    ixinbuf = 0;
    
    while (true){
        if (ixtext >= lentext){
            break;
        }
        
        ch = tempcstring [ixtext++];
        flignore = false;
        
        if ((ch >= 'A') && (ch <= 'Z')){
            ch = ch - 'A';
        } else if ((ch >= 'a') && (ch <= 'z')){
            ch = ch - 'a' + 26;
        } else if ((ch >= '0') && (ch <= '9')){
            ch = ch - '0' + 52;
        } else if (ch == '+'){
            ch = 62;
        } else if (ch == '=') {
            flendtext = true;
        } else if (ch == '/') {
            ch = 63;
        } else {
            flignore = true;
        }
        
        if (!flignore){
            short ctcharsinbuf = 3;
            Boolean flbreak = false;
            
            if (flendtext){
                if (ixinbuf == 0){
                    break;
                }
                
                if ((ixinbuf == 1) || (ixinbuf == 2)) {
                    ctcharsinbuf = 1;
                } else {
                    ctcharsinbuf = 2;
                }
                
                ixinbuf = 3;
                flbreak = true;
            }
            
            inbuf [ixinbuf++] = ch;
            
            if (ixinbuf == 4){
                ixinbuf = 0;
                
                outbuf[0] = (inbuf[0] << 2) | ((inbuf[1] & 0x30) >> 4);
                outbuf[1] = ((inbuf[1] & 0x0F) << 4) | ((inbuf[2] & 0x3C) >> 2);
                outbuf[2] = ((inbuf[2] & 0x03) << 6) | (inbuf[3] & 0x3F);
                
                for (i = 0; i < ctcharsinbuf; i++) {
                    [theData appendBytes: &outbuf[i] length: 1];
                }
            }
            
            if (flbreak) {
                break;
            }
        }
    }
    
    return theData;
}
@end
