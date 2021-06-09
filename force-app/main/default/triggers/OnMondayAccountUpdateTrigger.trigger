trigger OnMondayAccountUpdateTrigger on Monday_Account__c (after insert, after update, after delete) {
	if(Trigger.isDelete){
		Callout.callDelete(Trigger.old);        
    }else {
        Callout.callUpdate(Trigger.new);        
    }

}