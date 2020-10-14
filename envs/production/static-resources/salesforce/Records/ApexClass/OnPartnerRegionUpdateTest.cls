@isTest
public class OnPartnerRegionUpdateTest {
	static testMethod void testPartnerRegion() {
       Test.startTest();
       TestObjectCreator.persistImmediate = true;
        
       Account company = TestObjectCreator.CreateCompany();
       Partner_Region__c c = new Partner_Region__c(Name='region', Partner_Company__c=company.Id);
       insert c;
        
       Test.stopTest();
	}
}