package bencoding.securely;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.ObjectInput;
import java.io.ObjectInputStream;

import org.appcelerator.titanium.TiApplication;
import org.appcelerator.titanium.util.TiConvert;

import android.content.ActivityNotFoundException;
import android.content.Intent;
import android.os.Build;
import bencoding.securely.androidkeystore.android.security.KeyStore;

public class keyStorePropertiesProvider implements IPropertiesProvider{

	private static final boolean IS_JB = Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN;	    
	private static final String OLD_UNLOCK_ACTION = "android.credentials.UNLOCK";
	private static final String UNLOCK_ACTION = "com.android.credentials.UNLOCK";
	    
	private static String _secret = "";
	private static KeyStore _ks = KeyStore.getInstance();
	
	public keyStorePropertiesProvider(String Identifier, String secret, Boolean encryptValues, Boolean EncryptFields)
	{
		super();	
		_secret = secret;
		_ks.password(_secret);
	}

	private void saveToKeyStore(String key, String value){
		boolean success = _ks.put(key, value.getBytes());
		if (!success) {
		   LogHelpers.error("Failed writing to keystore, key:" + key + " errorCode:" + rcToStr(_ks.getLastError()));
		}
	}
	
	private String ComposeSecret(String key){
		String Seed = _secret + "_" + key;
		String composed =  SHA.sha256(Seed);
		return ((composed == null)? Seed : composed);
	};
	
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
	public Object getRawValue(String key) {
	      byte[] keyBytes = _ks.get(key);
          if (keyBytes == null) {
        	  LogHelpers.DebugLog("Encryption key not found in keystore: " + key);
              return null;
          }

          ByteArrayInputStream bis = new ByteArrayInputStream(keyBytes);
          ObjectInput in = null;
          Object results = null;
        try {
			in = new ObjectInputStream(bis);
			results = in.readObject();
		} catch (ClassNotFoundException e) {
			LogHelpers.error(e.getLocalizedMessage());			
		} catch (IOException e) {
			LogHelpers.error(e.getLocalizedMessage());
		}finally {
		  try {
			    bis.close();
			    if (in != null) {
				    in.close();
				}			    
			  } catch (IOException ex) {
			    // ignore close exception
			  }
			}
        
        return results;
	}

	@Override
	public boolean getBool(String key, Object defaultValue) {
		Boolean ifMissingValue = ((defaultValue==null) ? false :TiConvert.toBoolean(defaultValue) );
		String DecryptedStored = getString(key,ifMissingValue);
		return Converters.StringToBoolean(DecryptedStored);
	}

	@Override
	public double getDouble(String key, Object defaultValue) {
		double ifMissingValue =((defaultValue != null)? TiConvert.toDouble(defaultValue): 0D);		
		String DecryptedStored = getString(key,ifMissingValue);
		return Converters.StringToDouble(DecryptedStored);
	}

	@Override
	public int getInt(String key, Object defaultValue) {
		int ifMissingValue = ((defaultValue != null)?TiConvert.toInt(defaultValue):0);
		String DecryptedStored = getString(key,ifMissingValue);		
		return Converters.StringToInt(DecryptedStored);
	}

	@Override
	public boolean hasProperty(String key) {
		return _ks.contains(key);
	}

	@Override
	public String[] listProperties() {
		return _ks.saw("");
	}

	@Override
	public void removeProperty(String key) {		
		if (hasProperty(key)) {
			_ks.delete(key);
		}
	}

	@Override
	public void setBool(String key, boolean value) {
		String ValueAsString = Converters.BooleanToString(value);
		String tempS = ComposeSecret(key);
		String EncryptedValue = EncryptContent(tempS,ValueAsString);
		saveToKeyStore(key,EncryptedValue);	
	}

	@Override
	public void setDouble(String key, double value) {
		String ValueAsString = Converters.DoubleToString(value);
		String tempS = ComposeSecret(key);
		String EncryptedValue = EncryptContent(tempS,ValueAsString);					
		saveToKeyStore(key,EncryptedValue);		
	}

