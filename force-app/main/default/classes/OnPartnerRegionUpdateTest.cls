@isTest
public class OnPartnerRegionUpdateTest {
	static testMethod void testPartnerRegion() {
       Test.startTest();
       TestObjectCreator.persistImmediate = true;
        
       Account company = TestObjectCreator.CreateCompany();
       Partner_Country_Quota__c pcq = new Partner_Country_Quota__c(Name='Country Quota', Country_Daily_Quota__c=100);
       insert pcq;
       Partner_Region__c c = new Partner_Region__c(Name='Region', Partner_Company__c=company.Id,Partner_Country_Quota__c=pcq.Id);
       insert c;
        
       Test.stopTest();
	}
}