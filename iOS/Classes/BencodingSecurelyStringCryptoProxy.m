/**
 * Securely Titanium Security Project
 * Copyright (c) 2009-2013 by Benjamin Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "BencodingSecurelyStringCryptoProxy.h"
#import "NSData+Base64.h"
#import "NSString+Base64.h"
#import "NSData+CommonCrypto.h"
#import "BCXCryptoUtilities.h"

@implementation BencodingSecurelyStringCryptoProxy

-(NSString *)encrypt:(id)args
{
    ENSURE_SINGLE_ARG(args,NSDictionary);
    ENSURE_TYPE(args,NSDictionary);
    
    if (![args objectForKey:@"password"]) {
		NSLog(@"[ERROR] password is required");
        return;
	}
    if (![args objectForKey:@"value"]) {
		NSLog(@"[ERROR] value required");
		return;
	}
    if (![args objectForKey:@"completed"]) {
		NSLog(@"[ERROR] completed callback required");
		return;
	}

    BOOL useHex = YES;
    BOOL useBlob = NO;
    BOOL success = NO;
    NSString *statusMsg = @"invalid data returned";
    NSData *iv = nil;
    NSData *data;
    
    KrollCallback *callback = [[args objectForKey:@"completed"] retain];
	ENSURE_TYPE(callback,KrollCallback);
    
    NSString* password = [args objectForKey:@"password"];
    id inputValue = [args objectForKey:@"value"];
    
    if([inputValue isKindOfClass:[TiBlob class]]){
        ENSURE_TYPE(inputValue,TiBlob);
        data = [(TiBlob *)inputValue data];
    }else{
        data = [((NSString *)inputValue) dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSString* resultType =[[TiUtils stringValue:@"resultType" properties:args def:@"hex"] lowercaseString];
    
    if([resultType isEqualToString:@"blob"]){
        useHex = NO;
        useBlob = YES;
    }else{
        if([resultType isEqualToString:@"text"]){
           useHex = NO;
        }
    }
    
    if (![args objectForKey:@"iv"]) {
        NSString* ivString = [args objectForKey:@"iv"];
        iv = [ivString dataUsingEncoding:NSUTF8StringEncoding];
	}
    
    NSData* encryptedData;
    @try {
        encryptedData = [BCXCryptoUtilities encryptData:data
                                            key:[password dataUsingEncoding:NSUTF8StringEncoding]
                                            iv:iv];
        
        if(encryptedData!=nil){
            if([encryptedData length]>0){
                success=YES;
            }else{
                statusMsg = @"data length of zero returned";
            }
        }
    }
    @catch (NSException *exception) {
        success=NO;
        statusMsg = [exception reason];
    }

        
    NSMutableDictionary *event = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  NUMBOOL(success),@"success",
                                  nil];
 
    if(success){
        if(useBlob){
            TiBlob *result = [[[TiBlob alloc] initWithData:encryptedData
                                                  mimetype:@"application/octet-stream"] autorelease];
            [event setObject:@"blob" forKey:@"resultType"];
            [event setObject:result forKey:@"result"];
        }else{
            NSString *encryptedString = [NSString base64StringFromData:encryptedData
                                                                length:[encryptedData length]];
            if(useHex){
                NSString *hexEncrypted = [BCXCryptoUtilities stringToHex:encryptedString];
                [event setObject:@"hex" forKey:@"resultType"];
                [event setObject:hexEncrypted forKey:@"result"];
            }else{
                [event setObject:@"text" forKey:@"resultType"];
                [event setObject:encryptedString forKey:@"result"];
            }
        }
    }else{
        [event setObject:statusMsg forKey:@"message"];
    }

    if(callback != nil ){
        [self _fireEventToListener:@"completed" withObject:event
                          listener:callback thisObject:nil];
        [callback autorelease];
    }
}

-(NSString *)decrypt:(id)args
{
    ENSURE_SINGLE_ARG(args,NSDictionary);
    ENSURE_TYPE(args,NSDictionary);
    
    if (![args objectForKey:@"password"]) {
		NSLog(@"[ERROR] password is required");
		return;
	}
    if (![args objectForKey:@"value"]) {
		NSLog(@"[ERROR] value required");
		return;
	}
    if (![args objectForKey:@"completed"]) {
		NSLog(@"[ERROR] completed callback required");
		return;
	}

    BOOL useHex = YES;
    BOOL useBlob = NO;
    NSData *data;
    BOOL success = NO;
    NSString *statusMsg = @"invalid data returned";
    NSData *iv = nil;
    
    KrollCallback *callback = [[args objectForKey:@"completed"] retain];
	ENSURE_TYPE(callback,KrollCallback);
    
    NSString* password = [args objectForKey:@"password"];
    NSString* resultType =[[TiUtils stringValue:@"resultType" properties:args def:@"hex"] lowercaseString];
    
    if([resultType isEqualToString:@"blob"]){
        useHex = NO;
        useBlob = YES;
    }else{
        if([resultType isEqualToString:@"text"]){
            useHex = NO;
        }
    }
    
    id inputValue = [args objectForKey:@"value"];
    if([inputValue isKindOfClass:[TiBlob class]]){
        ENSURE_TYPE(inputValue,TiBlob);
        data = [(TiBlob *)inputValue data];
    }else{
        NSString* inputString = (useHex)? [BCXCryptoUtilities hexStringtoString:(NSString *)inputValue] : (NSString *)inputValue;
        data = [NSData base64DataFromString:inputString];
    }
          
    if (![args objectForKey:@"iv"]) {
        NSString* ivString = [args objectForKey:@"iv"];
        iv = [ivString dataUsingEncoding:NSUTF8StringEncoding];
	}
    
    NSData* decryptedData;
    @try {
        decryptedData = [BCXCryptoUtilities decryptData:data
                                            key:[password dataUsingEncoding:NSUTF8StringEncoding]
                                            iv:iv];
        if(decryptedData!=nil){
            if([decryptedData length]>0){
                success=YES;
            }else{
                statusMsg = @"data length of zero returned";
            }
        }
    }
    @catch (NSException *exception) {
        success=NO;
        statusMsg = [exception reason];
    }
    
    NSMutableDictionary *event = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  NUMBOOL(success),@"success",
                                  nil];
    
    if(success){
        if(useBlob){
            TiBlob *result = [[[TiBlob alloc] initWithData:decryptedData
                                                  mimetype:@"application/octet-stream"] autorelease];
            [event setObject:@"blob" forKey:@"resultType"];
            [event setObject:result forKey:@"result"];
        }else{
            NSString *plainText =  [[[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding] autorelease];
            [event setObject:@"text" forKey:@"resultType"];
            [event setObject:plainText forKey:@"result"];
        }
    }else{
        [event setObject:statusMsg forKey:@"message"];
    }
    
    if(callback != nil ){
        [self _fireEventToListener:@"completed" withObject:event
                          listener:callback thisObject:nil];
        [callback autorelease];
    }
}

-(NSString *)AESEncrypt:(id)args
{
    enum Args {
		kArgPassword = 0,
        kArgPlainText = 1,
        kArgCount,
        kArgUseHex = kArgCount        // Optional
	};
    
    ENSURE_ARG_COUNT(args, kArgCount);
    
    NSString* password = [TiUtils stringValue:[args objectAtIndex:kArgPassword]];
    //DebugLog(@"password: %@", password);
    NSString* plainText = [TiUtils stringValue:[args objectAtIndex:kArgPlainText]];
    //DebugLog(@"plainText: %@", plainText);
        
    BOOL useHex = ([args count] > kArgUseHex) ? [TiUtils boolValue:[args objectAtIndex:kArgUseHex]] : YES;
        
    NSData *encryptedData = [[plainText dataUsingEncoding:NSUTF8StringEncoding] AES256EncryptedDataUsingKey:[[password dataUsingEncoding:NSUTF8StringEncoding] SHA256Hash] error:nil];
    NSString *encryptedString = [NSString base64StringFromData:encryptedData
                                                            length:[encryptedData length]];
        
    if(useHex){
        NSString *hexEncrypted = [BCXCryptoUtilities stringToHex:encryptedString];
        return hexEncrypted;
    }else{
        return encryptedString;
    }
    
}


-(NSString *)AESDecryptWithOptions:(NSString *)password
                 withEncryptedText:(NSString*) encryptedText withUseHex:(BOOL)useHex
{
    
    NSString* inputString = (useHex)? [BCXCryptoUtilities hexStringtoString:encryptedText] : encryptedText;
    NSData *encryptedData = [NSData base64DataFromString:inputString];
    
    NSData *decryptedData = [encryptedData decryptedAES256DataUsingKey:[[password dataUsingEncoding:NSUTF8StringEncoding] SHA256Hash] error:nil];
    
    NSString *plainText =  [[[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding] autorelease];
    
    return plainText;
    
}

-(NSString *)AESDecrypt:(id)args
{
    enum Args {
		kArgPassword = 0,
        kArgEncryptedText = 1,
        kArgCount,
        kArgUseHex = kArgCount        // Optional
	};
    
    ENSURE_ARG_COUNT(args, kArgCount);

    NSString* password = [TiUtils stringValue:[args objectAtIndex:kArgPassword]];
    //DebugLog(@"password: %@", password);
    
    NSString* encryptedText = [TiUtils stringValue:[args objectAtIndex:kArgEncryptedText]];
    //DebugLog(@"encryptedText: %@", encryptedText);
    
    BOOL useHex = ([args count] > kArgUseHex) ? [TiUtils boolValue:[args objectAtIndex:kArgUseHex]] : YES;
    
    return [self AESDecryptWithOptions:password withEncryptedText:encryptedText withUseHex:useHex];
}

-(NSString *)DESEncrypt:(id)args
{
    ENSURE_ARG_COUNT(args,2);
    NSString* password = [TiUtils stringValue:[args objectAtIndex:0]];
    //DebugLog(@"password: %@", password);
    NSString* plainText = [TiUtils stringValue:[args objectAtIndex:1]];
    //DebugLog(@"plainText: %@", plainText);
    
    NSData *encryptedData = [[plainText dataUsingEncoding:NSUTF8StringEncoding] DESEncryptedDataUsingKey:[[password dataUsingEncoding:NSUTF8StringEncoding] SHA256Hash] error:nil];
    
    NSString *encryptedString = [NSString base64StringFromData:encryptedData length:[encryptedData length]];
    
    return encryptedString;
}

-(NSString *)DESDecrypt:(id)args
{
    ENSURE_ARG_COUNT(args,2);
    
    NSString* password = [TiUtils stringValue:[args objectAtIndex:0]];
    //DebugLog(@"password: %@", password);
    NSString* encryptedText = [TiUtils stringValue:[args objectAtIndex:1]];
    //DebugLog(@"encryptedText: %@", encryptedText);
    
    NSData *encryptedData = [NSData base64DataFromString:encryptedText];
    
    NSData *decryptedData = [encryptedData decryptedDESDataUsingKey:[[password dataUsingEncoding:NSUTF8StringEncoding] SHA256Hash] error:nil];
    
    NSString *plainText =  [[[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding]autorelease];
    
    return plainText;
    
}
-(NSString *) sha256:(id)args
{
    ENSURE_ARG_COUNT(args,1);
    NSString* plainText = [TiUtils stringValue:[args objectAtIndex:0]];
    NSData* data = [[plainText dataUsingEncoding:NSUTF8StringEncoding]SHA256Hash];
    NSString *hashText = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    return hashText;
}

-(NSString *) toHex:(id)args
{
    ENSURE_ARG_COUNT(args,1);
    NSString* plainText = [TiUtils stringValue:[args objectAtIndex:0]];
    NSString *hexed = [BCXCryptoUtilities stringToHex:plainText];    
    return hexed;
}

-(NSString *) fromHex:(id)args
{
    ENSURE_ARG_COUNT(args,1);
    NSString* text = [TiUtils stringValue:[args objectAtIndex:0]];
    NSMutableData *stringData = [[[NSMutableData alloc] init] autorelease];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    int i;
    for (i=0; i < [text length] / 2; i++) {
        byte_chars[0] = [text characterAtIndex:i*2];
        byte_chars[1] = [text characterAtIndex:i*2+1];
        whole_byte = strtol(byte_chars, NULL, 16);
        [stringData appendBytes:&whole_byte length:1];
    }
    
    return [[[NSString alloc] initWithData:stringData encoding:NSASCIIStringEncoding] autorelease];
}

@end
