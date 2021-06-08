public class CreatePartnerUserCtrl {
    public static Boolean firstRun = true;

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
	public static resWrapper getFieldsList(Id contactId, String email, Id accountId, Boolean isPartner, String approvalStatus){
		// permissions check
		String profileName = [Select Id, Name from Profile where Id =: UserInfo.getProfileId()].Name;
		if(!profileName.containsIgnoreCase('System Administrator')) throw new AuraHandledException('Oops! You are not allowed to run this action. Please contact Biz Ops.');
		if(approvalStatus == 'Pending') throw new AuraHandledException('Oops! This contact is pending approval to grant access to Salesforce and Big Brain. Please wait for the approval process to be completed.');
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
	public static User submitNewUserRequest(Id contactId, Contact contactToUpdate, String approvalStatus){
		try {
			if(contactToUpdate != null) Database.update(contactToUpdate);
			if(approvalStatus != 'Approved'){
				submitForApproval(contactId);
				return null;
			} else {
				List<User> newUserRecList = createUsers(new Set<Id>{contactId});
				updateUserIdsOnContacts(newUserRecList);
				return new User(Id = newUserRecList.get(0).Id, Username = newUserRecList.get(0).Username);
			}
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
		}
	}

	private static void updateUserIdsOnContacts(List<User> newUserRecList){
		List<Contact> contactsToUpdateUserIdsList = new List<Contact>();
		for(User newUserRec: newUserRecList){
			contactsToUpdateUserIdsList.add(new Contact(Id = newUserRec.ContactId, Community_User__c = newUserRec.Id));
		}
		if(!contactsToUpdateUserIdsList.isEmpty()) System.enqueueJob(new updateContactsQueueable(contactsToUpdateUserIdsList));
	}
	
	public static void createUsersForApprovedContacts(List<Contact> newContactsList, Map<Id, Contact> oldContactsMap){
		Set<Id> contactIds = new Set<Id>();
		for(Contact con: newContactsList){
			system.debug('ksenia ###: '+ con.Community_User_Approved__c);
			if(con.Community_User_Approved__c && !oldContactsMap.get(con.Id).Community_User_Approved__c){
				contactIds.add(con.Id);
			}
		}
		if(!contactIds.isEmpty()) {
			system.debug('##ksenia: ' + contactIds);
			firstRun = false;
			List<User> newUsersList = createUsers(contactIds);
			updateUserIdsOnContacts(newUsersList);
		}
	}

	private static List<User> createUsers(Set<Id> contactIds){
		List<User> newUsersList = new List<User>();
		try{
			Set<String> contactFieldSet = new Set<String>();
			List<Create_Community_User_Mapping__mdt> mappingCmtList = [select User_Field_API_Name__c, Contact_Field_API_Name__c, User_Field_Default_Value__c from Create_Community_User_Mapping__mdt];
			for(Create_Community_User_Mapping__mdt cmt: mappingCmtList){
				if(cmt.Contact_Field_API_Name__c != null && cmt.Contact_Field_API_Name__c != '') contactFieldSet.add(cmt.Contact_Field_API_Name__c);
			}
			String dynamicQuery = 'select Id, Account.Name, Account.IsPartner, OwnerId, Send_Welcome_Email__c';
			if(!contactFieldSet.isEmpty()) dynamicQuery += ', ' + String.join(new List<String>(contactFieldSet), ',');
			dynamicQuery += ' from Contact where Id IN: contactIds';
			List<Contact> contactRecList = Database.query(dynamicQuery);
			List<Contact> contactsToSendWelcomeEmail = new List<Contact>();
			for(Contact contactRec: contactRecList){
				User newUserRec = new User();
				for(Create_Community_User_Mapping__mdt cmt: mappingCmtList){
					if(cmt.User_Field_Default_Value__c != null && cmt.User_Field_Default_Value__c != '') { // default values
						if(cmt.User_Field_Default_Value__c == 'true' || cmt.User_Field_Default_Value__c == 'false'){
							newUserRec.put(cmt.User_Field_API_Name__c, Boolean.valueOf(cmt.User_Field_Default_Value__c));
						} else { // fields mapping from contact to user
							newUserRec.put(cmt.User_Field_API_Name__c, cmt.User_Field_Default_Value__c);
						}
					} else if (cmt.Contact_Field_API_Name__c != null && cmt.Contact_Field_API_Name__c != ''){
						newUserRec.put(cmt.User_Field_API_Name__c, contactRec.get(cmt.Contact_Field_API_Name__c));
					}
				}
				String partnerProfileName = [select Value__c from Environment_Variable__mdt where DeveloperName = 'Default_Partner_Profile' limit 1].Value__c;
				Id partnerProfileId = [Select Id from Profile where Name =: partnerProfileName limit 1].Id;
				newUserRec.ProfileId = partnerProfileId;
				newUserRec.CompanyName = contactRec.Account.Name;
				newUserRec.Created_date__c = Date.today();
				newUserRec.Alias = newUserRec.FirstName.left(1) + newUserRec.LastName.left(6);
				newUserRec.CommunityNickname = newUserRec.Alias;
				newUserRec.ManagerId = contactRec.OwnerId;
				newUserRec.ContactId = contactRec.Id;
				newUsersList.add(newUserRec);
				if(contactRec.Send_Welcome_Email__c) contactsToSendWelcomeEmail.add(contactRec);
			}
			if(!newUsersList.isEmpty()) Database.insert(newUsersList);

			Map<Id,Contact> contactRecMap = new Map<Id,Contact>(contactRecList);
			List<User> usersToSendWelcomeEmail = new List<User>();
			for(User userRec: newUsersList){
				if(contactRecMap.containsKey(userRec.ContactId) && contactRecMap.get(userRec.ContactId).Send_Welcome_Email__c){
					usersToSendWelcomeEmail.add(userRec);
				}
			}
			if(!usersToSendWelcomeEmail.isEmpty()) sendWelcomeEmail(usersToSendWelcomeEmail);
			
			return newUsersList;
		} catch (Exception e) {
			if(e.getMessage().containsIgnoreCase('DUPLICATE_USERNAME')){
				for(User userRec: newUsersList){
					userRec.Username = userRec.Username + '.monday';
				}
				try {
					Database.insert(newUsersList);
					return newUsersList;
				} catch (Exception secondEx) {
					throw new AuraHandledException(secondEx.getMessage() + '\n' + secondEx.getStackTraceString());
				}
			} else {
				throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
			}
		}
	}

	public static void sendWelcomeEmail(List<User> usersList){
		String welcomeEmailTempDeveloperName = [select Value__c from Environment_Variable__mdt where DeveloperName = 'Community_Users_Welcome_Email_Template' limit 1].Value__c;
		Id welcomeEmailTempId = [select Id from EmailTemplate where DeveloperName =: welcomeEmailTempDeveloperName limit 1].Id;
		List<Messaging.SingleEmailMessage> renderedEmailsList = new List<Messaging.SingleEmailMessage>();
		for(User userRec: usersList){
			Messaging.SingleEmailMessage renderedEmail = Messaging.renderStoredEmailTemplate(welcomeEmailTempId, userRec.Id, null);
			renderedEmail.setToAddresses(new List<String>{userRec.Email});
		}
		if(!test.isRunningTest() && !renderedEmailsList.isEmpty()) Messaging.sendEmail(renderedEmailsList);
	}

	private static void submitForApproval(Id contactId){ 
		Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();          
		req.setObjectId(contactId);
		req.setProcessDefinitionNameOrId('Approval_For_Partner_Users');
        req.setSkipEntryCriteria(true);
		Approval.ProcessResult result = Approval.process(req);  
	} 

	private class updateContactsQueueable implements System.Queueable {
        private List<Contact> contactsToUpdateList; 
        public updateContactsQueueable(List<Contact> contactsToUpdateList) {
            this.contactsToUpdateList = contactsToUpdateList;
        }
        public void execute(System.QueueableContext ctx) {
            Database.update(contactsToUpdateList);
        }
    }
}