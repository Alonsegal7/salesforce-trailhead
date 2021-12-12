import { LightningElement, wire } from 'lwc';
import getData from '@salesforce/apex/Ctrl_DashboardPageApp.initProfileUpdate';
import { NavigationMixin } from 'lightning/navigation';

export default class ProfileUpdate extends NavigationMixin(LightningElement) {
    dataLoaded = true;
    lastUpdate = 'N/A';
    nextUpdate = 'N/A';
    btnClass = 'slds-button slds-button_brand blue-btn';
    hasError = false;
    accountId;

    connectedCallback(){
        this.init();

        console.log('pageRef: ' + pageRef);
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
                if (this.hasError){
                    this.btnClass += ' alert';
                }
            }
        })
        .catch((err) => { console.log('Profile Update error: ' + err); });
    }


    openModal(){
        let temp = {
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Partner_Metrics__c',
                actionName: 'new'                
            },
            state : {
                nooverride: '1',
                defaultFieldValues:"Partner__c=" + this.accountId,
                retUrl: pageRef
            }
        };
        this[NavigationMixin.Navigate](temp);
    }

    /**
    * @param {Object} obj Any object to test
    * @return {Boolean} true if empty
    */
     isEmpty(obj){
        return (obj == null || obj == 'null' || typeof(obj) == 'undefined' || obj == 'undefined' || obj == '');
    }
}