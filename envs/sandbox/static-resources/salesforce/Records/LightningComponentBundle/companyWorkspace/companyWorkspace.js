import { LightningElement ,api,wire,track} from 'lwc';
import getAccount from '@salesforce/apex/companyWorkspaceController.getAccount';

export default class CompanyWorkspace extends LightningElement {
    @api recordId;
    @track accounts;
    @track error;
    @track showFooter = true ;
    value = ['h1'];
    valueOnboarding = ['ko'];
    valueSwag = ['h1'];
    @track onboarding;
    @wire(getAccount,{accId:'$recordId'})
     wiredAccountss({error,data}) {
         if (data) {
             this.accounts = data;
             console.log('Raz Ben Ron Accounts:'+data);
             console.log(JSON.stringify(data, null, '\t'));
         } else if (error) {
             console.log(error);
             this.error = error;
         }
     }
     get resurrectOptions() {
        return [
            { label: 'H1', value: 'h1' },
            { label: 'H2', value: 'h2' }];
    }
    get OnboardingOptions() {
        return [
            { label: 'Attend Kickoff', value: 'ko' },
            { label: 'Identified KPIs', value: 'kpis' },
            { label: 'Created Check-in Cadence', value: 'checkin' },
            { label: 'Confirmation on Go-Live Success', value: 'golive' }];
    }
    
}