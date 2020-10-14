/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class AutoLeadConverter {
    global AutoLeadConverter() {

    }
    @InvocableMethod(label='Auto Convert Leads' description='Auto Convert Leads based on the AutoLeadConverter custom settings: status~find account 0/1~find contact 0/1~ownerid/space~create oppty 0/1')
    global static void AutoConvert(List<Id> leads) {

    }
global class ConvertLeadActionRequest {
    @InvocableVariable( required=false)
    global String convertedStatus;
    @InvocableVariable( required=false)
    global Boolean createOpportunity;
    @InvocableVariable( required=false)
    global Boolean findAccountByLeadsCompnayName;
    @InvocableVariable( required=false)
    global Boolean findContactByLeadsEmail;
    @InvocableVariable( required=true)
    global Id leadId;
    @InvocableVariable( required=false)
    global String opportunityName;
    @InvocableVariable( required=false)
    global Id ownerId;
    @InvocableVariable( required=false)
    global Boolean sendEmailToOwner;
    global ConvertLeadActionRequest() {

    }
}
global class ConvertLeadActionResult {
    @InvocableVariable( required=false)
    global Id accountId;
    @InvocableVariable( required=false)
    global Id contactId;
    @InvocableVariable( required=false)
    global Id opportunityId;
    global ConvertLeadActionResult() {

    }
}
}
