/**
 * Securely Titanium Security Project
 * Copyright (c) 2009-2013 by Benjamin Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 *
 */
package bencoding.securely;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class SHA {

	public static String sha256(String data){

		try
		{
			byte[] b = data.getBytes();
			MessageDigest algorithm = MessageDigest.getInstance("SHA-256");
			algorithm.reset();
			algorithm.update(b);
			byte messageDigest[] = algorithm.digest();
			StringBuilder result = new StringBuilder();
			for (int i=0; i < messageDigest.length; i++) {
				result.append(Integer.toString(( messageDigest[i] & 0xff ) + 0x100, 16).substring(1));
			}
			return result.toString();
		} catch(NoSuchAlgorithmException e) {
			LogHelpers.Log("SHA256 is not a supported algorithm");
			return null;
		}
			
	}
}
