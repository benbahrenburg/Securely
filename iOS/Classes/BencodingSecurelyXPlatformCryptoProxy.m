/**
 * Securely Titanium Security Project
 * Copyright (c) 2009-2013 by Benjamin Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "BencodingSecurelyXPlatformCryptoProxy.h"
#import "BCXCryptoUtilities.h"
#import "NSData+AES256.h"
@implementation BencodingSecurelyXPlatformCryptoProxy


-(void)writeEncrypt:(id)args
{
    
    ENSURE_SINGLE_ARG(args,NSDictionary);
    ENSURE_TYPE(args,NSDictionary);
    BOOL success = NO;
    NSData *data;
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

    BOOL debug =[TiUtils boolValue:@"debug" def:NO];
    
    NSString* password = [args objectForKey:@"password"];
    id inputValue = [args objectForKey:@"inputValue"];
    
    if(debug){
        NSLog(@"[DEBUG] Is of type: %@", [inputValue class]);
    }
    
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
        
        if(encryptedData==nil){
            statusMsg = @"[DEBUG] invalid data in encryption process";
            NSLog(@"[DEBUG] %@", statusMsg);
            success = NO;
        }else{
            if([encryptedData length]==0){
                statusMsg = @"data length of zero returned";
                NSLog(@"[DEBUG] %@", statusMsg);
                success = NO;
            }else{
                NSError *error = nil;
                [encryptedData writeToFile:outputFile options:NSDataWritingAtomic error:&error];
                
                if(error==nil){
                    if(debug){
                        NSLog(@"[DEBUG] encryptedData written successful");
                    }
                    success=YES;
                }else{
                    success=NO;
                    NSLog(@"[DEBUG] encryptedData has error");
                    statusMsg = [error localizedDescription];
                }
            }
        }
    }
    @catch (NSException *exception) {
        success=NO;
        statusMsg = [exception reason];
        NSLog(@"[DEBUG] %@", statusMsg);
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
    NSData *decryptedData = nil;
    NSString *returnType = [TiUtils stringValue:@"returnType" properties:args def:@"blob"];
    NSString* password = [args objectForKey:@"password"];
    BOOL debug =[TiUtils boolValue:@"debug" def:NO];
    
    
    @try {
        NSData *data = [[[NSFileManager defaultManager] contentsAtPath:inputFile] autorelease];
        decryptedData = [data AES256DecryptWithKey:password];
        if(decryptedData==nil){
            success = NO;
            statusMsg = @"Invalid decryption action, null returned";
            NSLog(@"[DEBUG] %@", statusMsg);
        }else{
            if([decryptedData length]==0){
                success = NO;
                statusMsg = @"data length of zero returned";
                NSLog(@"[DEBUG] %@", statusMsg);
            }else{
                success=YES;
            }
        }
    }
    @catch (NSException *exception) {
        success = NO;
        statusMsg = [exception reason];
        NSLog(@"[DEBUG] %@", statusMsg);
    }
    
    
    NSMutableDictionary *event = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  NUMBOOL(success),@"success",
                                  nil];
    
    if(success){
        if([returnType isEqual:@"string"]){
            NSString *plainText = [[[NSString alloc] initWithData:decryptedData
                                                         encoding:NSUTF8StringEncoding] autorelease];
            [event setObject:plainText forKey:@"result"];
        }else{
            TiBlob *result = [[[TiBlob alloc] initWithData:decryptedData
                                                  mimetype:@"application/octet-stream"] autorelease];
            [event setObject:result forKey:@"result"];
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
    
    #if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
        NSString *encryptedString = [encryptedData base64EncodedStringWithOptions:0];
        return encryptedString;
    #else
        NSString *encryptedString = [encryptedData base64Encoding];
        return encryptedString;
    #endif

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
    //NSLog(@"password: %@", password);
    
    NSString* encryptedText = [TiUtils stringValue:[args objectAtIndex:kArgEncryptedText]];
    //NSLog(@"encryptedText: %@", encryptedText);
    
    NSData *data = [BCXCryptoUtilities base64DataFromString:encryptedText];
    NSData *decryptedData = [data AES256DecryptWithKey:password];
    NSString *plainText = [[[NSString alloc] initWithData:decryptedData
                                                encoding:NSUTF8StringEncoding] autorelease];
    //NSLog(@"plainText: %@", plainText);
    return plainText;
}

@end
