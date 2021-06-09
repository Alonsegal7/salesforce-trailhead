public class Ctrl_CreateCommunityUser  {

	public class resWrapper {
        @AuraEnabled
        public Id existingUserId {get;set;}
        @AuraEnabled
		public List<String> contactFieldNamesList {get;set;}

        public resWrapper(Id existingUserId){
			this.existingUserId = existingUserId;
        }

		public resWrapper(List<String> contactFieldNamesList){
			this.contactFieldNamesList = contactFieldNamesList;
        }
    }

	@AuraEnabled
	public static resWrapper getFieldsList(Id contactId, String email, Id accountId, Boolean isPartner){
		// permissions check
		String profileName = [Select Id, Name from Profile where Id =: UserInfo.getProfileId()].Name;
		if(!profileName.containsIgnoreCase('System Administrator')) throw new AuraHandledException('Oops! You are not allowed to run this action. Please contact Biz Ops.');

		try {
			// enable partner account
			if(!isPartner) Database.update(new Account(Id = accountId, IsPartner = true));
			// find exising users
			String dynamicQuery = 'select Id from User where ContactId = \'' + contactId + '\'';
			if(email != '') dynamicQuery += ' or Email = \'' + email + '\' limit 1';
			List<User> matchingUserList = Database.query(dynamicQuery);
			if(matchingUserList != null && !matchingUserList.isEmpty()) return new resWrapper(matchingUserList.get(0).Id);
			// get contact fieldset
			List<String> contactFieldNamesList = new List<String>();
			for(Schema.FieldSetMember f : SObjectType.Contact.FieldSets.Create_Community_User.getFields()) {
				contactFieldNamesList.add(f.getFieldPath());
			}
			return new resWrapper(contactFieldNamesList);
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
		}
	}

	@AuraEnabled
	public static User createUser(Id contactId, Contact contactToUpdate, Id managerId){
		User newUserRec = new User();
		Set<String> contactFieldSet = new Set<String>();
		try {
			List<Create_Community_User_Mapping__mdt> mappingCmtList = [select User_Field_API_Name__c, Contact_Field_API_Name__c, User_Field_Default_Value__c from Create_Community_User_Mapping__mdt];
			for(Create_Community_User_Mapping__mdt cmt: mappingCmtList){
				if(cmt.Contact_Field_API_Name__c != null && cmt.Contact_Field_API_Name__c != '') contactFieldSet.add(cmt.Contact_Field_API_Name__c);
			}
			String dynamicQuery = 'select Id, Account.Name, Account.IsPartner';
			if(!contactFieldSet.isEmpty()) dynamicQuery += ', ' + String.join(new List<String>(contactFieldSet), ',');
			dynamicQuery += ' from Contact where Id = \'' + contactId + '\'';
			Contact contactRec = Database.query(dynamicQuery);
			for(Create_Community_User_Mapping__mdt cmt: mappingCmtList){
				if(cmt.User_Field_Default_Value__c != null && cmt.User_Field_Default_Value__c != '') { // default values
					if(cmt.User_Field_Default_Value__c == 'true' || cmt.User_Field_Default_Value__c == 'false'){
						newUserRec.put(cmt.User_Field_API_Name__c, Boolean.valueOf(cmt.User_Field_Default_Value__c));
					} else { // fields mapping from contact to user
						newUserRec.put(cmt.User_Field_API_Name__c, cmt.User_Field_Default_Value__c);
					}
				} else if (cmt.Contact_Field_API_Name__c != null && cmt.Contact_Field_API_Name__c != ''){
					if(contactToUpdate != null && contactToUpdate.get(cmt.Contact_Field_API_Name__c) != null){
						newUserRec.put(cmt.User_Field_API_Name__c, contactToUpdate.get(cmt.Contact_Field_API_Name__c));
					} else {
						newUserRec.put(cmt.User_Field_API_Name__c, contactRec.get(cmt.Contact_Field_API_Name__c));
					}
				}
			}
			String partnerProfileName = [select Value__c from Environment_Variable__mdt where DeveloperName = 'Default_Partner_Profile' limit 1].Value__c;
			Id partnerProfileId = [Select Id from Profile where Name =: partnerProfileName limit 1].Id;
			newUserRec.ProfileId = partnerProfileId;
			newUserRec.CompanyName = contactRec.Account.Name;
			newUserRec.Created_date__c = Date.today();
			newUserRec.Alias = newUserRec.FirstName.left(1) + newUserRec.LastName.left(6);
			newUserRec.CommunityNickname = newUserRec.Alias;
			newUserRec.ManagerId = managerId;
			newUserRec.ContactId = contactRec.Id;
			Database.insert(newUserRec);
			if(contactToUpdate != null) System.enqueueJob(new updateContactQueueable(contactToUpdate)); // need to be async update due to user DML action
			return new User(Id = newUserRec.Id, Username = newUserRec.Username);
		} catch (Exception e) {
			if(e.getMessage().containsIgnoreCase('DUPLICATE_USERNAME')){
				newUserRec.Username = newUserRec.Username + '.monday';
				try {
					Database.insert(newUserRec);
					return new User(Id = newUserRec.Id, Username = newUserRec.Username);
				} catch (Exception secondEx) {
					throw new AuraHandledException(secondEx.getMessage() + '\n' + secondEx.getStackTraceString());
				}
			} else {
				throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
			}
		}
	}

	public class updateContactQueueable implements System.Queueable {

        private Contact contactToUpdate;
         
        public updateContactQueueable(Contact contactToUpdate) {
            this.contactToUpdate = contactToUpdate;
        }
        public void execute(System.QueueableContext ctx) {
            Database.update(contactToUpdate);
        }
    }
}