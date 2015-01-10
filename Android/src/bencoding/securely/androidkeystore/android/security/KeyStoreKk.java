/*
 * Copyright (C) 2009 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//package android.security;
package bencoding.securely.androidkeystore.android.security;


import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.Locale;

import android.os.IBinder;
import android.os.RemoteException;
import android.security.IKeystoreService;
import android.util.Log;

/**
 * @hide This should not be made public in its present form because it
 * assumes that private and secret key bytes are available and would
 * preclude the use of hardware crypto.
 */
public class KeyStoreKk extends KeyStore {
    private static final String TAG = "KeyStore";

    // ResponseCodes
    public static final int NO_ERROR = 1;
    public static final int LOCKED = 2;
    public static final int UNINITIALIZED = 3;
    public static final int SYSTEM_ERROR = 4;
    public static final int PROTOCOL_ERROR = 5;
    public static final int PERMISSION_DENIED = 6;
    public static final int KEY_NOT_FOUND = 7;
    public static final int VALUE_CORRUPTED = 8;
    public static final int UNDEFINED_ACTION = 9;
    public static final int WRONG_PASSWORD = 10;

    // Used for UID field to indicate the calling UID.
    public static final int UID_SELF = -1;

    // Flags for "put" "import" and "generate"
    public static final int FLAG_NONE = 0;
    public static final int FLAG_ENCRYPTED = 1;

    // States
    //    public enum State { UNLOCKED, LOCKED, UNINITIALIZED };

    private int mError = NO_ERROR;

    private final IKeystoreService mBinder;

    private KeyStoreKk(IKeystoreService binder) {
        mBinder = binder;
    }

    public static KeyStoreKk getInstance() {
        //        IKeystoreService keystore = IKeystoreService.Stub.asInterface(ServiceManager
        //                .getService("android.security.keystore"));
        //        return new KeyStore(keystore);
        try {
            Class<?> smClass = Class.forName("android.os.ServiceManager");

            Method getService = smClass.getMethod("getService", String.class);
            IBinder binder = (IBinder) getService.invoke(null,
                    "android.security.keystore");
            IKeystoreService keystore = IKeystoreService.Stub
                    .asInterface(binder);
            return new KeyStoreKk(keystore);
        } catch (ClassNotFoundException e) {
            throw new RuntimeException(e);
        } catch (NoSuchMethodException e) {
            throw new RuntimeException(e);
        } catch (IllegalArgumentException e) {
            throw new RuntimeException(e);
        } catch (IllegalAccessException e) {
            throw new RuntimeException(e);
        } catch (InvocationTargetException e) {
            throw new RuntimeException(e);
        }
    }

    static int getKeyTypeForAlgorithm(String keyType) throws IllegalArgumentException {
        if ("RSA".equalsIgnoreCase(keyType)) {
            return NativeCryptoConstants.EVP_PKEY_RSA;
        } else if ("DSA".equalsIgnoreCase(keyType)) {
            return NativeCryptoConstants.EVP_PKEY_DSA;
        } else if ("EC".equalsIgnoreCase(keyType)) {
            return NativeCryptoConstants.EVP_PKEY_EC;
        } else {
            throw new IllegalArgumentException("Unsupported key type: " + keyType);
        }
    }

    public State state() {
        final int ret;
        try {
            ret = mBinder.test();
        } catch (RemoteException e) {
            Log.w(TAG, "Cannot connect to keystore", e);
            throw new AssertionError(e);
        }

        switch (ret) {
            case NO_ERROR: return State.UNLOCKED;
            case LOCKED: return State.LOCKED;
            case UNINITIALIZED: return State.UNINITIALIZED;
            default: throw new AssertionError(mError);
        }
    }

    public boolean isUnlocked() {
        return state() == State.UNLOCKED;
    }

    public byte[] get(String key) {
        try {
            return mBinder.get(key);
        } catch (RemoteException e) {
            Log.w(TAG, "Cannot connect to keystore", e);
            return null;
        }
    }

    @Override
    public boolean put(String key, byte[] value) {
        return put(key, value, UID_SELF, FLAG_ENCRYPTED);
    }

    public boolean put(String key, byte[] value, int uid, int flags) {
        try {
            return mBinder.insert(key, value, uid, flags) == NO_ERROR;
        } catch (RemoteException e) {
            Log.w(TAG, "Cannot connect to keystore", e);
            return false;
        }
    }

    public boolean delete(String key, int uid) {
        try {
            return mBinder.del(key, uid) == NO_ERROR;
        } catch (RemoteException e) {
            Log.w(TAG, "Cannot connect to keystore", e);
            return false;
        }
    }

    public boolean delete(String key) {
        return delete(key, UID_SELF);
    }

    public boolean contains(String key, int uid) {
        try {
            return mBinder.exist(key, uid) == NO_ERROR;
        } catch (RemoteException e) {
            Log.w(TAG, "Cannot connect to keystore", e);
            return false;
        }
    }

    public boolean contains(String key) {
        return contains(key, UID_SELF);
    }

