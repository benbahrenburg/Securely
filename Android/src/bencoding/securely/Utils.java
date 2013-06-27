/**
 * Securely Titanium Security Project
 * Copyright (c) 2009-2013 by Benjamin Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 *
 */
package bencoding.securely;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import org.appcelerator.titanium.TiApplication;
import org.appcelerator.titanium.io.TiBaseFile;
import org.appcelerator.titanium.io.TiFileFactory;
import org.appcelerator.titanium.util.TiFileHelper;

import android.content.ComponentName;
import android.content.Context;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;

public class Utils {

	public static final String RESOURCE_ROOT_ASSETS = "file:///android_asset/";
	public static final String TEMP_PREFIX = "cachebcding";

	public static void streamCopy(InputStream is, OutputStream os) throws IOException {
	    int i;
	    byte[] b = new byte[1024];
	    while((i=is.read(b))!=-1) {
	      os.write(b, 0, i);
	    }
	}
	
	public static ActivityInfo getMetaInfo(Context context, String componentName){
		ActivityInfo info = null;
		try {
			info = context.getPackageManager().getReceiverInfo(new ComponentName(context, componentName), PackageManager.GET_META_DATA);			
		} catch (NameNotFoundException e) {
			e.printStackTrace();
		}		
		
		return info;
	}
	
	public static boolean fileCanBeLoadedFromPath(String path){
		
		TiFileHelper foo = new TiFileHelper(TiApplication.getInstance().getApplicationContext());
		try {
			InputStream stream = foo.openInputStream(path, true);
			stream.close();
			return true;
		} catch (IOException e) {
			e.printStackTrace();
			LogHelpers.Log(e);
			return false;
		}
	}

	public static OutputStream createOutputStreamFromPath(String path) throws IOException{
		TiBaseFile outFile = TiFileFactory.createTitaniumFile(path,false);					
        return outFile.getOutputStream(); 		
	}
	
	public static File createTempFileFromFileAtPath(String path) throws IOException{	
		TiFileHelper helper = new TiFileHelper(TiApplication.getInstance().getApplicationContext());
		InputStream stream = helper.openInputStream(path, true);
		File tempFile = helper.getTempFileFromInputStream(stream,TEMP_PREFIX,true);
		stream.close();
		return tempFile;
	}
	
	public static boolean pathIsInAssets(TiBaseFile file)
	{		
		if (file.isFile()) {
			return file.nativePath().startsWith(RESOURCE_ROOT_ASSETS);
		}
		return false;
	}

	public static boolean pathIsInResources(String path)
	{		
		return path.startsWith(RESOURCE_ROOT_ASSETS + "Resources");
	}
	
	public static boolean pathIsInResources(TiBaseFile file)
	{		
		if (file.isFile()) {
			return pathIsInResources(file.nativePath());
		}
		return false;
	}
	
	public static String removeResourcesDirectoryFromPath(String path){
		if(path.startsWith(RESOURCE_ROOT_ASSETS + "Resources")){
			int len = (RESOURCE_ROOT_ASSETS + "Resources").length();
			return path.substring(len);
		}else{
			return path;
		}
	}
   
	public static String removeFilePrefixFromPath(String path){
		if(path.startsWith("file:/")){
			int len = "file:/".length();
			return path.substring(len);
		}else{
			return path;
		}
	}	
}
