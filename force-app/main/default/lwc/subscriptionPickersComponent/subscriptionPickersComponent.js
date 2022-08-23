import { LightningElement,track,wire,api } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import getSubscriptions from '@salesforce/apex/SubscriptionPickerController.getSubscriptions';
import getClaimed from '@salesforce/apex/SubscriptionPickerController.getClaimed';
import claimSubs from '@salesforce/apex/SubscriptionPickerController.claimSubs';
import unclaimSubs from '@salesforce/apex/SubscriptionPickerController.uncliamSubscriptions';
import getUserDetails from '@salesforce/apex/SubscriptionPickerController.getUserDetails';
import updateMA from '@salesforce/apex/SubscriptionPickerController.updateMondayAccount';
import getMASubs from '@salesforce/apex/SubscriptionPickerController.getMASubs';
import getLatestPlan from '@salesforce/apex/SubscriptionPickerController.getLatestPlan';
import updateOppPlan from '@salesforce/apex/SubscriptionPickerController.updateOppPlan';
import sendOppToBB from '@salesforce/apex/SubscriptionPickerController.sendOppToBB';
import isclosed from '@salesforce/schema/Opportunity.IsClosed';
import closeDateThisMonth from '@salesforce/schema/Opportunity.Close_Date_This_Month__c';
import oppRecordTypeName from '@salesforce/schema/Opportunity.RecordType.DeveloperName';
import accId from '@salesforce/schema/Opportunity.AccountId';
import expectedPlan from '@salesforce/schema/Opportunity.Expected_Plan_Name__c';
import createdDate from '@salesforce/schema/Opportunity.CreatedDate';
import user_Id from '@salesforce/user/Id';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
const fields = [isclosed,accId,closeDateThisMonth,expectedPlan,oppRecordTypeName,createdDate];

export default class subscriptionPickersComponent extends LightningElement {
    @api recordId;
    @track selected=[];
    @track subsToClaim=[];
    @track unclaimableSubs=[];
    @track newSubsCodes=[];
    @track newClaims=[];
    @track subsClaimed=[];
    @track subsFinal=[];
    @track subsMap={};
    @track saveDisabled=true;
    @track savedSuccess=false;
    @track loadingSave=false;
    @track loadingComp=true;
    @track dialogVisible=false;
    @track subsToUnclaim=[];
    @track userDetails;
    @track oppDetails;
    @track refreshAfterAccUpdate=false;;
    //@track totalGainARR=0;
    claimedARR=0;
    selectedARR=0;
    selectedFullARR=0;
    claimedFullARR=0
    itemToRemoveIndex;
    arrToRemove=0;
    isAdmin=false;
    isPartner=false;
    oppIsClosed=false;
    closeDateThisMonth;
    maId;
    maSubs=[];
    suggestPlanModal=false;
    latestPlan;
    latestSub;
    planChecked=false;
    oppExpectedPlan;
    oppRecordType;
    oppCreateDate;
    showRenewalARR=false;
    componentTitle;

    @wire(getRecord, { recordId: '$recordId', fields })
    opp({data, error}){
        this.oppDetails=data;
        this.oppIsClosed=getFieldValue(this.oppDetails, isclosed);
        this.maId=getFieldValue(this.oppDetails, accId);
        this.closeDateThisMonth=getFieldValue(this.oppDetails, closeDateThisMonth);
        this.oppExpectedPlan=getFieldValue(this.oppDetails, expectedPlan);
        this.oppRecordType=getFieldValue(this.oppDetails, oppRecordTypeName);
        this.oppCreatedDate=getFieldValue(this.oppDetails,createdDate);
        if(this.oppRecordType=='CS_Opportunity') {
            this.showRenewalARR=true;
        }
    }


