/**
 * Securely Titanium Security Project
 * Copyright (c) 2009-2013 by Benjamin Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 *
 */
package bencoding.securely;

import org.appcelerator.kroll.annotations.Kroll;
import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.titanium.TiApplication;
import org.appcelerator.titanium.util.TiConvert;
import org.appcelerator.titanium.TiC;

@Kroll.proxy(creatableInModule=SecurelyModule.class)
public class PropertiesProxy extends KrollProxy 
{
	private String _secret = "";
	private Properties appProperties;

	private String buildName(String name){
		return SecurelyModule.SECURELY_MODULE_FULL_NAME + "_" + name;
	};
	public PropertiesProxy()
	{
		super();		
		appProperties = new Properties(TiApplication.getInstance().getApplicationContext(),buildName(TiApplication.getInstance().getAppInfo().getId()),false);
		_secret = TiApplication.getInstance().getAppGUID();
	}

	@Override
	public void handleCreationDict(KrollDict options)
	{
		super.handleCreationDict(options);
		if (options.containsKey("identifier")) {
			String identifier = TiConvert.toString(options.get("identifier"));
			appProperties = new Properties(TiApplication.getInstance().getApplicationContext(),buildName(identifier),false);
			Helpers.DebugLog("Setting identifer to : " + identifier);			
		}
		if (options.containsKey("secret")) {
			_secret = TiConvert.toString(options.get("secret"));
			Helpers.DebugLog("Setting secret to : " + _secret);		
		}		
	}
	
	@Kroll.method
	public void setSecret(String value){
		_secret = value;
		Helpers.DebugLog("Setting secret to : " + _secret);			
	}
	
	@Kroll.method
	public void setIdentifier(String key){
		appProperties = new Properties(TiApplication.getInstance().getApplicationContext(),key,false);
		Helpers.DebugLog("Setting identifer to : " + key);		
	}
	@Kroll.method
	public boolean getBool(String key)
	{
		return appProperties.getBool(key, false);
	}

	@Kroll.method
	public double getDouble(String key)
	{
		return appProperties.getDouble(key, 0D);
	}

	@Kroll.method
	public int getInt(String key)
	{
		return appProperties.getInt(key, 0);
	}

	@Kroll.method
	public String getString(String key)
	{
		return appProperties.getString(key, null);
	}

	@Kroll.method
	public boolean hasProperty(String key)
	{
		return appProperties.hasProperty(key);
	}

	@Kroll.method
	public String[] listProperties()
	{
		return appProperties.listProperties();
	}

	@Kroll.method
	public void removeProperty(String key)
	{
		if (hasProperty(key)) {
			appProperties.removeProperty(key);
			fireEvent(TiC.EVENT_CHANGE, null);
		}
	}

	//Convenience method for pulling raw values
	public Object getPreferenceValue(String key)
	{
		return appProperties.getPreference().getAll().get(key);
	}

	@Kroll.method
	public void setBool(String key, boolean value)
	{
		Object boolValue = getPreferenceValue(key);
		if (boolValue == null || !boolValue.equals(value)) {
			appProperties.setBool(key, value);
			fireEvent(TiC.EVENT_CHANGE, null);
		}


	}

	@Kroll.method
	public void setDouble(String key, double value)
	{
		Object doubleValue = getPreferenceValue(key);
		//Since there is no double type in SharedPreferences, we store doubles as strings, i.e "10.0"
		//so we need to convert before comparing.
		if (doubleValue == null || !doubleValue.equals(String.valueOf(value))) {
			appProperties.setDouble(key, value);
			fireEvent(TiC.EVENT_CHANGE, null);
		}

	}

	@Kroll.method
	public void setInt(String key, int value)
	{
		Object intValue = getPreferenceValue(key);
		if (intValue == null || !intValue.equals(value)) {
			appProperties.setInt(key, value);
			fireEvent(TiC.EVENT_CHANGE, null);
		}

	}

	@Kroll.method
	public void setString(String key, String value)
	{
		Object stringValue = getPreferenceValue(key);
		if (stringValue == null || !stringValue.equals(value)) {
			appProperties.setString(key, value);
			fireEvent(TiC.EVENT_CHANGE, null);
		}
	}
	@Kroll.method
	public void setAccessGroup(String key){
		Helpers.DebugLog("setAccessGroup is not used on Android, method is available for parity sake only");		
	}
}
