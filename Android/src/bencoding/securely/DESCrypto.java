package bencoding.securely;
import javax.crypto.*;
import java.security.spec.*;
import javax.crypto.spec.*;
import android.util.Base64;
import java.io.*;
import java.security.*;

public class DESCrypto {
    public static String encrypt(String key,String inString){
        String outString=null;
        try {
            byte[] byteKey= key.getBytes("UTF8");    
            KeySpec ks= new DESKeySpec(byteKey);  
            SecretKeyFactory skf= SecretKeyFactory.getInstance("DES");
            SecretKey sk= skf.generateSecret(ks);
            Cipher cph=Cipher.getInstance("DES");
            cph.init(Cipher.ENCRYPT_MODE, sk);
            byte[] byteInString= inString.getBytes("UTF8");
            byte[] byteEncoded= cph.doFinal(byteInString);
            outString= Base64.encodeToString(byteEncoded, Base64.DEFAULT);
        }
        catch (UnsupportedEncodingException e){outString="Unable to convert key to byte array.";}
        catch (InvalidKeyException e){outString="Unable to generate KeySpec from key";}  
        catch (NoSuchAlgorithmException e){outString="Unable to find algorithm.";}
        catch (InvalidKeySpecException e){outString="Invalid Key Specification";}
        catch (NoSuchPaddingException e){outString="No such padding";}
        catch (IllegalArgumentException e){outString="Illegal argument";}    
        catch (Exception e){outString=e.getMessage();} //should not get here
    
        return(outString);
    }
    public static String decrypt(String key,String inString){
        String outString=null;
        try {
            byte[] byteKey= key.getBytes("UTF8");    
            KeySpec ks= new DESKeySpec(byteKey);  
            SecretKeyFactory skf= SecretKeyFactory.getInstance("DES");
            SecretKey sk= skf.generateSecret(ks);
            Cipher cph=Cipher.getInstance("DES");
            cph.init(Cipher.DECRYPT_MODE, sk);
            byte[] byteInString=Base64.decode(inString,Base64.DEFAULT);
            byte[] byteDecoded= cph.doFinal(byteInString);
            outString= new String(byteDecoded, "UTF8");
        }
        catch (UnsupportedEncodingException e){outString="Unable to convert key to byte array.";}
        catch (InvalidKeyException e){outString="Unable to generate KeySpec from key";}  
        catch (NoSuchAlgorithmException e){outString="Unable to find algorithm.";}
        catch (InvalidKeySpecException e){outString="Invalid Key Specification";}
        catch (NoSuchPaddingException e){outString="No such padding";}
        catch (BadPaddingException e){outString="Bad padding. Possible Wrong Key, Bad Text, Wrong Mode";}
        catch (IllegalBlockSizeException e){outString="Illegal block size";}
        catch (IllegalArgumentException e){outString="Illegal argument";}        
        catch (Exception e){outString=e.getMessage();} // should not get here
        
        return(outString);
    }    
}
