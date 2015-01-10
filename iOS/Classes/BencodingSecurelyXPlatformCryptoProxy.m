/**
 * Securely Titanium Security Project
 * Copyright (c) 2014 by Benjamin Bahrenburg. All Rights Reserved.
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
    NSData *data = nil;
    NSData *iv = nil;

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
    
    KrollCallback *callback = [args objectForKey:@"completed"];
	ENSURE_TYPE(callback,KrollCallback);

    BOOL debug =[TiUtils boolValue:@"debug" def:NO];
    
    NSString* password = [args objectForKey:@"password"];
    if([BCXCryptoUtilities stringIsNilOrEmpty:password]){
        NSLog(@"[ERROR] password provided is empty or null");
        return;
    }
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
        //
        NSString *valueTest = (NSString *)inputValue;
        //Determine if filePath or just a string value
        if([BCXCryptoUtilities fileIsValid:valueTest]){
            //We think this is a file so try to read it
            data = [NSData dataWithContentsOfFile:[BCXCryptoUtilities getNormalizedPath:valueTest]];
        }else{
            data = [((NSString *)inputValue) dataUsingEncoding:NSUTF8StringEncoding];
        }
    }
    
    //Validate we are able to read all of the source file data
    if(data==nil){
        NSLog(@"[ERROR] unable to read data from inputValue, try using a TiFile type");
        return;
    }
    
    if([data length]==0){
        NSLog(@"[ERROR] zero bytes found in inputValue, try using a TiFile type");
        return;
    }

    if (![args objectForKey:@"iv"]) {
         iv = [BCXCryptoUtilities base64DataFromString:(NSString *)[args objectForKey:@"iv"]];
    }


    @try {
       
        NSData* encryptedData = [data AES256EncryptWithKeyAndIV:password withIV:iv];
        
        if(encryptedData==nil){
            statusMsg = @"Invalid data in encryption process";
            NSLog(@"[ERROR] %@", statusMsg);
            success = NO;
        }else{
            if([encryptedData length]==0){
                statusMsg = @"Data length of zero returned";
                NSLog(@"[ERROR] %@", statusMsg);
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
                    statusMsg = [error localizedDescription];
                    NSLog(@"[ERROR] write error: %@", statusMsg);
                }
            }
        }
    }
    @catch (NSException *exception) {
        success=NO;
        statusMsg = [exception reason];
        NSLog(@"[ERROR] %@", statusMsg);
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

    KrollCallback *callback = [args objectForKey:@"completed"];
	ENSURE_TYPE(callback,KrollCallback);
    
    BOOL debug =[TiUtils boolValue:@"debug" def:NO];
    id inputValue = [args objectForKey:@"readPath"];
    NSString *returnType = [TiUtils stringValue:@"returnType" properties:args def:@"blob"];
    NSString* password = [args objectForKey:@"password"];
    if([BCXCryptoUtilities stringIsNilOrEmpty:password]){
        NSLog(@"[ERROR] password provided is empty or null");
        return;
    }
    if(debug){
        NSLog(@"[DEBUG] Is of type: %@", [inputValue class]);
    }
 
    NSData *data =nil;
    NSData *iv = nil;

    if (![args objectForKey:@"iv"]) {
        iv = [BCXCryptoUtilities base64DataFromString:(NSString *)[args objectForKey:@"iv"]];
    }

    if([inputValue isKindOfClass:[TiBlob class]]){
        ENSURE_TYPE(inputValue,TiBlob);
        data = [(TiBlob *)inputValue data];
    }else if ([inputValue isKindOfClass:[TiFile class]]){
        ENSURE_TYPE(inputValue,TiFile);
        data = [[(TiFile *)inputValue blob] data];
    }else{
        
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
        
        data = [[NSFileManager defaultManager] contentsAtPath:inputFile];
    }

    //Validate we are able to read all of the source file data
    if(data==nil){
        NSLog(@"[ERROR] unable to read data from readPath, try using a TiFile type");
        return;
    }
    
    if([data length]==0){
        NSLog(@"[ERROR] zero bytes found in readPath, try using a TiFile type");
        return;
    }
    
    NSData *decryptedData = nil;
    
    @try {
        
        decryptedData = [data AES256DecryptWithKeyAndIV:password withIV:iv];

        if(decryptedData==nil){
            success = NO;
            statusMsg = @"Invalid decryption action, null returned";
            NSLog(@"[ERROR] %@", statusMsg);
        }else{
            if([decryptedData length]==0){
                success = NO;
                statusMsg = @"Data length of zero returned";
                NSLog(@"[ERROR] %@", statusMsg);
            }else{
                success=YES;
            }
        }
    }
    @catch (NSException *exception) {
        success = NO;
        statusMsg = [exception reason];
        NSLog(@"[ERROR] %@", statusMsg);
    }
    
    
    NSMutableDictionary *event = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  NUMBOOL(success),@"success",
                                  nil];
    
    if(success){
        if([returnType isEqual:@"string"]){
            NSString *plainText = [[NSString alloc] initWithData:decryptedData
                                                         encoding:NSUTF8StringEncoding];
            [event setObject:plainText forKey:@"result"];
        }else{
            TiBlob *result = [[TiBlob alloc] initWithData:decryptedData
                                                  mimetype:@"application/octet-stream"];
            [event setObject:result forKey:@"result"];
        }
    }else{
        [event setObject:statusMsg forKey:@"message"];
    }
    
    if(callback != nil ){
        [self _fireEventToListener:@"completed" withObject:event
                          listener:callback thisObject:nil];
    }
}

-(NSString *)encrypt:(id)args
{
    enum Args {
		kArgPassword = 0,
        kArgPlainText = 1,
        kArgCount,
        kArgIV = kArgCount        // Optional
	};
    
    ENSURE_ARG_COUNT(args, kArgCount);
    
    NSString* password = [TiUtils stringValue:[args objectAtIndex:kArgPassword]];
    //DebugLog(@"password: %@", password);
    if([BCXCryptoUtilities stringIsNilOrEmpty:password]){
        NSLog(@"[ERROR] password provided is empty or null");
        return;
    }
    NSString* plainText = [TiUtils stringValue:[args objectAtIndex:kArgPlainText]];
    if([BCXCryptoUtilities stringIsNilOrEmpty:plainText]){
        NSLog(@"[ERROR] text provided is empty or null");
        return;
    }
    //DebugLog(@"plainText: %@", plainText);
    NSData* data = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    NSData *iv = nil;

    if ([args count] > kArgIV) {
        iv = [BCXCryptoUtilities base64DataFromString:[TiUtils stringValue:[args objectAtIndex:kArgIV]]];
    }

    NSData* encryptedData = [data AES256EncryptWithKeyAndIV:password withIV:iv];
    NSString *encryptedString = nil;

    #if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
        encryptedString= [encryptedData base64EncodedStringWithOptions:0];
    #else
        encryptedString = [encryptedData base64Encoding];
    #endif

    return encryptedString;

}


-(NSString *)decrypt:(id)args
{
    enum Args {
		kArgPassword = 0,
        kArgEncryptedText = 1,
        kArgCount,
        kArgIV = kArgCount        // Optional
	};
    
    ENSURE_ARG_COUNT(args, kArgCount);
    
    NSString* password = [TiUtils stringValue:[args objectAtIndex:kArgPassword]];
    //NSLog(@"password: %@", password);
    
    NSString* encryptedText = [TiUtils stringValue:[args objectAtIndex:kArgEncryptedText]];
    //NSLog(@"encryptedText: %@", encryptedText);
    
    NSData *data = [BCXCryptoUtilities base64DataFromString:encryptedText];
    NSData* iv = nil;

    if ([args count] > kArgIV) {
        iv = [BCXCryptoUtilities base64DataFromString:[TiUtils stringValue:[args objectAtIndex:kArgIV]]];
    }

    NSData *decryptedData = [data AES256DecryptWithKeyAndIV:password withIV:iv];

    NSString *plainText = [[NSString alloc] initWithData:decryptedData
                                                encoding:NSUTF8StringEncoding];
    //NSLog(@"plainText: %@", plainText);
    return plainText;
}

@end
