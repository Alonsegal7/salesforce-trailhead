import { LightningElement, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getAllPaymentRequests from '@salesforce/apex/Partner_PaymentRequestService.getAllPaymentRequests';

export default class PaymentRequestsTool extends LightningElement {
    error;
    draftPaymentReqs;
    rejectedPaymentReqs;
    submittedPaymentReqs;
    paidPaymentReqs;
    urlPrefix;
    urlSuffix;
    wiredPaymentRequestsResult;
    
    @wire(getAllPaymentRequests)
    wiredPaymentRequests(result) {
        this.wiredPaymentRequestsResult = result;
        if (result.data) {
            console.log('wiredPaymentRequests: '+JSON.stringify(result.data));
            console.log('result.data.isPartnerUser: '+result.data.isPartnerUser);
            if(result.data.isPartnerUser){
                this.urlPrefix = '/partners/s/';
                this.urlSuffix = '';
            } else {
                this.urlPrefix = '/lightning/r/';
                this.urlSuffix = '/view';
            }
            if(result.data.draftPaymentReqList.length > 0){
                this.draftPaymentReqs = result.data.draftPaymentReqList.map((item) => ({
                    ...item,
                    PaymentRequestLink: this.urlPrefix + 'detail/' + item.Id + this.urlSuffix,
                    CreatedDateFormatted: this.getShortDate(item.CreatedDate)
                }));
            }
            if(result.data.rejectedPaymentReqList.length > 0){
                this.rejectedPaymentReqs = result.data.rejectedPaymentReqList.map((item) => ({
                    ...item,
                    PaymentRequestLink: this.urlPrefix + 'detail/' + item.Id + this.urlSuffix
                }));
            }
            if(result.data.submittedPaymentReqList.length > 0){
                this.submittedPaymentReqs = result.data.submittedPaymentReqList.map((item) => ({
                    ...item,
                    PaymentRequestLink: this.urlPrefix + 'detail/' + item.Id + this.urlSuffix,
                    SubmittedDateFormatted: this.getShortDate(item.Pending_CPM_Review_Timestamp__c)
                }));
            }
            if(result.data.paidPaymentReqList.length > 0){
                this.paidPaymentReqs = result.data.paidPaymentReqList.map((item) => ({
                    ...item,
                    PaymentRequestLink: this.urlPrefix + 'detail/' + item.Id + this.urlSuffix
                }));
            }
            this.error = undefined;
        } else if (result.error) {
            console.log('wiredPaymentRequests error: '+JSON.stringify(result.error));
            this.error = result.error;
            this.draftPaymentReqs = undefined;
            this.rejectedPaymentReqs = undefined;
            this.submittedPaymentReqs = undefined;
        }
    }

    getShortDate(longDateValue){
        var date = new Date(longDateValue);
        return ((date.getDate() > 9) ? date.getDate() : ('0' + date.getDate())) + '/' + ((date.getMonth() > 8) ? (date.getMonth() + 1) : ('0' + (date.getMonth() + 1))) + '/' + date.getFullYear();
    }

    handleRefreshPayments(event){
        refreshApex(this.wiredPaymentRequestsResult);
    }
}