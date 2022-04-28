import { LightningElement, wire, api, track } from "lwc";

import getfields from "@salesforce/apex/Field_PesmissionHelper.getfields";
import getSObjects from "@salesforce/apex/Field_PesmissionHelper.getSObjects";
import enableFieldVisibility from "@salesforce/apex/Field_PesmissionHelper.enableFieldVisibility";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class FieldLevelSecurityComponent extends LightningElement {
    @track fields = [];
    @track selected = [];
    @track objName = "";
    @track showSpinner = false;
    @api value = "";
    @api fieldsValue = [];
    showFields = false;
    
    get selectFields() {
        return this.fields;
    }
    
    get selected() {
        return this.selected.length ? this.selected : "none";
    }

    handleObjChange() {
        this.showSpinner = true;
        this.objName = this.template.querySelector('lightning-input').value;
        getfields({objectname: this.objName}).then((response)=>{
            console.log('### found fields: '+JSON.parse((JSON.stringify(response))));
            let Testdata = JSON.parse(JSON.stringify(response));
            let lstOption = [];
            for (var i = 0;i < Testdata.length;i++) {
                lstOption.push({value: Testdata[i].QualifiedApiName,label: Testdata[i].DeveloperName});
            }
            this.fields = lstOption;
            this.showFields = true;
        }).catch(error => {
            console.log('### error: '+error.body.message);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
        }).finally(()=>{
            this.showSpinner = false;
        });
    }

    updateRecordView() {
        setTimeout(() => {
             eval("$A.get('e.force:refreshView').fire();");
        }, 1000); 
     }
    
    handleSelectFields(event) {
        this.selected = event.detail.value;
        this.fieldsValue = event.detail.value;
        if(this.fieldsValue.length > 0 ){
            this.disableGetRecords = false;
        }else{
            this.disableGetRecords = true;
        }
    }

    handleClick() {
        this.showSpinner = true;
        console.log('### handle click with fields: '+this.selected);
        enableFieldVisibility( {objectName: 'Account', fieldNames: this.selected}).then((response)=>{
            console.log('### succcess');
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Success",
                    message: "Field level security updated successfully",
                    variant: "success"
                }),
            );
            this.updateRecordView();
        }).catch(error => {
            console.log('### error: '+error.body.message);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
        }).finally(()=>{
            this.showSpinner = false;
        });
    }
  }