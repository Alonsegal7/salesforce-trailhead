public without sharing class SuccessKPI_MappHealthScoreStamp {
    public static List<Success_KPI__c> SuccessKPI_MappHealthScoreStamp(List<Success_KPI__c> TargetsList) {
        Set<Id> accountIdsList = new Set<Id>();
        for (Success_KPI__c target : TargetsList) {
            accountIdsList.add(target.Monday_Account__c);

    }
    Map<Id,Account> relatedAccountMap = new Map<Id,Account>([SELECT Id,Health_Score__c,MAPP__c FROM Account WHERE Id IN: accountIdsList]);
    for (Success_KPI__c target : TargetsList) {
        if (target.monday_Account__c != null && relatedAccountMap.get(target.monday_Account__c).Health_Score__c != null){
            target.Health_Score_End__c =relatedAccountMap.get(target.monday_Account__c).Health_Score__c;    
        }
        if (target.monday_Account__c != null  && relatedAccountMap.get(target.monday_Account__c).MAPP__c != null){
            target.MAPP_End__c =relatedAccountMap.get(target.monday_Account__c).MAPP__c;        
        }
    }
    try {
        update TargetsList;
            
    } catch (Exception e) {
        System.debug('Project_ProjectStamps failed to update SucsessKPI_MappHealthScoreStamp '+e.getMessage());
        
    }  
    return TargetsList ;
}
}

