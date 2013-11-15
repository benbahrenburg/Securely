/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2013 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */


#import "BencodingSecurelyCommonStringCryptoProxy.h"
#import "BCXCryptoUtilities.h"
#import "NSData+AES256.h"
@implementation BencodingSecurelyCommonStringCryptoProxy

-(void)encrypto:(id)args
{
    
    ENSURE_SINGLE_ARG(args,NSDictionary);
    ENSURE_TYPE(args,NSDictionary);
    
    BOOL success = NO;
    BOOL isBlob = NO;
    NSString *statusMsg = @"invalid data returned";
    
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
    
    KrollCallback *callback = [[args objectForKey:@"completed"] retain];
	ENSURE_TYPE(callback,KrollCallback);
    NSData *data;
    
    NSString* password = [args objectForKey:@"password"];
    id inputValue = [args objectForKey:@"value"];
    
    if([inputValue isKindOfClass:[TiBlob class]]){
        ENSURE_TYPE(inputValue,TiBlob);
        data = [(TiBlob *)inputValue data];
        isBlob = YES;
    }else{
        data = [((NSString *)inputValue) dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSData* encryptedData = nil;
    
    @try {
        encryptedData = [data AES256EncryptWithKey:password];
        
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
        if(isBlob){
            TiBlob *result = [[[TiBlob alloc] initWithData:encryptedData
                                                  mimetype:@"application/octet-stream"] autorelease];
            [event setObject:result forKey:@"result"];
        }else{
            NSString *encryptedString = [encryptedData base64Encoding];
            [event setObject:encryptedString forKey:@"result"];
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

-(void)writeEncrypt:(id)args
{
    
    ENSURE_SINGLE_ARG(args,NSDictionary);
    ENSURE_TYPE(args,NSDictionary);
    
    BOOL success = NO;
    NSString *statusMsg = @"invalid data returned";
    
    if (![args objectForKey:@"password"]) {
		NSLog(@"[ERROR] password is required");
        return;
	}
    if (![args objectForKey:@"inputValue"]) {
		NSLog(@"[ERROR] inputValue required");
		return;
	}
    if (![args objectForKey:@"outputPath"]) {
		NSLog(@"[ERROR] outputPath required");
		return;
	}
    if (![args objectForKey:@"completed"]) {
		NSLog(@"[ERROR] completed callback required");
		return;
	}
 

    NSString* outputFile = [BCXCryptoUtilities getNormalizedPath:[args objectForKey:@"outputPath"]];
    
    if (outputFile == nil) {
        NSLog(@"[ERROR] %@",[NSString stringWithFormat:@"Invalid encryption file path provided [%@]",
                             outputFile]);
        return;
    }
    
    if([[NSFileManager defaultManager] fileExistsAtPath:outputFile]){
        NSLog(@"[DEBUG] Output file already exists, removing so a new one can be created");
        NSError *errorD;
        BOOL deleted = [[NSFileManager defaultManager] removeItemAtPath:outputFile error:&errorD];
        if (!deleted){
            NSLog(@"[ERROR] %@", [errorD localizedDescription]);
            return;
        }
    }
    
    if (![args objectForKey:@"completed"]) {
        NSLog(@"[ERROR] completed callback method is required");
        return;
    }
    
    KrollCallback *callback = [[args objectForKey:@"completed"] retain];
	ENSURE_TYPE(callback,KrollCallback);
    NSData *data;
    
    NSString* password = [args objectForKey:@"password"];
    id inputValue = [args objectForKey:@"fromValue"];
    
    if([inputValue isKindOfClass:[TiBlob class]]){
        ENSURE_TYPE(inputValue,TiBlob);
        data = [(TiBlob *)inputValue data];
    }else if ([inputValue isKindOfClass:[TiFile class]]){
        ENSURE_TYPE(inputValue,TiFile);
        data = [[(TiFile *)inputValue blob] data];
    }else{
        data = [((NSString *)inputValue) dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    @try {
    
        NSData* encryptedData = [[data AES256EncryptWithKey:password] autorelease];
        
        if(encryptedData!=nil){
            if([encryptedData length]>0){
                NSError *error = nil;
                [encryptedData writeToFile:outputFile options:NSDataWritingFileProtectionComplete error:&error];
                if(error==nil){
                    success=YES;
                }else{
                    statusMsg = [error localizedDescription];
                    NSLog(@"Write returned error: %@", statusMsg);
                }
            }else{
                statusMsg = @"data length of zero returned";
            }
        }
    }
    @catch (NSException *exception) {
        success=NO;
        statusMsg = [exception reason];
    }
    
    
    if(callback != nil ){
        
        NSMutableDictionary *event = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      NUMBOOL(success),@"success",
                                      nil];
        if(success){
            [event setObject:outputFile forKey:@"result"];
        }else{
             [event setObject:statusMsg forKey:@"message"];
        }
        [self _fireEventToListener:@"completed" withObject:event
                          listener:callback thisObject:nil];
        [callback autorelease];
    }
}

-(void)readEncrypt:(id)args
{
    
    ENSURE_SINGLE_ARG(args,NSDictionary);
    ENSURE_TYPE(args,NSDictionary);
    
    BOOL success = NO;
    NSString *statusMsg = @"invalid data returned";
    
    if (![args objectForKey:@"password"]) {
		NSLog(@"[ERROR] password is required");
        return;
	}
    if (![args objectForKey:@"readPath"]) {
		NSLog(@"[ERROR] readPath required");
		return;
	}
    if (![args objectForKey:@"completed"]) {
		NSLog(@"[ERROR] completed callback required");
		return;
	}
    
    
    NSString* inputFile = [BCXCryptoUtilities getNormalizedPath:[args objectForKey:@"readPath"]];
    
    if (inputFile == nil) {
        NSLog(@"[ERROR] %@",[NSString stringWithFormat:@"Invalid encryption file path provided [%@]",
                             inputFile]);
        return;
    }
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:inputFile]){
        NSLog(@"[ERROR] readPath does not exist");
        return;
    }
    
    if (![args objectForKey:@"completed"]) {
        NSLog(@"[ERROR] completed callback method is required");
        return;
    }
    
    KrollCallback *callback = [[args objectForKey:@"completed"] retain];
	ENSURE_TYPE(callback,KrollCallback);
    NSData *data;
    
    NSString* password = [args objectForKey:@"password"];
    NSData *decryptedData = nil;
    
    @try {
        NSData *data = [[[NSFileManager defaultManager] contentsAtPath:inputFile] autorelease];
        decryptedData = [data AES256DecryptWithKey:password];
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
        TiBlob *result = [[[TiBlob alloc] initWithData:decryptedData
                                              mimetype:@"application/octet-stream"] autorelease];
        [event setObject:result forKey:@"result"];
    }else{
        [event setObject:statusMsg forKey:@"message"];
    }
    
    if(callback != nil ){
        [self _fireEventToListener:@"completed" withObject:event
                          listener:callback thisObject:nil];
        [callback autorelease];
    }
}

-(NSString *)decrypto:(id)args
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

    NSString* password = [args objectForKey:@"password"];
    NSString* resultType =[[TiUtils stringValue:@"resultType" properties:args def:@"text"] lowercaseString];
    BOOL useBlob = [resultType isEqualToString:@"blob"];
    NSData *data;
    BOOL success = NO;
    NSString *statusMsg = @"invalid data returned";
    
    KrollCallback *callback = [[args objectForKey:@"completed"] retain];
	ENSURE_TYPE(callback,KrollCallback);
    
    id inputValue = [args objectForKey:@"value"];
    if([inputValue isKindOfClass:[TiBlob class]]){
        ENSURE_TYPE(inputValue,TiBlob);
        data = [(TiBlob *)inputValue data];
    }else{
        data = [BCXCryptoUtilities base64DataFromString:(NSString *)inputValue];
    }
    
    NSData* decryptedData = nil;
    @try {
        
        decryptedData = [[data AES256DecryptWithKey:password] autorelease];
        
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
            NSString *plainText = [[[NSString alloc] initWithData:decryptedData
                                  encoding:NSUTF8StringEncoding] autorelease];
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


-(NSString *)encrypt:(id)args
{
    enum Args {
		kArgPassword = 0,
        kArgPlainText = 1,
        kArgCount
	};
    
    ENSURE_ARG_COUNT(args, kArgCount);
    
    NSString* password = [TiUtils stringValue:[args objectAtIndex:kArgPassword]];
    //DebugLog(@"password: %@", password);
    NSString* plainText = [TiUtils stringValue:[args objectAtIndex:kArgPlainText]];
    //DebugLog(@"plainText: %@", plainText);
    NSData* data = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    NSData* encryptedData = [data AES256EncryptWithKey:password];
    NSString *encryptedString = [encryptedData base64Encoding];
    return encryptedString;
}


-(NSString *)decrypt:(id)args
{
    enum Args {
		kArgPassword = 0,
        kArgEncryptedText = 1,
        kArgCount
	};
    
    ENSURE_ARG_COUNT(args, kArgCount);
    
    NSString* password = [TiUtils stringValue:[args objectAtIndex:kArgPassword]];
    NSLog(@"password: %@", password);
    
    NSString* encryptedText = [TiUtils stringValue:[args objectAtIndex:kArgEncryptedText]];
    NSLog(@"encryptedText: %@", encryptedText);
    
    NSData *data = [BCXCryptoUtilities base64DataFromString:encryptedText];
    NSData *decryptedData = [data AES256DecryptWithKey:password];
    NSString *plainText = [[[NSString alloc] initWithData:decryptedData
                                                encoding:NSUTF8StringEncoding] autorelease];
    NSLog(@"plainText: %@", plainText);
    return plainText;
}

@end
