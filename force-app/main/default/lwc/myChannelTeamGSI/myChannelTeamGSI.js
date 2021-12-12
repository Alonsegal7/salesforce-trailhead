import { LightningElement } from 'lwc';
import Dashboard_SalesTrainerID from '@salesforce/label/c.Dashboard_SalesTrainerID';
import loadTeam from '@salesforce/apex/Ctrl_DashboardPageApp.getUserChannelTeam';

export default class MyChannelTeamGSI extends LightningElement {
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
        .catch((err) => { console.log('Error loading channel: ' + JSON.stringify(err)); });
    }

    processTeam(userList){
        if (!this.isEmpty(userList) && Array.isArray(userList)){
            this.theTeam = new Array();
            let controlList = new Array();
            userList.forEach((user) => {
                //console.log('Current user: ' + JSON.stringify(user));
                if (Dashboard_SalesTrainerID.substring(0, 15) != user.Id.substring(0, 15)) {
                    if (!this.isEmpty(user.ManagerId) && !controlList.includes(user.ManagerId.substring(0, 15))){
                        let currentUser = JSON.parse(JSON.stringify(user.Manager));
                        this.theTeam.push(currentUser);
                        controlList.push(currentUser.Id.substring(0, 15));
                    }
                    if (!this.isEmpty(user.ManagerId) && !this.isEmpty(user.Manager.ManagerId) && !controlList.includes(user.Manager.ManagerId.substring(0, 15))){
                        let currentUser = JSON.parse(JSON.stringify(user.Manager.Manager));
                        this.theTeam.push(currentUser);
                        controlList.push(currentUser.Id.substring(0, 15));
                    }
                }
            });

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