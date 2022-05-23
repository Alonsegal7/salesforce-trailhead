public without sharing class User_CommunityPublicGroupService {

    public static Id communityUsersPG_Id {
        get {
            if (communityUsersPG_Id == null) {
                communityUsersPG_Id = [select Id from Group where DeveloperName = 'Partner_Community_Users' limit 1].Id;
            }
            return communityUsersPG_Id;
        }
        set;
    }
    
    public static void addRemoved_PartnerCommunityUsersPG(List<User> newUsers, Map<Id,User> oldMap){
        Set<Id> usersToAddToPG = new Set<Id>();
        Set<Id> usersToRemoveFromPG = new Set<Id>();
        for(User u: newUsers){
            if(u.UserType != 'PowerPartner') continue; //relevant only to partner community users
            if(u.IsActive && (oldMap == null || !oldMap.get(u.Id).IsActive)){
                usersToAddToPG.add(u.Id); //new user or activated user
            }
            //existing user got deactivated
            if(!u.IsActive && oldMap != null && oldMap.get(u.Id).IsActive){
                usersToRemoveFromPG.add(u.Id); //remove users from group
            }
        }
        if(usersToAddToPG.isEmpty() && usersToRemoveFromPG.isEmpty()) return;
        System.enqueueJob(new updateGroupMembers(usersToAddToPG, usersToRemoveFromPG));
    }

    private class updateGroupMembers implements Queueable{
        private Set<Id> usersToAddToPG;
        private Set<Id> usersToRemoveFromPG;
    
        public updateGroupMembers(Set<Id> usersToAddToPG, Set<Id> usersToRemoveFromPG){
            this.usersToAddToPG = usersToAddToPG;
            this.usersToRemoveFromPG = usersToRemoveFromPG;
        }
        public void execute(System.QueueableContext ctx) {
            List<GroupMember> groupMembersListToCreate =new List<GroupMember>(); 
            for(Id userId: usersToAddToPG){
                //add users to group
                GroupMember newGm = new GroupMember(); 
                newGm.GroupId = communityUsersPG_Id;
                newGm.UserOrGroupId = userId;
                groupMembersListToCreate.add(newGm);
            }
            Database.insert(groupMembersListToCreate);
            if(!usersToRemoveFromPG.isEmpty()){
                List<GroupMember> groupMembersListToDelete = [select Id from GroupMember where GroupId=:communityUsersPG_Id and UserOrGroupId in: usersToRemoveFromPG];
                if(!groupMembersListToDelete.isEmpty()) Database.delete(groupMembersListToDelete);
            }
        }
    }
}