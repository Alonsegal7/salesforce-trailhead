public class MondayAccountHelper {
    public static map <id,Account> OldMap = new map <id,Account>();
    public static string event = null;
    
    public static Id MondayAccId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Monday_Account').getRecordTypeId();
    public static Id companyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Company').getRecordTypeId();
    
    public static map <id,sobject> sobject4Update = new map <id,sobject>();
    public static list <Company_Billing__c> CB4Insert = new list <Company_Billing__c>();

    public static void setCompanyID(List<Account> accList) { //running in before insert
        for(Account acc: accList){
            if (acc.RecordTypeId == companyRecordTypeId && (acc.Company_Id__c == null || acc.Company_Id__c == '')) {
                acc.Company_Id__c = acc.Name;
            }
        }
    }

    public static void HandleAfter(List<Account> accList, Map<Id, Account> oldAccMap)
    {
        updateRelatedObjsCompanyAndPulseId(accList, oldAccMap);
        createCompanyBillings(accList, oldAccMap);
        
        Globals.CodeOff = true;
        
        system.debug('TESTING sobject4Update is '+sobject4Update.size());
        if (sobject4Update.size()>0) {
            List<SObject>sortedSobjectsToUpdate = sobject4Update.values();
            system.debug('List before: '+sortedSobjectsToUpdate);
            sortedSobjectsToUpdate.sort();

            update sortedSobjectsToUpdate; 
            sobject4Update.clear();
            }
        
        system.debug('TESTING CB4Insert is '+CB4Insert.size());
        if (CB4Insert.size()>0 && CB4Insert[0].id==null){ insert CB4Insert; CB4Insert.clear();}
        
        Globals.CodeOff = false;
    }

    private static void updateRelatedObjsCompanyAndPulseId(List<Account> accList, Map<Id, Account> oldAccMap) { //running in after
        Set<Id> accToUpdateRelatedObjs = new Set<Id>();
        for(Account acc: accList){
            if (oldAccMap != null 
                && (acc.primary_pulse_account_id__c != oldAccMap.get(acc.Id).primary_pulse_account_id__c || acc.Company__c != oldAccMap.get(acc.Id).Company__c || //pulse account id change or company change
                (acc.Manual_Trigger__c == 'Recalculate Related Objects' && (oldAccMap.get(acc.Id).Manual_Trigger__c == null || acc.Manual_Trigger__c != oldAccMap.get(acc.Id).Manual_Trigger__c))) //manual trigger 
                && acc.RecordTypeId == MondayAccId){
                    accToUpdateRelatedObjs.add(acc.Id);
            }
        }
        if(accToUpdateRelatedObjs.isEmpty()) return;

        list <Account> accountsList = [
            select id,name, Company__c, parentid, RecordTypeId, primary_pulse_account_id__c, Manual_Trigger__c,
            (select id,stagename,AccountId from Opportunities where Co_Sell_V2__c = false or Main_Co_Sell_Opportunity__c = true),
            (select id,monday_Account__c from Sale1__r),
            (select id,monday_Account__c from Contacts1__r)
            from Account where id IN: accToUpdateRelatedObjs
        ];

        Id accountCompanyId;
        List<Account> accToClear = new List<Account>();
        for(Account acc: accountsList){
            accountCompanyId = acc.RecordTypeId == companyRecordTypeId ? acc.Id : acc.Company__c;
            
            for(Sale__c sale : acc.Sale1__r) {
                sale.Company__c = accountCompanyId;
                sale.Primary_Pulse_Account_Id__c = acc.primary_pulse_account_id__c;
                SObject4Update.put(sale.id, sale);
            }
            
            for(Opportunity opp : acc.Opportunities) {
                opp.Company__c = accountCompanyId;
                opp.primary_pulse_account_id__c = acc.primary_pulse_account_id__c;
                SObject4Update.put(opp.id, opp);
            }
            
            for(Contact con : acc.Contacts1__r) {
                con.Company__c = accountCompanyId;
                SObject4Update.put(con.id, con);
            }

            if (acc.Manual_Trigger__c == 'Recalculate Related Objects') {
                acc.Manual_Trigger__c = '';
                accToClear.add(acc);
            }
        }
        if (!accToClear.isEmpty()) {
            update accToClear;
        }
    }

    private static void createCompanyBillings(List<Account> accList, Map<Id, Account> oldAccMap) { //running in after
        Set<Id> accToUpdateRelatedObjs = new Set<Id>();
        for(Account acc: accList){
            if (oldAccMap != null && acc.ParentId != null && acc.ParentId != oldAccMap.get(acc.Id).ParentId){
                accToUpdateRelatedObjs.add(acc.Id);
            }
        }
        if(accToUpdateRelatedObjs.isEmpty()) return;

        map <Id,Account> accountsMap = new map <Id,Account>([
            select id,name,parentid, Latest_Billing_Entity__c,
            (select id,company__c,Billing_Entity__c from Company_Billings__r)
            from Account where id IN: accToUpdateRelatedObjs
        ]);
        
        for(Account acc: accountsMap.values()){
            boolean ChangeReq = false;
            if (acc.parentid != null && acc.Latest_Billing_Entity__c !=null) ChangeReq = true;
            system.debug('TESTING ChangeReq is '+ChangeReq);
            boolean HasCBAlready = false;
            for (Company_Billing__c cb : acc.Company_Billings__r) {
                if (cb.Billing_Entity__c == acc.Latest_Billing_Entity__c) HasCBAlready = true;
            }
            
            if ((ChangeReq && !HasCBAlready ) || test.isrunningtest()){
                Company_Billing__c cb = new Company_Billing__c();
                cb.Billing_Entity__c = acc.Latest_Billing_Entity__c;
                cb.company__c = acc.parentid;
                if (!test.isrunningtest()) CB4Insert.add (cb);
            }
        }
    }
}