/**
 * Securely Titanium Security Project
 * Copyright (c) 2009-2013 by Benjamin Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 *
 */
package bencoding.securely;

import javax.crypto.KeyGenerator;
import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;

import org.appcelerator.kroll.KrollModule;
import org.appcelerator.kroll.annotations.Kroll;
import org.appcelerator.titanium.TiApplication;


@Kroll.module(name="Securely", id="bencoding.securely")
public class SecurelyModule extends KrollModule
{

	public static final String SECURELY_MODULE_FULL_NAME = "bencoding.securely";
	public static boolean DEBUG = false;
	
	@Kroll.constant public static final int PROPERTY_TYPE_KEYCHAIN = 1;
	@Kroll.constant public static final int PROPERTY_TYPE_PREFERENCES = 2;
	
	@Kroll.constant public static final int PROPERTY_SECURE_LEVEL_LOW = 1;
	@Kroll.constant public static final int PROPERTY_SECURE_LEVEL_MED = 2;
	@Kroll.constant public static final int PROPERTY_SECURE_LEVEL_HIGH = 3;
		
	public SecurelyModule()
	{
		super();
	}

	@Kroll.onAppCreate
	public static void onAppCreate(TiApplication app)
	{
	}

	@Deprecated
	@Kroll.method
	public void disableLevel2Logging()
	{
		LogHelpers.UpdateSecureWrite(false);
	}
	@Deprecated
	@Kroll.method
	public void enableLevel2Logging()
	{
		LogHelpers.UpdateSecureWrite(true);
	}


	@Kroll.method
	public void setDebug(boolean value)
	{
		DEBUG = value;
	}
	
	@Kroll.method
	public void disableLogging()
	{
		DEBUG = false;
	}
	@Kroll.method
	public void enableLogging()
	{
		DEBUG = true;
	}
	@Kroll.method
	public String generateRandomKey(@Kroll.argument(optional=true) Object seedLength) {
		int randomSeed = 128;
		if((seedLength!=null) && (seedLength instanceof Integer)){			
			randomSeed=(Integer)seedLength;
		}
		try {	
		    KeyGenerator generator = KeyGenerator.getInstance("AES");
		    generator.init(randomSeed);

		    SecretKey key = generator.generateKey();
		    return generateDerivedKey(new String(key.getEncoded()));
		} catch (Exception e) {
			e.printStackTrace();
			LogHelpers.Log(e);
			return null;			
		}		
	}
	@Kroll.method
	public String generateDerivedKey(String seed) {
		try {			
			SecretKeySpec key = AESCrypto.builKey(seed);
			return new String(key.getEncoded());
		} catch (Exception e) {
			e.printStackTrace();
			LogHelpers.Log(e);
			return null;			
		}		
	}
}

