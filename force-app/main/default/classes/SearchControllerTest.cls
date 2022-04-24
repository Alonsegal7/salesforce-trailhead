@isTest
public with sharing class SearchControllerTest {

    @isTest
    public static void searchTest(){
        Account accuntRecord = createAccountRecord();
        List<String> fields = new List<String>();
        fields.add('Name');
        fields.add('Phone');
        fields.add('Rating');
        List<String> searchResultsIds = new List<String>();
        searchResultsIds.add(accuntRecord.Id);
        Test.startTest();
        Test.setFixedSearchResults(searchResultsIds);
        SearchController.search('Account', fields, 'Salesforce', '');
        Test.stopTest();
    }

    @isTest
    public static void searchTest1(){
        Account accuntRecord = createAccountRecord();
        List<String> fields = new List<String>();
        fields.add('Name');
        fields.add('Phone');
        fields.add('Rating');
        List<String> searchResultsIds = new List<String>();
        searchResultsIds.add(accuntRecord.Id);
        Test.startTest();
        Test.setFixedSearchResults(searchResultsIds);
        SearchController.search('Account', fields, '', '');
        Test.stopTest();
    }

    @isTest
    public static void getRecentlyCreatedRecordTest(){
        Account accuntRecord = createAccountRecord();
        List<String> fields = new List<String>();
        fields.add('Name');
        fields.add('Phone');
        fields.add('Rating');
        String accountId = accuntRecord.Id;
        Test.startTest();
        SObject account = SearchController.getRecentlyCreatedRecord( accountId , fields, 'Account');
        String fetchedAccountId = (String)account.get('Id');
        System.assertEquals( fetchedAccountId , accountId , 'Id is not matching' );
        Test.stopTest();
    }

    private static Account createAccountRecord(){
        Account acc = new Account();
        acc.Name = 'Salesforce.com';
        acc.Rating = 'Hot';
        acc.Industry = 'Technology';
        acc.Description = 'This is a test account';
        acc.BillingCity = 'San Francisco';
        acc.BillingState = 'California';
        acc.BillingPostalCode = '94105';
        acc.BillingCountry = 'United States';
        acc.Phone = '4158889999';
        acc.Type = 'Customer';
        insert acc;
        return acc;
    }
}