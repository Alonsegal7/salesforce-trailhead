public with sharing class Contract_DefineDefaultPROAssignment {
    public static List<Contract> Contract_DefineDefaultPROAssignment(List<Contract> relevantContracts) {
        List<Contract> contractsToUpdate = new List<Contract>();
        set<Id> relevantUsersIds= new set<Id>();
        set<Id> relevantPartnerCompanyIds= new set<Id>();
        if(relevantContracts.isEmpty()) return contractsToUpdate;
        Map<Id,Pod_Assignment__c> salesPodMap = new Map<Id,Pod_Assignment__c>();
        Map<Id,Pod_Assignment__c> partnersPodMap = new Map<Id,Pod_Assignment__c>();
        //Modeling the data & prep for defining the PRO on contract - define list of users (for Sales Pod) and list of partner companies (for Partners Pod)
        for (Contract c : relevantContracts) {
            if(!c.Accounts__r.isEmpty()){
                Account primaryMA=c.Accounts__r[0];
                if (primaryMA.Owner_is_Partner__c && primaryMA.Channel_Partner__c != null) {
                    relevantPartnerCompanyIds.add(primaryMA.Channel_Partner__c);
                }
                if((primaryMA.Owner.Profile.Name !='Partner Community Custom' || primaryMA.Owner.Profile.Name !='Channel Managers') &&primaryMA.OwnerId != null){
                    relevantUsersIds.add(primaryMA.OwnerId);              
                }
        }  
        }
        //Map for Pod's for sales- In case we need to update the PRO to be the RM. 
        for(Pod_Assignment__c Pod: [select id,Sales_Pod_Lead__c,Renewal_Manager__c from Pod_Assignment__c where Sales_Pod_Lead__c in: relevantUsersIds AND Status__c='Active']){
            salesPodMap.put(Pod.Sales_Pod_Lead__c,Pod);
        }
        //Map for Pod's for Partners - In case we need to update the PRO to be the RM. 
        for(Pod_Assignment__c Pod: [select id,Partner_Pod_Lead_Partner_Company__c,Renewal_Manager__c from Pod_Assignment__c where Sales_Pod_Lead__c in: relevantPartnerCompanyIds AND Status__c='Active']){
            partnersPodMap.put(Pod.Partner_Pod_Lead_Partner_Company__c,Pod);
        }
    
        //Define PRO on Contract based on conditions. 
        for (Contract c : relevantContracts) {
            if (!c.Accounts__r.isEmpty()) {
                Account primaryMA1=c.Accounts__r[0];   
                //---partner Logic & Logic to CO-sell Accounts---            
                if (primaryMA1.Owner_is_Partner__c && primaryMA1.Channel_Partner__c != null) //Account is a partner account or a co-sell account (partner+sales)
                {
                    if(primaryMA1.Owner.Profile.Name =='Partner Community Custom' || primaryMA1.Owner.Profile.Name =='Channel Managers'){ //Account Owner managed by partner user or a CPM   
                        c.Primary_Renewal_Owner__c = primaryMA1.OwnerId; // for partners - the owner is the account owenr 
                        c.Define_Default_PRO_Assignment__c = false;
                        if(partnersPodMap.containskey(primaryMA1.Channel_Partner__c)){ //assign RM in RM field 
                            c.Renewal_Manager__c=partnersPodMap.get(primaryMA1.Channel_Partner__c).Renewal_Manager__c;
                        }
                        contractsToUpdate.add(c);
                    } //Account Co-Sell - Account owner (from Sales) + define the PRO to be the sales RM 
                    else{
                        //owner is from Sales team, therfore will find the RM from the sales Pod
                        if(salesPodMap.containskey(primaryMA1.OwnerId)){
                            c.Primary_Renewal_Owner__c = salesPodMap.get(primaryMA1.OwnerId).Renewal_Manager__c;
                            c.Define_Default_PRO_Assignment__c = false; 
                            c.Renewal_Manager__c = salesPodMap.get(primaryMA1.OwnerId).Renewal_Manager__c;
                            contractsToUpdate.add(c);
                        }else{
                            c.Primary_Renewal_Owner__c =primaryMA1.OwnerId; //Account should be assigned to RM, but we couldn't find the relvant Pod Assignment therfor PRO is Account Owner 
                            c.Define_Default_PRO_Assignment__c = false;
                            contractsToUpdate.add(c);
                        }
                    } 
                } 
                //---Sales Logic for define PRO--- 
                if(!primaryMA1.Owner_is_Partner__c && primaryMA1.OwnerId != null){ //Account is a sales account 
                    if(primaryMA1.owner.Business_Role__c == 'AM' && (primaryMA1.owner.Segment__c == 'Mid-Market'||primaryMA1.owner.Segment__c =='Enterprise')){ 
                        c.Primary_Renewal_Owner__c =primaryMA1.OwnerId; //if AM & Mid-Market or ENT ->PRO is Account Owner. 
                        c.Define_Default_PRO_Assignment__c = false;
                        if(salesPodMap.containskey(primaryMA1.OwnerId)){ //assign RM in RM field 
                            c.Renewal_Manager__c=salesPodMap.get(primaryMA1.OwnerId).Renewal_Manager__c;
                        }
                        contractsToUpdate.add(c);
                    }else{ //Account is not ENT/Mid-markrt and only if we have existing Sales Pod lead 
                        if(salesPodMap.containskey(primaryMA1.OwnerId)){
                            c.Primary_Renewal_Owner__c = salesPodMap.get(primaryMA1.OwnerId).Renewal_Manager__c; //else - RM is the PRO
                            c.Renewal_Manager__c = salesPodMap.get(primaryMA1.OwnerId).Renewal_Manager__c;
                            system.debug('RM Noam'+c.Renewal_Manager__c);
                            system.debug('RM Contract Noam'+c.Renewal_Manager__c);
                            c.Define_Default_PRO_Assignment__c = false;
                            contractsToUpdate.add(c);
                        }else{
                            c.Primary_Renewal_Owner__c =primaryMA1.OwnerId; //Account should be assigned to RM, but we couldn't find the relvant Pod Assignment therfor PRO is Account Owner 
                            c.Define_Default_PRO_Assignment__c = false;
                            contractsToUpdate.add(c);
                        }
                    }
                }
            }
        }  
        //Update the contract with the PRO
        try {
            Database.update(contractsToUpdate, false);
        } catch (Exception e) {
            System.debug('Message: ' + e.getMessage());
        }
        return contractsToUpdate;           
    }
    // defineRenewalManagerBasedOnPod(Account primaryMA1, ,Map )){
    // }
} 