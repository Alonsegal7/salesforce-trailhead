import { LightningElement, track, wire, api } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import createRenewalSalesOrder from '@salesforce/apex/Renewal_Flat_CreateSalesOrder.createRenewalSalesOrder';
// import checkNewQuotes from '@salesforce/apex/Renewal_Flat_CreateSalesOrder.checkNewQuotes';
import originalContract from '@salesforce/schema/Opportunity.Selected_Company_Contract__c';
import billingEntity from '@salesforce/schema/Opportunity.Billing_Entity__c';
import contractSeats from '@salesforce/schema/Opportunity.Selected_Company_Contract__r.Contract_Seats__c';
import contractEndDate from '@salesforce/schema/Opportunity.Selected_Company_Contract__r.EndDate';
import contractTier from '@salesforce/schema/Opportunity.Selected_Company_Contract__r.Tier__c';
import contractPeriod from '@salesforce/schema/Opportunity.Selected_Company_Contract__r.Period__c';
import contractUnitPrice from '@salesforce/schema/Opportunity.Selected_Company_Contract__r.Weighted_Average_Net_Per_Unit__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const fields = [originalContract,billingEntity,contractSeats,contractEndDate,contractTier,contractPeriod,contractUnitPrice];                    

export default class Quote_renewalCreation extends LightningElement{
    @track opportunityId;
    @track newQuote;
    @api recordId;
    error;
    customError;
    showCreateRenewalSoSection=false;
    showNewQuoteSection=false;
    showCreateButton=true;
    oppDetails;
    originalContract;
    billingEntity;
    contractSeats;
    contractSeats;
    contractEndDate;
    contractTier;
    contractPeriod;
    contractUnitPrice;
    missingBe = false;
    missingContract = false;
    loading=false;
    loadingModal=true;
    StartDate;
    total=0;
    formFields= [originalContract,billingEntity,contractSeats,contractEndDate,contractTier,contractPeriod,contractUnitPrice]; 

    @wire(getRecord, { recordId: '$recordId', fields })
    opp({data, error}){
        if (data) {
            this.oppDetails=data;
            this.originalContract= getFieldValue(this.oppDetails, originalContract);
            this.billingEntity=getFieldValue(this.oppDetails, billingEntity);
            this.contractSeats=getFieldValue(this.oppDetails, contractSeats);
            this.contractEndDate=getFieldValue(this.oppDetails, contractEndDate);
            // var contractStartDate = new Date(this.contractEndDate);
            // contractStartDate.setDate(contractStartDate.getDate() + 1);
            // this.StartDate = contractStartDate;
            this.contractTier=getFieldValue(this.oppDetails, contractTier);
            this.contractPeriod=getFieldValue(this.oppDetails, contractPeriod);
            this.contractUnitPrice=getFieldValue(this.oppDetails, contractUnitPrice);
            console.log('Calc original contract End Date-'+this.contractEndDate);
            console.log('Calc new contract Start Date-'+ Date(this.contractEndDate));
            console.log('Calc contract Start Date-'+this.StartDate);
            var calcTotal = this.contractSeats*this.contractUnitPrice*12;
            this.total=calcTotal;
            console.log('Calc total: '+this.total);
            

            if(this.originalContract == null) {
                this.missingContract = true;
            }
            if(this.billingEntity == null) {
                this.missingBe = true;
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
        
        if (this.missingContract || this.missingBe) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Required fields are missing!',
                    message: 'Make sure to link a billing entity and a primary contract to opportunity before creating a renewal SO',
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
    
    handleCreateClick(e) {
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
            } else { //custom error
                // this.customError = response.errorMsg_lwc;
            }
        })
        .catch(error => {
            this.error = error;
            this.loadingModal = false;
        });
    };
}