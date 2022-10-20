@isTest
public with sharing class Quote_SyncToExternalTest {
    @TestSetup
    static void makeData(){
        Account comp = TestObjectCreator.CreateCompany();
        insert comp;
        Account ma = TestObjectCreator.CreateMondayAccount(comp);
        insert ma;
        //create opp that is synced to the external board (monday_External_Item__c <> null)
        Opportunity oppSyncedToExternal = TestObjectCreator.CreateOpp(ma);
        oppSyncedToExternal.monday_External_Item__c = 'link';
        insert oppSyncedToExternal;
        //create quote and sync it to the opp
        Quote syncedQuote = TestObjectCreator.CreateNonContractQuote(oppSyncedToExternal,'New Contract'); 
        insert syncedQuote;
        oppSyncedToExternal.syncedQuoteId = syncedQuote.Id;
        update oppSyncedToExternal;

    }

    static testMethod void shouldSyncToExternal(){
        Quote quote = [SELECT id FROM Quote LIMIT 1];
        //test - activation indication changes to true 
        Test.startTest();
        quote.Activated_via_Import_SO__c = true; 
        update quote;
        Test.stopTest();
        Opportunity opp = [SELECT id,Sync_to_External_monday__c FROM Opportunity LIMIT 1];
        system.assertEquals(opp.Sync_to_External_monday__c, true); //sync to external indication in opp level was set to true

    }
    

    static testMethod void shouldNotSyncToExternalWhenLinkIsBlank(){
        //Set the link field as blank
        Opportunity opp = [SELECT id FROM Opportunity LIMIT 1];
        opp.monday_External_Item__c = '';
        update opp;
        Quote quote = [SELECT id FROM Quote LIMIT 1];
        //test - activation indication changes to true 
        Test.startTest();
        quote.Activated_via_Import_SO__c = true; 
        update quote;
        Test.stopTest();
        opp = [SELECT id,Sync_to_External_monday__c FROM Opportunity LIMIT 1];
        system.assertEquals(opp.Sync_to_External_monday__c, false); //sync to external indication in opp level remains false
    }

    static testMethod void shouldNotSyncToExternalWhenQuoteIsNotSyncing(){
        //un-sync the quote from the opp
        Opportunity opp = [SELECT id FROM Opportunity LIMIT 1];
        opp.syncedQuoteId = null;
        update opp;
        Quote quote = [SELECT id FROM Quote LIMIT 1];
        //test - activation indication changes to true
        Test.startTest();
        quote.Activated_via_Import_SO__c = true;
        update quote;
        Test.stopTest();
        opp = [SELECT id,Sync_to_External_monday__c FROM Opportunity LIMIT 1];
        system.assertEquals(opp.Sync_to_External_monday__c, false); //sync to external indication in opp level remains false
    }
}
