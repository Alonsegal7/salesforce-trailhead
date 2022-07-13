public with sharing class ProjectItemService {
    public static Boolean firstRun = true;

    public static void CreateProjectItem(List<Handover__c> newHands, Map<Id,Handover__c> oldHand) {
        try{
        Map<Id, Project__c> newProjects = new Map<Id, Project__c>();
        List<Project_Item__c> projItmsToCreate = new List<Project_Item__c>();
        for (Handover__c handover : newHands) {
            if (handover.Onboarding_Owner__c!=null && handover.Onboarding_Owner__c!=oldHand.get(handover.Id).Onboarding_Owner__c && handover.CreateProjectOBAssignemnt__c) {
                System.debug('condition met');
                newProjects.put(handover.Opportunity__c,CreateProject(handover));
                firstRun=false;
            } 
        }
        if (!newProjects.isEmpty()) { {
            System.debug('found project');
            insert newProjects.values();    
            for (OpportunityLineItem oli : [select id,OpportunityId,ServiceDate, Expiration_Date__c,Quantity,Product2Id, Product2.Project_Item_Type__c from OpportunityLineItem WHERE (Product_Type__c='Onboarding' OR Product_Type__c='Professional Services')  AND OpportunityId IN:newProjects.keySet()]) {
                projItmsToCreate.add(new Project_Item__c(
                    Project__c = newProjects.get(oli.OpportunityId).Id,
                    Hours__c=oli.Quantity,
                    Product__c=oli.Product2Id,
                    Project_Item_Type__c=oli.Product2.Project_Item_Type__c,
                    Service_Date__c=oli.ServiceDate,
                    Expiration_Date__c=oli.Expiration_Date__c
                    ));
            }
        }
        if (!projItmsToCreate.isempty()) {
            System.debug('create project items');
              insert projItmsToCreate;
         }
        }
    }catch(Exception e){
        Utilities.sendDebugEmail('Error in ProjectItemService ', e, e.getMessage());   
    }
}
        private static Project__c CreateProject(Handover__c handover){ 
            System.debug('enter to create project');
            Project__c proj = new Project__c(
                Name='test',
                monday_Account__c=handover.monday_Account__c,
                Opportunity__c=handover.Opportunity__c,
                Created_from_flow__c= true,
                Project_Status__c='Pending Project Start',
                OwnerId=handover.Onboarding_Owner__c,
                Handover__c=handover.Id
            );
            System.debug('returned' + proj.id);
            return proj;
        }
        
}