package bencoding.securely;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.UnsupportedEncodingException;
import java.util.Arrays;
import java.util.HashMap;

import javax.crypto.Cipher;
import javax.crypto.CipherInputStream;
import javax.crypto.CipherOutputStream;
import javax.crypto.SecretKey;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;

import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.KrollFunction;
import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.kroll.annotations.Kroll;
import org.appcelerator.titanium.TiBlob;
import org.appcelerator.titanium.TiC;
import org.appcelerator.titanium.io.TiBaseFile;
import org.appcelerator.titanium.io.TiFile;
import org.appcelerator.titanium.io.TiFileFactory;

import ti.modules.titanium.filesystem.FileProxy;

import android.util.Base64;

@Kroll.proxy(creatableInModule=SecurelyModule.class)
public class XPlatformCryptoProxy  extends KrollProxy {

	public XPlatformCryptoProxy()
	{
		super();		
	}

	@SuppressWarnings({ "rawtypes", "unchecked" })
	@Kroll.method
	public void readEncrypt(HashMap hm){
		KrollDict args = new KrollDict(hm);
		
		if(!args.containsKey("completed")){
			throw new IllegalArgumentException("missing completed callback method");
		}
		if(!args.containsKey("password")){
			throw new IllegalArgumentException("missing password");
		}
		if(!args.containsKey("readPath")){
			throw new IllegalArgumentException("missing readPath value");
		}
		
		String password = args.getString("password");	
		Object readPath = args.get("readPath");	
		
		KrollFunction callback = null;
	
		Object object = args.get("completed");
		if (object instanceof KrollFunction) {
			callback = (KrollFunction)object;
		}
	    try {
	    	LogHelpers.info("Opening File");
	    	TiBaseFile inputFile = null;
	    	if(readPath instanceof TiFile){	    		
	    		inputFile = TiFileFactory.createTitaniumFile(((TiFile)readPath).getFile().getAbsolutePath(), false);
	    	}else{
	    		if(readPath instanceof FileProxy){
	    			inputFile = ((FileProxy)readPath).getBaseFile();
	    		}else{
		    		if(readPath instanceof TiBaseFile){
		    			inputFile = (TiBaseFile) readPath;
		    		}else{
		    			//Assume path provided
		    			inputFile = TiFileFactory.createTitaniumFile(readPath.toString(),false);
		    		}	    			
	    		}
	    	}
	    	if(inputFile==null){
		    	LogHelpers.error("Unable to load input file");
		    	return;	    		
	    	}
		    if (!inputFile.exists()){
		    	LogHelpers.error("Input file does not exist");
		    	return;
		    }

	    	InputStream fis = inputFile.getInputStream();
	        SecretKey key = getKey(password);
	        
	        //IMPORTANT TO GET SAME RESULTS ON iOS and ANDROID
	        final byte[] iv = new byte[16];
	        Arrays.fill(iv, (byte) 0x00);
	        IvParameterSpec ivParameterSpec = new IvParameterSpec(iv);

	        // cipher is not thread safe
	        Cipher cipher = Cipher.getInstance("AES/CBC/PKCS7Padding");
	        cipher.init(Cipher.DECRYPT_MODE, key, ivParameterSpec);
	        CipherInputStream is = new CipherInputStream(fis,cipher);	
	        
	        ByteArrayOutputStream bOut = new ByteArrayOutputStream();
	        int ch;
	        while ((ch = is.read()) >= 0) {
	            bOut.write(ch);
	        }
	        
	        byte[] decryptedBytes = bOut.toByteArray();
	        
			is.close();
			fis.close();	
			
			TiBlob result = TiBlob.blobFromData(decryptedBytes);

			if(callback!=null){
				HashMap<String, Object> event = new HashMap<String, Object>();
				event.put(TiC.PROPERTY_SUCCESS, true);	
				event.put("result",result);			
				callback.call(getKrollObject(), event);
			}	

	    } catch (Exception e) {
	        LogHelpers.error(e);
			HashMap<String, Object> errEvent = new HashMap<String, Object>();
			errEvent.put(TiC.PROPERTY_SUCCESS, false);	
			errEvent.put("message",e.getMessage());			
			callback.call(getKrollObject(), errEvent);	        
	    } 		
	};
	
