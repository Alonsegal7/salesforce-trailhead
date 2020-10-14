@isTest(SeeAllData=true)
public class RHX_TEST_Task {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM Task LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Task()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}