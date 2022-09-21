@isTest
public class TestObjectCreator 
{
    public static Id mondayAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Monday_Account').getRecordTypeId();
    public static Id companyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Company').getRecordTypeId();
    public static final Id ACC_PARTNER_COMP_RT_CONST = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner_Company').getRecordTypeId();
    public static boolean persistImmediate = false;
    static Integer s_num = 1;

    public static Account CreateAccount() {
        Account a = new Account();
        a.Name = 'Test ' + randomChars(9, 0);
        
        if (persistImmediate) insert a;
        return a;
    }

    public static Lead createLead(){
        Lead l = new Lead();
        l.LastName = 'test';
        l.email = 'test@monday.com';
        l.Company = 'test';
        if (persistImmediate) insert l;
        return l;
    }

	/*public static Contact CreateContact (Account a) {
        Contact c = new Contact();
		c.FirstName = 'Elfo';
        c.Lastname = 'Testo';
		c.Email = 'elfo@testo.com';
		c.Title = 'Dr';
		c.MobilePhone = '0522222222';
        c.accountid = a.id;
        c.MailingCity = 'test';
        c.mailingCountry = 'Israel';
        return c;
    }*/

    public static Account CreateCompany() {
        boolean prevPersist = persistImmediate;
        persistImmediate = false;
        Account a = CreateAccount();
        persistImmediate = prevPersist;
        
        a.RecordTypeId = companyRecordTypeId;
        
        if (persistImmediate) insert a;
        return a;
    }
    
    public static Account CreateMondayAccount(Account company) {
        boolean prevPersist = persistImmediate;
        persistImmediate = false;
        Account a = CreateAccount();
        persistImmediate = prevPersist;
        
        a.RecordTypeId = mondayAccRecordTypeId;
        a.ParentId = company.Id;
        a.Company__c = company.Id;
        
        if (persistImmediate) insert a;
        return a;
    }
    
    public static Opportunity CreateOpp (Account a){
        Opportunity Opp = new Opportunity();
        Opp.AccountId = a.Id;
        Opp.Name = 'TestOppName';
        Opp.CloseDate = System.today();
        Opp.StageName = 'Open';
        Opp.CurrencyIsoCode='USD';
        Opp.Billing_Ids__c='123456';
        Opp.Pricing_Version__c='8';
        Opp.Expected_Plan_Seats__c=60;
        Opp.Expected_Plan_Tier__c='Enterprise';
        Opp.Expected_Plan_Period__c='Yearly';
        Opp.Expected_Plan_Name__c='Enterprise -- Up to 60 users (Yearly)';
        if (persistImmediate) insert opp;
        return opp;
    }
    
    public static ExchangeRate__c CreateExchangeRate(String currencyCode, DateTime d, Double rate)
    {
        ExchangeRate__c ex = new ExchangeRate__c();
        ex.Currency__c = currencyCode;
        ex.CurrencyIsoCode  = currencyCode;
        ex.Date__c = Date.newInstance(d.year(), d.month(), d.day());
		ex.Rate__c  = rate;
        
        if (persistImmediate) insert ex;
        return ex;
    }
    
    public static Billing_Entity__c CreateBE()
    {
        Billing_Entity__c be = new Billing_Entity__c();
        be.name = 'TEST';
        be.VAT_Number__c = 'TESTExtremelyuniquemvckjcxh43mfc';
        be.CurrencyIsoCode = 'USD';
		be.Status__c = 'Active';
        be.Contact_Email__c = 'test@gmail.com';
        be.Finance_Contact_Phone__c = '0123456789';
        be.Country__c = 'Ukraine';
        be.City__c = 'test city';
        be.Street__c = 'test street';
        be.Zip_Postal_Code__c = '123456';
        be.Shipping_Country_G__c = 'Ukraine';
        be.Shipping_City__c= 'test city';
        be.Shipping_Street__c = 'test street';
        be.Shipping_Zip_Postal_Code__c = '123456';
        be.Ship_To_Name__c = 'test name';
        
        if (persistImmediate) insert be;
        return be;
    }

