@isTest(SeeAllData=false)
public class User_SnapshotTest {
    static testMethod void testScheduledLogic() {        

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

        Test.startTest();

        Database.executeBatch(new Opportunity_Snapshot());

        Test.stopTest();        
    }
}