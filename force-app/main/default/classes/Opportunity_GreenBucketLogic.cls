public without sharing class Opportunity_GreenBucketLogic {
    public static Id internalRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Internal_Opportunity').getRecordTypeId();
    public static Id partnerRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Partner_Opportunity').getRecordTypeId();
    public static Id currentRecordId=null;
    public static void Opportunity_GreenBucketLogic(List<Opportunity> newOpps, map<Id, Opportunity> oldOpps) {
        try{
            map<Id,GB_Threshold__c> allTHs=Utilities.getAllTHs();//use static method to avoid soql limits
            for(Opportunity opp: newOpps){ 
                boolean isGB=false;
                boolean isTransition=false;
                GB_Threshold__c gbth=null;
                currentRecordId=opp.Id;
                
                if(opp.GB_Threshold__c!=null)
                    gbth=allTHs.get(opp.GB_Threshold__c);

                system.debug('Raz Ben Ron OGBL in opp: '+opp.id);
                system.debug('Raz Ben Ron OGBL gbth: '+gbth);
                //Manual Override
                if(opp.Potential_GB_Opp_Override__c!=null){
                    if(opp.Potential_GB_Opp_Override__c=='Yes')
                        isGB=true;
                    else if(opp.Potential_GB_Opp_Override__c=='No')
                        isGB=false;

                //General Logic
                }else{
                    if(isValidOpp(opp,gbth)&&
                    (gbARR(opp)>=gbth.Min_ARR__c||opp.Is_Account_Green_Bucket_New__c||isGBPlanCalc(opp))){
                        isGB=true;
                        system.debug('Raz Ben Ron OGBL isGB: '+isGB);
                    }
                }
                if(!opp.Is_Account_Green_Bucket_New__c&&isGB&&opp.StageName!='Closed Lost')
                    isTransition=true;
                
                opp.Is_Potential_GB_Opportunity__c=isGB;
                opp.Transition_to_GB__c=isTransition;
                if(opp.Manual_Trigger__c!=null)
                    opp.Manual_Trigger__c='';
            }
        }catch(Exception e){
            Utilities.sendDebugEmail('Error in Opportunity_GreenBucketLogic ',e,e.getMessage());   
            //Utilities.sendSlackMessage(':fire: Error in GB Logic!! :fire:','test-raz',':moneybag:',e,null,null,currentRecordId);  
        }
    }
    //Is Green Bucket Plan
    public static Boolean isGBPlanCalc(Opportunity opp){
        Boolean gbPlan=false;
        try{
            boolean newPVs=opp.Pricing_Version__c=='6'||opp.Pricing_Version__c=='8'||opp.Pricing_Version__c=='9';
            system.debug('Raz Ben Ron OGBL Opp details: newPVs: '+newPVs+' Plan: '+opp.Expected_Plan_Seats__c+' '+opp.Expected_Plan_Tier__c+' '+opp.Expected_Plan_Period__c);
            if(opp.RecordTypeId==internalRecordTypeId){
                gbPlan=(opp.Expected_Plan_Seats__c>=50||
                            (newPVs&&opp.Expected_Plan_Tier__c.toLowercase()=='enterprise'&&opp.Expected_Plan_Seats__c>=20)||
                            (!newPVs&&opp.Expected_Plan_Tier__c.toLowercase()=='enterprise'&&opp.Expected_Plan_Seats__c>=25))&&
                            opp.Expected_Plan_Period__c.toLowercase()!='monthly';
            }else if(opp.RecordTypeId==partnerRecordTypeId){
                gbPlan=opp.Expected_Plan_Seats__c>=50;
            }
            system.debug('Raz Ben Ron OGBL gbPlan: '+gbPlan);
        }catch(Exception e){
            //Utilities.sendSlackMessage(':fire: Error in GB Logic (is gb plan)!! :fire:','test-raz',':moneybag:',e,null,null,currentRecordId);  
            Utilities.sendDebugEmail('Error in Opportunity_GreenBucketLogic ',e,e.getMessage());   

        }
        return gbPlan;
    }

    //Is Opportunity Ready for Calculation
    public static boolean isValidOpp(Opportunity opp,GB_Threshold__c gbth){
        string oppType=opp.Type==null?'':opp.Type;
        boolean isValid=(gbth!=null&&
                        opp.Expected_Plan_Name__c!=null&&
                        opp.Pricing_Version__c!=null&&
                        opp.Expected_Plan_Seats__c!=null&&
                        opp.Expected_Plan_Tier__c!=null&&
                        opp.Expected_Plan_Period__c!=null&&
                        !oppType.contains('Downgrade'));
        system.debug('Raz Ben Ron OGBL isValid opp: '+opp);
        system.debug('Raz Ben Ron OGBL isValid: '+isValid);
        return isValid;
    }

    public static Decimal gbARR(Opportunity opp){
        Decimal gbArr=opp.IsWon?opp.Claimed_ARR__c:opp.Expected_ARR__c;
        gbArr=gbArr==null?0:gbArr;
        Decimal maClaimedARR=opp.Monday_Account_ARR__c==null?0:opp.Monday_Account_ARR__c;
        system.debug('Raz Ben Ron OGBL gbArr: '+gbArr);
        if(!opp.Is_Account_Green_Bucket_New__c)
            gbArr+=maClaimedARR;
        system.debug('Raz Ben Ron OGBL gbArr: '+gbArr);
        return gbArr;
    }
}