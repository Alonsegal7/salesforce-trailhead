public without sharing class Opportunity_Calculate_ARR {
    //coverage by Renewal_Global_Test

    public static Id csRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('CS_Opportunity').getRecordTypeId();
    public static void Opportunity_Calculate_ARR(List<Opportunity> opps, Map<Id, Opportunity> oldOpps){
        for (Opportunity opp : opps) {
            calcRenewalMetrics(opp);
            if(opp.Claimed_ARR_Override__c != null){ // arr override is stronger than products arr
                opp.Claimed_ARR__c =opp.Claimed_ARR_Override__c;
            } 
            else if(opp.Main_Co_Sell_Opportunity__c || opp.Co_Sell_Request__c == null || opp.Co_Sell_Opportunity__c == null){  //not secondary co-sell - we do not calc the arr based on quotes for secondary co-sell opps (they do not have quotes)
                if (isManagedByDealhub(opp)){//quote exists?
                opp.Expected_ARR__c = opp.Quote_ARR__c + opp.CC_Products_ARR_Sum__c; 

                if(opp.Is_Primary_SO_Signed__c) {//quote is won? (the product_arr__c will hold cc claim if exists)
                    opp.Claimed_ARR__c = opp.Product_ARR__c; 
                }
            }
             else if((opp.CC_Products_ARR_Sum__c!=oldOpps.get(opp.Id).CC_Products_ARR_Sum__c) && opp.Billing_Ids__c==null){//dosn't have quote and is by new cc claim infra (w/o billing ids)
                opp.Claimed_ARR__c = opp.CC_Products_ARR_Sum__c;
                opp.Expected_ARR__c = opp.CC_Products_ARR_Sum__c;
            }
        }
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
                //No payments or Quote - Forecast by GB ARR
                if(opp.SyncedQuoteId==null && opp.CC_Products_Full_ARR_Sum__c==0){
                    totalDealARR=contractaRR+opp.Green_Bucket_ARR_V2__c;
                }
                //Get Renewal ARR By the quote only (can be or quote or cc payments for renewal)
                if(opp.SyncedQuoteId!=null){
                    totalDealARR=opp.Total_License_ARR__c;
                }
                //Dont have quote - check cc claim
                if (opp.CC_Products_Full_ARR_Sum__c>0) {
                    totalDealARR=opp.CC_Products_Full_ARR_Sum__c;
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