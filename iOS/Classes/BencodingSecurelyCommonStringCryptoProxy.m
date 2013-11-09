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
    
    BOOL success = NO;
    NSString *statusMsg = @"invalid data returned";
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
    
    NSString* resultType =[[TiUtils stringValue:@"resultType" properties:args def:@"text"] lowercaseString];
    BOOL useBlob = [resultType isEqualToString:@"blob"];
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
        if(useBlob){
            TiBlob *result = [[[TiBlob alloc] initWithData:encryptedData
                                                  mimetype:@"application/octet-stream"] autorelease];
            [event setObject:@"blob" forKey:@"resultType"];
            [event setObject:result forKey:@"result"];
        }else{
            NSString *encryptedString = [encryptedData base64Encoding];
            [event setObject:@"text" forKey:@"resultType"];
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

@end
