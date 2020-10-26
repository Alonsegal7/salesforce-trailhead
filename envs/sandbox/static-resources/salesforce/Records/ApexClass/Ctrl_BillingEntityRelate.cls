public class Ctrl_BillingEntityRelate  {
	@AuraEnabled
	public static String getInitialParameters(Id oppId){
		String res = '';
		Map <String, object> mso = new Map <String, object>();
		mso.put('bestMatch', getBillingEntities(oppId, true));
		mso.put('moreOptions', getBillingEntities(oppId, false));
		mso.put('partnerSORequest', getPartnerSO(oppId));
		mso.put('newFormFields', getNewFormFields());
		mso.put('fieldMapping', getfieldMapping());
		System.debug('iCloudius - Initial Parameters:\n' + JSON.serializePretty(mso));
		res = JSON.serialize(mso);
		return res;
	}

	public static Partner_SO_Request__c getPartnerSO(Id oppId){
		Partner_SO_Request__c p = null;
		List <Partner_SO_Request__c> lp = [SELECT Id, Name, Financial_Customer_Name__c, VAT__c, CurrencyIsoCode, Billing_Country__c, Billing_City__c, Billing_Street__c, 
												  Zip_Postal_Code__c, Finance_Contact_Email__c, Finance_Contact_Phone__c 
										   FROM Partner_SO_Request__c WHERE Partner_Opportunity__c = :oppId ORDER BY CreatedDate DESC];
		if (lp != null && !lp.isEmpty()) p = lp[0];
		return p;
	}

	public static List <BillingEntityWrap> getBillingEntities(Id oppId, Boolean bestMatch){
		String billingAddress = '';
		Boolean bestMatchFound = false;
		Id latestBillingEntityID = null;
		Id companyRTId = MondayAccountHelper.companyRecordTypeId;
		Id accountRTId = MondayAccountHelper.MondayAccId;
		List <Company_Billing__c> lcb = new List<Company_Billing__c>();
		List <BillingEntityWrap> lbew = new List <BillingEntityWrap>();
		Map <String, object> mso = new Map<String, object>();

		List <Opportunity> lo = [SELECT Id, Name, AccountId, Account.Name, Account.RecordTypeId, Account.Latest_Billing_Entity__c, Account.Latest_Billing_Entity__r.Name, Account.ParentId 
								 FROM Opportunity WHERE Id =:oppId LIMIT 1];

		if (lo != null && !lo.isEmpty()){
			Opportunity o = lo[0];
			if (o.Account.Latest_Billing_Entity__c != null) 
				latestBillingEntityId = o.Account.Latest_Billing_Entity__c;
			if (bestMatch && latestBillingEntityId != null){
				System.debug('iCloudius - Looking for best match according latest billing entity');
				lcb = [SELECT Id, Name, Billing_Entity__c, Billing_Entity__r.Name, Billing_Entity__r.CurrencyIsoCode, Billing_Entity__r.Billing_Currency__c,Billing_Entity__r.Billing_Address__c,Billing_Entity__r.Shipping_Address__c,
							  Company__r.Name, Company__r.Currency__c, Company__r.CurrencyIsoCode, Company__r.BillingCountry, Company__r.BillingState, Company__r.BillingStreet 
					   FROM Company_Billing__c 
					   WHERE Billing_Entity__r.Status__c = 'Active' AND 
					   Company__c = :o.AccountId AND 
					   Billing_Entity__c = :latestBillingEntityId];

				if (lcb != null && !lcb.isEmpty()){ bestMatchFound = true; System.debug('iCloudius - Best Match found based on latest billing entity'); }
			}
						
			if (((bestMatch && !bestMatchFound) || !bestMatch) && o.Account.RecordTypeId == companyRTId){
				System.debug('iCloudius - Looking for best match: ' + bestMatch);
				System.debug('iCloudius - Opportunity.Account is company');
				lcb = [SELECT Id, Name, Billing_Entity__c, Billing_Entity__r.Name, Billing_Entity__r.CurrencyIsoCode, Billing_Entity__r.Billing_Address__c,Billing_Entity__r.Shipping_Address__c,
							  Company__r.Name, Company__r.Currency__c, Company__r.CurrencyIsoCode, Company__r.BillingCountry, Company__r.BillingState, Company__r.BillingStreet 
					   FROM Company_Billing__c 
					   WHERE Billing_Entity__r.Status__c = 'Active' AND 
					   Company__c = :o.AccountId];
				if (lcb != null && !lcb.isEmpty()){ bestMatchFound = true; System.debug('iCloudius - Best Match found based on company account'); }
			}

			if (((bestMatch && !bestMatchFound) || !bestMatch) && o.Account.RecordTypeId == accountRTId && o.Account.ParentId != null){
				System.debug('iCloudius - Looking for best match: ' + bestMatch);
				System.debug('iCloudius - Opportunity.Account is account and has Parent');
				lcb = [SELECT Id, Name, Billing_Entity__c, Billing_Entity__r.Name, Billing_Entity__r.CurrencyIsoCode, Billing_Entity__r.Billing_Address__c,Billing_Entity__r.Shipping_Address__c,
							  Company__r.Name, Company__r.Currency__c, Company__r.CurrencyIsoCode, Company__r.BillingCountry, Company__r.BillingState, Company__r.BillingStreet 
					   FROM Company_Billing__c 
					   WHERE Billing_Entity__r.Status__c = 'Active' AND 
					   Company__c = :o.Account.ParentId];
			}

			System.debug('iCloudius - lcb.size(): ' + lcb.size());
			if (lcb != null && !lcb.isEmpty() && ((lcb.size() == 1 && bestMatch) || !bestMatch)) {
				for (Company_Billing__c cb: lcb) 
					if (bestMatch || (!bestMatch && cb.Billing_Entity__c != latestBillingEntityID)) {
						billingAddress  = cb.Company__r.BillingStreet != null ? cb.Company__r.BillingStreet + ', ' : '';
						billingAddress += cb.Company__r.BillingState != null ? cb.Company__r.BillingState + ', ' : '';
						billingAddress += cb.Company__r.BillingCountry != null ? cb.Company__r.BillingCountry : '';
						BillingEntityWrap bew = new BillingEntityWrap(cb.Billing_Entity__c, cb.Billing_Entity__r.Name, (bestMatchFound ? 'Monday Account: ' + o.Account.Name : cb.Company__r.Name), cb.Billing_Entity__r.CurrencyIsoCode, cb.Billing_Entity__r.Billing_Address__c, cb.Billing_Entity__r.Shipping_Address__c);
						if (bestMatchFound) bew.selected = true;
						lbew.add(bew);
					}
			}
		}


		return lbew;
	}

	public static List <String> getNewFormFields(){
		System.debug('iCloudius - Getting new form Fieldset');
		List<String> ls = new List<String>();
		for(Schema.FieldSetMember f : SObjectType.Billing_Entity__c.FieldSets.NewEntityfields.getFields()) {
			ls.add(f.getFieldPath());
		}
		return ls;
	}

	public static Map <String, String> getfieldMapping(){
		Map <String, String> mss = new Map <String, String>();
		List <Billing_Entity_Field_Mapping__mdt> lmd = [SELECT Id, MasterLabel, Partner_SO_Request_Field__c FROM Billing_Entity_Field_Mapping__mdt];
		if (lmd != null && !lmd.isEmpty()){
			for (Billing_Entity_Field_Mapping__mdt md: lmd) mss.put(md.MasterLabel, md.Partner_SO_Request_Field__c);
		}
		return mss;
	}
	
	@AuraEnabled
	public static string testUniquness(String vatNumber, String cBillingCurrency, String cCountry, String cCity, String cName){
		String res = '';
		String key = BillingEntityHandler.UniquenessKey(vatNumber, cBillingCurrency, cCountry, cCity, cName);
        
		List <Billing_Entity__c> lbe = [SELECT Id, Name FROM Billing_Entity__c WHERE Unique_Key__c = :key];
		if (lbe != null && !lbe.isEmpty()){
			Lookup_Ctrl.ResultWrapper rw = new Lookup_Ctrl.ResultWrapper();
			rw.objName = 'Billing_Entity__c';
			rw.val = String.valueOf(lbe[0].Id);
			rw.text = lbe[0].Name;

			res = JSON.serialize(rw);			
		}

		System.debug('iCloudius - Uniquness test result: ' + res);
		return res;
	}

	@AuraEnabled
	public static String doRelate(Id oppId, Id BEId){
		String res = '';
		List<Opportunity> lo = [SELECT Id, Name, AccountId, Account.ParentId FROM Opportunity WHERE Id = :oppId LIMIT 1];
		Account oppAcc = null;
		if (lo != null && !lo.isEmpty()){
			lo[0].Billing_Entity__c = BEId;
			oppAcc = new Account(Id = lo[0].AccountId, Latest_Billing_Entity__c = BEId);
			System.debug('iCloudius - Updated Opportunity:\n' + JSON.serializePretty(lo[0]));
			try{
				if (lo[0].Account.ParentId != null){
					List<Company_Billing__c> lcb = [SELECT Id, Name FROM Company_Billing__c WHERE Billing_Entity__c = :BEId AND Company__c = :lo[0].Account.ParentId];
					if (lcb == null || lcb.isEmpty()){
						System.debug('iCLoudius - Creating Company Billing');
						Company_Billing__c cb = new Company_Billing__c(Billing_Entity__c = BEId, Company__c = lo[0].Account.ParentId);
						insert cb;
					}
				}
				update lo;
				if (oppAcc != null) update oppAcc;
			}catch(Exception ex){
				res = ex.getMessage();
				System.debug('iCloudius - Exception relating billing entity: ' + ex.getStackTraceString());
			}
		}
		return res;
	}

	public class BillingEntityWrap {
		public Id bEId { get; set; }
		public String customerName {
			get {
				return customerName == null ? '' : customerName;
			} set; }
		public String connectedTo {
			get {
				return connectedTo == null ? '' : connectedTo;
			} set; }
		public String bECurrency {
			get {
				return bECurrency == null ? '' : bECurrency;
			} set; }
		public String billingAddress {
			get {
				return billingAddress == null ? '' : billingAddress;
			} set; 
		}
		public String shippingAddress {
			get {
				return shippingAddress == null ? '' : shippingAddress;
			} set; 
		}
		public Boolean selected {
			get {
				return selected == null ? false : true;
			} Set; }

		public BillingEntityWrap (){ }
		public BillingEntityWrap (Id bEId, String customerName, String connectedTo, String bECurrency, String billingAddress, String shippingAddress){
			this.bEId = bEId;
			this.customerName = customerName;
			this.connectedTo = connectedTo;
			this.bECurrency = bECurrency;
			this.billingAddress = billingAddress;
			this.shippingAddress = shippingAddress;
		}
	}
}