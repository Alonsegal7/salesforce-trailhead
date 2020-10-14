import { LightningElement,track,wire,api } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

export default class LeadKeyItems extends NavigationMixin(LightningElement) {}