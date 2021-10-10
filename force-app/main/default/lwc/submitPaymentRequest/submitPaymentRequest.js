import { LightningElement } from 'lwc';
import getData from '@salesforce/apex/Partner_PaymentRequestService.getData';
import getMonthsPicklist from '@salesforce/apex/Partner_PaymentRequestService.getMonthsPicklist';
import saveNewPaymentRequest from '@salesforce/apex/Partner_PaymentRequestService.saveNewPaymentRequest';

const columns = [
    { label: 'Pulse Account ID', fieldName: 'Pulse_Account_Id__c' },
    { label: 'Monday Account', fieldName: 'Monday_Account__c' },
    { label: 'Account Source Type', fieldName: 'Account_Source_Type__c' },
    { label: 'Partner Company', fieldName: 'Partner_Company__c' },
    { label: 'Partner Tier', fieldName: 'Partner_Tier__c' },
    { label: 'Plan Name', fieldName: 'Plan_Name__c' },
    { label: 'Plan Period', fieldName: 'Plan_Period__c' },
    { label: 'Plan Tier', fieldName: 'Plan_Tier__c' },
    { label: 'Account Slug', fieldName: 'Account_Slug__c' },
    { label: 'Collection Amount USD', fieldName: 'Collection_Amount_USD__c' },
    { label: 'Commission Amount USD', fieldName: 'Commission_Amount_USD__c' },
    { label: 'Collection Happened At', fieldName: 'Collection_Happened_At__c' },
    { label: 'Event Type', fieldName: 'Event_Type__c' },
    { label: 'Payment Type', fieldName: 'Payment_Type__c' }
];

export default class SubmitPaymentRequest extends LightningElement {
    error;
    showSpinner = false;
    isCustomError = false;
    showModal = false;
    dataScreen = false;
    filesScreen = false;
    monthScreen = false;
    submittedScreen = false;
    customError = '';
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
    submittedScreenText;
    isSaveAsDraftChosen = false;
    fileId;


    handleMonthChange(event) {
        this.monthValue = event.detail.value;
        this.selectedMonth = this.monthsMap[event.detail.value];
    }


    loadMonthsPicklist(){
        this.error = '';
        this.customError = '';
        this.showSpinner = true;
        this.fileId = null;
        getMonthsPicklist()
        .then(result => {
            if(result.status_lwc == 'success'){
                console.debug(JSON.stringify(result));
                this.monthsList = result.monthsSelectionOptions_lwc;
                this.monthValue = this.monthsList[0].value;
                this.selectedMonth = this.monthsList[0].label;
                this.monthsList.forEach(element => { // setup the month value to label map to display the selected month label in the data screen
                    this.monthsMap[element.value] = element.label;
                });
                this.userFullName = result.userFullName_lwc;
                this.showModal = true;
                this.monthScreen = true;
            } else { //custom error
                this.isCustomError = true;
                this.customError = result.errorMsg_lwc;
            }
        })
        .catch(error => {
            this.error = error;
            this.showSpinner = false;
        });
    }

    loadDataScreen() {
        this.error = '';
        this.customError = '';
        this.showSpinner = true;
        getData({month: this.monthValue})
        .then(result => {
            this.showSpinner = false;
            console.debug(result.status_lwc);
            console.debug(JSON.stringify(result.collectionsList_lwc));
            if(result.status_lwc == 'success'){
                this.data = result.collectionsList_lwc;
                this.monthlyAmount = result.monthlyAmount_lwc;
                this.yearlyAmount = result.yearlyAmount_lwc;
                this.twoYearlyAmount = result.twoYearlyAmount_lwc;
                this.totalAmount = result.totalAmount_lwc;
                this.inboundPercent = result.inboundPercent_lwc;
                this.outboundPercent = result.outboundPercent_lwc;
                this.monthScreen = false;
                this.dataScreen = true;
            } else { //custom error
                this.isCustomError = true;
                this.customError = result.errorMsg_lwc;
                if(result.existingPaymentRequestId_lwc != null){
                    this.paymentRequestLink = '/one/one.app?#/sObject/'+ result.existingPaymentRequestId_lwc + '/view';
                }
            } 
        })
        .catch(error => {
            this.error = error;
            this.showSpinner = false;
        });
    }

    handleCancelClick(){
        this.showModal = false;
        this.dataScreen = false;
        this.filesScreen = false;
        this.monthScreen = false;
        this.submittedScreen = false;
    }

    loadFilesScreen(){
        this.dataScreen = false;
        this.filesScreen = true;
    }

    goBackToDataScreen(){
        this.filesScreen = false;
        this.dataScreen = true;
    }

    goBackToMonthScreen(){
        this.dataScreen = false;
        this.monthScreen = true;
    }

    createNewPaymentRequest(event){
        if(event.target.name == 'saveAsDraft') {
            this.isSaveAsDraftChosen = true;
        }
        saveNewPaymentRequest({paymentRequestDate: this.monthValue, monthlyAmount_apex: this.monthlyAmount, yearlyAmount_apex: this.yearlyAmount, twoYearlyAmount_apex: this.twoYearlyAmount, saveAsDraft: this.isSaveAsDraftChosen, fileId_apex: this.fileId})
        .then(result => {
            this.showSpinner = false;
            this.filesScreen = false;
            this.submittedScreen = true;
            if(result.status_lwc == 'success'){
                this.paymentRequestLink = '/one/one.app?#/sObject/'+ result.newPaymentRequestId_lwc + '/view';
                if(this.isSaveAsDraftChosen){
                    this.submittedScreenText = 'It is saved as a draft and you can go back and edit it.';
                } else {
                    this.submittedScreenText = 'It is submitted for approval process and you will be notified on the progress.';
                }
            } else {
                this.isCustomError = true;
                this.customError = result.errorMsg_lwc;
            } 
        })
        .catch(error => {
            this.error = error;
            this.showSpinner = false;
        });
    }

    downloadCSVFile() {   
        let rowEnd = '\n';
        let csvString = '';
        let rowData = new Set();
        this.data.forEach(function (record) {
            Object.keys(record).forEach(function (key) {
                rowData.add(key);
            });
        });

        rowData = Array.from(rowData);
        csvString += rowData.join(',');
        csvString += rowEnd;

        for(let i=0; i < this.data.length; i++){
            let colValue = 0;
            for(let key in rowData) {
                if(rowData.hasOwnProperty(key)) {
                    let rowKey = rowData[key];
                    if(colValue > 0){
                        csvString += ',';
                    }
                    let value = this.data[i][rowKey] === undefined ? '' : this.data[i][rowKey];
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

    get acceptedFormats() {
        return ['.pdf', '.doc', '.docx'];
    }

    handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        this.fileId = uploadedFiles[0].documentId;
        console.debug('event.detail.files : '+ JSON.stringify(event.detail.files));
    }
}