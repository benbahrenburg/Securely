/**
 * Securely Titanium Security Project
 * Copyright (c) 2009-2013 by Benjamin Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 *
 */
package bencoding.securely;

import java.math.BigInteger;
import java.security.SecureRandom;

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

	@Kroll.method
	public void disableLevel2Logging()
	{
		LogHelpers.UpdateSecureWrite(false);
	}
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
		int randomSeed = 130;
		if((seedLength!=null) && (seedLength instanceof Integer)){			
			randomSeed=(Integer)seedLength;
		}
		try {			
			SecureRandom random = new SecureRandom();
			String seed = new BigInteger(randomSeed, random).toString(32);
			return generateDerivedKey(seed);
		} catch (Exception e) {
			e.printStackTrace();
			LogHelpers.Log(e);
			return null;			
		}		
	}
	@Kroll.method
	public String generateDerivedKey(String seed) {
		try {			
			String genKey = AESCrypto.getRawKey(seed.getBytes()).toString();
			return genKey;
		} catch (Exception e) {
			e.printStackTrace();
			LogHelpers.Log(e);
			return null;			
		}		
	}
}

