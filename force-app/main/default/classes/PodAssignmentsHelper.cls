    public with sharing class PodAssignmentsHelper {
    //define the Pod lead manager for Sales (manager of pod lead sales user),only when the Pod has been created via the change Pod process
    public static void definePodLeadManagerForSales(List<Pod_Assignment__c> newPodsAssignemnt, Map<Id,Pod_Assignment__c> oldPodsAssignemnt) {
        Set<Id> relvantSalesUsers = new set<Id>();
        List<Pod_Assignment__c> relvantPodAssignmentSales = new List<Pod_Assignment__c>();
        for(Pod_Assignment__c pod: newPodsAssignemnt){
            if(oldPodsAssignemnt == null && pod.Pod_Type__c == 'Sales' &&pod.Pod_Lead_Manager__c==null && pod.Sales_Pod_Lead__c!=null){
                relvantSalesUsers.add(pod.Sales_Pod_Lead__c);
                relvantPodAssignmentSales.add(pod);
            }
        }
        if (relvantPodAssignmentSales.isEmpty() && relvantSalesUsers.isEmpty()) return;
        Map<Id,User> usersMap = new Map<Id,User>([SELECT Id,ManagerId FROM USER WHERE Id IN: relvantSalesUsers]);
        for (Pod_Assignment__c podToUpdate : relvantPodAssignmentSales) {
            User currSalesUser = usersMap.get(podToUpdate.Sales_Pod_Lead__c);
            podToUpdate.Pod_Lead_Manager__c = currSalesUser.ManagerId;
        }     
    }  
    //define the Pod lead manager for Partners (CPM of the partner compney), only when the Pod has been created via the change Pod process
    public static void definePodLeadManagerForPartners(List<Pod_Assignment__c> newPodsAssignemnt, Map<Id,Pod_Assignment__c> oldPodsAssignemnt) {
        Set<Id> relvantPartnerCompenies = new set<Id>();
        List<Pod_Assignment__c> relvantPodAssignmentPartners = new List<Pod_Assignment__c>();
        for(Pod_Assignment__c pod: newPodsAssignemnt){
            if(oldPodsAssignemnt == null && pod.Pod_Type__c == 'Partners' &&pod.Pod_Lead_Manager__c==null && pod.Partner_Pod_Lead_Partner_Company__c!=null){
                relvantPartnerCompenies.add(pod.Partner_Pod_Lead_Partner_Company__c);
                relvantPodAssignmentPartners.add(pod);
            }
        }
        if (relvantPodAssignmentPartners.isEmpty() && relvantPartnerCompenies.isEmpty()) return;
        Map<Id,Account> PartnersCompniesMap = new Map<Id,Account>([SELECT Id,OwnerId FROM Account WHERE Id IN: relvantPartnerCompenies]);
        for (Pod_Assignment__c podToUpdate : relvantPodAssignmentPartners) {
            Account currPartnerCompney = PartnersCompniesMap.get(podToUpdate.Partner_Pod_Lead_Partner_Company__c);
            podToUpdate.Pod_Lead_Manager__c = currPartnerCompney.OwnerId;
            }   
        } 
    //for Pods that are Pending Assignment, once the Pod has been assigned to a renewal manager, update the status to "Active" and populate the Pod start date
    public static void renewalManagerAssignmentActions(List<Pod_Assignment__c> newPodsAssignemnt, Map<Id,Pod_Assignment__c> oldPodsAssignemnt) {
        List<Pod_Assignment__c> relvantPodAssignment = new List<Pod_Assignment__c>();
        for(Pod_Assignment__c pod: newPodsAssignemnt){
            if(oldPodsAssignemnt != null && pod.Renewal_Manager__c != oldPodsAssignemnt.get(pod.Id).Renewal_Manager__c && oldPodsAssignemnt.get(pod.Id).Renewal_Manager__c ==null)//renewal manager has been updated on the Pod assignment record (renewal manager will be defined only once, then record is for read only)
            {
                pod.Status__c='Active';
                pod.Pod_Start_Date__c=date.today();
            }
        }   
    }  
}

 