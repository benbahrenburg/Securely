/**
 * Securely Titanium Security Project
 * Copyright (c) 2014 by Benjamin Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "BencodingSecurelyCapabilitiesProxy.h"
#import "TiUtils.h"
#import "BCXCryptoUtilities.h"

@implementation BencodingSecurelyCapabilitiesProxy

-(NSNumber *) touchIDAvailable:(id)unused
{
    return NUMBOOL([BCXCryptoUtilities touchIDEnabled]);
}

-(NSNumber *) passwordCurrentlyEnabled:(id)unused
{
    return NUMBOOL([BCXCryptoUtilities passwordCurrentlyEnabled]);
}

@end
