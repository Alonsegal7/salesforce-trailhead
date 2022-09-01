import { LightningElement, api } from "lwc";
import getfields from "@salesforce/apex/Field_PesmissionHelper.getfields";
import getSObjects from "@salesforce/apex/Field_PesmissionHelper.getSObjects";
import enableFieldVisibility from "@salesforce/apex/Field_PesmissionHelper.enableFieldVisibility";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class FieldLevelSecurityComponent extends LightningElement {
    fields = [];
    selected = [];
    objName = "";
    showSpinner = false;
    @api value = "";
    @api fieldsValue = [];
    showFields = false;
    
    get selectFields() {
        return this.fields;
    }
    
    get selected() {
        return this.selected.length ? this.selected : "none";
    }

    async handleObjChange() {
        this.showSpinner = true;
        this.objName = this.template.querySelector('lightning-input').value;
        try {
            let response = await getfields({objectname: this.objName});
            let rawFields = JSON.parse(JSON.stringify(response));
            let lstOption = [];
            for (var i = 0;i < rawFields.length;i++) {
                lstOption.push({value: rawFields[i].QualifiedApiName,label: rawFields[i].DeveloperName});
            }
            this.fields = lstOption;
            this.showFields = true;
        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
        } finally {
            this.showSpinner = false;
        }
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

    async handleClick() {
        this.showSpinner = true;
        try {
            let response = await enableFieldVisibility( {objectName: this.objName, fieldNames: this.selected});
            if (response == true) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Success",
                        message: "Field level security updated successfully",
                        variant: "success"
                    }),
                );
            } else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error",
                        message: "There was some kind of error :(",
                        variant: "error"
                    }),
                );
            }
            this.updateRecordView();
        } catch (error) {
            console.log('### error: '+error.body.message);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
        } finally {
            this.showSpinner = false;
        }
    }
  }