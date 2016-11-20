/**
 * Securely Titanium Security Project
 * Copyright (c) 2009-2013 by Benjamin Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 *
 */
package bencoding.securely;

import java.security.MessageDigest;
import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;
import java.io.UnsupportedEncodingException;
import java.security.NoSuchAlgorithmException;
import java.util.Arrays;
 
public class AESCrypto {

    public static String encrypt(String seed, String cleartext) throws Exception {        
    	SecretKeySpec key = builKey(seed);
         Cipher cipher = Cipher.getInstance("AES/ECB/PKCS5Padding");
         cipher.init(Cipher.ENCRYPT_MODE, key);
         byte[] result = cipher.doFinal(cleartext.getBytes("UTF-8"));
         return Converters.toHex(result);	
	}

	public static String decrypt(String seed, String encrypted) throws Exception {
		SecretKeySpec key = builKey(seed);
		byte[] enc = Converters.toByte(encrypted);
		Cipher cipher = Cipher.getInstance("AES/ECB/PKCS5PADDING");
        cipher.init(Cipher.DECRYPT_MODE, key);
        byte[] original = cipher.doFinal(enc);
        return new String(original);
	}
	
    public static SecretKeySpec builKey(String myKey) {
        try {
        	byte[] key = myKey.getBytes("UTF-8");
        	//MessageDigest sha = MessageDigest.getInstance("SHA-1");
//            key = sha.digest(key);
//            key = Arrays.copyOf(key, 16); 
        	byte[] sha256 = MessageDigest.getInstance("SHA-256").digest(key);
            return new SecretKeySpec(sha256, "AES");
        } 
        catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
            return null;
        } 
        catch (UnsupportedEncodingException e) {
            e.printStackTrace();
            return null;
        }		
    }
}
