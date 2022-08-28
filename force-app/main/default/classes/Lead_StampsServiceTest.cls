@isTest
public with sharing class Lead_StampsServiceTest {
    public static Profile profileId;
    public static User userRecord;
    @TestSetup
    static void makeData(){
        profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        userRecord = TestUtils.getUserWithoutRole(profileId);
        insert userRecord;
        //create companies - one with ARR > 0 and one with ARR = 0
        List<Account> comps = new List<Account>();
        comps.add(TestObjectCreator.CreateCompany());
        comps.get(0).ARR__c = 1000;
        comps.get(0).Name = 'test1';
        comps.get(0).Named_Account__c = true;
        comps.add(TestObjectCreator.CreateCompany());
        comps.get(1).ARR__c = 0;
        comps.get(1).Name = 'test2';
        insert comps;
        List<Lead> LeadsToInsert = new List<Lead>();

        LeadsToInsert.add(new Lead(
            Company='leadWithPhone',
            LastName='LastName',
            Email='test@test.com',
            Phone='12345678',
            LeadSource='Big Brain - Signup',
            visitor_id__c='123',
            Sub_source__c='Sign up', 
            Channel_Lead_Source__c = 'Outbound',
            OwnerId=userRecord.Id,
            Status='Attempting',
            SQL__c=true,
            Hubspot_Lifecycle_stage__c='marketingqualifiedlead'
        ));

        LeadsToInsert.add(new Lead(
            Company='leadWithOutPhone',
            LastName='LastName',
            Email='test@test.com',
            LeadSource='Big Brain - Signup',
            Status='Qualified',
            Reached_Out_To__c=true

        ));
        
        LeadsToInsert.add(new Lead(
            Company='leadWithEnrichedPhone',
            LastName='LastName',
            Email='test@test.com',
            Enriched_phone__c='12345678',
            LeadSource='Big Brain - Signup',
            Status='Unqualified',
            Reached_Out_To__c=true
        ));

        LeadsToInsert.add(new Lead(
            Company='ReceivedStatusLead',
            LastName='LastName',
            Email='test@test.com',
            Enriched_phone__c='12345678',
            LeadSource='Big Brain - Signup',
            Status='Received',
            Related_Company__c=comps.get(0).Id
        ));
        //create leads - one with company assigned and one w/o company
        LeadsToInsert.add(new Lead(LastName = 'test1', Email = 'test1@monday.com', Related_Company__c = comps.get(0).Id, Company = 'test1')); //lead1 w/ related company
        LeadsToInsert.add(new Lead(LastName = 'test2', Email = 'test2@monday.com', Company = 'test2')); //lead2 w/o related company
        LeadsToInsert.add(new Lead(LastName = 'test3', Email = 'test3@monday.com', Account_ARR__c = 500, LeadSource='Outsource', Company = 'test3')); //Outbound lead
        LeadsToInsert.add(new Lead(LastName = 'test4', Email = 'test4@monday.com', Related_Company__c = comps.get(0).Id, Company = 'test4')); //lead w/ related outbound company
        insert LeadsToInsert;
    }

    static testMethod void markCompanyStampsOnCreation_createdWithCompanyARR() { 
        Lead lead1 = [select Company_paying_on_lead_creation__c, Named_Account_on_Creation__c from Lead where LastName = 'test1' limit 1];
        system.assertEquals(true, lead1.Company_paying_on_lead_creation__c);
        system.assertEquals(true, lead1.Named_Account_on_Creation__c);
    }
    
    static testMethod void markCompanyStampsOnCreation_createdWoRelCompany() { // test create w/o related company and assign related company
        Lead lead2 = [select Company_paying_on_lead_creation__c from Lead where LastName = 'test2' limit 1];
        system.assertEquals(false, lead2.Company_paying_on_lead_creation__c);
        Account company1 = [select Id from Account where Name = 'test1' limit 1];
        lead2.Related_Company__c = company1.Id;
        update lead2;
        lead2 = [select Company_paying_on_lead_creation__c, Named_Account_on_Creation__c from Lead where Id =: lead2.Id];
        system.assertEquals(true, lead2.Company_paying_on_lead_creation__c);
        system.assertEquals(true, lead2.Named_Account_on_Creation__c);
    }
    static testMethod void markCompanyStampsOnCreation_ArrZero() { // test create w/o related company and assign related company
        Lead lead2 = [select Company_paying_on_lead_creation__c from Lead where LastName = 'test2' limit 1];
        system.assertEquals(false, lead2.Company_paying_on_lead_creation__c);
        Account company2 = [select Id from Account where Name = 'test2' limit 1];
        lead2.Related_Company__c = company2.Id;
        update lead2;
        lead2 = [select Company_paying_on_lead_creation__c from Lead where Id =: lead2.Id];
        system.assertEquals(false, lead2.Company_paying_on_lead_creation__c);
    }

    static testMethod void ownerStampsOnCreate(){
        User myUser = [select ManagerId, Manager.Team__c, Business_Role__c, Group__c, Name, Office__c, Office_Region__c, Quota_Carrying__c, Segment__c, Seniority__c, Team__c from User where Id =: UserInfo.getUserId()];
        Lead leadRec = [select Owner_s_Manager__c, Owner_s_Manager_Team__c, Owner_Business_Role_Initial__c, Owner_Group_Initial__c, Owner_Name_Initial__c, Owner_Office_Initial__c, Owner_Office_Region_Initial__c, Owner_Quota_Carrying_Initial__c, Owner_Segment_Initial__c, Owner_Seniority_Initial__c, Owner_Team_Initial__c, Owner_Business_Role_Live__c, Owner_Group_Live__c, Owner_Name_Live__c, Owner_Office_Live__c, Owner_Office_Region_Live__c, Owner_Quota_Carrying_Live__c, Owner_Segment_Live__c, Owner_Seniority_Live__c, Owner_Team_Live__c from Lead where LastName = 'test1' limit 1];
        assertOwnerInitialFields(myUser, leadRec);
        assertOwnerLiveFields(myUser, leadRec);
        assertOwnerManagerFields(myUser, leadRec);
    }

    static testMethod void ownerStampsOnUpdate(){
        User someUser = [select ManagerId, Manager.Team__c, Business_Role__c, Group__c, Name, Office__c, Office_Region__c, Quota_Carrying__c, Segment__c, Seniority__c, Team__c from User where Id !=: UserInfo.getUserId() and IsActive = true and Profile.Name = 'System Administrator' limit 1];
        User myUser = [select Business_Role__c, Group__c, Name, Office__c, Office_Region__c, Quota_Carrying__c, Segment__c, Seniority__c, Team__c from User where Id =: UserInfo.getUserId()];
        Lead leadRec = [select Id from Lead where LastName = 'test1' limit 1];
        leadRec.OwnerId = someUser.Id;
        update leadRec;
        leadRec = [select Owner_s_Manager__c, Owner_s_Manager_Team__c, Owner_Business_Role_Initial__c, Owner_Group_Initial__c, Owner_Name_Initial__c, Owner_Office_Initial__c, Owner_Office_Region_Initial__c, Owner_Quota_Carrying_Initial__c, Owner_Segment_Initial__c, Owner_Seniority_Initial__c, Owner_Team_Initial__c, Owner_Business_Role_Live__c, Owner_Group_Live__c, Owner_Name_Live__c, Owner_Office_Live__c, Owner_Office_Region_Live__c, Owner_Quota_Carrying_Live__c, Owner_Segment_Live__c, Owner_Seniority_Live__c, Owner_Team_Live__c from Lead where Id =: leadRec.Id];
        assertOwnerInitialFields(myUser, leadRec);
        assertOwnerLiveFields(someUser, leadRec);
        assertOwnerManagerFields(someUser, leadRec);
        User cmpUser = [select Id, Team__c from User where Id !=: UserInfo.getUserId() and IsActive = true and UserRole.Name = 'Channel Managers' limit 1];
        leadRec.OwnerId = cmpUser.Id;
        update leadRec;
        leadRec = [select Owner_s_Manager__c, Owner_s_Manager_Team__c from Lead where Id =: leadRec.Id];
        assertOwnerManagerFields_CPMs(cmpUser, leadRec);
        User sdrUser = [select Id, Name, Office__c, Team__c, ManagerId, Business_Role__c from User where Id !=: UserInfo.getUserId() and IsActive = true and Function__c = 'SDR' limit 1];
        leadRec.OwnerId = sdrUser.Id;
        update leadRec;
        leadRec = [select SDR_Name__c, SDR_Name_for_reports__c, SDR_Office_stamp__c, SDR_Team__c, SDR_Manager__c, SDR_Business_Role__c from Lead where Id =: leadRec.Id];
        assertSdrFields(sdrUser, leadRec);
    }

    private static void assertOwnerManagerFields(User ownerUser, Lead leadRec){
        system.assertEquals(ownerUser.ManagerId, leadRec.Owner_s_Manager__c);
        system.assertEquals(ownerUser.Manager.Team__c, leadRec.Owner_s_Manager_Team__c);
    }

    private static void assertOwnerManagerFields_CPMs(User ownerUser, Lead leadRec){
        system.assertEquals(ownerUser.Id, leadRec.Owner_s_Manager__c);
        system.assertEquals(ownerUser.Team__c, leadRec.Owner_s_Manager_Team__c);
    }

    private static void assertSdrFields(User ownerUser, Lead leadRec){
        system.assertEquals(ownerUser.Id, leadRec.SDR_Name__c);
        system.assertEquals(ownerUser.Name, leadRec.SDR_Name_for_reports__c);
        system.assertEquals(ownerUser.Office__c, leadRec.SDR_Office_stamp__c);
        system.assertEquals(ownerUser.Team__c, leadRec.SDR_Team__c);
        system.assertEquals(ownerUser.ManagerId, leadRec.SDR_Manager__c);
        system.assertEquals(ownerUser.Business_Role__c, leadRec.SDR_Business_Role__c);
    }

    private static void assertOwnerInitialFields(User ownerUser, Lead leadRec){
        system.assertEquals(ownerUser.Business_Role__c, leadRec.Owner_Business_Role_Initial__c);
        system.assertEquals(ownerUser.Group__c, leadRec.Owner_Group_Initial__c);
        system.assertEquals(ownerUser.Name, leadRec.Owner_Name_Initial__c);
        system.assertEquals(ownerUser.Office__c, leadRec.Owner_Office_Initial__c);
        system.assertEquals(ownerUser.Office_Region__c, leadRec.Owner_Office_Region_Initial__c);
        system.assertEquals(ownerUser.Quota_Carrying__c, leadRec.Owner_Quota_Carrying_Initial__c);
        system.assertEquals(ownerUser.Segment__c, leadRec.Owner_Segment_Initial__c);
        system.assertEquals(ownerUser.Seniority__c, leadRec.Owner_Seniority_Initial__c);
        system.assertEquals(ownerUser.Team__c, leadRec.Owner_Seniority_Initial__c);
    }

    private static void assertOwnerLiveFields(User ownerUser, Lead leadRec){
        system.assertEquals(ownerUser.Business_Role__c, leadRec.Owner_Business_Role_Live__c);
        system.assertEquals(ownerUser.Group__c, leadRec.Owner_Group_Live__c);
        system.assertEquals(ownerUser.Name, leadRec.Owner_Name_Live__c);
        system.assertEquals(ownerUser.Office__c, leadRec.Owner_Office_Live__c);
        system.assertEquals(ownerUser.Office_Region__c, leadRec.Owner_Office_Region_Live__c);
        system.assertEquals(ownerUser.Quota_Carrying__c, leadRec.Owner_Quota_Carrying_Live__c);
        system.assertEquals(ownerUser.Segment__c, leadRec.Owner_Segment_Live__c);
        system.assertEquals(ownerUser.Seniority__c, leadRec.Owner_Seniority_Live__c);
        system.assertEquals(ownerUser.Team__c, leadRec.Owner_Seniority_Live__c);
    }

    @istest
    static void checkPhoneIndications(){
        Lead leadWithPhone = [select id, Distributed_w_o_Phone_Number__c,Distributed_with_Phone__c,Enriched_phone__c,Phone from lead where Company='leadWithPhone' limit 1];
        Lead leadWithOutPhone = [select id, Distributed_w_o_Phone_Number__c,Distributed_with_Phone__c,Enriched_phone__c,Phone from lead where Company='leadWithOutPhone' limit 1];
        Lead leadWithEnrichedPhone = [select id, Distributed_w_o_Phone_Number__c,Distributed_with_Phone__c,Enriched_phone__c,Phone from lead where Company='leadWithEnrichedPhone' limit 1];

        system.assertEquals(true, leadWithPhone.Distributed_with_Phone__c);
        system.assertEquals(false, leadWithPhone.Distributed_w_o_Phone_Number__c);
        system.assertEquals(true, leadWithOutPhone.Distributed_w_o_Phone_Number__c);
        system.assertEquals(false, leadWithOutPhone.Distributed_with_Phone__c);
        system.assertEquals(leadWithEnrichedPhone.Phone, leadWithEnrichedPhone.Enriched_phone__c);

        leadWithOutPhone.Enriched_phone__c='12345';
        leadWithOutPhone.Company='Im now with phone';
        update leadWithOutPhone;

        Lead leadWithOutPhoneNowWithPhone = [select id, Distributed_w_o_Phone_Number__c,Enriched_phone__c,Distributed_with_Phone__c,Phone from lead where Company='Im now with phone' limit 1];

        system.assertEquals(leadWithOutPhoneNowWithPhone.Phone, leadWithOutPhoneNowWithPhone.Enriched_phone__c);
    }
    @istest
    static void checkGetValuesOnCreate(){
        Lead createdLead = [select id,visitor_id__c,Sub_source__c,LeadSource,Channel_Lead_Source__c,Type__c,Distributed_to_First__c,OwnerId,First_Visitor_Id__c,Account_ARR__c, Account_Arr_on_Lead_Creation__c, Lead_created_date__c,Salesloft_Import_Link__c,First_Sub_source__c,First_Lead_Source__c,Channel__c,Received_timestamp__c, Distributed_w_o_Phone_Number__c,Distributed_with_Phone__c,Enriched_phone__c,Phone from lead where Company='leadWithPhone' limit 1];
        Lead createdLeadOutboundChannel = [select id,Account_ARR__c, Account_Arr_on_Lead_Creation__c,Type__c from lead where Company='test3' limit 1];

        system.assertEquals(createdLead.visitor_id__c, createdLead.First_Visitor_Id__c);
        system.assertEquals(Date.today(), createdLead.Lead_created_date__c);
        system.assertEquals(createdLead.Sub_source__c, createdLead.First_Sub_source__c);
        system.assertEquals(createdLead.LeadSource, createdLead.First_Lead_Source__c);
        system.assertEquals(createdLead.Channel_Lead_Source__c, createdLead.Channel__c);
        system.assertEquals(Date.today(), createdLead.Received_timestamp__c);
        system.assertEquals('Test', createdLead.Distributed_to_First__c);
        system.assertEquals(createdLead.Type__c, 'New Business');
        
        
        system.assertEquals(createdLeadOutboundChannel.Account_ARR__c, createdLeadOutboundChannel.Account_Arr_on_Lead_Creation__c);
        system.assertEquals(createdLeadOutboundChannel.Type__c, 'Expansion');
    }
    @istest
    static void handleOngoingUpdates(){
        Lead AttemptingLead = [select id, Status,Time_to_Attempting__c,Distributed_with_Phone__c,Enriched_phone__c,Phone from lead where Company='leadWithPhone' limit 1];
        Lead UnqualifiedLead = [select id,Time_to_Attempting__c,Status, Owner_edit_time__c,Distributed_w_o_Phone_Number__c,Distributed_with_Phone__c,Enriched_phone__c,Phone from lead where Company='leadWithOutPhone' limit 1];
        Lead QualifiedLead = [select id,Time_to_Attempting__c,First_Reachout_Timestamp__c,Status, Distributed_w_o_Phone_Number__c,Distributed_with_Phone__c,Enriched_phone__c,Phone from lead where Company='leadWithEnrichedPhone' limit 1];

        system.assertEquals(0, AttemptingLead.Time_to_Attempting__c);
        system.assertEquals(0, UnqualifiedLead.Time_to_Attempting__c);
        system.assertEquals(null, QualifiedLead.Time_to_Attempting__c);
        system.assertEquals(date.today(), UnqualifiedLead.Owner_edit_time__c.date());
        system.assertEquals(date.today(), QualifiedLead.First_Reachout_Timestamp__c.date());

        AttemptingLead.Reached_Out_To__c=true;
        update AttemptingLead;

        Lead ReachedOutLead = [select id, Status,First_Reachout_Timestamp__c,Enriched_phone__c,Phone from lead where Company='leadWithPhone' limit 1];
        system.assertEquals(date.today(), ReachedOutLead.First_Reachout_Timestamp__c.date());
    }
    @istest
    static void handleMqlSql(){
        Lead createdAsSQLandMQL = [select id, MQL_Timestamp_DT__c,MQL__c,SQL_Timestamp__c,SQL_Timestamp_DT__c,Distributed_w_o_Phone_Number__c,Distributed_with_Phone__c,Enriched_phone__c,Phone from lead where Company='leadWithPhone' limit 1];
        
        system.assertEquals(Date.today(), createdAsSQLandMQL.SQL_Timestamp__c);
        system.assertEquals(date.today(), createdAsSQLandMQL.SQL_Timestamp_DT__c.date());

        system.assertEquals(true, createdAsSQLandMQL.MQL__c);
        system.assertEquals(date.today(), createdAsSQLandMQL.MQL_Timestamp_DT__c.date());


        Lead createdWoSQLandMQL = [select id, SQL__c,SQL_Timestamp__c,SQL_Timestamp_DT__c,MQL__c,MQL_Timestamp_DT__c,Distributed_with_Phone__c,Enriched_phone__c,Phone from lead where Company='leadWithOutPhone' limit 1];
        
        system.assertEquals(null, createdWoSQLandMQL.SQL_Timestamp__c);
        system.assertEquals(null, createdWoSQLandMQL.SQL_Timestamp_DT__c);
        system.assertEquals(false, createdWoSQLandMQL.MQL__c);
        system.assertEquals(null, createdWoSQLandMQL.MQL_Timestamp_DT__c);
    
        
        createdWoSQLandMQL.SQL__c=true;
        createdWoSQLandMQL.Hubspot_Lifecycle_stage__c='marketingqualifiedlead';
        update createdWoSQLandMQL;

        Lead nowIsSQLandMQL = [select id, SQL_Timestamp_DT__c,SQL_Timestamp__c,MQL_Timestamp_DT__c,MQL__c,SQL__c,Distributed_with_Phone__c,Enriched_phone__c,Phone from lead where Company='leadWithOutPhone' limit 1];

        system.assertEquals(Date.today(), nowIsSQLandMQL.SQL_Timestamp__c);
        system.assertEquals(date.today(), nowIsSQLandMQL.SQL_Timestamp_DT__c.date());
        system.assertEquals(true, nowIsSQLandMQL.MQL__c);
        system.assertEquals(Date.today(), nowIsSQLandMQL.MQL_Timestamp_DT__c.date());

        Lead toConvretlead = [select id, SQL__c,SQL_Timestamp__c,SQL_Timestamp_DT__c,MQL__c,MQL_Timestamp_DT__c,Distributed_with_Phone__c,Enriched_phone__c,Phone from lead where Company='ReceivedStatusLead' limit 1];
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(toConvretlead.Id);
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        
        Lead convertedLead = [select id, SQL__c,SQL_Timestamp__c,SQL_Timestamp_DT__c,MQL__c,MQL_Timestamp_DT__c,Distributed_with_Phone__c,Enriched_phone__c,Phone from lead where IsConverted=true limit 1];

        system.assertEquals(Date.today(), convertedLead.SQL_Timestamp__c);
        system.assertEquals(date.today(), convertedLead.SQL_Timestamp_DT__c.date());
        system.assertEquals(true, convertedLead.SQL__c);

    }
    @istest
    static void handleStatusTimestamps(){
        Lead leadRevicedStatus = [select id, Status,unqualified_timestamp__c,Unqualified_Timestamp_DT__c,Nurturing_Timestamp__c,Received_Timestamp_DT__c,Received_timestamp__c,Attempting_timestamp__c,Attempting_Timestamp_DT__c,Contacted_timestamp__c,Contacted_Timestamp_DT__c,Meeting_Scheduled_Timestamp_DT__c,Qualified_Timestamp_DT__c,Qualified_timestamp__c,Enriched_phone__c,Phone from lead where Company='ReceivedStatusLead' and status='Received' limit 1];

        system.assertEquals(Date.today(), leadRevicedStatus.Received_timestamp__c);
        system.assertEquals(date.today(), leadRevicedStatus.Received_Timestamp_DT__c.date());

        system.assertEquals(null, leadRevicedStatus.unqualified_timestamp__c);
        system.assertEquals(null, leadRevicedStatus.Unqualified_Timestamp_DT__c);
        
        system.assertEquals(null, leadRevicedStatus.Nurturing_Timestamp__c);

        system.assertEquals(null, leadRevicedStatus.Attempting_timestamp__c);
        system.assertEquals(null, leadRevicedStatus.Attempting_Timestamp_DT__c);

        system.assertEquals(null, leadRevicedStatus.Contacted_timestamp__c);
        system.assertEquals(null, leadRevicedStatus.Contacted_Timestamp_DT__c);

        system.assertEquals(null, leadRevicedStatus.Meeting_Scheduled_Timestamp_DT__c);

        system.assertEquals(null, leadRevicedStatus.Qualified_Timestamp_DT__c);
        system.assertEquals(null, leadRevicedStatus.Qualified_timestamp__c);

        leadRevicedStatus.Status='Nurturing';
        update leadRevicedStatus;

        Lead leadNurturingStatus = [select id, Status,unqualified_timestamp__c,Unqualified_Timestamp_DT__c,Nurturing_Timestamp__c,Received_Timestamp_DT__c,Received_timestamp__c,Attempting_timestamp__c,Attempting_Timestamp_DT__c,Contacted_timestamp__c,Contacted_Timestamp_DT__c,Meeting_Scheduled_Timestamp_DT__c,Qualified_Timestamp_DT__c,Qualified_timestamp__c,Enriched_phone__c,Phone from lead where Company='ReceivedStatusLead' and status ='Nurturing' limit 1];

        system.assertEquals(Date.today(), leadNurturingStatus.Received_timestamp__c);
        system.assertEquals(date.today(), leadNurturingStatus.Received_Timestamp_DT__c.date());

        system.assertEquals(null, leadNurturingStatus.unqualified_timestamp__c);
        system.assertEquals(null, leadNurturingStatus.Unqualified_Timestamp_DT__c);
        
        system.assertEquals(Date.today(), leadNurturingStatus.Nurturing_Timestamp__c);

        system.assertEquals(null, leadNurturingStatus.Attempting_timestamp__c);
        system.assertEquals(null, leadNurturingStatus.Attempting_Timestamp_DT__c);

        system.assertEquals(null, leadNurturingStatus.Contacted_timestamp__c);
        system.assertEquals(null, leadNurturingStatus.Contacted_Timestamp_DT__c);

        system.assertEquals(null, leadNurturingStatus.Meeting_Scheduled_Timestamp_DT__c);

        system.assertEquals(null, leadNurturingStatus.Qualified_Timestamp_DT__c);
        system.assertEquals(null, leadNurturingStatus.Qualified_timestamp__c);


        leadRevicedStatus.Status='Unqualified';
        update leadRevicedStatus;

        Lead leadUnqualifiedStatus = [select id, Status,unqualified_timestamp__c,Unqualified_Timestamp_DT__c,Nurturing_Timestamp__c,Received_Timestamp_DT__c,Received_timestamp__c,Attempting_timestamp__c,Attempting_Timestamp_DT__c,Contacted_timestamp__c,Contacted_Timestamp_DT__c,Meeting_Scheduled_Timestamp_DT__c,Qualified_Timestamp_DT__c,Qualified_timestamp__c,Enriched_phone__c,Phone from lead where Company='ReceivedStatusLead' and status ='Unqualified' limit 1];

        system.assertEquals(Date.today(), leadUnqualifiedStatus.Received_timestamp__c);
        system.assertEquals(date.today(), leadUnqualifiedStatus.Received_Timestamp_DT__c.date());

        system.assertEquals(Date.today(), leadUnqualifiedStatus.unqualified_timestamp__c);
        system.assertEquals(date.today(), leadUnqualifiedStatus.Unqualified_Timestamp_DT__c.date());
        
        system.assertEquals(Date.today(), leadUnqualifiedStatus.Nurturing_Timestamp__c);

        system.assertEquals(null, leadUnqualifiedStatus.Attempting_timestamp__c);
        system.assertEquals(null, leadUnqualifiedStatus.Attempting_Timestamp_DT__c);

        system.assertEquals(null, leadUnqualifiedStatus.Contacted_timestamp__c);
        system.assertEquals(null, leadUnqualifiedStatus.Contacted_Timestamp_DT__c);

        system.assertEquals(null, leadUnqualifiedStatus.Meeting_Scheduled_Timestamp_DT__c);

        system.assertEquals(null, leadUnqualifiedStatus.Qualified_Timestamp_DT__c);
        system.assertEquals(null, leadUnqualifiedStatus.Qualified_timestamp__c);

        leadRevicedStatus.Status='Contacted';
        update leadRevicedStatus;

        Lead leadContactedStatus = [select id, Status,unqualified_timestamp__c,Unqualified_Timestamp_DT__c,Nurturing_Timestamp__c,Received_Timestamp_DT__c,Received_timestamp__c,Attempting_timestamp__c,Attempting_Timestamp_DT__c,Contacted_timestamp__c,Contacted_Timestamp_DT__c,Meeting_Scheduled_Timestamp_DT__c,Qualified_Timestamp_DT__c,Qualified_timestamp__c,Enriched_phone__c,Phone from lead where Company='ReceivedStatusLead' and status ='Contacted' limit 1];

        system.assertEquals(Date.today(), leadContactedStatus.Received_timestamp__c);
        system.assertEquals(Date.today(), leadContactedStatus.Received_Timestamp_DT__c.date());

        system.assertEquals(Date.today(), leadContactedStatus.unqualified_timestamp__c);
        system.assertEquals(Date.today(), leadContactedStatus.Unqualified_Timestamp_DT__c.date());
        
        system.assertEquals(Date.today(), leadContactedStatus.Nurturing_Timestamp__c);

        system.assertEquals(Date.today(), leadContactedStatus.Attempting_timestamp__c);
        system.assertEquals(Date.today(), leadContactedStatus.Attempting_Timestamp_DT__c.date());

        system.assertEquals(Date.today(), leadContactedStatus.Contacted_timestamp__c);
        system.assertEquals(Date.today(), leadContactedStatus.Contacted_Timestamp_DT__c.date());

        system.assertEquals(null, leadContactedStatus.Meeting_Scheduled_Timestamp_DT__c);

        system.assertEquals(null, leadContactedStatus.Qualified_Timestamp_DT__c);
        system.assertEquals(null, leadContactedStatus.Qualified_timestamp__c);

        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(leadContactedStatus.Id);
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        Database.LeadConvertResult lcr = Database.convertLead(lc);

        Lead leadQualifiedStatus = [select id, Status,unqualified_timestamp__c,Unqualified_Timestamp_DT__c,Nurturing_Timestamp__c,Received_Timestamp_DT__c,Received_timestamp__c,Attempting_timestamp__c,Attempting_Timestamp_DT__c,Contacted_timestamp__c,Contacted_Timestamp_DT__c,Meeting_Scheduled_Timestamp_DT__c,Qualified_Timestamp_DT__c,Qualified_timestamp__c,Enriched_phone__c,Phone from lead where Company='ReceivedStatusLead' and IsConverted=true limit 1];


        system.assertEquals(Date.today(), leadQualifiedStatus.Received_timestamp__c);
        system.assertEquals(Date.today(), leadQualifiedStatus.Received_Timestamp_DT__c.date());

        system.assertEquals(Date.today(), leadQualifiedStatus.unqualified_timestamp__c);
        system.assertEquals(Date.today(), leadQualifiedStatus.Unqualified_Timestamp_DT__c.date());
        
        system.assertEquals(Date.today(), leadQualifiedStatus.Nurturing_Timestamp__c);

        system.assertEquals(Date.today(), leadQualifiedStatus.Attempting_timestamp__c);
        system.assertEquals(Date.today(), leadQualifiedStatus.Attempting_Timestamp_DT__c.date());

        system.assertEquals(Date.today(), leadQualifiedStatus.Contacted_timestamp__c);
        system.assertEquals(Date.today(), leadQualifiedStatus.Contacted_Timestamp_DT__c.date());

        system.assertEquals(Date.today(), leadQualifiedStatus.Meeting_Scheduled_Timestamp_DT__c.date());

        system.assertEquals(Date.today(), leadQualifiedStatus.Qualified_Timestamp_DT__c.date());
        system.assertEquals(Date.today(), leadQualifiedStatus.Qualified_timestamp__c);
    }

    @isTest
    static void shouldMarkChannelOnCreate(){
        Lead lead1 = [SELECT Id, Channel_Lead_Source__c, Channel__c, Lead_Source_Type__c, Sub_source__c, LeadSource from Lead WHERE Email = 'test3@monday.com' limit 1]; //this lead was created without a channel, means it should go theough the logic
        String expectedChannel = Utilities.getChannelMapping().get('Outsource').Channel__c;
        System.assertEquals(expectedChannel, lead1.Channel_Lead_Source__c);
        System.assertEquals(expectedChannel, lead1.Channel__c);
        System.assertEquals('None', lead1.Sub_source__c);
        System.assertEquals('Outsource', lead1.LeadSource);
    }

    @isTest
    static void shouldNotMarkChannelOnCreate(){
        Lead lead1 = [SELECT Id, Channel_Lead_Source__c, Channel__c, Lead_Source_Type__c, Sub_source__c, LeadSource from Lead WHERE Company = 'leadWithPhone' limit 1]; //this lead was created with a channel, means it shouldn't go theough the logic
        System.assertEquals('Outbound', lead1.Channel_Lead_Source__c);
        System.assertEquals('Outbound', lead1.Channel__c);
        System.assertEquals('Inbound', lead1.Lead_Source_Type__c);
        System.assertEquals('Sign up', lead1.Sub_source__c);
        System.assertEquals('Big Brain - Signup', lead1.LeadSource);
    }

    @isTest
    static void shouldMarkChannelOnResubmit(){
        
        Lead lead1 = [SELECT Id, LeadSource, Channel_Lead_Source__c from Lead WHERE Email = 'test3@monday.com' limit 1];
        String channelBeforeUpdate = lead1.Channel_Lead_Source__c;
        
        Test.startTest();
        lead1.LeadSource = 'Website - Contact Sales';
        lead1.Sub_source__c = 'Sign up';
        update lead1;
        Test.stopTest();
        
        lead1 = [SELECT Id, Channel_Lead_Source__c, Channel__c, Lead_Source_Type__c, Sub_source__c, LeadSource, First_Sub_source__c, First_Lead_Source__c from Lead WHERE Email = 'test3@monday.com' limit 1]; //this lead was updated without a channel, means it should go theough the logic
        String channelAfterUpdate = lead1.Channel_Lead_Source__c;
        String expectedChannelCurrent = Utilities.getChannelMapping().get('Website - Contact Sales').Channel__c;
        String expectedChannelFirst = Utilities.getChannelMapping().get('Outsource').Channel__c;


        System.assertEquals(expectedChannelCurrent, lead1.Channel_Lead_Source__c);
        System.assertEquals(expectedChannelFirst, lead1.Channel__c);
        System.assertEquals('Inbound', lead1.Lead_Source_Type__c);
        System.assertEquals('None', lead1.First_Sub_source__c);
        System.assertEquals('Sign up', lead1.Sub_source__c);
        System.assertEquals('Outsource', lead1.First_Lead_Source__c);
        System.assertEquals('Website - Contact Sales', lead1.LeadSource);
    }

    @isTest
    static void shouldNotMarkChannelOnResubmit(){
        
        Lead lead1 = [SELECT Id, LeadSource, Channel_Lead_Source__c from Lead WHERE Email = 'test3@monday.com' limit 1];
        String channelBeforeUpdate = lead1.Channel_Lead_Source__c;
        
        Test.startTest();
        lead1.LeadSource = 'Website - Contact Sales';
        lead1.Sub_source__c = 'Sign up';
        lead1.Channel_Lead_Source__c = 'Event';
        update lead1;
        Test.stopTest();
        
        lead1 = [SELECT Id, Channel_Lead_Source__c, Channel__c, Lead_Source_Type__c, Sub_source__c, LeadSource, First_Sub_source__c, First_Lead_Source__c from Lead WHERE Email = 'test3@monday.com' limit 1]; //this lead was updated without a channel, means it should go theough the logic
        String channelAfterUpdate = lead1.Channel_Lead_Source__c;
        String expectedChannelCurrent = 'Event';
        String expectedChannelFirst = Utilities.getChannelMapping().get('Outsource').Channel__c;


        System.assertEquals(expectedChannelCurrent, lead1.Channel_Lead_Source__c);
        System.assertEquals(expectedChannelFirst, lead1.Channel__c);
        System.assertEquals('Inbound', lead1.Lead_Source_Type__c);
        System.assertEquals('None', lead1.First_Sub_source__c);
        System.assertEquals('Sign up', lead1.Sub_source__c);
        System.assertEquals('Outsource', lead1.First_Lead_Source__c);
        System.assertEquals('Website - Contact Sales', lead1.LeadSource);
    }
}