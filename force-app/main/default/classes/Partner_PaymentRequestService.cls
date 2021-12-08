public without sharing class Partner_PaymentRequestService {

    public class resWrapper {

        @AuraEnabled
        public Id existingPaymentRequestId_lwc {get;set;}
        @AuraEnabled
        public String errorMsg_lwc;
        @AuraEnabled
        public List<Commission_Collection__c> collectionsList_lwc;
        @AuraEnabled
        public String status_lwc;
        @AuraEnabled
        public Decimal monthlyAmount_lwc;
        @AuraEnabled
        public Decimal yearlyAmount_lwc;
        @AuraEnabled
        public Decimal twoYearlyAmount_lwc;
        @AuraEnabled
        public Decimal totalAmount_lwc;
        @AuraEnabled
        public Decimal inboundPercent_lwc;
        @AuraEnabled
        public Decimal outboundPercent_lwc;
        @AuraEnabled
        public String userFullName_lwc;
        @AuraEnabled
        public Id newPaymentRequestId_lwc;
        @AuraEnabled
        public List<Map<String,String>> monthsSelectionOptions_lwc;
        @AuraEnabled
        public Boolean isPartnerUser_lwc;
        @AuraEnabled
        public List<Payment_Request__c> draftPaymentReqList_lwc;
        @AuraEnabled
        public List<Payment_Request__c> rejectedPaymentReqList_lwc;
        @AuraEnabled
        public List<Payment_Request__c> submittedPaymentReqList_lwc;
        @AuraEnabled
        public List<Payment_Request__c> paidPaymentReqList_lwc;

        public resWrapper(Id existingPaymentRequestId, String errorMsg, Boolean isPartnerUser){
			this.existingPaymentRequestId_lwc = existingPaymentRequestId;
            this.errorMsg_lwc = errorMsg;
            this.isPartnerUser_lwc = isPartnerUser;
            this.status_lwc = 'error';
        }

        public resWrapper(String errorMsg){
			this.errorMsg_lwc = errorMsg;
            this.status_lwc = 'error';
        }

        public resWrapper(List<Commission_Collection__c> collectionsList, Decimal monthlyAmount, Decimal yearlyAmount, Decimal twoYearlyAmount, Decimal inboundPercent, Decimal outboundPercent, Id paymentRequestId, Boolean isPartnerUser){
			this.collectionsList_lwc = collectionsList;
            this.monthlyAmount_lwc = monthlyAmount;
            this.yearlyAmount_lwc = yearlyAmount;
            this.twoYearlyAmount_lwc = twoYearlyAmount;
            this.totalAmount_lwc = monthlyAmount + yearlyAmount + twoYearlyAmount;
            this.inboundPercent_lwc = inboundPercent;
            this.outboundPercent_lwc = outboundPercent;
            this.newPaymentRequestId_lwc = paymentRequestId;
            this.isPartnerUser_lwc = isPartnerUser;
            this.status_lwc = 'success';
        }

        public resWrapper(List<Map<String,String>> monthsSelectionOptions, String userFullName){
            this.monthsSelectionOptions_lwc = monthsSelectionOptions;
            this.userFullName_lwc = userFullName;
            this.status_lwc = 'success';
        }

        public resWrapper(Id newPaymentRequestId){
			this.newPaymentRequestId_lwc = newPaymentRequestId;
            this.status_lwc = 'success';
        }

        public resWrapper(List<Payment_Request__c> draftPaymentReqList, List<Payment_Request__c> rejectedPaymentReqList, List<Payment_Request__c> submittedPaymentReqList, List<Payment_Request__c> paidPaymentReqList, Boolean isPartnerUser){
			this.draftPaymentReqList_lwc = draftPaymentReqList;
            this.rejectedPaymentReqList_lwc = rejectedPaymentReqList;
            this.submittedPaymentReqList_lwc = submittedPaymentReqList;
            this.paidPaymentReqList_lwc = paidPaymentReqList;
            this.isPartnerUser_lwc = isPartnerUser;
            this.status_lwc = 'success';
        }
    }

    @AuraEnabled(cacheable=true)
    public static resWrapper getAllPaymentRequests(){
        try {
            User runningUser = [select ManagerId, Contact.AccountId, Contact.Account.Name, Profile.Name from User where Id =: UserInfo.getUserId() limit 1];
            String partnerForTest = [select Value__c from Environment_Variable__mdt where DeveloperName = 'Partner_Commission_Payment_Req_Test_Acc' limit 1].Value__c;
            Id partnerCompanyId = partnerForTest;
            if(runningUser.Profile.Name != 'System Administrator') partnerCompanyId = runningUser.Contact.AccountId;
            Boolean isPartnerUser = false;
            if(runningUser.Profile.Name != 'System Administrator') isPartnerUser = true;

            List<Payment_Request__c> paymentReqList = [select Id, Name, CreatedDate, Status__c, Total_Commission_Amount__c, Pending_CPM_Review_Timestamp__c from Payment_Request__c where Channel_Partner__c =: partnerCompanyId order by Pending_CPM_Review_Timestamp__c DESC];
            List<Payment_Request__c> draftPaymentReqList = new List<Payment_Request__c>();
            List<Payment_Request__c> rejectedPaymentReqList = new List<Payment_Request__c>();
            List<Payment_Request__c> recentSubmitPaymentReqList = new List<Payment_Request__c>();
            List<Payment_Request__c> paidPaymentReqList = new List<Payment_Request__c>();
            for(Payment_Request__c paymentReq: paymentReqList){
                if(paymentReq.Status__c == 'Draft') draftPaymentReqList.add(paymentReq);
                else if(paymentReq.Status__c == 'Rejected')rejectedPaymentReqList.add(paymentReq);
                else if(paymentReq.Status__c == 'Paid') paidPaymentReqList.add(paymentReq);
                else if(recentSubmitPaymentReqList.size() < 3) recentSubmitPaymentReqList.add(paymentReq);
            }
            return new resWrapper(draftPaymentReqList, rejectedPaymentReqList, recentSubmitPaymentReqList, paidPaymentReqList, isPartnerUser);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static resWrapper getMonthsPicklist(){
        try {
            User runningUser = [select Name, ContactId, Contact.AccountId, Profile.Name from User where Id =: UserInfo.getUserId() limit 1];
            if(runningUser.Profile.Name != 'System Administrator' && (runningUser.ContactId == null || runningUser.Contact.AccountId == null)) return new resWrapper('Your User is not connected to partner company. Please reach out to Biz Ops for help.');
            String userFullName = runningUser.Name;
            Boolean isPartnerUser = false;
            if(runningUser.Profile.Name != 'System Administrator') isPartnerUser = true;
            Integer numOfMonths = Integer.valueOf([select Value__c from Environment_Variable__mdt where DeveloperName = 'Partner_Commission_Payment_Req_Months' limit 1].Value__c);

            //get available reports from last X months (X - from CMT)
            Date dtForReports = Date.today().toStartOfMonth().addMonths(-numOfMonths);
            List<Commission_Report__c> reportsList = [select Date__c from Commission_Report__c where Is_Available_For_Payment_Request__c = true and Date__c >=: dtForReports];
            Set<String> monthsWithAvailableReports = new Set<String>();
            for(Commission_Report__c report: reportsList){
                monthsWithAvailableReports.add(String.valueOf(report.Date__c.toStartOfMonth()));
            }
            DateTime dt = Datetime.now().addMonths(-1);
            List<Map<String,String>> monthSelectionPicklistValues = new List<Map<String,String>>();
            for(Integer i=0; i<numOfMonths ; i++){
                Date dateVal = Date.newInstance(dt.year(), dt.month(), dt.day());
                if(monthsWithAvailableReports.contains(String.valueOf(dateVal.toStartOfMonth()))){
                    Map<String,String> newMonthValue = new Map<String,String>();
                    newMonthValue.put('label', dt.format('MMM') + ' ' + dt.year());
                    newMonthValue.put('value', String.valueOf(Date.newInstance(dt.year(), dt.month(), dt.day())));
                    monthSelectionPicklistValues.add(newMonthValue);
                }
                dt = dt.addMonths(-1);
                if(dt.month() == 5 && dt.year() == 2021) break; // we want the values to start from June 2021 (this is when we launced the new commission infra)
            }
            if(monthSelectionPicklistValues.isEmpty()) return new resWrapper('No Available Data for Commission!');
            return new resWrapper(monthSelectionPicklistValues, userFullName);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static resWrapper getData(Date month, Id paymentRequestId){
        try {
            User runningUser = [select ManagerId, Contact.AccountId, Contact.Account.Name, Profile.Name from User where Id =: UserInfo.getUserId() limit 1];
            String partnerForTest = [select Value__c from Environment_Variable__mdt where DeveloperName = 'Partner_Commission_Payment_Req_Test_Acc' limit 1].Value__c;
            Id partnerCompanyId = partnerForTest;
            Boolean isPartnerUser = false;
            if(runningUser.Profile.Name != 'System Administrator' && runningUser.Profile.Name != 'Channel Managers') partnerCompanyId = runningUser.Contact.AccountId;
            else if(runningUser.Profile.Name == 'Partner Community Custom') isPartnerUser = true;
            
            Date monthForQuery = month;
            if(paymentRequestId == null){
                //check if payment req already exists
                List<Payment_Request__c> existingPaymentRequest = [select Id from Payment_Request__c where Month__c =: month.toStartOfMonth() and Channel_Partner__c =: partnerCompanyId order by CreatedDate DESC];
                if(existingPaymentRequest != null && !existingPaymentRequest.isEmpty()) return new resWrapper(existingPaymentRequest.get(0).Id, 'Payment Request already exists for ' + month.month() +'/'+month.year()+'! In case it was rejected, please follow to link to the exising payment request and resubmit it according to the reject notes.', isPartnerUser);
            } else {
                Payment_Request__c currPaymentReq = [select Month__c, Channel_Partner__c from Payment_Request__c where Id =: paymentRequestId];
                monthForQuery = currPaymentReq.Month__c;
                partnerCompanyId = currPaymentReq.Channel_Partner__c;
            }
            
            //get inbound outbound percent
            Partner_Commission_Model__c pcm = [select Id, Commission_Model__r.Inbound_Percent__c, Commission_Model__r.Outbound_Percent__c from Partner_Commission_Model__c where Partner_Company__c =: partnerCompanyId and Start_Date__c <=: monthForQuery and (End_Date__c = null or End_Date__c >=: monthForQuery) limit 1];
            Decimal inboundPercent = pcm.Commission_Model__r.Inbound_Percent__c / 100;
            Decimal outboundPercent = pcm.Commission_Model__r.Outbound_Percent__c / 100;
            //query all relevant data of collections and remove fix collections - should be hidden for same report
            Map<Id,Commission_Collection__c> collectionsMap = new Map<Id,Commission_Collection__c>([select Pulse_Account_Id__c, Is_Hidden__c, Is_Fix__c, Monday_Account__c, Monday_Account__r.Name, Account_Source_Type__c, Partner_Company__c, Partner_Company__r.Name, Partner_Tier__c, Plan_Name__c, Plan_Period__c, Plan_Tier__c, Account_Slug__c, Collection_Amount_USD__c, Commission_Amount_USD__c, Collection_Happened_At__c, Event_Type__c, Payment_Type__c, Commission_Report__r.Date__c, Commission_Report__r.Id, Commission_Report__r.Is_Available_For_Payment_Request__c from Commission_Collection__c where Partner_Company__c =: partnerCompanyId and Commission_Report__r.Is_Available_For_Payment_Request__c = true and CALENDAR_MONTH(Commission_Report__r.Date__c) =: monthForQuery.month() and CALENDAR_YEAR(Commission_Report__r.Date__c) =: monthForQuery.year()]);
            List<Commission_Collection__c> collectionsToDisplay = new List<Commission_Collection__c>();
            for(Commission_Collection__c collection: collectionsMap.values()){
                if(!collection.Is_Hidden__c) collectionsToDisplay.add(collection);
            }
            if(collectionsToDisplay.isEmpty()) {
                Datetime dt = monthForQuery;
                return new resWrapper('No collections for ' + dt.format('MMM') + ' ' + dt.year());
            }
            //calculate amounts
            Decimal monthlyAmount = 0, yearlyAmount = 0, twoYearlyAmount = 0;
            for(Commission_Collection__c collection: collectionsToDisplay){
                if(collection.Plan_Period__c.containsIgnoreCase('monthly')) monthlyAmount += collection.Commission_Amount_USD__c;
                if(collection.Plan_Period__c.containsIgnoreCase('yearly')) {
                    if(collection.Plan_Period__c.containsIgnoreCase('two_yearly')) twoYearlyAmount += collection.Commission_Amount_USD__c;
                    else yearlyAmount += collection.Commission_Amount_USD__c;
                }
            }
            Id newPaymentReqId = paymentRequestId;
            if(paymentRequestId == null){
                newPaymentReqId = saveNewPaymentRequest(runningUser, partnerCompanyId, month, monthlyAmount, yearlyAmount, twoYearlyAmount);
                Batch_SearchAndReplace linkPaymentReqToCollectionsBatch = new Batch_SearchAndReplace(collectionsMap.keySet(), 'Commission_Collection__c', 'Payment_Request__c', String.valueOf(newPaymentReqId), 'Link Collections to Payment Request Id: ' + newPaymentReqId);
                Utilities.cleanFlexQueue();
                Database.executeBatch(linkPaymentReqToCollectionsBatch, 100);
            }
            
            return new resWrapper(collectionsToDisplay, monthlyAmount, yearlyAmount, twoYearlyAmount, inboundPercent, outboundPercent, newPaymentReqId, isPartnerUser);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static resWrapper deleteOldFiles(Id paymentRequestId){
        try {
            list<ContentDocumentLink> filesList = [select Id from ContentDocumentLink where LinkedEntityId =: paymentRequestId];
            if(!filesList.isEmpty()) Database.delete(filesList);
            return new resWrapper(paymentRequestId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static void updatePaymentRequest(Id paymentRequestId, Decimal mdfAmount, Decimal spiffAmount, Id incoiveFileVerId, String invoiceCurrency){
        try {
            Payment_Request__c paymentRequestToUpdate = new Payment_Request__c(Id = paymentRequestId, MDF_Amount__c = 0, Spiff_Amount__c = 0, Invoice_Content_Version_Id__c = incoiveFileVerId, Invoice_Currency__c = invoiceCurrency);
            if(mdfAmount != null && mdfAmount > 0) paymentRequestToUpdate.MDF_Amount__c = mdfAmount;
            if(spiffAmount != null && spiffAmount > 0) paymentRequestToUpdate.Spiff_Amount__c = spiffAmount;
            Database.update(paymentRequestToUpdate);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static resWrapper submitForApproval(Id paymentRequestId, Decimal mdfAmount, Decimal spiffAmount, Id incoiveFileVerId, String invoiceCurrency){
        try {
            updatePaymentRequest(paymentRequestId, mdfAmount, spiffAmount, incoiveFileVerId, invoiceCurrency);
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();          
            req.setObjectId(paymentRequestId);
            req.setProcessDefinitionNameOrId('Payment_Request_Approval_Process');
            req.setSkipEntryCriteria(true);
            Approval.ProcessResult result = Approval.process(req);
            return new resWrapper(paymentRequestId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    private static Id saveNewPaymentRequest(User runningUser, Id partnerCompanyId, Date paymentRequestDate, Decimal monthlyAmount, Decimal yearlyAmount, Decimal twoYearlyAmount){
        String partnerCompanyName = runningUser.Profile.Name == 'System Administrator' ? 'a-players' : runningUser.Contact.Account.Name;
        Id cpmId = runningUser.Profile.Name == 'System Administrator' ? '0051t000003kFp4AAE' : runningUser.ManagerId;
        Payment_Request__c newPaymentRequest = new Payment_Request__c();
        newPaymentRequest.Name = partnerCompanyName + ' - ' + paymentRequestDate.month() +'/'+paymentRequestDate.year();
        newPaymentRequest.Channel_Partner__c = partnerCompanyId;
        newPaymentRequest.CPM__c = cpmId;
        newPaymentRequest.Monthly_Commission_Amount__c = monthlyAmount;
        newPaymentRequest.Yearly_Commission_Amount__c = yearlyAmount;
        newPaymentRequest.Two_Yearly_Commission_Amount__c = twoYearlyAmount;
        newPaymentRequest.Total_Commission_Amount__c = monthlyAmount + yearlyAmount + twoYearlyAmount;
        newPaymentRequest.OwnerId = runningUser.Id;
        newPaymentRequest.Month__c = paymentRequestDate.toStartOfMonth();
        Database.insert(newPaymentRequest);
        return newPaymentRequest.Id;
    }
}