import { LightningElement } from 'lwc';
import pipelineURL from '@salesforce/label/c.Dashboard_Pipeline';
import portfolioURL from '@salesforce/label/c.Dashboard_Portfolio';

export default class DashboardBtnNavigation extends LightningElement {
    label = {
        pipelineURL,
        portfolioURL
    };
    
}