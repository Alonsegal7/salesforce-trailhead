/*************************************************************************
    * Created by: anastasiyakovalchuk
    * Created date: 11 March 2020
    * Description: 
    * History:
************************************************************************/

@IsTest
private with sharing class ContentDocumentLinkTriggerHandlerTest {

    @IsTest
    static void test() {
        Account testAccount = new Account(
                Name = 'Test'
        );
        insert testAccount;

        ContentVersion testContentVersion = new ContentVersion(
                Title = 'Test',
                VersionData = Blob.valueOf('Test'),
                PathOnClient = 'Test.txt'
        );
        insert testContentVersion;

        testContentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :testContentVersion.Id LIMIT 1];
        ContentDocumentLink testContentDocumentLink = new ContentDocumentLink(
                ContentDocumentId = testContentVersion.ContentDocumentId,
                LinkedEntityId = testAccount.Id,
                ShareType = 'I'
        );
        insert testContentDocumentLink;
    }
}