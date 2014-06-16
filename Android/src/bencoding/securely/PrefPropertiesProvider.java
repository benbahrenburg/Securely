package bencoding.securely;

import org.appcelerator.titanium.TiApplication;
import org.appcelerator.titanium.util.TiConvert;


public class PrefPropertiesProvider implements IPropertiesProvider{

	private String _secret = "";
	private Properties _appProperties;
	private Boolean _encryptFieldNames = false;
	
	public PrefPropertiesProvider(String Identifier, String secret, Boolean encryptValues, Boolean EncryptFields)
	{
		super();	
		_encryptFieldNames = EncryptFields;
		_secret = secret;
		_appProperties = new Properties(TiApplication.getInstance().getApplicationContext(),Identifier,false);
	}

	@Override
	public Object getRawValue(String key)
	{
		return _appProperties.getPreference().getAll().get(key);
	}
	
	private String ComposeSecret(String key){
		String Seed = _secret + "_" + key;
		String composed =  SHA.sha256(Seed);
		return ((composed == null)? Seed : composed);
	};
	
	private boolean keyExists(String key){
		return _appProperties.hasProperty(key);		
	}
	
	private String EncryptContent(String PassKey, String value){
		try {
			String EncryptedText =  AESCrypto.encrypt(PassKey, value);
			return EncryptedText;
		} catch (Exception e) {
			e.printStackTrace();
			LogHelpers.Log(e);
			return null;
		}
	}
	
	private String DecryptContent(String PassKey, String value){
		try {
			String ClearText =  AESCrypto.decrypt(PassKey, value);
			return ClearText;
		} catch (Exception e) {
			e.printStackTrace();
			LogHelpers.Log(e);
			return null;
		}
	}	
	
	@Override
	public boolean getBool(String key, Object defaultValue )
	{
		Boolean ifMissingValue = ((defaultValue==null) ? false :TiConvert.toBoolean(defaultValue) );
		String DecryptedStored = getString(key,ifMissingValue);
		return Converters.StringToBoolean(DecryptedStored);
	}

	@Override
	public double getDouble(String key,Object defaultValue )
	{
		double ifMissingValue =((defaultValue != null)? TiConvert.toDouble(defaultValue): 0D);		
		String DecryptedStored = getString(key,ifMissingValue);
		return Converters.StringToDouble(DecryptedStored);
	}

	@Override
	public int getInt(String key, Object defaultValue)
	{
		int ifMissingValue = ((defaultValue != null)?TiConvert.toInt(defaultValue):0);
		String DecryptedStored = getString(key,ifMissingValue);		
		return Converters.StringToInt(DecryptedStored);
	}

	@Override
	public boolean hasProperty(String key)
	{
		return keyExists(key);
	}
	
	@Override
	public String[] listProperties()
	{
		if(_encryptFieldNames){
			LogHelpers.info("Field names are encrypted and will not be returned");
			return null;
		}else{
			return _appProperties.listProperties();
		}
	}

	@Override
	public void removeProperty(String key)
	{
		if (keyExists(key)) {
			_appProperties.removeProperty(key);
		}
	}

	@Override
	public void setBool(String key, boolean value)
	{
		String ValueAsString = Converters.BooleanToString(value);
		String tempS = ComposeSecret(key);
		String EncryptedValue = EncryptContent(tempS,ValueAsString);
		_appProperties.setString(key, EncryptedValue);
	}

	@Override
	public void setDouble(String key, double value)
	{
		String ValueAsString = Converters.DoubleToString(value);
		String tempS = ComposeSecret(key);
		String EncryptedValue = EncryptContent(tempS,ValueAsString);					
		_appProperties.setString(key, EncryptedValue);
	}

	@Override
	public void setInt(String key, int value)
	{
		String ValueAsString = Converters.IntToString(value);
		String tempS = ComposeSecret(key);
		String EncryptedValue = EncryptContent(tempS,ValueAsString);					
		_appProperties.setString(key, EncryptedValue);
	}

	@Override
	public void setString(String key, String value)
	{
		String ValueAsString = TiConvert.toString(value);
		LogHelpers.Level2Log("setString key:" + key + " value:" + ValueAsString);
		
		String PassKey = ComposeSecret(key);
		LogHelpers.Level2Log("setString PassKey:" + PassKey);
		
		String EncryptedValue = EncryptContent(PassKey,ValueAsString);	
		LogHelpers.Level2Log("setString EncryptedValue:" + EncryptedValue);

		_appProperties.setString(key, EncryptedValue);
	}

	@Override
	public String getString(String key,Object defaultValue)
	{
		String ifMissingValue = ((defaultValue == null)? null : TiConvert.toString(defaultValue));
		String StoredValue = _appProperties.getString(key, ifMissingValue);
		LogHelpers.Level2Log("getString key:" + key + " value:" + StoredValue);
		String PassKey = ComposeSecret(key);
		LogHelpers.Level2Log("getString PassKey:" + PassKey);
		String TextValue = DecryptContent(PassKey,StoredValue);
		return TextValue;
	}

	@Override
	public void removeAllProperties(){
		_appProperties.getPreference().edit().clear().commit();
	}

	@Override
	public void dispose(){
		if(_appProperties!=null){
			_appProperties.getPreference().edit().commit();
			_appProperties = null;
		}			
	}
}
