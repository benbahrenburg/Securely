/**
 * Securely Titanium Security Project
 * Copyright (c) 2014 by Benjamin Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiModule.h"

@interface BencodingSecurelyModule : TiModule 
{
}

extern int const kBCXKeyChain_Storage;
extern int const kBCXPLIST_Storage;
extern int const kBCXProperty_Security_Low;
extern int const kBCXProperty_Security_Med;
extern int const kBCXProperty_Security_High;
@end
