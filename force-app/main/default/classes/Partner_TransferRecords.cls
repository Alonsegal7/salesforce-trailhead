public class Partner_TransferRecords {    

    @AuraEnabled
    public static String runUserTransfer(Id oldOwnerId, Id newOwnerId){
        try {
            //accounts
            Batch_PartnerUserTransfer_Accounts accountsBatch = new Batch_PartnerUserTransfer_Accounts(oldOwnerId, newOwnerId);
            Database.executeBatch(accountsBatch,20);
            //leads
            String query = 'select Id, Name from Lead where OwnerId = \''+oldOwnerId+'\' and Status != \'Nurturing\' and Status != \'Qualified\' and Status != \'Converted\'';
            Batch_SearchAndReplace leadsBatch = new Batch_SearchAndReplace(query,'OwnerId',String.valueOf(newOwnerId));
            Database.executeBatch(leadsBatch,20);
            //opps
            query = 'select Id, Name from Opportunity where OwnerId = \''+oldOwnerId+'\' and StageName != \'Closed Won\' and StageName != \'Closed Lost\'';
            Batch_SearchAndReplace oppsBatch = new Batch_SearchAndReplace(query,'OwnerId',String.valueOf(newOwnerId));
            Database.executeBatch(oppsBatch,20);
            //sales
            query = 'select Id, Name from Sale__c where Owner__c = \''+oldOwnerId+'\' and Sale_Status__c != \'Complete\'';
            Batch_SearchAndReplace salesBatch = new Batch_SearchAndReplace(query,'Owner__c',String.valueOf(newOwnerId));
            Database.executeBatch(salesBatch,20);
            return 'running';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static String runCpmTransfer(Id partnerAccountId, Id oldCpmId, Id newCpmId, Date startingFrom){
        try {
            Datetime dt = (Datetime) startingFrom;
            String formattedDate = dt.format('yyyy-MM-dd');
            system.debug('$$$ Ksenia formattedDate='+formattedDate);
            String query = 'select Id, Name from User where managerId = \''+oldCpmId+'\' and Contact.AccountId = \''+partnerAccountId+'\'';
            system.debug('$$$ Ksenia='+query);
            Batch_SearchAndReplace usersBatch = new Batch_SearchAndReplace(query,'ManagerId',String.valueOf(newCpmId));
            Database.executeBatch(usersBatch,20);

            Account partnerAccount = [select Name from Account where Id =: partnerAccountId];
            String partnerNameForCompare = '%'+partnerAccount.Name+'%';
            query = 'select Id, Name from Account where (Partner_s_Role_Formula__c like \'' + partnerNameForCompare + '\' or Channel_Partner__c = \''+partnerAccountId+'\') and Owner_s_Manager__c = \''+oldCpmId+'\'';
            system.debug('$$$ Ksenia='+query);
            Batch_SearchAndReplace accountsBatch = new Batch_SearchAndReplace(query,'Owner_s_Manager__c',String.valueOf(newCpmId));
            Database.executeBatch(accountsBatch,20);

            query = 'select Id from Account where Id = \'' +partnerAccountId+ '\'';
            system.debug('$$$ Ksenia='+query);
            Batch_SearchAndReplace accountsBatch2 = new Batch_SearchAndReplace(query,'OwnerId',String.valueOf(newCpmId));
            Database.executeBatch(accountsBatch2,20);

            query = 'select Id, Name from Lead where (Owner.UserRole.Name like \'' + partnerNameForCompare + '\' or Partner_Company__c = \''+partnerAccountId+'\') and Owner_s_Manager__c = \''+oldCpmId+'\' and Status != \'Nurturing\' and Status != \'Qualified\' and Status != \'Converted\'';
            system.debug('$$$ Ksenia='+query);
            Batch_SearchAndReplace leadsBatch = new Batch_SearchAndReplace(query,'Owner_s_Manager__c',String.valueOf(newCpmId));
            Database.executeBatch(leadsBatch,20);

            query = 'select Id, Name from Opportunity where (Owner.UserRole.Name like \'' + partnerNameForCompare + '\' or Channel_Partner__c = \''+partnerAccountId+'\') and Owner_s_Manager__c = \''+oldCpmId+'\' and ((StageName != \'Closed Won\' and StageName != \'Closed Lost\') or CloseDate >= '+formattedDate+')';
            system.debug('$$$ Ksenia='+query);
            Batch_SearchAndReplace oppsBatch = new Batch_SearchAndReplace(query,'Owner_s_Manager__c',String.valueOf(newCpmId));
            Database.executeBatch(oppsBatch,20);

            query = 'select Id, Name from Sale__c where Owner__r.UserRole.Name like \'' + partnerNameForCompare + '\' and Owner_s_Manager__c = \''+oldCpmId+'\' and (Sale_Status__c != \'Complete\' or Close_Date__c >= '+formattedDate+')';
            system.debug('$$$ Ksenia='+query);
            Batch_SearchAndReplace salesBatch = new Batch_SearchAndReplace(query,'Owner_s_Manager__c',String.valueOf(newCpmId));
            Database.executeBatch(salesBatch,20);

            return 'running';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
}