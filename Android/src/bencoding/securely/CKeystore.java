package bencoding.securely;

import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.os.Build;
import android.util.Log;
import java.lang.reflect.Method;
import java.util.List;

public class CKeystore
{
    /**
     * Always use this method before any of the other methods.
     *
     * Checks if we think we're able to use the keystore daemon.
     * All it does is try to instantiate the required reflection
     * methods, classes and intents.
     */
    public static boolean featureAvailable(Context ctx)
    { return (getKeystoreInstance(ctx) != null); }
 
    /**
     * Launch an intent (if necessary) to unlock the
     * keystore.
     */
    public static synchronized void startUnlock(Context ctx)
    {
        if (!featureAvailable(ctx)) {
            throw new IllegalStateException("Keystore feature unavailable");
        }
        if (isOpen(ctx)) { return; }
        ctx.startActivity(s_unlock_intent);
    }
 
    /**
     * Check if we believe the keystore is open. Internally, it
     * tries to access a non-existent key (don't use a key named
     * ___) and check the error code.
     */
    public static synchronized boolean isOpen(Context ctx)
    {
        Object ksi = getKeystoreInstance(ctx);
        if (ksi == null) {
            throw new IllegalStateException("Keystore feature unavailable");
        }
        try {
            // Just run a dummy method to get the error status.
            if (s_ks_method_get_s != null) {
                s_ks_method_get_s.invoke(ksi, K_EMPTY_S);
            }
            else {
                s_ks_method_get_b.invoke(ksi, K_EMPTY_B);
            }
            Object eo = s_ks_method_get_last_error.invoke(ksi);
            if (eo == null) {
                // unexpected.
                throw new RuntimeException("unexpected null on getLastError()");
            }
 
            // result is of type int.
            if (!(eo instanceof Integer)) {
                throw new RuntimeException("bad ret: "+eo);
            }
 
            // Anything other than
            // android.security.KeyStore.KEY_NOT_FOUND means we can't
            // access the keystore.
            return ((Integer) eo).intValue() == 7;
        }
        catch (Exception ex) {
            throw new RuntimeException("Unable to access keystore", ex);
        }
    }
 
    public static synchronized boolean putBytes
        (Context ctx, String key, byte[] value)
    {
        Object ksi = getKeystoreInstance(ctx);
        if (ksi == null) {
            throw new IllegalStateException("Keystore feature unavailable");
        }
 
        try {
            Object result;
            if (s_ks_method_put_s != null) {
                result = s_ks_method_put_s.invoke(ksi, key, value);
            }
            else {
                result = s_ks_method_put_b.invoke
                    (ksi, key.getBytes("utf-8"), value);
            }
            if (result == null) {
                throw new RuntimeException("Unexpected - null on put()");
            }
            if (!(result instanceof Boolean)) {
                throw new RuntimeException("Unexpected - non-boolean: "+result);
            }
            return ((Boolean) result).booleanValue();
        }
        catch (Exception ex) {
            throw new RuntimeException("Unable to put to keystore", ex);
        }
    }
 
    public static synchronized byte[] getBytes(Context ctx, String key)
    {
        Object ksi = getKeystoreInstance(ctx);
        if (ksi == null) {
            throw new IllegalStateException("Keystore feature unavailable");
        }
 
        try {
            Object result;
            if (s_ks_method_get_s != null) {
                result = s_ks_method_get_s.invoke(ksi, key);
            }
            else {
                result = s_ks_method_get_b.invoke(ksi, key.getBytes("utf-8"));
            }
            if (result == null) {
                return null;
            }
            return (byte[]) result;
        }
        catch (Exception ex) {
            throw new RuntimeException("Unable to get from keystore", ex);
        }
    }
 
    @SuppressWarnings({ "unchecked", "rawtypes" })
    private final static synchronized Object getKeystoreInstance(Context ctx)
    {
        if (s_keystore_instance != null) { return s_keystore_instance; }
 
        // Basic check -- do we have a receiver for a keystore unlock
        // intent?
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.HONEYCOMB) {
            s_unlock_intent = new Intent("android.credentials.UNLOCK");
        }
        else {
            s_unlock_intent = new Intent("com.android.credentials.UNLOCK");
        }
 
        List<ResolveInfo> rlist =
            ctx.getPackageManager()
            .queryIntentActivities
            (s_unlock_intent, PackageManager.MATCH_DEFAULT_ONLY);
        if ((rlist == null) || (rlist.size() == 0)) {
            return null;
        }
 
        try {
            // s_keystore_instance = Keystore.getInstance();
            Class ksclass = Class.forName("android.security.KeyStore");
            Method getInstance = ksclass.getMethod("getInstance");
            Object ksi = getInstance.invoke(null);
 
            // debugging
            /*
            Method[] m = ksclass.getDeclaredMethods();
            for (int i=0; i<m.length; i++) {
                Log.d(TAG, "ks-dm: "+m[i]);
            }
            */
 
            // cache various methods, different ones depending
            // on the various android versions.
            s_ks_method_get_last_error = ksclass.getMethod("getLastError");
            try {
                // Try the key-by-string variations.
                s_ks_method_put_s = ksclass.getMethod
                    ("put", String.class, byte[].class);
                s_ks_method_get_s = ksclass.getMethod
                    ("get", String.class);
            }
            catch (Throwable th) {
                s_ks_method_put_s = null;
                s_ks_method_get_s = null;
 
                // Otherwise, try the by-byte variations.
                s_ks_method_put_b =
                    ksclass.getMethod("put", byte[].class, byte[].class);
                s_ks_method_get_b = ksclass.getMethod("get", byte[].class);
            }
 
 
            // Got so far == good.
            s_keystore_instance = ksi;
            return s_keystore_instance;
        }
        catch (Throwable th) {
            Log.d(TAG, "Unable to get keystore", th);
            return null;
        }
    }
 
    private static Object s_keystore_instance = null;
    private static Method s_ks_method_get_last_error;
    private static Method s_ks_method_put_s;
    private static Method s_ks_method_get_s;
    private static Method s_ks_method_put_b;
    private static Method s_ks_method_get_b;
    private static Intent s_unlock_intent;
    private final static byte[] K_EMPTY_B ={(byte) '_', (byte) '_', (byte) '_'};
    private final static String K_EMPTY_S = "___";
    private final static String TAG = CKeystore.class.getName();
}