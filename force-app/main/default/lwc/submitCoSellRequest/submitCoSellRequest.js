import { LightningElement, api, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import createNewCoSellRequest from '@salesforce/apex/CoSellRequestService.createNewCoSellRequest';
import getAssociatePotentialOpps from '@salesforce/apex/CoSellRequestService.getAssociatePotentialOpps';
import OPP_ACCOUNTID from "@salesforce/schema/Opportunity.AccountId";
import OPP_STAGE from "@salesforce/schema/Opportunity.StageName";
import OPP_OWNER_MANAGER_NAME from "@salesforce/schema/Opportunity.Owner.Manager.Name";
import OPP_OWNER_MANAGER_ID from "@salesforce/schema/Opportunity.Owner.ManagerId";
import OPP_OWNER_ID from "@salesforce/schema/Opportunity.OwnerId";
import OPP_RT_DEV_NAME from "@salesforce/schema/Opportunity.RecordType.DeveloperName";
import OPP_OWNER_ACCOUNTID from "@salesforce/schema/Opportunity.Owner.AccountId";
import SYNCED_QUOTE from "@salesforce/schema/Opportunity.SyncedQuoteId";
import SYNCED_QUOTE_STATUS from "@salesforce/schema/Opportunity.SyncedQuote.DH_Quote_Status__c";
import SYNCED_QUOTE_PUBLISH from "@salesforce/schema/Opportunity.SyncedQuote.Is_Published__c";
import SYNCED_QUOTE_DATE from "@salesforce/schema/Opportunity.SyncedQuote.CreatedDate";

export default class SubmitCoSellRequest extends LightningElement {
    @api recordId;
    error;
    customError;
    accountId;
    oppStage;
    managerName;
    managerId;
    currentOppRT;
    submittedTextManager;
    beforeSaveMsg;
    partnerCompanyId;
    oppOwnerId;
    isLoading = true;
    mainScreen = false;
    showSpinner = true;
    newCoSellScreen = false;
    associateScreen = false;
    submittedScreen = false;
    displayPsFields = false;
    allowSwitchMainSec = false;
    currentOppMustBeMain = false;
    radioValue = '';
    cosellRequest = {};
    associateOppsOptions = [];
    associateOppsMap = {};
    associatedOppId;
    mainOppId;
    secondaryOppId;
    soBadgeControl = {};
    oppsSyncedQts_map = {};

    get options() {
        return [
            { label: 'Create a co-sell opp opportunity', value: 'newopp' },
            { label: 'Associate an existing opportinity as co-sell', value: 'existingopp' },
        ];
    }

    get newCosellInputFields() {
        return ['Secondary_Opportunity_Owner__c','Reason__c','Reason_Details__c',];
    }

    get existingCosellInputFields() {
        return ['Reason__c','Reason_Details__c',];
    }

    get psFields() {
        return ['PS_Deal_Type__c','PS_Type__c','PS_Type_Details__c','PS_Use_Case_Description__c'];
    }

    @wire(getRecord, { recordId: '$recordId', fields: [OPP_ACCOUNTID, OPP_STAGE, OPP_OWNER_MANAGER_NAME, OPP_OWNER_MANAGER_ID, OPP_OWNER_ID, OPP_RT_DEV_NAME, OPP_OWNER_ACCOUNTID, SYNCED_QUOTE, SYNCED_QUOTE_STATUS, SYNCED_QUOTE_PUBLISH, SYNCED_QUOTE_DATE] })
    wiredRecord({ error, data }) {
        if (error) { this.error = error; }
        if (data) {
            this.oppStage = getFieldValue(data, OPP_STAGE);
            this.accountId = getFieldValue(data, OPP_ACCOUNTID);
            this.managerName = getFieldValue(data, OPP_OWNER_MANAGER_NAME);
            this.managerId = getFieldValue(data, OPP_OWNER_MANAGER_ID);
            this.currentOppRT = getFieldValue(data, OPP_RT_DEV_NAME);
            this.partnerCompanyId = getFieldValue(data, OPP_OWNER_ACCOUNTID);
            this.oppOwnerId = getFieldValue(data, OPP_OWNER_ID);
            let syncedQuoteId = getFieldValue(data, SYNCED_QUOTE);
            if(syncedQuoteId){
                let qt = {};
                qt.Id = syncedQuoteId;
                qt.Is_Published__c = getFieldValue(data, SYNCED_QUOTE_PUBLISH);
                qt.Status__c = getFieldValue(data, SYNCED_QUOTE_STATUS);
                qt.CreatedDate = getFieldValue(data, SYNCED_QUOTE_DATE);;
                if(qt.Status == 'Won') qt.isWon = true;
                this.oppsSyncedQts_map[this.recordId] = qt;
                console.log('wiredRecord qt: ' + JSON.stringify(qt));
                console.log('wiredRecord allowSwitchMainSec: ' + this.allowSwitchMainSec);
            }
            this.beforeSaveMsg = 'Once clicking Save, your request will be submitted for approval to ' + this.managerName + '.';
            this.mainScreen = true;
        }
        this.isLoading = false;
    }

    handleSave(event){
        console.log('handleSave');
        if (!this.checkInputValidity()) return;
        this.cosellRequest.Monday_Account__c = this.accountId;
        this.cosellRequest.Assigned_Approver__c = this.managerId;
        this.cosellRequest.Partner_Company__c = this.partnerCompanyId;
        if(this.partnerCompanyId) this.cosellRequest.Partner_User__c = this.oppOwnerId;
        if(this.radioValue == 'newopp'){
            this.cosellRequest.Type__c = 'Create';
            this.cosellRequest.Main_Opportunity__c = this.recordId;
            this.cosellRequest.Secondary_Opportunity_Owner__c = this.cosellRequest.Secondary_Opportunity_Owner__c[0];
            this.cosellRequest.Main_Opportunity_Stage__c = this.oppStage;
        } else if (this.radioValue == 'existingopp'){
            this.cosellRequest.Type__c = 'Associate';
            this.cosellRequest.Main_Opportunity__c = this.mainOppId;
            this.cosellRequest.Secondary_Opportunity__c = this.secondaryOppId;
            if(this.mainOppId == this.recordId){ // current opp is main
                this.cosellRequest.Main_Opportunity_Stage__c = this.oppStage;
            } else { //other opp selected as main
                this.cosellRequest.Main_Opportunity_Stage__c = this.associateOppsMap[this.mainOppId].StageName;
            }
        }
        this.callCreateNewCoSellRequest();
    }

    // submit co-sell request
    callCreateNewCoSellRequest(){
        console.log('handleSave this.cosellRequest: ' + JSON.stringify(this.cosellRequest));
        this.beforeCallback();
        createNewCoSellRequest({
            newCoSellReq: this.cosellRequest
        })
        .then(result => {
            console.log('handleSave createNewCoSellRequest result: ' + JSON.stringify(result));
            if(result.newCoSellReqId != null){
                console.log('handleSave createNewCoSellRequest result new rec id: ' + result.newCoSellReqId);
                this.submittedTextManager = 'Your Co-sell Request was submitted for the approval of ' + this.managerName;
                this.mainScreen = false;
                this.submittedScreen = true;
            }
            this.isLoading = false;  
        })
        .catch(error => {
            console.log('handleSave createNewCoSellRequest result error: ' + JSON.stringify(error));
            this.error = error;
            this.isLoading = false;
        });
    }

    updateCosellRequest(e){
        let fieldVal = e.detail.value;
        let fieldName = e.target.dataset.id;
        this.cosellRequest[fieldName] = fieldVal;
        if(fieldName == 'Reason__c'){ 
            if(fieldVal == 'Delivery - PS') this.displayPsFields = true;
            else this.displayPsFields = false;
        }
    }

    handleMainRadioChange(e) {
        this.radioValue = e.detail.value;
        this.displayPsFields = false;
        this.customError = '';
        if(this.radioValue == 'newopp'){ // Create a co-sell opp opportunity
            this.associateScreen = false;
            this.newCoSellScreen = true;
        } else if(this.radioValue == 'existingopp'){ // Associate an existing opportinity as co-sell
            this.newCoSellScreen = false;

            if(this.associateOppsOptions.length == 0){
                this.callGetAssociatePotentialOpps();
            } else {
                this.associateScreen = true;
            }
        }
    }

    callGetAssociatePotentialOpps(){
        this.beforeCallback();
        getAssociatePotentialOpps({
            accountId: this.accountId,
            mainOppRecordTypeName: this.currentOppRT
        })
        .then(result => {
            if(result.length == 0){ // no potential opps were found for associate -> we show a comment to the user that there is no potential opp to associate.
                this.customError = 'Could not find opportunities that can be associated as a co-sell.';
            } else {
                this.associateOppsOptions = result;
                console.log('handleRadioChange this.associateOppsOptions'+JSON.stringify(this.associateOppsOptions));
                this.setAssociateOppsMap();
                this.setAssociateOppsOptions();
                this.associateScreen = true;
            }
            this.isLoading = false;
        })
        .catch(error => {
            this.error = error;
            this.isLoading = false;
        });
    }

    setAssociateOppsOptions(){
        let res = [];
        this.associateOppsOptions.forEach(opp => {
            res.push({ label: opp.Name + ' (Owned by ' + opp.Owner.Name + ')', value: opp.Id })
        });
        this.associateOppsOptions = res;
        console.log('associateOppsOptions after setAssociateOppsOptions finished: '+JSON.stringify(this.associateOppsOptions));
    }

    setAssociateOppsMap(){
        let res = {};
        this.associateOppsOptions.forEach(opp => {
            res[opp.Id] = opp;
        });
        this.associateOppsMap = res;
        console.log('associateOppsMap after setAssociateOppsMap finished: '+JSON.stringify(this.associateOppsMap));
    }

    updateSoBadgeControl(){
        this.soBadgeControl = {};
        let mainOppQt = this.oppsSyncedQts_map[this.mainOppId];
        let secOppQt = this.oppsSyncedQts_map[this.secondaryOppId];
        if(mainOppQt){
            if(mainOppQt.Status__c == 'Won') this.soBadgeControl.main_signed = true;
            if(mainOppQt.Is_Published__c) this.soBadgeControl.main_published = true;
        }
        if(secOppQt){
            if(secOppQt.Is_Published__c) this.soBadgeControl.sec_published = true;
        }
        console.log('updateSoBadgeControl this.soBadgeControl : '+JSON.stringify(this.soBadgeControl));
    }

    handleAssociateOppSelected(event) {
        console.log('entered handleAssociateOppSelected');
        let selectedOppId = event.detail.value;
        let selectedQt = this.associateOppsMap[selectedOppId].SyncedQuote;
        let currQt = this.oppsSyncedQts_map[this.recordId];
        if(currQt == null || currQt == undefined || !currQt.isWon){ //if current opp does not have quote at all or does not have a won quote
            console.log('current opp does not have a won quote');
            if(selectedQt){ // if selected opp has a synced quote
                console.log('selected opp has a synced quote');
                if(selectedQt.DH_Quote_Status__c == 'Won') { // if selected opp has a won quote - switch forbidden. main should be the associated opp
                    console.log('selected opp has a won quote - switch forbidden. main should be the associated opp');
                    this.allowSwitchMainSec = false;
                    this.mainOppId = selectedOppId;
                    this.secondaryOppId = this.recordId;
                } else if ((currQt && currQt.Is_Published__c) || (selectedQt.Is_Published__c)){ // if main or selected opp has a published quote 
                    console.log('main or selected opp has a published quote');
                    this.allowSwitchMainSec = false; //when 1 or 2 opps have a published quote - switch is forbidden
                    if(currQt && currQt.Is_Published__c && selectedQt.Is_Published__c){ //if both have published quote - the main will be the one with the latest quote
                        console.log('both have published quote - the main will be the one with the latest quote');
                        if(currQt.CreatedDate >= selectedQt.CreatedDate){ // main is current opp
                            this.mainOppId = this.recordId;
                            this.secondaryOppId = selectedOppId;
                        } else { //main is selected opp
                            this.mainOppId = selectedOppId;
                            this.secondaryOppId = this.recordId;
                        }
                    } else if (currQt && currQt.Is_Published__c){ //if only current opp has a published quote then it will be the main
                        console.log('only current opp has a published quote then it will be the main');
                        this.mainOppId = this.recordId;
                        this.secondaryOppId = selectedOppId;
                    } else if (selectedQt.Is_Published__c){ //if only selected opp has a published quote then it will be the main
                        console.log('only selected opp has a published quote then it will be the main');
                        this.mainOppId = selectedOppId;
                        this.secondaryOppId = this.recordId;
                    }
                } else { // switch allowed. main should be the record Id
                    console.log('both opps have no published quotes');
                    this.allowSwitchMainSec = true;
                    this.mainOppId = this.recordId;
                    this.secondaryOppId = selectedOppId;
                }
            } else { //selected opp does not have a quote. main should be the record Id
                console.log('selected opp does not have a quote. main should be the record Id');
                if(currQt && currQt.Is_Published__c){ //if main opp has a quote at all or a published quote then switch will be forbidden
                    console.log('main opp has a published quote then switch will be forbidden');
                    this.allowSwitchMainSec = false;
                } else { // main opp has no published/won quote and selected opp has no quote - switch allowed
                    console.log('main opp has no published/won quote and selected opp has no quote - switch allowed');
                    this.allowSwitchMainSec = true;
                }
                this.mainOppId = this.recordId;
                this.secondaryOppId = selectedOppId;
            }
        } else { //current opp has a won quote - switch is forbidden (in wire). main should be the record Id
            console.log('current opp has a won quote - switch is forbidden (in wire). main should be the record Id');
            this.allowSwitchMainSec = false;
            this.mainOppId = this.recordId;
            this.secondaryOppId = selectedOppId;
        }
        this.associatedOppId = selectedOppId;
        this.oppsSyncedQts_map[selectedOppId] = selectedQt;
        this.updateSoBadgeControl();
        console.log('handleAssociateOppSelected this.associatedOppId : '+this.associatedOppId);
        console.log('handleAssociateOppSelected this.allowSwitchMainSec : '+this.allowSwitchMainSec);
        console.log('handleAssociateOppSelected this.mainOppId : '+this.mainOppId);
        console.log('handleAssociateOppSelected this.secondaryOppId : '+this.secondaryOppId);
    }

    handleSwitchMainSecondary(event) {
        let tempId = this.secondaryOppId;
        this.secondaryOppId = this.mainOppId;
        this.mainOppId = tempId;
        console.log('Switch Main Secondary this.mainOppId : '+this.mainOppId);
        console.log('Switch Main Secondary this.secondaryOppId : '+this.secondaryOppId);
    }

    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    beforeCallback() {
        this.isLoading = true;
        this.error = undefined;
    }

    checkInputValidity(event){
        let inputValid = [...this.template.querySelectorAll('.validate')].reduce((val, inp) => {
            inp.reportValidity();
            return val && inp.checkValidity();
        }, true);

        let cosellReqFieldValid = true;
        // note: checkValidity is not avaiable for lightning-input-field!!!
        this.template.querySelectorAll('lightning-input-field').forEach(element => {
            if (!element.value) {
                cosellReqFieldValid = false;
            }
            element.reportValidity();
        });

        if(inputValid && cosellReqFieldValid) console.log('All input look valid. Ready to save!');
        else console.log('Found invalid input entries.');
        return inputValid && cosellReqFieldValid;
    }
}