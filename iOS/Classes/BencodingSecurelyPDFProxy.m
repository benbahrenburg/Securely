/**
 * Securely Titanium Security Project
 * Copyright (c) 2014 by Benjamin Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "BencodingSecurelyPDFProxy.h"
#import "TiUtils.h"
#import "BCXCryptoUtilities.h"
@implementation BencodingSecurelyPDFProxy


-(void) unprotect:(id)args
{
    ENSURE_SINGLE_ARG(args,NSDictionary);
    ENSURE_TYPE(args,NSDictionary);
    
    //Make sure we're on the UI thread, this stops bad things
	ENSURE_UI_THREAD(unprotect,args);
    
    if (![args objectForKey:@"password"]) {
		NSLog(@"[ERROR] password is required");
		return;
	}
    NSString* secret = [args objectForKey:@"password"];
    BOOL deleteSource = [TiUtils boolValue:[args objectForKey:@"deleteSource"] def:NO];
    NSString* fileEncryptedFile = [args objectForKey:@"from"];
	NSString* inputFile = [BCXCryptoUtilities getNormalizedPath:fileEncryptedFile];
    
    if (inputFile == nil) {
		NSLog(@"[ERROR] %@",[NSString stringWithFormat:@"Invalid protected pdf file path provided [%@]", inputFile]);
		return;
	}
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:inputFile]){
 		NSLog(@"[ERROR] %@",[NSString stringWithFormat:@"Invalid protected pdf file path provided [%@]", inputFile]);
		return;
    }
    
    NSString* fileDecryptedFile = [args objectForKey:@"to"];
	NSString* outputFile = [BCXCryptoUtilities getNormalizedPath:fileDecryptedFile];
    
    if (outputFile == nil) {
		NSLog(@"[ERROR] %@",[NSString stringWithFormat:@"Invalid protected pdf file path provided [%@]", outputFile]);
		return;
	}
    
    if([[NSFileManager defaultManager] fileExistsAtPath:outputFile]){
        NSLog(@"[DEBUG] Output file already exists, removing");
        NSError *error;
        BOOL deleted = [[NSFileManager defaultManager] removeItemAtPath:outputFile error:&error];
        if (!deleted) NSLog(@"Error: %@", [error localizedDescription]);
    }
    
    if (![args objectForKey:@"completed"]) {
		NSLog(@"[ERROR] completed callback method is required");
		return;
	}
    
    KrollCallback *callback = [args objectForKey:@"completed"];
	ENSURE_TYPE(callback,KrollCallback);

    CFURLRef url = (CFURLRef)CFBridgingRetain([[NSURL alloc] initFileURLWithPath:inputFile]);
    CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL(url);
    BOOL encrypted = CGPDFDocumentIsEncrypted(pdf);
 
    NSMutableDictionary *event = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  inputFile,@"to",
                                  outputFile,@"from",
                                  nil];
    
    BOOL unlocked = YES;
    if(encrypted){
        const char *key = [secret UTF8String];
        unlocked = CGPDFDocumentUnlockWithPassword(pdf, key);
        if(!unlocked){
            [event setObject:NUMBOOL(NO) forKey:@"success"];
            [event setObject:@"Failed to unlock try another password"
                      forKey:@"message"];
        }
    }
    
    if(unlocked){
        CFMutableDictionaryRef myDictionary = NULL;
        myDictionary = CFDictionaryCreateMutable(NULL, 0,
                                                 &kCFTypeDictionaryKeyCallBacks,
                                                 &kCFTypeDictionaryValueCallBacks);
        
        
        CFDictionarySetValue(myDictionary, kCGPDFContextAllowsCopying, kCFBooleanTrue);
        CFDictionarySetValue(myDictionary, kCGPDFContextAllowsPrinting, kCFBooleanTrue);
        
        CFURLRef pdfURLOutput = (CFURLRef)CFBridgingRetain([[NSURL alloc] initFileURLWithPath:outputFile]);
        NSInteger numberOfPages1 = CGPDFDocumentGetNumberOfPages(pdf);
        
        // Create the output context
        CGContextRef writeContext = CGPDFContextCreateWithURL(pdfURLOutput, NULL, myDictionary);

        // Loop variables
        CGPDFPageRef page;
        CGRect mediaBox;
        
        // Read the first PDF and generate the output pages
        NSLog(@"[ERROR] Pages from pdf (%i)", numberOfPages1);
        for (int i=1; i<=numberOfPages1; i++) {
            page = CGPDFDocumentGetPage(pdf, i);
            mediaBox = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
            CGContextBeginPage(writeContext, &mediaBox);
            CGContextDrawPDFPage(writeContext, page);
            CGContextEndPage(writeContext);
        }
        
        // Finalize the output file
        CGPDFContextClose(writeContext);
        // Release from memory
        CGContextRelease(writeContext);
        CFRelease(pdfURLOutput);
        CFRelease(myDictionary);
        
         [event setObject:NUMBOOL(YES) forKey:@"success"];
    }


    

    
    // Release from memory
    
    CFRelease(url);    
    CGPDFDocumentRelease(pdf);
        
    
    if(unlocked){
        if(![[NSFileManager defaultManager] fileExistsAtPath:outputFile]){
            [event setObject:NUMBOOL(NO) forKey:@"success"];
            [event setObject:@"Failed unlocking protected file"
                      forKey:@"message"];
        }else{
            if(deleteSource){
                if(![[NSFileManager defaultManager] isDeletableFileAtPath:inputFile]){
                    NSLog(@"[ERROR] unable to remove input file");
                }else{
                    NSLog(@"[DEBUG] Removing source file");
                    NSError *error;
                    BOOL deleted = [[NSFileManager defaultManager] removeItemAtPath:inputFile error:&error];
                    if (!deleted) NSLog(@"Error: %@", [error localizedDescription]);
                }
            }
        }
    }
    
    if(callback != nil ){
        [self _fireEventToListener:@"completed" withObject:event
                          listener:callback thisObject:nil];
    }
    
}

-(void) protect:(id)args
{
    ENSURE_SINGLE_ARG(args,NSDictionary);
    ENSURE_TYPE(args,NSDictionary);
 
    //Make sure we're on the UI thread, this stops bad things
	ENSURE_UI_THREAD(protect,args);
    
    if (![args objectForKey:@"userPassword"]) {
		NSLog(@"[ERROR] user password is required");
		return;
	}

    NSString* userPassword = [args objectForKey:@"userPassword"];
    
    NSString* ownerPassword = nil;
    if ([args objectForKey:@"ownerPassword"]) {
        ownerPassword = [args objectForKey:@"ownerPassword"];
	}
    
    NSString* filePlainFile = [args objectForKey:@"from"];
	NSString* inputFile = [BCXCryptoUtilities getNormalizedPath:filePlainFile];
    
    if (inputFile == nil) {
		NSLog(@"[ERROR] %@",[NSString stringWithFormat:@"Invalid source file path provided [%@]", inputFile]);
		return;
	}
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:inputFile]){
 		NSLog(@"[ERROR] %@",[NSString stringWithFormat:@"Invalid source file path provided [%@]", inputFile]);
		return;
    }
    
    NSString* fileEncryptedFile = [args objectForKey:@"to"];
	NSString* outputFile = [BCXCryptoUtilities getNormalizedPath:fileEncryptedFile];
    
    if (outputFile == nil) {
		NSLog(@"[ERROR] %@",[NSString stringWithFormat:@"Invalid protected file path provided [%@]", outputFile]);
		return;
	}
    
    if([[NSFileManager defaultManager] fileExistsAtPath:outputFile]){
        NSLog(@"[Debug] File already exists, removing");
        NSError *error;
        BOOL deleted = [[NSFileManager defaultManager] removeItemAtPath:outputFile error:&error];
        if (!deleted) NSLog(@"Error: %@", [error localizedDescription]);
    }
    
    if (![args objectForKey:@"completed"]) {
		NSLog(@"[ERROR] completed callback method is required");
		return;
	}

    BOOL allowCopy = [TiUtils boolValue:[args objectForKey:@"allowCopy"] def:YES];
    //BOOL allowPrint = [TiUtils boolValue:[args objectForKey:@"allowPrint"] def:YES];
    BOOL deleteSource = [TiUtils boolValue:[args objectForKey:@"deleteSource"] def:NO];
    
    KrollCallback *callback = [args objectForKey:@"completed"];
	ENSURE_TYPE(callback,KrollCallback);

    CFURLRef url = (CFURLRef)CFBridgingRetain([[NSURL alloc] initFileURLWithPath:inputFile]);
    CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL(url);
    BOOL encrypted = CGPDFDocumentIsEncrypted(pdf);
    
    if(encrypted){
        CFRelease(url);
        CGPDFDocumentRelease(pdf);
        NSMutableDictionary *event = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      NUMBOOL(NO),@"success",
                                      @"file already protected",@"message",
                                       outputFile,@"to",
                                          inputFile,@"from",
                                          nil];
            if(callback != nil ){
                [self _fireEventToListener:@"completed" withObject:event
                                listener:callback thisObject:nil];
        }
        
        return;
        
    }
    
    CFMutableDictionaryRef myDictionary = NULL;
    myDictionary = CFDictionaryCreateMutable(NULL, 0,
                                             &kCFTypeDictionaryKeyCallBacks,
                                             &kCFTypeDictionaryValueCallBacks);
    
    if(ownerPassword!=nil)
    {
        CFDictionarySetValue(myDictionary, kCGPDFContextOwnerPassword, (CFStringRef)ownerPassword);
    }

    CFDictionarySetValue(myDictionary, kCGPDFContextUserPassword, (CFStringRef)userPassword);

    
    if (!allowCopy){
        CFDictionarySetValue(myDictionary, kCGPDFContextAllowsCopying, kCFBooleanFalse);
    }

    
    CFURLRef pdfURLOutput = (CFURLRef)CFBridgingRetain([[NSURL alloc] initFileURLWithPath:outputFile]);
    NSInteger numberOfPages1 = CGPDFDocumentGetNumberOfPages(pdf);

    // Create the output context
    CGContextRef writeContext = CGPDFContextCreateWithURL(pdfURLOutput, NULL, myDictionary);
    
    // Loop variables
    CGPDFPageRef page;
    CGRect mediaBox;
    
    // Read the first PDF and generate the output pages
    NSLog(@"[DEBUG] Pages from pdf (%i)", numberOfPages1);
    for (int i=1; i<=numberOfPages1; i++) {
        page = CGPDFDocumentGetPage(pdf, i);
        mediaBox = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
        CGContextBeginPage(writeContext, &mediaBox);
        CGContextDrawPDFPage(writeContext, page);
        CGContextEndPage(writeContext);
    }

    // Finalize the output file
    CGPDFContextClose(writeContext);
    
    // Release from memory
    CFRelease(myDictionary);
    CFRelease(url);
    CFRelease(pdfURLOutput);
    CGPDFDocumentRelease(pdf);
    CGContextRelease(writeContext);
    
    NSMutableDictionary *event = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  outputFile,@"to",
                                  inputFile,@"from",
                                  nil];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:outputFile]){
        [event setObject:NUMBOOL(NO) forKey:@"success"];
        [event setObject:@"Failed writing protected file"
                  forKey:@"message"];
    }else{
        [event setObject:NUMBOOL(YES) forKey:@"success"];
        if(deleteSource){
             if(![[NSFileManager defaultManager] isDeletableFileAtPath:inputFile]){
                  NSLog(@"[ERROR] Unable to remove input file");
             }else{
                 NSLog(@"[DEBUG] Removing source file");
                 NSError *error;
                 BOOL deleted = [[NSFileManager defaultManager] removeItemAtPath:inputFile error:&error];
                 if (!deleted) NSLog(@"Error: %@", [error localizedDescription]);
             }
        }
    }

     if(callback != nil ){
        [self _fireEventToListener:@"completed" withObject:event
                          listener:callback thisObject:nil];
    }
}

@end
