public without sharing class PartnerMarketingActivity_PortionsService {

    //runs in after insert/update Partner_Marketing_Activity__c trigger
    public static void createPortions(List<Partner_Marketing_Activity__c> newMarketingAct_list, Map<Id,Partner_Marketing_Activity__c> oldMarketingAct_map){
        Set<String> typesForPortions = new Set<String>{'Headcount'}; //to add new types for portions - add them here
        List<MDF_Payment_Portion__c> newMdfPortions_list = new List<MDF_Payment_Portion__c>();
        Set<Id> maIdsforDeletePortions_set = new Set<Id>();
        for(Partner_Marketing_Activity__c ma: newMarketingAct_list){
            //CPM_Approval_Status__c changed to approved and Activity_Type__c is Headcount - need to delete old portions if existing and create new ones
            //Activity_Type__c is changed from Headcount to not Headcount - need to delete old portions
            if(ma.CPM_Approval_Status__c == 'Approved' 
                && typesForPortions.contains(ma.Activity_Type__c)
                && (oldMarketingAct_map == null 
                    || oldMarketingAct_map.get(ma.Id).CPM_Approval_Status__c != ma.CPM_Approval_Status__c 
                    || oldMarketingAct_map.get(ma.Id).Activity_Type__c != ma.Activity_Type__c)){
                        maIdsforDeletePortions_set.add(ma.Id); // delete existing portions
                        initNewPortions(ma, newMdfPortions_list); // init new portions

            } else if (oldMarketingAct_map != null 
                    && ma.CPM_Approval_Status__c == 'Approved' 
                    && oldMarketingAct_map.get(ma.Id).Activity_Type__c != ma.Activity_Type__c
                    && typesForPortions.contains(oldMarketingAct_map.get(ma.Id).Activity_Type__c)){
                        maIdsforDeletePortions_set.add(ma.Id); // delete existing portions    
            }
        }

        if(!maIdsforDeletePortions_set.isEmpty()) {
            List<MDF_Payment_Portion__c> ppToDelete = [select Id from MDF_Payment_Portion__c where Partner_Marketing_Activity__c in: maIdsforDeletePortions_set];
            if(!ppToDelete.isEmpty()) Database.delete(ppToDelete);
        }
        if(!newMdfPortions_list.isEmpty()) Database.insert(newMdfPortions_list);
    }

    private static void initNewPortions(Partner_Marketing_Activity__c ma, List<MDF_Payment_Portion__c> newMdfPortions_list){
        Integer numOfMonths;
        Date availableFromDate;
        numOfMonths = Integer.valueOf(ma.Months_for_Fund__c);
        availableFromDate = ma.Start_Date_for_Fund__c.toStartOfMonth();
        for(Integer i = 0; i < numOfMonths; i++){
            availableFromDate = availableFromDate.addMonths(1);
            MDF_Payment_Portion__c newMdfPortion = new MDF_Payment_Portion__c(
                Available_from_Date__c = availableFromDate,
                Is_Available_by_Date_not_formula__c = (Date.today() >= availableFromDate),
                Name = ma.Name + ' - ' + String.valueOf(availableFromDate),
                Partner_Marketing_Activity__c = ma.Id,
                Amount__c = ma.Monthly_Requested_Amount__c
            );
            newMdfPortions_list.add(newMdfPortion);
        }
    }
}