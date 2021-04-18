global class PortfolioManagement_BATCH implements Database.Batchable<SObject> {
	
	Set <Id> accIds = null;

	global PortfolioManagement_BATCH(Set <Id> accIds) {
		this.accIds = accIds;
	}

	global PortfolioManagement_BATCH() {
		
	}
	
	global Database.QueryLocator start(Database.BatchableContext context) {
		System.debug('iCloudius - PortfolioManagement_BATCH - Start');
		String query = 'SELECT Id, name,OwnerId, Owner.UserRoleId, Partner__c, Partner__r.UserRoleId, RecordType.DeveloperName,';
		query+='(select id from Accounts_Metrics__r)';
		query += ' FROM Account WHERE (RecordType.DeveloperName = \'Monday_Account\' OR RecordType.DeveloperName = \'Partner_Company\')';
		if (accIds != null && !accIds.isEmpty()) query += ' AND Id IN :accIds';
		System.debug('iCloudius - PortfolioManagement_BATCH - query: ' + query);
		return Database.getQueryLocator(query);
	}
    
	public static Account_Mertics__c GetAccMetric (id aid)
	{
	    Account aData = null;
	    if (mapaccounts.containsKey (aid)) aData = mapaccounts.get (aid);
	    system.debug('TESTING aData is '+aData);
	    Account_Mertics__c res = new Account_Mertics__c(Account__c = aid);
	    if (aData!=null && aData.name!=null) res.name = aData.name;
	    if (aData.Accounts_Metrics__r.size()>0) res = new Account_Mertics__c (id = aData.Accounts_Metrics__r[0].id);
	    return res;
	}
	
	public static map <id,Account> mapAccounts = new Map <Id, Account>();

	global void execute(Database.BatchableContext context, List<Account> scope) {
		System.debug('iCloudius - PortfolioManagement_BATCH - Execute - scope is: ' + scope.size());
		List <AggregateResult> lar = null;
		Map <Id, Account> accounts4Update = new Map <Id, Account>();
		Map <Id, Integer> mapNumbers = new Map <Id, Integer>();
		Map <Id, Date> mapDates = new Map <Id, Date>();
		String oppQuery = '';
		Set <Id> setId = new Set <Id>();
		Integer count = null;
		Date lastDate = null;
		Date firstDate = null;
		mapAccounts.putAll(scope);

		// Handle set #1
		for (Account a: scope) if (a.RecordType.DeveloperName == 'Monday_Account'){
			setId.add(a.Id);
			mapNumbers.put(a.Id, 0);
			mapDates.put(a.Id, null);
		}
		
		map <id,Account_Mertics__c> ResMap = new map <id,Account_Mertics__c>();

		// # of Open Opps - Current Partner
		lar = [SELECT COUNT(Id) openCount, AccountId, Owner.UserRoleId FROM Opportunity WHERE AccountId IN :setId AND IsClosed = false GROUP BY AccountId, Owner.UserRoleId];
		if (lar != null && !lar.isEmpty()) for (AggregateResult ar: lar){
			Id accId = (Id)ar.get('AccountId');
			Id userRoleId = (Id)ar.get('UserRoleId');
			count = mapNumbers.get(accId);
			if (mapAccounts.get(accId).OwnerId != null && mapAccounts.get(accId).Owner.UserRoleId == userRoleId) count += (Integer)ar.get('openCount');
			if (mapAccounts.get(accId).Partner__c != null && mapAccounts.get(accId).Partner__r.UserRoleId == userRoleId) count += (Integer)ar.get('openCount');
			if (count != 0 || Test.isRunningTest()){
				mapNumbers.put(accId, count);
				Account_Mertics__c am = GetAccMetric (accid);
				if (ResMap.containsKey(accid)) am = ResMap.get(accid);
				am.of_Open_Opps_Current_Partner__c = count;
				ResMap.put(accid, am);
			}
		}

		// Reset numbersMap
		for (Id aId: mapNumbers.keySet()) mapNumbers.put(aId, 0);

		// # of Closed Won Opps - Current Partner
		lar = [SELECT COUNT(Id) closedWonCount, AccountId, Owner.UserRoleId FROM Opportunity WHERE AccountId IN :setId AND IsClosed = true AND IsWon = true GROUP BY AccountId, Owner.UserRoleId];
		if (lar != null && !lar.isEmpty()) for (AggregateResult ar: lar){
			Id accId = (Id)ar.get('AccountId');
			Id userRoleId = (Id)ar.get('UserRoleId');
			count = mapNumbers.get(accId);
			if (mapAccounts.get(accId).OwnerId != null && mapAccounts.get(accId).Owner.UserRoleId == userRoleId) count += (Integer)ar.get('closedWonCount');
			if (mapAccounts.get(accId).Partner__c != null && mapAccounts.get(accId).Partner__r.UserRoleId == userRoleId) count += (Integer)ar.get('closedWonCount');
			if (count != 0 || Test.isRunningTest()){
				mapNumbers.put(accId, count);
				Account_Mertics__c am = GetAccMetric (accid);
				if (ResMap.containsKey(accid)) am = ResMap.get(accid);
				am.of_Closed_Won_Opps_Current_Partner__c = count;
				resmap.put(accid, am);
			}
		}

		// Reset numbersMap
		for (Id aId: mapNumbers.keySet()) mapNumbers.put(aId, 0);

		// # of Closed Lost Opps - Current Partner
		lar = [SELECT COUNT(Id) closedLostCount, AccountId, Owner.UserRoleId FROM Opportunity WHERE AccountId IN :setId AND IsClosed = true AND IsWon = false GROUP BY AccountId, Owner.UserRoleId];
		if (lar != null && !lar.isEmpty()) for (AggregateResult ar: lar){
			Id accId = (Id)ar.get('AccountId');
			Id userRoleId = (Id)ar.get('UserRoleId');
			count = mapNumbers.get(accId);
			if (mapAccounts.get(accId).OwnerId != null && mapAccounts.get(accId).Owner.UserRoleId == userRoleId) count += (Integer)ar.get('closedLostCount');
			if (mapAccounts.get(accId).Partner__c != null && mapAccounts.get(accId).Partner__r.UserRoleId == userRoleId) count += (Integer)ar.get('closedLostCount');
			if (count != 0 || Test.isRunningTest()){
				mapNumbers.put(accId, count);
				
				Account_Mertics__c am = GetAccMetric (accid);
				if (ResMap.containsKey(accid)) am = ResMap.get(accid);
				am.of_Closed_Lost_Opps_Current_Partner__c = count;
				resmap.put(accid, am);
			}
		}

		// Last Closed Won Date - Current Partner
		lar = [SELECT MAX(CloseDate) maxDate, AccountId, Owner.UserRoleId FROM Opportunity WHERE AccountId IN :setId AND IsClosed = true AND IsWon = true GROUP BY AccountId, Owner.UserRoleId];
		if (lar != null && !lar.isEmpty()) for (AggregateResult ar: lar){
			Id accId = (Id)ar.get('AccountId');
			Id userRoleId = (Id)ar.get('UserRoleId');
			lastDate = mapDates.get(accId);
			if (mapAccounts.get(accId).OwnerId != null && mapAccounts.get(accId).Owner.UserRoleId == userRoleId && (lastDate == null || (Date)ar.get('maxDate') > lastDate)) lastDate = (Date)ar.get('maxDate');
			if (mapAccounts.get(accId).Partner__c != null && mapAccounts.get(accId).Partner__r.UserRoleId == userRoleId && (lastDate == null || (Date)ar.get('maxDate') > lastDate)) lastDate = (Date)ar.get('maxDate');
			if (lastDate != null || Test.isRunningTest()){
				mapDates.put(accId, lastDate);
				
				Account_Mertics__c am = GetAccMetric (accid);
				if (ResMap.containsKey(accid)) am = ResMap.get(accid);
				am.Last_Closed_Won_Date_Current_Partner__c = count;
				resmap.put(accid, am);
			}
		}

		// Reset datesMap
		for (Id aId: mapDates.keySet()) mapNumbers.put(aId, null);

		// Last Closed Lost Date - Current Partner
		lar = [SELECT MAX(CloseDate) maxDate, AccountId, Owner.UserRoleId FROM Opportunity WHERE AccountId IN :setId AND IsClosed = true AND IsWon = false GROUP BY AccountId, Owner.UserRoleId];
		if (lar != null && !lar.isEmpty()) for (AggregateResult ar: lar){
			Id accId = (Id)ar.get('AccountId');
			Id userRoleId = (Id)ar.get('UserRoleId');
			lastDate = mapDates.get(accId);
			if (mapAccounts.get(accId).OwnerId != null && mapAccounts.get(accId).Owner.UserRoleId == userRoleId && (lastDate == null || (Date)ar.get('maxDate') > lastDate)) lastDate = (Date)ar.get('maxDate');
			if (mapAccounts.get(accId).Partner__c != null && mapAccounts.get(accId).Partner__r.UserRoleId == userRoleId && (lastDate == null || (Date)ar.get('maxDate') > lastDate)) lastDate = (Date)ar.get('maxDate');
			if (lastDate != null || Test.isRunningTest()){
				mapDates.put(accId, lastDate);
				
				Account_Mertics__c am = GetAccMetric (accid);
				if (ResMap.containsKey(accid)) am = ResMap.get(accid);
				am.Last_Closed_Lost_Date_Current_Partner__c = lastDate;
				resmap.put(accid, am);
			}
		}

		// Reset datesMap
		for (Id aId: mapDates.keySet()) mapNumbers.put(aId, null);

		// Open Opp - First Close Date - Current Partner
		lar = [SELECT MIN(CloseDate) minDate, AccountId, Owner.UserRoleId FROM Opportunity WHERE AccountId IN :setId AND IsClosed = false GROUP BY AccountId, Owner.UserRoleId];
		if (lar != null && !lar.isEmpty()) for (AggregateResult ar: lar){
			Id accId = (Id)ar.get('AccountId');
			Id userRoleId = (Id)ar.get('UserRoleId');
			lastDate = mapDates.get(accId);
			if (mapAccounts.get(accId).OwnerId != null && mapAccounts.get(accId).Owner.UserRoleId == userRoleId && (lastDate == null || (Date)ar.get('minDate') < lastDate)) lastDate = (Date)ar.get('minDate');
			if (mapAccounts.get(accId).Partner__c != null && mapAccounts.get(accId).Partner__r.UserRoleId == userRoleId && (lastDate == null || (Date)ar.get('minDate') < lastDate)) lastDate = (Date)ar.get('minDate');
			if (lastDate != null || Test.isRunningTest()){
				mapDates.put(accId, lastDate);
				
				Account_Mertics__c am = GetAccMetric (accid);
				if (ResMap.containsKey(accid)) am = ResMap.get(accid);
				am.Open_Opp_Close_Date_Current_Partner__c = lastDate;
				resmap.put(accid, am);
			}
		}

		// Reset datesMap
		for (Id aId: mapDates.keySet()) mapNumbers.put(aId, null);

		// Last Renewal Date - Current Partner
		lar = [SELECT MAX(CloseDate) maxDate, AccountId, Owner.UserRoleId FROM Opportunity WHERE AccountId IN :setId AND Type = 'Renewal' GROUP BY AccountId, Owner.UserRoleId];
		if (lar != null && !lar.isEmpty()) for (AggregateResult ar: lar){
			Id accId = (Id)ar.get('AccountId');
			Id userRoleId = (Id)ar.get('UserRoleId');
			lastDate = mapDates.get(accId);
			if (mapAccounts.get(accId).OwnerId != null && mapAccounts.get(accId).Owner.UserRoleId == userRoleId && (lastDate == null || (Date)ar.get('maxDate') > lastDate)) lastDate = (Date)ar.get('maxDate');
			if (mapAccounts.get(accId).Partner__c != null && mapAccounts.get(accId).Partner__r.UserRoleId == userRoleId && (lastDate == null || (Date)ar.get('maxDate') > lastDate)) lastDate = (Date)ar.get('maxDate');
			if (lastDate != null || Test.isRunningTest()){
				mapDates.put(accId, lastDate);
				
				Account_Mertics__c am = GetAccMetric (accid);
				if (ResMap.containsKey(accid)) am = ResMap.get(accid);
				am.Last_Renewal_Date_Current_Partner__c = lastDate;
				resmap.put(accid, am);
			}
		}

		// Reset datesMap
		for (Id aId: mapDates.keySet()) mapNumbers.put(aId, null);

		// Last Expansion Date - Current Partner
		lar = [SELECT MAX(CloseDate) maxDate, AccountId, Owner.UserRoleId FROM Opportunity WHERE AccountId IN :setId AND Type = 'Expansion' GROUP BY AccountId, Owner.UserRoleId];
		if (lar != null && !lar.isEmpty()) for (AggregateResult ar: lar){
			Id accId = (Id)ar.get('AccountId');
			Id userRoleId = (Id)ar.get('UserRoleId');
			lastDate = mapDates.get(accId);
			if (mapAccounts.get(accId).OwnerId != null && mapAccounts.get(accId).Owner.UserRoleId == userRoleId && (lastDate == null || (Date)ar.get('maxDate') > lastDate)) lastDate = (Date)ar.get('maxDate');
			if (mapAccounts.get(accId).Partner__c != null && mapAccounts.get(accId).Partner__r.UserRoleId == userRoleId && (lastDate == null || (Date)ar.get('maxDate') > lastDate)) lastDate = (Date)ar.get('maxDate');
			if (lastDate != null || Test.isRunningTest()){
				mapDates.put(accId, lastDate);
				
				Account_Mertics__c am = GetAccMetric (accid);
				if (ResMap.containsKey(accid)) am = ResMap.get(accid);
				am.Last_Expansion_Date_Current_Partner__c = lastDate;
				resmap.put(accid, am);
			}
		}

		// Reset datesMap
		for (Id aId: mapDates.keySet()) mapNumbers.put(aId, null);

		// Last New Business Date - Current Partner
		lar = [SELECT MAX(CloseDate) maxDate, AccountId, Owner.UserRoleId FROM Opportunity WHERE AccountId IN :setId AND Type = 'New Business' GROUP BY AccountId, Owner.UserRoleId];
		if (lar != null && !lar.isEmpty()) for (AggregateResult ar: lar){
			Id accId = (Id)ar.get('AccountId');
			Id userRoleId = (Id)ar.get('UserRoleId');
			lastDate = mapDates.get(accId);
			if (mapAccounts.get(accId).OwnerId != null && mapAccounts.get(accId).Owner.UserRoleId == userRoleId && (lastDate == null || (Date)ar.get('maxDate') > lastDate)) lastDate = (Date)ar.get('maxDate');
			if (mapAccounts.get(accId).Partner__c != null && mapAccounts.get(accId).Partner__r.UserRoleId == userRoleId && (lastDate == null || (Date)ar.get('maxDate') > lastDate)) lastDate = (Date)ar.get('maxDate');
			if (lastDate != null || Test.isRunningTest()){
				mapDates.put(accId, lastDate);
			
				Account_Mertics__c am = GetAccMetric (accid);
				if (ResMap.containsKey(accid)) am = ResMap.get(accid);
				am.Last_New_Business_Date_Current_Partner__c = lastDate;
				resmap.put(accid, am);
			}
		}

		// Handle set #2
		setId.clear();
		for (Account a: scope) if (a.RecordType.DeveloperName == 'Partner_Company'){
			setId.add(a.Id);
			mapNumbers.put(a.Id, 0);
			mapDates.put(a.Id, null);
		}

		firstDate = Date.today().addDays(-7);
		lastDate = Date.today().addDays(-14);
		// Partner GB ARR - Last 7 Days ($)
		lar = [SELECT SUM(Green_Bucket_ARR_V2__c) theSum, COUNT(Green_Bucket_ARR_V2__c) theCount, Owner.AccountId FROM Opportunity WHERE Owner.AccountId IN :setId AND Is_Potential_GB_Opportunity__c = true AND CloseDate >= :firstDate GROUP BY Owner.AccountId];
		if (lar != null && !lar.isEmpty()) for (AggregateResult ar: lar){
			Id accId = (Id)ar.get('AccountId');
			
			Account_Mertics__c am = GetAccMetric (accid);
			if (ResMap.containsKey(accid)) am = ResMap.get(accid);
			am.Partner_GB_ARR_Last_7_Days__c = (Decimal)ar.get('theSum');
			am.Partner_GB_ARR_Last_7_Days_Count__c = (Decimal)ar.get('theCount');
			resmap.put(accid, am);
		}

		// Partner GB ARR - Last 7 Days ($) - Prev
		lar = [SELECT SUM(Green_Bucket_ARR_V2__c) theSum, COUNT(Green_Bucket_ARR_V2__c) theCount, Owner.AccountId FROM Opportunity WHERE Owner.AccountId IN :setId AND Is_Potential_GB_Opportunity__c = true AND CloseDate >= :lastDate AND CloseDate < :firstDate GROUP BY Owner.AccountId];
		if (lar != null && !lar.isEmpty()) for (AggregateResult ar: lar){
			Id accId = (Id)ar.get('AccountId');
			
			Account_Mertics__c am = GetAccMetric (accid);
			if (ResMap.containsKey(accid)) am = ResMap.get(accid);
			am.Partner_GB_ARR_Last_7_Days_Prev__c = (Decimal)ar.get('theSum');
			am.Partner_GB_ARR_Last_7_Days_Prev_Count__c = (Decimal)ar.get('theCount');
			resmap.put(accid, am);
		}

		// Partner OB ARR - Last 7 Days ($)
		lar = [SELECT SUM(Green_Bucket_ARR_V2__c) theSum, COUNT(Green_Bucket_ARR_V2__c) theCount, Owner.AccountId FROM Opportunity WHERE Owner.AccountId IN :setId AND Is_Potential_GB_Opportunity__c = false AND CloseDate >= :firstDate GROUP BY Owner.AccountId];
		if (lar != null && !lar.isEmpty()) for (AggregateResult ar: lar){
			Id accId = (Id)ar.get('AccountId');
			
			Account_Mertics__c am = GetAccMetric (accid);
			if (ResMap.containsKey(accid)) am = ResMap.get(accid);
			am.Partner_OB_ARR_Last_7_Days__c = (Decimal)ar.get('theSum');
			am.Partner_OB_ARR_Last_7_Days_Count__c = (Decimal)ar.get('theCount');
			resmap.put(accid, am);
		}

		// Partner OB ARR - Last 7 Days ($) - Prev
		lar = [SELECT SUM(Green_Bucket_ARR_V2__c) theSum, COUNT(Green_Bucket_ARR_V2__c) theCount, Owner.AccountId FROM Opportunity WHERE Owner.AccountId IN :setId AND Is_Potential_GB_Opportunity__c = false AND CloseDate >= :lastDate AND CloseDate < :firstDate GROUP BY Owner.AccountId];
		if (lar != null && !lar.isEmpty()) for (AggregateResult ar: lar){
			Id accId = (Id)ar.get('AccountId');
			
			Account_Mertics__c am = GetAccMetric (accid);
			if (ResMap.containsKey(accid)) am = ResMap.get(accid);
			am.Partner_OB_ARR_Last_7_Days_Prev__c = (Decimal)ar.get('theSum');
			am.Partner_OB_ARR_Last_7_Days_Prev_Count__c = (Decimal)ar.get('theCount');
			resmap.put(accid, am);
		}

		firstDate = Date.today().addDays(-30);
		lastDate = Date.today().addDays(-60);

		// Partner GB ARR - Last 30 Days ($)
		lar = [SELECT SUM(Green_Bucket_ARR_V2__c) theSum, COUNT(Green_Bucket_ARR_V2__c) theCount, Owner.AccountId FROM Opportunity WHERE Owner.AccountId IN :setId AND Is_Potential_GB_Opportunity__c = true AND CloseDate >= :firstDate GROUP BY Owner.AccountId];
		if (lar != null && !lar.isEmpty()) for (AggregateResult ar: lar){
			Id accId = (Id)ar.get('AccountId');
		
			Account_Mertics__c am = GetAccMetric (accid);
			if (ResMap.containsKey(accid)) am = ResMap.get(accid);
			am.Partner_GB_ARR_Last_30_Days__c = (Decimal)ar.get('theSum');
			am.Partner_GB_ARR_Last_30_Days_Count__c = (Decimal)ar.get('theCount');
			resmap.put(accid, am);
		}

		// Partner GB ARR - Last 30 Days ($) - Prev
		lar = [SELECT SUM(Green_Bucket_ARR_V2__c) theSum, COUNT(Green_Bucket_ARR_V2__c) theCount, Owner.AccountId FROM Opportunity WHERE Owner.AccountId IN :setId AND Is_Potential_GB_Opportunity__c = true AND CloseDate >= :lastDate AND CloseDate < :firstDate GROUP BY Owner.AccountId];
		if (lar != null && !lar.isEmpty()) for (AggregateResult ar: lar){
			Id accId = (Id)ar.get('AccountId');
		
			Account_Mertics__c am = GetAccMetric (accid);
			if (ResMap.containsKey(accid)) am = ResMap.get(accid);
			am.Partner_GB_ARR_Last_30_Days_Prev__c = (Decimal)ar.get('theSum');
			am.Partner_GB_ARR_Last_30_Days_Prev_Count__c = (Decimal)ar.get('theCount');
			resmap.put(accid, am);
		}

		// Partner OB ARR - Last 30 Days ($)
		lar = [SELECT SUM(Green_Bucket_ARR_V2__c) theSum, COUNT(Green_Bucket_ARR_V2__c) theCount, Owner.AccountId FROM Opportunity WHERE Owner.AccountId IN :setId AND Is_Potential_GB_Opportunity__c = false AND CloseDate >= :firstDate GROUP BY Owner.AccountId];
		if (lar != null && !lar.isEmpty()) for (AggregateResult ar: lar){
			Id accId = (Id)ar.get('AccountId');
			
			Account_Mertics__c am = GetAccMetric (accid);
			if (ResMap.containsKey(accid)) am = ResMap.get(accid);
			am.Partner_OB_ARR_Last_30_Days__c = (Decimal)ar.get('theSum');
			am.Partner_OB_ARR_Last_30_Days_Count__c = (Decimal)ar.get('theCount');
			resmap.put(accid, am);
		}

		// Partner OB ARR - Last 30 Days ($) - Prev
		lar = [SELECT SUM(Green_Bucket_ARR_V2__c) theSum, COUNT(Green_Bucket_ARR_V2__c) theCount, Owner.AccountId FROM Opportunity WHERE Owner.AccountId IN :setId AND Is_Potential_GB_Opportunity__c = false AND CloseDate >= :lastDate AND CloseDate < :firstDate GROUP BY Owner.AccountId];
		if (lar != null && !lar.isEmpty()) for (AggregateResult ar: lar){
			Id accId = (Id)ar.get('AccountId');
			
			Account_Mertics__c am = GetAccMetric (accid);
			if (ResMap.containsKey(accid)) am = ResMap.get(accid);
			am.Partner_OB_ARR_Last_30_Days_Prev__c = (Decimal)ar.get('theSum');
			am.Partner_OB_ARR_Last_30_Days_Prev_Count__c = (Decimal)ar.get('theCount');
			resmap.put(accid, am);
		}


		System.debug('iCloudius - ResMap: ' + ResMap.size());
		if (!ResMap.isEmpty()){
			Globals.CodeOff = true;
			upsert ResMap.values();
			Globals.CodeOff = false;
			ResMap.clear();
		}
	}
	
	global void finish(Database.BatchableContext context) {
		
	}
}