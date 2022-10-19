public with sharing class Contract_DefineDefaultPROAssignment {
    public static List<Contract> Contract_DefineDefaultPROAssignment(List<Contract> relevantContracts) {
        List<Contract> contractsToUpdate = new List<Contract>();
        set<Id> relevantUsersIds= new set<Id>();
        set<Id> relevantPartnerCompanyIds= new set<Id>();
        Map<Id,Pod_Assignment__c> salesPodMap = new Map<Id,Pod_Assignment__c>();
        Map<Id,Pod_Assignment__c> partnersPodMap = new Map<Id,Pod_Assignment__c>();
        //Modeling the data & prep for defining the PRO on contract - define list of users (for Sales Pod) and list of partner companies (for Partners Pod)
        for (Contract c : relevantContracts) {
            if(!c.Accounts__r.isEmpty()){
                Account primaryMA=c.Accounts__r[0];
                if (primaryMA.Owner_is_Partner__c && primaryMA.Channel_Partner__c != null) {
                    relevantPartnerCompanyIds.add(primaryMA.Channel_Partner__c);
                }
                if(!isOwnerPartner(primaryMA)){
                    relevantUsersIds.add(primaryMA.OwnerId);              
                }
            }  
        }
        //Map for Pod's for sales- In case we need to update the PRO to be the RM. 
        for(Pod_Assignment__c Pod: [select id,Sales_Pod_Lead__c,Renewal_Manager__c from Pod_Assignment__c where Sales_Pod_Lead__c in: relevantUsersIds AND Status__c='Active']){
            salesPodMap.put(Pod.Sales_Pod_Lead__c,Pod);}
        //Map for Pod's for Partners - In case we need to update the PRO to be the RM. 
        for(Pod_Assignment__c Pod: [select id,Partner_Pod_Lead_Partner_Company__c,Renewal_Manager__c from Pod_Assignment__c where Partner_Pod_Lead_Partner_Company__c in: relevantPartnerCompanyIds AND Status__c='Active']){
            partnersPodMap.put(Pod.Partner_Pod_Lead_Partner_Company__c,Pod);}
       //Define PRO on Contract based on conditions.
        for (Contract c : relevantContracts) {
            if (!c.Accounts__r.isEmpty()) {
                Account primaryMA1=c.Accounts__r[0];           
                if(isOwnerPartner(primaryMA1) && primaryMA1.Channel_Partner__c != null){  //---Account owner is partner (owner is partner user || CPM is account owner) 
                    c.Primary_Renewal_Owner__c = primaryMA1.OwnerId; // for partners - the owner is the account owenr 
                    if(partnersPodMap.containskey(primaryMA1.Channel_Partner__c)){ //assign RM in RM field 
                        c.Renewal_Manager__c=partnersPodMap.get(primaryMA1.Channel_Partner__c).Renewal_Manager__c;
                    }
                } 
                if(isOwnerEntAM(primaryMA1)){ //if AM & Mid-Market or ENT ->PRO is Account Owner
                    c.Primary_Renewal_Owner__c =primaryMA1.OwnerId;  
                    if(salesPodMap.containskey(primaryMA1.OwnerId)){ //assign RM in RM field 
                        c.Renewal_Manager__c=salesPodMap.get(primaryMA1.OwnerId).Renewal_Manager__c;
                    }
                }else{ //in other cases (co sell accoount / sales accounts with owner that is no AM Mid/Ent)
                    if(salesPodMap.containskey(primaryMA1.OwnerId)){
                        c.Primary_Renewal_Owner__c = salesPodMap.get(primaryMA1.OwnerId).Renewal_Manager__c; // RM is the PRO
                        c.Renewal_Manager__c = salesPodMap.get(primaryMA1.OwnerId).Renewal_Manager__c;
                    }else{
                        c.Primary_Renewal_Owner__c =primaryMA1.OwnerId; //Account should be assigned to RM, but we couldn't find the relvant Pod Assignment therfor PRO is Account Owner 
                    }
                }
                contractsToUpdate.add(c); 
                c.Define_Default_PRO_Assignment__c = false;
            }
        }  
        //Update the contract with the PRO
        try {
            Database.update(contractsToUpdate, false);
        } catch (Exception e) {
            Utilities.sendDebugEmail('Error in Define Default PRO Assignement daily Scheduled Job', e, e.getMessage());
        }
        return contractsToUpdate;           
    }
    public static Boolean isOwnerPartner(Account acc){
        return (acc.Owner.Profile.Name =='Partner Community Custom' || acc.Owner.Profile.Name =='Channel Managers');
    }
    public static Boolean isOwnerEntAM(Account acc){
        return (acc.owner.Business_Role__c == 'AM' && (acc.owner.Segment__c == 'Mid-Market'||acc.owner.Segment__c =='Enterprise'));
    }
} 