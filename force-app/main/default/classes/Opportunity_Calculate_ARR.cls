public without sharing class Opportunity_Calculate_ARR {
    public static Id csRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('CS_Opportunity').getRecordTypeId();
    public static void Opportunity_Calculate_ARR(List<Opportunity> opps, Map<Id, Opportunity> oldOpps){
        for (Opportunity opp : opps) {
            //Controlled from Quotes
            if(isManagedByDealhub(opp)){
                system.debug('OCA Raz Ben Ron is managed by dealhub');
                opp.Expected_ARR__c = opp.Quote_ARR__c;

                if(opp.Is_Primary_SO_Signed__c) {
                    opp.Claimed_ARR__c = opp.Product_ARR__c; 
                }
            }
            //co-sell
            if(!opp.Is_Primary_SO_Signed__c&&opp.Co_Sell_Opportunity__c!=null&&opp.Main_Co_Sell_Opportunity__c==false){//secondary co-sell opp
                system.debug('OCA Raz Ben Ron Secondary co-sell');
                opp.Expected_ARR__c = opp.Product_ARR__c;
                opp.Claimed_ARR__c = opp.CC_Products_ARR_Sum__c+opp.Co_Sell_Products_ARR_Sum__c; 

            }///override
            if(opp.Claimed_ARR_Override__c!=null){
                system.debug('OCA Raz Ben Ron claimed ARR Override');
                opp.Claimed_ARR__c =opp.Claimed_ARR_Override__c;
            }
            
            calcRenewalMetrics(opp);

        }
    }
    public static boolean isManagedByDealhub(Opportunity opp){
        return (opp.Quote_Count__c != null && opp.Quote_Count__c != 0) /*|| (opp.Product_Count__c != null && opp.Product_Count__c != 0)*/;
    }
    
    public static void calcRenewalMetrics(Opportunity opp){
        try{
            if(opp.Type!=null&&opp.Type.contains('Renewal')||opp.RecordTypeId==csRecordTypeId){
                decimal totalDealARR=null;
                decimal contractaRR=opp.Original_Contract_ARR__c==null?0:opp.Original_Contract_ARR__c;
                if(opp.SyncedQuoteId==null){
                    totalDealARR=contractaRR+opp.Green_Bucket_ARR_V2__c;
                    
                }else{
                    totalDealARR=opp.Total_License_ARR__c;
                }
                decimal retentionRate=contractaRR==0?0:totalDealARR/contractaRR;
                opp.Total_Renewal_ARR__c=totalDealARR;
                opp.Net_ARR_Retention__c=retentionRate*100;
                opp.Gross_ARR_Retention__c=math.min(retentionRate,1)*100;
            }
        }catch(exception e){
            Utilities.sendDebugEmail('Error in Opportunity_Calculate_ARR: Renewal Metrics ',e,e.getMessage());   
        }
    }
}