	public static Company_Billing__c CreateCompanyBilling(Account a, Billing_Entity__c be){
		Company_Billing__c cb = new Company_Billing__c();
		cb.Company__c = a.Id;
		cb.Billing_Entity__c = be.Id;
        
        if (persistImmediate) insert cb;
		return cb;
	}

    public static Pricebook2 CreatePricebook(){
		Pricebook2 p = new Pricebook2(Name = 'Test pricebook', IsActive = true, Is_Main__c=true);
        
        if (persistImmediate) insert p;
		return p;
	}
    
    public static Product2 CreateProduct(){
		Product2 p = new Product2(Name = 'Pro Plan', IsActive = true, IsRecurring__c=true,Contract_Creation_Product__c=true,Contract_Event_Product__c=true,Quantity_Unit_Of_Measure__c='Seats',subscription_main_tier__c='Pro');
        
        if (persistImmediate) insert p;
		return p;
    }

    public static Product2 CreateNonRcringProduct(){
		Product2 p = new Product2(Name = 'Additional Advanced Onboarding Hours', ProductCode='CSG-ADTNL-ADV-ONB-SUPPORT',Project_Item_Type__c='Onboarding- Paid',IsActive = true, IsRecurring__c=false,Contract_Creation_Product__c=false,Contract_Event_Product__c=true,Quantity_Unit_Of_Measure__c='Hours');
        
        if (persistImmediate) insert p;
		return p;
    }

    public static Product2 CreateProductWithCode(string Code){
		Product2 p = new Product2(Name = 'Test product', IsActive = true,ProductCode=code);
		return p;
	}
    
    public static PricebookEntry CreatePricebookEntry(Product2 product, decimal unitPrice){
        if (product == null) { product = CreateProduct(); }
        
		PricebookEntry standardPBE = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = product.Id,
            UnitPrice = unitPrice,
            UseStandardPrice = false,
            IsActive = true
        );
    	
