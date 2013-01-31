/**
 * Securely Titanium Security Project
 * Copyright (c) 2009-2013 by Benjamin Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 *
 */
package bencoding.securely;

import org.appcelerator.kroll.KrollModule;
import org.appcelerator.kroll.annotations.Kroll;
import org.appcelerator.titanium.TiApplication;


@Kroll.module(name="Securely", id="bencoding.securely")
public class SecurelyModule extends KrollModule
{

	public static final String SECURELY_MODULE_FULL_NAME = "becoding.securely";
	// Standard Debugging variables
//	private static final String LCAT = "SecurelyModule";
//	private static final boolean DBG = TiConfig.LOGD;
	
	public SecurelyModule()
	{
		super();
	}

	@Kroll.onAppCreate
	public static void onAppCreate(TiApplication app)
	{
//		Log.d(DBG, "inside onAppCreate");
		// put module init code that needs to run when the application is created
	}

	@Kroll.method
	public void disableLogging()
	{
		LogHelpers.UpdateWriteStatus(false);
	}
	@Kroll.method
	public void enableLogging()
	{
		LogHelpers.UpdateWriteStatus(true);
	}
}