	@Override
	public void setInt(String key, int value) {
		String ValueAsString = Converters.IntToString(value);
		String tempS = ComposeSecret(key);
		String EncryptedValue = EncryptContent(tempS,ValueAsString);					
		saveToKeyStore(key,EncryptedValue);	
	}


	@Override
	public void setString(String key, String value) {
		String ValueAsString = TiConvert.toString(value);
		LogHelpers.Level2Log("setString key:" + key + " value:" + ValueAsString);
		
		String PassKey = ComposeSecret(key);
		LogHelpers.Level2Log("setString PassKey:" + PassKey);
		
		String EncryptedValue = EncryptContent(PassKey,ValueAsString);	
		LogHelpers.Level2Log("setString EncryptedValue:" + EncryptedValue);
		saveToKeyStore(key,EncryptedValue);
	}

	@Override
	public String getString(String key, Object defaultValue) {
		
		String ifMissingValue = ((defaultValue == null)? null : TiConvert.toString(defaultValue));
		if(!hasProperty(key)){
			return ifMissingValue;
		}
		
		Object rawValue = getRawValue(key);
		
		if(rawValue  == null){
			return null;
		}
		
		String StoredValue = (String)rawValue;
		String PassKey = ComposeSecret(key);
		String TextValue = DecryptContent(PassKey,StoredValue);		
		return TextValue;
	}

	@Override
	public void removeAllProperties() {
		if(!_ks.isEmpty()){
            String[] keys = _ks.saw("");
            for (String key : keys) {
                boolean success = _ks.delete(key);
                LogHelpers.DebugLog(String.format("delete key '%s' success: %s",key, success));
                if (!success && IS_JB) {
                    success = _ks.delKey(key);
                    LogHelpers.DebugLog(String.format("delKey '%s' success: %s",key, success));
                }
            }		
		}		
	}

	@Override
	public void lock() {
	   if (_ks.state() == KeyStore.State.LOCKED) {
		   return;
	   }
		   
	   boolean success = _ks.lock();
       if (!success) {
    	   LogHelpers.error("lock() last error = " + rcToStr(_ks.getLastError()));
       }
		
	}

	@Override
	public void unlock() {
	   if (_ks.state() == KeyStore.State.UNLOCKED) {
            return;
        }

        try {
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.HONEYCOMB) {
            	TiApplication.getInstance().startActivity(new Intent(OLD_UNLOCK_ACTION));
            } else {
            	TiApplication.getInstance().startActivity(new Intent(UNLOCK_ACTION));
            }
        } catch (ActivityNotFoundException e) {
        	LogHelpers.error("No UNLOCK activity: " + e.getMessage());
        }		
	}

	@Override
	public boolean isLocked() {
		return (_ks.state() == KeyStore.State.UNLOCKED);
	}

	   private static final String rcToStr(int rc) {
	        switch (rc) {
	        case KeyStore.NO_ERROR:
	            return "NO_ERROR";
	        case KeyStore.LOCKED:
	            return "LOCKED";
	        case KeyStore.UNINITIALIZED:
	            return "UNINITIALIZED";
	        case KeyStore.SYSTEM_ERROR:
	            return "SYSTEM_ERROR";
	        case KeyStore.PROTOCOL_ERROR:
	            return "PROTOCOL_ERROR";
	        case KeyStore.PERMISSION_DENIED:
	            return "PERMISSION_DENIED";
	        case KeyStore.KEY_NOT_FOUND:
	            return "KEY_NOT_FOUND";
	        case KeyStore.VALUE_CORRUPTED:
	            return "VALUE_CORRUPTED";
	        case KeyStore.UNDEFINED_ACTION:
	            return "UNDEFINED_ACTION";
	        case KeyStore.WRONG_PASSWORD:
	            return "WRONG_PASSWORD";
	        default:
	            return "Unknown RC";
	        }
	    }

		@Override
		public void dispose() {}
}
