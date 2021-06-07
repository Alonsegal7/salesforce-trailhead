public with sharing class DealRegistration_RegionMapping {
    public static Map<String, Country_Region_Mapping__c> regionsMapping = null;

    public static void leadReg_MapRegions(List<Deal_Registration__c > newLeadRegs, Map<Id, Deal_Registration__c> oldLeadRegs) {
        try{
            regionsMapping = getRegionMapping(newLeadRegs);
            List<Deal_Registration__c> leadRegToCheck = new List<Deal_Registration__c>();
            for(Deal_Registration__c lReg : newLeadRegs){
                String region='';
                
                if(oldLeadRegs == null || (lReg.Manual_Trigger__c != oldLeadRegs.get(lReg.Id).Manual_Trigger__c && lReg.Manual_Trigger__c == 'Match Regions')){
                    if(regionsMapping.containskey(lReg.Company_Location__c)){
                        region = regionsMapping.get(lReg.Company_Location__c).Region__c;
                    }
                    
                    else{
                        region='';
                    }

                    lReg.Region__c = region;
                    
                    if(lReg.Manual_Trigger__c == 'Match Regions'){
                        lReg.Manual_Trigger__c = '';
                    }
                }
                leadRegToCheck.add(lReg);
            }

            if(oldLeadRegs == null){
                DealRegistration_SearchLogic.validateDealRegistration(leadRegToCheck);
            }
        }catch(Exception e){
            Utilities.sendDebugEmail('Error in Lead_MapRegions ', e, e.getMessage());   
        }
    }

    public static Map<String, Country_Region_Mapping__c> getRegionMapping(List<Deal_Registration__c> newLeadRegs){
        List<String> leadRegCountry = new List<String>();

        if(regionsMapping == null){
            regionsMapping = new Map<String,Country_Region_Mapping__c>();
            for(Deal_Registration__c lReg : newLeadRegs){
                leadRegCountry.add(lReg.Company_Location__c);
            }
            
            if(leadRegCountry != null){
                for(Country_Region_Mapping__c rm : [SELECT Id, Name, Region__c, Country_Name__c FROM Country_Region_Mapping__c WHERE Country_Name__c IN: leadRegCountry LIMIT 1]){
                    regionsMapping.put(rm.Country_Name__c, rm);
                }
            }
        }
        return regionsMapping;
    }

}