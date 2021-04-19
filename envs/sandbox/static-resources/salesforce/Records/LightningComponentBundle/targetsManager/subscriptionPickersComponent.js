import { LightningElement,track,wire,api } from 'lwc';
import getSubscriptions from '@salesforce/apex/SubscriptionPickerController.getSubscriptions';
import getClaimed from '@salesforce/apex/SubscriptionPickerController.getClaimed';
import claimSubs from '@salesforce/apex/SubscriptionPickerController.claimSubs';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

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

    @wire(getSubscriptions,{oppId:'$recordId'})
        wiredSubs({data, error}){
            console.log('Raz this.recordId: '+this.recordId);
            if(data){
                console.log('data: '+JSON.stringify(data));              
                this.error = undefined;
                const temp=[];
                for(let key in data) {
                    if (data.hasOwnProperty(key)) { 
                        /*console.log('key: '+key);
                        console.log('data[key].Name: '+data[key].Name);*/
                        var singleObj2 = {};
                        singleObj2['value'] = key;
                        singleObj2['label'] = data[key].Name;
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
                    singleObj['label'] = data[i].Name;
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

    get selectedValues() {
        return this.selected.join(',');
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
        console.log('this.selected: '+this.selected);
        for(let i in this.selected) {
            var singleObj = {};
            singleObj['label'] = this.subsMap[this.selected[i]].Name;
            temp2.push(singleObj);
            tempCodes.push(this.subsMap[this.selected[i]].Product_Code__c);
        }
        this.newClaims=temp2;
        this.newSubsCodes=tempCodes;
        this.subsFinal=[];
        console.log('this.selected: '+JSON.stringify(this.selected));
        console.log('this.newSubsCodes: '+JSON.stringify(this.newSubsCodes));
        this.subsFinal.push.apply(this.subsFinal,this.subsClaimed);
        this.subsFinal.push.apply(this.subsFinal,this.newClaims);
    }

    handleSave(e){
        console.log('this.selected: '+JSON.stringify(this.selected));
        claimSubs( {oppId: this.recordId, subsIdsToClaim: this.selected, productCodes: this.newSubsCodes}).then((resultSubs)=>{
        console.log('resultSubs: '+resultSubs);
        this.saveDisabled=true;
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Plans Claimed Successfully!',
                variant: 'success',
            }),
        );
        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error Claiming Payments',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
        });
    }
 

}