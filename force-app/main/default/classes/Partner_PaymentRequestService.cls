public class Partner_PaymentRequestService {
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

        public resWrapper(Id existingPaymentRequestId, String errorMsg){
			this.existingPaymentRequestId_lwc = existingPaymentRequestId;
            this.errorMsg_lwc = errorMsg;
            this.status_lwc = 'error';
        }

        public resWrapper(String errorMsg){
			this.errorMsg_lwc = errorMsg;
            this.status_lwc = 'error';
        }

        public resWrapper(List<Commission_Collection__c> collectionsList, Decimal monthlyAmount, Decimal yearlyAmount, Decimal twoYearlyAmount, Decimal inboundPercent, Decimal outboundPercent){
			this.collectionsList_lwc = collectionsList;
            this.monthlyAmount_lwc = monthlyAmount;
            this.yearlyAmount_lwc = yearlyAmount;
            this.twoYearlyAmount_lwc = twoYearlyAmount;
            this.totalAmount_lwc = monthlyAmount + yearlyAmount + twoYearlyAmount;
            this.inboundPercent_lwc = inboundPercent;
            this.outboundPercent_lwc = outboundPercent;
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
    }

    @AuraEnabled
    public static resWrapper getMonthsPicklist(){
        try {
            User runningUser = [select Name, ContactId, Contact.AccountId, Profile.Name from User where Id =: UserInfo.getUserId() limit 1];
            if(runningUser.Profile.Name != 'System Administrator' && (runningUser.ContactId == null || runningUser.Contact.AccountId == null)) return new resWrapper('Your User is not connected to partner company. Please reach out to Biz Ops for help.');
            String userFullName = runningUser.Name;

            Integer numOfMonths = Integer.valueOf([select Value__c from Environment_Variable__mdt where DeveloperName = 'Partner_Commission_Payment_Req_Months' limit 1].Value__c);
            DateTime dt = Datetime.now();
            List<Map<String,String>> monthSelectionPicklistValues = new List<Map<String,String>>();
            for(Integer i=0; i<numOfMonths ; i++){
                Map<String,String> newMonthValue = new Map<String,String>();
                newMonthValue.put('label', dt.format('MMM') + ' ' + dt.year());
                newMonthValue.put('value', String.valueOf(Date.newInstance(dt.year(), dt.month(), dt.day())));
                monthSelectionPicklistValues.add(newMonthValue);
                dt = dt.addMonths(-1);
                if(dt.month() == 5 && dt.year() == 2021) break; // we want the values to start from June 2021 (this is when we launced the new commission infra)
            }
            return new resWrapper(monthSelectionPicklistValues, userFullName);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static resWrapper getData(Date month){
        try {
            User runningUser = [select Contact.AccountId, Profile.Name from User where Id =: UserInfo.getUserId() limit 1];
            String partnerForTest = [select Value__c from Environment_Variable__mdt where DeveloperName = 'Partner_Commission_Payment_Req_Test_Acc' limit 1].Value__c;
            Id partnerCompanyId = runningUser.Profile.Name == 'System Administrator' ? partnerForTest : runningUser.Contact.AccountId;
            //check if payment req already exists
            List<Payment_Request__c> existingPaymentRequest = [select Id from Payment_Request__c where Month__c =: month.toStartOfMonth() and Channel_Partner__c =: partnerCompanyId order by CreatedDate DESC];
            if(existingPaymentRequest != null && !existingPaymentRequest.isEmpty()) return new resWrapper(existingPaymentRequest.get(0).Id, 'Payment Request already exists for ' + month.month() +'/'+month.year());
            //get inbound outbound percent
            Partner_Commission_Model__c pcm = [select Id, Commission_Model__r.Inbound_Percent__c, Commission_Model__r.Outbound_Percent__c from Partner_Commission_Model__c where Partner_Company__c =: partnerCompanyId and Start_Date__c <=: month and (End_Date__c = null or End_Date__c >=: month) limit 1];
            Decimal inboundPercent = pcm.Commission_Model__r.Inbound_Percent__c / 100;
            Decimal outboundPercent = pcm.Commission_Model__r.Outbound_Percent__c / 100;
            //query all relevant data of collections and remove fix collections - should be hidden for same report
            Map<Id,Commission_Collection__c> collectionsMap = new Map<Id,Commission_Collection__c>([select Pulse_Account_Id__c, Is_Fix__c, Monday_Account__c, Account_Source_Type__c, Partner_Company__c, Partner_Tier__c, Plan_Name__c, Plan_Period__c, Plan_Tier__c, Account_Slug__c, Collection_Amount_USD__c, Commission_Amount_USD__c, Collection_Happened_At__c, Event_Type__c, Payment_Type__c, Commission_Report__r.Date__c, Commission_Report__r.Id from Commission_Collection__c where Partner_Company__c =: partnerCompanyId and CALENDAR_MONTH(Commission_Report__r.Date__c) =: month.month() and CALENDAR_YEAR(Commission_Report__r.Date__c) =: month.year()]);
            Map<String,Commission_Collection__c> fixCollectionsMap = new Map<String,Commission_Collection__c>();
            for(Commission_Collection__c collection: collectionsMap.values()){
                String key = getCollectionUniqueKey(collection);
                if(fixCollectionsMap.containsKey(key)){
                    Commission_Collection__c existingCollection = fixCollectionsMap.get(key);
                    if(existingCollection.Collection_Amount_USD__c + collection.Collection_Amount_USD__c == 0 && existingCollection.is_Fix__c != collection.is_Fix__c){
                        //remove the two collections
                        collectionsMap.remove(collection.Id);
                        collectionsMap.remove(existingCollection.Id);
                    }
                } else {
                    fixCollectionsMap.put(key, collection);
                }
            }
            //calculate amounts
            Decimal monthlyAmount = 0, yearlyAmount = 0, twoYearlyAmount = 0;
            for(Commission_Collection__c collection: collectionsMap.values()){
                if(collection.Plan_Period__c == 'monthly') monthlyAmount += collection.Commission_Amount_USD__c;
                if(collection.Plan_Period__c == 'yearly') yearlyAmount += collection.Commission_Amount_USD__c;
                if(collection.Plan_Period__c == 'two_yearly') twoYearlyAmount += collection.Commission_Amount_USD__c;
            }
            return new resWrapper(collectionsMap.values(), monthlyAmount, yearlyAmount, twoYearlyAmount, inboundPercent, outboundPercent);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static String getCollectionUniqueKey(Commission_Collection__c collection){
        Decimal absoluteAmount = collection.Collection_Amount_USD__c;
        if(absoluteAmount < 0) absoluteAmount = -absoluteAmount;
        return collection.Commission_Report__r.Id + String.valueOf(collection.Monday_Account__c) + String.valueOf(collection.Collection_Happened_At__c) + String.valueOf(absoluteAmount);
    }

    @AuraEnabled
    public static resWrapper saveNewPaymentRequest(Date paymentRequestDate, Decimal monthlyAmount_apex, Decimal yearlyAmount_apex, Decimal twoYearlyAmount_apex, Boolean saveAsDraft, Id fileId_apex){
        try {
            User runningUser = [select ManagerId, Contact.AccountId, Contact.Account.Name, Profile.Name from User where Id =: UserInfo.getUserId() limit 1];
            Id partnerCompanyId = runningUser.Profile.Name == 'System Administrator' ? '0013X00003UL4XqQAL' : runningUser.Contact.AccountId;
            String partnerCompanyName = runningUser.Profile.Name == 'System Administrator' ? 'a-players' : runningUser.Contact.Account.Name;
            Id cpmId = runningUser.Profile.Name == 'System Administrator' ? '0051t000003kFp4AAE' : runningUser.Contact.AccountId;
            Payment_Request__c newPaymentRequest = new Payment_Request__c();
            newPaymentRequest.Name = partnerCompanyName + ' - ' + paymentRequestDate.month() +'/'+paymentRequestDate.year();
            newPaymentRequest.Channel_Partner__c = partnerCompanyId;
            newPaymentRequest.CPM__c = cpmId;
            if(!saveAsDraft) newPaymentRequest.Status__c = 'Pending CPM Review';
            newPaymentRequest.Monthly_Commission_Amount__c = monthlyAmount_apex;
            newPaymentRequest.Yearly_Commission_Amount__c = yearlyAmount_apex;
            newPaymentRequest.Two_Yearly_Commission_Amount__c = twoYearlyAmount_apex;
            newPaymentRequest.OwnerId = runningUser.Id;
            newPaymentRequest.Month__c = paymentRequestDate.toStartOfMonth();
            Database.insert(newPaymentRequest);
            if(fileId_apex != null) linkUploadedFileToPaymentRequest(fileId_apex, newPaymentRequest.Id);
            if(!saveAsDraft) {
                //submit for apprpval - TBD
                submitPaymentRequestForApproval(newPaymentRequest.Id);
            }
            return new resWrapper(newPaymentRequest.Id);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static void submitPaymentRequestForApproval(Id paymentRequestId){

    }

    private static void linkUploadedFileToPaymentRequest(Id fileId_apex, Id paymentReqId){
        ContentDocumentLink linkToPaymentReq = new ContentDocumentLink();
        linkToPaymentReq.ContentDocumentId = fileId_apex;
        linkToPaymentReq.LinkedEntityId = paymentReqId;
        linkToPaymentReq.ShareType = 'I';
        linkToPaymentReq.Visibility = 'AllUsers';
        Database.insert(linkToPaymentReq);
    }
}
