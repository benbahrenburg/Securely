// Modified from the great work from Eric Butler 
//https://gist.github.com/2339666

package bencoding.securely;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.*;

public class JsonHelper {
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