    @wire(getSubscriptions,{oppId:'$recordId'})
        wiredSubs({data, error}){
            console.log('Raz this.recordId: '+this.recordId);
            if(data){
                this.loadingComp=false;
                console.log('data: '+JSON.stringify(data));              
                this.error = undefined;
                const temp=[];
                const unclaimableTemp=[];
                for(let key in data) {
                    var claimName = data[key].Name_for_CC_Claim__c;
                    console.log('rectype'+this.oppRecordType);
                    if (this.oppRecordType=='CS_Opportunity') {claimName = data[key].Name_for_CC_Claim_Full_ARR__c; }
                    if (data.hasOwnProperty(key)) { 
                        var singleObj2 = {};
                        singleObj2['value'] = key;
                        singleObj2['label'] = claimName;
                        singleObj2['arrGain'] = data[key].ARR_Gain__c;
                        singleObj2['subId'] = data[key].Id;
                        singleObj2['arr'] = data[key].ARR__c;
                        var isClaimable=(data[key].Claimable_Activation_Date__c||data[key].Activation_Date__c>=this.oppCreateDate);
                        console.log('Raz isClaimable  '+data[key].Id+' '+isClaimable);
                        singleObj2['isClaimable'] = isClaimable;
                        console.log('singleObj2 : '+JSON.stringify(singleObj2));  
                        if(isClaimable){
                            temp.push(singleObj2);
                        }else{//not claimable
                            if(this.isAdmin==true){
                                temp.push(singleObj2);
                                singleObj2['label'] += ' - ❌ Passed Claim Date, Available for Admins Only';
                            }else{
                                unclaimableTemp.push(singleObj2);
                                singleObj2['label'] += ' - 🚫 Passed Claim Date';
                            }
                        }
                        this.subsMap[key]=data[key];
                        console.log('singleobj'+singleObj2);
                    }
                }
                this.subsToClaim=temp;
                this.unclaimableSubs=unclaimableTemp;
            }
            else if (error) {
                this.error = error;
                this.subs = undefined;
            }
        }
    @wire(getClaimed,{oppId:'$recordId'})
    wiredClaimedSubs({data, error}){
            if(data){
                console.log('data: '+JSON.stringify(data)); 
                this.error = undefined;
                const temp3=[];
                for(let i in data) {
                    var claimName = data[i].Name_for_CC_Claim__c;
                    if (this.oppRecordType=='CS_Opportunity') {claimName = data[i].Name_for_CC_Claim_Full_ARR__c; }
                    console.log('data[i]: '+data[i]);
                    var singleObj = {};
                    singleObj['label'] = claimName;
                    singleObj['arrGain'] = data[i].ARR_Gain__c;
                    singleObj['subId'] = data[i].Id;
                    singleObj['arr'] = data[i].ARR__c;
                    this.claimedARR+=data[i].ARR_Gain__c;
                    this.claimedFullARR+=data[i].ARR__c;
                    temp3.push(singleObj);
                }
                this.subsClaimed=temp3;
                this.subsFinal=this.subsClaimed;
                console.log('subsClaimed: '+JSON.stringify(this.subsClaimed));              

            }
            else if (error) {
                this.error = error;
                this.subs = undefined;
            }
        }
    @wire(getUserDetails, { userId: user_Id }) 
        userData({data, error}){
            if(data){
                this.userDetails=data;
                this.isAdmin=this.userDetails.Profile.Name=='System Administrator';
                this.isPartner=this.userDetails.IsPortalEnabled==true;
                console.log('Raz Ben Ron user data: '+ JSON.stringify(data));
            }
        }

    @wire(getMASubs, { oppId: '$recordId'})
    maSubsData({data, error}){
        if(data){
            console.log('Raz Ben Ron ma subs: '+ JSON.stringify(data));
            this.maSubs=data;
        }
    }
    get selectedValues() {
        return this.selected.join(',');
    }

    get hasSubsToClaim() {                       
        return this.subsToClaim.length!=0||this.unclaimableSubs.length!=0;
    }
    get hasClaimedSubs() {                       
        return this.subsFinal.length!=0;
    }
    get hasNoSubs() {                       
        return this.subsFinal.length==0&&this.subsToClaim.length==0&&this.unclaimableSubs.length==0&&this.maSubs.length==0;
    }
    get noSubsAfterSync() {              
        return this.subsFinal.length==0&&this.subsToClaim.length==0&&this.unclaimableSubs.length==0&&this.maSubs.length!=0;
    }
    get changesDisabled(){
        console.log('Raz Ben Ron changes disabled?: '+this.oppIsClosed==true&&this.isAdmin==false&&this.closeDateThisMonth==false);
        return this.oppIsClosed==true&&this.isAdmin==false&&this.closeDateThisMonth==false;
    }
    handleChange(e) {
        this.selected = e.detail.value;
        if(this.selected.length == 0){
            this.saveDisabled=true;
        }else{
            this.saveDisabled=false;
        }
        const temp2=[];
        const tempCodes=[];
        var totalARRTemp=0;
        var totalFullARRTemp=0;
        console.log('this.selected: '+this.selected);
        //console.log('Raz Ben Ron this.totalGainARR: '+this.totalGainARR);
        for(let i in this.selected) {
            var singleObj = {};
            var claimName = this.subsMap[this.selected[i]].Name_for_CC_Claim__c;
            if (this.oppRecordType=='CS_Opportunity') {claimName = this.subsMap[this.selected[i]].Name_for_CC_Claim_Full_ARR__c; }
            singleObj['label'] = claimName;
            singleObj['arrGain'] = this.subsMap[this.selected[i]].ARR_Gain__c;
            singleObj['subId'] = this.subsMap[this.selected[i]].Id;
            singleObj['arr'] = this.subsMap[this.selected[i]].ARR__c;
            console.log('Raz Ben Ron this.subsMap[this.selected[i]].ARR_Gain__c: '+this.subsMap[this.selected[i]].ARR_Gain__c);
            console.log('Raz Ben Ron totalARRTemp 1: '+totalARRTemp);
            totalARRTemp+=this.subsMap[this.selected[i]].ARR_Gain__c;
            totalFullARRTemp+=this.subsMap[this.selected[i]].ARR__c;//Collect entire arr for renewals (sum the sub.arr also for multi product cases)
            console.log('Raz Ben Ron totalARRTemp 2: '+totalARRTemp);
            temp2.push(singleObj);
            tempCodes.push(this.subsMap[this.selected[i]].Product_Code__c);
        }
        this.newClaims=temp2;
        this.newSubsCodes=tempCodes;
        this.subsFinal=[];
        this.selectedARR=totalARRTemp;
        this.selectedFullARR=totalFullARRTemp;
        console.log('Raz Ben Ron totalARRTemp: '+totalARRTemp);
        console.log('this.selected: '+JSON.stringify(this.selected));
        console.log('this.newSubsCodes: '+JSON.stringify(this.newSubsCodes));
        this.subsFinal.push.apply(this.subsFinal,this.subsClaimed);
        this.subsFinal.push.apply(this.subsFinal,this.newClaims);
    }

