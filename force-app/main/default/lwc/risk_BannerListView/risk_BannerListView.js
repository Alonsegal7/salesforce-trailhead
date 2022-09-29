import { LightningElement, track, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import findRisks from '@salesforce/apex/RiskBannerController.getRisks';
import riskExistOnAccount from '@salesforce/label/c.riskExistOnAccount';

export default class Risk_BannerListView extends NavigationMixin(LightningElement) {
    label = {
        riskExistOnAccount
    };

    @api recordId;
    @track risks;
    error;

    /*  Get the related Risks records if exist on the Monday Account
        This component will be shown inly is the Account is marked as 'At Risk' = true --> if there is an Open Risk related
    */
    @wire(findRisks, { recordId: '$recordId' })
    risksList({ error, data }) {
        if (data) {
			console.log(' No of risks --> ' + data.length);
            this.risks = data;
            this.error = undefined;
        }
        
        else if (error) {
            this.error = error;
            this.risks = undefined;
        }
    }

    /*
        When clicking the button --> navigate the Risk Related List view
    */
    navigateToRelatedList() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Account',
                relationshipApiName: 'Risks__r',
                actionName: 'view'
            }
        });
    }
}