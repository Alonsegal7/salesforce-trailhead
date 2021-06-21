trigger OnSaleUpdate on Sale__c (before update, before insert, after insert, after update, after delete) {
    if(Trigger.isBefore && !Trigger.isDelete){        
        for(Sale__c sale : Trigger.new){
            if(sale.Sale_Status_Override__c != '' && sale.Sale_Status_Override__c != null){
                sale.FinalSaleStatus__c = sale.Sale_Status_Override__c;
            }else{
                sale.FinalSaleStatus__c = sale.Sale_Status__c;
            }
        }
        TargetsService targetServiceHelper = new TargetsService();
        targetServiceHelper.TargetsServiceOnSales(trigger.new,trigger.oldmap);
    }
    
    if(Trigger.isAfter){
        if (Trigger.isDelete) CalloutHandler.HandleCallout (trigger.old,'Delete',null);
        if (trigger.isInsert) CalloutHandler.HandleCallout (trigger.new,'Insert',null);
        if (trigger.IsUpdate) CalloutHandler.HandleCallout (trigger.new,'Update',trigger.oldmap);   
    }
}