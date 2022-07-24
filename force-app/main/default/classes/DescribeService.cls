public without sharing class DescribeService {
    public static Map<String, Schema.SObjectType> globalDescribe {
        get { 
            if(globalDescribe == null) globalDescribe = Schema.getGlobalDescribe();
            return globalDescribe;
        }
        set;
    }

    public static map<string,Schema.DescribeSObjectResult> partialDescribe_map{
        get { 
            if(partialDescribe_map == null) partialDescribe_map = new map<string,Schema.DescribeSObjectResult>();
            return partialDescribe_map;
        }
        set;
    }

    public static Schema.DescribeSObjectResult getSObjDescribe(String objName){
        if(partialDescribe_map.containsKey(objName)) return partialDescribe_map.get(objName);
        else {
            Schema.DescribeSObjectResult sObjDescribe = Schema.describeSObjects(new List<string>{objName})[0];
            partialDescribe_map.put(objName, sObjDescribe);
            return sObjDescribe;
        }
    }
}
