import { LightningElement, api, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import getCurrUser from '@salesforce/apex/Partner_PaymentRequestService.getCurrUser';
import getMonthsPicklist from '@salesforce/apex/Partner_PaymentRequestService.getMonthsPicklist';
import getData from '@salesforce/apex/Partner_PaymentRequestService.getData';
import deleteOldFiles from '@salesforce/apex/Partner_PaymentRequestService.deleteOldFiles';
import submitForApproval from '@salesforce/apex/Partner_PaymentRequestService.submitForApproval';
import updatePaymentRequest from '@salesforce/apex/Partner_PaymentRequestService.updatePaymentRequest';
import getFilesScreenData from '@salesforce/apex/Partner_PaymentRequestService.getFilesScreenData';
import submittedScreenGif from '@salesforce/resourceUrl/makeItRainGif';
import PAYMENT_REQ_STATUS_FIELD from '@salesforce/schema/Payment_Request__c.Status__c';
import PAYMENT_REQ_MONTH_FIELD from '@salesforce/schema/Payment_Request__c.Month__c';
import PAYMENT_REQ_MDF_FIELD from '@salesforce/schema/Payment_Request__c.MDF_Amount__c';
import PAYMENT_REQ_SPIFF_FIELD from '@salesforce/schema/Payment_Request__c.Spiff_Amount__c';
import PAYMENT_REQ_INV_DATE from '@salesforce/schema/Payment_Request__c.Invoice_Date__c';
import PAYMENT_REQ_INV_NUM from '@salesforce/schema/Payment_Request__c.Invoice_Number__c';

const columns = [
    { label: 'Partner Company', fieldName: 'PartnerCompanyURL', type: 'url', typeAttributes: { label: { fieldName: 'PartnerCompanyName' }, target: '_blank' }, sortable: true, wrapText: true , hideDefaultActions: true, hideDefaultActions: true},
    { label: 'Monday Account', fieldName: 'MondayAccountURL', type: 'url', typeAttributes: { label: { fieldName: 'MondayAccountName' }, target: '_blank' }, sortable: true, wrapText: true , hideDefaultActions: true},
    { label: 'Pulse Account ID', fieldName: 'Pulse_Account_Id__c', sortable: true, wrapText: true , hideDefaultActions: true},
    { label: 'Account Source Type', fieldName: 'Account_Source_Type__c' , sortable: true, wrapText: true , hideDefaultActions: true},
    { label: 'Partner Tier', fieldName: 'Partner_Tier__c' , sortable: true, wrapText: true , hideDefaultActions: true},
    { label: 'Plan Name', fieldName: 'Plan_Name__c' , sortable: true, wrapText: true , hideDefaultActions: true},
    { label: 'Plan Period', fieldName: 'Plan_Period__c' , sortable: true, wrapText: true , hideDefaultActions: true},
    { label: 'Plan Tier', fieldName: 'Plan_Tier__c' , sortable: true, wrapText: true , hideDefaultActions: true},
    { label: 'Account Slug', fieldName: 'Account_Slug__c' , sortable: true, wrapText: true , hideDefaultActions: true},
    { label: 'Collection Amount USD', fieldName: 'Collection_Amount_USD__c', type: 'number', sortable: true, wrapText: true , hideDefaultActions: true},
    { label: 'Commission Amount USD', fieldName: 'Commission_Amount_USD__c', type: 'number', sortable: true, wrapText: true , hideDefaultActions: true},
    { label: 'Collection Happened At', fieldName: 'Collection_Happened_At__c', type: 'date', sortable: true, wrapText: true , hideDefaultActions: true},
    { label: 'Event Type', fieldName: 'Event_Type__c' , sortable: true, wrapText: true , hideDefaultActions: true},
    { label: 'Payment Type', fieldName: 'Payment_Type__c' , sortable: true, wrapText: true , hideDefaultActions: true}
];

export default class SubmitPaymentRequest extends LightningElement {
    @api runningFromHomepage;
    @api recordId;
    @api cardTitle;
    @api submitButtonLabel;
    @api allowSubmit;

    error;
    customError;
    customInvoiceFilesError;
    customMdfFilesError
    currUserObj = {};
    isLoading = false;
    showModal = false;
    dataScreen = false;
    filesScreen = false;
    monthScreen = false;
    submittedScreen = false;
    showCancelButton = true;
    showViewBreakdownBtn = false;
    viewBreakdownMode = false;
    filesScreenFirstRun = true;
    submittedForApproval = false;
    isPartnerUser = false;
    mdfFound = false;
    columns = columns;
    displayedCollections; //the collections displayed on the page
    commissionData; // the result we get from getData callback
    partnerCompanyId;
    userFullName;
    selectedMonth; // format of 'MMM YYYY'
    monthsList;
    monthValue; // format of '2021-10-04'
    monthsMap = {};
    paymentRequestLink;
    newPaymentRequestId;
    submittedScreenText;
    submittedScreenTitle = 'Payment Request Created Successfully!';
    urlPrefix;
    urlSuffix;
    wiredPaymentReqResult;
    mdfAmount;
    spiffAmount;
    showUploadMdfFiles;
    fileKeyMdf;
    headerCardText;
    uploadedInvoiceId;
    invoiceFileUploadLabel;
    mdfFileUploadLabel;
    headerIconName = 'custom:custom17';
    cancelBtnLabel = 'Cancel';
    submittedScreenGifIcon = submittedScreenGif;
    currencyValue = 'USD';
    modalTitle;
    mdfOptions;
    mdfIdtoAmount_map;
    selectedMDFs = [];
    mdfNumRequiredFiles;
    invoiceNumber;
    invoiceDate;
    
    //sort & filter variables for datatable in data screen
    //allows sort & filter the datatable
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    page = 1; 
    _allData = []; 
    filteredData;
    startingRecord = 1;
    endingRecord = 0; 
    pageSize = 10; 
    totalRecountCount = 0;
    totalPage = 0;
    //filterableFields = ['Pulse_Account_Id__c','MondayAccountName','PartnerCompanyName']; //use in case you want to filter only on specific fields in the datatable

    get currencies() { //TBD move currencies to CMT 
        return [
            { label: 'USD', value: 'USD' },
            { label: 'EUR', value: 'EUR' },
            { label: 'GBP', value: 'GBP' },
        ];
    }

    @wire(getCurrUser)
    wiredCurrUser(result) {
        if (result.data) {
            this.currUserObj = result.data;
            this.userFullName = this.currUserObj['Name'];
            if(this.currUserObj['AccountId'] != null) this.isPartnerUser = true;
            if(this.isPartnerUser){
                this.urlPrefix = '/partners/s/';
                this.urlSuffix = '';
            } else {
                this.urlPrefix = '/lightning/r/';
                this.urlSuffix = '/view';
            }
        } else if (result.error) {
            this.error = result.error;
            this.currUserObj = undefined;
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields: [PAYMENT_REQ_STATUS_FIELD, PAYMENT_REQ_MONTH_FIELD, PAYMENT_REQ_MDF_FIELD, PAYMENT_REQ_SPIFF_FIELD, PAYMENT_REQ_INV_DATE, PAYMENT_REQ_INV_NUM] })
    wiredPaymentReq(result) {
        this.wiredPaymentReqResult = result;
        if (result.data) {
            this.showViewBreakdownBtn = true;
            var statusValue = getFieldValue(result.data, PAYMENT_REQ_STATUS_FIELD);
            this.selectedMonth = getFieldValue(result.data, PAYMENT_REQ_MONTH_FIELD);
            this.monthValue = this.selectedMonth;
            this.mdfAmount = getFieldValue(result.data, PAYMENT_REQ_MDF_FIELD);
            this.spiffAmount = getFieldValue(result.data, PAYMENT_REQ_SPIFF_FIELD);
            this.invoiceDate = getFieldValue(result.data, PAYMENT_REQ_INV_DATE);
            this.invoiceNumber = getFieldValue(result.data, PAYMENT_REQ_INV_NUM);
            this.cardTitle = 'Payment Request Status - ' + statusValue;
            if(statusValue != 'Draft' && statusValue != 'Rejected') {
                this.allowSubmit = false;
                this.headerCardText = undefined;
                this.headerIconName = 'custom:custom17';
            } else {
                if(statusValue == 'Draft') {
                    this.headerCardText = 'Please make sure to submit your request';
                    this.headerIconName = 'custom:custom17';
                    this.submitButtonLabel = 'Submit';
                } else if(statusValue == 'Rejected') {
                    this.headerCardText = 'Your Payment Request was rejected, please re:submit your request';
                    this.headerIconName = 'standard:first_non_empty';
                    this.submitButtonLabel = 'Resubmit';
                    this.mdfAmount = 0; // on resubmit we reset the mdf amount
                }
                this.allowSubmit = true;
            }
            if(this.mdfAmount != null && this.mdfAmount != '' && this.mdfAmount > 0) {
                this.showUploadMdfFiles = true;
                this.fileKeyMdf = this.recordId + '1';
                this.mdfFileUploadLabel = 'In order to get the payment for ' + this.selectedMonth + ' MDF, please upload relevant files here:';
            } else this.showUploadMdfFiles = false;
        } 
    }

    handleCurrencyChange(event) {
        this.currencyValue = event.detail.value;
    }

    onViewBreakdownClick(){
        this.viewBreakdownMode = true;
        this.modalTitle = 'View Payment Request Breakdown';
        this.showModal = true;
        this.loadDataScreen();
    }

    openModal(){
        this.modalTitle = 'Submit Payment Request';
        this.showModal = true;
        if(this.runningFromHomepage) {
            this.loadMonthsPicklist();
        } else {
            this.loadDataScreen();
        }
    }
    
    loadMonthsPicklist(){
        this.error = undefined;
        this.customError = undefined;
        this.isLoading = true;
        getMonthsPicklist()
        .then(result => {
            this.isLoading = false;
            if(result.length > 0){
                this.monthsList = result;
                this.monthValue = this.monthsList[0].value;
                this.selectedMonth = this.monthsList[0].label;
                this.monthsList.forEach(element => { // setup the month value to label map to display the selected month label in the data screen
                    this.monthsMap[element.value] = element.label;
                });
                this.monthScreen = true;
            } else { //custom error
                this.customError = 'No Available Data for Commission!';
            }
        })
        .catch(error => {
            this.error = error;
            this.isLoading = false;
        });
    }

    loadDataScreen() {
        this.error = undefined;
        this.customError = undefined;
        this.isLoading = true;
        this.paymentRequestLink = undefined;
        getData({
            month: this.monthValue,
            paymentRequestId: this.recordId,
            runningUser: this.currUserObj
        })
        .then(result => {
            this.commissionData = result;
            if(result.status == 'success'){
                this.paymentRequestLink = this.urlPrefix + 'detail/' + result.paymentReqId + this.urlSuffix;
                if(this.commissionData.collectionsList.length > 0){
                    this.datatableSetup();
                }
                if(!this.viewBreakdownMode){
                    this.showCancelButton = false;
                    this.monthScreen = false;
                }
                if(this.commissionData.spiffAmount != null && this.commissionData.spiffAmount != undefined){
                    this.spiffAmount = this.commissionData.spiffAmount;
                }
                console.log('spiff amount: ' + this.spiffAmount);
                this.setModalToLarge();
                this.dataScreen = true;
            } else { //custom error
                this.customError = result.errorMsg;
                if(result.existingPaymentRequestId != null){
                    this.paymentRequestLink = this.urlPrefix + 'detail/' + result.existingPaymentRequestId + this.urlSuffix;
                }
            } 
            this.isLoading = false;
        })
        .catch(error => {
            this.error = error;
            this.isLoading = false;
        });
    }

    datatableSetup(){
        this._allData = this.commissionData.collectionsList.map((item) => ({
            ...item,
            MondayAccountName: item.Monday_Account__r.Name,
            MondayAccountURL: this.urlPrefix + 'account/' + item.Monday_Account__r.Id + this.urlSuffix,
            PartnerCompanyName: item.Partner_Company__r.Name,
            PartnerCompanyURL: this.urlPrefix + item.Partner_Company__r.Id + this.urlSuffix
        }));
        this.totalRecountCount = this._allData.length; 
        this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); 
        this.filteredData = this._allData;
        this.displayedCollections = this._allData.slice(0,this.pageSize); 
        this.endingRecord = this.pageSize;
    }

    handleMDFChange(e){
        this.selectedMDFs = e.detail.value;
        if(this.selectedMDFs.length > 0) {
            this.showUploadMdfFiles = true;
            this.fileKeyMdf = this.commissionData.paymentReqId + '1';
            this.mdfFileUploadLabel = 'In order to get the payment for ' + this.selectedMonth + ' MDF, please upload relevant files here:';
        } else this.showUploadMdfFiles = false;
        let totalMdfAmount = 0;
        let mdfCount = 0;
        this.selectedMDFs.forEach(mdfId => {
            totalMdfAmount += this.mdfIdtoAmount_map[mdfId];
            mdfCount++;
        });
        this.mdfAmount = totalMdfAmount;
        this.mdfNumRequiredFiles = mdfCount;
    }

    loadFilesScreen(){
        this.error = undefined;
        this.customError = undefined;
        this.invoiceFileUploadLabel = 'In order to get the payment for ' + this.selectedMonth + ' please upload your invoice here:';
        this.isLoading = true;
        getFilesScreenData({
            partnerCompanyId: this.currUserObj['AccountId'],
            paymentReqId: this.recordId,
            requestedMonth: this.monthValue
        }).then(result => {
            this.mdfOptions = result.mdfOptions_list;
            this.mdfIdtoAmount_map = result.mdfIdtoAmount_map;
            this.selectedMDFs = result.selected_list;
            if(this.selectedMDFs != null && this.selectedMDFs.length > 0) this.mdfNumRequiredFiles = this.selectedMDFs.length;
            if(this.mdfOptions != null && this.mdfOptions.length > 0) this.mdfFound = true;
            if(this.recordId && this.filesScreenFirstRun){ //running from existing payment request (draft or rejected) - need to delete old files 
                this.filesScreenFirstRun = false;
                deleteOldFiles({
                    paymentRequestId: this.recordId
                })
                .then(result => {
                    this.dataScreen = false;
                    this.setModalToNormal();
                    this.filesScreen = true;
                    this.isLoading = false;
                })
                .catch(error => {
                    this.error = error;
                    this.isLoading = false;
                });
            } else { //running from first time submitting the payment request 
                if(this.runningFromHomepage && this.filesScreenFirstRun) {
                    this.filesScreenFirstRun = false;
                    if(this.selectedMDFs == undefined || this.selectedMDFs.length == 0) this.mdfAmount = 0;
                }
                this.dataScreen = false;
                this.setModalToNormal();
                this.filesScreen = true;
                this.isLoading = false;
            }
        })
        .catch(error => {
            this.error = error;
            this.isLoading = false;
        });
    }

    saveAsDraft(){
        this.error = undefined;
        this.customError = undefined;
        this.isLoading = true;
        this.template.querySelectorAll('c-file-upload-improved').forEach(element => { 
            element.clearSessionStorage();
        });
        updatePaymentRequest({
            paymentRequestId: this.commissionData.paymentReqId,
            mdfAmount: this.mdfAmount,
            selectedMDFs: this.selectedMDFs,
            invoiceFileVerId: this.uploadedInvoiceId,
            invoiceCurrency: this.currencyValue,
            invoiceNumber: this.invoiceNumber,
            invoiceDate: this.invoiceDate
        })
        .then(result => {
            this.isLoading = false;
            this.submittedScreenText = 'It is saved as a draft and you can go back and edit it.';
            this.showCancelButton = true;
            this.filesScreen = false;
            this.submittedScreen = true;
            this.cancelBtnLabel = 'Finish';
            if(this.recordId != null) refreshApex(this.wiredPaymentReqResult);
        })
        .catch(error => {
            this.error = error;
            this.isLoading = false;
        });
    }

    setModalToLarge() {
        this.template.querySelector('[data-id="submitmodal"]').classList.add('slds-modal_large');
    }

    setModalToNormal() {
        this.template.querySelector('[data-id="submitmodal"]').classList.remove('slds-modal_large');
    }

    handleInvoiceDateChange(event){
        this.invoiceDate = event.detail.value;
    }

    handleInvoiceNumberChange(event){
        this.invoiceNumber = event.detail.value;
    }
    
    submitInputValidation(event){
        let fileUploaded = this.checkFilesUploaded(event);
        let inputValid = this.checkInputValidity(event);
        return (fileUploaded && inputValid);
    }

    checkFilesUploaded(event){
        this.customInvoiceFilesError = undefined;
        this.customMdfFilesError = undefined;
        var fileUploaded = true;
        let filesArray = this.template.querySelectorAll('c-file-upload-improved');
        filesArray.forEach(element => { // validate files upload
            var validateFileUpload = element.validate();
            if(!validateFileUpload.isValid){
                fileUploaded = false;
                var filesLabel = element.getLabel();
                if(filesLabel == this.invoiceFileUploadLabel){
                    this.customInvoiceFilesError = validateFileUpload.errorMessage;
                }
                if(filesLabel == this.mdfFileUploadLabel){
                    this.customMdfFilesError = validateFileUpload.errorMessage;
                }
            }
        });
        if(fileUploaded) filesArray.forEach(element => { element.clearSessionStorage(); });
        return fileUploaded;
    }

    checkInputValidity(event){
        let inputValid = [...this.template.querySelectorAll('lightning-input')].reduce((val, inp) => {
            inp.reportValidity();
            return val && inp.checkValidity();
        }, true);
        return inputValid;
    }

    submitPaymentRequestForApproval(event){
        this.error = undefined;
        if(this.submitInputValidation(event)){
            this.isLoading = true;
            submitForApproval({
                paymentRequestId: this.commissionData.paymentReqId,
                mdfAmount: this.mdfAmount,
                selectedMDFs: this.selectedMDFs,
                invoiceFileVerId: this.uploadedInvoiceId,
                invoiceCurrency: this.currencyValue,
                invoiceNumber: this.invoiceNumber,
                invoiceDate: this.invoiceDate
            })
            .then(result => {
                if(this.recordId) {
                    this.submittedScreenTitle = 'Payment Request Submitted Successfully!';
                    refreshApex(this.wiredPaymentReqResult);
                }
                this.submittedScreenText = 'It is submitted for approval process and you will be notified on the progress.';
                this.showCancelButton = true;
                this.filesScreen = false;
                this.cancelBtnLabel = 'Finish';
                this.submittedForApproval = true;
                this.submittedScreen = true;
                this.isLoading = false;
            })
            .catch(error => {
                this.error = error;
                this.isLoading = false;
            });
        }
    }

    handleResults(event){
        this.filteredData = event.detail.filteredData;
        this.page = 1;
        this.totalRecountCount = this.filteredData.length; 
        this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); 
        this.displayRecordPerPage(this.page);
    }

    //clicking on previous button this method will be called
    previousHandler() {
        if (this.page > 1) {
            this.page = this.page - 1; //decrease page by 1
            this.displayRecordPerPage(this.page);
        }
    }

    //clicking on next button this method will be called
    nextHandler() {
        if((this.page<this.totalPage) && this.page !== this.totalPage){
            this.page = this.page + 1; //increase page by 1
            this.displayRecordPerPage(this.page);            
        }             
    }

    //this method displays records page by page
    displayRecordPerPage(page){
        this.startingRecord = ((page -1) * this.pageSize) ;
        this.endingRecord = (this.pageSize * page);
        this.endingRecord = (this.endingRecord > this.totalRecountCount) ? this.totalRecountCount : this.endingRecord; 
        this.displayedCollections = this.filteredData.slice(this.startingRecord, this.endingRecord);
        this.startingRecord = this.startingRecord + 1;
    } 

    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                  return primer(x[field]);
              }
            : function (x) {
                  return x[field];
              };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.filteredData];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.filteredData = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
        this.displayRecordPerPage(this.page);
    }


    handleMonthChange(event) {
        this.monthValue = event.detail.value;
        this.selectedMonth = this.monthsMap[event.detail.value];
    }

    handleSendVersIds(event){
        this.uploadedInvoiceId = event.detail['versIds'][0];
    }

    handleCancelClick(){
        this.showModal = false;
        this.dataScreen = false;
        this.filesScreen = false;
        this.submittedScreen = false;
        this.cancelBtnLabel = 'Cancel';
        this.mdfAmount = 0;
        this.mdfFound = false;
        this.showUploadMdfFiles = false;
        this.spiffAmount = 0;
        this.invoiceNumber = null;
        this.invoiceDate = null;
        localStorage.clear();
        if(this.viewBreakdownMode || this.monthScreen){
            this.viewBreakdownMode = false;
            this.monthScreen = false;
        }
        if(this.recordId == null){ //cancel from homepage
            const refreshPaymentRequestsListEvent = new CustomEvent("refreshpaymentslist");
            this.dispatchEvent(refreshPaymentRequestsListEvent);
        }
    }

    goBackToDataScreen(){
        this.error = undefined;
        this.customError = undefined;
        this.filesScreen = false;
        this.setModalToLarge();
        this.dataScreen = true;
    }

    downloadCSVFile() {   
        let rowEnd = '\n';
        let csvString = '';
        let rowData = new Set();
        this._allData.forEach(function (record) {
            Object.keys(record).forEach(function (key) {
                rowData.add(key);
            });
        });

        rowData = Array.from(rowData);
        csvString += rowData.join(',');
        csvString += rowEnd;

        for(let i=0; i < this._allData.length; i++){
            let colValue = 0;
            for(let key in rowData) {
                if(rowData.hasOwnProperty(key)) {
                    let rowKey = rowData[key];
                    if(colValue > 0){
                        csvString += ',';
                    }
                    let value = this._allData[i][rowKey] === undefined ? '' : this._allData[i][rowKey];
                    csvString += '"'+ value +'"';
                    colValue++;
                }
            }
            csvString += rowEnd;
        }
        let downloadElement = document.createElement('a');
        downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
        downloadElement.target = '_self';
        downloadElement.download = 'Collections Data.csv';
        downloadElement.click(); 
    }

    isEmpty(obj){
        return ((obj == null || obj == 'null' || typeof(obj) == 'undefined' || obj == 'undefined' || obj == '') && obj != 0);
    }
}