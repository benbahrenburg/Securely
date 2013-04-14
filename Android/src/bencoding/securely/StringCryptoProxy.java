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

import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.kroll.annotations.Kroll;

@Kroll.proxy(creatableInModule=SecurelyModule.class)
public class StringCryptoProxy  extends KrollProxy {

	public StringCryptoProxy()
	{
		super();		
	}

	@Kroll.method
	public static String sha256(String data) {
		return SHA.sha256(data);
	}

	@Override
	public void handleCreationDict(KrollDict options)
	{
		super.handleCreationDict(options);
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
	
	@Kroll.method
	public String AESEncrypt(String key, String value) {
		try {			
			String EncryptedText = AESCrypto.encrypt(key, value);
			return EncryptedText;
		} catch (Exception e) {
			e.printStackTrace();
			LogHelpers.Log(e);
			return null;			
		}		
	}
	@Kroll.method
	public String AESDecrypt(String key, String value) {		
		try {
			String ClearText =  AESCrypto.decrypt(key, value);
			return ClearText;
		} catch (Exception e) {
			e.printStackTrace();
			LogHelpers.Log(e);
			return null;			
		}
	}
	@Kroll.method
	public String DESEncrypt(String key, String value) {
		try {
			String EncryptedText = DESCrypto.encrypt(key, value);
			return EncryptedText;
		} catch (Exception e) {
			e.printStackTrace();
			LogHelpers.Log(e);
			return null;			
		}	
	}
	@Kroll.method
	public String DESDecrypt(String key, String value) {
		try {
			String ClearText = DESCrypto.decrypt(key, value);
			return ClearText;
		} catch (Exception e) {
			e.printStackTrace();
			LogHelpers.Log(e);
			return null;			
		}
	}
	
	@Kroll.method
    public String toHex(String txt) {
        return Converters.toHex(txt.getBytes());
    }
	
	@Kroll.method
	public String fromHex(String hex) {
	     return new String(Converters.toByte(hex));
	}
}
