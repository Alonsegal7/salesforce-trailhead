public without sharing class User_CreateLeadsCap {

    public static void User_CreateLeadsCap(List<User> newUsers, Map<Id,User> oldUsersMap){
        try{
            list<User> relevantUsers= new list<User>();
            set<Id> relevantUsersIds= new set<Id>();
            Lead_Cap_Settings__mdt leadsCapSettings = [select id,Max_Open_Leads__c from Lead_Cap_Settings__mdt where DeveloperName='Sales'][0];
            for(User user: newUsers){
                if((oldUsersMap==null&&user.should_get_leads_from_BigBrain__c)||
                (user.should_get_leads_from_BigBrain__c&&
                user.should_get_leads_from_BigBrain__c!=oldUsersMap.get(user.id).should_get_leads_from_BigBrain__c)||
                user.Manual_Trigger__c=='Create Leads Cap'&&user.Manual_Trigger__c!=oldUsersMap.get(user.id).Manual_Trigger__c){
                    relevantUsers.add(user);
                    if(user.Id!=null)
                        relevantUsersIds.add(user.Id);
                }
                system.debug('Raz Ben Ron user.should_get_leads_from_BigBrain__c: '+user.should_get_leads_from_BigBrain__c);
            }
            system.debug('Raz Ben Ron relevantUsers: '+relevantUsers);
            if(relevantUsers.isEmpty())
                return;
            //look for existing LCs in order to prevent duplications
            map<id,Leads_Cap__c> existingLCs= new map<id,Leads_Cap__c>();
            for(Leads_Cap__c lc: [select id,User__c from Leads_Cap__c where User__c in: relevantUsersIds]){
                existingLCs.put(lc.User__c,lc);
            }
            system.debug('Raz Ben Ron existingLCs: '+existingLCs);
            list<Leads_Cap__c> lcsToCreate= new list<Leads_Cap__c>();
            list<User> usersToUpdate= new list<User>();
            for(User user:relevantUsers){
                if(user.Id==null||!existingLCs.containskey(user.Id))
                    lcsToCreate.add(new Leads_Cap__c(OwnerId=user.Id,
                                                    Name=user.FirstName+' '+user.LastName,
                                                    User__c=user.id,
                                                    Open_Leads_Limit__c=leadsCapSettings.Max_Open_Leads__c,
                                                    Department__c='Sales'));
                if(user.Manual_Trigger__c=='Create Leads Cap')  {
                    usersToUpdate.add(new user(id=user.id,Manual_Trigger__c=''));
                }
            }
            system.debug('Raz Ben Ron lcsToCreate: '+lcsToCreate);
            if(!lcsToCreate.isEmpty())
                insert lcsToCreate;
            if(!usersToUpdate.isEmpty())
                update usersToUpdate;
        }catch(exception e){
            Utilities.sendDebugEmail('Error in User_CreateLeadsCap',e,e.getMessage());   
        }
    }

}