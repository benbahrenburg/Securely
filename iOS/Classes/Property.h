/**
 * Securely Titanium Security Project
 * Copyright (c) 2014 by Benjamin Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import <Foundation/Foundation.h>
@protocol Property <NSObject>

@required
-(id)initWithIdentifierAndOptions:(NSString *)identifier
                  withAccessGroup:(NSString*)accessGroup
                 withEncryptedField:(BOOL)encryptFields
              withEncryptedValues:(BOOL)encryptedValues
                       withSecret:(NSString*)secret;
- (id)objectForKey:(NSString *)defaultName;
-(BOOL)propertyExists: (NSString *) key;
-(id)getBool:(NSString*)key;
-(id)getDouble:(NSString*)key;
-(id)getInt:(NSString*)key;
-(NSString *)getString:(NSString*)key;
-(id)getList:(NSString*)key;
-(id)getObject:(NSString*)key;
-(void)setBool:(BOOL)value withKey:(NSString*)key;
-(void)setDouble:(double)value withKey:(NSString*)key;
-(void)setInt:(int)value withKey:(NSString*)key;
-(void)setString:(NSString*)value withKey:(NSString*)key;
-(void)setList:(id)value withKey:(NSString*)key;
-(void)setObject:(id)value withKey:(NSString*)key;
-(id)hasProperty:(NSString*)key;
-(void)removeProperty:(NSString*)key;
-(void)setIdentifier:(NSString*)value;
-(void)setAccessGroup:(NSString*)value;
-(void)removeAllProperties;
-(id)listProperties;

@end
