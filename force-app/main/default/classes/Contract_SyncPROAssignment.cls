public without sharing class Contract_SyncPROAssignment {
    public static void Contract_SyncPROAssignment(List <Contract> newContracts, Map<Id,Contract> oldContracts) {
        date conEndDateQ1 = date.newInstance(2023, 03, 31); 
        for (Contract conToChangeToSync: newContracts) {
            if(oldContracts != null  && conToChangeToSync.Last_Event_Payment_Method__c == 'WIRE' && conToChangeToSync.Primary_Renewal_Owner__c != null && conToChangeToSync.Renewal_Opp_Created_from_Contract__c == false && conToChangeToSync.EndDate <= conEndDateQ1 && conToChangeToSync.Last_Event_Payment_Method__c != oldContracts.get(conToChangeToSync.Id).Last_Event_Payment_Method__c){
                conToChangeToSync.Define_Default_PRO_Assignment__c = true;
            }
        }

    }
}
