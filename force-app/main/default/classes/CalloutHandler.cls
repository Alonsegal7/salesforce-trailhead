public class CalloutHandler 
{
    public static map <string,BigBrain_Callout_Control__mdt> ObjectControls = new map <string,BigBrain_Callout_Control__mdt>();
    
    public static list <sobject> so4CalloutDelete = new list <sobject>();
    public static list <sobject> so4calloutUpdate = new list <sobject>();
    
    public static void GenObjectControl()
    {
        ObjectControls.clear();
        list <BigBrain_Callout_Control__mdt> Sett = [select id,DELETE__c,INSERT__c,UPDATE__c,Field_Set_Name__c,masterlabel from BigBrain_Callout_Control__mdt];
        for (BigBrain_Callout_Control__mdt md : Sett) ObjectControls.put (md.masterlabel.tolowercase(),md);
    }
    
    public static void HandleCallout (list <sobject> solist, string event, map <id,sobject> oldmap)
    {
        GenObjectControl();
        system.debug('TESTING HandleCallout called. event is '+event);
        system.debug('TESTING sobject list size is '+solist.size());

        for (sobject so : solist)
        {
            string sotype = string.valueof(so.getSObjectType());
            system.debug('TESTING sotype is '+sotype);
            BigBrain_Callout_Control__mdt mt = null;
            if (sotype!=null && ObjectControls.containsKey (sotype.tolowercase())){
              mt = ObjectControls.get (sotype.tolowercase());  
            } 
            
            system.debug('TESTING mt is '+mt);
            
            if (mt!=null && mt.INSERT__c && event=='Insert'){
                so4calloutUpdate.add (so); 
                system.debug('TESTING so added on INSERT');
            }
            
            if (mt!=null && mt.UPDATE__c && event=='Update' && mt.Field_Set_Name__c==null){
                so4calloutUpdate.add (so); 
                system.debug('TESTING so added on UPDATE, no field set check required');
            }
            
            if (mt!=null && mt.UPDATE__c && event=='Update' && mt.Field_Set_Name__c!=null && Oldmap!=null && Oldmap.containsKey (so.id) && UpdateCheckFieldSet (so,sotype,oldmap.get (so.id),mt)) {
                so4calloutUpdate.add (so); 
                system.debug('TESTING so added on UPDATE, passed field set check');
            }
            
            if (mt!=null && mt.DELETE__c && event=='Delete'){ 
                so4CalloutDelete.add (so); 
                system.debug('TESTING so added on DELETE');
            }
            
        }
        system.debug('TESTING so4CalloutDelete is '+so4CalloutDelete);
        system.debug('TESTING so4calloutUpdate is '+so4calloutUpdate);
        
        if (so4CalloutDelete.size()>0&&!System.isFuture()){ Callout.callDelete (so4CalloutDelete); if (!test.isrunningtest()) so4CalloutDelete.clear();}
        if (so4calloutUpdate.size()>0&&!System.isFuture()){ Callout.CallUpdate (so4calloutUpdate); if (!test.isrunningtest()) so4calloutUpdate.clear();}
    }
    
    public static boolean UpdateCheckFieldSet (sobject so,string sotype, sobject oldso, BigBrain_Callout_Control__mdt mt)
    {
        boolean b = false;
        system.debug('TESTING UpdateCHeckFieldSet fired.');
        system.debug('TESTING so is '+so);
        system.debug('TESTING oldso is '+oldso);
        system.debug('TESTING sotype is '+sotype);
        system.debug('TESTING mt is '+mt);
        if (so==null || sotype==null || oldso==null) return b;
        string fsname = null;
        if (mt!=null && mt.Field_Set_Name__c!=null) fsname = mt.Field_Set_Name__c;
        system.debug('TESTING fsname is '+fsname);
        
        Schema.FieldSet fs = null;
        if (fsname!=null && sotype.equalsignorecase('Account')) fs = Schema.SObjectType.Account.fieldSets.getMap().get(fsname);
        if (fsname!=null && sotype.equalsignorecase('Lead')) fs = Schema.SObjectType.Lead.fieldSets.getMap().get(fsname);
        if (fsname!=null && sotype.equalsignorecase('Contact')) fs = Schema.SObjectType.Contact.fieldSets.getMap().get(fsname);
        if (fsname!=null && sotype.equalsignorecase('Opportunity')) fs = Schema.SObjectType.Opportunity.fieldSets.getMap().get(fsname);
        if (fsname!=null && sotype.equalsignorecase('Sale__c')) fs = Schema.SObjectType.Sale__c.fieldSets.getMap().get(fsname);
        if (fsname!=null && sotype.equalsignorecase('User')) fs = Schema.SObjectType.User.fieldSets.getMap().get(fsname);
        if (fsname!=null && sotype.equalsignorecase('Partner_Region__c')) fs = Schema.SObjectType.Partner_Region__c.fieldSets.getMap().get(fsname);
        if (fsname!=null && sotype.equalsignorecase('Quote')) fs = Schema.SObjectType.Quote.fieldSets.getMap().get(fsname);
        if (fsname!=null && sotype.equalsignorecase('QuoteLineItem')) fs = Schema.SObjectType.QuoteLineItem.fieldSets.getMap().get(fsname);
        if (fsname!=null && sotype.equalsignorecase('OpportunityLineItem')) fs = Schema.SObjectType.OpportunityLineItem.fieldSets.getMap().get(fsname);
        if (fsname!=null && sotype.equalsignorecase('Subscription__c')) fs = Schema.SObjectType.OpportunityLineItem.fieldSets.getMap().get(fsname);
        if (fsname!=null && sotype.equalsignorecase('Contract')) fs = Schema.SObjectType.Contract.fieldSets.getMap().get(fsname);
        if (fsname!=null && sotype.equalsignorecase('Contract_Event__c')) fs = Schema.SObjectType.Contract_Event__c.fieldSets.getMap().get(fsname);

        system.debug('TESTING fs is '+fs);
        if (fs != null){
            for(Schema.FieldSetMember f : fs.getFields()){
              if (so.get(f.getFieldPath()) != oldso.get(f.getFieldPath())) { 
                  b = true; 
                  system.debug('TESTING field updated: ' + f.getFieldPath());
              }  
            } 
        }
        
        return b;
    }
}