@isTest(SeeAllData=true)
public class RHX_TEST_Relationship {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM Relationship__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Relationship__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}