package bencoding.securely;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.security.SecureRandom;
import java.util.HashMap;

import javax.crypto.Cipher;
import javax.crypto.CipherInputStream;
import javax.crypto.CipherOutputStream;
import javax.crypto.KeyGenerator;
import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;

import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.KrollFunction;
import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.kroll.annotations.Kroll;
import org.appcelerator.titanium.TiC;
import org.appcelerator.titanium.io.TiBaseFile;
import org.appcelerator.titanium.io.TiFileFactory;
import org.appcelerator.titanium.util.TiConvert;

@Kroll.proxy(creatableInModule=SecurelyModule.class)
public class FileCryptoProxy extends KrollProxy {

	static int _aesBytes = 128;
	
	public FileCryptoProxy()
	{
		super();		
	}
	
	private class AESFilesRunnable implements Runnable
	{
		private boolean _isEncrypt = true;
		private File _to = null;
		private File _from = null;
		KrollFunction _callback = null;
		String _secret = null;
		
		public AESFilesRunnable(String secret, KrollFunction callback, boolean isEncrypt, File from, File to){
			_isEncrypt = isEncrypt;
			_to = to;
			_from = from;
			_callback = callback;
			_secret = secret;
		}
		private byte[] getRawKey(byte[] seed) throws Exception {
		    KeyGenerator kgen = KeyGenerator.getInstance("AES");
		    SecureRandom sr = SecureRandom.getInstance("SHA1PRNG");
		    sr.setSeed(seed);
		    kgen.init(_aesBytes, sr); // 192 and 256 bits may not be available
		    SecretKey skey = kgen.generateKey();
		    byte[] raw = skey.getEncoded();
		    return raw;
		}
		
		private Cipher getCipherEncrypt(byte[] raw) throws Exception {
		    SecretKeySpec skeySpec = new SecretKeySpec(raw, "AES");
		    Cipher cipher = Cipher.getInstance("AES");
		    cipher.init(Cipher.ENCRYPT_MODE, skeySpec);
		    return cipher;
		}
		private Cipher getCipherDecrypt(byte[] raw) throws Exception {
		    SecretKeySpec skeySpec = new SecretKeySpec(raw, "AES");
		    Cipher cipher = Cipher.getInstance("AES");
		    cipher.init(Cipher.DECRYPT_MODE, skeySpec);
		    return cipher;
		}		
//		 private byte[] getKeyBytes(final byte[] key) throws Exception {
//		        byte[] keyBytes = new byte[16];
//		        System.arraycopy(key, 0, keyBytes, 0, Math.min(key.length, keyBytes.length));
//		        return keyBytes;
//		    }
//		    public Cipher getCipherEncrypt(final byte[] key) throws Exception {
//		        byte[] keyBytes = getKeyBytes(key);
//		        Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
//		        SecretKeySpec secretKeySpec = new SecretKeySpec(keyBytes, "AES");
//		        IvParameterSpec ivParameterSpec = new IvParameterSpec(keyBytes);
//		        cipher.init(Cipher.ENCRYPT_MODE, secretKeySpec, ivParameterSpec);
//		        return cipher;
//		    }
//		    public Cipher getCipherDecrypt(byte[] key) throws Exception {
//		        byte[] keyBytes = getKeyBytes(key);
//		        Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
//		        SecretKeySpec secretKeySpec = new SecretKeySpec(keyBytes, "AES");
//		        IvParameterSpec ivParameterSpec = new IvParameterSpec(keyBytes);
//		        cipher.init(Cipher.DECRYPT_MODE, secretKeySpec, ivParameterSpec);
//		        return cipher;
//		    }		
		    public void encrypt(File inputFile, File outputFile, byte[] key) throws Exception {
		        Cipher cipher = getCipherEncrypt(key);
		        FileOutputStream fos = null;
		        CipherOutputStream cos = null;
		        FileInputStream fis = null;
		        try {
		        	fis = new FileInputStream(inputFile);
		            fos = new FileOutputStream(outputFile);
		            cos = new CipherOutputStream(fos, cipher);
		            fos = null;
		            byte[] data = new byte[1024];
		            int read = fis.read(data);
		            while (read != -1) {
		                cos.write(data, 0, read);
		                read = fis.read(data);
		                System.out.println(new String(data, "UTF-8").trim());
		            }
		            cos.flush();
		        } finally {
		            if (cos != null) {
		                cos.close();
		             }
		             if (fos != null) {
		                fos.close();
		             }
		             if (fis != null) {
		                fis.close();
		             }
		        }
		    }	
		    public void decrypt(File inputFile, File outputFile, byte[] key) throws Exception {
		        Cipher cipher = getCipherDecrypt(key);
		        FileOutputStream fos = null;
		        CipherInputStream cis = null;
		        FileInputStream fis = null;
		        try {
		            fis = new FileInputStream(inputFile);
		            cis = new CipherInputStream(fis, cipher);
		            fos = new FileOutputStream(outputFile);
		            byte[] data = new byte[1024];
		            int read = cis.read(data);
		            while (read != -1) {
		                fos.write(data, 0, read);
		                read = cis.read(data);
		                System.out.println(new String(data, "UTF-8").trim());
		            }
		        } finally {
		            fos.close();
		            cis.close();
		            fis.close();
		        }
		    }		
		    
