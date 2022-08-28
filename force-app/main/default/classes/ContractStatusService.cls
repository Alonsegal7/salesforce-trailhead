public with sharing class ContractStatusService {

    public static void subsStatusChanged(List<Subscription__c> newSubs, map<Id, Subscription__c> oldMap){
        Set<Id> activationsIds = new Set<Id>();
        for (Subscription__c sub : newSubs) {
            if (sub.status__c != oldMap.get(sub.id).status__c && (sub.Status__c == 'INACTIVE' || sub.Status__c == 'ACTIVE')) {
                activationsIds.add(sub.id);
            }
        }
        List<Contract_Event__c> activationRelatedEvents = [select id,related_activation__c,Contract__c,contract_product__c from contract_event__c where related_activation__c in: activationsIds];
        if (!activationRelatedEvents.isempty()) {
            handleContractAndContractProductStatus(activationRelatedEvents,null);
        }
    }

    public static void handleContractAndContractProductStatus(List<Contract_Event__c> newConEve, Map<Id,Contract_Event__c> oldContEvents){
        try{
        List<Contract_Product__c> conProdToUpdate = new List<Contract_Product__c>();
        List<Contract> contsToUpdate = new List<Contract>();
        Set<Id> contIds = new Set<Id>();

        for (Contract_Event__c event : newConEve) {//I am a new event or got activation - run status process
            if (oldContEvents==null || (oldContEvents!=null && event.related_activation__c != null && event.related_activation__c!= oldContEvents.get(event.Id).related_activation__c) && event.IsRecurring__c) {
                contIds.add(event.Contract__c);
            }
        }
        //Get last start date events
        List<Contract_Product__c> conProdEvent = [select id,Activation_Status__c,product__r.IsRecurring__c, (select id,Start_Date__c,Activation_Status__c from Contract_Events__r where IsRecurring__c = true ORDER BY Start_Date__c DESC LIMIT 1) from Contract_Product__c where Contract__c in:contIds AND product__r.IsRecurring__c=true];

        for (Contract_Product__c singleConProdEvent : conProdEvent) {
            conProdToUpdate.add(new Contract_Product__c(Id=singleConProdEvent.Id,Activation_Status__c=singleConProdEvent.Contract_Events__r[0].Activation_Status__c)); 
        }
        update conProdToUpdate;

        List<Contract> contsWithProds = [select id,Activation_Status__c,(select id,Activation_Status__c,Contract__c from Contract_Products__r) from Contract where Id in:contIds];
        for (Contract con : contsWithProds) {
            contsToUpdate.add(setContractStatus(con.Contract_Products__r));
        }
        update contsToUpdate;
        }catch(Exception e){
            Utilities.sendDebugEmail('Error in ContractStatusService ',e,e.getMessage());   
        }
    }

    
    public static contract setContractStatus(List<Contract_Product__c> conProds){
        string activationStatus = 'Pending Activation';
        for (Contract_Product__c conProd : conProds) {
            if (conProd.Activation_status__c=='Pending Activation') {
                activationStatus='Pending Activation';
                break;
            }
            else if(conProd.Activation_status__c=='Scheduled Activation'){
                activationStatus='Scheduled Activation';
            }
            else if(conProd.Activation_status__c=='Active' && activationStatus!='Scheduled Activation'){
                activationStatus='Active';
            }
            else if(conProd.Activation_status__c=='Inactive' && activationStatus!='Scheduled Activation' && activationStatus!='Active'){
                activationStatus='Inactive';
            }
        }
        Contract con = new Contract(Id=conProds[0].contract__c,Activation_Status__c=activationStatus);
        return con;
    }
}