/**
 * Securely Titanium Security Project
 * Copyright (c) 2009-2013 by Benjamin Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 *
 */
package bencoding.securely;


import java.util.HashMap;

import org.appcelerator.kroll.annotations.Kroll;
import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.titanium.TiApplication;
import org.appcelerator.titanium.util.TiConvert;
import org.appcelerator.titanium.TiC;

import com.google.gson.Gson;

import org.json.*;

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

	private String ComposeSecret(String key){
		String Seed = _secret + "_" + key;
		String composed =  SHA.sha256(Seed);
		return ((composed == null)? Seed : composed);
	};
	private String EncryptContent(String key, String value){
		try {
			String EncryptedText = AES128Crypto.encrypt(key, value);
			return EncryptedText;
		} catch (Exception e) {
			e.printStackTrace();
			LogHelpers.Log(e);
			return null;
		}
	}
	private String DecryptContent(String PassKey, String value){
		try {
			String ClearText = AES128Crypto.decrypt(PassKey, value);
			return ClearText;
		} catch (Exception e) {
			e.printStackTrace();
			LogHelpers.Log(e);
			return null;
		}
	}	
	@Override
	public void handleCreationDict(KrollDict options)
	{
		super.handleCreationDict(options);
		if (options.containsKey("identifier")) {
			String identifier = TiConvert.toString(options.get("identifier"));
			appProperties = new Properties(TiApplication.getInstance().getApplicationContext(),buildName(identifier),false);
			LogHelpers.DebugLog("Setting identifer to : " + identifier);			
		}
		if (options.containsKey("secret")) {
			_secret = TiConvert.toString(options.get("secret"));
			LogHelpers.DebugLog("Setting secret to : " + _secret);		
		}		
	}
	
	@Kroll.method
	public void setSecret(String value){
		_secret = value;
		LogHelpers.DebugLog("Setting secret to : " + _secret);			
	}
	
	@Kroll.method
	public void setIdentifier(String key){
		appProperties = new Properties(TiApplication.getInstance().getApplicationContext(),key,false);
		LogHelpers.DebugLog("Setting identifer to : " + key);		
	}
	@Kroll.method
	public boolean getBool(String key,@Kroll.argument(optional=true) Object defaultValue )
	{
		Boolean ifMissingValue = false;
		if(!appProperties.hasProperty(key)){
			if(defaultValue != null){
				ifMissingValue = TiConvert.toBoolean(defaultValue);
			}
			return ifMissingValue;
		}

		String DecryptedStored = getString(key,ifMissingValue);
		return Converters.StringToBoolean(DecryptedStored);
	}

	@Kroll.method
	public double getDouble(String key,@Kroll.argument(optional=true) Object defaultValue )
	{
		double ifMissingValue = 0D;
		if(!appProperties.hasProperty(key)){
			if(defaultValue != null){
				ifMissingValue = TiConvert.toDouble(defaultValue);
			}		
			return ifMissingValue;
		}
		
		String DecryptedStored = getString(key,ifMissingValue);
		return Converters.StringToDouble(DecryptedStored);
	}

	@Kroll.method
	public int getInt(String key,@Kroll.argument(optional=true) Object defaultValue)
	{
		int ifMissingValue = 0;
		if(!appProperties.hasProperty(key)){
			if(defaultValue != null){
				ifMissingValue = TiConvert.toInt(defaultValue);
			}			
			return ifMissingValue;
		}		
		
		String DecryptedStored = getString(key,ifMissingValue);		
		return Converters.StringToInt(DecryptedStored);
	}

	@Kroll.method
	public String getString(String key,@Kroll.argument(optional=true) Object defaultValue)
	{
		String ifMissingValue = null;
		if(!appProperties.hasProperty(key)){
			if(defaultValue != null){
				ifMissingValue = TiConvert.toString(defaultValue);
			}	
			
			return ifMissingValue;
		}
		String StoredValue = appProperties.getString(key, ifMissingValue);
		String tempS = ComposeSecret(key);
		String ReturnValue = DecryptContent(StoredValue,tempS);
		return ReturnValue;
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
		if (appProperties.hasProperty(key)) {
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
			String ValueAsString = Converters.BooleanToString(value);
			String tempS = ComposeSecret(key);
			String EncryptedValue = EncryptContent(tempS,ValueAsString);					
			appProperties.setString(key, EncryptedValue);
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
			String ValueAsString = Converters.DoubleToString(value);
			String tempS = ComposeSecret(key);
			String EncryptedValue = EncryptContent(tempS,ValueAsString);					
			appProperties.setString(key, EncryptedValue);
			fireEvent(TiC.EVENT_CHANGE, null);
		}

	}

	@Kroll.method
	public void setInt(String key, int value)
	{
		Object intValue = getPreferenceValue(key);
		if (intValue == null || !intValue.equals(value)) {
			String ValueAsString = Converters.IntToString(value);
			String tempS = ComposeSecret(key);
			String EncryptedValue = EncryptContent(tempS,ValueAsString);					
			appProperties.setString(key, EncryptedValue);
			fireEvent(TiC.EVENT_CHANGE, null);
		}

	}

	@Kroll.method
	public void setString(String key, String value)
	{
		Object stringValue = getPreferenceValue(key);
		if (stringValue == null || !stringValue.equals(value)) {
			String ValueAsString = TiConvert.toString(stringValue);
			String tempS = ComposeSecret(key);
			String EncryptedValue = EncryptContent(tempS,ValueAsString);						
			appProperties.setString(key, EncryptedValue);
			fireEvent(TiC.EVENT_CHANGE, null);
		}
	}
	
	@Kroll.method
	public void setObject(String key, @SuppressWarnings("rawtypes") HashMap value)
	{
		if(value == null){
			setString(key,null);
			return;
		}
		
		Gson gson = new Gson();
        String jsonText = gson.toJson(value);
        LogHelpers.DebugLog("object jsonText : " + jsonText);	
		setString(key,jsonText);		
	}
	@SuppressWarnings("rawtypes")
	@Kroll.method
	public HashMap getObject(String key, @Kroll.argument(optional=true) HashMap defaultValue)
	{	
		if(!appProperties.hasProperty(key)){
			return defaultValue;
		}else{
			String temp = getString(key,null);
			LogHelpers.DebugLog("object JSON : " + temp);	
			if(temp == null){
				return null;
			}
			
			try {
				JSONObject jsonObject = new JSONObject(temp);
				return (HashMap)Converters.toMap(jsonObject);
			} catch (JSONException e) {
				e.printStackTrace();
				LogHelpers.Log(e);				
				return null;
			}						
		}

	}
	@Kroll.method
	public void setList(String key, Object value)
	{
		if(value == null){
			setString(key,null);
			return;
		}
		if (!(value.getClass().isArray())) {
			throw new IllegalArgumentException("Argument must be an array");
		}
		
		setString(key,Converters.objectToGson(value));
	}


	@Kroll.method
	public Object[] getList(String key, @Kroll.argument(optional=true) Object defaultValue)
	{
		if(!appProperties.hasProperty(key)){
			if(defaultValue==null){
				return null;
			}else{
				if (!(defaultValue.getClass().isArray())) {
					throw new IllegalArgumentException("Default value must be an array");
				}					
				return (Object[]) defaultValue;
			}			
		}else{
			String temp = getString(key,null);
			LogHelpers.DebugLog("object JSON : " + temp);	
			if(temp == null){
				return null;
			}
			
			try {
				JSONArray inputArray = new JSONArray(temp);				
				Object[] result = new Object[inputArray.length()];
				for (int iLoop = 0; iLoop < inputArray.length(); iLoop++) {				
					result[iLoop] =Converters.toMap((JSONObject) inputArray.get(iLoop));
				}
				return result;
			} catch (JSONException e) {
				e.printStackTrace();
				LogHelpers.Log(e);
				return null;
			}				
		}
	}	
	@Kroll.method
	public void setAccessGroup(String key){
		LogHelpers.DebugLog("setAccessGroup is not used on Android, method is available for parity sake only");		
	}
	@Kroll.method
	public void removeAllProperties(){
		appProperties.getPreference().edit().clear().commit();
	}
}
