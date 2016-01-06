/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2010 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */
package bencoding.securely;

import java.util.ArrayList;
import android.content.Context;
import android.content.SharedPreferences;

/**
 * API for accessing, storing, and modifying application properties that are 
 * exposed via Ti.App.Properties.
 */
public class Properties
{
	SharedPreferences _preferences;

	/**
	 * Instantiates the private SharedPreferences collection with the given name and context.
	 * This means no other Android application will have access to they keys and values.
	 * @param context the context used to create/retrieve preferences.
	 * @param name the name used to create/retrieve preferences.
	 * @param clear whether to clear all keys and values in the instantiated SharedPreferences collection.
	 */
	public Properties(Context context, String name, boolean clear) {	
		_preferences = context.getSharedPreferences(name,Context.MODE_PRIVATE);	
		if (clear) {
			_preferences.edit().clear().commit();
		}
	}

	/**
	 * Returns the mapping of a specified key, in String format. If key does not exist, returns the default value.
	 * @param key the lookup key.
	 * @param def the default value.
	 * @return mapping of key, or default value.
	 * @module.api
	 */
	public String getString(String key, String def)
	{
		LogHelpers.DebugLog("getString called with key:" + key + ", def:" + def);
		
		Object value = _preferences.getAll().get(key);
		if (value != null) {
			LogHelpers.DebugLog("getString called with key:" + key + " ,value:" + value.toString());
			return value.toString();
		} else {
			LogHelpers.DebugLog("getString called with key:" + key + " ,value: null returning def:" + def);
			return def;
		}
	}

	public SharedPreferences getPreference()
	{
		return _preferences;
	}
	
	/**
	 * Maps the specified key with a String value. If value is null, existing key will be removed from preferences.
	 * Otherwise, its value will be overwritten.
	 * @param key the key to set.
	 * @param value the value to set.
	 * @module.api
	 */
	public void setString(String key, String value)
	{
		LogHelpers.DebugLog("setString called with key:"+key+", value:"+value);
		SharedPreferences.Editor editor = _preferences.edit();
		if (value==null) {
			editor.remove(key);
		} else {
			editor.putString(key,value);
		}
		editor.commit();
	}

	/**
	 * Returns the mapping of a specified key as an Integer. If key does not exist, returns the default value.
	 * @param key the lookup key.
	 * @param def the default value.
	 * @return mapping of key, or default value.
	 * @module.api
	 */
	public int getInt(String key, int def)
	{
		LogHelpers.DebugLog("getInt called with key:" + key + ", def:" + def);
		try {
			return _preferences.getInt(key,def);
		} catch(ClassCastException cce) {
			//Value stored as something other than int. Try and convert to int
			String val = getString(key,"");
			try {
				return Integer.parseInt(val);
			} catch (NumberFormatException nfe) {
				return def;
			}
		}
	}
	
	/**
	 * Maps the specified key with an int value. If key exists, its value will be overwritten.
	 * @param key the key to set.
	 * @param value the value to set.
	 * @module.api
	 */
	public void setInt(String key, int value)
	{
		LogHelpers.DebugLog("setInt called with key:" + key + ", value:" + value);

		SharedPreferences.Editor editor = _preferences.edit();
		editor.putInt(key,value);
		editor.commit();
	}
	
	/**
	 * Returns the mapping of a specified key as a Double. If key does not exist, returns the default value.
	 * @param key the lookup key.
	 * @param def the default value.
	 * @return mapping of key, or default value.
	 * @module.api
	 */
	public double getDouble(String key, double def)
	{
		LogHelpers.DebugLog("getDouble called with key:" + key + ", def:" + def);
		String stringValue = null;
		Object string = _preferences.getAll().get(key);
		if (string == null) {
			return def;
		}
		stringValue = string.toString();
		try {
			return Double.parseDouble(stringValue);
		} catch (NumberFormatException e) {
			return def;
		}
	}

	/**
	 * Maps the specified key with a double value. If key exists, its value will be
	 * overwritten.
	 * @param key the key to set.
	 * @param value the value to set.
	 * @module.api
	 */
	public void setDouble(String key, double value)
	{
		LogHelpers.DebugLog("setDouble called with key:" + key + ", value:" + value);
		
		SharedPreferences.Editor editor = _preferences.edit();
		editor.putString(key,value + "");
		editor.commit();
	}
	
