@istest
public with sharing class Contract_Event_Daily_Update_Test {
    @istest
    public static void runTest() {
        DateTime dT = System.now();
        Date today = date.newinstance(dT.year(), dT.month(), dT.day());
        Date tommorow = date.newinstance(dT.year(), dT.month(), dT.day()+1);

        Account comp = TestObjectCreator.CreateCompany();
        insert comp;
        Account mondayAccount = TestObjectCreator.CreateMondayAccount(comp);
        Contract priorCon = TestObjectCreator.CreateContract(comp);
        priorCon.Status__c='Active';
        insert priorCon;
        mondayAccount.Active_Contract__c=priorCon.Id;
        mondayAccount.ParentId=comp.Id;
        mondayAccount.name='blabla';
        insert mondayAccount;
        Contract con = TestObjectCreator.CreateContract(comp);
        con.Prior_contract__c=priorCon.Id;
        con.Status__c='Future Activation';
        insert con;
        Contract_Product__c conProd = new Contract_Product__C (Contract__c=con.Id);
        insert conProd;

        Contract_Event__c todayCon = new Contract_Event__c(
            Contract_Product__c=conProd.Id,isrecurring__c=true,
            Contract__c=con.Id,Start_Date__c=today);
        Contract_Event__c futureCon = new Contract_Event__c(
            Contract_Product__c=conProd.Id,isrecurring__c=true,
            Contract__c=con.Id,Start_Date__c=tommorow);

        insert todayCon;
        insert futureCon;


        Test.startTest();
        Contract_Event_Daily_Update evdaily = new Contract_Event_Daily_Update();
        database.executeBatch(evdaily);
        Test.stopTest();

        Contract_Event__c getTodayEvent=[select id, Contract__c, Contract__r.Prior_Contract__c, calculate_arr__c from contract_event__c where start_date__c=:today];
        Contract_Event__c getFutureEvent=[select id, calculate_arr__c from contract_event__c where start_date__c=:tommorow];
        Contract getNewCon = [select id, status__c from contract where id =: getTodayEvent.Contract__c limit 1];
        Contract getPriorCon = [select id, status__c from contract where id =:  getTodayEvent.Contract__r.Prior_Contract__c limit 1];
        
        System.assertEquals(true,getTodayEvent.calculate_arr__c);
        System.assertEquals(false,getFutureEvent.calculate_arr__c);
        System.assertEquals('Deactivated',getPriorCon.Status__c);
        System.assertEquals('Active',getNewCon.Status__c);


    }
}