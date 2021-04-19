public without sharing class Lead_MapRegions {
    public static void Lead_MapRegions(List<Lead> newLeads, map<Id, Lead> oldLead) {
        try{
            map<string,Country_Region_Mapping__c> regionsMapping=Utilities.getRegionMapping();
            for(Lead lead: newLeads){
                string region='';
                string subRegion='';
                //system.debug('Raz Ben Ron lead.CountryCode: '+lead.CountryCode);
                //system.debug('Raz Ben Ron oldLead.get(lead.Id).CountryCode: '+oldLead.get(lead.Id).CountryCode);
                if((oldLead==null||//new lead
                    (lead.Manual_Trigger__c!=oldLead.get(lead.Id).Manual_Trigger__c&&lead.Manual_Trigger__c=='Match Regions')||//manual
                    (oldLead!=null&&lead.CountryCode!=oldLead.get(lead.Id).CountryCode)||
                    lead.Region__c==null)&&//country change
                    lead.CountryCode!=null){
                    if(regionsMapping.containskey(lead.CountryCode)){
                        system.debug('Raz Ben Ron regionsMapping.get(lead.CountryCode): '+regionsMapping.get(lead.CountryCode));
                        region=regionsMapping.get(lead.CountryCode).Region__c;
                        //subRegion=regionsMapping.get(lead.CountryCode).Sub_Region__c;
                    }else{
                        region='';
                        subRegion='';
                    }
                    lead.Region__c=region;
                    //lead.Sub_Region__c=subRegion;
                    if(lead.Manual_Trigger__c=='Match Regions')lead.Manual_Trigger__c='';
                }
             }
        }catch(Exception e){
            Utilities.sendDebugEmail('Error in Lead_MapRegions ',e,e.getMessage());   
        }

    }
}