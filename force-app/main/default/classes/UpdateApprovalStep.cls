public class UpdateApprovalStep {

    public class FlowInputs {
        @InvocableVariable(label='workItemId' description='The work item of an approval prcoess' required=true)        
        public Id workItmId;

        @InvocableVariable(label='isApproved' description='The approval indication' required=true)        
        public Boolean isApproved=false;

    }
    
    @InvocableMethod
    public static void UpdateApprovalSetToApprove(List<FlowInputs> flowInputs) {
        Id workItmId = flowInputs[0].workItmId;
        Boolean isApproved = flowInputs[0].isApproved;
        //Class used for Approving Record
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        
        if (isApproved) {
            req.setAction('Approve');  
        }
        else {
            req.setAction('Reject');  
        }
        ProcessInstanceWorkitem wItm = [Select Id from ProcessInstanceWorkitem WHERE Id =:workItmId];
        req.setWorkitemId(wItm.Id);
        // Submit the request for approval
        Approval.ProcessResult result = Approval.process(req);
        }       
    }