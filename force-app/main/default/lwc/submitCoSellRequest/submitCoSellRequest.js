import { LightningElement, api, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { getRecord, updateRecord, getFieldValue } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import createNewCoSellRequest from '@salesforce/apex/CoSellRequestService.createNewCoSellRequest';
import getAssociatePotentialOpps from '@salesforce/apex/CoSellRequestService.getAssociatePotentialOpps';
import send10Kemail from '@salesforce/apex/CoSellRequestService.send10Kemail';
import OPP_ACCOUNTID from "@salesforce/schema/Opportunity.AccountId";
import OPP_STAGE from "@salesforce/schema/Opportunity.StageName";
import OPP_ARR from "@salesforce/schema/Opportunity.Green_Bucket_ARR_V2__c";
import OPP_OWNER_MANAGER_NAME from "@salesforce/schema/Opportunity.Owner.Manager.Name";
import OPP_OWNER_MANAGER_ID from "@salesforce/schema/Opportunity.Owner.ManagerId";
import OPP_OWNERS_MANAGER_TEAM from "@salesforce/schema/Opportunity.Owner_s_Manager_Team__c";
import OPP_OWNERS_OFFICE from "@salesforce/schema/Opportunity.Owner_Office_Live__c";
import OPP_OWNER_SEGMENT from "@salesforce/schema/Opportunity.Owner_Segment_Live__c";
import OPP_OWNER_ID from "@salesforce/schema/Opportunity.OwnerId";
import OPP_RT_DEV_NAME from "@salesforce/schema/Opportunity.RecordType.DeveloperName";
import OPP_OWNER_ACCOUNTID from "@salesforce/schema/Opportunity.Owner.AccountId";
import SYNCED_QUOTE from "@salesforce/schema/Opportunity.SyncedQuoteId";
import SYNCED_QUOTE_STATUS from "@salesforce/schema/Opportunity.SyncedQuote.DH_Quote_Status__c";
import SYNCED_QUOTE_PUBLISH from "@salesforce/schema/Opportunity.SyncedQuote.Is_Published__c";
import SYNCED_QUOTE_DATE from "@salesforce/schema/Opportunity.SyncedQuote.CreatedDate";
import COSELL_LEADER from "@salesforce/schema/Opportunity.Account.Co_Sell_Leader__c";
import ACC_ARR from "@salesforce/schema/Opportunity.Account.ARR__c";


export default class SubmitCoSellRequest extends LightningElement {
    @api recordId;
    userId = Id;
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
    chooseLeaderScreen = false;
    newCoSellScreen = false;
    associateScreen = false;
    submittedScreen = false;
    displayPsFields = false;
    displaySolutionLookup = false;
    psTypeDetailsRequired = true;
    allowSwitchMainSec = false;
    currentOppMustBeMain = false;
    showBackBtn = false;
    whatYouWishValue = '';
    cosellRequest = {};
    associateOppsOptions = [];
    associateOppsMap = {};
    associatedOppId;
    mainOppId;
    secondaryOppId;
    soBadgeControl = {};
    oppsSyncedQts_map = {};
    coSellLeaderValue = '';
    arrIsUnder10k = false;
    modalHeader = '';

    // used to choose co-sell leader when Co_Sell_Leader__c is blank on monday account
    get coSellLeaderOptions() {
        return [
            { label: 'Sales joining to Partners', value: 'Partners' },
            { label: 'Partners joining to Sales', value: 'Sales' },
        ];
    }

    // used to choose new or associate co-sell
    get whatYouWishOptions() {
        return [
            { label: 'Create a new Opportunity as Co-Sell', value: 'newopp' },
            { label: 'Link an existing Opportunity as Co-Sell', value: 'existingopp' },
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

    @wire(getRecord, { recordId: '$recordId', 
                        fields: [OPP_ACCOUNTID, OPP_STAGE, OPP_OWNER_MANAGER_NAME, OPP_OWNER_MANAGER_ID, OPP_OWNER_ID, 
                                OPP_RT_DEV_NAME, OPP_OWNER_ACCOUNTID, SYNCED_QUOTE, SYNCED_QUOTE_STATUS, SYNCED_QUOTE_PUBLISH, 
                                SYNCED_QUOTE_DATE,COSELL_LEADER, OPP_ARR, ACC_ARR, OPP_OWNERS_MANAGER_TEAM, OPP_OWNERS_OFFICE, OPP_OWNER_SEGMENT] })
    wiredRecord({ error, data }) {
        if (error) { this.modalHeader = 'Submit Co-Sell Request'; this.error = error; }
        if (data) {
            this.oppStage = getFieldValue(data, OPP_STAGE);
            this.accountId = getFieldValue(data, OPP_ACCOUNTID);
            this.managerName = getFieldValue(data, OPP_OWNER_MANAGER_NAME);
            this.managerId = getFieldValue(data, OPP_OWNER_MANAGER_ID);
            this.currentOppRT = getFieldValue(data, OPP_RT_DEV_NAME);
            this.partnerCompanyId = getFieldValue(data, OPP_OWNER_ACCOUNTID);
            this.oppOwnerId = getFieldValue(data, OPP_OWNER_ID);
            let cosellLeader = getFieldValue(data, COSELL_LEADER);
            let syncedQuoteId = getFieldValue(data, SYNCED_QUOTE);
            var oppArr = getFieldValue(data, OPP_ARR);
            var accArr = getFieldValue(data, ACC_ARR);
            var totalArr = oppArr + accArr;
            var isAnzTeam = false; //ANZ team is excluded from 10K TH validation
            var isSmb = false; //SMB is excluded from 10K TH validation (Sales)
            var ownersManagerTeam = getFieldValue(data, OPP_OWNERS_MANAGER_TEAM); //for partners
            var ownersOffice = getFieldValue(data, OPP_OWNERS_OFFICE); //for sales
            var ownerSegment = getFieldValue(data, OPP_OWNER_SEGMENT); //for sales
            if(ownersManagerTeam == 'CP - ANZ Team' || ownersOffice == 'Sydney Office') isAnzTeam = true;
            else if(this.currentOppRT == 'Internal_Opportunity' && ownerSegment == 'SMB') isSmb = true;
            if(isSmb || isAnzTeam || totalArr >= 10000 || this.userId == '0053X00000BoB3CQAV' || this.userId == '0053X00000CytmyQAB'){
                this.customError = '';
                this.arrIsUnder10k = false;
                if(syncedQuoteId){
                    let qt = {};
                    qt.Id = syncedQuoteId;
                    qt.Is_Published__c = getFieldValue(data, SYNCED_QUOTE_PUBLISH);
                    qt.DH_Quote_Status__c = getFieldValue(data, SYNCED_QUOTE_STATUS);
                    qt.CreatedDate = getFieldValue(data, SYNCED_QUOTE_DATE);;
                    if(qt.DH_Quote_Status__c == 'Won' || qt.DH_Quote_Status__c == 'Approved') qt.isWonOrApproved = true;
                    this.oppsSyncedQts_map[this.recordId] = qt;
                }
                if(cosellLeader == null || cosellLeader == undefined){
                    this.modalHeader = 'Choose the Co-Sell Leader for this Monday Account';
                    this.chooseLeaderScreen = true;
                } else {
                    this.modalHeader = 'Submit Co-Sell Request';
                    this.mainScreen = true;
                }
            } else {
                this.modalHeader = 'Submit Co-Sell Request';
                var err10K = 'Submit Co-Sell Request is available only for accounts that reached 10K ARR (including current opp ARR).';
                err10K += ' This account ARR is ' + accArr + ' and this opportunity ARR is ' + oppArr + ' so total ARR is ' + totalArr;
                err10K += '. If you have any question about this process please reach out to your manager or the Biz Ops team.';
                this.customError = err10K;
                this.arrIsUnder10k = true;
                this.callback_send10Kemail();
            }
        }
        this.isLoading = false;
    }

    callback_send10Kemail(){
        send10Kemail({
            opportunityId: this.recordId
        });
    }

    handleBackToCoSellLeader(event){
        this.mainScreen = false;
        this.modalHeader = 'Choose the Co-Sell Leader for this Monday Account';
        this.chooseLeaderScreen = true;
    }

    handleCoSellLeaderSelection(event){
        this.coSellLeaderValue = event.detail.value;
    }

    handleNextLeaderScreen(event){
        if(this.coSellLeaderValue == '') this.customError = 'Please choose an option for the co-sell leader.';
        else {
            this.customError = '';
            const fields = {};
            fields['Id'] = this.accountId;
            fields['Co_Sell_Leader__c'] = this.coSellLeaderValue;
            const recordInput = { fields };
            this.isLoading = true;
            updateRecord(recordInput)
            .then(() => {
                this.isLoading = false;
                this.chooseLeaderScreen = false;
                this.modalHeader = 'Submit Co-Sell Request';
                this.mainScreen = true;
            })
            .catch(error => {
                this.isLoading = false;
                this.error = error;
            });
        }
    }

    handleSave(event){
        if (!this.checkInputValidity()) return;
        this.cosellRequest.Monday_Account__c = this.accountId;
        this.cosellRequest.Assigned_Approver__c = this.managerId;
        this.cosellRequest.Partner_Company__c = this.partnerCompanyId;
        if(this.partnerCompanyId) {
            this.cosellRequest.Partner_User__c = this.oppOwnerId;
            this.cosellRequest.CPM__c = this.managerId;
        } else {
            this.cosellRequest.Sales_User__c = this.oppOwnerId;
        }
        if(this.whatYouWishValue == 'newopp'){
            this.cosellRequest.Type__c = 'Create';
            this.cosellRequest.Main_Opportunity__c = this.recordId;
            this.cosellRequest.Secondary_Opportunity_Owner__c = this.cosellRequest.Secondary_Opportunity_Owner__c[0];
            this.cosellRequest.Main_Opportunity_Stage__c = this.oppStage;
        } else if (this.whatYouWishValue == 'existingopp'){
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
        this.beforeCallback();
        createNewCoSellRequest({
            newCoSellReq: this.cosellRequest
        })
        .then(result => {
            if(result.newCoSellReqId != null){
                this.submittedTextManager = 'Your Co-sell Request was submitted for the approval of ' + result.managerName;
                this.mainScreen = false;
                this.submittedScreen = true;
            }
            this.isLoading = false;  
        })
        .catch(error => {
            this.error = error;
            this.isLoading = false;
        });
    }

    updateCosellRequest(e){
        let fieldVal = e.detail.value;
        let fieldName = e.target.dataset.id;
        this.cosellRequest[fieldName] = fieldVal;
        if(fieldName == 'Reason__c'){ 
            if(fieldVal == 'Professional Services Sales Expertise') this.displayPsFields = true;
            else this.displayPsFields = false;
            if(fieldVal == 'Partner Solution') this.displaySolutionLookup = true;
            else this.displaySolutionLookup = false;
        } else if(fieldName == 'PS_Type__c'){
            if(fieldVal == 'Onboarding') this.psTypeDetailsRequired = false;
            else this.psTypeDetailsRequired = true;
        }
    }

    handleMainRadioChange(e) {
        this.whatYouWishValue = e.detail.value;
        this.displayPsFields = false;
        this.displaySolutionLookup = false;
        this.customError = '';
        if(this.whatYouWishValue == 'newopp'){ // Create a co-sell opp opportunity
            this.associateScreen = false;
            this.newCoSellScreen = true;
        } else if(this.whatYouWishValue == 'existingopp'){ // Associate an existing opportinity as co-sell
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
    }

    setAssociateOppsMap(){
        let res = {};
        this.associateOppsOptions.forEach(opp => {
            res[opp.Id] = opp;
        });
        this.associateOppsMap = res;
    }

    updateSoBadgeControl(){
        this.soBadgeControl = {};
        let mainOppQt = this.oppsSyncedQts_map[this.mainOppId];
        let secOppQt = this.oppsSyncedQts_map[this.secondaryOppId];
        if(mainOppQt){
            if(mainOppQt.DH_Quote_Status__c == 'Won') this.soBadgeControl.main_signed = true;
            if(mainOppQt.Is_Published__c) this.soBadgeControl.main_published = true;
            if(mainOppQt.DH_Quote_Status__c == 'Approved') this.soBadgeControl.main_approved = true;
        }
        if(secOppQt){
            if(secOppQt.Is_Published__c) this.soBadgeControl.sec_published = true;
            if(secOppQt.DH_Quote_Status__c == 'Approved') this.soBadgeControl.sec_approved = true;
        }
    }

    handleAssociateOppSelected(event) {
        let selectedOppId = event.detail.value;
        let selectedQt = this.associateOppsMap[selectedOppId].SyncedQuote;
        let currQt = this.oppsSyncedQts_map[this.recordId];
        if(currQt == null || currQt == undefined || !currQt.isWonOrApproved){ //if current opp does not have quote at all or does not have a won or approved quote
            if(selectedQt){ // if selected opp has a synced quote
                if(selectedQt.DH_Quote_Status__c == 'Won' || selectedQt.DH_Quote_Status__c == 'Approved') { // if selected opp has a won or approved quote - switch forbidden. main should be the associated opp
                    this.allowSwitchMainSec = false;
                    this.mainOppId = selectedOppId;
                    this.secondaryOppId = this.recordId;
                } else if ((currQt && currQt.Is_Published__c) || (selectedQt.Is_Published__c)){ // if main or selected opp has a published quote 
                    this.allowSwitchMainSec = false; //when 1 or 2 opps have a published quote - switch is forbidden
                    if(currQt && currQt.Is_Published__c && selectedQt.Is_Published__c){ //if both have published quote - the main will be the one with the latest quote
                        if(currQt.CreatedDate >= selectedQt.CreatedDate){ // main is current opp
                            this.mainOppId = this.recordId;
                            this.secondaryOppId = selectedOppId;
                        } else { //main is selected opp
                            this.mainOppId = selectedOppId;
                            this.secondaryOppId = this.recordId;
                        }
                    } else if (currQt && currQt.Is_Published__c){ //if only current opp has a published quote then it will be the main
                        this.mainOppId = this.recordId;
                        this.secondaryOppId = selectedOppId;
                    } else if (selectedQt.Is_Published__c){ //if only selected opp has a published quote then it will be the main
                        this.mainOppId = selectedOppId;
                        this.secondaryOppId = this.recordId;
                    }
                } else { // switch allowed. main should be the record Id
                    this.allowSwitchMainSec = true;
                    this.mainOppId = this.recordId;
                    this.secondaryOppId = selectedOppId;
                }
            } else { //selected opp does not have a quote. main should be the record Id
                if(currQt && currQt.Is_Published__c){ //if main opp has a quote at all or a published quote then switch will be forbidden
                    this.allowSwitchMainSec = false;
                } else { // main opp has no published/won or approved quote and selected opp has no quote - switch allowed
                    this.allowSwitchMainSec = true;
                }
                this.mainOppId = this.recordId;
                this.secondaryOppId = selectedOppId;
            }
        } else { //current opp has a won or approved quote - switch is forbidden (in wire). main should be the record Id
            this.allowSwitchMainSec = false;
            this.mainOppId = this.recordId;
            this.secondaryOppId = selectedOppId;
        }
        this.associatedOppId = selectedOppId;
        this.oppsSyncedQts_map[selectedOppId] = selectedQt;
        this.updateSoBadgeControl();
    }

    handleSwitchMainSecondary(event) {
        let tempId = this.secondaryOppId;
        this.secondaryOppId = this.mainOppId;
        this.mainOppId = tempId;
        this.updateSoBadgeControl();
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
        let ignorePsDetails = false;
        this.template.querySelectorAll('lightning-input-field').forEach(element => {
            if (!element.value) {
                if(element.fieldName != 'PS_Type_Details__c' || this.psTypeDetailsRequired) cosellReqFieldValid = false;
            }
            element.reportValidity();
        });

        if(inputValid && cosellReqFieldValid) console.log('All input look valid. Ready to save!');
        else console.log('Found invalid input entries.');
        return inputValid && cosellReqFieldValid;
    }
}