    syncOppToBB(e){
        sendOppToBB({oppId: this.recordId}).then((resultSubs)=>{
            console.log('opp sent to BB');
        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error syncing opp to bb',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
        });
    }

    handleSave(e){
        this.loadingSave=true;
        if(this.planChecked==true){
            console.log('this.selected: '+JSON.stringify(this.selected));
            claimSubs( {oppId: this.recordId, subsIdsToClaim: this.selected, productCodes: this.newSubsCodes}).then((resultSubs)=>{
                console.log('resultSubs: '+resultSubs);
                this.saveDisabled=true;
                this.savedSuccess=true;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Payments Claimed Successfully!',
                        variant: 'success',
                    }),
                );
                this.syncOppToBB(e);
                this.loadingSave=false;
            refreshApex(this.recordId);
            }).catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error Claiming Payments',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
                this.loadingSave=false;
            });
        }else{
            this.handleGetPlanSuggestion(e);
        }
    }
    handleGetPlanSuggestion(e){
        getLatestPlan( {subsIdsToClaim: this.selected, oppId: this.recordId}).then((resultSub)=>{
            this.planChecked=true;
            if(resultSub){
                console.log('resultSub.Plan_Name__c: '+resultSub.Plan_Name__c);
                this.latestSub=resultSub;
                this.latestPlan=resultSub.Plan_Name__c;
                this.suggestPlanModal=true;
            }else{
                this.handleSave(e);
            }
            
        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error Getting Plan',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
        });
    }

    handleUpdatePlan(e){
        this.suggestPlanModal=false;
        updateOppPlan( {sub: this.latestSub, oppId: this.recordId}).then(()=>{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Opportunity Plan Updated Successfully!',
                    variant: 'success',
                }),
            );
            this.handleSave(e);
        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error Updating Plan',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
        });
    }

    handleIgnorePlanSuggestion(e){
        this.suggestPlanModal=false;
        this.handleSave(e);
    }
    handleCancelPlanSuggestion(e){
        this.suggestPlanModal=false;
        this.planChecked=false;
        this.loadingSave=false;
    }

    //Currently, renewal opps subs will alwys have a single claim, so we not going to handle deduction of arr on removal
    handleItemRemove (event) {
        if(this.changesDisabled==false){
            this.dialogVisible=true;
            const name = event.detail.item.label;
            const subId = event.detail.item.subId;
            this.itemToRemoveIndex = event.detail.index;
            this.arrToRemove = event.detail.item.arrGain;
            console.log('Raz Ben Ron this.itemToRemoveIndex: '+this.itemToRemoveIndex);
            //this.subsToUnclaim.push(name);
            this.subsToUnclaim.push(subId);
        }
    }
    handleCancelClick(event) {
        this.dialogVisible=false;
    }
    handleConfirmClick(event) {
        this.loadingSave=true;
        unclaimSubs( {subsToUnclaim: this.subsToUnclaim,oppId: this.recordId}).then((resultSubs)=>{
            console.log('resultSubs: '+resultSubs);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Plans Removed Successfully!',
                    variant: 'success',
                }),
            );
            this.loadingSave=false;
            this.subsToUnclaim=[];
            this.dialogVisible=false;
            let items = this.subsFinal;
            items.splice(this.itemToRemoveIndex, 1);
            this.subsFinal = items;
            console.log('Raz Ben subPick this.subsMap[this.itemToRemoveIndex]'+JSON.stringify(this.subsMap[this.itemToRemoveIndex]));
            this.claimedARR-=this.arrToRemove;
            this.syncOppToBB(event);
            refreshApex(this.recordId);
        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error Removing Payments',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
            this.loadingSave=false;
        });
    }

    handleSyncClick(event) {
        this.loadingSave=true;
        updateMA( {maId : this.maId}).then((resultAcc)=>{
            console.log('resultAcc: '+resultAcc);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Syncing Credit Card Payments..',
                    variant: 'success',
                }),
            );
            this.loadingSave=false;
            this.refreshAfterAccUpdate=true;
        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error Syncing Credit Card Payments',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
            this.loadingSave=false;
        });
    }

    get totalARRGain(){
        return this.claimedARR+this.selectedARR;
    }

    get totalARRFull(){
        return this.claimedFullARR+this.selectedFullARR;
    }

    get headerTile(){
        if(this.oppRecordType=='CS_Opportunity'){
            this.componentTitle='Claim Credit Card Payments - Renewal Opportuinty'
        }
        else{
            this.componentTitle='Claim Credit Card Payments'
        }
        return this.componentTitle;
    }

}