public class CreatePartnerUserCtrl {
    public static Boolean firstRun = true;

	public class resWrapper {
        @AuraEnabled
        public Id existingUserId {get;set;}
        @AuraEnabled
		public List<String> contactFieldNamesList {get;set;}
		@AuraEnabled
		public Boolean displayWelcomeEmailCheckbox {get;set;}

        public resWrapper(Id existingUserId){
			this.existingUserId = existingUserId;
        }

		public resWrapper(List<String> contactFieldNamesList, Boolean displayWelcomeEmailCheckbox){
			this.contactFieldNamesList = contactFieldNamesList;
			this.displayWelcomeEmailCheckbox = displayWelcomeEmailCheckbox;
        }
    }

	@AuraEnabled
	public static resWrapper getFieldsList(Id contactId, String email, Id accountId, Boolean isPartner, String approvalStatus){
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
			User myUser = [select Team__c from User where Id =: UserInfo.getUserId()];
			String teamName = [select Value__c from Environment_Variable__mdt where DeveloperName = 'Community_Users_Team_For_Welcome_Email' limit 1].Value__c;
			return new resWrapper(contactFieldNamesList, myUser.Team__c == teamName);
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
		}
	}

	@AuraEnabled
	public static User submitNewUserRequest(Id contactId, Contact contactToUpdate, String approvalStatus){
		try {
			if(contactToUpdate != null) Database.update(contactToUpdate);
			if(approvalStatus != 'Approved' && contactToUpdate.Partner_Role__c != 'Finance'){
				submitForApproval(contactId);
				return null;
			} else {
				Partners_SharingService.stopAddToEligibleCommissionGroup = true;
				List<User> newUserRecList = createUsers(new Set<Id>{contactId});
				Partners_SharingService.stopAddToEligibleCommissionGroup = false;
				Partners_SharingService.handleEligibleUsersUserRole(newUserRecList, null);
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
		if(!contactsToUpdateUserIdsList.isEmpty()) System.enqueueJob(new updatesObjectsQueueable(contactsToUpdateUserIdsList));
	}
	
	public static void createUsersForApprovedContacts(List<Contact> newContactsList, Map<Id, Contact> oldContactsMap){
		Set<Id> contactIds = new Set<Id>();
		for(Contact con: newContactsList){
			if(con.Community_User_Approved__c && !oldContactsMap.get(con.Id).Community_User_Approved__c){
				contactIds.add(con.Id);
			}
		}
		if(!contactIds.isEmpty()) {
			firstRun = false;
			List<User> newUsersList = createUsers(contactIds);
			updateUserIdsOnContacts(newUsersList);
		}
	}

	private static List<User> createUsers(Set<Id> contactIds){
		List<User> newUsersList = new List<User>();
		try{
			Set<String> contactFieldSet = new Set<String>();
			List<User> usersToSendWelcomeEmail = new List<User>();
			List<Contact> contactsToSendWelcomeEmail = new List<Contact>();
			Map<Id,String> managersUsersMap = new Map<Id,String>();

			List<Create_Community_User_Mapping__mdt> mappingCmtList = [select User_Field_API_Name__c, Contact_Field_API_Name__c, User_Field_Default_Value__c from Create_Community_User_Mapping__mdt];
			for(Create_Community_User_Mapping__mdt cmt: mappingCmtList){
				if(cmt.Contact_Field_API_Name__c != null && cmt.Contact_Field_API_Name__c != '') contactFieldSet.add(cmt.Contact_Field_API_Name__c);
			}
			String dynamicQuery = 'select Id, AccountId, Account.Name, Account.IsPartner, OwnerId, Owner.Email, Send_Welcome_Email__c';
			if(!contactFieldSet.isEmpty()) dynamicQuery += ', ' + String.join(new List<String>(contactFieldSet), ',');
			dynamicQuery += ' from Contact where Id IN: contactIds';
			List<Contact> contactRecList = Database.query(dynamicQuery);
			Map<Id,Contact> contactRecMap = new Map<Id,Contact>(contactRecList);
			Set<Id> accountIds = new Set<Id>();
			for(Contact contactRec: contactRecList){
				accountIds.add(contactRec.AccountId);
			}
			Map<Id,Map<String,Id>> accountRolesMap = Partners_SharingService.getPartnerCompToRoleMap(accountIds);
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
				if(!managersUsersMap.containsKey(newUserRec.ManagerId)) managersUsersMap.put(newUserRec.ManagerId, contactRec.Owner.Email);
				if(accountRolesMap.containsKey(contactRec.AccountId) && accountRolesMap.get(contactRec.AccountId).containsKey('Manager')) newUserRec.IsPrmSuperUser = true;
				else newUserRec.IsPrmSuperUser = false;
			}
			if(!newUsersList.isEmpty()) {
				Database.insert(newUsersList);
				sendEmails(newUsersList, managersUsersMap, contactRecMap);
			}
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

	public static void sendWelcomeEmails(List<Contact> newContactsList, Map<Id, Contact> oldContactsMap){
		Set<Id> usersIds = new Set<Id>();
		for(Contact con: newContactsList){
			if(con.Send_Welcome_Email__c && !oldContactsMap.get(con.Id).Send_Welcome_Email__c && con.Community_User__c != null){
				usersIds.add(con.Community_User__c);
			}
		}
		if(!usersIds.isEmpty()) {
			firstRun = false;
			Map<String,Id> IdsForEmailsMap = getMetadataForEmails();
			List<Messaging.SingleEmailMessage> allEmailsToSend = new List<Messaging.SingleEmailMessage>();
			List<User> usersList = [select Id, ContactId, Email from User where Id IN: usersIds];
			for(User userRec: usersList){
				allEmailsToSend.add(generateEmail(new List<String>{userRec.Email}, userRec.Id, IdsForEmailsMap.get('welcomeEmailTempId'), IdsForEmailsMap.get('orgWideEmailAddressId')));
			}
			if(!Test.isRunningTest() && !allEmailsToSend.isEmpty()) Messaging.sendEmail(allEmailsToSend);
		}
	}

	public static void updateEligibleForCommissionOnUser(List<Contact> newContactsList, Map<Id, Contact> oldContactsMap){
		Set<Id> usersIds = new Set<Id>();
		for(Contact con: newContactsList){
			if(con.Eligible_for_Partners_Commission__c != oldContactsMap.get(con.Id).Eligible_for_Partners_Commission__c && con.Community_User__c != null){
				usersIds.add(con.Community_User__c);
			}
		}
		if(!usersIds.isEmpty()) {
			firstRun = false;
			List<Messaging.SingleEmailMessage> allEmailsToSend = new List<Messaging.SingleEmailMessage>();
			List<User> usersList = [select Id, Contact.Eligible_for_Partners_Commission__c from User where Id IN: usersIds];
			for(User userRec: usersList){
				userRec.Eligible_for_Partners_Commission__c = userRec.Contact.Eligible_for_Partners_Commission__c;
			}
			if(!Test.isRunningTest() && !usersList.isEmpty()) System.enqueueJob(new updatesObjectsQueueable(usersList));
		}
	}

	public static void sendEmails(List<User> newUsersList, Map<Id,String> managersUsersMap, Map<Id,Contact> contactRecMap){
		Map<String,Id> IdsForEmailsMap = getMetadataForEmails();
		List<Messaging.SingleEmailMessage> allEmailsToSend = new List<Messaging.SingleEmailMessage>();
		for(User userRec: newUsersList){
			allEmailsToSend.add(generateEmail(new List<String>{managersUsersMap.get(userRec.ManagerId)}, userRec.ContactId, IdsForEmailsMap.get('approvedEmailTempId'), IdsForEmailsMap.get('orgWideEmailAddressId')));
			if(contactRecMap.containsKey(userRec.ContactId) && contactRecMap.get(userRec.ContactId).Send_Welcome_Email__c){ //welcome email
				allEmailsToSend.add(generateEmail(new List<String>{userRec.Email}, userRec.Id, IdsForEmailsMap.get('welcomeEmailTempId'), IdsForEmailsMap.get('orgWideEmailAddressId')));
			}
		}
		if(!Test.isRunningTest() && !allEmailsToSend.isEmpty()) Messaging.sendEmail(allEmailsToSend);
	}

	private static Messaging.SingleEmailMessage generateEmail(List<String> toAddresses, Id targetObjectId, Id emailTemplateId, Id orgWideEmailAddressId){
		Messaging.SingleEmailMessage renderedEmail = Messaging.renderStoredEmailTemplate(emailTemplateId, targetObjectId, null);
		Messaging.SingleEmailMessage resEmail = new Messaging.SingleEmailMessage();
		resEmail.setSubject(renderedEmail.getSubject());
		resEmail.setHtmlBody(renderedEmail.getHtmlBody());
		resEmail.setOrgWideEmailAddressId(orgWideEmailAddressId);
		resEmail.setToAddresses(toAddresses);
		resEmail.setBccAddresses(new List<String>{'kseniasm@monday.com','avivc@monday.com'});
		resEmail.setReplyTo('noreply@monday.com'); 
		resEmail.setSaveAsActivity(false);
		return resEmail;
	}

	private static Map<String,Id> getMetadataForEmails(){
		Map<String,Id> resMap = new Map<String,Id>();
		List<String> emailTempNamesList = new List<String>();
		Map<String,Id> emailTemplateMap = new Map<String,Id>();
		Map<String,Environment_Variable__mdt> envVarMap = new Map<String,Environment_Variable__mdt>();
		List<String> envVarForEmailTempNamesList = new List<String>{'Community_Users_Welcome_Email_Template','Community_Users_Approved_Email_Template'};
		List<String> allEnvVarNamesList = new List<String>(envVarForEmailTempNamesList);
		allEnvVarNamesList.add('Community_Users_Email_Sender');

		List<Environment_Variable__mdt> envVarNamesList = [select DeveloperName, Value__c from Environment_Variable__mdt where DeveloperName IN: allEnvVarNamesList];
		for(Environment_Variable__mdt envVar: envVarNamesList){
			envVarMap.put(envVar.DeveloperName, envVar);
		}
		for(String envVarName: envVarForEmailTempNamesList){
			emailTempNamesList.add(envVarMap.get(envVarName).Value__c);
		}
		List<EmailTemplate> emailTemplateList = [select Id, DeveloperName from EmailTemplate where DeveloperName IN: emailTempNamesList];
		for(EmailTemplate EmailTempRec: emailTemplateList){
			emailTemplateMap.put(EmailTempRec.DeveloperName, EmailTempRec.Id);
		}
        Id orgWideEmailAddressId = [select Id from orgWideEmailAddress where Address =: envVarMap.get('Community_Users_Email_Sender').Value__c limit 1].Id;
		resMap.put('orgWideEmailAddressId', orgWideEmailAddressId);
		resMap.put('welcomeEmailTempId', emailTemplateMap.get(envVarMap.get('Community_Users_Welcome_Email_Template').Value__c));
		resMap.put('approvedEmailTempId', emailTemplateMap.get(envVarMap.get('Community_Users_Approved_Email_Template').Value__c));
		return resMap;
	}

	private static void submitForApproval(Id contactId){ 
		Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();          
		req.setObjectId(contactId);
		req.setProcessDefinitionNameOrId('Approval_For_Partner_Users');
        req.setSkipEntryCriteria(true);
		Approval.ProcessResult result = Approval.process(req);  
	} 

	private class updatesObjectsQueueable implements System.Queueable {
        private List<sObject> sobjectsToUpdate; 
        public updatesObjectsQueueable(List<sObject> sobjectsToUpdate) {
            this.sobjectsToUpdate = sobjectsToUpdate;
        }
        public void execute(System.QueueableContext ctx) {
            Database.update(sobjectsToUpdate);
        }
    }
}