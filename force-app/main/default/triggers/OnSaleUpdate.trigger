trigger OnSaleUpdate on Sale__c (before update, before insert, after insert, after update, after delete) {
    if(Trigger.isBefore && !Trigger.isDelete){
        //Sale__c prevSale = null;
        
        for(Sale__c sale : Trigger.new){
            if(sale.Sale_Status_Override__c != '' && sale.Sale_Status_Override__c != null){
                sale.FinalSaleStatus__c = sale.Sale_Status_Override__c;
            }else{
                sale.FinalSaleStatus__c = sale.Sale_Status__c;
            }
            /*prevSale = null;
            if(sale.Id != null){
                prevSale = Trigger.oldMap.get(sale.Id);
            }
            if(prevSale == null || prevSale.Close_Date__c != sale.Close_Date__c || prevSale.Owner__c != sale.Owner__c|| prevSale.Owner_s_Manager__c != sale.Owner_s_Manager__c){
                TargetsService.updateSaleTarget(sale);
            }*/
        }
        TargetsService.TargetsService(trigger.new,trigger.oldmap);
    }
    
    if(Trigger.isAfter){
        if (Trigger.isDelete) CalloutHandler.HandleCallout (trigger.old,'Delete',null);
        if (trigger.isInsert) CalloutHandler.HandleCallout (trigger.new,'Insert',null);
        if (trigger.IsUpdate) CalloutHandler.HandleCallout (trigger.new,'Update',trigger.oldmap);   
    }
}