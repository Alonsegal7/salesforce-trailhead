@isTest(SeeAllData=true)
public class RHX_TEST_Subscription {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM Subscription__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Subscription__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}