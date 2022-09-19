public without sharing class User_CreatePodAssignment {
    public static void User_CreatePodAssignment(List<User> newUsers, Map<Id,User> oldUsersMap){
        try{
            list<User> relevantUsers= new list<User>();
            set<Id> relevantUsersIds= new set<Id>();
            for(User user: newUsers){
                //1. AE/AM rep has been created 2. user has been changed to be an AE/AM and the change was not made from being an AE/AM 
                if((oldUsersMap==null && (user.Seniority__c=='Rep' && (user.Business_Role__c == 'AE'|| user.Business_Role__c=='AM')))||
                (oldUsersMap!=null && user.Business_Role__c!=oldUsersMap.get(user.id).Business_Role__c && 
                ((user.Business_Role__c=='AE' && user.seniority__c=='Rep'&& oldUsersMap.get(user.id).Business_Role__c!='AM') || (user.Business_Role__c=='AM' && user.seniority__c=='Rep'&&oldUsersMap.get(user.id).Business_Role__c!='AE'))))
                {
                    relevantUsers.add(user);
                    //for user that has been updated, make sure for duplications
                    if(user.Id!=null)
                    relevantUsersIds.add(user.Id);
                }
            }
            if(relevantUsers.isEmpty())
                return;

            //look for existing Active Pods Assignemnt in order to prevent duplications
            map<id,Pod_Assignment__c> existingPodAssignment= new map<id,Pod_Assignment__c>();
            if(!relevantUsersIds.isEmpty()){
                for(Pod_Assignment__c Pod: [select id,Sales_Pod_Lead__c from Pod_Assignment__c where Sales_Pod_Lead__c in: relevantUsersIds AND Status__c!='Inactive']){
                    existingPodAssignment.put(Pod.Sales_Pod_Lead__c,Pod);
                }
            }

            list<Pod_Assignment__c> podsAssignmentToCreate= new list<Pod_Assignment__c>();
            for(User user:relevantUsers){
                if(user.Id==null||!existingPodAssignment.containskey(user.Id))
                podsAssignmentToCreate.add(new Pod_Assignment__c(Sales_Pod_Lead__c=user.Id,
                                                    Pod_Lead_Manager__c=user.ManagerId,
                                                    Pod_Type__c='Sales',
                                                    Status__c='Pending Assignment'));
            }
            if(!podsAssignmentToCreate.isEmpty())
                insert podsAssignmentToCreate;
        }catch(exception e){
            Utilities.sendDebugEmail('Error in User_CreateLeadsCap',e,e.getMessage());   
        }
    }
}