	/**
	 * Returns the mapping of a specified key, as a Boolean. If key does not exist, returns the default value.
	 * @param key the lookup key.
	 * @param def the default value.
	 * @return mapping of key, or default value.
	 * @module.api
	 */
	public boolean getBool(String key, boolean def)
	{
		LogHelpers.DebugLog("getBool called with key:" + key + ", def:" + def);
		try {
			return _preferences.getBoolean(key,def);
		} catch(ClassCastException cce) {
			//Value stored as something other than boolean. Try and convert to boolean
			String val = getString(key,"");
			try {
				return Boolean.valueOf(val).booleanValue();
			} catch (Exception e) {
				return def;
			}
		}
	}
	
	/**
	 * Maps the specified key with a boolean value. If key exists, its value will be
	 * overwritten.
	 * @param key the key to set.
	 * @param value the value to set.
	 * @module.api
	 */
	public void setBool(String key, boolean value)
	{
		LogHelpers.DebugLog("setBool called with key:" + key + ", value:" + value);

		SharedPreferences.Editor editor = _preferences.edit();
		editor.putBoolean(key,value);
		editor.commit();
	}

	/**
	 * Returns the mapping of a specified key as a String array. If key does not exist, returns the default value.
	 * @param key the lookup key.
	 * @param def the default value.
	 * @return mapping of key, or default value.
	 * @module.api
	 */
	public String[] getList(String key, String def[])
	{
		LogHelpers.DebugLog("getList called with key:" + key + ", def:" + def);

		int length = _preferences.getInt(key+".length", -1);
		if (length == -1) {
			return def;
		}

		String list[] = new String[length];
		for (int i = 0; i < length; i++) {
			list[i] = _preferences.getString(key+"."+i, "");
		}
		return list;
	}

	/**
	 * Maps the specified key with String[] value. Also maps 'key.length' to 'value.length'.
	 * If key exists, its value will be overwritten.
	 * @param key the key to set.
	 * @param value the value to set.
	 * @module.api
	 */
	public void setList(String key, String[] value)
	{
		LogHelpers.DebugLog("setList called with key:" + key + ", value:" + value);

		SharedPreferences.Editor editor = _preferences.edit();
		for (int i = 0; i < value.length; i++)
		{
			editor.putString(key+"."+i, value[i]);
		}
		editor.putInt(key+".length", value.length);

		editor.commit();

	}

	/**
	 * @param key the lookup list key.
	 * @return true if the list property exists in preferences
	 * @module.api
	 */
	public boolean hasListProperty(String key) {
		return hasProperty(key+".0");
	}
	
	/**
	 * Returns whether key exists in preferences.
	 * @param key the lookup key.
	 * @return true if key exists in preferences.
	 * @module.api
	 */
	public boolean hasProperty(String key)
	{
		LogHelpers.DebugLog("hasProperty called with key:" + key);
		return _preferences.contains(key);
	}

	/**
	 * Returns an array of keys whose values are lists.
	 * @return an array of keys.
	 * @module.api
	 */
	public String[] listProperties()
	{
		ArrayList<String> properties = new ArrayList<String>();
		for (String key : _preferences.getAll().keySet())
		{
			if (key.endsWith(".length")) {
				properties.add(key.substring(0, key.length()-7));
			}
			else if (key.matches(".+\\.\\d+$")) {

			}
			else {
				properties.add(key);
			}
		}
		return properties.toArray(new String[properties.size()]);
	}

	/**
	 * Removes the key from preferences if it exists.
	 * @param key the key to remove.
	 * @module.api
	 */
	public void removeProperty(String key)
	{
		LogHelpers.DebugLog("removeProperty called with key:" + key);
		if (_preferences.contains(key)) {
			SharedPreferences.Editor editor = _preferences.edit();
			editor.remove(key);
			editor.commit();
			LogHelpers.DebugLog("removeProperty called with key:" + key + " value removed");
		}else{
			LogHelpers.DebugLog("removeProperty called with key:" + key + " value does not exist");
		}
	}
}