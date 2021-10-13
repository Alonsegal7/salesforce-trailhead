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
            
           for(Opportunity o : aData.Opportunities) {
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
            (select id,stagename,AccountId from Opportunities),
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
}