package bencoding.securely;
import org.appcelerator.kroll.common.Log;

public class Helpers {
	
	private static boolean _writeToLog = true;
	public Helpers()
	{
		super();
	}
	
	public static void UpdateWriteStatus(boolean value){
		_writeToLog = true;
	}
	public static void  Log(String message){
		if(_writeToLog){
			Log.i(SecurelyModule.SECURELY_MODULE_FULL_NAME, message);
		}
		
	}
	public static void DebugLog(String message){
		if(_writeToLog){
			Log.d(SecurelyModule.SECURELY_MODULE_FULL_NAME, message);
		}
	}
}
