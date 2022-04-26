import { LightningElement, api, track, wire } from 'lwc';
import search from '@salesforce/apex/SearchController.search';
import getRecentlyCreatedRecord from '@salesforce/apex/SearchController.getRecentlyCreatedRecord';
const DELAY = 10;

import { NavigationMixin } from 'lightning/navigation';

export default class SearchComponent extends NavigationMixin(LightningElement) {

    /* values for an existing selected record */
    @api valueId;
    @api valueName;

    @api objName        = 'Account';
    @api iconName       = 'standard:account';
    @api labelName;
    @api currentRecordId;
    @api placeholder    = 'Search';
    @api fields         = ['Name'];
    @api displayFields  = 'Name';
    @api showLabel      = false;
    @api parentAPIName  = 'ParentId';
    @api createRecord   = false;
    @api recentlyViewed = false;
    @api whereCondition = '';

    /* values to be passed to create the new record */
    @api recordTypeId;
    @api fieldsToCreate = [];

    /* Create fields for using in Datatable for Multiple In-line Edit */
    @api index;

    @track error;

    searchTerm;
    delayTimeout;

    searchRecords;
    selectedRecord;
    objectLabel;
    isLoading = false;
    showButton = false;
    showModal = false;

    field;
    field1;
    field2;

    ICON_URL       = '/apexpages/slds/latest/assets/icons/{0}-sprite/svg/symbols.svg#{1}';
    ICON_URL_NEW   = '/apexpages/slds/latest/assets/icons/utility-sprite/svg/symbols.svg#add';
    ICON_URL_CLOSE = '/apexpages/slds/latest/assets/icons/utility-sprite/svg/symbols.svg#close';

    connectedCallback(){
        try{
            //console.log('SearchComponent entered connectedCallback');
            //console.log('SearchComponent objName: ' + this.objName);
            let icons           = this.iconName.split(':');
            this.ICON_URL       = this.ICON_URL.replace('{0}',icons[0]);
            this.ICON_URL       = this.ICON_URL.replace('{1}',icons[1]);

            if(this.objName.includes('__c')){
                let obj = this.objName.substring(0, this.objName.length-3);
                this.objectLabel = obj.replaceAll('_',' ');
            }else{
                this.objectLabel = this.objName;
            }
            //console.log('SearchComponent objectLabel: ' + this.objectLabel);

            if( this.valueId && this.valueName ){
                this.selectedRecord = {
                    FIELD1 : this.valueName,
                    Id     : this.valueId
                }
            }

            this.objectLabel    = this.titleCase(this.objectLabel);
            //console.log('SearchComponent objectLabel: ' + this.objectLabel);

            let fieldList;
            if( !Array.isArray(this.displayFields)){
                fieldList       = this.displayFields.split(',');
            }else{
                fieldList       = this.displayFields;
            }
            if(fieldList.length > 1){
                this.field  = fieldList[0].trim();
                this.field1 = fieldList[1].trim();
            }
            if(fieldList.length > 2){
                this.field2 = fieldList[2].trim();
            }
            let combinedFields = [];
            fieldList.forEach(field => {
                if( !this.fields.includes(field.trim()) ){
                    combinedFields.push( field.trim() );
                }
            });

            this.fields = combinedFields.concat( JSON.parse(JSON.stringify(this.fields)) );

            if(this.valueId && this.valueName){
                this.selectedRecord = {
                    FIELD1   : this.valueName,
                    recordId : this.valueId
                }
            }
            //console.log('SearchComponent connectedCallback field: ' + this.field + '; field1: ' + this.field1 + '; field2: ' + this.field2);
        } catch(e){
			console.error(e);
			console.error('e.name => ' + e.name );
			console.error('e.message => ' + e.message );
			console.error('e.stack => ' + e.stack );
		}
    }

