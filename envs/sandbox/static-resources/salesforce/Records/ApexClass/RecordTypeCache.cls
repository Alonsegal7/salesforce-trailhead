public class RecordTypeCache implements Cache.CacheBuilder {
    public Object doLoad(String identifier) {
        RecordType rt = [SELECT Id, Name, DeveloperName FROM RecordType WHERE Id =: identifier LIMIT 1];
        if (rt.DeveloperName == null) { return ''; }
        return rt.DeveloperName;
    }
}