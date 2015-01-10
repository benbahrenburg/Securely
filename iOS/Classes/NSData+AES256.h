
//
// Based on work from Michael Hohl on 29.06.12
//


#import <Foundation/Foundation.h>


@interface NSData (AES256)

/// @discussion Important: This implementation has many security leask.
/// Please use the platform specific encryption functions for real secure data.
///

///
/// Encrypts the string with the passed key.
///
- (NSData *)AES256EncryptWithKeyAndIV:(NSString*)key withIV:(NSData*)iv;
///
/// Decrypts the string with the passed key.
///
- (NSData *)AES256DecryptWithKeyAndIV:(NSString*)key withIV:(NSData*)iv;
@end