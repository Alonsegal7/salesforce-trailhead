@isTest
public without sharing class Partner_PaymentRequestServiceTest {
    @TestSetup
    static void makeData(){
        //create commission model
        Commission_Model__c commissionModel = new Commission_Model__c(Partner_Tier__c = 'Platinum', Name = 'test', Outbound_Percent__c = 30, Inbound_Percent__c	= 20, Is_Active__c = true, Commission_Type__c = 'One Time', Effective_Start_Date__c = Date.today());
        insert commissionModel;

        User partnerUser = TestObjectCreator.createValidPartnerUser();
        Id partnerCompanyId = [select Id, Contact.AccountId, ManagerId from User where Id =: partnerUser.Id].Contact.AccountId;

        //create partner commission model
        Partner_Commission_Model__c pcm = new Partner_Commission_Model__c(Commission_Model__c = commissionModel.Id, Partner_Company__c = partnerCompanyId, Start_Date__c = Datetime.now());
        insert pcm;

        Commission_Report__c report = new Commission_Report__c(
            name = 'test',
            Big_Brain_Id__c = '12',
            Date__c = Date.today().addMonths(1),
            Is_Available_For_Payment_Request__c = true
        );
        insert report;
        Commission_Collection__c collection1 = new Commission_Collection__c(
            Name = 'test',
            Pulse_Account_Id__c = '12345',
            Commitment_Big_Brain_Id__c = '879',
            Report_Id__c = '12',
            Partner_Company__c = partnerCompanyId,
            Plan_Period__c = 'monthly',
            Commission_Amount_USD__c = 100
        );
        Commission_Collection__c collection2 = new Commission_Collection__c(
            Name = 'test',
            Pulse_Account_Id__c = '12345',
            Commitment_Big_Brain_Id__c = '879',
            Report_Id__c = '12',
            Partner_Company__c = partnerCompanyId,
            Plan_Period__c = 'yearly',
            Commission_Amount_USD__c = 100
        );
        Commission_Collection__c collection3 = new Commission_Collection__c(
            Name = 'test',
            Pulse_Account_Id__c = '12345',
            Commitment_Big_Brain_Id__c = '879',
            Report_Id__c = '12',
            Partner_Company__c = partnerCompanyId,
            Plan_Period__c = 'two_yearly',
            Commission_Amount_USD__c = 100
        );
        List<Commission_Collection__c> colList = new List<Commission_Collection__c>();
        colList.add(collection1);
        colList.add(collection2);
        colList.add(collection3);
        insert colList; 
    }
    static testmethod void getAllPaymentRequests(){
        Id partnerCompanyId = [select Partner_Company__c from Partner_Commission_Model__c limit 1].Partner_Company__c;
        User partnerUser = [select Id, Contact.AccountId, ManagerId from User where Contact.AccountId =: partnerCompanyId limit 1];
 
        Payment_Request__c pr1 = new Payment_Request__c(
            Month__c = Date.today().toStartOfMonth(), 
            Channel_Partner__c = partnerUser.Contact.AccountId, 
            CPM__c = partnerUser.ManagerId, 
            Monthly_Commission_Amount__c = 100, 
            Yearly_Commission_Amount__c = 200, 
            Two_Yearly_Commission_Amount__c = 300,
            MDF_Amount__c = 100,
            Spiff_Amount__c = 50,
            Status__c = 'Draft',
            CurrencyIsoCode = 'USD'
        );
        Payment_Request__c pr2 = new Payment_Request__c(
            Month__c = Date.today().toStartOfMonth(), 
            Channel_Partner__c = partnerUser.Contact.AccountId, 
            CPM__c = partnerUser.ManagerId, 
            Monthly_Commission_Amount__c = 100, 
            Yearly_Commission_Amount__c = 200, 
            Two_Yearly_Commission_Amount__c = 300,
            MDF_Amount__c = 100,
            Spiff_Amount__c = 50,
            Status__c = 'Rejected',
            CurrencyIsoCode = 'USD'
        );
        Payment_Request__c pr3 = new Payment_Request__c(
            Month__c = Date.today().toStartOfMonth(), 
            Channel_Partner__c = partnerUser.Contact.AccountId, 
            CPM__c = partnerUser.ManagerId, 
            Monthly_Commission_Amount__c = 100, 
            Yearly_Commission_Amount__c = 200, 
            Two_Yearly_Commission_Amount__c = 300,
            MDF_Amount__c = 100,
            Spiff_Amount__c = 50,
            Status__c = 'Paid',
            CurrencyIsoCode = 'USD'
        );
        Payment_Request__c pr4 = new Payment_Request__c(
            Month__c = Date.today().toStartOfMonth(), 
            Channel_Partner__c = partnerUser.Contact.AccountId, 
            CPM__c = partnerUser.ManagerId, 
            Monthly_Commission_Amount__c = 100, 
            Yearly_Commission_Amount__c = 200, 
            Two_Yearly_Commission_Amount__c = 300,
            MDF_Amount__c = 100,
            Spiff_Amount__c = 50,
            Status__c = 'Pending CPM Review',
            CurrencyIsoCode = 'USD'
        );
        List<Payment_Request__c> prList = new List<Payment_Request__c>();
        prList.add(pr1);
        prList.add(pr2);
        prList.add(pr3);
        prList.add(pr4);
        Partner_Marketing_Activity__c pma = new Partner_Marketing_Activity__c(
            Name = 'Test',
            Channel_Partner__c = partnerUser.Contact.AccountId,
            Activity_Date__c = Date.today().addMonths(-1),
            MDF_Requested_Amount__c = 1000
        );
        insert pma;
        pma.CPM_Approval_Status__c = 'Approved';
        update pma;
        system.runAs(partnerUser){
            Test.startTest();
            insert prList;
            Partner_PaymentRequestService.getAllPaymentRequests();
            Partner_PaymentRequestService.getMonthsPicklist();
            User u = Partner_PaymentRequestService.getCurrUser();
            Partner_PaymentRequestService.getData(Date.today().addMonths(1).toStartOfMonth(), null, u);
            Partner_PaymentRequestService.deleteOldFiles(prList.get(0).Id);
            Partner_PaymentRequestService.updatePaymentRequest(prList.get(0).Id, //Id paymentRequestId
                                                                300, //Decimal mdfAmount
                                                                new List<Id>{pma.Id}, //List<Id> selectedMDFs
                                                                200, //Decimal spiffAmount
                                                                null, //Id invoiceFileVerId
                                                                null, //Id spiffId
                                                                'USD', //String invoiceCurrency
                                                                '1000', //String invoiceNumber
                                                                Date.today()); //Date invoiceDate
            Partner_PaymentRequestService.submitForApproval(prList.get(0).Id, //Id paymentRequestId
                                                            300, //Decimal mdfAmount
                                                            null, //List<Id> selectedMDFs
                                                            200, //Decimal spiffAmount
                                                            null, //Id spiffId
                                                            null, //Id invoiceFileVerId
                                                            'USD', //String invoiceCurrency
                                                            '1000', //String invoiceNumber
                                                            Date.today()); //Date invoiceDate
            Partner_PaymentRequestService.getFilesScreenData(partnerUser.Contact.AccountId, prList.get(0).Id, Date.today());
            Test.stopTest();
        }
    }

    static testmethod void test_scheduledPortions(){
        Test.startTest();
        MdfPortions_ScheduledAvailableByDate p = new MdfPortions_ScheduledAvailableByDate();
        String sch = '0 0 * * * ?';
        system.schedule('Test_MdfPortions_ScheduledAvailableByDate', sch, p);
        Test.stopTest();
    }
}