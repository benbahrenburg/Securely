/**
 * Securely Titanium Security Project
 * Copyright (c) 2009-2013 by Benjamin Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 *
 */
package bencoding.securely;


import java.util.HashMap;
import java.util.List;

import org.appcelerator.kroll.annotations.Kroll;
import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.KrollPropertyChange;
import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.kroll.KrollProxyListener;
import org.appcelerator.titanium.TiApplication;
import org.appcelerator.titanium.TiLifecycle;
import org.appcelerator.titanium.util.TiConvert;

import android.app.Activity;

@Kroll.proxy(creatableInModule=SecurelyModule.class)
public class PropertiesProxy  extends KrollProxy implements TiLifecycle.OnLifecycleEvent, KrollProxyListener 
{
	private String _secret = "";
	private IPropertiesProvider _provider = null;
	
	private String _identifier;
	private Boolean _encryptValues = false;
	private Boolean _encryptFieldNames = false;
	private static String _changedEventName = "changed";
	
	private static String STORAGE_TYPE ="storageType";
	private static String SECURITY_LEVEL ="securityLevel";
	
	private String buildName(String name){
		return SecurelyModule.SECURELY_MODULE_FULL_NAME + "_" + name;
	};
	
	public PropertiesProxy()
	{
		super();	
		_encryptValues = false;
		_encryptFieldNames = false;
		_identifier = buildName(TiApplication.getInstance().getAppGUID());
		_secret = TiApplication.getInstance().getAppGUID();
	}

	private String keyEncrypt(String key){
		if(_encryptFieldNames){
			String composed =  SHA.sha256(key);
			return ((composed == null)? key : composed);			
		}else{
			return key;
		}

	};
	
	private boolean keyExists(String key){		
		return _provider.hasProperty(((_encryptFieldNames) ? keyEncrypt(key) :key ));	
	}
		
	private void fireChanged(String propertyName, String actionType){
        if (hasListeners(_changedEventName)) {
            HashMap<String, Object> event = new HashMap<String, Object>();
            event.put("propertyName",propertyName);
            event.put("actionType",actionType);	            
            fireEvent(_changedEventName, event);
        }else{
        	LogHelpers.DebugLog("[DEBUG] no changed listener defined");
        }
	}
	
	@Override
	public void handleCreationDict(KrollDict options)
	{
		super.handleCreationDict(options);
		
		int storageType = options.optInt(STORAGE_TYPE, SecurelyModule.PROPERTY_TYPE_PREFERENCES);
		int securityLevel = options.optInt(SECURITY_LEVEL, SecurelyModule.PROPERTY_SECURE_LEVEL_MED);
		
		if((storageType != SecurelyModule.PROPERTY_TYPE_PREFERENCES) && (storageType != SecurelyModule.PROPERTY_TYPE_KEYCHAIN)){
			LogHelpers.error("Invalid storageType provided, defaulting to Preference Storage");
			storageType = SecurelyModule.PROPERTY_TYPE_PREFERENCES;
		}
	    
		if((storageType == SecurelyModule.PROPERTY_TYPE_PREFERENCES) && (securityLevel == SecurelyModule.PROPERTY_SECURE_LEVEL_LOW)){
			LogHelpers.error("PREFERENCE Storage required MED or HIGH securityLevel, increasing securityLevel to MED");
			securityLevel = SecurelyModule.PROPERTY_SECURE_LEVEL_MED;
		}

	    
		if (options.containsKey("identifier")) {
			_identifier = TiConvert.toString(options.get("identifier"));
			LogHelpers.Level2Log("Setting identifer to : " + _identifier);			
		}
		if (options.containsKey("secret")) {
			_secret = TiConvert.toString(options.get("secret"));
			LogHelpers.Level2Log("Setting secret to : " + _secret);		
		}else{

			if((securityLevel==SecurelyModule.PROPERTY_SECURE_LEVEL_MED) ||
					(securityLevel==SecurelyModule.PROPERTY_SECURE_LEVEL_HIGH)){
			
				LogHelpers.error("A secret is required for MED and HIGH securityLevel");				
				LogHelpers.error("Since no secret provided BUNDLE ID will be used");				
				_secret = TiApplication.getInstance().getAppGUID();
				
			}
		}

		if((securityLevel==SecurelyModule.PROPERTY_SECURE_LEVEL_MED) ||
				(securityLevel==SecurelyModule.PROPERTY_SECURE_LEVEL_HIGH)){
			_encryptValues=true;
		}
		
		if(securityLevel==SecurelyModule.PROPERTY_SECURE_LEVEL_HIGH){
			_encryptFieldNames=true;
		}
		
		_provider = new PrefPropertiesProvider(_identifier, _secret, _encryptValues, _encryptFieldNames);
		
//		if(storageType == SecurelyModule.PROPERTY_TYPE_PREFERENCES){
//			_provider = new PrefPropertiesProvider(_identifier, _secret, _encryptValues, _encryptFieldNames);
//		}else{
//			_provider = new keyStorePropertiesProvider(_identifier, _secret, _encryptValues, _encryptFieldNames);
//		}
	}
	
