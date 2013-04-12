package bencoding.securely;


import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.HashMap;

import javax.crypto.Cipher;
import javax.crypto.CipherInputStream;
import javax.crypto.CipherOutputStream;
import javax.crypto.KeyGenerator;
import javax.crypto.NoSuchPaddingException;
import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;

import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.KrollFunction;
import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.kroll.annotations.Kroll;
import org.appcelerator.titanium.TiApplication;
import org.appcelerator.titanium.TiC;
import org.appcelerator.titanium.TiLifecycle;
import org.appcelerator.titanium.io.TiBaseFile;
import org.appcelerator.titanium.io.TiFileFactory;
import org.appcelerator.titanium.util.TiConvert;

import android.app.Activity;

@Kroll.proxy(creatableInModule=SecurelyModule.class)
public class FileCryptoProxy  extends KrollProxy implements TiLifecycle.OnLifecycleEvent 
{

	public static final String RESOURCE_ROOT_ASSETS = "file:///android_asset/Resources";
	static int _aesBytes = 128;

	public FileCryptoProxy()
	{
		super();

	}
	
	private boolean isInResources(TiBaseFile file)
	{		
		if (file.isFile()) {
			return file.nativePath().startsWith(RESOURCE_ROOT_ASSETS);
		}
		return false;
	}
	
	private void copy(InputStream is, OutputStream os) throws IOException {
	    int i;
	    byte[] b = new byte[1024];
	    while((i=is.read(b))!=-1) {
	      os.write(b, 0, i);
	    }
	  }

	private static byte[] getRawKey(byte[] seed) throws Exception {
		KeyGenerator kgen = KeyGenerator.getInstance("AES");
		SecureRandom sr = SecureRandom.getInstance("SHA1PRNG", "Crypto");
		sr.setSeed(seed);
		try {
			kgen.init(256, sr);
			} catch (Exception e) {
			// Log.w(LOG, "This device doesn't support 256 bits, trying 192 bits.");
			try {
			kgen.init(192, sr);
			} catch (Exception e1) {
			// Log.w(LOG, "This device doesn't support 192 bits, trying 128 bits.");
			kgen.init(128, sr);
			}
		}
		SecretKey skey = kgen.generateKey();
		byte[] raw = skey.getEncoded();
		return raw;
	}
    private void doCallback(KrollFunction callback,HashMap<String, Object> event){
		if(callback!=null){		
			callback.call(getKrollObject(), event);
		}		    	
    }

	private class AESDecryptRunnable implements Runnable
	{
		private FileOutputStream _to = null;
		private FileInputStream _from = null;
		KrollFunction _callback = null;
		String _secret = null;
		String _inputFile = null;
		String _outputFile = null;
		public AESDecryptRunnable(String password, 
								 FileInputStream from, 
								 FileOutputStream to,
								 KrollFunction callback,
								 String inputFile, String outputFile ){
			_secret = password;
			_to=to;
			_from = from;
			_callback=callback;
			_inputFile = inputFile;
			_outputFile = outputFile;			
		}
		
