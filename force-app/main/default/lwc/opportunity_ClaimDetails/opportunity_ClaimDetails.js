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
import overrideReason from '@salesforce/schema/Opportunity.Green_Bucket_Override_Reason__c';
import triggerSlackCelebration from '@salesforce/schema/Opportunity.Trigger_Slack_Celebration__c';
import userId from '@salesforce/user/Id';
const fields = [claimedARR,addedARR,stage,closedOpp,maClaimedARR,ccARR,coSellARR,productsARR,gbARR,isGBOpp,isGBAcc];

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
    overrideFields=[overrideIsGB,overrideReason,triggerSlackCelebration];
    

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
        this.expectedArrOnWon=this.maClaimedARR+this.claimedARR;
        this.isGBOpp=getFieldValue(this.oppDetails, isGBOpp);
        console.log('Raz Ben Ron this.isGBOpp: '+this.isGBOpp);
        console.log('Raz Ben Ron this.gbIcon, this.obIcon: '+this.gbIcon+ ' '+this.obIcon);
        this.isGBAcc=getFieldValue(this.oppDetails, isGBAcc);
        this.soARR=this.productsARR-this.ccARR-this.coSellARR;
        this.isOppClosed=getFieldValue(this.oppDetails, closedOpp);
        if(this.maClaimedARR&&this.maClaimedARR!=0)
            this.helpText=this.maClaimedARR.toString()+' (OB ARR)';
        if(this.claimedARR&&this.claimedARR!=0){
            if(this.helpText!=''){
                this.helpText+=' + ';
            }
            this.helpText+=this.claimedARR.toString()+' (claimed ARR)';
        }
        if(!this.maClaimedARR||this.maClaimedARR=='')
            this.maClaimedARR=0;
        if(!this.claimedARR||this.claimedARR=='')
            this.claimedARR=0;
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
}