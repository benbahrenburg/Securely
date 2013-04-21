package bencoding.securely;

import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.kroll.annotations.Kroll;
import org.appcelerator.titanium.TiApplication;
import org.appcelerator.titanium.TiLifecycle;

import bencoding.securely.recievers.LockBroadcastReciever;
import bencoding.securely.recievers.UnlockBroadcastReciever;

import android.app.Activity;
import android.app.KeyguardManager;
import android.content.Intent;
import android.content.IntentFilter;

@Kroll.proxy(creatableInModule=SecurelyModule.class)
public class LockScreenHelperProxy extends KrollProxy implements TiLifecycle.OnLifecycleEvent {
	LockBroadcastReciever mLockedReciever = null;
	UnlockBroadcastReciever mUnLockedReciever = null;
	public LockScreenHelperProxy(){
		super();	
	}

	@Kroll.method
	public Boolean wasLocked(){
		if(mLockedReciever==null){
			return false;
		}else{
			return mLockedReciever.status();
		}
	}

	@Kroll.method
	public void startMonitorForScreenOn(){
		   // INITIALIZE RECEIVER
	    IntentFilter filter = new IntentFilter(Intent.ACTION_SCREEN_ON);
	    if(mUnLockedReciever!=null){
	    	stopMonitorForScreenOn();
	    }
	    mUnLockedReciever = new UnlockBroadcastReciever();
	    mUnLockedReciever.reset();
	    TiApplication.getInstance().getApplicationContext().registerReceiver(mUnLockedReciever, filter);	
	}

	@Kroll.method
	public void resetMonitorForScreenOn(){
		if(mUnLockedReciever!=null){
			mUnLockedReciever.reset();
		}
	}
	
	@Kroll.method
	public void stopMonitorForScreenOn(){
		if(mUnLockedReciever!=null){
			TiApplication.getInstance().getApplicationContext().unregisterReceiver(mUnLockedReciever);
			mUnLockedReciever=null;
		}
	}
	
	@Kroll.method
	public void startMonitorForScreenOff(){
		   // INITIALIZE RECEIVER
	    IntentFilter filter = new IntentFilter(Intent.ACTION_SCREEN_OFF);
	    if(mLockedReciever!=null){
	    	stopMonitorForScreenOff();
	    }
	    mLockedReciever = new LockBroadcastReciever();
	    mLockedReciever.reset();
	    TiApplication.getInstance().getApplicationContext().registerReceiver(mLockedReciever, filter);	
	}

	@Kroll.method
	public void stopMonitorForScreenOff(){
		if(mLockedReciever!=null){
			TiApplication.getInstance().getApplicationContext().unregisterReceiver(mLockedReciever);
			mLockedReciever=null;
		}
	}

	@Kroll.method
	public void stopMonitoring(){
		stopMonitorForScreenOff();
		stopMonitorForScreenOn();
	}
	@Kroll.method
	public void resetMonitorForScreenOff(){
		if(mLockedReciever!=null){
			mLockedReciever.reset();
		}
	}
		@Kroll.method
	public boolean isShowingLockScreen(){
		KeyguardManager kgMgr = 
			    (KeyguardManager) TiApplication.getInstance().getApplicationContext().getSystemService(TiApplication.KEYGUARD_SERVICE);
			boolean showing = kgMgr.inKeyguardRestrictedInputMode();
			return showing;
	}

		@Override
		public void onDestroy(Activity arg0) {
			stopMonitoring();
		}

		@Override
		public void onPause(Activity arg0) {}

		@Override
		public void onResume(Activity arg0) {}

		@Override
		public void onStart(Activity arg0) {}

		@Override
		public void onStop(Activity arg0) {}
}
