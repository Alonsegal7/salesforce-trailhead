import { LightningElement,track,wire,api } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import getMilestones from '@salesforce/apex/projectWidget.projectWidget';
import latestProject from '@salesforce/apex/projectWidget.getLatestProject';
import currentStep from '@salesforce/apex/projectWidget.getCurrentStep';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ProjectWidget extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName;
    @track steps=[];
    @track milestones;
    @track projectId;
    @track milestoneId;
    @track error;
    @track showProject=true;
    @track projectName;
    @track package;
    @track currentStep;
    
    @wire(latestProject,{accountId:'$recordId'})
        wiredProject({data, error}){
            if(data){
                console.log('Raz Ben Ron data:',data);
                this.projectId = data.Id;  
                this.projectName = data.Name; 
                this.package = data.Package__c;                
                this.error = undefined;
                console.log('Raz Ben Ron projectId:',this.projectId);
                console.log('Raz Ben Ron projectName:',this.projectName);
            }
            else if (error) {
                console.log('Raz Ben Ron error1:',this.error);
                this.error = error;
                this.project = undefined;
            }
        }
    @wire(getMilestones,{accountId:'$recordId'})
        wiredMSs({data, error}){
            if(data){
                this.milestones = data;                
                this.error = undefined;
                const temp=[];
                data.forEach(function (record, i){
                    var singleObj = {};
                    singleObj['label'] = record.Name;
                    singleObj['value'] = record.Id;
                    temp.push(singleObj);
                    
                });
                this.steps=temp;
            }
            else if (error) {
                this.error = error;
                this.milestones = undefined;
            }
        }
    @wire(currentStep,{accountId:'$recordId'})
        wiredCurrentStep({data, error}){
            if(data){
                console.log('Raz Ben Ron data:',data);
                this.currentStep = data.Id;                 
                this.error = undefined;
            }
            else if (error) {
                this.error = error;
                this.project = undefined;
            }
        }
    handleMSClick(event){
        this.milestoneId=event.target.value;
        this.showProject=false;
    }
    handleProjectClick(event){
        console.log('Raz Ben Ron on project click:');
        this.showProject=true;
    }
    get hasProject() {
        return this.projectId? true : false;
    }
    goToProject(event) {
        console.log('Raz Ben Ron on icon click:');
        console.log('Raz Ben Ron event.target.value:'+event.target.value);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.target.value,
                objectApiName: 'Project__c',
                actionName: 'view',
            },
        });
    }
    cretaeProjectLink(event) {
        console.log('Raz Ben Ron event.target.value:'+event.target.value);
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Project__c',
                actionName: 'new',
            },
            state : {
                nooverride: '1',
                defaultFieldValues:"Name=Project Name ,monday_Account__c="+this.recordId
            }
        });
    }
}