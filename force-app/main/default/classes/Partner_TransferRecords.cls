public class Partner_TransferRecords {    

    @AuraEnabled
    public static String runUserTransfer(Id oldOwnerId, Id newOwnerId){
        try {
            String helpText = ' from '+ oldOwnerId + ' to ' + newOwnerId;
            //accounts
            Batch_PartnerUserTransfer_Accounts accountsBatch = new Batch_PartnerUserTransfer_Accounts(oldOwnerId, newOwnerId);
            //leads
            String query = 'select Id, Name from Lead where OwnerId = \''+oldOwnerId+'\' and Status != \'Nurturing\' and Status != \'Qualified\' and Status != \'Converted\'';
            Batch_SearchAndReplace leadsBatch = new Batch_SearchAndReplace(query,'OwnerId',String.valueOf(newOwnerId), 'Leads Transfer' + helpText);
            //opps
            query = 'select Id, Name from Opportunity where OwnerId = \''+oldOwnerId+'\' and StageName != \'Closed Won\' and StageName != \'Closed Lost\'';
            Batch_SearchAndReplace oppsBatch = new Batch_SearchAndReplace(query,'OwnerId',String.valueOf(newOwnerId), 'Opportunities Transfer' + helpText);
            //sales
            query = 'select Id, Name from Sale__c where Owner__c = \''+oldOwnerId+'\' and Sale_Status__c != \'Complete\'';
            Batch_SearchAndReplace salesBatch = new Batch_SearchAndReplace(query,'Owner__c',String.valueOf(newOwnerId), 'Sales Transfer' + helpText);

            Utilities.cleanFlexQueue();
            Database.executeBatch(accountsBatch,20);
            Database.executeBatch(leadsBatch,20);
            Database.executeBatch(oppsBatch,20);
            Database.executeBatch(salesBatch,20);

            return 'running';
        } catch (Exception e) {
            Utilities.sendEmail('Error in Partner_TransferRecords: ', e.getMessage() + '\n' + e.getStackTraceString(), new List<String>{UserInfo.getUserEmail(),'biztech@monday.com'});
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static String runCpmTransfer(Id partnerAccountId, Id oldCpmId, Id newCpmId, Date startingFrom){
        try {
            Map<String,String> fieldsToValuesMap = new Map<String,String>();
            fieldsToValuesMap.put('Owner_s_Manager__c', String.valueOf(newCpmId));
            fieldsToValuesMap.put('CPM__c', String.valueOf(newCpmId));
            String helpText = ' from '+ oldCpmId + ' to ' + newCpmId;
            Datetime dt = (Datetime) startingFrom;
            String formattedDate = dt.format('yyyy-MM-dd');
            String query = 'select Id, Name from User where managerId = \''+oldCpmId+'\' and Contact.AccountId = \''+partnerAccountId+'\'';
            Batch_SearchAndReplace usersBatch = new Batch_SearchAndReplace(query,'ManagerId',String.valueOf(newCpmId), 'Users Transfer - Manager Update' + helpText);

            Account partnerAccount = [select Name from Account where Id =: partnerAccountId];
            String partnerNameForCompare = '%'+partnerAccount.Name+'%';
            query = 'select Id, Name from Account where (Partner_s_Role_Formula__c like \'' + partnerNameForCompare + '\' or Channel_Partner__c = \''+partnerAccountId+'\') and Owner_s_Manager__c = \''+oldCpmId+'\'';
            Batch_SearchAndReplace accountsBatch = new Batch_SearchAndReplace(query,fieldsToValuesMap, 'Monday Account Transfer - Owner Manager and CPM Update' + helpText);

            query = 'select Id from Account where Id = \'' +partnerAccountId+ '\'';
            Batch_SearchAndReplace accountsBatch2 = new Batch_SearchAndReplace(query,'OwnerId',String.valueOf(newCpmId), 'Partner Account Transfer - Owner Update' + helpText);

            query = 'select Id from Contact where AccountId = \'' +partnerAccountId+ '\'';
            Batch_SearchAndReplace contactsBatch = new Batch_SearchAndReplace(query,'OwnerId',String.valueOf(newCpmId), 'Contact Transfer - Owner Update' + helpText);

            query = 'select Id, Name from Lead where (Owner.UserRole.Name like \'' + partnerNameForCompare + '\' or Partner_Company__c = \''+partnerAccountId+'\') and Owner_s_Manager__c = \''+oldCpmId+'\' and Status != \'Nurturing\' and Status != \'Qualified\' and Status != \'Converted\'';
            Batch_SearchAndReplace leadsBatch = new Batch_SearchAndReplace(query,'Owner_s_Manager__c',String.valueOf(newCpmId), 'Lead Transfer - - Owner Manager Update' + helpText);

            query = 'select Id, Name from Opportunity where (Owner.UserRole.Name like \'' + partnerNameForCompare + '\' or Channel_Partner__c = \''+partnerAccountId+'\') and Owner_s_Manager__c = \''+oldCpmId+'\' and ((StageName != \'Closed Won\' and StageName != \'Closed Lost\') or CloseDate >= '+formattedDate+')';
            Batch_SearchAndReplace oppsBatch = new Batch_SearchAndReplace(query,'Owner_s_Manager__c',String.valueOf(newCpmId), 'Opportunity Transfer - Owner Manager Update' + helpText);

            query = 'select Id, Name from Sale__c where Owner__r.UserRole.Name like \'' + partnerNameForCompare + '\' and Owner_s_Manager__c = \''+oldCpmId+'\' and (Sale_Status__c != \'Complete\' or Close_Date__c >= '+formattedDate+')';
            Batch_SearchAndReplace salesBatch = new Batch_SearchAndReplace(query,'Owner_s_Manager__c',String.valueOf(newCpmId), 'Sale Transfer - Owner Manager Update' + helpText);

            Utilities.cleanFlexQueue();
            Database.executeBatch(usersBatch,20);
            Database.executeBatch(accountsBatch,20);
            Database.executeBatch(accountsBatch2,20);
            Database.executeBatch(contactsBatch,20);
            Database.executeBatch(leadsBatch,20);
            Database.executeBatch(oppsBatch,20);
            Database.executeBatch(salesBatch,20);

            return 'running';
        } catch (Exception e) {
            Utilities.sendEmail('Error in Partner_TransferRecords: ', e.getMessage() + '\n' + e.getStackTraceString(), new List<String>{UserInfo.getUserEmail(),'biztech@monday.com'});
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
}