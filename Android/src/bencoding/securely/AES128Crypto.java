/**
 * Securely Titanium Security Project
 * Copyright (c) 2009-2013 by Benjamin Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 *
 */
package bencoding.securely;

import java.security.SecureRandom;

import javax.crypto.Cipher;
import javax.crypto.KeyGenerator;
import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;

public class AES128Crypto {

    public static String encrypt(String seed, String cleartext) throws Exception {
        byte[] rawKey = getRawKey(seed.getBytes());
        byte[] result = encrypt(rawKey, cleartext.getBytes());
        return Converters.toHex(result);
	}

	public static String decrypt(String seed, String encrypted) throws Exception {
        byte[] rawKey = getRawKey(seed.getBytes());
        byte[] enc = Converters.toByte(encrypted);
        byte[] result = decrypt(rawKey, enc);
        return new String(result);
	}

	private static byte[] getRawKey(byte[] seed) throws Exception {
	    KeyGenerator kgen = KeyGenerator.getInstance("AES");
	    SecureRandom sr = SecureRandom.getInstance("SHA1PRNG");
	    sr.setSeed(seed);
	    kgen.init(128, sr); // 192 and 256 bits may not be available
	    SecretKey skey = kgen.generateKey();
	    byte[] raw = skey.getEncoded();
	    return raw;
	}


	private static byte[] encrypt(byte[] raw, byte[] clear) throws Exception {
	    SecretKeySpec skeySpec = new SecretKeySpec(raw, "AES");
	        Cipher cipher = Cipher.getInstance("AES");
	    cipher.init(Cipher.ENCRYPT_MODE, skeySpec);
	    byte[] encrypted = cipher.doFinal(clear);
	        return encrypted;
	}

	private static byte[] decrypt(byte[] raw, byte[] encrypted) throws Exception {
	    SecretKeySpec skeySpec = new SecretKeySpec(raw, "AES");
	        Cipher cipher = Cipher.getInstance("AES");
	    cipher.init(Cipher.DECRYPT_MODE, skeySpec);
	    byte[] decrypted = cipher.doFinal(encrypted);
	        return decrypted;
	}
}
