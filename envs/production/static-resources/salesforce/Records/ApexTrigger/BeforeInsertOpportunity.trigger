trigger BeforeInsertOpportunity on Opportunity (before insert) {
    /*
    for(Opportunity o:Trigger.new){
        if(o.primary_pulse_account_id__c == null ){
            String companyId = o.AccountId;
            Opportunity prevOpp = null;
            Opportunity[] prevOpps = [SELECT Id, primary_pulse_account_id__c, pulse_account_ids__c 
                                        FROM Opportunity 
                                        WHERE AccountId = :companyId
                                        AND primary_pulse_account_id__c != '' 
                                        and IsClosed=true
                                        order by CloseDate DESC
                                        limit 100];
            

            Set<String> pulseAccountIDs = new Set<String>();
        	for (Opportunity po : prevOpps) {
            	pulseAccountIDs.add(po.primary_pulse_account_id__c);
        	}
            	
            if(pulseAccountIDs.size() == 1){
               prevOpp = prevOpps[0];    
            }

            
            if(prevOpp != null){
                o.primary_pulse_account_id__c = prevOpp.primary_pulse_account_id__c;
                if(prevOpp.pulse_account_ids__c != '' && prevOpp.pulse_account_ids__c != null){
					o.pulse_account_ids__c = prevOpp.pulse_account_ids__c;                    
                }
            }
        }
        else if(o.pulse_account_ids__c == null || o.pulse_account_ids__c == ''){
            o.pulse_account_ids__c = o.primary_pulse_account_id__c;
        }
    }
*/
}