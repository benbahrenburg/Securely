/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2013 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "BencodingSecurelyFileCryptoProxy.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import "TiFile.h"
#import "TiBlob.h"
#import "TiFilesystemFileProxy.h"
@implementation BencodingSecurelyFileCryptoProxy

#define fileURLify(foo)	[[NSURL fileURLWithPath:foo isDirectory:YES] absoluteString]

-(NSString*)resourcesDirectory
{
	return fileURLify([TiHost resourcePath]);
}

// internal
-(id)resolveFile:(id)arg
{
	if ([arg isKindOfClass:[TiFilesystemFileProxy class]])
	{
		return [arg path];
	}
	return [TiUtils stringValue:arg];
}

-(NSString*)pathFromComponents:(NSString*)path
{
	NSString * newpath;
    
	if ([path hasPrefix:@"file://localhost/"])
	{
		NSURL * fileUrl = [NSURL URLWithString:path];
		//Why not just crop? Because the url may have some things escaped that need to be unescaped.
		newpath =[fileUrl path];
	}
	else if ([path characterAtIndex:0]!='/')
	{
		NSURL* url = [NSURL URLWithString:[self resourcesDirectory]];
        newpath = [[url path] stringByAppendingPathComponent:[self resolveFile:path]];
	}
	else
	{
		newpath = [self resolveFile:path];
	}
        
    return [newpath stringByStandardizingPath];
}

-(NSData *) loadToData:(id)value
{
    NSData *data = nil;
    if([value isKindOfClass:[NSString class]])
    {
        
        NSURL* fileUrl = [self sanitizeURL:value];
        if (![fileUrl isKindOfClass:[NSURL class]]) {
            [self throwException:@"invalid image type"
                       subreason:[NSString stringWithFormat:@"expected TiBlob, String, TiFile, was: %@",[value class]]
                        location:CODELOCATION];
        }
        
        NSError* error = nil;
        data = [NSData dataWithContentsOfURL:fileUrl options:NSDataReadingUncached error:&error];
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
            [error release];
        } 
        
    }
    else if ([value isKindOfClass:[TiBlob class]])
    {
        data = [(TiBlob*)value data];
        
    }else if ([value isKindOfClass:[TiFile class]])
    {
        TiFile *file = (TiFile*)value;
        NSString *path = [file path];
        data = [NSData dataWithContentsOfFile:path];
    }
    
    return data;
    
}
-(NSString *)AESEncryptToFile:(id)args
{
    ENSURE_SINGLE_ARG(args,NSDictionary);
    ENSURE_TYPE(args,NSDictionary);
    
    id from = [args objectForKey:@"from"];
    id to = [args objectForKey:@"to"];;
    KrollCallback *callbackComplete = [args objectForKey:@"completed"];
    KrollCallback *callbackErr = [args objectForKey:@"error"];
    NSData *data = nil;
    
    if((![from isKindOfClass:[NSString class]]) ||
       (![from isKindOfClass:[NSString class]])||
       (![from isKindOfClass:[NSString class]]))
    {
        NSLog(@"Invalid from Parameter provided");
        return;
    }

    if((![to isKindOfClass:[NSString class]]) ||
       (![to isKindOfClass:[NSString class]])||
       (![to isKindOfClass:[NSString class]]))
    {
        NSLog(@"Invalid to Parameter provided");
        return;
    }
    
    
    NSData * fromData = [self loadToData:from];
    NSData * toData = [self loadToData:to];
    
}

-(NSString *)AESEncryptToBlob:(id)args
{
    
}

@end
