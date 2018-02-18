/**
 * Securely Titanium Security Project
 * Copyright (c) 2009-2013 by Benjamin Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 *
 */
package bencoding.securely;
import org.appcelerator.kroll.common.Log;

public class LogHelpers {
	
	private static final boolean _writeIfSecure = false;
	public LogHelpers()
	{
		super();
	}

	@Deprecated
	public static void UpdateSecureWrite(boolean value){
		Log.w(SecurelyModule.SECURELY_MODULE_FULL_NAME, "This method has been deprecated and has no effect in this version of the module.");
	}
	public static void Level2Log(String message){
		if(_writeIfSecure){
			Log.i(SecurelyModule.SECURELY_MODULE_FULL_NAME, message);
		}
	}
	public static void info(String message){
		Log.i(SecurelyModule.SECURELY_MODULE_FULL_NAME, message);
	}
	public static void Log(String message){
		if(SecurelyModule.DEBUG){
			Log.i(SecurelyModule.SECURELY_MODULE_FULL_NAME, message);
		}
	}
	public static void error(String message){
		Log.e(SecurelyModule.SECURELY_MODULE_FULL_NAME, message);
	}
	public static void error(Exception e){
		Log.e(SecurelyModule.SECURELY_MODULE_FULL_NAME, e.toString());
	}	
	public static void  Log(Exception e){
		if(SecurelyModule.DEBUG){
			Log.i(SecurelyModule.SECURELY_MODULE_FULL_NAME, e.toString());
		}
		
	}	
	public static void DebugLog(String message){
		if(SecurelyModule.DEBUG){
			Log.d(SecurelyModule.SECURELY_MODULE_FULL_NAME, message);
		}
	}
}
