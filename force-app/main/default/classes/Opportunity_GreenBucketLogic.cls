public without sharing class Opportunity_GreenBucketLogic {
    public static Id internalRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Internal_Opportunity').getRecordTypeId();
    public static Id partnerRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Partner_Opportunity').getRecordTypeId();
    public static Id currentRecordId=null;
    public static void Opportunity_GreenBucketLogic(List<Opportunity> newOpps, map<Id, Opportunity> oldOpps) {
        try{
            List<Opportunity> relevantOpps= new list<Opportunity>();
            for(Opportunity opp: newOpps){
                if(opp.isClosed==false||
                    inTimeFrame(opp.CloseDate)||
                    (opp.Manual_Trigger__c!=oldOpps.get(opp.Id).Manual_Trigger__c&&opp.Manual_Trigger__c=='Recalculate GB')||
                    opp.Potential_GB_Opp_Override__c!=oldOpps.get(opp.Id).Potential_GB_Opp_Override__c){
                    relevantOpps.add(opp);
                }
            }
            map<Id,GB_Threshold__c> allTHs=Utilities.getAllTHs();//use static method to avoid soql limits
            for(Opportunity opp: relevantOpps){ 
                system.debug('OGBL Raz Ben Ron - opp in Gb logic: '+Opp.Name+' '+Opp.Id);
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
                if(opp.Manual_Trigger__c=='Recalculate GB')
                    opp.Manual_Trigger__c='';
                //opp.Green_Bucket_Override_Reason__c=string.valueof(datetime.now());
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
            if(opp.Expected_Plan_Name__c!=null&&opp.Pricing_Version__c!=null&&
                opp.Expected_Plan_Seats__c!=null&&opp.Expected_Plan_Tier__c!=null&&
                opp.Expected_Plan_Period__c!=null){
                boolean newPVs=opp.Pricing_Version__c=='6'||opp.Pricing_Version__c=='8'||opp.Pricing_Version__c=='9';
                system.debug('Raz Ben Ron OGBL Opp details: newPVs: '+newPVs+' Plan: '+opp.Expected_Plan_Seats__c+' '+opp.Expected_Plan_Tier__c+' '+opp.Expected_Plan_Period__c);
                if(opp.RecordTypeId==internalRecordTypeId){
                    gbPlan=(opp.Expected_Plan_Seats__c>=50||
                                (newPVs&&opp.Expected_Plan_Tier__c.toLowercase()=='enterprise'&&opp.Expected_Plan_Seats__c>=20)||
                                (!newPVs&&opp.Expected_Plan_Tier__c.toLowercase()=='enterprise'&&opp.Expected_Plan_Seats__c>=25));
                }
                ///The condition was cancelled for Partners 09/05/21
                /*else if(opp.RecordTypeId==partnerRecordTypeId){ 
                    gbPlan=opp.Expected_Plan_Seats__c>=50;
                }*/
            }
            system.debug('Raz Ben Ron OGBL gbPlan: '+gbPlan);
        }catch(Exception e){
            Utilities.sendDebugEmail('Error in Opportunity_GreenBucketLogic ',e,e.getMessage());   

        }
        return gbPlan;
    }

    //Is Opportunity Ready for Calculation
    public static boolean isValidOpp(Opportunity opp,GB_Threshold__c gbth){
        string oppType=opp.Type==null?'':opp.Type;
        boolean isValid=(gbth!=null&&
                        !oppType.contains('Downgrade')&&
                        !(opp.Expected_Plan_Period__c!=null&&
                            opp.RecordTypeId==internalRecordTypeId&&opp.Expected_Plan_Period__c.toLowercase()=='monthly'));
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

    public static boolean inTimeFrame(Date closeDate){
        date today=date.today();
        system.debug('Raz Ben Ron close date: '+closeDate.month()+' '+closeDate.year());
        system.debug('Raz Ben Ron today: '+today.month()+' '+today.year()+' last month: '+today.addMonths(-1).month());
        if((today.month()==closeDate.month()&&//close date on current month
            today.year()==closeDate.year())||
            (today.day()>=1&&today.day()<=10&&//last month is stil editable in first 10 days of the month
            today.addMonths(-1).month()==closeDate.month())||
            today<=closeDate){//close date in the future
            return true;
        }else{
            return false;
        }

    }
}