	@Kroll.method
	public boolean getBool(String key,@Kroll.argument(optional=true) Object defaultValue )
	{
		Boolean ifMissingValue = false;
		if(!keyExists(key)){
			if(defaultValue != null){
				ifMissingValue = TiConvert.toBoolean(defaultValue);
			}
			return ifMissingValue;
		}
		return _provider.getBool(keyEncrypt(key), null);
	}

	@Kroll.method
	public double getDouble(String key,@Kroll.argument(optional=true) Object defaultValue )
	{
		double ifMissingValue = 0D;
		if(!keyExists(key)){
			if(defaultValue != null){
				ifMissingValue = TiConvert.toDouble(defaultValue);
			}		
			return ifMissingValue;
		}
		
		return _provider.getDouble(keyEncrypt(key), null);
	}

	@Kroll.method
	public int getInt(String key,@Kroll.argument(optional=true) Object defaultValue)
	{
		int ifMissingValue = 0;
		if(!keyExists(key)){
			if(defaultValue != null){
				ifMissingValue = TiConvert.toInt(defaultValue);
			}			
			return ifMissingValue;
		}		
		
		return _provider.getInt(keyEncrypt(key), null);
	}

	@Kroll.method
	public boolean hasProperty(String key)
	{
		return keyExists(keyEncrypt(key));
	}
	
	@Kroll.method
	public boolean hasFieldsEncrypted()
	{
		return _encryptFieldNames;
	}

	@Kroll.method
	public boolean hasValuesEncrypted()
	{
		return _encryptValues;
	}
	
	@Kroll.method
	public String[] listProperties()
	{
		return _provider.listProperties();
	}

	@Kroll.method
	public void removeProperty(String key)
	{
		if (keyExists(key)) {
			_provider.removeProperty(keyEncrypt(key));
			fireChanged(key,"removed");
		}
	}

	@Kroll.method
	public void setBool(String key, boolean value)
	{
		String findKey = keyEncrypt(key);
		Object boolValue = _provider.getRawValue(findKey);
		if (boolValue == null || !boolValue.equals(value)) {
			_provider.setBool(findKey, value);
			fireChanged(key,"modify");
		}
	}

	@Kroll.method
	public void setDouble(String key, double value)
	{
		String findKey = keyEncrypt(key);
		Object doubleValue = _provider.getRawValue(findKey);
		//Since there is no double type in SharedPreferences, we store doubles as strings, i.e "10.0"
		//so we need to convert before comparing.
		if (doubleValue == null || !doubleValue.equals(String.valueOf(value))) {
			_provider.setDouble(findKey, value);
			fireChanged(key,"modify");
		}
	}

	@Kroll.method
	public void setInt(String key, int value)
	{
		String findKey = keyEncrypt(key);
		Object intValue = _provider.getRawValue(findKey);
		if (intValue == null || !intValue.equals(value)) {
			_provider.setInt(findKey, value);
			fireChanged(key,"modify");
		}
	}

	@Kroll.method
	public void setString(String key, String value)
	{
		String findKey = keyEncrypt(key);
		Object stringValue = _provider.getRawValue(findKey);
		if (stringValue == null || !stringValue.equals(value)) {
			_provider.setString(findKey, value);
			fireChanged(key,"modify");
		}else{
			LogHelpers.Level2Log("setString not value to update. Key:" + key + " value:" + value);
		}
	}

