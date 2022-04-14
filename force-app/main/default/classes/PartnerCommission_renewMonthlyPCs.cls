public without sharing class PartnerCommission_renewMonthlyPCs implements Database.Batchable<sObject>,Schedulable{
    public void execute(SchedulableContext SC) {
        try{
            Utilities.cleanFlexQueue();
            Database.executeBatch(this, 30);
        }catch (Exception ex){
            Utilities.sendEmail('Error in PartnerCommission_renewMonthlyPCs SchedulableContext', ex.getMessage(), new List<String>{'kseniasm@monday.com'});
        }
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id FROM Partner_Commission__c WHERE Is_Future_Payment__c = true and End_Date__c = TODAY';
        try {
            return Database.getQueryLocator(query);
        }catch(Exception ex){
            Utilities.sendEmail('Error in PartnerCommission_renewMonthlyPCs start', ex.getMessage(), new List<String>{'kseniasm@monday.com'});
            return null;
        }
     }

    public void execute(Database.BatchableContext BC, list<Partner_Commission__c> scope){
        try {
            PartnerCommissionService service = new PartnerCommissionService();
            for(Partner_Commission__c pc: scope){
                pc.Close_Reason__c = 'Monthly Plan PC Auto Expired';
            }
            service.upsertPartnerCommissionInQueue(scope, 'PartnerCommission_renewMonthlyPCs close reason for old pcs');
            List<Partner_Commission__c> pcsToInsert = new List<Partner_Commission__c>();
            for(Partner_Commission__c pc: scope){
                Partner_Commission__c newPc = pc.clone(false, true, false, false);
                newPc.Trigger_Valid_From__c = null;
                newPc.Start_Date__c = Date.today().addDays(1);
                newPc.End_Date__c = Date.today().addDays(1).addYears(1);
                newPc.Previous_Partner_Commission__c = pc.Id;
                newPc.Created_From__c = 'Code';
                newPc.Creation_Reason__c = 'Monthly Plan PC Auto Renewal';
                pcsToInsert.add(newPc);
            }
            service.upsertPartnerCommissionInQueue(pcsToInsert, 'PartnerCommission_renewMonthlyPCs renewed pcs');
        } catch (Exception ex) {
            Utilities.sendEmail('Error in PartnerCommission_renewMonthlyPCs execute', ex.getMessage(), new List<String>{'kseniasm@monday.com'});
        }
    }

    public void finish(Database.BatchableContext BC){}
}
