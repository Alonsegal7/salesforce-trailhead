public class Ctrl_BillingEntityRelate  {
	@AuraEnabled
	public static String getInitialParameters(Id oppId){
		String res = '';
		Map <String, object> mso = new Map <String, object>();
		mso.put('opportunity', getOpportunity(oppId));
        mso.put('fieldMapping', getfieldMapping());
		mso.put('bestMatch', getBillingEntities(oppId, true));
		mso.put('moreOptions', getBillingEntities(oppId, false));
		mso.put('partnerSORequest', getPartnerSO(oppId, (Map <String, String>)mso.get('fieldMapping')));
		mso.put('newFormFields', getNewFormFields());
		mso.put('newFormShippingFields', getNewFormShippingFields());
		mso.put('editFormFields', getEditFormFields());
		mso.put('fieldValidations', getFieldValidations());
		System.debug('iCloudius - Initial Parameters:\n' + JSON.serializePretty(mso));
		res = JSON.serialize(mso);
		return res;
	}

	public static Map <String, Object> getFieldValidations(){
		Map <String, Object> mso = new Map <String, Object>();
		List <BillingEntityFieldValidation__mdt> listRules = [SELECT DeveloperName, Error_Message__c, Field_API_Name__c, Id, Label, MasterLabel, Restriction_Type__c, Validation_Type__c 
															  FROM BillingEntityFieldValidation__mdt ORDER BY Restriction_Type__c];
		mso.put('list_rules', listRules);
		
		return mso;
	}

	public static Opportunity getOpportunity(Id oppId){
		Opportunity o = null;
		List<Opportunity> lo = [SELECT Id, Name, AccountId, Billing_Entity__c, Billing_Entity__r.Name, Account.Latest_Billing_Entity__c, Account.Latest_Billing_Entity__r.Name, 
									   Account.Latest_Billing_Entity__r.VAT_Number__c 
								FROM Opportunity
								WHERE Id =: oppId];

		if (lo != null && !lo.isEmpty()){
			o = lo[0];
		}
		System.debug('iCloudius - The Opp: ' + JSON.serializePretty(o));
		return o;
	}

	public static Partner_SO_Request__c getPartnerSO(Id oppId, Map <String, String> fieldsMapping){
		Partner_SO_Request__c p = null;
		String query = 'SELECT ';

        for (String s: fieldsMapping.values()){
			query += s + ', ';
		}

		query += 'Id, Name FROM Partner_SO_Request__c WHERE Partner_Opportunity__c = \'' + oppId + '\' ORDER BY CreatedDate DESC';
		List <Partner_SO_Request__c> lp = Database.query(query);

		if (lp != null && !lp.isEmpty()){
			p = lp[0];
		}

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
								 FROM Opportunity WHERE Id =: oppId LIMIT 1];

		if (lo != null && !lo.isEmpty()){
			Opportunity o = lo[0];
			if (o.Account.Latest_Billing_Entity__c != null){
				latestBillingEntityId = o.Account.Latest_Billing_Entity__c;
			}

			if (bestMatch && latestBillingEntityId != null){
				System.debug('iCloudius - Looking for best match according latest billing entity');
				lcb = [SELECT Id, Name, Billing_Entity__c, Billing_Entity__r.Name, Billing_Entity__r.CurrencyIsoCode, Billing_Entity__r.Billing_Currency__c,Billing_Entity__r.Billing_Address__c,Billing_Entity__r.Shipping_Address__c,
							  Company__r.Name, Company__r.Currency__c, Company__r.CurrencyIsoCode, Company__r.BillingCountry, Company__r.BillingState, Company__r.BillingStreet 
					   FROM Company_Billing__c 
					   WHERE Billing_Entity__r.Status__c = 'Active' AND Company__c = :o.AccountId AND Billing_Entity__c =: latestBillingEntityId];

				if (lcb != null && !lcb.isEmpty()){
					bestMatchFound = true;
					System.debug('iCloudius - Best Match found based on latest billing entity');
				}
			}
						
			if ( ((bestMatch && !bestMatchFound) || !bestMatch) && o.Account.RecordTypeId == companyRTId){
				System.debug('iCloudius - Looking for best match: ' + bestMatch);
				System.debug('iCloudius - Opportunity.Account is company');
				lcb = [SELECT Id, Name, Billing_Entity__c, Billing_Entity__r.Name, Billing_Entity__r.CurrencyIsoCode, Billing_Entity__r.Billing_Address__c,Billing_Entity__r.Shipping_Address__c,
							  Company__r.Name, Company__r.Currency__c, Company__r.CurrencyIsoCode, Company__r.BillingCountry, Company__r.BillingState, Company__r.BillingStreet 
					   FROM Company_Billing__c 
					   WHERE Billing_Entity__r.Status__c = 'Active' AND Company__c = :o.AccountId];

				if (lcb != null && !lcb.isEmpty()){
					bestMatchFound = true;
					System.debug('iCloudius - Best Match found based on company account');
				}
			}

			if ( ((bestMatch && !bestMatchFound) || !bestMatch) && o.Account.RecordTypeId == accountRTId && o.Account.ParentId != null){
				System.debug('iCloudius - Looking for best match: ' + bestMatch);
				System.debug('iCloudius - Opportunity.Account is account and has Parent');
				lcb = [SELECT Id, Name, Billing_Entity__c, Billing_Entity__r.Name, Billing_Entity__r.CurrencyIsoCode, Billing_Entity__r.Billing_Address__c,Billing_Entity__r.Shipping_Address__c,
							  Company__r.Name, Company__r.Currency__c, Company__r.CurrencyIsoCode, Company__r.BillingCountry, Company__r.BillingState, Company__r.BillingStreet 
					   FROM Company_Billing__c 
					   WHERE Billing_Entity__r.Status__c = 'Active' AND Company__c = :o.Account.ParentId];
			}

			System.debug('iCloudius - lcb.size(): ' + lcb.size());
			if (lcb != null && !lcb.isEmpty() && ((lcb.size() == 1 && bestMatch) || !bestMatch)) {
				for (Company_Billing__c cb: lcb){
					if (bestMatch || (!bestMatch && cb.Billing_Entity__c != latestBillingEntityID)){
						billingAddress  = cb.Company__r.BillingStreet != null ? cb.Company__r.BillingStreet + ', ' : '';
						billingAddress += cb.Company__r.BillingState != null ? cb.Company__r.BillingState + ', ' : '';
						billingAddress += cb.Company__r.BillingCountry != null ? cb.Company__r.BillingCountry : '';
						BillingEntityWrap bew = new BillingEntityWrap(cb.Billing_Entity__c, cb.Billing_Entity__r.Name, (bestMatchFound ? 'Monday Account: ' + o.Account.Name : cb.Company__r.Name), cb.Billing_Entity__r.CurrencyIsoCode, cb.Billing_Entity__r.Billing_Address__c, cb.Billing_Entity__r.Shipping_Address__c);
						if (bestMatchFound){
							bew.selected = true;
						}
						lbew.add(bew);
					}
				}
			}
		}

		return lbew;
	}

	public static List <Map <String, Object>> getNewFormFields(){
		System.debug('iCloudius - Getting new form Fieldset');
		List<String> ls = new List<String>();
		List <Map<String, Object>> lmss = new List <Map<String, Object>>();
		for(Schema.FieldSetMember f : SObjectType.Billing_Entity__c.FieldSets.NewEntityfields.getFields()) {
			Map<String, Object> tmp = new Map<String, Object>();
			tmp.put('name', f.getFieldPath());
			tmp.put('required', (f.getDbRequired() || f.getRequired()));
			lmss.add(tmp);
			ls.add(f.getFieldPath());
		}
		System.debug('iCloudius - New Fieldset mapping:\n' + JSON.serializePretty(lmss));
		return lmss;
	}

	public static List <Map<String, Object>> getNewFormShippingFields(){
		System.debug('iCloudius - Getting new form Fieldset');
		List<String> ls = new List<String>();
		List <Map<String, Object>> lmss = new List <Map<String, Object>>();
		for(Schema.FieldSetMember f : SObjectType.Billing_Entity__c.FieldSets.NewShippingFields.getFields()) {
			Map<String, Object> tmp = new Map<String, Object>();
			tmp.put('name', f.getFieldPath());
			tmp.put('required', (f.getDbRequired() || f.getRequired()));
			lmss.add(tmp);
			ls.add(f.getFieldPath());
		}
		System.debug('iCloudius - New Fieldset mapping:\n' + JSON.serializePretty(lmss));
		return lmss;
	}

	public static List <Map <String, Object>> getEditFormFields(){
		System.debug('iCloudius - Getting edit form Fieldset');
		List<String> ls = new List<String>();
		List <Map<String, Object>> lmss = new List<Map <String, Object>>();
		for(Schema.FieldSetMember f : SObjectType.Billing_Entity__c.FieldSets.EditEntityFields.getFields()) {
		Map <String, Object> tmp = new Map <String, Object>();
			tmp.put('name', f.getFieldPath());
			tmp.put('required', (f.getDbRequired() || f.getRequired()));
			lmss.add(tmp);
			ls.add(f.getFieldPath());
		}
		System.debug('iCloudius - Edit Fieldset mapping:\n' + JSON.serializePretty(lmss));
		return lmss;
	}

	public static Map <String, String> getfieldMapping(){
		Map <String, String> mss = new Map <String, String>();

		List <Billing_Entity_Field_Mapping__mdt> lmd = [SELECT Id, MasterLabel, Partner_SO_Request_Field__c FROM Billing_Entity_Field_Mapping__mdt];

		if (lmd != null && !lmd.isEmpty()){
			for (Billing_Entity_Field_Mapping__mdt md: lmd){
				mss.put(md.MasterLabel, md.Partner_SO_Request_Field__c);
			}
		}
		return mss;
	}

	@AuraEnabled (cacheable=false)
	public static String fieldValidations(Billing_Entity__c be){
		System.debug('iCloudius - Billing entity for field validations: ' + JSON.serializePretty(be));
		Map <String, Object> beMso = (Map <String, Object>)JSON.deserializeUntyped(JSON.serialize(be));
		Map <String, Object> mso = new Map <String, Object>();
		List <BillingEntityWrap> matchesFound = new List <BillingEntityWrap>();
		Boolean prevent = false;
		Boolean inform = false;
		Set <Id> setId = new Set <Id>();
		String baseQuery = 'SELECT Id, Name, CurrencyIsoCode, Billing_Address__c, Shipping_Address__c, Country__c, VAT_Number__c ';
		String finalQuery = '';

		List <BillingEntityFieldValidation__mdt> preventiveRules = new List <BillingEntityFieldValidation__mdt>();
		List <BillingEntityFieldValidation__mdt> informativeRules = new List <BillingEntityFieldValidation__mdt>();
		List <BillingEntityFieldValidation__mdt> listRules = [SELECT DeveloperName, Error_Message__c, Field_API_Name__c, Id, Label, MasterLabel, Restriction_Type__c, Validation_Type__c, 
																	 (SELECT Id, DeveloperName, MasterLabel FROM Billing_Entity_Field_Validation_Suffixes__r) 
															  FROM BillingEntityFieldValidation__mdt ORDER BY Restriction_Type__c];
		if (listRules != null && !listRules.isEmpty()){
			for (BillingEntityFieldValidation__mdt fv: listRules){
				if (!baseQuery.containsIgnoreCase(', ' + fv.Field_API_Name__c)) baseQuery += ', ' + fv.Field_API_Name__c;
				if (fv.Restriction_Type__c == 'Preventative') preventiveRules.add(fv);
				if (fv.Restriction_Type__c == 'Informative') informativeRules.add(fv);
			}
		}

		baseQuery += ' FROM Billing_Entity__c WHERE Status__c = \'Active\' AND ';

		List <Billing_Entity__c> BEsFound = null;
		if (!preventiveRules.isEmpty()){
			for (BillingEntityFieldValidation__mdt fv: preventiveRules){
				if (fv.Validation_Type__c != null && fv.Field_API_Name__c != null && beMso.containsKey(fv.Field_API_Name__c) && beMso.get(fv.Field_API_Name__c) != null){
					finalQuery = baseQuery + getWhereCluase(fv, be);
					System.debug('iCloudius - Preventative validation query: ' + finalQuery);
					BEsFound = Database.query(finalQuery);
					if (BEsFound != null && !BEsFound.isEmpty()){
						for (Billing_Entity__c ibe: BEsFound) {
							Boolean isMatch = false;
							if (fv.Validation_Type__c == 'Exact Match' && String.valueOf(ibe.get(fv.Field_API_Name__c)).equals(String.valueOf(be.get(fv.Field_API_Name__c))) && !setId.contains(ibe.Id)) { isMatch = true; }
							if (fv.Validation_Type__c == 'Upper/Lower case' && String.valueOf(ibe.get(fv.Field_API_Name__c)).equalsIgnoreCase(String.valueOf(be.get(fv.Field_API_Name__c))) && !setId.contains(ibe.Id)) { isMatch = true; }
							if ((fv.Validation_Type__c == 'Punctuations' || fv.Validation_Type__c == 'Email Domain' || fv.Validation_Type__c == 'Suffix') && !setId.contains(ibe.Id)) { isMatch = true; }
							if (isMatch){
								BillingEntityWrap bew = new BillingEntityWrap(ibe.Id, ibe.Name, '', ibe.CurrencyIsoCode, ibe.Billing_Address__c, ibe.Shipping_Address__c);
								bew.country = ibe.Country__c;
								bew.VATNumber = ibe.VAT_Number__c;
								bew.errorMessage = fv.Error_Message__c;
								matchesFound.add(bew);
								prevent = true;
								setId.add(ibe.Id);
							}
						}
					}
				}
			}
		}

		if (!informativeRules.isEmpty()){
			for (BillingEntityFieldValidation__mdt fv: informativeRules){
				if (fv.Validation_Type__c != null && fv.Field_API_Name__c != null && beMso.containsKey(fv.Field_API_Name__c) && beMso.get(fv.Field_API_Name__c) != null){
					finalQuery = baseQuery + getWhereCluase(fv, be);
					System.debug('iCloudius - Informative validation query: ' + finalQuery);				
					BEsFound = Database.query(finalQuery);
					if (BEsFound != null && !BEsFound.isEmpty()){
						for (Billing_Entity__c ibe: BEsFound) {
							Boolean isMatch = false;
							if (fv.Validation_Type__c == 'Exact Match' && String.valueOf(ibe.get(fv.Field_API_Name__c)).equals(String.valueOf(be.get(fv.Field_API_Name__c))) && !setId.contains(ibe.Id)) { isMatch = true; }
							if (fv.Validation_Type__c == 'Upper/Lower case' && String.valueOf(ibe.get(fv.Field_API_Name__c)).equalsIgnoreCase(String.valueOf(be.get(fv.Field_API_Name__c))) && !setId.contains(ibe.Id)) { isMatch = true; }
							if ((fv.Validation_Type__c == 'Punctuations' || fv.Validation_Type__c == 'Email Domain' || fv.Validation_Type__c == 'Suffix') && !setId.contains(ibe.Id)) { isMatch = true; }
							if (isMatch){
								BillingEntityWrap bew = new BillingEntityWrap(ibe.Id, ibe.Name, '', ibe.CurrencyIsoCode, ibe.Billing_Address__c, ibe.Shipping_Address__c);
								bew.country = ibe.Country__c;
								bew.VATNumber = ibe.VAT_Number__c;
								bew.errorMessage = fv.Error_Message__c;
								matchesFound.add(bew);
								inform = true;
								setId.add(ibe.Id);
							}
						}
					}
				}
			}
		}

		mso.put('matchesFound', matchesFound);
		mso.put('prevent', prevent);
		mso.put('inform', inform);

		System.debug('iCloudius - Fields validation results: ' + JSON.serializePretty(mso));
		return JSON.serialize(mso);
	}

	public static String getWhereCluase(BillingEntityFieldValidation__mdt fv, Billing_Entity__c be){
		String res = '';
		String toMatch = (String)be.get(fv.Field_API_Name__c);
		toMatch = toMatch.replaceAll('[(),;\\."\']', '');

		if (fv.Validation_Type__c == 'Exact Match' || fv.Validation_Type__c == 'Upper/Lower case') {
			res = fv.Field_API_Name__c + ' = \'' + toMatch + '\'';
		}
		if (fv.Validation_Type__c == 'Punctuations'){
			res = fv.Field_API_Name__c + ' LIKE \'%' + toMatch + '%\'';
		}
		if (fv.Validation_Type__c == 'Email Domain'){
			if (toMatch.contains('@')) toMatch = toMatch.split('@')[1];
			res = res + fv.Field_API_Name__c + ' LIKE \'%@' + toMatch + '\'';
		}
		if (fv.Validation_Type__c == 'Suffix'){
			for (ValidationSuffixes__mdt s: fv.Billing_Entity_Field_Validation_Suffixes__r) {
				toMatch = toMatch.remove(s.MasterLabel);
			}
			res = res + fv.Field_API_Name__c + ' = \'' + toMatch + '\'';
		}

		return res;
	}
	
	@AuraEnabled(cacheable=false)
	public static string testUniquness(String vatNumber, String cBillingCurrency, String cCountry, String cCity, String cName){
		String res = '';
		String key = BillingEntityHandler.UniquenessKey(vatNumber, cBillingCurrency, cCountry, cCity, cName);
		System.debug('iCloudius - Key: ' + key);
		List <Billing_Entity__c> lbe = [SELECT Id, Name FROM Billing_Entity__c WHERE Unique_Key__c =: key];

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

	@AuraEnabled(cacheable=true)
	public static string searchDB(String objectName, String searchText, Integer lim, String VATvalue, String VATno){

		// searchText = '\'%' + String.escapeSingleQuotes(searchText.trim()) + '%\'';
		String query =  'SELECT ' + VATno;
		query += ', Id FROM Billing_Entity__c WHERE Status__c = \'Active\' AND ' + VATno + ' = ' + VATvalue;

		if (lim != null){
			query += ' LIMIT ' + lim;
		}

		List<sObject> sobjList = Database.query(query);
		List<ResultWrapper> lstRet = new List<ResultWrapper>();

		for(SObject s : sobjList){
			ResultWrapper obj = new ResultWrapper();
			obj.objName = objectName;
			obj.text = String.valueOf(s.get(VATno));
			lstRet.add(obj);
		}

		return JSON.serialize(lstRet);
	}

	public class ResultWrapper {
		public String objName { get; set; }
		public String text { get; set; }
		public String val { get; set; }
	}

	@AuraEnabled
	public static Map <String, object> doRelate(Id oppId, Id BEId){
		Map <String, object> mso = new Map <String, object>();
		List<Opportunity> lo = [SELECT Id, Name, AccountId, Account.ParentId FROM Opportunity WHERE Id =: oppId LIMIT 1];
		Account oppAcc = null;
		if (lo != null && !lo.isEmpty()){
			lo[0].Billing_Entity__c = BEId;
			oppAcc = new Account(Id = lo[0].AccountId, Latest_Billing_Entity__c = BEId);
			System.debug('iCloudius - Updated Opportunity:\n' + JSON.serializePretty(lo[0]));
			try{
				if(lo[0].Account.ParentId != null){
					List<Company_Billing__c> lcb = [SELECT Id, Name FROM Company_Billing__c WHERE Billing_Entity__c =: BEId AND Company__c =: lo[0].Account.ParentId];
					if (lcb == null || lcb.isEmpty()){
						System.debug('iCloudius - Creating Company Billing');
						Company_Billing__c cb = new Company_Billing__c(Billing_Entity__c = BEId, Company__c = lo[0].Account.ParentId);

						insert cb;
					}
				}

				update lo;

				if (oppAcc != null){
					update oppAcc;
				}

				List <Billing_Entity__c> lbe = [SELECT Id, Name FROM Billing_Entity__c WHERE Id =: BEId];
				if (lbe != null && !lbe.isEmpty()){
					mso.put('related_be', new Map <String, String> { 'val' => BEId, 'text' => lbe[0].Name });
				}

				mso.put('status', 'success');
			}catch(Exception ex){
				mso.put('error', ex.getMessage());
				mso.put('status', 'fail');
				System.debug('iCloudius - Exception relating billing entity: ' + ex.getStackTraceString());
			}
		}
		System.debug('iCloudius - doRelate response:\n' + JSON.serializePretty(mso));
		return mso;
	}
	@AuraEnabled(cacheable=true)
	public static String CallVatService(String countryName, String vatNumber){
		system.debug('### countryName: ' + countryName);
		system.debug('### vatNumber: ' + vatNumber);
		return VatVerificationService.CallVatService(countryName,vatNumber);
	}

	public class BillingEntityWrap {
		public Id bEId {get; set;}
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
		public String VATNumber {
			get {
				return VATNumber == null ? '' : VATNumber;
			} set; 
		}
		public String country {
			get {
				return country == null ? '' : country;
			} set; 
		}
		public Boolean selected {
			get {
				return selected == null ? false : true;
			} Set; }
		public String errorMessage {
			get {
				return errorMessage == null ? '' : errorMessage;
			} set; }

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

	//Start Tal - VAT Logic
	@AuraEnabled(cacheable=true)
	public static String getValuesCallVatService(String BEId){
		List<Billing_Entity__c> beToSearch = [SELECT Id, VAT_Number__c, Shipping_Country_G__c FROM Billing_Entity__c WHERE Id =: BEId];
		String getVatVerification = VatVerificationService.CallVatService(beToSearch[0].Shipping_Country_G__c, beToSearch[0].VAT_Number__c);
		return getVatVerification;
	}

	@AuraEnabled
	public static void updateBillingEntityFields(Id BEId, String customerVat, String vatNumber, String vatServiceStatus){
		String getVatServiceStatus = '';
		
		List<Billing_Entity__c> beToUpdate = [SELECT Id, Customer_Has_VAT_Number__c, VAT_Number__c, Last_VAT_Validation_Date__c FROM Billing_Entity__c WHERE Id =: BEId];
		if(!beToUpdate.isEmpty()){
			beToUpdate[0].Customer_Has_VAT_Number__c = customerVat;
			if(customerVat == 'No'){
				beToUpdate[0].VAT_Number__c = '';
			}

			else if(customerVat == 'Yes'){
				beToUpdate[0].VAT_Number__c = vatNumber;
			}
			
			if(vatServiceStatus != 'irrelevant'){
				beToUpdate[0].Last_VAT_Validation_Date__c = System.today();
			}
			Database.update(beToUpdate[0]);
		}
	}

	@AuraEnabled
	public static String isVATrequiresChecking(){
		String getVatServiceStatus = '';

		Apex_Services_Status__mdt vatServiceStatus = [SELECT Id, Label, Status__c FROM Apex_Services_Status__mdt WHERE Label = 'VatService'][0];
		getVatServiceStatus = vatServiceStatus.Status__c;

		return getVatServiceStatus;
	}
	//End Tal - VAT Logic
}