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
            console.log('result.data.isPartnerUser_lwc: '+result.data.isPartnerUser_lwc);
            if(result.data.isPartnerUser_lwc){
                this.urlPrefix = '/partners/s/';
                this.urlSuffix = '';
            } else {
                this.urlPrefix = '/lightning/r/';
                this.urlSuffix = '/view';
            }
            if(result.data.draftPaymentReqList_lwc.length > 0){
                this.draftPaymentReqs = result.data.draftPaymentReqList_lwc.map((item) => ({
                    ...item,
                    PaymentRequestLink: this.urlPrefix + 'detail/' + item.Id + this.urlSuffix,
                    CreatedDateFormatted: this.getShortDate(item.CreatedDate)
                }));
            }
            if(result.data.rejectedPaymentReqList_lwc.length > 0){
                this.rejectedPaymentReqs = result.data.rejectedPaymentReqList_lwc.map((item) => ({
                    ...item,
                    PaymentRequestLink: this.urlPrefix + 'detail/' + item.Id + this.urlSuffix
                }));
            }
            if(result.data.submittedPaymentReqList_lwc.length > 0){
                this.submittedPaymentReqs = result.data.submittedPaymentReqList_lwc.map((item) => ({
                    ...item,
                    PaymentRequestLink: this.urlPrefix + 'detail/' + item.Id + this.urlSuffix,
                    SubmittedDateFormatted: this.getShortDate(item.Pending_CPM_Review_Timestamp__c)
                }));
            }
            if(result.data.paidPaymentReqList_lwc.length > 0){
                this.paidPaymentReqs = result.data.paidPaymentReqList_lwc.map((item) => ({
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