package bencoding.securely;

import javax.crypto.Cipher;
import javax.crypto.KeyGenerator;
import javax.crypto.SecretKey;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.NoSuchPaddingException;
import javax.crypto.BadPaddingException;
import javax.crypto.spec.GCMParameterSpec;
import java.io.IOException;
import java.security.InvalidKeyException;
import java.security.InvalidParameterException;
import java.security.InvalidAlgorithmParameterException;
import java.security.cert.CertificateException;
import java.security.KeyStore;
import java.security.KeyStoreException;
import java.security.UnrecoverableEntryException;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.security.SignatureException;

import android.security.keystore.KeyGenParameterSpec;
import android.security.keystore.KeyProperties;
import android.support.annotation.NonNull;
import android.util.Base64;

import org.appcelerator.titanium.TiApplication;
import org.appcelerator.titanium.util.TiConvert;

public class KeyStoreKeyPropertiesProvider implements IPropertiesProvider {

	private static final String TRANSFORMATION = "AES/GCM/NoPadding";
	private static final String ANDROID_KEY_STORE = "AndroidKeyStore";
	private KeyStore _keyStore;

	private Properties _appProperties;
	private Boolean _encryptFieldNames = false;
	private String _identifier;
	private String _fixed_iv;

	public KeyStoreKeyPropertiesProvider(String Identifier, String IV, Boolean encryptValues, Boolean EncryptFields) {
		super();
		_encryptFieldNames = EncryptFields;
		_appProperties = new Properties(TiApplication.getInstance().getApplicationContext(), Identifier, false);
		_identifier = Identifier;
		_fixed_iv = IV.substring(0, 12);

		try {
			_keyStore = KeyStore.getInstance(ANDROID_KEY_STORE);
			_keyStore.load(null);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	@Override
	public Object getRawValue(String key) {
		return _appProperties.getPreference().getAll().get(key);
	}

	@NonNull
	private SecretKey getSecretKey()
			throws NoSuchAlgorithmException, NoSuchProviderException, InvalidAlgorithmParameterException {
		try {
			if (!_keyStore.containsAlias(_identifier)) {
				final KeyGenerator keyGenerator = KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES,
						ANDROID_KEY_STORE);

				keyGenerator.init(new KeyGenParameterSpec.Builder(_identifier,
						KeyProperties.PURPOSE_ENCRYPT | KeyProperties.PURPOSE_DECRYPT)
								.setBlockModes(KeyProperties.BLOCK_MODE_GCM)
								.setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
								.setRandomizedEncryptionRequired(false).build());

				return keyGenerator.generateKey();
			}
			return ((KeyStore.SecretKeyEntry) _keyStore.getEntry(_identifier, null)).getSecretKey();
		} catch (Exception e) {
			e.printStackTrace();
			LogHelpers.Log(e);
			return null;
		}
	}

	private String EncryptContent(String value) {
		try {
			final Cipher cipher = Cipher.getInstance(TRANSFORMATION);
			cipher.init(Cipher.ENCRYPT_MODE, getSecretKey(), new GCMParameterSpec(128, _fixed_iv.getBytes()));
			final byte[] encryptedText = cipher.doFinal(value.getBytes("UTF-8"));
			return Base64.encodeToString(encryptedText, Base64.DEFAULT);
		} catch (Exception e) {
			e.printStackTrace();
			LogHelpers.Log(e);
			return null;
		}
	}

	private String DecryptContent(String value) {
		try {
			final Cipher cipher = Cipher.getInstance(TRANSFORMATION);
			final GCMParameterSpec spec = new GCMParameterSpec(128, _fixed_iv.getBytes());
			cipher.init(Cipher.DECRYPT_MODE, getSecretKey(), spec);

			return new String(cipher.doFinal(Base64.decode(value, Base64.DEFAULT)), "UTF-8");
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
	}

	@Override
	public boolean getBool(String key, Object defaultValue) {
		Boolean ifMissingValue = ((defaultValue == null) ? false : TiConvert.toBoolean(defaultValue));
		String DecryptedStored = getString(key, ifMissingValue);
		return Converters.StringToBoolean(DecryptedStored);
	}

	@Override
	public double getDouble(String key, Object defaultValue) {
		double ifMissingValue = ((defaultValue != null) ? TiConvert.toDouble(defaultValue) : 0D);
		String DecryptedStored = getString(key, ifMissingValue);
		return Converters.StringToDouble(DecryptedStored);
	}

	@Override
	public int getInt(String key, Object defaultValue) {
		int ifMissingValue = ((defaultValue != null) ? TiConvert.toInt(defaultValue) : 0);
		String DecryptedStored = getString(key, ifMissingValue);
		return Converters.StringToInt(DecryptedStored);
	}

	@Override
	public boolean hasProperty(String key) {
		return _appProperties.hasProperty(key);
	}

	@Override
	public String[] listProperties() {
		if (_encryptFieldNames) {
			LogHelpers.info("Field names are encrypted and will not be returned");
			return null;
		} else {
			return _appProperties.listProperties();
		}
	}

	@Override
	public void removeProperty(String key) {
		_appProperties.removeProperty(key);
	}

	@Override
	public void setBool(String key, boolean value) {
		String ValueAsString = Converters.BooleanToString(value);
		String EncryptedValue = EncryptContent(ValueAsString);
		_appProperties.setString(key, EncryptedValue);
	}

	@Override
	public void setDouble(String key, double value) {
		String ValueAsString = Converters.DoubleToString(value);
		String EncryptedValue = EncryptContent(ValueAsString);
		_appProperties.setString(key, EncryptedValue);
	}

	@Override
	public void setInt(String key, int value) {
		String ValueAsString = Converters.IntToString(value);
		String EncryptedValue = EncryptContent(ValueAsString);
		_appProperties.setString(key, EncryptedValue);
	}

	@Override
	public void setString(String key, String value) {
		String ValueAsString = TiConvert.toString(value);
		LogHelpers.Level2Log("setString key:" + key + " value:" + ValueAsString);

		String EncryptedValue = EncryptContent(ValueAsString);
		LogHelpers.Level2Log("setString EncryptedValue:" + EncryptedValue);

		_appProperties.setString(key, EncryptedValue);
	}

	@Override
	public String getString(String key, Object defaultValue) {
		String ifMissingValue = ((defaultValue == null) ? null : TiConvert.toString(defaultValue));
		String StoredValue = _appProperties.getString(key, ifMissingValue);
		LogHelpers.Level2Log("getString key:" + key + " value:" + StoredValue);
		String TextValue = DecryptContent(StoredValue);
		return TextValue;
	}

	@Override
	public void removeAllProperties() {
		_appProperties.getPreference().edit().clear().commit();
	}

	@Override
	public void dispose() {
		if (_appProperties != null) {
			_appProperties.getPreference().edit().commit();
			_appProperties = null;
		}
	}

	@Override
	public void lock() {
	}

	@Override
	public void unlock() {
	}

	@Override
	public boolean isLocked() {
		return false;
	}
}