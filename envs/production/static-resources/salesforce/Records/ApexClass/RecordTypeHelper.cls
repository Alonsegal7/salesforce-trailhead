public class RecordTypeHelper {
    public static string devName(Id recordTypeID){
        if (recordTypeID == null){ return null; }
        return (String)Cache.Org.get(RecordTypeCache.class, String.valueOf(recordTypeID));
    }
}