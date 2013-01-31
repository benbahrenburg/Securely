package bencoding.securely;

//JSON helpers inspired or pasted from Eric Butler https://gist.github.com/2339666

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.google.gson.Gson;

public class Converters {

	public static byte[] toByte(String hexString) {
	        int len = hexString.length()/2;
	        byte[] result = new byte[len];
	        for (int i = 0; i < len; i++)
	                result[i] = Integer.valueOf(hexString.substring(2*i, 2*i+2), 16).byteValue();
	        return result;
	}

	public static String toHex(byte[] buf) {
	        if (buf == null)
	                return "";
	        StringBuffer result = new StringBuffer(2*buf.length);
	        for (int i = 0; i < buf.length; i++) {
	                appendHex(result, buf[i]);
	        }
	        return result.toString();
	}
	private final static String HEX = "0123456789ABCDEF";
	private static void appendHex(StringBuffer sb, byte b) {
	        sb.append(HEX.charAt((b>>4)&0x0f)).append(HEX.charAt(b&0x0f));
	}

	public static Boolean StringToBoolean(String value){
		Boolean ifNullValue = false;
		if(value == null){
			return ifNullValue;
		}
		return Boolean.parseBoolean(value);
		
	}
	public static int StringToInt(String value){
		int ifNullValue = 0;
		if(value == null){
			return ifNullValue;
		}
		return Integer.parseInt(value);
	}
	public static double StringToDouble(String value){
		double ifNullValue = 0D;
		if(value == null){
			return ifNullValue;
		}		
		return Double.parseDouble(value);
	};
	
	public static String BooleanToString(Boolean value){
		String sValue = new Boolean(value).toString();
		return sValue;
	}
	public static String IntToString(int value){
		String sValue = new Integer(value).toString();
		return sValue;
	}	
	public static String DoubleToString(double value){
		String sValue = new Double(value).toString();
		return sValue;
	}		
	public static String objectToGson(Object value){
	      String jsonText = new Gson().toJson(value);
	      //LogHelpers.DebugLog("object jsonText : " + jsonText);
	      return jsonText;
	}
	@SuppressWarnings("rawtypes")
	public static HashMap toHashMap(JSONArray array) throws JSONException {
		HashMap<String, Object> pairs = new HashMap<String, Object>();
		for (int i = 0; i < array.length(); i++) {
		   JSONObject j = array.optJSONObject(i);
			Iterator keys = j.keys();
	        while (keys.hasNext()) {
	            String key = (String) keys.next();
	            pairs.put(key, fromJson(j.get(key)));
	        }
		}
		return pairs;
	}
    @SuppressWarnings("rawtypes")
	public static Object toJSON(Object object) throws JSONException {
        if (object instanceof HashMap) {
            JSONObject json = new JSONObject();
            HashMap hashmap = (HashMap) object;
            for (Object key : hashmap.keySet()) {
                json.put(key.toString(), toJSON(hashmap.get(key)));
            }
            return json;
        } else if (object instanceof Map) {
            JSONObject json = new JSONObject();
			Map map = (Map) object;
            for (Object key : map.keySet()) {
                json.put(key.toString(), toJSON(map.get(key)));
            }
            return json;
        } else if (object instanceof Iterable) {
            JSONArray json = new JSONArray();
            for (Object value : ((Iterable)object)) {
            	json.put(toJSON(value));
            }
            return json;
        } else {
            return object;
        }
    }

	public static String toJSONString(Object object) throws JSONException {
    	Object results = toJSON(object);
    	return ((results ==null) ? null : results.toString());
    }
	
    public static boolean isEmptyObject(JSONObject object) {
        return object.names() == null;
    }

    public static Map<String, Object> getMap(JSONObject object, String key) throws JSONException {
        return toMap(object.getJSONObject(key));
    }

    @SuppressWarnings({ "rawtypes", "unchecked" })
    public static Map<String, Object> toMap(JSONObject object) throws JSONException {
		Map<String, Object> map = new HashMap();
		Iterator keys = object.keys();
        while (keys.hasNext()) {
            String key = (String) keys.next();
            map.put(key, fromJson(object.get(key)));
        }
        return map;
    }

    @SuppressWarnings({ "rawtypes", "unchecked" })
	public static List toList(JSONArray array) throws JSONException {
        List list = new ArrayList();
        for (int i = 0; i < array.length(); i++) {
            list.add(fromJson(array.get(i)));
        }
        return list;
    }

    public static Object fromJson(Object json) throws JSONException {
        if (json == JSONObject.NULL) {
            return null;
        } else if (json instanceof JSONObject) {
            return toMap((JSONObject) json);
        } else if (json instanceof JSONArray) {
            return toList((JSONArray) json);
        } else {
            return json;
        }
    }	
}