	@SuppressWarnings({ "rawtypes", "unchecked" })
	@Kroll.method
	public void writeEncrypt(HashMap hm){
		KrollDict args = new KrollDict(hm);
		
		if(!args.containsKey("completed")){
			throw new IllegalArgumentException("missing completed callback method");
		}
		if(!args.containsKey("password")){
			throw new IllegalArgumentException("missing password");
		}
		if(!args.containsKey("inputValue")){
			throw new IllegalArgumentException("missing inputValue value");
		}
		if(!args.containsKey("outputPath")){
			throw new IllegalArgumentException("missing outputPath");
		}		
		String password = args.getString("password");	
		String outputPath = args.getString("outputPath");	
		Object inputValue = args.get("inputValue");
		
		KrollFunction callback = null;
		
		if(Utils.pathIsInResources(outputPath)){
			throw new IllegalArgumentException("Output file cannot be in the Resources directory: " + outputPath);
		}
		
		Object object = args.get("completed");
		if (object instanceof KrollFunction) {
			callback = (KrollFunction)object;
		}	
	    try {
	    
	    	TiBaseFile inputFile = null;
	    	if(inputValue instanceof TiFile){	    		
	    		inputFile = TiFileFactory.createTitaniumFile(((TiFile)inputValue).getFile().getAbsolutePath(), false);
	    	}else{
	    		if(inputValue instanceof FileProxy){
	    			inputFile = ((FileProxy)inputValue).getBaseFile();
	    		}else{
		    		if(inputValue instanceof TiBaseFile){
		    			inputFile = (TiBaseFile) inputValue;
		    		}else{
		    			//Assume path provided
		    			inputFile = TiFileFactory.createTitaniumFile(inputValue.toString(),false);
		    		}	    			
	    		}
	    	}
	    	if(inputFile==null){
		    	LogHelpers.error("Unable to load input file");
		    	return;	    		
	    	}
		    if (!inputFile.exists()){
		    	LogHelpers.error("Input file does not exist");
		    	return;
		    }
		    
			InputStream fis = inputFile.getInputStream();
			OutputStream fos = TiFileFactory.createTitaniumFile(outputPath,false).getOutputStream();
	    	
			SecretKeySpec skeySpec = getKey(password);

	        //IMPORTANT TO GET SAME RESULTS ON iOS and ANDROID
	        final byte[] iv = new byte[16];
	        Arrays.fill(iv, (byte) 0x00);
	        IvParameterSpec ivParameterSpec = new IvParameterSpec(iv);

	        // Cipher is not thread safe
	        Cipher cipher = Cipher.getInstance("AES/CBC/PKCS7Padding");
	        cipher.init(Cipher.ENCRYPT_MODE, skeySpec, ivParameterSpec);
	        
			CipherOutputStream os = new CipherOutputStream(fos, cipher);
			
			Utils.streamCopy(fis, os);
			os.close();			
			
			if(callback!=null){
				HashMap<String, Object> event = new HashMap<String, Object>();
				event.put(TiC.PROPERTY_SUCCESS, true);	
				event.put("result",outputPath);			
				callback.call(getKrollObject(), event);
			}	

	    } catch (Exception e) {
	    	LogHelpers.error(e);
			HashMap<String, Object> errEvent = new HashMap<String, Object>();
			errEvent.put(TiC.PROPERTY_SUCCESS, false);	
			errEvent.put("message",e.getMessage());			
			callback.call(getKrollObject(), errEvent);	        
	    } 		
	};
	
	@Kroll.method
	public String encrypt(String key, String value) {
		try {				
			if(key.isEmpty()){
				LogHelpers.error("empty key provided.");
				return null;				
			}
			if(value.isEmpty()){
				LogHelpers.error("empty value to encrypt provided.");
				return null;
			}			
			String EncryptedText = doEncode(key,value);
			return EncryptedText;
		} catch (Exception e) {
			LogHelpers.error("encrypt failed returning null");
			LogHelpers.error("encrypt:" + e.getMessage());
			LogHelpers.error(e);			
			return null;			
		}		
	}
	@Kroll.method
	public String decrypt(String key, String value) {		
		try {
			if(key.isEmpty()){
				LogHelpers.error("empty key provided.");
				return null;				
			}
			if(value.isEmpty()){
				LogHelpers.error("empty value to decrypt provided.");
				return null;
			}	
			String ClearText =  doDecode(key, value);
			return ClearText;
		} catch (Exception e) {
			LogHelpers.error("decrypt failed returning null");
	    	LogHelpers.error("decrypt:" + e.getMessage());
	        LogHelpers.error(e);
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
	    	LogHelpers.error("doEncode:" + e.getMessage());
	        LogHelpers.error(e);
	        throw e;
	    } 
	}

	/**
	 * Decodes a String using AES-256 and Base64
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
	    	LogHelpers.error("doDecode:" + e.getMessage());
	        LogHelpers.error(e);
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