    handleInputChange(event){
        try{
            //console.log('SearchComponent entered handleInputChange');

            window.clearTimeout(this.delayTimeout);
            const searchKey = event.target.value;
            //console.log('handleInputChange searchKey: ' + searchKey);
            if((searchKey != '' && searchKey != null && searchKey != undefined) || this.recentlyViewed){ //if searchKey is entered or we turned on the recently viewed records -> we run search
                this.delayTimeout = setTimeout(() => {
                    search({
                        objectName      : this.objName,
                        fields          : this.fields,
                        searchTerm      : searchKey,
                        whereCondition  : this.whereCondition
                    })
                    .then(result => {
                        let stringResult = JSON.stringify(result);
                        //console.log('SearchComponent handleInputChange search result: '+ stringResult);
                        let allResult    = JSON.parse(stringResult);
                        allResult.forEach( record => {
                            record.FIELD1       = record[this.field];
                            record.FIELD2       = record[this.field1];
                            if( this.field2 ){
                                record.FIELD3   = record[this.field2];
                            }else{
                                record.FIELD3 = '';
                            }
                        });
                        this.searchRecords = allResult;
                        //console.log('SearchComponent handleInputChange search this.searchRecords: '+ JSON.stringify(this.searchRecords));
    
                    })
                    .catch(error => {
                        console.error('Error:', error);
                    })
                    .finally( ()=>{
                        this.showButton = this.createRecord;
                    });
                }, DELAY);
            } else {
                this.searchRecords = undefined;
            }
        }catch(e){
            console.error(e);
            console.error('e.name => ' + e.name );
            console.error('e.message => ' + e.message );
            console.error('e.stack => ' + e.stack );
        }
    }

    handleSelect(event){
        try{
            //console.log('SearchComponent entered handleSelect');

            let recordId = event.currentTarget.dataset.recordId;
            let selectRecord = this.searchRecords.find((item) => {
                return item.Id === recordId;
            });
            this.selectedRecord = selectRecord;
            const selectedEvent = new CustomEvent('lookup', {
                bubbles    : true,
                composed   : true,
                cancelable : true,
                detail: {
                    data : {
                        record          : selectRecord,
                        recordId        : recordId,
                        currentRecordId : this.currentRecordId,
                        parentAPIName   : this.parentAPIName,
                        index           : this.index
                    }
                }
            });
            this.dispatchEvent(selectedEvent);
        }catch(e){
            console.error(e);
            console.error('e.name => ' + e.name );
            console.error('e.message => ' + e.message );
            console.error('e.stack => ' + e.stack );
        }
    }

    @api
    handleClose(){
        try{
            //console.log('SearchComponent entered handleClose');

            this.selectedRecord = undefined;
            this.searchRecords  = undefined;
            this.showButton     = false;
            const selectedEvent = new CustomEvent('lookup', {
                bubbles    : true,
                composed   : true,
                cancelable : true,
                detail: {
                    data : {
                        record          : undefined,
                        recordId        : undefined,
                        currentRecordId : this.currentRecordId,
                        parentAPIName   : this.parentAPIName,
                        index           : this.index
                    }
                }
            });
            this.dispatchEvent(selectedEvent);
        }catch(e){
            console.error(e);
            console.error('e.name => ' + e.name );
            console.error('e.message => ' + e.message );
            console.error('e.stack => ' + e.stack );
        }
    }

    titleCase(string) {
        //console.log('SearchComponent entered titleCase');
        var res = '';
        var words = string.toLowerCase().split(" ");
        for(var i = 0; i< words.length; i++){
            res += words[i][0].toUpperCase() + words[i].slice(1) + ' ';
        }
        return res;
    }

    handleNewRecord = event => {
        event.preventDefault();
        this.showModal = true;
    }

    handleCancel = event => {
        event.preventDefault();
        this.showModal = false;
    }

    handleSuccess = event => {
        event.preventDefault();
        this.showModal = false;
        let recordId   = event.detail.id;
        this.hanleCreatedRecord(recordId);
    }

    hanleCreatedRecord = (recordId) => {
        getRecentlyCreatedRecord({
            recordId   : recordId,
            fields     : this.fields,
            objectName : this.objName
        })
        .then(result => {
            if(result){
                this.selectedRecord = {
                    FIELD1   : result[this.field],
                    Id       : recordId
                };
                const selectedEvent = new CustomEvent('lookup', {
                    bubbles    : true,
                    composed   : true,
                    cancelable : true,
                    detail: {
                        data : {
                            record          : this.selectedRecord,
                            recordId        : recordId,
                            currentRecordId : this.currentRecordId,
                            parentAPIName   : this.parentAPIName,
                            index           : this.index
                        }
                    }
                });
                this.dispatchEvent(selectedEvent);
            }
        })
        .catch(error => {
            console.error('Error: \n ', error);
        })
        .finally( ()=>{
            this.showModal = false;
        });
    }
}