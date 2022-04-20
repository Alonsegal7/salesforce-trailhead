public without sharing class ApexLimits {
    @AuraEnabled(cacheable=true)
    public static Map<String,Integer> getLimits(string requestedLimit){
        Map<String, Integer> returnedLimit = new Map<String, Integer>();
        Map < String,System.OrgLimit > limitsMap = OrgLimits.getMap();  
        System.OrgLimit orgLimit = limitsMap.get(requestedLimit);  
        returnedLimit.put('UsageValue',orgLimit.getValue());
        returnedLimit.put('MaximumLimit' ,orgLimit.getLimit() );
        return returnedLimit;
    }

    public static Boolean queueableLimitReached(){
        return Limits.getQueueableJobs() == Limits.getLimitQueueableJobs();
    }
}