        if (persistImmediate) insert standardPBE;
		return standardPBE;
	}
    
    public static QuoteLineItem CreateQuoteLineItem(Quote quote, string productType, integer quantity, decimal unitPrice) {
        Product2 product;
        if(productType=='License')  product = CreateProduct();
        if(productType=='Onboarding')  product = CreateNonRcringProduct();
        PricebookEntry pb = CreatePricebookEntry(product, unitPrice);
        
        QuoteLineItem i = new QuoteLineItem(
            PricebookEntryId = pb.Id,
            Product2Id = product.Id,
        	QuoteId = quote.Id,
            Quantity = quantity,
            UnitPrice = unitPrice,
            Product_Type__c = productType,
            Is_Primary__c=true
        );
        
        if (persistImmediate) insert i;
		return i;
	}
    
    public static Contract CreateContract(Account account){
        Contract c = new Contract(
            Name = 'Test contract',
            Seats__c = 5,
        	AccountId = account.Id
        );
        
        if (persistImmediate) insert c;
		return c;
    }
    
    public static Subscription__c CreateSubscription(){
        Subscription__c s = new Subscription__c(
            Name = 'Test Sub',
            Status__c='ACTIVE',
            Pulse_Account_Id__c='12211',
            Pricing_Version__c=8,
            Tier__c='pro',
            Seats__c='50',
            Paid_Months__c=12,
            Free_Months__c=1,
            ARR_Gain__c=1020,
            Billing_Ids__c='123456',
            ARR__c=1020
        );
        
        if (persistImmediate) insert s;
		return s;
	}
    
    public static Quote CreateQuote(Opportunity oppportunity, Contract contract, string quoteType){
        Quote q = new Quote(
            Name = 'Test quote',
            OpportunityId = oppportunity.Id,
            Pricebook2Id = Test.getStandardPricebookId(),
            ContractId = contract.Id,
            Quote_Type__c = quoteType,
            Duration__c = 12
        );
        
        if (persistImmediate) insert q;
		return q;
    }

    public static Quote CreateNonContractQuote(Opportunity oppportunity,string quoteType){
        Quote q = new Quote(
            Name = 'Test quote',
            OpportunityId = oppportunity.Id,
            Pricebook2Id = Test.getStandardPricebookId(),
            Quote_Type__c = quoteType,
            Duration__c = 12
        );
        
        if (persistImmediate) insert q;
		return q;
    }
    
    
    public static OpportunityLineItem CreateOpportunityProduct(Opportunity oppportunity, QuoteLineItem qli){
        OpportunityLineItem q = new OpportunityLineItem(
            OpportunityId = oppportunity.Id,
            Quantity = qli.Quantity,
            PricebookEntryId = qli.PricebookEntryId,
            TotalPrice = qli.Quantity * qli.UnitPrice,
            Product_Type__c=qli.Product_Type__c
        );
        
        if (persistImmediate) insert q;
		return q;
    }
    
    public static GB_Threshold__c CreateGBThreshold(String recordType)
    {
        GB_Threshold__c gbt = new GB_Threshold__c();
        gbt.name = 'GB Threshold Test';
        gbt.Opportunity_Record_Type__c = recordType;
        gbt.Is_Active__c = true;
        gbt.Min_ARR__c=7000;

        if (persistImmediate) insert gbt;
        return gbt;
    }

	/*public static User CreateUser(){
		User u = new User();
		u.FirstName = 'User T1';
		u.LastName = 'ACME';
		u.Email = 'usert1@acme.com';
		u.ProfileId = UserInfo.getProfileId();
		u.IsActive = true;
		u.Username = u.Email;
		u.Alias = u.FirstName.left(1) + u.LastName.left(4);
		u.Country = 'Israel';
		u.LanguageLocaleKey = UserInfo.getLanguage();
		u.LocaleSidKey = UserInfo.getLocale();
		u.EmailEncodingKey = 'UTF-8';
		u.TimeZoneSidKey = 'America/Argentina/Buenos_Aires';
		u.CurrencyIsoCode = 'USD';
		return u;
	}*/
    
	// random chars on 0, random integer on 1 random refcallno
	static public String randomChars(Integer len,Integer typeNum) {
         final String[] charsArr = new list<String>{'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz','0123456789','13'};
         String chars = charsArr[Math.mod(typeNum,charsArr.size())];
         String randStr = '';
         while (randStr.length() < len) {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
           randStr += chars.substring(idx, idx+1);
         }
         return randStr; 
    }
    
    public static String getFakeId(Schema.SObjectType sot)
   {
      String result = String.valueOf(s_num++);
      return sot.getDescribe().getKeyPrefix() + 
         '0'.repeat(12-result.length()) + result;
   }

   public static User createValidPartnerUser(){
       //create partner company
       List<Account> partnersList = new List<Account>();
       partnersList.add(new Account(Name = 'testPartner', RecordTypeId = ACC_PARTNER_COMP_RT_CONST));
       insert partnersList;
   
       for(Account partner: partnersList){
           partner.Partner_Company_Status__c = 'Signed';
           partner.Signature_Approval_Status__c = 'Approved';
       }
       update partnersList;

       Contact con = new Contact(Email='demo1@randomdemodomain.com', FirstName = 'test', LastName = 'bla', AccountId = partnersList.get(0).Id);
       insert con;

       Profile p = [SELECT Id FROM Profile WHERE Name='Partner Community Custom'];
       User manager2 = [select Id from User where IsActive = true and Profile.Name='Channel Managers' limit 1];
       User user = new User(ContactId = con.Id, Alias='standt1', ManagerId=manager2.Id, Country='United Kingdom',Email='demo1@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='testing123@monday.com');
       insert user;
       return user;
   }

   public static Target__c CreateTarget(Account company){
        Target__c t = new Target__c(
            Name = 'Test target',
            Target_Date__c = date.today(),
            Partner_Company__c = company.Id
        );
        
        if (persistImmediate) insert t;
        return t;
   }
}