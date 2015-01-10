package bencoding.securely.recievers;


import java.util.Date;

import org.appcelerator.kroll.KrollDict;
import org.appcelerator.titanium.TiApplication;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;


public class LockBroadcastReciever extends BroadcastReceiver{
	public static boolean wasLocked = false;
	public static String EVENT_NAME = "BCX:SCREEN_OFF";
	@Override
	public void onReceive(Context context, Intent intent) {

		if(intent.getAction().equals(Intent.ACTION_SCREEN_OFF)){

			wasLocked = true;
			
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
		return wasLocked;
	}
	public void reset(){
		wasLocked = false;
	}

}
