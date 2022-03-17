public class LMS_AssignmentHandler  {
    public static Map <Id, LMS_Assignment__c> OldMap = new Map <Id, LMS_Assignment__c>();
    public static String event = null;
    public Static List<Certification_Contact_Field_Mapping__mdt> listContact_mdt = new List<Certification_Contact_Field_Mapping__mdt>();
    public Static Map <Id, contact> contacts4Update = new Map <Id, contact>();


    public static void GenData (List <LMS_Assignment__c> LList){

    }

    public static void HandleBefore (List <LMS_Assignment__c> LList, Map <Id, LMS_Assignment__c> oldTriggerMap, String evt){
        if (oldTriggerMap != null) OldMap = oldTriggerMap;
        if (evt != null) event = evt;


        GenData(LList);
    }

    public static void GenDataAfter (List <LMS_Assignment__c> LList){
        if(listContact_mdt.isEmpty()) {
            listContact_mdt = Certification_Contact_Field_Mapping__mdt.getall().values();//[SELECT Id, Resource_Name__c, Checkbox_Field__c, Date_Field__c from Certification_Contact_Field_Mapping__mdt];
        }
    }

    public static void updateContact(LMS_Assignment__c l){
        for(Certification_Contact_Field_Mapping__mdt lF : listContact_mdt){
            String resourceName = ';' + lF.Resource_Name__c + ';';
            if(resourceName.containsIgnoreCase((';' + l.Resource_Name__c + ';'))){
                System.debug('Rafa - we have a match');

                contact con = new Contact(Id = l.Contact__c);
                if (contacts4Update.containsKey(con.Id)) con = contacts4Update.get(con.Id);
                con.put(lF.Checkbox_Field__c, true);
                con.put(lF.Date_Field__c, l.Completed_At__c);

                System.debug('Rafa - con: ' + con);
                contacts4Update.put(con.Id, con);
            }
        }
        
    }

    public static Boolean updateContactREQ(LMS_Assignment__c l){
        Boolean b = false;
        if((event == 'Insert' && l.Status__c == 'Completed') || (event == 'Update' && l.Status__c == 'Completed' && OldMap.get(l.Id).Status__c != 'Completed')) b = true;
        if(l.Contact__c == Null) b = false;
        if(l.Resource_Name__c == Null) b = false;

        System.debug('Rafa - b: ' + b);
        return b;
    }

    public static void updateContact(List <LMS_Assignment__c> LList){
        for (LMS_Assignment__c l: LList) if (updateContactREQ(l)) updateContact(l);
    }

    public static void HandleAfter (List <LMS_Assignment__c> LList){
        System.debug('Rafa - Handler fired');
        GenDataAfter(LList);
        updateContact(LList);

        System.debug('Rafa -  contacts4Update.size: ' + contacts4Update.size());
        if(contacts4Update.size() > 0) update contacts4Update.values();
    }
}