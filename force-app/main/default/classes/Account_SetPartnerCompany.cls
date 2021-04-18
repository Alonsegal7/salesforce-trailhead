public with sharing class Account_SetPartnerCompany {
    public static Id MondayAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Monday_Account').getRecordTypeId();
    public static void Account_SetPartnerCompany (list <Account> newAccs, map<Id,Account> oldAccs){
        try{
            Set<Id> relevantUsers= new Set<Id>();
            List<Account> relevantAccs= new List<Account>();
            for(Account acc: newAccs){
                if(acc.RecordTypeId==MondayAccRecordTypeId&&
                    (oldAccs==null||acc.OwnerId!=oldAccs.get(acc.Id).OwnerId||
                                    acc.Partner__c!=oldAccs.get(acc.Id).Partner__c)){
                        relevantUsers.add(acc.OwnerId);
                        relevantUsers.add(acc.Partner__c);
                        relevantAccs.add(acc);
                    }
            }
            if(relevantAccs.isempty())
                return;
            map<Id,User> usersWithDetails= new map<Id,User>([select id,Contact.AccountId from User where id in:relevantUsers]);
            for(Account acc: relevantAccs){
                if(usersWithDetails.containskey(acc.Partner__c)&&usersWithDetails.get(acc.Partner__c).Contact.AccountId!=null)
                    acc.Channel_Partner__c=usersWithDetails.get(acc.Partner__c).Contact.AccountId;
                else if(usersWithDetails.containskey(acc.OwnerId)&&usersWithDetails.get(acc.OwnerId).Contact.AccountId!=null)
                    acc.Channel_Partner__c=usersWithDetails.get(acc.OwnerId).Contact.AccountId;
                else{
                    acc.Channel_Partner__c=null;
                }
            }
        }catch(Exception e){
            Utilities.sendDebugEmail('Error in Account_SetPartnerCompany ',e,e.getMessage());   
        }
    }
}