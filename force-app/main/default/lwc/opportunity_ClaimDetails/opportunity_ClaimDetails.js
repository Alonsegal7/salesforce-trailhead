import { LightningElement,wire,api } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import getUserDetails from '@salesforce/apex/Opportunity_ClaimDetailsController.getUserDetails';
import greenBucketIcon from '@salesforce/resourceUrl/greenBucket';
import orangeBucketIcon from '@salesforce/resourceUrl/orangeBucket';
import stage from '@salesforce/schema/Opportunity.StageName';
import claimedARR from '@salesforce/schema/Opportunity.Claimed_ARR__c';
import addedARR from '@salesforce/schema/Opportunity.Expected_ARR__c';
import closedOpp from '@salesforce/schema/Opportunity.IsClosed';
import maClaimedARR from '@salesforce/schema/Opportunity.Monday_Account_ARR__c';
import ccARR from '@salesforce/schema/Opportunity.CC_Products_ARR_Sum__c';
import coSellARR from '@salesforce/schema/Opportunity.Co_Sell_Products_ARR_Sum__c';
import productsARR from '@salesforce/schema/Opportunity.Product_ARR__c';
import gbARR from '@salesforce/schema/Opportunity.Green_Bucket_ARR_V2__c';
import isGBOpp from '@salesforce/schema/Opportunity.Is_Potential_GB_Opportunity__c';
import isGBAcc from '@salesforce/schema/Opportunity.Is_Account_Green_Bucket_New__c';
import overrideIsGB from '@salesforce/schema/Opportunity.Potential_GB_Opp_Override__c';
import overrideCLMProcess from '@salesforce/schema/Opportunity.Override_Legal_Document_Validation__c';
import overrideCLMProcessReason from '@salesforce/schema/Opportunity.Legal_Document_Override_Reason__c';
import overrideReason from '@salesforce/schema/Opportunity.Green_Bucket_Override_Reason__c';
import triggerSlackCelebration from '@salesforce/schema/Opportunity.Trigger_Slack_Celebration__c';
import isPrimarySOSigned from '@salesforce/schema/Opportunity.Is_Primary_SO_Signed__c';
import claimARROverride from '@salesforce/schema/Opportunity.Claimed_ARR_Override__c';
import billingIds from '@salesforce/schema/Opportunity.Billing_Ids__c';
import userId from '@salesforce/user/Id';
const fields = [claimedARR,addedARR,stage,closedOpp,maClaimedARR,ccARR,coSellARR,productsARR,gbARR,isGBOpp,isGBAcc,claimARROverride,isPrimarySOSigned,billingIds];

export default class Opportunity_ClaimDetails extends LightningElement {
    @api recordId;
    oppDetails;
    claimedARR;
    addedARR;
    maClaimedARR;
    ccARR;
    coSellARR;
    productsARR;
    gbARR;
    expectedArrOnWon;
    helpText='';
    gbIcon=greenBucketIcon;
    obIcon=orangeBucketIcon;
    isGBOpp;
    soARR;
    showClaimDetails=false;
    showOverrideDetails=false;
    isOppClosed;
    isGBAcc;
    loading=true;
    userDetails;
    isManager;
    isAdmin;
    isPrimarySOSigned;
    claimARROverride;
    bbPickersARR;
    billingIds;
    overrideFields=[overrideIsGB,overrideReason,triggerSlackCelebration,overrideCLMProcess,overrideCLMProcessReason];
    

    @wire(getRecord, { recordId: '$recordId', fields })
    opp({data, error}){
        this.oppDetails=data;
        this.claimedARR=getFieldValue(this.oppDetails, claimedARR);
        this.addedARR=getFieldValue(this.oppDetails, addedARR);
        this.maClaimedARR=getFieldValue(this.oppDetails, maClaimedARR);
        this.ccARR=getFieldValue(this.oppDetails, ccARR);
        this.coSellARR=getFieldValue(this.oppDetails, coSellARR);
        this.productsARR=getFieldValue(this.oppDetails, productsARR);
        this.gbARR=getFieldValue(this.oppDetails, gbARR);
        this.isGBOpp=getFieldValue(this.oppDetails, isGBOpp);
        this.isGBAcc=getFieldValue(this.oppDetails, isGBAcc);
        this.isPrimarySOSigned=getFieldValue(this.oppDetails,isPrimarySOSigned);
        this.claimARROverride=getFieldValue(this.oppDetails,claimARROverride);
        console.log('Raz Ben Ron this.claimARROverride: '+this.claimARROverride);
        this.isOppClosed=getFieldValue(this.oppDetails, closedOpp);
        this.billingIds=getFieldValue(this.oppDetails, billingIds);
        //this.expectedArrOnWon=this.maClaimedARR+this.claimedARR;
        if(this.isGBAcc==true){
            this.expectedArrOnWon=this.claimedARR; 
        }else{
            this.expectedArrOnWon=this.maClaimedARR+this.claimedARR; 
        }
        if(this.isPrimarySOSigned==true){
            this.soARR=this.productsARR-this.ccARR-this.coSellARR;
        }else{
            this.soARR=0;
        }
        
        /*if(this.maClaimedARR&&this.maClaimedARR!=0)
            this.helpText=this.maClaimedARR.toString()+' (OB ARR)';
        if(this.claimedARR&&this.claimedARR!=0){
            if(this.helpText!=''){
                this.helpText+=' + ';
            }
            this.helpText+=this.claimedARR.toString()+' (claimed ARR)';
        }*/
        if(!this.maClaimedARR||this.maClaimedARR=='')
            this.maClaimedARR=0;
        if(!this.claimedARR||this.claimedARR=='')
            this.claimedARR=0;
        if(this.billingIds&&this.billingIds!=''){
            this.bbPickersARR=this.claimedARR-this.productsARR;
        }
        this.loading=false;
    }

    @wire(getUserDetails, { userId: userId }) 
        userData({data, error}){
            if(data){
                this.userDetails=data;
                this.isAdmin=this.userDetails.Profile.Name=='System Administrator';
                this.isManager=this.userDetails.Profile.Name=='Managers monday sales';
                console.log('Raz Ben Ron user data: '+ JSON.stringify(data));
            }
        }

    handleDetailsClick(e){
        if(this.showClaimDetails==false)
            this.showClaimDetails=true;
        else
            this.showClaimDetails=false;
    }
    handleOverrideClick(e){
        if(this.showOverrideDetails==false)
            this.showOverrideDetails=true;
        else
            this.showOverrideDetails=false;
    }
    handleCancelClick(e){
        this.showOverrideDetails=false;
    }

    get showManagersSection(){
        return (this.isManager||this.isAdmin)==true;
    }
    get GBOppVar(){
        return this.isGBOpp==true;
    }
    get hasARROverride(){
        if(this.claimARROverride){
            return true;
        }else{
            return false;
        }
    }
    get hasPickersARR(){
        if(this.bbPickersARR){
            return true;
        }else{
            return false;
        }
    }
}