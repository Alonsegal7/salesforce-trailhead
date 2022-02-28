public class BillingEntityHandler 
{
    public static map <id, Billing_Entity__c> oldMap = new map <id,Billing_Entity__c>();
    public static string event = null;
    
    public static boolean SetUniquenessREQ (Billing_Entity__c a)
    {
        return (event == 'Insert' || event == 'Update');
    }
    
    public static boolean SyncIConductREQ(Billing_Entity__c newBE, Billing_Entity__c oldBE)
    {
    	return newBE.Sync_Request_Timestamp_iConduct__c != oldBE.Sync_Request_Timestamp_iConduct__c;
    }
    
    public static void SyncIConduct(list <Billing_Entity__c> BEList)
    {
        for(Billing_Entity__c newBillingEntity : BEList)
        {
            boolean syncRequestChanged = SyncIConductREQ(newBillingEntity, oldMap.get(newBillingEntity.Id));
            if (syncRequestChanged) { System.enqueueJob(new IConductService('BillingEntityERPInsertUpdateSync',newBillingEntity.Id));}
        }
    }
    
    public static void CopyPriorityId(list <Billing_Entity__c> BEList)
    {
        List<Quote> quotesList = new List<Quote>();
            
        for(Billing_Entity__c newBE : BEList)
        {
            Billing_Entity__c oldBE = oldMap.get(newBE.Id);
            boolean priorityIdChanged = newBE.Priority_Id__c != oldBE.Priority_Id__c;
            if (priorityIdChanged && newBE.Priority_Id__c != null) {
                List<Quote> quotes = [SELECT Id, Priority_Customer_ID_Text__c FROM Quote where (Sync_Status__c = 'Need to Transfer' or Sync_Status__c = '') AND Billing_Entity__c = :newBE.Id];
                
                if (!quotes.isEmpty()) {
                    for (Quote quote: quotes){
                        quote.Priority_Customer_ID_Text__c = newBE.Priority_Id__c;
                		quotesList.add(quote);
                    }
        		}
            }
        }
        
        update quotesList;
    }
    
    public static void SetUniqueness (list <Billing_Entity__c> BEList)
    {
        for (Billing_Entity__c be : BEList) if (SetUniquenessREQ (be)) SetUniqueness (be);
    }
    
    public static void SetUniqueness (Billing_Entity__c be)
    {
        be.Unique_Key__c = UniquenessKey(be.vat_Number__c, be.CurrencyIsoCode, be.Country__c, be.City__c, be.Name);
    }
   
    public static string UniquenessKey(string VatNumber, string CurrencyIsoCode, string Country, string City, string Name)
    {
        //if (VatNumber == null || CurrencyIsoCode == null || Country == null || City == null || Name == null ) { return null; }
        //return VatNumber + CurrencyIsoCode + Country + City + Name;
        if (Name == null ) { return null; }
        return Name;
    }
    
    public static void HandleBefore(list<Billing_Entity__c> BEList, map<id,Billing_Entity__c> OldTriggerMap, string evnt)
    {
        if (evnt != null) event = evnt;
        if (OldTriggerMap != null) oldMap = OldTriggerMap;
        
        SetUniqueness(BEList);
        if (event == 'Update') { SyncIConduct(BEList); }
        if (event == 'Update') { CopyPriorityId(BEList); }
    }    
}