public class Ctrl_CreateCommunityUser  {
	@AuraEnabled
	public static Map <String, Object> getInitialParams(Id cId){
		System.debug('iCloudius - Getting params for Contact: ' + cId);
		Map <String, Object> mso = new Map <String, Object>();
		String errorMsg = '';
		Contact c = getContact(cId);
		User u = getUser(c);
		if (u != null) mso.put('user_error', 'A user already exists for this contact');
		if (c != null){
			if (c.FirstName == null) errorMsg += 'First Name';
			if (c.LastName == null) errorMsg += (errorMsg == '' ? 'Last Name' : ', Last Name');
			if (c.Email == null) errorMsg += (errorMsg == '' ? 'Email' : ', Email');
			if (c.Title == null) errorMsg += (errorMsg == '' ? 'Title' : ', Title');
			if (c.MobilePhone == null) errorMsg += (errorMsg == '' ? 'Mobile Phone' : ', Mobile Phone');
			if (c.Contact_Role__c == null) errorMsg += (errorMsg == '' ? 'Contact Role' : ', Contact Role');
			if (errorMsg != '') errorMsg = 'One of the data points needed to create the user is missing. Please make sure that the following fields are populated correctly: [' + errorMsg + ']';
			if (c.Account.Owner.UserRoleId == null) mso.put('account_error', 'Contact account owner has no role, cannot enable as partner');
		}
		if (errorMsg != ''){
			mso.put('contact_error', errorMsg);
		} else if (!mso.containsKey('user_error') && !mso.containsKey('account_error')) {
			errorMsg = createUser(c);
			mso.put('create_message', errorMsg);
		}
		System.debug('iCloudius - Initial Params:\n' + JSON.serializePretty(mso));
		return mso;
	}

	public static User getUser(Contact c){
		User u = null;
		List <User> lu = [SELECT Id, Name FROM User WHERE ContactId =:c.Id];
		if (lu != null && !lu.isEmpty()) u = lu[0];
		System.debug('iCloudius - Found User: ' + u);
		return u;
	}

	public static Contact getContact(Id cId){
		Contact c = null;
		List <Contact> lc = [SELECT Id, Name, FirstName, LastName, Email, Title, MobilePhone, AccountId, Account.Name, Account.Owner.UserRoleId, Contact_Role__c FROM Contact WHERE Id =:cId];
		if (lc != null && !lc.isEmpty()) c = lc[0];
		return c;
	}

	public static String createUser(Contact c){
		String res = 'OK';
		User u = new User();
		u.ProfileID = Label.DefaultPartnerProfile;
		u.FirstName = c.FirstName;
		u.LastName = c.LastName;
		u.Email = c.Email;
		u.Username = c.Email;
		u.CommunityNickname = c.FirstName;
		u.CompanyName = c.Account.Name;
		u.ContactId = c.Id;
		u.Alias = c.FirstName.left(1) + c.LastName.left(4);
		u.Function__c = 'Partner';
		u.TimeZoneSidKey = 'GMT';
		u.LanguageLocaleKey = 'en_US';
		u.LocaleSidKey = 'en_GB';
		u.EmailEncodingKey = 'UTF-8';
		u.CurrencyIsoCode = 'USD';
		u.ManagerId = UserInfo.getUserId();
		u.IsPrmSuperUser = true;
		u.Created_date__c = Date.today();
		u.Contact_Role__c = c.Contact_Role__c;
		try{
			insert u;
			res += ':' + u.Id;
		} catch (Exception ex){
			res = ex.getMessage();
			System.debug('iCloudius - Exception creating the User: ' + ex.getStackTraceString());
			if (res.containsIgnoreCase('DUPLICATE_USERNAME')) {
				System.debug('iCloudius - Trying again');
				res = 'OK';
				u.Username = u.Username + '.monday';
				try{
					insert u;
					res += ':' + u.Id;
				} catch (Exception Exc){
					res = Exc.getMessage();
					System.debug('iCloudius - Exception creating the User second time: ' + Exc.getStackTraceString());
				}
			}
		}
		if (res.containsIgnoreCase('first error:')){
			res = res.substringAfter('first error:');
		}
		System.debug('iCloudius - createUser response: ' + res);
		return res;
	}
}