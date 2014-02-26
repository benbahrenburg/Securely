package bencoding.securely.recievers;

import java.util.Date;

import org.appcelerator.kroll.KrollDict;
import org.appcelerator.titanium.TiApplication;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

public class UnlockBroadcastReciever extends BroadcastReceiver{
	public static boolean wasUnlocked = true;
	public static String EVENT_NAME = "BCX:SCREEN_ON";
	@Override
	public void onReceive(Context context, Intent intent) {

		if(intent.getAction().equals(Intent.ACTION_SCREEN_ON)){
			wasUnlocked = true;
			
			if(TiApplication.getInstance()!=null){
				KrollDict event = new KrollDict();
				Date now = new Date();
				event.put("actionName", intent.getAction());
				event.put("actionTime", now.getTime());			
				TiApplication.getInstance().fireAppEvent(EVENT_NAME, event);
			}
		}
	}
	
	public Boolean status()
	{
		return wasUnlocked;
	}
	public void reset(){
		wasUnlocked = true;
	}
}
