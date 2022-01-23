import { LightningElement, wire } from 'lwc';
import getData from '@salesforce/apex/Ctrl_DashboardPageApp.initProfileUpdate';
import { NavigationMixin } from 'lightning/navigation';

export default class ProfileUpdate extends NavigationMixin(LightningElement) {
    dataLoaded = true;
    lastUpdate = 'N/A';
    nextUpdate = 'N/A';
    btnClass = 'slds-button slds-button_brand blue-btn';
    hasError = false;
    partnerMatrics;
    partnerMatricsURL;
    accountId;

    connectedCallback(){
        this.init();
    }

    init(){
        getData()
        .then((data) => {
            console.log('Profile Update: ' + JSON.stringify(data));
            if (!this.isEmpty(data)){
                this.lastUpdate = data.last_update;
                this.nextUpdate = data.next_update;
                this.hasError = data.alert;
                this.accountId = data.accountId;
                if (!this.isEmpty(data.partner_matrics)){
                    this.partnerMatrics = data.partner_matrics;
                    this.partnerMatricsURL = '/partners/s/detail/' + data.partner_matrics.Id;
                }
                if (this.hasError){
                    this.btnClass += ' alert';
                }
            }
        })
        .catch((err) => { console.log('Profile Update error: ' + err); });
    }


    openModal(e){
        console.log('Update clicked');
        try{
            let temp = {
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'Partner_Metrics__c',
                    actionName: 'new'                
                },
                state : {
                    nooverride: '1',
                    defaultFieldValues:"Partner__c=" + this.accountId
                }
            };
            console.log('New object params: ' + JSON.stringify(temp));
        
            this[NavigationMixin.Navigate](temp);
        } catch(e){
            console.log('Error openning new Partner Matrix modal: ' + e);
        }
    }

    /**
    * @param {Object} obj Any object to test
    * @return {Boolean} true if empty
    */
     isEmpty(obj){
        return (obj == null || obj == 'null' || typeof(obj) == 'undefined' || obj == 'undefined' || obj == '');
    }
}