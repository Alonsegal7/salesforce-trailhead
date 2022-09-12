public class PartnerCommission_PartnerTransfer_Queue implements System.Queueable {
    private List<Account> mondayAccountsList;     
    private Map<Id,Id> partnersToClosePC;
    private Map<Id,Id> partnersToCreatePC;
    private static final String CLASS_NAME_CONST = 'PartnerCommission_PartnerTransfer_Queue';

    public PartnerCommission_PartnerTransfer_Queue(List<Account> mondayAccountsList, Map<Id,Id> partnersToClosePC, Map<Id,Id> partnersToCreatePC) {
        this.mondayAccountsList = mondayAccountsList;
        this.partnersToClosePC = partnersToClosePC;
        this.partnersToCreatePC = partnersToCreatePC;
    }

    public void execute(System.QueueableContext ctx) {
        List<Partner_Commission__c> newPartnerCommissionList = new List<Partner_Commission__c>();
        PartnerCommissionService pcService = new PartnerCommissionService();
        try{
            Map<Id,Account> mondayAccountsMap = new Map<Id,Account>(mondayAccountsList);
            if(!partnersToClosePC.isEmpty()){   // close all PCs of prev partners
                Set<Id> partnersIds = new Set<Id>(partnersToClosePC.values());
                List<Partner_Commission__c> pcToCloseList = [select Id, 
                                                            Monday_Account__c, 
                                                            Monday_Account__r.Plan_Period__c,
                                                            Partner_Company__c, 
                                                            Close_Reason__c, 
                                                            End_Date__c 
                                                            from Partner_Commission__c 
                                                            where Monday_Account__c IN: partnersToClosePC.keySet() 
                                                            and Partner_Company__c IN: partnersIds 
                                                            and is_Last__c = true 
                                                            and Renewable__c = true];
                for(Partner_Commission__c pc: pcToCloseList){
                    if(partnersToClosePC.containsKey(pc.Monday_Account__c) && partnersToClosePC.get(pc.Monday_Account__c) == pc.Partner_Company__c){
                        Partner_Commission__c updatedPc = new Partner_Commission__c(
                            Id = pc.Id, 
                            Renewable__c = false
                        );
                        if(pc.Close_Reason__c == null && (pc.End_Date__c == null || pc.End_Date__c >= Datetime.now())){ //pc is open - we set end date to be the last transaction time
                            Datetime setEndDateTime = mondayAccountsMap.get(pc.Monday_Account__c).Last_ARR_Update_Timestamp__c;

                            if(setEndDateTime == null){
                                setEndDateTime = Datetime.now();
                            }
                            
                            updatedPc.End_Date__c = setEndDateTime;
                            updatedPc.ARR_Upon_Close__c = mondayAccountsMap.get(pc.Monday_Account__c).ARR__c;
                            updatedPc.Close_Reason__c = 'Partners Transfer';
                        }
                        newPartnerCommissionList.add(updatedPc);
                    }
                }
            }
            if(!newPartnerCommissionList.isEmpty()) {
                pcService.upsertPartnerCommissionInQueue(newPartnerCommissionList, CLASS_NAME_CONST);
                newPartnerCommissionList.clear();
            }
            
            if(!partnersToCreatePC.isEmpty()) {// create PCs for all new partners
                //create new PCs only for MAs above TH
                Map<String, GB_Threshold__c> gbThresholdsMap = pcService.getThsMap();
                for(Id mondayAccId: partnersToCreatePC.keySet()){
                    if(mondayAccountsMap.get(mondayAccId).ARR__c < gbThresholdsMap.get(mondayAccountsMap.get(mondayAccId).Account_Source_Type__c).Min_ARR__c){
                        partnersToCreatePC.remove(mondayAccId);
                    }
                }
                if(!partnersToCreatePC.isEmpty()){
                    Set<Id> partnerToCreateIds = new Set<Id>(partnersToCreatePC.values());
                    List<Partner_Commission__c> existingPcsList = [select Id, Monday_Account__c, Partner_Company__c from Partner_Commission__c where Monday_Account__c IN: partnersToCreatePC.keySet() and Partner_Company__c IN: partnerToCreateIds and is_Last__c = true and Renewable__c = true and (End_Date__c = null or End_Date__c >: Datetime.now())];
                    for(Partner_Commission__c pc: existingPcsList){
                        if(partnersToCreatePC.containsKey(pc.Monday_Account__c) && partnersToCreatePC.get(pc.Monday_Account__c) == pc.Partner_Company__c){
                            partnersToCreatePC.remove(pc.Monday_Account__c);
                        }
                    }
                    if(!partnersToCreatePC.isEmpty()){
                        Set<Id> allaccountsForCreate = new Set<Id>(partnersToCreatePC.values());
                        allaccountsForCreate.addAll(mondayAccountsMap.keySet());
                        Map<Id,Account> accountsMap = pcService.getAccountsMap(allaccountsForCreate);
                        for(Id mondayAccId: partnersToCreatePC.keySet()){
                            if(accountsMap.containsKey(mondayAccId) && accountsMap.containsKey(partnersToCreatePC.get(mondayAccId))){
                                Partner_Commission__c newPc = pcService.createNewPc(accountsMap.get(mondayAccId), accountsMap.get(partnersToCreatePC.get(mondayAccId)), null, 'Partners Transfer');
                                //we set start date to be 1 second after the mondayAccount.Last_ARR_Update_Timestamp__c so the new partner will get comission only for new transactions
                                //if newPc.Start_Date__c == null it will handled in the PartnerCommission service and will set a start date
                                    newPc.Start_Date__c = newPc.Start_Date__c.addSeconds(1); 

                                newPartnerCommissionList.add(newPc);
                            }
                        }
                    }
                }
            }
            if(!newPartnerCommissionList.isEmpty()) {
                pcService.upsertPartnerCommissionInQueue(newPartnerCommissionList, CLASS_NAME_CONST);
            }
        } catch (Exception ex){
            pcService.sendErrorEmail(CLASS_NAME_CONST, ex.getMessage());
            throw ex;
        }
    }
}