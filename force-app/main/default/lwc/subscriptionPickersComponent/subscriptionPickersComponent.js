import { LightningElement,track,wire,api } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import getSubscriptions from '@salesforce/apex/SubscriptionPickerController.getSubscriptions';
import getClaimed from '@salesforce/apex/SubscriptionPickerController.getClaimed';
import claimSubs from '@salesforce/apex/SubscriptionPickerController.claimSubs';
import unclaimSubs from '@salesforce/apex/SubscriptionPickerController.uncliamSubscriptions';
import getUserDetails from '@salesforce/apex/SubscriptionPickerController.getUserDetails';
import updateMA from '@salesforce/apex/SubscriptionPickerController.updateMondayAccount';
import isclosed from '@salesforce/schema/Opportunity.IsClosed';
import accId from '@salesforce/schema/Opportunity.AccountId';
import user_Id from '@salesforce/user/Id';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
const fields = [isclosed,accId];

export default class subscriptionPickersComponent extends LightningElement {
    @api recordId;
    @track selected=[];
    @track subsToClaim=[];
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
    itemToRemoveIndex;
    arrToRemove=0;
    isAdmin=false;
    isPartner=false;
    oppIsClosed=false;
    maId;

    @wire(getRecord, { recordId: '$recordId', fields })
    opp({data, error}){
        this.oppDetails=data;
        this.oppIsClosed=getFieldValue(this.oppDetails, isclosed);
        this.maId=getFieldValue(this.oppDetails, accId);
    }


    @wire(getSubscriptions,{oppId:'$recordId'})
        wiredSubs({data, error}){
            console.log('Raz this.recordId: '+this.recordId);
            if(data){
                this.loadingComp=false;
                console.log('data: '+JSON.stringify(data));              
                this.error = undefined;
                const temp=[];
                for(let key in data) {
                    if (data.hasOwnProperty(key)) { 
                        var singleObj2 = {};
                        singleObj2['value'] = key;
                        singleObj2['label'] = data[key].Name_for_CC_Claim__c;
                        singleObj2['arrGain'] = data[key].ARR_Gain__c;
                        singleObj2['subId'] = data[key].Id;
                        console.log('singleObj2: '+JSON.stringify(singleObj2));  
                        temp.push(singleObj2);
                        this.subsMap[key]=data[key];
                    }
                }
                this.subsToClaim=temp;
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
                    console.log('data[i]: '+data[i]);
                    var singleObj = {};
                    singleObj['label'] = data[i].Name_for_CC_Claim__c;
                    singleObj['arrGain'] = data[i].ARR_Gain__c;
                    singleObj['subId'] = data[i].Id;
                    this.claimedARR+=data[i].ARR_Gain__c;
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

    get selectedValues() {
        return this.selected.join(',');
    }

    get hasSubsToClaim() {                       
        return this.subsToClaim.length!=0;
    }
    get hasClaimedSubs() {                       
        return this.subsFinal.length!=0;
    }
    get hasNoSubs() {                       
        return this.subsFinal.length==0&&this.subsToClaim.length==0;
    }
    get changesDisabled(){
        console.log('Raz Ben Ron changes disabled?: '+this.oppIsClosed==true&&this.isAdmin==false);
        return this.oppIsClosed==true&&this.isAdmin==false;
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
        console.log('this.selected: '+this.selected);
        //console.log('Raz Ben Ron this.totalGainARR: '+this.totalGainARR);
        for(let i in this.selected) {
            var singleObj = {};
            singleObj['label'] = this.subsMap[this.selected[i]].Name_for_CC_Claim__c;
            singleObj['arrGain'] = this.subsMap[this.selected[i]].ARR_Gain__c;
            singleObj['subId'] = this.subsMap[this.selected[i]].Id;
            console.log('Raz Ben Ron this.subsMap[this.selected[i]].ARR_Gain__c: '+this.subsMap[this.selected[i]].ARR_Gain__c);
            console.log('Raz Ben Ron totalARRTemp 1: '+totalARRTemp);
            totalARRTemp+=this.subsMap[this.selected[i]].ARR_Gain__c;
            console.log('Raz Ben Ron totalARRTemp 2: '+totalARRTemp);
            temp2.push(singleObj);
            tempCodes.push(this.subsMap[this.selected[i]].Product_Code__c);
        }
        this.newClaims=temp2;
        this.newSubsCodes=tempCodes;
        this.subsFinal=[];
        this.selectedARR=totalARRTemp;
        console.log('Raz Ben Ron totalARRTemp: '+totalARRTemp);
        console.log('this.selected: '+JSON.stringify(this.selected));
        console.log('this.newSubsCodes: '+JSON.stringify(this.newSubsCodes));
        this.subsFinal.push.apply(this.subsFinal,this.subsClaimed);
        this.subsFinal.push.apply(this.subsFinal,this.newClaims);
    }

    handleSave(e){
        this.loadingSave=true;
        console.log('this.selected: '+JSON.stringify(this.selected));
        claimSubs( {oppId: this.recordId, subsIdsToClaim: this.selected, productCodes: this.newSubsCodes}).then((resultSubs)=>{
            console.log('resultSubs: '+resultSubs);
            this.saveDisabled=true;
            this.savedSuccess=true;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Plans Claimed Successfully!',
                    variant: 'success',
                }),
            );
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
    }
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

}