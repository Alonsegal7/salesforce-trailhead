import { LightningElement, track, wire, api } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import createRenewalSalesOrder from '@salesforce/apex/Renewal_Flat_CreateSalesOrder.createRenewalSalesOrder';
// import checkNewQuotes from '@salesforce/apex/Renewal_Flat_CreateSalesOrder.checkNewQuotes';
import originalContract from '@salesforce/schema/Opportunity.Selected_Company_Contract__c';
import paymentTerms from '@salesforce/schema/Opportunity.Payment_Terms__c';
import billingEntity from '@salesforce/schema/Opportunity.Billing_Entity__c';
import contractSeats from '@salesforce/schema/Opportunity.Selected_Company_Contract__r.Contract_Seats__c';
import contractEndDate from '@salesforce/schema/Opportunity.Selected_Company_Contract__r.EndDate';
import oppCurrencyCode from '@salesforce/schema/Opportunity.CurrencyIsoCode';
import contractTier from '@salesforce/schema/Opportunity.Selected_Company_Contract__r.Tier__c';
import contractPeriod from '@salesforce/schema/Opportunity.Selected_Company_Contract__r.Period__c';
import contractRenewalUnitPrice from '@salesforce/schema/Opportunity.Selected_Company_Contract__r.Weighted_Ave_Renewal_Unit_Price_CORE__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const fields = [oppCurrencyCode,originalContract,billingEntity,contractSeats,paymentTerms,contractEndDate,contractTier,contractPeriod,contractRenewalUnitPrice];                    

export default class Quote_renewalCreation extends LightningElement{
    @track opportunityId;
    @track newQuote;
    @api recordId;
    error;
    customError;
    showCreateRenewalSoSection=false;
    showNewQuoteSection=false;
    showConfirmation=false;
    showCreateButton=true;
    oppDetails;
    originalContract;
    paymentTerms;
    billingEntity;
    contractSeats;
    contractEndDate;
    contractTier;
    contractPeriod;
    contractRenewalUnitPrice;
    contractRenewalUnitPriceWithCurrencyText;
    oppCurrencyCode;
    missingBe = false;
    missingContract = false;
    missingPaymentTerms = false;
    loading=false;
    loadingModal=true;
    StartDate;
    total=0;
    formFields= [oppCurrencyCode,originalContract,billingEntity,contractSeats,paymentTerms,contractEndDate,contractTier,contractPeriod,contractRenewalUnitPrice]; 

    @wire(getRecord, { recordId: '$recordId', fields })
    opp({data, error}){
        if (data) {
            this.oppDetails=data;
            this.originalContract= getFieldValue(this.oppDetails, originalContract);
            this.oppCurrencyCode= getFieldValue(this.oppDetails, oppCurrencyCode);
            this.billingEntity=getFieldValue(this.oppDetails, billingEntity);
            this.paymentTerms=getFieldValue(this.oppDetails, paymentTerms);
            this.contractSeats=getFieldValue(this.oppDetails, contractSeats);
            this.contractEndDate=getFieldValue(this.oppDetails, contractEndDate);
            this.contractTier=getFieldValue(this.oppDetails, contractTier);
            this.contractPeriod=getFieldValue(this.oppDetails, contractPeriod);
            this.contractRenewalUnitPrice=getFieldValue(this.oppDetails, contractRenewalUnitPrice);
            this.contractRenewalUnitPriceWithCurrencyText = this.contractRenewalUnitPrice +' '+ this.oppCurrencyCode;
            console.log('contractRenewalUnitPriceText '+this.contractRenewalUnitPriceWithCurrencyText);
            console.log('Payment Terms- '+this.paymentTerms);
            console.log('BE- '+this.billingEntity);
            console.log('Contract- '+this.originalContract);
            var calcTotal = this.contractSeats*this.contractRenewalUnitPrice*12;
            this.total=calcTotal +' ' + this.oppCurrencyCode;            

            if(this.originalContract == null) {
                this.missingContract = true;
            }
            if(this.billingEntity == null) {
                this.missingBe = true;
            }
            if(this.paymentTerms == null) {
                this.missingPaymentTerms = true;
            }
            this.loadingModal=false;
        } 
        else if (error) {
            console.log('### error: ' + error.body.message);
            this.error = error;
        }
        this.loadingModal=false;
    }

    handleCancelClick(e){
        this.showCreateRenewalSoSection=false;
        this.showNewQuoteSection=false;
    }
    handleStart(e) {
        
        if (this.missingContract || this.missingBe || this.missingPaymentTerms) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Required fields are missing!',
                    message: 'Make sure to have a billing entity, primary contract and payment terms on the opportunity before creating a renewal SO. Once added, refresh the page',
                    variant: 'error',
                }),
            );
        }
        else {
            if(this.showCreateRenewalSoSection==false) {
                this.showCreateRenewalSoSection=true;
            }
            else
                this.showCreateRenewalSoSection=false;
        }
    }
    
    handleSubmitClick(e) {
        this.showCreateRenewalSoSection=false;
        this.showConfirmation=true;
    }
    
    handleConfirmationCancel(e) {
        this.showConfirmation=false;
        this.showCreateRenewalSoSection=true;
    }
    
    handleCreateClick(e) {
        this.showConfirmation=false;
        this.showCreateRenewalSoSection=true;
        this.loadingModal=true;
        console.log('Entered createClick');
        const oppIds = [this.recordId];
        console.log(oppIds);
        createRenewalSalesOrder({renewalOppIds: oppIds})
        .then(response => {
            this.loadingModal = false;
            console.log('Response: '+JSON.stringify(response));
            if(response){
                console.log('Entered response');
                this.newQuote = response.quotesToCreate;
                console.log('newQuote ID: '+this.newQuote);
                this.showNewQuoteSection = true;
                this.showCreateRenewalSoSection=false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Renewal SO Created!',
                        message: 'Refresh this page to see the new renewal SO',
                        variant: 'success',
                        mode: 'sticky',
                    }),
                );
            } else { 
                console.log('### error: empty response');
            }
        })
        .catch(error => {
            this.error = error;
            this.loadingModal = false;
        });
    };
}