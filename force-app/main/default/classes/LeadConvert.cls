public class LeadConvert {
	public static void handle(Lead lead){
        List<SObject> recordsToUpdate = new List<SObject>();

        if(lead.ConvertedAccountId != null){
            recordsToUpdate.add(new Account(Id=lead.ConvertedAccountId, ParentId=lead.Related_Company__c));

            if(lead.ConvertedOpportunityId != null){
                recordsToUpdate.add(new Opportunity(Id=lead.ConvertedOpportunityId, Company__c=lead.Related_Company__c, Monday_Account__c=lead.ConvertedAccountId, pulse_account_ids__c=lead.primary_pulse_account_id__c));
            }

            if(lead.ConvertedContactId != null){
                recordsToUpdate.add(new Contact(Id=lead.ConvertedContactId, Company__c=lead.Related_Company__c, Monday_Account__c=lead.ConvertedAccountId));
            }
        }

        if(recordsToUpdate.size() > 0){
            update recordsToUpdate;
        }
    }
}