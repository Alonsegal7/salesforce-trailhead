public without sharing class MdfPortions_ScheduledAvailableByDate implements Schedulable{
    // this class runs as scheduled job on the first of each month 
    // to set the field Is_Available_by_Date_not_formula__c on MDF_Payment_Portion__c to true
    public void execute(SchedulableContext SC) {
        list<MDF_Payment_Portion__c> p_list = [select Id from MDF_Payment_Portion__c where Is_Available_by_Date_not_formula__c = false and Is_Available_by_Date__c = true];
        for(MDF_Payment_Portion__c p: p_list){
            p.Is_Available_by_Date_not_formula__c = true;
        }
        update p_list;
    }
}