		    void doCallback(boolean success,String msg){
				if(_callback!=null){
	    			HashMap<String, Object> event = new HashMap<String, Object>();
	    			event.put(TiC.PROPERTY_SUCCESS, success);
	    			event.put("message", msg);
	    			event.put("to",_to.getAbsolutePath());	
	    			event.put("from",_from.getAbsolutePath());			
					_callback.call(getKrollObject(), event);
				}		    	
		    }
			@Override
			public void run() {
				try {	
					
					if(_isEncrypt){
						encrypt(_from, _to, getRawKey(_secret.getBytes()));			
					}else{
						decrypt(_from, _to, getRawKey(_secret.getBytes()));
					}
					doCallback(true,"completed");
				
				} catch (Exception e) {
					e.printStackTrace();
					doCallback(false,e.toString());
				}finally{
					if(_to!=null){
						_to=null;
					}
					if(_from!=null){
						_from=null;
					}					
				}
			}		
	}

	@Override
	public void handleCreationDict(KrollDict options)
	{
		super.handleCreationDict(options);
		if (options.containsKey("AESBytes")) {
			_aesBytes= TiConvert.toInt("AESBytes");			
		}		
	}
	@SuppressWarnings({ "rawtypes", "unchecked" })
	@Kroll.method
	public void AESDecrypt(HashMap hm){
		KrollDict args = new KrollDict(hm);
		
		if(!args.containsKey("completed")){
			throw new IllegalArgumentException("missing completed callback method");
		}
		if(!args.containsKey("secret")){
			throw new IllegalArgumentException("missing secret");
		}
		if(!args.containsKey("to")){
			throw new IllegalArgumentException("missing output file");
		}
		if(!args.containsKey("from")){
			throw new IllegalArgumentException("missing file to decrypt");
		}		
		String secret = args.getString("secret");
		KrollFunction callback = null;
		Object object = args.get("completed");
		if (object instanceof KrollFunction) {
			callback = (KrollFunction)object;
		}
		String rawSourceFile = args.getString("from");
		TiBaseFile sourceFile = TiFileFactory.createTitaniumFile(rawSourceFile,false);
		if(!sourceFile.exists()){
			throw new IllegalArgumentException("File to decrypt does not exist " + sourceFile.nativePath());
		}
		String rawOutputFile = args.getString("to");
		TiBaseFile outputFile = TiFileFactory.createTitaniumFile(rawOutputFile,false);
		if(outputFile.exists()){
			outputFile.deleteFile();
		}

		Thread clientThread = new Thread(new AESFilesRunnable(secret,callback,false,sourceFile.getNativeFile(),outputFile.getNativeFile()));
		clientThread.run();
        
	}

	@SuppressWarnings({ "rawtypes", "unchecked" })
	@Kroll.method
	public void AESEncrypt(HashMap hm){
		KrollDict args = new KrollDict(hm);
		
		if(!args.containsKey("completed")){
			throw new IllegalArgumentException("missing completed callback method");
		}
		if(!args.containsKey("secret")){
			throw new IllegalArgumentException("missing secret");
		}
		if(!args.containsKey("to")){
			throw new IllegalArgumentException("missing output file");
		}
		if(!args.containsKey("from")){
			throw new IllegalArgumentException("missing file to decrypt");
		}		
		String secret = args.getString("secret");
		KrollFunction callback = null;
		Object object = args.get("completed");
		if (object instanceof KrollFunction) {
			callback = (KrollFunction)object;
		}
		String rawSourceFile = args.getString("from");
		TiBaseFile sourceFile = TiFileFactory.createTitaniumFile(rawSourceFile,false);
		if(!sourceFile.exists()){
			throw new IllegalArgumentException("File to encrypt does not exist " + sourceFile.nativePath());
		}
		
		String rawOutputFile = args.getString("to");
		TiBaseFile outputFile = TiFileFactory.createTitaniumFile(rawOutputFile,false);
		if(outputFile.exists()){
			outputFile.deleteFile();
		}
		Thread clientThread = new Thread(new AESFilesRunnable(secret,callback,true,sourceFile.getNativeFile(),outputFile.getNativeFile()));
		clientThread.run();
	}
}
