public without sharing class Lead_ComapnyCreation {
    public static void Lead_ComapnyCreation(List<Lead> newLeads, map<Id, Lead> oldLeads) {
        try{
            map<string,lead> leadByDomain= new map<string,lead>();
            //if (oldLeads==null){
                for(Lead lead: newLeads){
                    string leadDomain=lead.email.split('@').get(1);
                    leadByDomain.put(leadDomain,lead);
                }
            /*}else{
                return;
            }*/
            map<string,id> relevantCompByDomain= new map<string,id>();
            for (Company_Domain__c cd: [select id,Domain__c,Company__c from Company_Domain__c where Domain__c in: leadByDomain.keySet()])
                relevantCompByDomain.put(cd.Domain__c,cd.Company__c);
            list<Account> compsToCreate = new list<Account>();
            for(Lead lead: newLeads){
                string leadDomain=lead.email.split('@').get(1);
                if(relevantCompByDomain.containsKey(leadDomain)){//connect to existing company
                    lead.Related_Company__c=relevantCompByDomain.get(leadDomain);
                }else{//create new comapny
                    compsToCreate.add(new Account(RecordTypeId='0121t000000IQTiAAO',
                                                    Name=lead.Company,
                                                    Website=leadDomain,
                                                    Account_Domains__c=lead.Account_Domains__c,
                                                    NumberOfEmployees=Lead.NumberOfEmployees));
                }
            }
            if(!compsToCreate.isEmpty()){
                Database.SaveResult[] srList = Database.insert(compsToCreate);
                integer i=0;
                for (Database.SaveResult sr : srList) {
                    lead matchingLead=leadByDomain.get(compsToCreate[i].Website);
                    if (sr.isSuccess())
                        matchingLead.Related_Company__c=compsToCreate[i].id;//connect newly create company to lead
                    i++;
                }
            }
        }catch(Exception e){
            Utilities.sendDebugEmail('Error in Lead_ComapnyCreation ',e,e.getMessage());   
        }

    }
}