    public String[] saw(String prefix, int uid) {
        try {
            return mBinder.saw(prefix, uid);
        } catch (RemoteException e) {
            Log.w(TAG, "Cannot connect to keystore", e);
            return null;
        }
    }

    public String[] saw(String prefix) {
        return saw(prefix, UID_SELF);
    }

    public boolean reset() {
        try {
            return mBinder.reset() == NO_ERROR;
        } catch (RemoteException e) {
            Log.w(TAG, "Cannot connect to keystore", e);
            return false;
        }
    }

    public boolean password(String password) {
        try {
            return mBinder.password(password) == NO_ERROR;
        } catch (RemoteException e) {
            Log.w(TAG, "Cannot connect to keystore", e);
            return false;
        }
    }

    public boolean lock() {
        try {
            return mBinder.lock() == NO_ERROR;
        } catch (RemoteException e) {
            Log.w(TAG, "Cannot connect to keystore", e);
            return false;
        }
    }

    public boolean unlock(String password) {
        try {
            mError = mBinder.unlock(password);
            return mError == NO_ERROR;
        } catch (RemoteException e) {
            Log.w(TAG, "Cannot connect to keystore", e);
            return false;
        }
    }

    public boolean isEmpty() {
        try {
            return mBinder.zero() == KEY_NOT_FOUND;
        } catch (RemoteException e) {
            Log.w(TAG, "Cannot connect to keystore", e);
            return false;
        }
    }

    public boolean generate(String key, int uid, int keyType, int keySize, int flags,
            byte[][] args) {
        try {
            return mBinder.generate(key, uid, keyType, keySize, flags, args) == NO_ERROR;
        } catch (RemoteException e) {
            Log.w(TAG, "Cannot connect to keystore", e);
            return false;
        }
    }

    public boolean importKey(String keyName, byte[] key, int uid, int flags) {
        try {
            return mBinder.import_key(keyName, key, uid, flags) == NO_ERROR;
        } catch (RemoteException e) {
            Log.w(TAG, "Cannot connect to keystore", e);
            return false;
        }
    }

    public byte[] getPubkey(String key) {
        try {
            return mBinder.get_pubkey(key);
        } catch (RemoteException e) {
            Log.w(TAG, "Cannot connect to keystore", e);
            return null;
        }
    }

    public boolean delKey(String key, int uid) {
        try {
            return mBinder.del_key(key, uid) == NO_ERROR;
        } catch (RemoteException e) {
            Log.w(TAG, "Cannot connect to keystore", e);
            return false;
        }
    }

    public boolean delKey(String key) {
        return delKey(key, UID_SELF);
    }

    public byte[] sign(String key, byte[] data) {
        try {
            return mBinder.sign(key, data);
        } catch (RemoteException e) {
            Log.w(TAG, "Cannot connect to keystore", e);
            return null;
        }
    }

    public boolean verify(String key, byte[] data, byte[] signature) {
        try {
            return mBinder.verify(key, data, signature) == NO_ERROR;
        } catch (RemoteException e) {
            Log.w(TAG, "Cannot connect to keystore", e);
            return false;
        }
    }

    public boolean grant(String key, int uid) {
        try {
            return mBinder.grant(key, uid) == NO_ERROR;
        } catch (RemoteException e) {
            Log.w(TAG, "Cannot connect to keystore", e);
            return false;
        }
    }

    public boolean ungrant(String key, int uid) {
        try {
            return mBinder.ungrant(key, uid) == NO_ERROR;
        } catch (RemoteException e) {
            Log.w(TAG, "Cannot connect to keystore", e);
            return false;
        }
    }

    /**
     * Returns the last modification time of the key in milliseconds since the
     * epoch. Will return -1L if the key could not be found or other error.
     */
    public long getmtime(String key) {
        try {
            final long millis = mBinder.getmtime(key);
            if (millis == -1L) {
                return -1L;
            }

            return millis * 1000L;
        } catch (RemoteException e) {
            Log.w(TAG, "Cannot connect to keystore", e);
            return -1L;
        }
    }

    public boolean duplicate(String srcKey, int srcUid, String destKey, int destUid) {
        try {
            return mBinder.duplicate(srcKey, srcUid, destKey, destUid) == NO_ERROR;
        } catch (RemoteException e) {
            Log.w(TAG, "Cannot connect to keystore", e);
            return false;
        }
    }

    // TODO remove this when it's removed from Settings
    public boolean isHardwareBacked() {
        return isHardwareBacked("RSA");
    }

    public boolean isHardwareBacked(String keyType) {
        try {
            return mBinder.is_hardware_backed(keyType.toUpperCase(Locale.US)) == NO_ERROR;
        } catch (RemoteException e) {
            Log.w(TAG, "Cannot connect to keystore", e);
            return false;
        }
    }

    public boolean clearUid(int uid) {
        try {
            return mBinder.clear_uid(uid) == NO_ERROR;
        } catch (RemoteException e) {
            Log.w(TAG, "Cannot connect to keystore", e);
            return false;
        }
    }

    public int getLastError() {
        return mError;
    }
}