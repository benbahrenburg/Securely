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
	
	private static boolean _writeToLog = true;
	private static boolean _writeIfSecure = false;
	public LogHelpers()
	{
		super();
	}
	
	public static void UpdateWriteStatus(boolean value){
		_writeToLog = value;
	}
	public static void UpdateSecureWrite(boolean value){
		_writeIfSecure = value;
	}	
	public static void Level2Log(String message){
		if(_writeIfSecure){
			Log.i(SecurelyModule.SECURELY_MODULE_FULL_NAME, message);
		}
		
	}	
	public static void  Log(String message){
		if(_writeToLog){
			Log.i(SecurelyModule.SECURELY_MODULE_FULL_NAME, message);
		}
		
	}
	public static void  Log(Exception e){
		if(_writeToLog){
			Log.i(SecurelyModule.SECURELY_MODULE_FULL_NAME, e.toString());
		}
		
	}	
	public static void DebugLog(String message){
		if(_writeToLog){
			Log.d(SecurelyModule.SECURELY_MODULE_FULL_NAME, message);
		}
	}
}
