/**
 * Securely Titanium Security Project
 * Copyright (c) 2009-2013 by Benjamin Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 *
 */
package bencoding.securely;

import java.security.MessageDigest;
import java.util.ArrayList;
import java.util.List;

import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.kroll.annotations.Kroll;
import org.appcelerator.titanium.TiApplication;

import android.app.Activity;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.Signature;
import android.provider.Settings;
import android.provider.Settings.SettingNotFoundException;
import android.util.Base64;

@Kroll.proxy(creatableInModule=SecurelyModule.class)
public class PlatformProxy extends KrollProxy {
	public PlatformProxy(){
		super();
	}

	@Kroll.method
	public String[] getSignatures() {
		List<String> list = new ArrayList<String>();
		 try {
			 Activity content = TiApplication.getAppRootOrCurrentActivity();			 
		     PackageInfo packageInfo = content.getPackageManager().getPackageInfo(content.getPackageName(), PackageManager.GET_SIGNATURES);

		     for (Signature signature : packageInfo.signatures) {
		        //byte[] signatureBytes = signature.toByteArray();
		        MessageDigest md = MessageDigest.getInstance("SHA");
		        md.update(signature.toByteArray());
		        final String currentSignature = Base64.encodeToString(md.digest(), Base64.DEFAULT);
		        list.add(currentSignature);
		     }

		    } catch (Exception e) {
		    		e.printStackTrace();
		    }

		return (String[]) list.toArray();
	}
	
	@Kroll.method
	public boolean debuggerIsAttached(){
		return (TiApplication.getAppRootOrCurrentActivity().getApplicationInfo().flags & ApplicationInfo.FLAG_DEBUGGABLE) != 0;	
	}
	
	@Kroll.method
	public String getInstallerName(){
		return TiApplication.getAppRootOrCurrentActivity().getPackageManager()
				.getInstallerPackageName(TiApplication.getAppRootOrCurrentActivity().getPackageName());
	
	}
	
	@Kroll.method
	public boolean lockPatternEnabled(){
		try {
			@SuppressWarnings("deprecation")
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
			@SuppressWarnings("deprecation")
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
			@SuppressWarnings("deprecation")
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
