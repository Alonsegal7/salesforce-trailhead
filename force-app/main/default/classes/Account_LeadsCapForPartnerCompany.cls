public with sharing class Account_LeadsCapForPartnerCompany {
    public static void Account_LeadsCapForPartnerCompany(List<Account> newAccs, Map<Id,Account> oldAccMap){
        try{
            Id partnerCompanyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner_Company').getRecordTypeId();
            list<Account> relevantAccs= new list<Account>();
            set<Id> relevantAccsIds= new set<Id>();
            system.debug('Raz Ben Ron in trigger relevantAccsIds ');
            Lead_Cap_Settings__mdt leadsCapSettings = [select id,Max_Open_Leads__c from Lead_Cap_Settings__mdt where DeveloperName='Partners'][0];
            for(Account acc: newAccs){
                if(acc.RecordTypeid==partnerCompanyRecordTypeId&&
                (newAccs==null&&acc.Partner_Company_Status__c=='Signed')||
                (acc.Partner_Company_Status__c=='Signed'&&
                acc.Partner_Company_Status__c!=oldAccMap.get(acc.id).Partner_Company_Status__c)||
                (acc.Manual_Trigger__c=='Create Leads Cap'&&acc.Manual_Trigger__c!=oldAccMap.get(acc.id).Manual_Trigger__c)){
                    relevantAccs.add(acc);
                    if(acc.Id!=null)
                        relevantAccsIds.add(acc.Id);
                }
            }
            system.debug('Raz Ben Ron relevantAccsIds: '+relevantAccsIds);
            if(relevantAccs.isEmpty())
                return;
            //look for existing LCs in order to prevent duplications
            map<id,Leads_Cap__c> existingLCs= new map<id,Leads_Cap__c>();
            for(Leads_Cap__c lc: [select id,Channel_Partner__c from Leads_Cap__c where Channel_Partner__c in: relevantAccsIds]){
                existingLCs.put(lc.Channel_Partner__c,lc);
            }
            system.debug('Raz Ben Ron existingLCs: '+existingLCs);
            list<Leads_Cap__c> lcsToCreate= new list<Leads_Cap__c>();
            list<Account> accsToUpdate= new list<Account>();
            for(Account acc:relevantAccs){
                if(acc.Id==null||!existingLCs.containskey(acc.Id))
                    lcsToCreate.add(new Leads_Cap__c(OwnerId=acc.OwnerId,
                                                    Name=acc.Name,
                                                    Channel_Partner__c=acc.id,
                                                    Open_Leads_Limit__c=leadsCapSettings.Max_Open_Leads__c,
                                                    Department__c='Partners'));
                if(acc.Manual_Trigger__c=='Create Leads Cap')  {
                    accsToUpdate.add(new Account(id=acc.id,Manual_Trigger__c=''));
                }
            }
            if(!lcsToCreate.isEmpty())
                insert lcsToCreate;
            if(!accsToUpdate.isEmpty())
                update accsToUpdate;
        }catch(exception e){
            Utilities.sendDebugEmail('Error in Account_LeadsCapForPartnerCompany',e,e.getMessage());   
        }
    }

}