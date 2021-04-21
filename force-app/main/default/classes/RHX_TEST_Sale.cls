@isTest(SeeAllData=true)
public class RHX_TEST_Sale {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM Sale__c order by createddate desc LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Sale__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}