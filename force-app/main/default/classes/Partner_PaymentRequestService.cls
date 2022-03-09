public without sharing class Partner_PaymentRequestService {
    /*
    this service is for submitPaymentRequest and paymentRequestsTool LWCs
    =========================================================================
    */

    //use this wrapper to return options for that require label and value. f.e lightning-combobox
    private class optionWrapper{
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;

        public optionWrapper(String label, String value){
			this.label = label;
            this.value = value;
        }
    }

    // used by wire to get all user relevant data
    @AuraEnabled(cacheable=true)
    public static User getCurrUser(){
        try {
            User myUser = [select Id, Name, ManagerId, AccountId, Account.Name from User where Id =: UserInfo.getUserId()];
            return myUser;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    // used to get the available Marketing Activities for selection in a lightning-dual-listbox
    @AuraEnabled
    public static Map<String, Object> getMdfOptions(Id partnerCompanyId, Id paymentReqId, Date requestedMonth){
        try {
            Date dateForQuery = requestedMonth.addMonths(1).toStartOfMonth();
            Map<String, Object> res = new Map<String, Object>();
            String query = 'select Id, Name, Available_Amount_for_Payment__c, Last_Payment_Request__c, Last_Payment_Request_Status__c, MDF_Requested_Amount__c, Monthly_Requested_Amount__c, (select Id from MDF_Payment_Portions__r where Payment_Request__c =: paymentReqId and Is_Available_by_Date__c = true)';
            query += ' from Partner_Marketing_Activity__c';
            query += ' where Channel_Partner__c =: partnerCompanyId'; //marketing activities related to the partner
            query += ' and CPM_Approval_Status__c = \'Approved\''; //only approved marketing activities
            query += ' and Is_Canceled__c = false'; //canceled marketing activities are excluded
            query += ' and (Activity_Date__c <: dateForQuery or Start_Date_for_Fund__c <: dateForQuery)';
            if(paymentReqId == null) query = query + ' and Available_Amount_for_Payment__c > 0'; //from homepage - marketing activities with available amount
            else query = query + ' and (Available_Amount_for_Payment__c > 0 or Last_Payment_Request__c =: paymentReqId)'; //for draft payment reqs we display the selected marketing activities as well by Last_Payment_Request__c
            List<Partner_Marketing_Activity__c> pma_list = Database.query(query);
            if(pma_list.isEmpty()) return res;
            List<optionWrapper> mdfOptions_list = new List<optionWrapper>();
            Map<Id,Decimal> mdfIdtoAmount_map = new Map<Id,Decimal>();
            Set<Id> selectedPmaIds = new Set<Id>();
            Decimal amount;
            for(Partner_Marketing_Activity__c pma: pma_list){ //build the list of mdf options (optionWrapper)
                if(paymentReqId != null && pma.Last_Payment_Request__c == paymentReqId && pma.Last_Payment_Request_Status__c == 'Draft'){
                    selectedPmaIds.add(pma.Id);
                }
                if(pma.Available_Amount_for_Payment__c > 0) amount = pma.Available_Amount_for_Payment__c;
                else if(!pma.MDF_Payment_Portions__r.isEmpty()){ //portions
                    amount = pma.MDF_Payment_Portions__r.size() * pma.Monthly_Requested_Amount__c;
                } else {
                    amount = pma.MDF_Requested_Amount__c;
                }
                mdfOptions_list.add(new optionWrapper(pma.Name + ' (Amount: ' + amount + ')', pma.Id));
                mdfIdtoAmount_map.put(pma.Id, amount);

            }
            res.put('mdfOptions_list', mdfOptions_list);
            res.put('mdfIdtoAmount_map', mdfIdtoAmount_map);
            res.put('selected_list', selectedPmaIds);
            return res;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    //used by the paymentRequestsTool lwc to display lists of payment reqs by status
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getAllPaymentRequests(){
        try {
            Map <String, Object> res = new Map <String, Object>();
            Id partnerCompanyId = [select AccountId from User where Id =: UserInfo.getUserId() limit 1].AccountId;
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
            res.put('draftPaymentReqList',draftPaymentReqList);
            res.put('rejectedPaymentReqList',rejectedPaymentReqList);
            res.put('submittedPaymentReqList',recentSubmitPaymentReqList);
            res.put('paidPaymentReqList',paidPaymentReqList);
            res.put('isPartnerUser',(partnerCompanyId != null));
            res.put('status','success');
            return res;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    // gets the options for months selection (lightning-combobox) to submit a paymnet request 
    @AuraEnabled
    public static List<optionWrapper> getMonthsPicklist(){
        try {
            List<optionWrapper> res = new List<optionWrapper>();
            Integer numOfMonths = Integer.valueOf([select Value__c from Environment_Variable__mdt where DeveloperName = 'Partner_Commission_Payment_Req_Months' limit 1].Value__c);
            //get available reports from last X months (X - from CMT)
            Date dtForReports = Date.today().toStartOfMonth().addMonths(-numOfMonths);
            List<Commission_Report__c> reportsList = [select Date__c from Commission_Report__c where Is_Available_For_Payment_Request__c = true and Date__c >=: dtForReports];
            Set<String> monthsWithAvailableReports = new Set<String>();
            for(Commission_Report__c report: reportsList){
                monthsWithAvailableReports.add(String.valueOf(report.Date__c.toStartOfMonth()));
            }
            DateTime dt = Datetime.now().addMonths(-1);
            for(Integer i=0; i<numOfMonths ; i++){
                Date dateVal = Date.newInstance(dt.year(), dt.month(), dt.day());
                if(monthsWithAvailableReports.contains(String.valueOf(dateVal.toStartOfMonth()))){
                    res.add(new optionWrapper(dt.format('MMM') + ' ' + dt.year(), String.valueOf(Date.newInstance(dt.year(), dt.month(), 1))));
                }
                dt = dt.addMonths(-1);
                if(dt.month() == 5 && dt.year() == 2021) break; // we want the values to start from June 2021 (this is when we launced the new commission infra)
            }
            return res;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    // get all relevant colections and display commission total amounts and percents
    @AuraEnabled
    public static Map<String, Object> getData(Date month, Id paymentRequestId, User runningUser){
        try {
            Map <String, Object> res = new Map <String, Object>();
            Id partnerCompanyId = runningUser.AccountId;
            Date monthForQuery = month;
            if(paymentRequestId == null){
                //check if payment req already exists
                List<Payment_Request__c> existingPaymentRequest = [select Id from Payment_Request__c where Month__c =: month.toStartOfMonth() and Channel_Partner__c =: partnerCompanyId order by CreatedDate DESC];
                if(existingPaymentRequest != null && !existingPaymentRequest.isEmpty()) {
                    res.put('existingPaymentRequestId', existingPaymentRequest.get(0).Id);
                    res.put('errorMsg','Payment Request already exists for ' + month.month() +'/'+month.year()+'! In case it was rejected, please follow to link to the exising payment request and resubmit it according to the reject notes.');
                    res.put('status', 'error');
                    return res;
                }
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
            List<Commission_Collection__c> collectionsList = new List<Commission_Collection__c>();
            for(Commission_Collection__c collection: collectionsMap.values()){
                if(!collection.Is_Hidden__c) collectionsList.add(collection);
            }
            
            //calculate amounts
            Decimal monthlyAmount = 0, yearlyAmount = 0, twoYearlyAmount = 0;
            if(!collectionsList.isEmpty()) {
                for(Commission_Collection__c collection: collectionsList){
                    if(collection.Plan_Period__c.containsIgnoreCase('monthly')) monthlyAmount += collection.Commission_Amount_USD__c;
                    if(collection.Plan_Period__c.containsIgnoreCase('yearly')) {
                        if(collection.Plan_Period__c.containsIgnoreCase('two_yearly')) twoYearlyAmount += collection.Commission_Amount_USD__c;
                        else yearlyAmount += collection.Commission_Amount_USD__c;
                    }
                }
            }
            if(paymentRequestId == null){
                Id newPaymentReqId = saveNewPaymentRequest(runningUser, partnerCompanyId, month, monthlyAmount, yearlyAmount, twoYearlyAmount);
                Batch_SearchAndReplace linkPaymentReqToCollectionsBatch = new Batch_SearchAndReplace(collectionsMap.keySet(), 'Commission_Collection__c', 'Payment_Request__c', String.valueOf(newPaymentReqId), 'Link Collections to Payment Request Id: ' + newPaymentReqId);
                Utilities.cleanFlexQueue();
                Database.executeBatch(linkPaymentReqToCollectionsBatch, 100);
                res.put('paymentReqId',newPaymentReqId);
            } else {
                res.put('paymentReqId',paymentRequestId);
            }
            res.put('collectionsList',collectionsList);
            res.put('monthlyAmount',monthlyAmount);
            res.put('yearlyAmount',yearlyAmount);
            res.put('twoYearlyAmount',twoYearlyAmount);
            res.put('totalAmount', monthlyAmount + yearlyAmount + twoYearlyAmount);
            res.put('inboundPercent',inboundPercent);
            res.put('outboundPercent',outboundPercent);
            res.put('status', 'success');
            return res;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    // in case of submit draft or resubmit after reject - we delete old files
    @AuraEnabled
    public static void deleteOldFiles(Id paymentRequestId){
        try {
            list<ContentDocumentLink> filesList = [select Id from ContentDocumentLink where LinkedEntityId =: paymentRequestId];
            if(!filesList.isEmpty()) Database.delete(filesList);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    // update payment request with MDF and Spiff details
    @AuraEnabled
    public static void updatePaymentRequest(Id paymentRequestId, 
                                            Decimal mdfAmount, 
                                            List<Id> selectedMDFs, 
                                            Decimal spiffAmount, 
                                            Id invoiceFileVerId, 
                                            String invoiceCurrency, 
                                            String invoiceNumber, 
                                            Date invoiceDate){
        try {
            Payment_Request__c paymentRequestToUpdate = new Payment_Request__c(
                    Id = paymentRequestId, 
                    MDF_Amount__c = 0, 
                    Spiff_Amount__c = 0, 
                    Invoice_Content_Version_Id__c = invoiceFileVerId, 
                    Invoice_Currency__c = invoiceCurrency,
                    Invoice_Date__c = invoiceDate,
                    Invoice_Number__c = invoiceNumber
                );
            if(mdfAmount != null && mdfAmount > 0) paymentRequestToUpdate.MDF_Amount__c = mdfAmount;
            if(spiffAmount != null && spiffAmount > 0) paymentRequestToUpdate.Spiff_Amount__c = spiffAmount;
            Database.update(paymentRequestToUpdate);
            if(selectedMDFs != null && !selectedMDFs.isEmpty()) updateRelatedMDFs(paymentRequestId, selectedMDFs);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    //submit payment request for approval
    @AuraEnabled
    public static void submitForApproval(Id paymentRequestId, Decimal mdfAmount, List<Id> selectedMDFs, Decimal spiffAmount, Id invoiceFileVerId, String invoiceCurrency, String invoiceNumber, Date invoiceDate){
        try {
            updatePaymentRequest(paymentRequestId, mdfAmount, selectedMDFs, spiffAmount, invoiceFileVerId, invoiceCurrency, invoiceNumber, invoiceDate);
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();          
            req.setObjectId(paymentRequestId);
            req.setProcessDefinitionNameOrId('Payment_Request_Approval_Process');
            req.setSkipEntryCriteria(true);
            Approval.ProcessResult result = Approval.process(req);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    private static void updateRelatedMDFs(Id paymentRequestId, List<Id> selectedMDFs){
        Set<Id> pmaIds = new Set<Id>(selectedMDFs);
        List<Partner_Marketing_Activity__c> pma_list = [select Id, (select Id from MDF_Payment_Portions__r where Is_Available_by_Date__c = true and (Payment_Request_Status__c = null or Payment_Request_Status__c = 'Rejected')) from Partner_Marketing_Activity__c where Id in: pmaIds];
        List<Partner_Marketing_Activity__c> pmaToUpdate_list = new List<Partner_Marketing_Activity__c>();
        List<MDF_Payment_Portion__c> ppToUpdate_list = new List<MDF_Payment_Portion__c>();
        for(Partner_Marketing_Activity__c pma: pma_list){
            pmaToUpdate_list.add(new Partner_Marketing_Activity__c(
                    Id = pma.Id,
                    Last_Payment_Request__c = paymentRequestId
                ));
            if(!pma.MDF_Payment_Portions__r.isEmpty()){
                for(MDF_Payment_Portion__c pp: pma.MDF_Payment_Portions__r){
                    ppToUpdate_list.add(new MDF_Payment_Portion__c(
                        Id = pp.Id,
                        Payment_Request__c = paymentRequestId,
                        Payment_Request_Status__c = 'Draft'
                    ));
                }
            }
        }
        List<SObject> objsToUpdate = new List<SObject>();
        objsToUpdate.addAll(pmaToUpdate_list);
        if(!ppToUpdate_list.isEmpty()) objsToUpdate.addAll(ppToUpdate_list);
        if(!objsToUpdate.isEmpty()) Database.update(objsToUpdate);
    }

    // create new payment request
    private static Id saveNewPaymentRequest(User runningUser, Id partnerCompanyId, Date paymentRequestDate, Decimal monthlyAmount, Decimal yearlyAmount, Decimal twoYearlyAmount){
        String partnerCompanyName = runningUser.Account.Name;
        Id cpmId = runningUser.ManagerId;
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