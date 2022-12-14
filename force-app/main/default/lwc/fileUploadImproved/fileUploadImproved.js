import { LightningElement, track, api, wire } from 'lwc';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import { NavigationMixin } from 'lightning/navigation';
import { deleteRecord } from 'lightning/uiRecordApi';
import getKey from '@salesforce/apex/FileUploadImprovedHelper.getKey';
import encrypt from '@salesforce/apex/FileUploadImprovedHelper.encrypt';
import createContentDocLink from '@salesforce/apex/FileUploadImprovedHelper.createContentDocLink';
import deleteContentDoc from '@salesforce/apex/FileUploadImprovedHelper.deleteContentDoc';

export default class FileUpload extends NavigationMixin(LightningElement) {
    @api acceptedFormats;
    @api allowMultiple;
    @api community; //deprecated
    @api contentDocumentIds;
    @api contentVersionIds;
    @api icon;
    @api label;
    @api recordId;
    @api required;
    @api minRequired = 1;
    @api maxAllowed;
    @api requiredMessage;
    @api sessionKey;
    @api uploadedFileNames;
    @api uploadedlabel;
    @api uploadedLabel; // deprecated
    @api preventSessionStorage = false;
    @api filenameSuffix; //Optional - this adds a suffix to the uploaded filenames
    
    @track docIds =[]; // docIds = ['id1', 'id2'] ; docIds.length = 2
    @track fileNames = [];
    @track objFiles = [];
    @track versIds = [];

    recordIdToUse;
    @api
    get communityDetails(){
        if(this.community != true){
            this.recordIdToUse = this.recordId;
        }
        return this.recordIdToUse;
    }

    key;
    @wire(getKey) key;

    value;
    @wire(encrypt,{recordId: '$recordId', encodedKey: '$key.data'}) value;

    connectedCallback(){
        //if(!this.preventSessionStorage){
            let cachedSelection = sessionStorage.getItem(this.sessionKey);
            if(cachedSelection){
                this.objFiles = JSON.parse(cachedSelection);
    
                this.objFiles.forEach((file) => {
                    this.docIds.push(file.id);
                    this.versIds.push(file.versid);
                    this.fileNames.push(file.name);
                });
                
                this.communicateEvent(this.docIds,this.versIds,this.fileNames,this.objFiles);
            }
        //}
    }
    
    handleUploadFinished(event) {
        const files = event.detail.files;

        var objFile;
        files.forEach(file => {
            var filetype;
            if(this.icon == null){
                filetype = getIconSpecs(file.name.split('.').pop());
            }
            else{
                filetype = this.icon;
            }
            objFile = {
                name: file.name,
                filetype: filetype,
                id: file.documentId,
                versid: file.contentVersionId
            };
            this.objFiles.push(objFile);
            this.docIds.push(file.documentId);
            this.versIds.push(file.contentVersionId);
            this.fileNames.push(file.name);
        });
        let returnObj = {versIds: this.versIds};
        const sendVersIdsEvent = new CustomEvent("sendversids", {detail: returnObj});
        this.dispatchEvent(sendVersIdsEvent);

        this.communicateEvent(this.docIds,this.versIds,this.fileNames,this.objFiles);
        if(this.value.data != ''){
            console.log('LWC file upload improved docIds: '+ this.docIds);
            createContentDocLink({versIds: this.versIds, encodedKey: this.key.data, nameSuffix: this.filenameSuffix, docIds: this.docIds});
        }
        
        function getIconSpecs(docType){
            switch(docType){
                case 'csv':
                    return 'doctype:csv';
                case 'pdf':
                    return 'doctype:pdf';
                case 'pps':
                case 'ppt':
                case 'pptx':
                    return 'doctype:ppt';
                case 'xls':
                case 'xlsx':
                    return 'doctype:excel';
                case 'doc':
                case 'docx':
                    return 'doctype:word';
                case 'txt':
                    return 'doctype:txt';
                case 'png':
                case 'jpeg':
                case 'jpg':
                case 'gif':
                    return 'doctype:image';
                default:
                    return 'doctype:unknown';
            }
        }
    }
    
    deleteDocument(event){
        const docId = event.target.dataset.docid;
        const versId = event.target.dataset.versid;
        
        if(docId){
            deleteRecord(docId);
        } else {
            deleteContentDoc({versId: versId});
        }

        let objFiles = this.objFiles;
        let removeIndex;
        for(let i=0; i<objFiles.length; i++){
            if(versId === objFiles[i].versid){
                removeIndex = i;
            }
        }

        this.objFiles.splice(removeIndex,1);
        this.docIds.splice(removeIndex,1);
        this.versIds.splice(removeIndex,1);
        this.fileNames.splice(removeIndex,1);

        this.communicateEvent(this.docIds,this.versIds,this.fileNames,this.objFiles);
    }    

    communicateEvent(docIds, versIds, fileNames, objFiles){
        this.dispatchEvent(new FlowAttributeChangeEvent('contentDocumentIds', docIds));
        this.dispatchEvent(new FlowAttributeChangeEvent('contentVersionIds', versIds));
        this.dispatchEvent(new FlowAttributeChangeEvent('uploadedFileNames', fileNames));

        sessionStorage.setItem(this.sessionKey, JSON.stringify(objFiles));
    }

    openFile(event) {
        const docId = event.target.dataset.docid;
        event.preventDefault();
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state: {
                recordIds: docId
            }
        });
    }

    @api
    validate(){ //validation on save files
        console.log('LWC file upload improved validate required: '+ this.required);
        console.log('LWC file upload improved validate minRequired: '+ this.minRequired);
        console.log('LWC file upload improved validate maxAllowed: '+ this.maxAllowed);
        console.log('LWC file upload improved validate num of files uploaded: '+ this.docIds.length);
        if(this.required == true || this.required == 'true'){ // files are mandatory
            var errorMessage;
            if(this.docIds.length < this.minRequired){ // not enough files uploaded 
                if(this.requiredMessage == null){
                    errorMessage = 'Upload at least ' + this.minRequired + ' file.'; //TBD - set message to be dynamic by the minRequired
                } else {
                    errorMessage = this.requiredMessage;
                }
                return { 
                    isValid: false,
                    errorMessage: errorMessage
                };
            } else if(this.maxAllowed != null && this.docIds.length > this.maxAllowed){ // files exceed max allowed 
                if(this.requiredMessage == null){
                    errorMessage = 'You uploaded too many files. Max files allowed is ' + this.maxAllowed; //TBD - set message to be dynamic by the minRequired
                } else {
                    errorMessage = this.requiredMessage;
                }
                return { 
                    isValid: false,
                    errorMessage: errorMessage
                };
            } else { // passed validation
                return { isValid: true };
            }
        } else { // files not mandatory - no validation
            return { isValid: true };
        }
    }

    @api
    clearSessionStorage(){
        sessionStorage.clear();
    }

    @api
    getLabel(){
        return this.uploadedlabel;
    }
}