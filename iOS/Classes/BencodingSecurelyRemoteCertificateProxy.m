/**
 * Securely Titanium Security Project
 * Copyright (c) 2014 by Benjamin Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "BencodingSecurelyRemoteCertificateProxy.h"
#import <CommonCrypto/CommonDigest.h>
#import "TiUtils.h"

@implementation BencodingSecurelyRemoteCertificateProxy


-(void)_initWithProperties:(NSDictionary*)properties
{
    _debug = [TiUtils boolValue:@"debug" properties:properties def:NO];
}
- (BOOL)connection:(NSURLConnection *)connection
    canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    if(_debug){
      NSLog(@"[DEBUG] canAuthenticateAgainstProtectionSpace triggered");
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if(_debug){
        NSLog(@"[DEBUG] didReceiveAuthenticationChallenge triggered");
    }
}

- (void)connection:(NSURLConnection *)connection
    willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if(_debug){
        NSLog(@"[DEBUG] willSendRequestForAuthenticationChallenge triggered");
    }
    
    NSString *thumbprint = [self findFingerprint: SecTrustGetCertificateAtIndex(challenge.protectionSpace.serverTrust, 0)];
    
    [connection cancel];

    if(_debug){
        NSLog(@"[DEBUG] Thumbprint %@",thumbprint);
    }
    
    if ([self _hasListeners:@"completed"])
    {
        NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:
                               NUMBOOL(YES),@"success",
                               thumbprint,@"thumbprint",
                               nil];
        [self fireEvent:@"completed" withObject:event];
    }
    
}

- (void) connection: (NSURLConnection*)connection didFailWithError: (NSError*)error {
    
    NSLog(@"[ERROR] CONNECTION ERROR %@",[error localizedDescription]);
    
    if ([self _hasListeners:@"completed"])
    {
        NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:
                               NUMBOOL(NO),@"success",
                               [error localizedDescription],@"error",
                               nil];
        [self fireEvent:@"completed" withObject:event];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if(_debug){
        NSLog(@"[DEBUG] connectionDidFinishLoading triggered");
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if(_debug){
        NSLog(@"[DEBUG] didReceiveData triggered");
    }
}

- (NSString*) findFingerprint: (SecCertificateRef) cert {
    NSData* certData = (__bridge NSData*) SecCertificateCopyData(cert);
    unsigned char sha1Bytes[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(certData.bytes, (int)certData.length, sha1Bytes);
    NSMutableString *fingerprint = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 3];
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; ++i) {
        [fingerprint appendFormat:@"%02x ", sha1Bytes[i]];
    }
    return [fingerprint stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

-(void)getThumbprint:(id)args
{
    ENSURE_UI_THREAD(getThumbprint, args)
    
    ENSURE_SINGLE_ARG(args,NSDictionary);
    ENSURE_TYPE(args,NSDictionary);
    
    NSString* url =[TiUtils stringValue:@"url" properties:args];
    if(_debug){
        NSLog(@"[DEBUG] url %@",url);
    }
    
    NSURL *httpsURL = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:httpsURL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:15.0f];
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [self.connection start];
    
}
@end
