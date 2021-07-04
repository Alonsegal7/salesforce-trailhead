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
        /*try {
            String body = '';
            List<User> userList = [select Id, Name from User where managerId =: oldCpmId and Contact.AccountId =: partnerAccountId];
            for(User userRec : userList){
                userRec.ManagerId = newCpmId;
            }
            if(!userList.isEmpty()) {
                body += 'Users: \n';
                for(User userRec : userList){
                    body += userRec.Name + ' - ' + userRec.Id + '\n';
                }
                System.enqueueJob(new updateRecords(userList));
            }

            Account partnerAccount = [select Name from Account where Id =: partnerAccountId];
            String partnerNameForCompare = '%'+partnerAccount.Name+'%';
            List<Account> accountlist = [select Id, Name from Account where (Partner_s_Role_Formula__c like: partnerNameForCompare or Channel_Partner__c =: partnerAccountId) and Owner_s_Manager__c =: oldCpmId];
            for(Account accountRec : accountlist){
                accountRec.Owner_s_Manager__c = newCpmId;
            }
            if(!accountlist.isEmpty()) {
                body += 'Accounts: \n';
                for(Account acc: accountlist){
                    body += acc.Name + ' - ' + acc.Id + '\n';
                }
                System.enqueueJob(new updateRecords(accountlist));
            }

            List<Lead> leadsList = [select Id, Name from Lead where (Owner.UserRole.Name like: partnerNameForCompare or Partner_Company__c =: partnerAccountId) and Owner_s_Manager__c =: oldCpmId and Status != 'Nurturing' and Status != 'Qualified' and Status != 'Converted'];
            for(Lead leadRec : leadsList){
                leadRec.Owner_s_Manager__c = newCpmId;
            }
            if(!leadsList.isEmpty()) {
                body += 'Leads: \n';
                for(Lead leadRec: leadsList){
                    body += leadRec.Name + ' - ' + leadRec.Id + '\n';
                }
                System.enqueueJob(new updateRecords(leadsList));
            }

            List<Opportunity> oppList = [select Id, Name from Opportunity where (Owner.UserRole.Name like: partnerNameForCompare or Channel_Partner__c =: partnerAccountId) and Owner_s_Manager__c =: oldCpmId and ((StageName != 'Closed Won' and StageName != 'Closed Lost') or CloseDate >: startingFrom)];
            for(Opportunity oppRec : oppList){
                oppRec.Owner_s_Manager__c = newCpmId;
            }
            if(!oppList.isEmpty()) {
                body += 'Opportunities: \n';
                for(Opportunity opp: oppList){
                    body += opp.Name + ' - ' + opp.Id + '\n';
                }
                System.enqueueJob(new updateRecords(oppList));
            }

            List<Sale__c> saleList = [select Id, Name from Sale__c where Owner__r.UserRole.Name like: partnerNameForCompare and Owner_s_Manager__c =: oldCpmId and (Sale_Status__c != 'Complete' or Close_Date__c >: startingFrom)];
            for(Sale__c saleRec : saleList){
                saleRec.Owner_s_Manager__c = newCpmId;
            }
            if(!saleList.isEmpty()) {
                body += 'Sales: \n';
                for(Sale__c sale: saleList){
                    body += sale.Name + ' - ' + sale.Id + '\n';
                }
                System.enqueueJob(new updateRecords(saleList));
            }

            if(!(userList.isEmpty() && accountList.isEmpty() && oppList.isEmpty() && saleList.isEmpty() && leadsList.isEmpty())){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new List<String>{UserInfo.getUserEmail()});
                mail.setSubject('Partner CPM Records Transfer Summary');
                mail.setHtmlBody(body);
                Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
                return 'running';
            } else {
                return 'empty';
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }*/
        return 'running';
    }
}