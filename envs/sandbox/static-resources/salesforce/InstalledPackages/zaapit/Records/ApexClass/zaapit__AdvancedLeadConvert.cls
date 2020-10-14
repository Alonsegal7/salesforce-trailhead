/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class AdvancedLeadConvert {
    global AdvancedLeadConvert() {

    }
    @InvocableMethod(label='Advanced Lead Convert ' description='Auto Convert Leads - Advanced')
    global static List<zaapit.AdvancedLeadConvert.ConvertLeadActionResult> AdvancedAutoConvert(List<zaapit.AdvancedLeadConvert.ConvertLeadActionRequest> requests) {
        return null;
    }
global class ConvertLeadActionRequest {
    @InvocableVariable( required=false)
    global String accountCompanyFieldToFind;
    @InvocableVariable( required=false)
    global String convertedStatus;
    @InvocableVariable( required=false)
    global Boolean convertOnlyWhenAMatchingAccountWasFound;
    @InvocableVariable( required=false)
    global Boolean convertOnlyWhenAMatchingContactWasFound;
    @InvocableVariable( required=false)
    global Boolean createOpportunity;
    @InvocableVariable( required=false)
    global Boolean findAccount;
    @InvocableVariable( required=false)
    global Boolean findContactByLeadsEmail;
    @InvocableVariable( required=false)
    global String leadCompanyFieldFind;
    @InvocableVariable( required=true)
    global Id leadId;
    @InvocableVariable( required=false)
    global String opportunityName;
    @InvocableVariable( required=false)
    global Boolean overwriteContactLeadSourceWhenExist;
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