	@Kroll.method
	public String getString(String key,@Kroll.argument(optional=true) Object defaultValue)
	{
		String ifMissingValue = null;
		
		if(!keyExists(key)){
			
			if(defaultValue != null){
				ifMissingValue = TiConvert.toString(defaultValue);
			}	
			
			return ifMissingValue;
		}
		
		return _provider.getString(keyEncrypt(key), null);
	}
	
	@Kroll.method
	public void setObject(String key, @SuppressWarnings("rawtypes") HashMap value) 
	{
		if(value == null){
			
			setString(key,null);
			return;
			
		}
			
		try {
			
			String serializedString = Converters.serializeObjectToString(value);
	        LogHelpers.Level2Log("setObject serialized : " + serializedString);	
			setString(key,serializedString);
			
		} catch (Exception e) {
			e.printStackTrace();
			LogHelpers.Log(e);
		}
	}

	@SuppressWarnings("rawtypes")
	@Kroll.method
	public HashMap getObject(String key, @Kroll.argument(optional=true) HashMap defaultValue)
	{	
		if(!keyExists(key)){
			
			LogHelpers.DebugLog("getObject no properties found returning default");	
			return defaultValue;
			
		}else{
			
			String temp = getString(key,null);
			LogHelpers.DebugLog("getObject string return : " + temp);	
			if(temp == null){
				return null;
			}
			
			try {
				LogHelpers.DebugLog("getObject Start deserialization ");	
				Object convertedObject = Converters.deserializeObjectFromString(temp);
				LogHelpers.DebugLog("getObject Finished deserialization ");	
				return (HashMap) convertedObject;
			} catch (Exception e) {
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

		try {
			String serializedString = Converters.serializeObjectToString(value);
	        LogHelpers.Level2Log("setList serialized : " + serializedString);	
			setString(key,serializedString);
		} catch (Exception e) {
			e.printStackTrace();
			LogHelpers.Log(e);
		}
	}

	@Kroll.method
	public Object[] getList(String key, @Kroll.argument(optional=true) Object defaultValue)
	{
		if(!keyExists(key)){
			if(defaultValue==null){
				LogHelpers.DebugLog("getList null value returned");	
				return null;
			}else{
				if (!(defaultValue.getClass().isArray())) {
					throw new IllegalArgumentException("Default value must be an array");
				}					
				return (Object[]) defaultValue;
			}			
		}else{

			String temp = getString(key,null);
			LogHelpers.Level2Log("getList string return : " + temp);	
			if(temp == null){
				return null;
			}
			
			try {
				LogHelpers.Level2Log("getList Start deserialization ");	
				Object convertedObject = Converters.deserializeObjectFromString(temp);
				LogHelpers.Level2Log("getList Finished deserialization ");	
				return (Object[]) convertedObject;
			} catch (Exception e) {
				e.printStackTrace();
				LogHelpers.Log(e);
				return null;
			}			
		}
	}	
	
	@Kroll.method
	public void removeAllProperties(){
		_provider.removeAllProperties();
	}
	
	@Override
	public void onDestroy(Activity arg0) {
		if(_provider!=null){
			_provider.dispose();
			_provider = null;
		}	
	}
	
	@Kroll.method
	public void lock()
	{
		_provider.lock();
	}
	
	@Kroll.method
	public void unlock(){
		_provider.unlock();
	}
	
	@Kroll.method
	public boolean isLocked(){
		return _provider.isLocked();
	}
	
	@Override
	public void onPause(Activity arg0) {}
	@Override
	public void onResume(Activity arg0) {}
	@Override
	public void onStart(Activity arg0) {}
	@Override
	public void onStop(Activity arg0) {}
	
    @Override
    public void listenerAdded(String type, int count, KrollProxy proxy) {}
    @Override
    public void listenerRemoved(String type, int count, KrollProxy proxy) {}
    @Override
	public void processProperties(KrollDict arg0) {}
	@Override
	public void propertiesChanged(List<KrollPropertyChange> arg0,KrollProxy arg1) {}
	@Override
	public void propertyChanged(String arg0, Object arg1, Object arg2,KrollProxy arg3) {}
}
