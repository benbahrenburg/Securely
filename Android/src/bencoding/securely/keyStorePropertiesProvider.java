package bencoding.securely;

public class keyStorePropertiesProvider implements IPropertiesProvider{

	@SuppressWarnings("unused")
	private static String _secret = "";
	@SuppressWarnings("unused")
	private static Boolean _encryptFieldNames = false;
	@SuppressWarnings("unused")
	private static Boolean _encryptValues = false;
	
	public keyStorePropertiesProvider(String Identifier, String secret, Boolean encryptValues, Boolean EncryptFields)
	{
		super();	
		_encryptFieldNames = EncryptFields;
		_secret = secret;
		_encryptValues = encryptValues;
	}
	
	@Override
	public Object getRawValue(String key) {
		return null;
	}

	@Override
	public boolean getBool(String key, Object defaultValue) {
		return false;
	}

	@Override
	public double getDouble(String key, Object defaultValue) {
		return 0;
	}

	@Override
	public int getInt(String key, Object defaultValue) {
		return 0;
	}

	@Override
	public boolean hasProperty(String key) {
		return false;
	}

	@Override
	public String[] listProperties() {
		return null;
	}

	@Override
	public void removeProperty(String key) {
		
	}

	@Override
	public void setBool(String key, boolean value) {
		
	}

	@Override
	public void setDouble(String key, double value) {
		
	}

	@Override
	public void setInt(String key, int value) {
		
	}

	@Override
	public void setString(String key, String value) {
		
	}

	@Override
	public String getString(String key, Object defaultValue) {
		return null;
	}

	@Override
	public void removeAllProperties() {
		
	}

	@Override
	public void dispose() {
		
	}

}
