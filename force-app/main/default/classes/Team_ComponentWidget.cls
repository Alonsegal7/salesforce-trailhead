public with sharing class Team_ComponentWidget{
    // public List<Team__c> teamsList {get;set;}

    // public Team_ComponentWidget(){
    //     this.teamsList = new List<Team__c>();
    // }

    @AuraEnabled(cacheable=true)
    public static List<Team__c> getTeams(Id recordId){
        List<Team__c> lst = new List<Team__c>([SELECT Id, Name, Department__c FROM Team__c WHERE Monday_Account__c =: recordId]);
        return lst;
    }
}