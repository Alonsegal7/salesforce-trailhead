import { LightningElement, api, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import getMonthsPicklist from '@salesforce/apex/Partner_PaymentRequestService.getMonthsPicklist';
import getData from '@salesforce/apex/Partner_PaymentRequestService.getData';
import deleteOldFiles from '@salesforce/apex/Partner_PaymentRequestService.deleteOldFiles';
import submitForApproval from '@salesforce/apex/Partner_PaymentRequestService.submitForApproval';
import updatePaymentRequest from '@salesforce/apex/Partner_PaymentRequestService.updatePaymentRequest';
import PAYMENT_REQ_STATUS_FIELD from '@salesforce/schema/Payment_Request__c.Status__c';
import PAYMENT_REQ_MONTH_FIELD from '@salesforce/schema/Payment_Request__c.Month__c';
import PAYMENT_REQ_MDF_FIELD from '@salesforce/schema/Payment_Request__c.MDF_Amount__c';
import PAYMENT_REQ_SPIFF_FIELD from '@salesforce/schema/Payment_Request__c.Spiff_Amount__c';
import submittedScreenGif from '@salesforce/resourceUrl/makeItRainGif';

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
    columns = columns;
    data;
    monthlyAmount;
    yearlyAmount;
    twoYearlyAmount;
    totalAmount;
    inboundPercent;
    outboundPercent;
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
    
    //sort & filter variables
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

    get currencies() {
        return [
            { label: 'USD', value: 'USD' },
            { label: 'EUR', value: 'EUR' },
            { label: 'GBP', value: 'GBP' },
        ];
    }

    

    @wire(getRecord, { recordId: '$recordId', fields: [PAYMENT_REQ_STATUS_FIELD, PAYMENT_REQ_MONTH_FIELD, PAYMENT_REQ_MDF_FIELD, PAYMENT_REQ_SPIFF_FIELD] })
    wiredPaymentReq(result) {
        this.wiredPaymentReqResult = result;
        if (result.data) {
            this.showViewBreakdownBtn = true;
            var statusValue = getFieldValue(result.data, PAYMENT_REQ_STATUS_FIELD);
            this.selectedMonth = getFieldValue(result.data, PAYMENT_REQ_MONTH_FIELD);
            this.monthValue = this.selectedMonth;
            this.mdfAmount = getFieldValue(result.data, PAYMENT_REQ_MDF_FIELD);
            this.spiffAmount = getFieldValue(result.data, PAYMENT_REQ_SPIFF_FIELD);
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
                }
                this.allowSubmit = true;
            }
            if(this.mdfAmount != null && this.mdfAmount != '' && this.mdfAmount > 0) {
                this.showUploadMdfFiles = true;
                this.fileKeyMdf = this.newPaymentRequestId + '1';
                this.mdfFileUploadLabel = 'In order to get the payment for ' + this.selectedMonth + ' MDF, please upload relevant files here:';
            } else this.showUploadMdfFiles = false;
        } 
    }

    handleCurrencyChange(event) {
        this.currencyValue = event.detail.value;
    }

    handleSpiffAmountChange(event) {
        this.spiffAmount = event.detail.value;
    }

    handleMdfAmountChange(event) {
        this.mdfAmount = event.detail.value;
        console.log('mdfAmount: '+this.mdfAmount);
        if(this.mdfAmount != null && this.mdfAmount != '' && this.mdfAmount > 0) {
            this.showUploadMdfFiles = true;
            this.fileKeyMdf = this.newPaymentRequestId + '1';
            this.mdfFileUploadLabel = 'In order to get the payment for ' + this.selectedMonth + ' MDF, please upload relevant files here:';
        } else this.showUploadMdfFiles = false;
        console.log('showUploadMdfFiles: '+this.showUploadMdfFiles);
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
            if(result.status_lwc == 'success'){
                this.monthsList = result.monthsSelectionOptions_lwc;
                this.monthValue = this.monthsList[0].value;
                this.selectedMonth = this.monthsList[0].label;
                this.monthsList.forEach(element => { // setup the month value to label map to display the selected month label in the data screen
                    this.monthsMap[element.value] = element.label;
                });
                this.userFullName = result.userFullName_lwc;
                this.monthScreen = true;
            } else { //custom error
                this.customError = result.errorMsg_lwc;
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
            paymentRequestId: this.recordId
        })
        .then(result => {
            this.isLoading = false;
            if(result.isPartnerUser_lwc){
                this.urlPrefix = '/partners/s/';
                this.urlSuffix = '';
            } else {
                this.urlPrefix = '/lightning/r/';
                this.urlSuffix = '/view';
            }
            if(result.status_lwc == 'success'){
                this._allData = result.collectionsList_lwc.map((item) => ({
                    ...item,
                    MondayAccountName: item.Monday_Account__r.Name,
                    MondayAccountURL: this.urlPrefix + 'account/' + item.Monday_Account__r.Id + this.urlSuffix,
                    PartnerCompanyName: item.Partner_Company__r.Name,
                    PartnerCompanyURL: this.urlPrefix + item.Partner_Company__r.Id + this.urlSuffix
                }));
                this.totalRecountCount = this._allData.length; 
                this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); 
                this.filteredData = this._allData;
                this.data = this._allData.slice(0,this.pageSize); 
                this.endingRecord = this.pageSize;
                this.monthlyAmount = result.monthlyAmount_lwc;
                this.yearlyAmount = result.yearlyAmount_lwc;
                this.twoYearlyAmount = result.twoYearlyAmount_lwc;
                this.totalAmount = result.totalAmount_lwc;
                this.inboundPercent = result.inboundPercent_lwc;
                this.outboundPercent = result.outboundPercent_lwc;
                this.paymentRequestLink = this.urlPrefix + 'detail/' + result.newPaymentRequestId_lwc + this.urlSuffix;
                this.newPaymentRequestId = result.newPaymentRequestId_lwc;
                console.log('this.newPaymentRequestId: ' + this.newPaymentRequestId);
                if(!this.viewBreakdownMode){
                    this.showCancelButton = false;
                    this.monthScreen = false;
                }
                this.setModalToLarge();
                this.dataScreen = true;
            } else { //custom error
                this.customError = result.errorMsg_lwc;
                if(result.existingPaymentRequestId_lwc != null){
                    this.paymentRequestLink = this.urlPrefix + 'detail/' + result.existingPaymentRequestId_lwc + this.urlSuffix;
                }
            } 
        })
        .catch(error => {
            this.error = error;
            this.isLoading = false;
        });
    }

    loadFilesScreen(){
        this.error = undefined;
        this.customError = undefined;
        this.invoiceFileUploadLabel = 'In order to get the payment for ' + this.selectedMonth + ' commission, please update your invoice here:';
        if(this.recordId && this.filesScreenFirstRun){
            this.isLoading = true;
            this.filesScreenFirstRun = false;
            deleteOldFiles({
                paymentRequestId: this.recordId
            })
            .then(result => {
                this.isLoading = false;
                if(result.status_lwc == 'success'){
                    this.dataScreen = false;
                    this.setModalToNormal();
                    this.filesScreen = true;
                } else {
                    this.customError = result.errorMsg_lwc;
                } 
            })
            .catch(error => {
                this.error = error;
                this.isLoading = false;
            });
        } else {
            if(this.runningFromHomepage && this.filesScreenFirstRun) {
                this.filesScreenFirstRun = false;
                this.mdfAmount = 0;
                this.spiffAmount = 0;
            }
            this.dataScreen = false;
            this.setModalToNormal();
            this.filesScreen = true;
        }
    }

    saveAsDraft(){
        this.error = undefined;
        this.customError = undefined;
        this.isLoading = true;
        console.log('this.uploadedInvoiceId: '+ this.uploadedInvoiceId);
        updatePaymentRequest({
            paymentRequestId: this.newPaymentRequestId,
            mdfAmount: this.mdfAmount,
            spiffAmount: this.spiffAmount,
            incoiveFileVerId: this.uploadedInvoiceId,
            invoiceCurrency: this.currencyValue
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

    submitPaymentRequestForApproval(event){
        this.error = undefined;
        this.customError = undefined;
        var fileUploadIsValid = true;
        this.template.querySelectorAll('c-file-upload-improved').forEach(element => { // validate files upload
            var validateFileUpload = element.validate();
            if(!validateFileUpload.isValid){
                fileUploadIsValid = false;
                this.customError = validateFileUpload.errorMessage;
            }
        });
        if(fileUploadIsValid){
            this.isLoading = true;
            console.log('this.uploadedInvoiceId: '+ this.uploadedInvoiceId);
            submitForApproval({
                paymentRequestId: this.newPaymentRequestId,
                mdfAmount: this.mdfAmount,
                spiffAmount: this.spiffAmount,
                incoiveFileVerId: this.uploadedInvoiceId,
                invoiceCurrency: this.currencyValue
            })
            .then(result => {
                this.isLoading = false;
                if(result.status_lwc == 'success'){
                    if(this.recordId) {
                        this.submittedScreenTitle = 'Payment Request Submitted Successfully!'
                    }
                    this.submittedScreenText = 'It is submitted for approval process and you will be notified on the progress.';
                    this.showCancelButton = true;
                    this.filesScreen = false;
                    this.submittedScreen = true;
                    this.cancelBtnLabel = 'Finish';
                    this.submittedForApproval = true;
                } else {
                    this.customError = result.errorMsg_lwc;
                } 
                if(this.recordId != null) refreshApex(this.wiredPaymentReqResult);
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
        this.data = this.filteredData.slice(this.startingRecord, this.endingRecord);
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
        console.log('In handleSendVersIds');
        console.log('event.detail: '+ JSON.stringify(event.detail));
        this.uploadedInvoiceId = event.detail['versIds'][0];
    }

    handleCancelClick(){
        this.showModal = false;
        this.dataScreen = false;
        this.filesScreen = false;
        this.submittedScreen = false;
        this.cancelBtnLabel = 'Cancel';
        this.mdfAmount = 0;
        this.spiffAmount = 0;
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
}