		HashMap<String, Object> buildResult(Boolean success){
			HashMap<String, Object> event = new HashMap<String, Object>();
			event.put(TiC.PROPERTY_SUCCESS, success);	
			event.put("to",_outputFile);	
			event.put("from",_inputFile);
			return event;
		}
		@Override
		public void run() {
			try {	
				byte[] raw = null;
				raw = getRawKey(_secret.getBytes());				
				SecretKeySpec skeySpec = new SecretKeySpec(raw, "AES");
				Cipher cipher = Cipher.getInstance("AES");
				cipher.init(Cipher.DECRYPT_MODE, skeySpec);					
				CipherInputStream is = new CipherInputStream(_from,cipher);
				
				copy(is, _to);

				is.close();
				_to.close();
				_from.close();						
				doCallback(_callback, buildResult(true));
								
			} catch (NoSuchAlgorithmException e) {
				e.printStackTrace();
				LogHelpers.Log(e);
				HashMap<String, Object> event = buildResult(false);
				event.put("message",e.toString());	
				doCallback(_callback, event);					
			} catch (NoSuchPaddingException e) {
				e.printStackTrace();
				LogHelpers.Log(e);
				HashMap<String, Object> event = buildResult(false);
				event.put("message",e.toString());	
				doCallback(_callback, event);
			} catch (Exception e) {
				e.printStackTrace();
				LogHelpers.Log(e);
				HashMap<String, Object> event = buildResult(false);
				event.put("message",e.toString());	
				doCallback(_callback, event);			
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
	private class AESEncryptRunnable implements Runnable
	{
		private FileOutputStream _to = null;
		private FileInputStream _from = null;
		KrollFunction _callback = null;
		String _secret = null;
		String _inputFile = null;
		String _outputFile = null;
		public AESEncryptRunnable(String password, 
								 FileInputStream from, 
								 FileOutputStream to,
								 KrollFunction callback,
								 String inputFile, String outputFile ){
			_secret = password;
			_to=to;
			_from = from;
			_callback=callback;
			_inputFile = inputFile;
			_outputFile = outputFile;			
		}
		
		HashMap<String, Object> buildResult(Boolean success){
			HashMap<String, Object> event = new HashMap<String, Object>();
			event.put(TiC.PROPERTY_SUCCESS, success);	
			event.put("to",_outputFile);	
			event.put("from",_inputFile);
			return event;
		}
		@Override
		public void run() {
			try {	

				byte[] raw = null;
				raw = getRawKey(_secret.getBytes());

				SecretKeySpec skeySpec = new SecretKeySpec(raw, "AES");
				Cipher cipher = Cipher.getInstance("AES");
				cipher.init(Cipher.ENCRYPT_MODE, skeySpec);				
				CipherOutputStream os = new CipherOutputStream(_to, cipher);

				copy(_from, os);
				os.close();
				doCallback(_callback, buildResult(true));	
				
			} catch (NoSuchAlgorithmException e) {
				e.printStackTrace();
				LogHelpers.Log(e);
				HashMap<String, Object> event = buildResult(false);
				event.put("message",e.toString());	
				doCallback(_callback, event);					
			} catch (NoSuchPaddingException e) {
				e.printStackTrace();
				LogHelpers.Log(e);
				HashMap<String, Object> event = buildResult(false);
				event.put("message",e.toString());	
				doCallback(_callback, event);
			} catch (Exception e) {
				e.printStackTrace();
				LogHelpers.Log(e);
				HashMap<String, Object> event = buildResult(false);
				event.put("message",e.toString());	
				doCallback(_callback, event);	
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
		if(!args.containsKey("password")){
			throw new IllegalArgumentException("missing password");
		}
		if(!args.containsKey("to")){
			throw new IllegalArgumentException("missing output file");
		}
		if(!args.containsKey("from")){
			throw new IllegalArgumentException("missing file to decrypt");
		}		
		String secret = args.getString("password");
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
		if(isInResources(outputFile)){
			throw new IllegalArgumentException("Output file cannot be in a protected directory " + outputFile.nativePath());
		}
		if(outputFile.exists()){
			outputFile.deleteFile();
		}
  
		try{
			
			FileInputStream fis = null;
			if(isInResources(sourceFile)){
				String path = removeResourcesDirectory(sourceFile.nativePath());
				fis = new FileInputStream(TiApplication.getInstance().getApplicationContext().getFileStreamPath(path));
			}else{
				fis = new FileInputStream(sourceFile.getNativeFile());
			}

			String path = removeFilePrefix(outputFile.nativePath());
			//LogHelpers.Log("path=" + path);					
	        FileOutputStream fos = new FileOutputStream(path); 
	        			
			Thread clientThread = new Thread(new AESDecryptRunnable(secret,fis,fos, callback,sourceFile.nativePath(),outputFile.nativePath() ));
			clientThread.run();
			
		} catch (FileNotFoundException e) {
			e.printStackTrace();
			LogHelpers.Log(e);
		}
	}

	private String removeResourcesDirectory(String path){
		if(path.startsWith("file:///android_asset/Resources/")){
			int len = "file:///android_asset/Resources/".length();
			return path.substring(len);
		}else{
			return path;
		}
	}
   
	private String removeFilePrefix(String path){
		if(path.startsWith("file:/")){
			int len = "file:/".length();
			return path.substring(len);
		}else{
			return path;
		}
	}
	
	@SuppressWarnings({ "rawtypes", "unchecked" })
	@Kroll.method
	public void AESEncrypt(HashMap hm){
		KrollDict args = new KrollDict(hm);

		if(!args.containsKey("completed")){
			throw new IllegalArgumentException("missing completed callback method");
		}
		if(!args.containsKey("password")){
			throw new IllegalArgumentException("missing password");
		}
		if(!args.containsKey("to")){
			throw new IllegalArgumentException("missing output file");
		}
		if(!args.containsKey("from")){
			throw new IllegalArgumentException("missing file to decrypt");
		}		
		String secret = args.getString("password");
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
		if(isInResources(outputFile)){
			throw new IllegalArgumentException("Output file cannot be in a protected directory " + outputFile.nativePath());
		}
		
		if(outputFile.exists()){
			outputFile.deleteFile();
		}

		try{
				
			FileInputStream fis = null;
			if(isInResources(sourceFile)){
				String path = removeResourcesDirectory(sourceFile.nativePath());
				fis = new FileInputStream(TiApplication.getInstance().getApplicationContext().getFileStreamPath(path));
			}else{
				fis = new FileInputStream(sourceFile.getNativeFile());
			}

			String path = removeFilePrefix(outputFile.nativePath());
			//LogHelpers.Log("path=" + path);					
	        FileOutputStream fos = new FileOutputStream(path);
			
			Thread clientThread = new Thread(new AESEncryptRunnable(secret,fis,fos, callback,sourceFile.nativePath(),outputFile.nativePath() ));
			clientThread.run();
			
		} catch (FileNotFoundException e) {
			e.printStackTrace();
			LogHelpers.Log(e);			
		}	
	}
	@Override
	public void onDestroy(Activity arg0) {}
	@Override
	public void onPause(Activity arg0) {}
	@Override
	public void onResume(Activity arg0) {}
	@Override
	public void onStart(Activity arg0) {}
	@Override
	public void onStop(Activity arg0) {}
}
