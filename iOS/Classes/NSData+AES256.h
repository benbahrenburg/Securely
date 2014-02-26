//
//  NSString+AES256.h
//  SourceDrop
//
//  Created by Michael Hohl on 29.06.12.
//  Copyright (c) 2012 Michael Hohl. All rights reserved.
//

#import <Foundation/Foundation.h>

///
/// @discussion Important: This implementation has many security leask, but since we are crypting the content
/// of the clipboard or an uncrypted local files, this doesn't matter.
/// But DO NOT USE this methods on really secure information.
///
/// DO NOT USE THIS FOR ANY REAL SECURE DATA!
///
@interface NSData (AES256)

///
/// Encrypts the string with the passed key.
///
/// @param key 32 bytes
/// @return encrypt with the passed key
///
- (NSData *)AES256EncryptWithKey:(NSString*)key;

///
/// Decrypts the string with the passed key.
///
/// @param key 32 bytes
/// @return decrypted data
///
- (NSData *)AES256DecryptWithKey:(NSString*)key;

@end