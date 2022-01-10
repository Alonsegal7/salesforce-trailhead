import { LightningElement } from 'lwc';
import Dashboard_SalesTrainerID from '@salesforce/label/c.Dashboard_SalesTrainerID';
import loadTeam from '@salesforce/apex/Ctrl_DashboardPageApp.getUserChannelTeam';

export default class MyChannelTeam extends LightningElement {
    teamLoaded = false;
    theTeam;

    connectedCallback(){
        this.init();
    }

    init(){
        loadTeam()
        .then((data) => {
            console.log('Channel team data received');
            this.processTeam(data);
        })
        .catch((err) => { console.log('Error loading channel: ' + err); });
    }

    processTeam(userList){
        if (!this.isEmpty(userList) && Array.isArray(userList)){
            this.theTeam = new Array();
            let controlList = new Array();
            let cpmManager = null;
            let regionalDirector = null;
            let salesTrainer = null;
            let pcsm = null;
            userList.forEach((user) => {
                //console.log('Current user: ' + JSON.stringify(user));
                if (Dashboard_SalesTrainerID.substring(0, 15) == user.Id.substring(0, 15) && !controlList.includes(user.Id.substring(0, 15))){
                    //console.log('Handling the trainer');
                    salesTrainer = JSON.parse(JSON.stringify(user));
                    salesTrainer.Title = 'Sales Trainer';
                    controlList.push(salesTrainer.Id.substring(0, 15));
                } else if (Dashboard_SalesTrainerID.substring(0, 15) != user.Id.substring(0, 15)) {
                    if (!this.isEmpty(user.ManagerId) && !controlList.includes(user.ManagerId.substring(0, 15))){
                        cpmManager = JSON.parse(JSON.stringify(user.Manager));
                        cpmManager.Title = 'Channel Partner Manager';
                        controlList.push(cpmManager.Id.substring(0, 15));
                    }
                    if (!this.isEmpty(user.ManagerId) && !this.isEmpty(user.Manager.ManagerId) && !controlList.includes(user.Manager.ManagerId.substring(0, 15))){
                        regionalDirector = JSON.parse(JSON.stringify(user.Manager.Manager));
                        regionalDirector.Title = 'Channel Partner Regional Director';
                        controlList.push(regionalDirector.Id.substring(0, 15));
                    }
                    if (!this.isEmpty(user.Account.PSM__c) && !this.isEmpty(user.Account.PSM__c) && !controlList.includes(user.Account.PSM__c.substring(0, 15))){
                        pcsm = JSON.parse(JSON.stringify(user.Account.PSM__r));
                        pcsm.Title = 'Partner Success Manager';
                        controlList.push(pcsm.Id.substring(0, 15));
                    }
                }
            });
            if (!this.isEmpty(cpmManager)) this.theTeam.push(cpmManager);
            if (!this.isEmpty(regionalDirector)) this.theTeam.push(regionalDirector);
            if (!this.isEmpty(salesTrainer)) this.theTeam.push(salesTrainer);
            if (!this.isEmpty(pcsm)) this.theTeam.push(pcsm);

            //console.log('Final list: ' + JSON.stringify(this.theTeam));
            this.teamLoaded = true;
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