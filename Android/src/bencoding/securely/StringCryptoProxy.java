/**
 * Securely Titanium Security Project
 * Copyright (c) 2009-2013 by Benjamin Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 *
 */
package bencoding.securely;

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

	@Kroll.method
	public String AESEncrypt(String key, String value) {
		try {
			String EncryptedText = AES128Crypto.encrypt(key, value);
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
			String ClearText = AES128Crypto.decrypt(key, value);
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
