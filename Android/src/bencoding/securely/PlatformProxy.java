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
import org.appcelerator.titanium.TiApplication;
import android.provider.Settings;
import android.provider.Settings.SettingNotFoundException;

@Kroll.proxy(creatableInModule=SecurelyModule.class)
public class PlatformProxy extends KrollProxy {
	public PlatformProxy(){
		super();
	}

	@Kroll.method
	public boolean lockPatternEnabled(){
		try {
			int enable = Settings.Secure.getInt(TiApplication.getInstance().getContentResolver(), Settings.Secure.LOCK_PATTERN_ENABLED);
			return (enable==1);
		} catch (SettingNotFoundException e) {
			e.printStackTrace();
			return false;
		}
		
	}
	@Kroll.method
	public boolean lockPatternVisible(){
		try {
			int enable = Settings.Secure.getInt(TiApplication.getInstance().getContentResolver(), Settings.Secure.LOCK_PATTERN_VISIBLE);
			return (enable==1);
		} catch (SettingNotFoundException e) {
			e.printStackTrace();
			return false;
		}
		
	}
	@Kroll.method
	public boolean deviceProvisioned(){
		try{
			int enable = Settings.Secure.getInt(TiApplication.getInstance().getContentResolver(),Settings.Secure.DEVICE_PROVISIONED);
			return (enable==1);
		} catch (SettingNotFoundException e) {
			e.printStackTrace();
			return true;
		}		
	}
	@Kroll.method
	public boolean allowSideLoading(){
		try{
			int enable = Settings.Secure.getInt(TiApplication.getInstance().getContentResolver(),Settings.Secure.INSTALL_NON_MARKET_APPS);
			return (enable==1);
		} catch (SettingNotFoundException e) {
			e.printStackTrace();
			return true;
		}		
	}

}
