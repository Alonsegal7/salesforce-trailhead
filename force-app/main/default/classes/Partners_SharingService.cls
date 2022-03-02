public without sharing class Partners_SharingService {
    
    public static Id partnerOppRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Partner_Opportunity').getRecordTypeId();
    public static Id partnerLeadRT = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Partner_Lead').getRecordTypeId();

    public static Boolean stopAddToEligibleCommissionGroup = false;
    public static Id allEligibleGroupId;

    public static void handleEligibleUsersUserRole(List<User> newUsers, Map<Id,User> oldUsersMap){
        if(stopAddToEligibleCommissionGroup) return;
        Set<Id> eligibleUsersIds = new Set<Id>();
        for(User userRec: newUsers){
            if(userRec.IsActive && userRec.ContactId != null &&
                ((userRec.Eligible_for_Partners_Commission__c && oldUsersMap == null) ||
                (oldUsersMap != null && userRec.Eligible_for_Partners_Commission__c != oldUsersMap.get(userRec.Id).Eligible_for_Partners_Commission__c))){ //new eligible user or updated to be eligible for commission
                    eligibleUsersIds.add(userRec.Id);
            }
        }
        if(eligibleUsersIds.isEmpty()) return;

        List<User> eligibleUsersList = [select Contact.AccountId, Contact.Account.Name, Eligible_for_Partners_Commission__c, UserRole.DeveloperName from User where Id in: eligibleUsersIds];
        Set<Id> partnerCompsIds = new Set<Id>();
        for(User userRec: eligibleUsersList){
            partnerCompsIds.add(userRec.Contact.AccountId);
        }

        Id partnerCompId;
        Map<Id,Map<String,Id>> partnerCompToRolesMap = getPartnerCompToRoleMap(partnerCompsIds);
        List<User> usersWithPublicGroups = new List<User>();
        Set<Id> partnerCompsIds_EFC = new Set<Id>();
        Set<Id> rolesToAddToAll = new Set<Id>();

        for(User userRec: eligibleUsersList){ //go over users and check if the partner comp has a manager group
            partnerCompId = userRec.Contact.AccountId;
            if(partnerCompId == null) continue;
            if(userRec.Eligible_for_Partners_Commission__c){
                if(partnerCompToRolesMap.containsKey(partnerCompId) && partnerCompToRolesMap.get(partnerCompId).containsKey('Manager')){
                    userRec.UserRoleId = partnerCompToRolesMap.get(partnerCompId).get('Manager');
                    rolesToAddToAll.add(userRec.UserRoleId); //add role to All_Eligible_for_Commission_Partners group
                } else { //users of the 29 partner comps that have only one role of user (no manager role) so we need to create a public group for them EFC_AccountId
                    usersWithPublicGroups.add(userRec);
                    partnerCompsIds_EFC.add(partnerCompId);
                }
            } else {
                if(partnerCompToRolesMap.containsKey(partnerCompId) && partnerCompToRolesMap.get(partnerCompId).containsKey('User')){
                    userRec.UserRoleId = partnerCompToRolesMap.get(partnerCompId).get('User');
                }
            }
        }
        Database.update(eligibleUsersList);
        if(!usersWithPublicGroups.isEmpty()){
            addToEligibleCommissionGroup(usersWithPublicGroups, partnerCompsIds_EFC);
        }
        if(!rolesToAddToAll.isEmpty()){
            Map<Id, Group> groupsMap = new Map<Id, Group>([select Id, DeveloperName, RelatedId, Type from Group where RelatedId in: rolesToAddToAll and Type = 'Role' and (DeveloperName like '%PartnerUser' or DeveloperName like '%PartnerManager')]);
            if(allEligibleGroupId == null) allEligibleGroupId = [select Id from Group where DeveloperName = 'All_Eligible_for_Commission_Partners' limit 1].Id;
            for(GroupMember gm: [select Id, UserOrGroupId from GroupMember where GroupId =: allEligibleGroupId and UserOrGroupId in: groupsMap.keySet()]){
                groupsMap.remove(gm.UserOrGroupId);
            }
            if(groupsMap.isEmpty()) return;
            List<GroupMember> newGroupMembersList =new List<GroupMember>(); 
            for(Group gr: groupsMap.values()){
                GroupMember newGm = new GroupMember(); 
                newGm.GroupId = allEligibleGroupId;
                newGm.UserOrGroupId = gr.Id;
                newGroupMembersList.add(newGm);
            }
            Database.insert(newGroupMembersList);
        }
    }

    public static Map<Id,Map<String,Id>> getPartnerCompToRoleMap(Set<Id> partnerCompsIds){
        Map<Id,Map<String,Id>> res = new Map<Id,Map<String,Id>>();
        //get user roles by Portal Account ids
        List<UserRole> userRolesList = [select Id, PortalAccountId, DeveloperName from UserRole where PortalAccountId in: partnerCompsIds and PortalType = 'Partner'];
        system.debug('userRolesList: '+ userRolesList);
        Id partnerCompId;
        String key;
        for(UserRole uRole: userRolesList){ //for every group (can be max 2 per partner comp - user and manager) we will create account share
            if(uRole.DeveloperName.endsWith('PartnerManager')) key = 'Manager';
            else key = 'User';
            partnerCompId = uRole.PortalAccountId;
            if(res.containsKey(partnerCompId)){
                res.get(partnerCompId).put(key, uRole.Id);
            } else {
                Map<String,Id> temp = new Map<String,Id>();
                temp.put(key,uRole.Id);
                res.put(partnerCompId, temp);
            }
        }
        system.debug('getPartnerCompToRoleMap res: '+ res);
        return res;
    }

    public static void addToEligibleCommissionGroup(List<User> usersList, Set<Id> partnerCompsIds){
        Set<Id> usersIdsToRemove = new Set<Id>();
        Set<Id> groupIdsToRemove = new Set<Id>();
        Map<Id,Id> partnerCompToGroupsMap = getPartnerCompToEligibleGroupMap(partnerCompsIds);
        List<GroupMember> newGroupMembersList =new List<GroupMember>(); 
        List<User> usersToCreateNewGroupsFor = new List<User>();
        Map<Id, Group> partnerIdToNewGroups = new Map<Id, Group>();

        for(User userRec: usersList){
            if(partnerCompToGroupsMap.containsKey(userRec.Contact.AccountId)){ //group already exists
                if(userRec.Eligible_for_Partners_Commission__c){
                    GroupMember gmExistingGroup = new GroupMember(); 
                    gmExistingGroup.GroupId = partnerCompToGroupsMap.get(userRec.Contact.AccountId);
                    gmExistingGroup.UserOrGroupId = userRec.Id;
                    newGroupMembersList.add(gmExistingGroup);
                } else {
                    usersIdsToRemove.add(userRec.Id);
                    groupIdsToRemove.add(partnerCompToGroupsMap.get(userRec.Contact.AccountId));
                }
            } else if(userRec.Eligible_for_Partners_Commission__c){ //need to create new group for eligible for commission
                Group newGroup = new Group();
                newGroup.Name = getPartnerEFCGroupName(userRec.Contact.AccountId);
                newGroup.Type = 'Regular';
                newGroup.DoesIncludeBosses = false;
                partnerIdToNewGroups.put(userRec.Contact.AccountId, newGroup);
                usersToCreateNewGroupsFor.add(userRec);
            }
        }
        if(!usersIdsToRemove.isEmpty()){
            List<GroupMember> groupMemberToDelete = [select Id from GroupMember where GroupId IN: groupIdsToRemove and UserOrGroupId IN: usersIdsToRemove];
            if(!groupMemberToDelete.isEmpty()) Database.delete(groupMemberToDelete);
        }
        if(!partnerIdToNewGroups.isEmpty()){
            Database.insert(partnerIdToNewGroups.values());
            if(allEligibleGroupId == null) allEligibleGroupId = [select Id from Group where DeveloperName = 'All_Eligible_for_Commission_Partners' limit 1].Id;
            for(Group groupRec: partnerIdToNewGroups.values()){
                GroupMember gmGeneralGroup = new GroupMember(); 
                gmGeneralGroup.GroupId = allEligibleGroupId;
                gmGeneralGroup.UserOrGroupId = groupRec.Id;
                newGroupMembersList.add(gmGeneralGroup);
            }
            for(User userRec: usersToCreateNewGroupsFor){
                GroupMember gmUser = new GroupMember(); 
                gmUser.GroupId = partnerIdToNewGroups.get(userRec.Contact.AccountId).Id;
                gmUser.UserOrGroupId = userRec.Id;
                newGroupMembersList.add(gmUser);
            }
        }
        if(!newGroupMembersList.isEmpty()) Database.insert(newGroupMembersList);
    }

    public static void newPartnerOppsSharingValidation(List<Opportunity> newOppsList){
        if(UserInfo.getProfileId() != '00e1t000000e3ITAAY') return;
        Set<Id> accountIds = new Set<Id>();
        List<Opportunity> partnerOpps = new List<Opportunity>();
        for(Opportunity opp :newOppsList){
            if(opp.RecordTypeId == partnerOppRT && opp.AccountId != null){
                accountIds.add(opp.AccountId);
                partnerOpps.add(opp);
            }
        }
        if(partnerOpps.isEmpty()) return;
        Map<Id,Id> mondayAccsToChannelPartners = new Map<Id,Id>();
        for(Account acc: [select Id, Channel_Partner__c from Account where Id in: accountIds]){
            mondayAccsToChannelPartners.put(acc.Id, acc.Channel_Partner__c);
        }
        Id partnerAccountId = [select Id, Contact.AccountId from User where Id =: UserInfo.getUserId()].Contact.AccountId;
        for(Opportunity opp: partnerOpps){
            if(partnerAccountId != mondayAccsToChannelPartners.get(opp.AccountId)){
                opp.addError('You have no permission to create new opportunities on this account');
            }
        }
    }

    public static void createOpportunityShares(List<Opportunity> newOppsList, Map<Id,Opportunity> oldOppsMap){
        Set<Id> partnerCompsIds = new Set<Id>();
        List<Opportunity> oppsToCreateSharesCPChanged = new List<Opportunity>();
        List<Opportunity> oppsToDeleteSharesCPChanged = new List<Opportunity>();
        //1
        //go over partner opps only (record type = partner), and collect opps that need to create shares for and opps that their shares need to be deleted
        //by Channel_Partner__c like in accounts
        for(Opportunity opp :newOppsList){
            if((opp.RecordTypeId == partnerOppRT || (oldOppsMap != null && oldOppsMap.get(opp.Id).RecordTypeId == partnerOppRT)) && 
                (oldOppsMap == null || opp.Channel_Partner__c != oldOppsMap.get(opp.Id).Channel_Partner__c)){
                if(oldOppsMap == null){ //new opp
                    if(opp.Channel_Partner__c != null) { //channel partner is assigned
                        oppsToCreateSharesCPChanged.add(opp);
                        partnerCompsIds.add(opp.Channel_Partner__c);
                    }
                } else { //opp updated
                    if(opp.Channel_Partner__c != oldOppsMap.get(opp.Id).Channel_Partner__c){ //channel partner changed
                        if(opp.Channel_Partner__c != null) { //new channel partner is assigned
                            oppsToCreateSharesCPChanged.add(opp);
                            partnerCompsIds.add(opp.Channel_Partner__c);
                        }
                        if(oldOppsMap.get(opp.Id).Channel_Partner__c != null) { //old channel unassigned 
                            oppsToDeleteSharesCPChanged.add(opp);
                            partnerCompsIds.add(oldOppsMap.get(opp.Id).Channel_Partner__c);
                        }
                    }
                }
            }
        }
        //2
        //get the groups of the partner companies
        if(partnerCompsIds.isEmpty()) return;
        system.debug('partnerCompsIds: '+partnerCompsIds);
        Map<Id,List<Id>> partnerCompToGroupsMap = getPartnerCompToGroupsMap(partnerCompsIds);

        //3
        //delete opp shares due to channel partner change
        if(!oppsToDeleteSharesCPChanged.isEmpty()){
            system.debug('oppsToDeleteSharesCPChanged: '+oppsToDeleteSharesCPChanged);
            Set<Id> groupIdsForDelete = new Set<Id>();
            Set<Id> oppIds = new Set<Id>();
            if(!oppsToDeleteSharesCPChanged.isEmpty()){
                oppIds.addAll((new Map<Id,Opportunity>(oppsToDeleteSharesCPChanged)).keySet());
                for(Opportunity opp : oppsToDeleteSharesCPChanged){
                    if(!partnerCompToGroupsMap.containsKey(oldOppsMap.get(opp.Id).Channel_Partner__c)) continue;
                    for(Id groupId: partnerCompToGroupsMap.get(oldOppsMap.get(opp.Id).Channel_Partner__c)){
                        groupIdsForDelete.add(groupId);
                    }
                }
            }
            system.debug('groupIdsForDelete: '+groupIdsForDelete);
            system.debug('oppIds: '+oppIds);

            List<OpportunityShare> oppSharesToDelete = [select Id, OpportunityId, UserOrGroupId from OpportunityShare where OpportunityId in: oppIds and UserOrGroupId in: groupIdsForDelete and RowCause = 'Manual'];
            if(!oppSharesToDelete.isEmpty()) deleteShares(oppSharesToDelete, 'OpportunityShare');
            system.debug('oppSharesToDelete: '+oppSharesToDelete);
        }

        //4
        //create opp shares
        if(!oppsToCreateSharesCPChanged.isEmpty()){
            system.debug('oppsToCreateSharesCPChanged: '+oppsToCreateSharesCPChanged);

            List<OpportunityShare> oppSharesToCreate = new List<OpportunityShare>();
            for(Opportunity opp : oppsToCreateSharesCPChanged){
                if(!partnerCompToGroupsMap.containsKey(opp.Channel_Partner__c)) continue;
                for(Id groupId: partnerCompToGroupsMap.get(opp.Channel_Partner__c)){
                    OpportunityShare newOppShare = new OpportunityShare();
                    newOppShare.OpportunityId = opp.Id;
                    newOppShare.OpportunityAccessLevel = 'Edit';
                    newOppShare.UserOrGroupId = groupId;
                    oppSharesToCreate.add(newOppShare);
                }
            }
            
            if(oppSharesToCreate.isEmpty()) return;
            createShares(oppSharesToCreate,'OpportunityShare');
            system.debug('oppSharesToCreate: '+oppSharesToCreate);
        }  
    }

    public static void createLeadShares_ManualTrigger(List<Lead> newLeadsList){
        List<Lead> leadList = new List<Lead>();
        for(Lead lead :newLeadsList){
            if(lead.Manual_Trigger__c == 'Create Lead Shares - Partners'){
                lead.Manual_Trigger__c = '';
                leadList.add(lead);
            }
        }
        if(!leadList.isEmpty()) createLeadShares(leadList, null);
    }

    public static void createAccountShares_ManualTrigger(List<Account> newAccountsList){
        List<Account> accList = new List<Account>();
        for(Account acc :newAccountsList){
            if(acc.Manual_Trigger__c == 'Create Account Shares - Partners'){
                acc.Manual_Trigger__c = '';
                accList.add(acc);
            }
        }
        if(!accList.isEmpty()) createAccountShares(accList, null);
    }

    public static void createOpportunityShares_ManualTrigger(List<Opportunity> newOppsList){
        List<Opportunity> oppList = new List<Opportunity>();
        for(Opportunity opp :newOppsList){
            if(opp.Manual_Trigger__c == 'Create Opportunity Shares - Partners'){
                opp.Manual_Trigger__c = '';
                oppList.add(opp);
            }
        }
        if(!oppList.isEmpty()) createOpportunityShares(oppList, null);
    }

    public static void createAccountShares(List<Account> newAccountsList, Map<Id,Account> oldAccountsMap){
        Set<Id> partnerCompsIds = new Set<Id>();
        List<Account> accountsToCreateShares = new List<Account>();
        List<Account> accountToDeleteShares = new List<Account>();
        Id MARecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Monday_Account').getRecordTypeId();

        //go over accounts and collect account that need to create shares for and accounts that their shares needs to be deleted
        for(Account acc :newAccountsList){
            if(acc.RecordTypeId == MARecordTypeId && (oldAccountsMap == null || acc.Channel_Partner__c != oldAccountsMap.get(acc.Id).Channel_Partner__c)){
                if(acc.Channel_Partner__c != null){ //new partner company is assigned to the account - need to create new shares
                    partnerCompsIds.add(acc.Channel_Partner__c);
                    accountsToCreateShares.add(acc);
                }
                if(oldAccountsMap != null && oldAccountsMap.get(acc.Id).Channel_Partner__c != null){ //prev partner company unassigned from account - need to delete old shares
                    partnerCompsIds.add(oldAccountsMap.get(acc.Id).Channel_Partner__c);
                    accountToDeleteShares.add(acc);
                }
            }
        }
        if(partnerCompsIds.isEmpty()) return;
        Map<Id,List<Id>> partnerCompToGroupsMap = getPartnerCompToGroupsMap(partnerCompsIds);

        //delete account shares
        if(!accountToDeleteShares.isEmpty()){
            Set<Id> accountToDeleteSharesIds = (new Map<Id,Account>(accountToDeleteShares)).keySet();
            Set<Id> groupIdsForDelete = new Set<Id>();
            for(Account acc : accountToDeleteShares){
                if(!partnerCompToGroupsMap.containsKey(oldAccountsMap.get(acc.Id).Channel_Partner__c)) continue;
                for(Id groupId: partnerCompToGroupsMap.get(oldAccountsMap.get(acc.Id).Channel_Partner__c)){
                    groupIdsForDelete.add(groupId);
                }
            }
            List<AccountShare> accountSharesToDelete = [select Id, AccountId, UserOrGroupId from AccountShare where AccountId in: accountToDeleteSharesIds and UserOrGroupId in: groupIdsForDelete and RowCause = 'Manual'];
            if(!accountSharesToDelete.isEmpty()) deleteShares(accountSharesToDelete, 'AccountShare');
        }
        //create account shares
        if(!accountsToCreateShares.isEmpty()){
            List<AccountShare> accountSharesToCreate = new List<AccountShare>();
            for(Account acc : accountsToCreateShares){
                if(!partnerCompToGroupsMap.containsKey(acc.Channel_Partner__c)) continue;
                for(Id groupId: partnerCompToGroupsMap.get(acc.Channel_Partner__c)){
                    AccountShare newAccShare = new AccountShare();
                    newAccShare.AccountId = acc.Id;
                    newAccShare.AccountAccessLevel = 'Edit';
                    newAccShare.CaseAccessLevel = 'Edit';
                    newAccShare.OpportunityAccessLevel = 'None';
                    newAccShare.UserOrGroupId = groupId;
                    accountSharesToCreate.add(newAccShare);
                }
            }
            if(accountSharesToCreate.isEmpty()) return;
            createShares(accountSharesToCreate,'AccountShare');
        }  
    }

    public static void createAccountSharesOwnerChange(List<Account> newAccountsList, Map<Id,Account> oldAccountsMap){
        if(oldAccountsMap == null) return;
        Set<Id> partnerCompsIds = new Set<Id>();
        List<Account> accountsToCreateShares = new List<Account>();
        Id MARecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Monday_Account').getRecordTypeId();

        //go over accounts and collect account that need to create shares for and accounts that their shares needs to be deleted
        for(Account acc :newAccountsList){
            if(acc.RecordTypeId == MARecordTypeId && acc.OwnerId != oldAccountsMap.get(acc.Id).OwnerId && acc.Channel_Partner__c != null){
                partnerCompsIds.add(acc.Channel_Partner__c);
                accountsToCreateShares.add(acc);
            }
        }
        if(partnerCompsIds.isEmpty()) return;
        Map<Id,List<Id>> partnerCompToGroupsMap = getPartnerCompToGroupsMap(partnerCompsIds);

        //create account shares
        if(!accountsToCreateShares.isEmpty()){
            List<AccountShare> accountSharesToCreate = new List<AccountShare>();
            for(Account acc : accountsToCreateShares){
                if(!partnerCompToGroupsMap.containsKey(acc.Channel_Partner__c)) continue;
                for(Id groupId: partnerCompToGroupsMap.get(acc.Channel_Partner__c)){
                    AccountShare newAccShare = new AccountShare();
                    newAccShare.AccountId = acc.Id;
                    newAccShare.AccountAccessLevel = 'Edit';
                    newAccShare.CaseAccessLevel = 'Edit';
                    newAccShare.OpportunityAccessLevel = 'None';
                    newAccShare.UserOrGroupId = groupId;
                    accountSharesToCreate.add(newAccShare);
                }
            }
            if(accountSharesToCreate.isEmpty()) return;
            createShares(accountSharesToCreate,'AccountShare');
        }  
    }

    private static Map<Id,List<Id>> getPartnerCompToGroupsMap(Set<Id> partnerCompsIds){
        //get the userRoles from the partner users that are in the partner companies
        List<User> usersList = [select UserRoleId, Contact.AccountId from User where Contact.AccountId in: partnerCompsIds];
        Map<Id,Id> userRolesToPartnerCompMap = new Map<Id,Id>();
        for (User user : usersList) {
            userRolesToPartnerCompMap.put(user.UserRoleId, user.Contact.AccountId);
        }
        //get the groups by the userRoles
        List<Group> groupsList = [select Id, DeveloperName, RelatedId, Type from Group where RelatedId in: userRolesToPartnerCompMap.keySet() and Type = 'Role' and (DeveloperName like '%PartnerUser' or DeveloperName like '%PartnerManager')];
        Map<Id,List<Id>> partnerCompToGroupsMap = new Map<Id,List<Id>>();
        Id partnerCompId;
        for(Group groupRec: groupsList){ //for every group (can be max 2 per partner comp - user and manager) we will create account share
            if(!userRolesToPartnerCompMap.containskey(groupRec.RelatedId)) continue;
            partnerCompId = userRolesToPartnerCompMap.get(groupRec.RelatedId);
            if(partnerCompToGroupsMap.containskey(partnerCompId)) partnerCompToGroupsMap.get(partnerCompId).add(groupRec.Id);
            else partnerCompToGroupsMap.put(partnerCompId, new List<Id>{groupRec.Id});
        }
        return partnerCompToGroupsMap;
    }

    private static string getPartnerEFCGroupName(Id partnerCompId){
        return 'EFC_' + partnerCompId;
    }

    private static Map<Id,Id> getPartnerCompToEligibleGroupMap(Set<Id> partnerCompsIds){
        Map<String, Id> groupDevNameToPartnerCompId = new Map<String, Id>();
        for(Id partnerCompId: partnerCompsIds){
            groupDevNameToPartnerCompId.put(getPartnerEFCGroupName(partnerCompId), partnerCompId);
        }
        List<Group> groupsList = [select Id, DeveloperName, RelatedId, Type, Name from Group where DeveloperName in: groupDevNameToPartnerCompId.keySet()];
        Map<Id,Id> partnerCompToGroupsMap = new Map<Id,Id>();
        Id partnerCompId;
        for(Group groupRec: groupsList){ //for every group (can be max 2 per partner comp - user and manager) we will create account share
            partnerCompToGroupsMap.put(groupDevNameToPartnerCompId.get(groupRec.Name), groupRec.Id);
        }
        return partnerCompToGroupsMap;
    }

    private static void deleteShares(List<sObject> sharesList, String entityName){
        Set<Id> successIds = new Set<Id>();
        String errorsFound = '', currErr = '';
        Database.DeleteResult[] drList = Database.delete(sharesList, false);
        for(Database.DeleteResult dr : drList) {
            if (dr.isSuccess()) {
                successIds.add(dr.getId());
            } else {
                for(Database.Error err : dr.getErrors()) {
                    currErr = err.getStatusCode() + ': ' + err.getMessage();
                    errorsFound += currErr + ', ';
                    system.debug('Partners_SharingService error in '+entityName+' delete: ' + errorsFound);
                }
            }
        }
        /*if(!successIds.isEmpty()){
            Utilities.sendEmail('Partners_SharingService - Successfully deleted '+entityName+'!', 'Ids of deleted '+entityName+': ' + successIds + ' <br/>Date: ' + date.today() + ' ' + datetime.now().format('E'), new List<String>{'kseniasm@monday.com'});
        }*/
        if(errorsFound != ''){
            Utilities.sendEmail('Partners_SharingService - Error in deleting '+entityName, 'Errors found: ' + errorsFound + ' <br/>Date: ' + date.today() + ' ' + datetime.now().format('E'), new List<String>{'kseniasm@monday.com'});
        }
    }

    private static void createShares(List<sObject> sharesList, String entityName){
        Set<Id> successIds = new Set<Id>();
        String errorsFound = '', currErr = '';
        Database.SaveResult[] lsr = Database.insert(sharesList, false);
        for (Database.SaveResult sr : lsr) {
            if (sr.isSuccess()) {
                successIds.add(sr.getId());
            } else {
                for(Database.Error err : sr.getErrors()) {
                    currErr = err.getStatusCode() + ': ' + err.getMessage();
                    errorsFound += currErr + ', ';
                    system.debug('Partners_SharingService error in '+entityName+' insert: ' + errorsFound);
                }
            }
        }
        /*if(!successIds.isEmpty()){
            Utilities.sendEmail('Partners_SharingService - Successfully created '+entityName+'!', 'Ids of new '+entityName+': ' + successIds + ' <br/>Date: ' + date.today() + ' ' + datetime.now().format('E'), new List<String>{'kseniasm@monday.com'});
        }*/
        if(errorsFound != ''){
            Utilities.sendEmail('Partners_SharingService - Error in creating '+entityName+'', 'Errors found: ' + errorsFound + ' <br/>Date: ' + date.today() + ' ' + datetime.now().format('E'), new List<String>{'kseniasm@monday.com'});
        }
    }

    public static void createLeadShares(List<Lead> newLeadsList, Map<Id,Lead> oldLeadsMap){
        Set<Id> partnerCompsIds = new Set<Id>();
        List<Lead> leadsToCreateSharesCPChanged = new List<Lead>();
        List<Lead> leadsToDeleteSharesCPChanged = new List<Lead>();
        //1
        //go over partner leads only (record type = partner), and collect leads that need to create shares for and leads that their shares need to be deleted
        //by Partner_Company__c like in accounts
        for(Lead lead :newLeadsList){
            if((lead.RecordTypeId == partnerLeadRT || (oldLeadsMap != null && oldLeadsMap.get(lead.Id).RecordTypeId == partnerLeadRT)) && 
                (oldLeadsMap == null || lead.Partner_Company__c != oldLeadsMap.get(lead.Id).Partner_Company__c)){
                if(oldLeadsMap == null){ //new lead
                    if(lead.Partner_Company__c != null) { //channel partner is assigned
                        leadsToCreateSharesCPChanged.add(lead);
                        partnerCompsIds.add(lead.Partner_Company__c);
                    }
                } else { //lead updated
                    if(lead.Partner_Company__c != oldLeadsMap.get(lead.Id).Partner_Company__c){ //channel partner changed
                        if(lead.Partner_Company__c != null) { //new channel partner is assigned
                            leadsToCreateSharesCPChanged.add(lead);
                            partnerCompsIds.add(lead.Partner_Company__c);
                        }
                        if(oldLeadsMap.get(lead.Id).Partner_Company__c != null) { //old channel unassigned 
                            leadsToDeleteSharesCPChanged.add(lead);
                            partnerCompsIds.add(oldLeadsMap.get(lead.Id).Partner_Company__c);
                        }
                    }
                }
            }
        }
        //2
        //get the groups of the partner companies
        if(partnerCompsIds.isEmpty()) return;
        system.debug('partnerCompsIds: '+partnerCompsIds);
        Map<Id,List<Id>> partnerCompToGroupsMap = getPartnerCompToGroupsMap(partnerCompsIds);

        //3
        //delete lead shares due to channel partner change
        if(!leadsToDeleteSharesCPChanged.isEmpty()){
            system.debug('leadsToDeleteSharesCPChanged: '+leadsToDeleteSharesCPChanged);
            Set<Id> groupIdsForDelete = new Set<Id>();
            Set<Id> leadIds = new Set<Id>();
            if(!leadsToDeleteSharesCPChanged.isEmpty()){
                leadIds.addAll((new Map<Id,Lead>(leadsToDeleteSharesCPChanged)).keySet());
                for(Lead lead : leadsToDeleteSharesCPChanged){
                    if(!partnerCompToGroupsMap.containsKey(oldLeadsMap.get(lead.Id).Partner_Company__c)) continue;
                    for(Id groupId: partnerCompToGroupsMap.get(oldLeadsMap.get(lead.Id).Partner_Company__c)){
                        groupIdsForDelete.add(groupId);
                    }
                }
            }
            system.debug('groupIdsForDelete: '+groupIdsForDelete);
            system.debug('leadIds: '+leadIds);

            List<LeadShare> leadSharesToDelete = [select Id, LeadId, UserOrGroupId from LeadShare where LeadId in: leadIds and UserOrGroupId in: groupIdsForDelete and RowCause = 'Manual'];
            if(!leadSharesToDelete.isEmpty()) deleteShares(leadSharesToDelete, 'LeadShare');
            system.debug('leadSharesToDelete: '+leadSharesToDelete);
        }

        //4
        //create lead shares
        if(!leadsToCreateSharesCPChanged.isEmpty()){
            system.debug('leadsToCreateSharesCPChanged: '+leadsToCreateSharesCPChanged);

            List<LeadShare> leadSharesToCreate = new List<LeadShare>();
            for(Lead lead : leadsToCreateSharesCPChanged){
                if(!partnerCompToGroupsMap.containsKey(lead.Partner_Company__c)) continue;
                for(Id groupId: partnerCompToGroupsMap.get(lead.Partner_Company__c)){
                    LeadShare newLeadShare = new LeadShare();
                    newLeadShare.LeadId = lead.Id;
                    newLeadShare.LeadAccessLevel = 'Edit';
                    newLeadShare.UserOrGroupId = groupId;
                    leadSharesToCreate.add(newLeadShare);
                }
            }
            
            if(leadSharesToCreate.isEmpty()) return;
            createShares(leadSharesToCreate,'LeadShare');
            system.debug('leadSharesToCreate: '+leadSharesToCreate);
        }  
    }
}