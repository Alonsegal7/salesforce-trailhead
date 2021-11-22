public without sharing class approvalButtonsController {
    @AuraEnabled(cacheable=true)
    public static string checkApproval(Id recordId){
        Id myUserId = UserInfo.getUserId();
        String res = '';
        try {
            List<ProcessInstance> pendingApproverLst = [select id, targetobjectid, (SELECT Id, ActorId, StepStatus, ProcessInstanceId FROM StepsAndWorkitems) from ProcessInstance where targetobjectid =: recordId];
            for(ProcessInstance p: pendingApproverLst){
                for(ProcessInstanceHistory h: p.StepsAndWorkitems){
                    if(h.StepStatus == 'Pending'){
                        if(myUserId == h.ActorId) {
                            res = h.Id;
                            break;
                        }
                    }
                }
            }
            return res;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static string approveOrRejectRecord(Id approvalProcessId, String action, String comments){
        try {
            Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
            req2.setAction(action);            
            req2.setWorkitemId(approvalProcessId);
            if(comments != null) req2.setComments(comments);
            Approval.ProcessResult result2 =  Approval.process(req2);
            return 'success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
}