@istest
public without sharing class LeadContextComponentHelper_Test {

    @isTest
    static void getUserIdTest(){
        Test.startTest();
        User testUser = new User(
            FirstName = 'User T1',
            LastName = 'ACME',
            Email = 'usert1@acme.com',
            ProfileId = UserInfo.getProfileId(),
            IsActive = true,
            Username = 'usert1@acme.com',
            Alias = 'UACME',
            Country = 'Israel',
            LanguageLocaleKey = UserInfo.getLanguage(),
            LocaleSidKey = UserInfo.getLocale(),
            EmailEncodingKey = 'UTF-8',
            TimeZoneSidKey = 'America/Argentina/Buenos_Aires',
            CurrencyIsoCode = 'USD'
        );

        insert testUser;
        
        //The test user dont have name beacuse we cant set a name this is why the expected result is empty list
        System.assertEquals(LeadContextComponentHelper.getUserId(testUser.Name).isEmpty(), true);
        Test.stopTest();
    }
}
