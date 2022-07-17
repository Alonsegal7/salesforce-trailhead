import { LightningElement, api } from 'lwc';
import { loadStyle} from 'lightning/platformResourceLoader';
import { CloseActionScreenEvent } from 'lightning/actions';
import ModalWidthCSS from '@salesforce/resourceUrl/ModalWidthCSS';

export default class HandoverFromQuickAction extends LightningElement {
    @api recordId;
    connectedCallback() {
        Promise.all([loadStyle(this, ModalWidthCSS)]);    
    }
    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}