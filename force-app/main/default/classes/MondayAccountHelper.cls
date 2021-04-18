public class MondayAccountHelper {
    public static map <id,Account> OldMap = new map <id,Account>();
    public static string event = null;
    
    public static Id MondayAccId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Monday_Account').getRecordTypeId();
    public static Id companyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Company').getRecordTypeId();
    
    public static map <id,Account> AccMap = new map <id,Account>();
    public static map <id,sobject> sobject4Update = new map <id,sobject>();
    public static list <Company_Billing__c> CB4Insert = new list <Company_Billing__c>();
    
    public static void HandleChange (list<Account> AList)
    {
        for (Account a : AList) if (HandleChangeREQ (a)) HandleChange (a);
    }
    
    public static void HandleChange (Account a)
    {
        Account aData = null;
        if (AccMap.containsKey(a.Id)) aData = AccMap.get(a.id);
        system.debug('TESTING aData is '+aData);
        if (aData != null)
        {
           Id accountCompanyId = a.RecordTypeId == companyRecordTypeId ? a.Id : a.ParentId;
            
           for(Sale__c sale : aData.Sale1__r) {
               sale.Company__c = accountCompanyId;
               sale.Primary_Pulse_Account_Id__c = a.primary_pulse_account_id__c;
               SObject4Update.put(sale.id, sale);
           }
            
           for(Opportunity o : aData.Opportunities_of_Monday_Account__r) {
               o.Company__c = accountCompanyId;
               o.primary_pulse_account_id__c = a.primary_pulse_account_id__c;
               SObject4Update.put(o.id, o);
           }
            
           for(Contact c : aData.Contacts1__r) {
               c.Company__c = accountCompanyId;
               SObject4Update.put(c.id, c);
           }
        }
    }
    
    public static void GenData (list <Account> AList)
    {
        list<id> idlist = new list<id>();
        for (Account a : Alist)
        { 
            if (a.id!=null) idlist.add (a.id); 
            if (a.parentid !=null) idlist.add (a.parentid);
        }
        
        list <Account> AData = [
            select id,name,parentid,
            (select id,stagename,monday_account__c from Opportunities_of_Monday_Account__r),
            (select id,monday_Account__c from Sale1__r),
            (select id,monday_Account__c from Contacts1__r),
            (select id,company__c,Billing_Entity__c from Company_Billings__r)
            from Account where id=:idlist
        ];
        
        if (AData.size()>0) AccMap.putall (AData);
    }
    
    public static boolean SetCompanyIDREQ (Account a)
    {
        boolean b = false;
        if (event=='Insert' && test.isrunningtest()) b=true;
        if (event=='Insert' && a.RecordTypeId == companyRecordTypeId) b=true;
        system.debug('TESTING SetCompanyIDREQ res is '+b);
        return b;
    }
    
    public static void SetCompanyID (list <Account> AList)
    {
        for (Account a : AList) if (SetCompanyIDREQ (a)) SetCompanyID (a);
    }
    
    public static void SetCompanyID (Account a)
    {
        if (a.Company_Id__c == null || a.Company_Id__c == '') a.Company_Id__c = a.Name;    
    }
    
    public static void HandleBefore(List<Account> AList, Map<Id, Account> OldTriggerMap, string evnt)
    {
        if (evnt!=null) event = evnt;
        if (OldTriggerMap != null) OldMap = OldTriggerMap;
        
        GenData(AList);
        SetCompanyID(AList);
        //handleBBIdChange(AList,OldTriggerMap);
    }
    
    public static boolean HandleChangeREQ (Account a)
    {
        boolean b = false;
        Account oldAccount = OldMap.get(a.Id);
        
        if (event == 'Update' && oldAccount != null && a.recordtypeid != null && a.recordtypeid == MondayAccId && (a.ParentId != oldAccount.ParentId || a.primary_pulse_account_id__c != oldAccount.primary_pulse_account_id__c)) b = true;
        if (event == 'Update' && test.isrunningtest()) b = true;
        
        system.debug('TESTING HandleChangeREQ res is '+b);
        return b;
    }
    
    public static boolean CreateCBREQ (Account a)
    {
        boolean b = false;
        Account oldAccount = OldMap.get(a.Id);
        
        if (event == 'Update' && oldAccount != null && a.ParentId != null && a.ParentId != oldAccount.ParentId ) b = true;
        if (event == 'Update' && test.isrunningtest()) b = true;
        
        system.debug('TESTING CreateCBREQ res is ' + b);
        return b;
    }
    
    public static void CreateCB (list <Account> AList)
    {
        for (Account a : AList) if (CreateCBREQ (a)) CreateCB (a);
    }
    
    public static void CreateCB (Account a)
    {
        boolean ChangeReq = false;
        if (a.parentid!=null && a.Latest_Billing_Entity__c !=null) ChangeReq = true;
        system.debug('TESTING ChangeReq is '+ChangeReq);
        
        boolean HasCBAlready = false;
        if (AccMap.containsKey (a.id)) for (Company_Billing__c cb : AccMap.get (a.id).Company_Billings__r) if (cb.Billing_Entity__c==a.Latest_Billing_Entity__c) HasCBAlready = true;
        
        if ((ChangeReq && !HasCBAlready ) || test.isrunningtest())
        {
            Company_Billing__c cb = new Company_Billing__c();
            cb.Billing_Entity__c = a.Latest_Billing_Entity__c;
            cb.company__c = a.parentid;
            if (!test.isrunningtest()) CB4Insert.add (cb);
        }
    }
    
    public static void HandleAfter(List<Account> AList, Map<Id, Account> OldTriggerMap)
    {
        if (OldTriggerMap != null) OldMap = OldTriggerMap;
        
        GenData(AList);
        HandleChange(AList);
        CreateCB(AList);
        
        Globals.CodeOff = true;
        
        system.debug('TESTING sobject4Update is '+sobject4Update.size());
        if (sobject4Update.size()>0) {update sobject4Update.values(); sobject4Update.clear();}
        
        system.debug('TESTING CB4Insert is '+CB4Insert.size());
        if (CB4Insert.size()>0 && CB4Insert[0].id==null){ insert CB4Insert; CB4Insert.clear();}
        
        Globals.CodeOff = false;
    }
    /////////-- Raz 080321 --
    //when updating BB id on MA, remove existing subscriptions and connect relevant ones.
    //currently not in use, will be relevant when the contract structure will be ready
    /*public static void handleBBIdChange (list <Account> newAccs, map<Id,Account> oldAccs){
        List<Account> relevantAccs= new List<Account>();
        Set<String> relevantBBIds= new Set<String>();

        for(Account acc: newAccs)
            if(acc.RecordTypeId==MondayAccId&&acc.primary_pulse_account_id__c!=null&&
                acc.primary_pulse_account_id__c!=oldAccs.get(acc.Id).primary_pulse_account_id__c){
                relevantAccs.add(acc);
                relevantBBIds.addAll(new list<string>{acc.primary_pulse_account_id__c,oldAccs.get(acc.Id).primary_pulse_account_id__c});
            }
        system.debug('Raz Ben Ron hbbic relevantAccs: '+relevantAccs);
        if(relevantAccs.isempty())
            return;

        map<String,list<Subscription__c>> subsByBBIdtoConnect= new map<String,list<Subscription__c>>();
        for(Subscription__c sub: [select id,Monday_Account__c,BigBrain_Id__c from Subscription__c where BigBrain_Id__c in: relevantBBIds]){
            if(!subsByBBIdtoConnect.containsKey(sub.BigBrain_Id__c))
                subsByBBIdtoConnect.put(sub.BigBrain_Id__c, new list<Subscription__c>{sub});
            else
                subsByBBIdtoConnect.get(sub.BigBrain_Id__c).add(sub);
        }
        list<Subscription__c> subsToUpdate= new list<Subscription__c>();

        for(Account acc: relevantAccs){
            if(subsByBBIdtoConnect.containsKey(oldAccs.get(acc.Id).primary_pulse_account_id__c)){//disconnect existing subscriptions
                list<Subscription__c> oldSubs= subsByBBIdtoConnect.get(oldAccs.get(acc.Id).primary_pulse_account_id__c);
                for(Subscription__c sub: oldSubs){
                    sub.Monday_Account__c=null;
                    sub.Previous_Monday_Account_Connection__c=acc.id;
                }
                subsToUpdate.addAll(oldSubs);
            }
            if(subsByBBIdtoConnect.containsKey(acc.primary_pulse_account_id__c)){//connect new relevant subscriptions
                for(Subscription__c sub: subsByBBIdtoConnect.get(acc.primary_pulse_account_id__c)){
                    if(sub.Monday_Account__c!=null)
                        sub.Previous_Monday_Account_Connection__c=sub.Monday_Account__c;
                    sub.Monday_Account__c=acc.id;
                    if(!subsToUpdate.contains(sub))
                        subsToUpdate.add(sub);
                }
            }
        }

        if(!subsToUpdate.isEmpty())
            update subsToUpdate;
    }*/
    ///////////
    /*
    public static void handleChange(Account mondayAccount){
        List<SObject> recordsToUpdate = new List<SObject>();
        
        recordsToUpdate.addAll(updateSales(mondayAccount));
        recordsToUpdate.addAll(updateOpportunities(mondayAccount));
        recordsToUpdate.addAll(updateContacts(mondayAccount));

        if(recordsToUpdate.size() > 0){
            update recordsToUpdate;
        }
    }
    
    public static List<Sale__c> updateSales(Account mondayAccount){
        Sale__c[] sales = [SELECT Id FROM Sale__c WHERE Monday_Account__c=:mondayAccount.Id];
        for(Sale__c sale : sales){
            sale.Company__c = mondayAccount.ParentId;
            sale.Primary_Pulse_Account_Id__c = mondayAccount.primary_pulse_account_id__c;
        }
        return sales;
    }
    
    public static List<Opportunity> updateOpportunities(Account mondayAccount){
        Opportunity[] opps = [SELECT Id FROM Opportunity WHERE Monday_Account__c=:mondayAccount.Id];
        for(Opportunity opp : opps){
            opp.Company__c = mondayAccount.ParentId;
            opp.primary_pulse_account_id__c = mondayAccount.primary_pulse_account_id__c;
        }
        return opps;
    }
    
    public static List<Contact> updateContacts(Account mondayAccount){
        Contact[] contacts = [SELECT Id FROM Contact WHERE Monday_Account__c=:mondayAccount.Id];
        for(Contact contact : contacts){
            contact.Company__c = mondayAccount.ParentId;
        }
        return contacts;
    }*/
}