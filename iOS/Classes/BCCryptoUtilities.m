//
//  BCCryptoUtilities.m
//  Securely
//
//  Created by Ben on 4/14/13.
//
//

#import "BCCryptoUtilities.h"

@implementation BCCryptoUtilities

NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

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
@end
