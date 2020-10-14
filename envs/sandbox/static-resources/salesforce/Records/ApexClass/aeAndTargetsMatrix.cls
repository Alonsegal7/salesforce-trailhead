public with sharing class aeAndTargetsMatrix {
    //public map<String,map<String,Integer>> aesPeriodandTargets {get;set;}
    //public list<String> periods {get;set;}
    
    @AuraEnabled(cacheable=true)
    public static list<String> getPeriods() {
        list<String> periods=new list<String>();
        for (Integer year = 2019; year < 2021; year++) {
            for(Integer month = 1; month <=12&&(month<=DATE.today().month()||YEAR!=DATE.TODAY().YEAR()); month++){
                periods.add(year+'-'+month);
                system.debug('Raz Ben Ron period: '+year+'-'+month);
            }
        }
        return periods;
    }
    @AuraEnabled(cacheable=true)
    public static map<String,map<String,Integer>> getTargetsMatrix() {
        //map<String,map<String,Integer>> aesPeriodandTargets = new  map<String,map<String,Integer>>();
        map<String,map<String,Integer>> aesPeriodandTargets = new  map<String,map<String,Integer>>();
        list<String> periods= getPeriods();
        string period='';
        string aeName='';
        for(Target__c target: [select id,User__c,Target_Date__c ,Total_Actual__c,User__r.Name,Amount__c 
                               from Target__c 
                               order by createddate DESC limit 200]){
            period=target.Target_Date__c.year()+'-'+target.Target_Date__c.month();
            aeName=target.User__r.Name;
            if(!aesPeriodandTargets.containsKey(aeName))
                aesPeriodandTargets.put(aeName,new map<String,Integer>());
            system.debug('Raz Ben Ron period: '+period); 
            if(!aesPeriodandTargets.get(aeName).containsKey(period)){
               aesPeriodandTargets.get(aeName).put(period,integer.valueof(target.Amount__c));
               system.debug('Raz Ben Ron aesPeriodandTargets: '+aesPeriodandTargets.get(aeName).get(period)); 
            }
        }
        system.debug('Raz Ben Ron targets map: '+aesPeriodandTargets); 
        
        for(String ae: aesPeriodandTargets.keySet()){
            for(String per :periods){
                if(!aesPeriodandTargets.get(ae).containsKey(per))
                    aesPeriodandTargets.get(ae).put(per,0);
            }
        }
        system.debug('Raz Ben Ron targets map full: '+aesPeriodandTargets); 
        return aesPeriodandTargets;
    }
    
}