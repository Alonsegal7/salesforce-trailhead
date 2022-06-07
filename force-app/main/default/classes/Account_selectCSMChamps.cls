public without sharing class Account_selectCSMChamps {

    //use this wrapper to return options for that require label and value. f.e lightning-combobox
    private class optionWrapper{
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;

        public optionWrapper(String label, String value){
			this.label = label;
            this.value = value;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getAllContacts(Id accountId){
        try {
            Map<String,Object> res = new Map<String,Object>();
            list<AccountContactRelation> acrs = [select Id, ContactId, Contact.CSM_Champion__c, Contact.FirstName, Contact.LastName from AccountContactRelation where AccountId =: accountId];
            set<Id> selected_champs = new set<Id>();
            list<optionWrapper> contacts_options = new list<optionWrapper>();
            for(AccountContactRelation acr: acrs){
                if(acr.Contact.CSM_Champion__c){
                    selected_champs.add(acr.ContactId);
                } 
                contacts_options.add(new optionWrapper(acr.Contact.FirstName + ' ' + acr.Contact.LastName, acr.ContactId));
            }
            res.put('contacts_options', contacts_options);
            res.put('selected_champs', selected_champs);
            return res;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static string saveContacts(Map<String,List<Id>> contacts_map){
        try {
            Set<Id> originally_selected = contacts_map.get('originally_selected') != null ? new Set<Id>(contacts_map.get('originally_selected')) : new Set<Id>();
            Set<Id> currently_selected = contacts_map.get('currently_selected') != null ? new Set<Id>(contacts_map.get('currently_selected')) : new Set<Id>();
            List<Contact> consToUpdate = new List<Contact>();

            for(Id currently_selected_Id: currently_selected){
                if(!originally_selected.contains(currently_selected_Id)){ //newely selected champs
                    consToUpdate.add(new Contact(
                        Id = currently_selected_Id,
                        CSM_Champion__c = true
                    ));
                }
            }
            for(Id originally_selected_Id: originally_selected){ //removed selections
                if(!currently_selected.contains(originally_selected_Id)){
                    consToUpdate.add(new Contact(
                        Id = originally_selected_Id,
                        CSM_Champion__c = false
                    ));
                }
            }
            Database.update(consToUpdate);
            return 'success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + e.getStackTraceString());
        }
    }
}
