public with sharing class Account_SetPartnerCompany {
    public static Id MondayAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Monday_Account').getRecordTypeId();
    public static void Account_SetPartnerCompany (list <Account> newAccs, map<Id,Account> oldAccs){
        try{
            Set<Id> relevantUsers= new Set<Id>();
            List<Account> relevantAccs= new List<Account>();
            for(Account acc: newAccs){
                if(acc.RecordTypeId == MondayAccRecordTypeId &&
                    (oldAccs ==null ||//new
                    (acc.Manual_Trigger__c != oldAccs.get(acc.Id).Manual_Trigger__c && acc.Manual_Trigger__c=='Update CPM') ||//manual
                    acc.OwnerId!=oldAccs.get(acc.Id).OwnerId ||
                    acc.Partner__c!=oldAccs.get(acc.Id).Partner__c)){
                        relevantUsers.add(acc.OwnerId);
                        relevantUsers.add(acc.Partner__c);
                        relevantAccs.add(acc);
                    }
            }
            if(relevantAccs.isempty()) return;

            map<Id,User> usersWithDetails= new map<Id,User>([select id,Contact.AccountId, ManagerId, Profile.Name from User where id in:relevantUsers]);

            String partnerUserProfileName = 'Partner Community Custom';
            String cpmProfileName = 'Channel Managers';

            for(Account acc: relevantAccs){
                //Channel partner logic, should populate the field Channel Partner with the partner if "Partner" exists or the account owner if there's no partner
                if(usersWithDetails.containskey(acc.Partner__c)&&usersWithDetails.get(acc.Partner__c).Contact.AccountId!=null)
                    acc.Channel_Partner__c=usersWithDetails.get(acc.Partner__c).Contact.AccountId;
                else if(usersWithDetails.containskey(acc.OwnerId)&&usersWithDetails.get(acc.OwnerId).Contact.AccountId!=null)
                    acc.Channel_Partner__c=usersWithDetails.get(acc.OwnerId).Contact.AccountId;
                else{
                    acc.Channel_Partner__c=null;
                }
                
                //CPM logic, should populate the field CPM with the Partner's Manager if "Partner" exists or the account owner's manager ithe owner is a partner
                acc.CPM__c = null; //default       
                if(acc.Partner__c != null && usersWithDetails.containskey(acc.Partner__c)){ //first check if partner__c user is not null
                    if(usersWithDetails.get(acc.Partner__c).Profile.Name == cpmProfileName) acc.CPM__c = usersWithDetails.get(acc.Partner__c).Id;
                    else if(usersWithDetails.get(acc.Partner__c).Profile.Name == partnerUserProfileName) acc.CPM__c = usersWithDetails.get(acc.Partner__c).ManagerId;
                }
                else if(usersWithDetails.containskey(acc.OwnerId)){ //if partner__c was null than check if owner is partner
                    if(usersWithDetails.get(acc.OwnerId).Profile.Name == cpmProfileName) acc.CPM__c = usersWithDetails.get(acc.OwnerId).Id;
                    else if(usersWithDetails.get(acc.OwnerId).Profile.Name == partnerUserProfileName) acc.CPM__c = usersWithDetails.get(acc.OwnerId).ManagerId;
                }

                if(acc.Manual_Trigger__c == 'Update CPM') acc.Manual_Trigger__c = '';
            }
        }catch(Exception e){
            Utilities.sendDebugEmail('Error in Account_SetPartnerCompany ',e,e.getMessage());   
        }
    }
}