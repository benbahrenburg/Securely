package bencoding.securely;

import java.security.NoSuchAlgorithmException;
import java.util.HashMap;
import java.util.List;

import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.KrollPropertyChange;
import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.kroll.KrollProxyListener;
import org.appcelerator.kroll.annotations.Kroll;
import org.appcelerator.titanium.TiC;

import javax.net.ssl.HttpsURLConnection;

import java.net.URL;
import java.security.MessageDigest;
import java.security.cert.Certificate;


@Kroll.proxy(creatableInModule=SecurelyModule.class)
public class RemoteCertificateProxy  extends KrollProxy implements KrollProxyListener  {
   private static final String COMPLETED_EVENT = "completed";
   private static boolean _debug = false;

	public RemoteCertificateProxy(){
		super();
	}
	
   private static String dumpHex(byte[] data) {
	 char[] HEX_CHARS = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};
	  
	    final int n = data.length;
	    final StringBuilder sb = new StringBuilder(n * 3 - 1);
	    for (int i = 0; i < n; i++) {
	      if (i > 0) {
	        sb.append(' ');
	      }
	      sb.append(HEX_CHARS[(data[i] >> 4) & 0x0F]);
	      sb.append(HEX_CHARS[data[i] & 0x0F]);
	    }
	    return sb.toString();
    }

	private void triggerEvent(String eventName, HashMap<String, Object> event){
        if (hasListeners(eventName)) {          
            fireEvent(eventName, event);
        }else{
        	LogHelpers.DebugLog("[DEBUG] no changed listener defined");
        }
	}
	private class NetworkRunnable implements Runnable
	{

		String _url = null;
		public NetworkRunnable(String url){
			_url = url;			
		}
		
		HashMap<String, Object> buildSuccess(String thumbnail){
			HashMap<String, Object> event = new HashMap<String, Object>();
			event.put(TiC.PROPERTY_SUCCESS, true);	
			event.put("url",_url);	
			event.put("thumbprint",thumbnail);
			return event;
		}

		HashMap<String, Object> buildError(String message){
			HashMap<String, Object> event = new HashMap<String, Object>();
			event.put(TiC.PROPERTY_SUCCESS, false);	
			event.put("url",_url);	
			event.put("error",message);
			return event;
		}
		
		@Override
		public void run() {
			try {	
			    HttpsURLConnection connection = (HttpsURLConnection) new URL(_url).openConnection();
			    connection.setConnectTimeout(5000);
			    connection.connect();
			    
			    Certificate cert = connection.getServerCertificates()[0];
			    MessageDigest shaMsg = MessageDigest.getInstance("SHA1");
			    shaMsg.update(cert.getEncoded());
			    
			    String thumbprint = dumpHex(shaMsg.digest());
				
			    if(_debug){
					LogHelpers.DebugLog("thumbprint:" + thumbprint);
				}
			    triggerEvent(COMPLETED_EVENT,buildSuccess(thumbprint));
			    
			} catch (NoSuchAlgorithmException e) {
				e.printStackTrace();
				LogHelpers.Log(e);
				triggerEvent(COMPLETED_EVENT,buildError(e.toString()));
			} catch (Exception e) {
				e.printStackTrace();
				LogHelpers.Log(e);
				triggerEvent(COMPLETED_EVENT,buildError(e.toString()));			
			}
		}			
	}
	
	@SuppressWarnings({ "rawtypes", "unchecked" })
	@Kroll.method
	public void getThumbprint(HashMap hm){
		KrollDict args = new KrollDict(hm);
		
		if(!args.containsKey("url")){
			throw new IllegalArgumentException("missing completed callback method");
		}
		String url = args.getString("url");
		if(_debug){
			LogHelpers.DebugLog("URL:" + url);
		}
		Thread clientThread = new Thread(new NetworkRunnable(url));
		clientThread.run();
	}
	@Override
	public void listenerAdded(String arg0, int arg1, KrollProxy arg2) {}

	@Override
	public void listenerRemoved(String arg0, int arg1, KrollProxy arg2) {}

	@Override
	public void processProperties(KrollDict args) {
		_debug = args.optBoolean("debug", false);
	}

	@Override
	public void propertiesChanged(List<KrollPropertyChange> arg0,KrollProxy arg1) {}

	@Override
	public void propertyChanged(String arg0, Object arg1, Object arg2,KrollProxy arg3) {}

}
