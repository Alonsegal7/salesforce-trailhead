public without sharing class Opportunity_OppTypeService {
    public static void Opportunity_OppTypeService(List<Opportunity> opps, Map<Id, Opportunity> oldOpps) {
        try{
            list<Opportunity> relevantOpps= new  list<Opportunity>();
            for(Opportunity opp: opps){
                if(oldOpps==null||//insert
                    !opp.Is_Locked__c||
                    (opp.Manual_Trigger__c!=oldOpps.get(opp.Id).Manual_Trigger__c&&opp.Manual_Trigger__c=='Calc Opp Type')){
                        relevantOpps.add(opp);
                    }
            }
            system.debug('Raz Ben Ron relevantOpps: '+relevantOpps);
            if(relevantOpps.isEmpty())
                return;
            map<Id,Opportunity> oppWithContractData= new map<Id,Opportunity>([select id,Selected_Company_Contract__c,Selected_Company_Contract__r.Contract_ARR__c from Opportunity where id in: relevantOpps]);
            
            for(Opportunity opp: relevantOpps){
                decimal oppRenewalARR=opp.Total_Renewal_ARR__c;
                decimal contractARR;
                if(oppWithContractData.containsKey(opp.id)){
                    contractARR=oppWithContractData.get(opp.id).Selected_Company_Contract__c!=null?oppWithContractData.get(opp.id).Selected_Company_Contract__r.Contract_ARR__c:null;
                }
                system.debug('OppTypeSer real oppRenewalARR: '+oppRenewalARR);
                system.debug('OppTypeSer real contractARR: '+contractARR);
                if(opp.Type=='Service'){
                    opp.Opportunity_Type_V2__c='Service';
                }else if(opp.Green_Bucket_ARR_V2__c<0){
                    opp.Opportunity_Type_V2__c='Downgrade';
                }else if(opp.Selected_Company_Contract__c!=null&&contractARR!=null){//originated in the renewal process
                    if(oppRenewalARR==contractARR){
                        opp.Opportunity_Type_V2__c='Flat Renewal';
                    }else if(oppRenewalARR>contractARR){
                        opp.Opportunity_Type_V2__c='Expansion on Renewal';
                    }else{
                        opp.Opportunity_Type_V2__c='Downgrade on Renewal';
                    }
                }else if(opp.Prior_ARR__c==0||opp.First_Subscription_Claimed_on_Opp__c){//has first sub or arr on opp creation is 0
                    opp.Opportunity_Type_V2__c='New Business';
                }else{
                    opp.Opportunity_Type_V2__c='Expansion';
                }
                if(opp.Manual_Trigger__c!=null)
                    opp.Manual_Trigger__c='';
                system.debug('OppTypeSer opp.Opportunity_Type_V2__c: '+opp.Opportunity_Type_V2__c);
            }
        } catch(Exception e) {
            Utilities.sendEmail('Error in Opportunity_OppTypeService ',e.getMessage()+'<br/>Line: '+e.getLineNumber()+'<br/>Stack: '+e.getStackTraceString(),new list<string>{'razbe@monday.com'});
        }
    }
}