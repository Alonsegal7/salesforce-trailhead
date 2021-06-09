@istest
public with sharing class  UpdateApprovalStep_Test {

    @isTest
    public static void TestUpdateApprovers() {

        Account acc = new Account() ; 
        acc.Name = 'Test' ;
        insert acc ; 

        PriceBook2 pb = New PriceBook2(Id = test.getStandardPricebookId(), isActive = true);
        update pb;

        Opportunity opp = new Opportunity() ; 
        opp.Name = 'Test' ;
        opp.StageName = 'Test' ;
        opp.CloseDate = system.today() ; 
        opp.Pricebook2Id = pb.Id;
        insert opp;

        Quote q = new Quote();
        q.Name = 'Test';
        q.OpportunityId = opp.Id;
        q.Pricebook2Id = pb.Id;
        insert q; 
        User user1 = [SELECT Id FROM User WHERE Alias='asega'];
        
        // Create an approval request for the account
        Approval.ProcessSubmitRequest req1 =
        new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(q.id);

        // Submit on behalf of a specific submitter
        req1.setSubmitterId(user1.Id);

        // Submit the record to specific process and skip the criteria evaluation
        req1.setProcessDefinitionNameOrId('Finance_approval_to_signed_SO');
        req1.setSkipEntryCriteria(true);
            
        // Submit the approval request for the quote
        Approval.ProcessResult result = Approval.process(req1);

        // Get the ID of the newly created item
        List<Id> newWorkItemIds = result.getNewWorkitemIds();


        UpdateApprovalStep.FlowInputs inpts = new UpdateApprovalStep.FlowInputs();
        inpts.isApproved=true;
        inpts.workItmId=newWorkItemIds.get(0);

        
        Test.startTest();
        UpdateApprovalStep.UpdateApprovalSetToApprove(new List<UpdateApprovalStep.FlowInputs>{inpts});
        Test.stopTest();
        }
}