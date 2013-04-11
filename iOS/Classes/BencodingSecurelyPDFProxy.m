/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2013 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "BencodingSecurelyPDFProxy.h"
#import "TiUtils.h"
@implementation BencodingSecurelyPDFProxy

-(NSString*)getNormalizedPath:(NSString*)source
{
	// NOTE: File paths may contain URL prefix as of release 1.7 of the SDK
	if ([source hasPrefix:@"file:/"]) {
		NSURL* url = [NSURL URLWithString:source];
		return [url path];
	}
    
	// NOTE: Here is where you can perform any other processing needed to
	// convert the source path. For example, if you need to handle
	// tilde, then add the call to stringByExpandingTildeInPath
    
	return source;
}


-(void) unlock:(id)args
{
    ENSURE_SINGLE_ARG(args,NSDictionary);
    ENSURE_TYPE(args,NSDictionary);
    
    //Make sure we're on the UI thread, this stops bad things
	ENSURE_UI_THREAD(protect,args);
    
    if (![args objectForKey:@"secret"]) {
		NSLog(@"[ERROR] decrypt secret is required");
		return;
	}
    NSString* secret = [args objectForKey:@"secret"];
    BOOL deleteSource = [TiUtils boolValue:[args objectForKey:@"deleteSource"] def:NO];
    NSString* fileEncryptedFile = [args objectForKey:@"from"];
	NSString* protectedFile = [self getNormalizedPath:fileEncryptedFile];
    
    if (protectedFile == nil) {
		NSLog(@"[ERROR] %@",[NSString stringWithFormat:@"Invalid protected file path provided [%@]", protectedFile]);
		return;
	}
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:protectedFile]){
 		NSLog(@"[ERROR] %@",[NSString stringWithFormat:@"Invalid protected file path provided [%@]", protectedFile]);
		return;
    }
    
    NSString* fileDecryptedFile = [args objectForKey:@"to"];
	NSString* outputFile = [self getNormalizedPath:fileDecryptedFile];
    
    if (outputFile == nil) {
		NSLog(@"[ERROR] %@",[NSString stringWithFormat:@"Invalid decrypt file path provided [%@]", outputFile]);
		return;
	}
    
    if([[NSFileManager defaultManager] fileExistsAtPath:outputFile]){
        NSLog(@"[DEBUG] Output file already exists, removing");
        NSError *error;
        BOOL deleted = [[NSFileManager defaultManager] removeItemAtPath:protectedFile error:&error];
        if (!deleted) NSLog(@"Error: %@", [error localizedDescription]);
    }
    
    if (![args objectForKey:@"completed"]) {
		NSLog(@"[ERROR] completed callback method is required");
		return;
	}
    
    KrollCallback *callback = [[args objectForKey:@"completed"] retain];
	ENSURE_TYPE(callback,KrollCallback);

    CFURLRef url = (CFURLRef)[NSURL fileURLWithPath:protectedFile];
    CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL((CFURLRef)url);
    BOOL encrypted = CGPDFDocumentIsEncrypted(pdf);
 
    NSMutableDictionary *event = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  protectedFile,@"to",
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
        
        CFURLRef pdfURLOutput = (CFURLRef)[[NSURL alloc] initFileURLWithPath:protectedFile];
        NSInteger numberOfPages1 = CGPDFDocumentGetNumberOfPages(pdf);
        // Create the output context
        CGContextRef writeContext = CGPDFContextCreateWithURL(pdfURLOutput, NULL, NULL);

        // Loop variables
        CGPDFPageRef page;
        CGRect mediaBox;
        
        // Read the first PDF and generate the output pages
        NSLog(@"[Debug] Pages from pdf (%i)", numberOfPages1);
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
        CFRelease(pdfURLOutput);
        CGContextRelease(writeContext);
        
        [event setObject:NUMBOOL(YES) forKey:@"success"];
    }

    // Release from memory
    CFRelease(url);
    CGPDFDocumentRelease(pdf);
 
    if(unlocked){
        if(![[NSFileManager defaultManager] fileExistsAtPath:protectedFile]){
            [event setObject:NUMBOOL(NO) forKey:@"success"];
            [event setObject:@"Failed unlocking protected file"
                      forKey:@"message"];
        }else{
            if(deleteSource){
                NSLog(@"[DEBUG] Removing source file");
                NSError *error;
                BOOL deleted = [[NSFileManager defaultManager] removeItemAtPath:protectedFile error:&error];
                if (!deleted) NSLog(@"Error: %@", [error localizedDescription]);
            }
        }
    }
    
    if(callback != nil ){
        [self _fireEventToListener:@"completed" withObject:event
                          listener:callback thisObject:nil];
        [callback autorelease];
    }
    
}
-(void) protect:(id)args
{
    ENSURE_SINGLE_ARG(args,NSDictionary);
    ENSURE_TYPE(args,NSDictionary);
 
    //Make sure we're on the UI thread, this stops bad things
	ENSURE_UI_THREAD(protect,args);
    
    if (![args objectForKey:@"userPassword"]) {
		NSLog(@"[ERROR] secret is required");
		return;
	}

    NSString* userPassword = [args objectForKey:@"userPassword"];
    
    NSString* ownerPassword = nil;
    if ([args objectForKey:@"ownerPassword"]) {
        ownerPassword = [args objectForKey:@"ownerPassword"];
	}
    
    NSString* filePlainFile = [args objectForKey:@"from"];
	NSString* sourceFile = [self getNormalizedPath:filePlainFile];
    
    if (sourceFile == nil) {
		NSLog(@"[ERROR] %@",[NSString stringWithFormat:@"Invalid source file path provided [%@]", sourceFile]);
		return;
	}
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:sourceFile]){
 		NSLog(@"[ERROR] %@",[NSString stringWithFormat:@"Invalid source file path provided [%@]", sourceFile]);
		return;
    }
    
    NSString* fileEncryptedFile = [args objectForKey:@"to"];
	NSString* protectedFile = [self getNormalizedPath:fileEncryptedFile];
    
    if (protectedFile == nil) {
		NSLog(@"[ERROR] %@",[NSString stringWithFormat:@"Invalid protected file path provided [%@]", protectedFile]);
		return;
	}
    
    if([[NSFileManager defaultManager] fileExistsAtPath:protectedFile]){
        NSLog(@"[Debug] File already exists, removing");
        NSError *error;
        BOOL deleted = [[NSFileManager defaultManager] removeItemAtPath:protectedFile error:&error];
        if (!deleted) NSLog(@"Error: %@", [error localizedDescription]);
    }
    
    if (![args objectForKey:@"completed"]) {
		NSLog(@"[ERROR] completed callback method is required");
		return;
	}

    BOOL allowCopy = [TiUtils boolValue:[args objectForKey:@"allowCopy"] def:YES];
    BOOL allowPrint = [TiUtils boolValue:[args objectForKey:@"allowPrint"] def:YES];
    BOOL deleteSource = [TiUtils boolValue:[args objectForKey:@"deleteSource"] def:NO];
    
    KrollCallback *callback = [[args objectForKey:@"completed"] retain];
	ENSURE_TYPE(callback,KrollCallback);

    CFMutableDictionaryRef myDictionary = NULL;
    // This dictionary contains extra options mostly for 'signing' the PDF

    CFURLRef url = (CFURLRef)[NSURL fileURLWithPath:sourceFile];
    CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL((CFURLRef)url);
    BOOL encrypted = CGPDFDocumentIsEncrypted(pdf);
    
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

    if (!allowPrint){
        CFDictionarySetValue(myDictionary, kCGPDFContextAllowsPrinting, kCFBooleanFalse);
    }
    
    CFURLRef pdfURLOutput = (CFURLRef)[[NSURL alloc] initFileURLWithPath:protectedFile];
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
    CFRelease(url);
    CFRelease(pdfURLOutput);
    CGPDFDocumentRelease(pdf);
    CGContextRelease(writeContext);

    
    NSMutableDictionary *event = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  protectedFile,@"to",
                                  sourceFile,@"from",
                                  nil];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:protectedFile]){
        [event setObject:NUMBOOL(NO) forKey:@"success"];
        [event setObject:@"Failed writing protected file"
                  forKey:@"message"];
    }else{
        if(deleteSource){
            NSLog(@"[DEBUG] Removing source file");
            NSError *error;
            BOOL deleted = [[NSFileManager defaultManager] removeItemAtPath:protectedFile error:&error];
            if (!deleted) NSLog(@"Error: %@", [error localizedDescription]);
        }
    }

     if(callback != nil ){
        [self _fireEventToListener:@"completed" withObject:event
                          listener:callback thisObject:nil];
        [callback autorelease];
    }
}

@end
