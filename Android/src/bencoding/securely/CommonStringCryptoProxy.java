package bencoding.securely;

import java.io.UnsupportedEncodingException;
import java.util.Arrays;

import javax.crypto.Cipher;
import javax.crypto.SecretKey;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;

import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.kroll.annotations.Kroll;

import android.util.Base64;

@Kroll.proxy(creatableInModule=SecurelyModule.class)
public class CommonStringCryptoProxy  extends KrollProxy {

	public CommonStringCryptoProxy()
	{
		super();		
	}
	
	@Kroll.method
	public String encrypt(String key, String value) {
		try {						
			String EncryptedText = doEncode(key,value);
			return EncryptedText;
		} catch (Exception e) {
			e.printStackTrace();
			LogHelpers.Log(e);
			return null;			
		}		
	}
	@Kroll.method
	public String decrypt(String key, String value) {		
		try {
			String ClearText =  doDecode(key, value);
			return ClearText;
		} catch (Exception e) {
			e.printStackTrace();
			LogHelpers.Log(e);
			return null;			
		}
	}
	
	private String doEncode(String password, String text) throws Exception{

	    try {
	        SecretKeySpec skeySpec = getKey(password);
	        byte[] clearText = text.getBytes("UTF8");

	        //IMPORTANT TO GET SAME RESULTS ON iOS and ANDROID
	        final byte[] iv = new byte[16];
	        Arrays.fill(iv, (byte) 0x00);
	        IvParameterSpec ivParameterSpec = new IvParameterSpec(iv);

	        // Cipher is not thread safe
	        Cipher cipher = Cipher.getInstance("AES/CBC/PKCS7Padding");
	        cipher.init(Cipher.ENCRYPT_MODE, skeySpec, ivParameterSpec);

	        String encrypedValue = Base64.encodeToString(
	                cipher.doFinal(clearText), Base64.DEFAULT);
	        LogHelpers.DebugLog("Encrypted: " + text + " -> " + encrypedValue);
	        return encrypedValue;

	    } catch (Exception e) {
	        e.printStackTrace();
	        throw e;
	    } 
	}

	/**
	 * Decodes a String using AES-128 and Base64
	 * 
	 * @param context
	 * @param password
	 * @param text
	 * @return desoded String
	 * @throws Exception 
	 * @throws NoPassGivenException
	 * @throws NoTextGivenException
	 */
	private String doDecode(String password, String text) throws Exception {

	    try {
	        SecretKey key = getKey(password);

	        //IMPORTANT TO GET SAME RESULTS ON iOS and ANDROID
	        final byte[] iv = new byte[16];
	        Arrays.fill(iv, (byte) 0x00);
	        IvParameterSpec ivParameterSpec = new IvParameterSpec(iv);

	        byte[] encrypedPwdBytes = Base64.decode(text, Base64.DEFAULT);
	        // cipher is not thread safe
	        Cipher cipher = Cipher.getInstance("AES/CBC/PKCS7Padding");
	        cipher.init(Cipher.DECRYPT_MODE, key, ivParameterSpec);
	        byte[] decrypedValueBytes = (cipher.doFinal(encrypedPwdBytes));

	        String decrypedValue = new String(decrypedValueBytes);
	        LogHelpers.DebugLog("Decrypted: " + text + " -> " + decrypedValue);
	        return decrypedValue;

	    } catch (Exception e) {
	        e.printStackTrace();
	        throw e;
	    } 
	}
	/**
	 * Generates a SecretKeySpec for given password
	 * @param password
	 * @return SecretKeySpec
	 * @throws UnsupportedEncodingException
	 */
	private SecretKeySpec getKey(String password)
	        throws UnsupportedEncodingException {


	    int keyLength = 256;
	    byte[] keyBytes = new byte[keyLength / 8];
	    // explicitly fill with zeros
	    Arrays.fill(keyBytes, (byte) 0x0);

	    // if password is shorter then key length, it will be zero-padded
	    // to key length
	    byte[] passwordBytes = password.getBytes("UTF-8");
	    int length = passwordBytes.length < keyBytes.length ? passwordBytes.length
	            : keyBytes.length;
	    System.arraycopy(passwordBytes, 0, keyBytes, 0, length);
	    SecretKeySpec key = new SecretKeySpec(keyBytes, "AES");
	    return key;
	}
}
