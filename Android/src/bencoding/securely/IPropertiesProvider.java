package bencoding.securely;

public interface IPropertiesProvider {

	public Object getRawValue(String key);
	public boolean getBool(String key, Object defaultValue );
	public double getDouble(String key,Object defaultValue );
	public int getInt(String key, Object defaultValue);
	public boolean hasProperty(String key);
	public String[] listProperties();
	public void removeProperty(String key);
	public void setBool(String key, boolean value);
	public void setDouble(String key, double value);
	public void setInt(String key, int value);
	public void setString(String key, String value);
	public String getString(String key,Object defaultValue);
	public void removeAllProperties();
	public void dispose();
}
