import { LightningElement,track,wire,api } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';
import getSalesOrderInfo from '@salesforce/apex/ManageLegalDocumentController.getSalesOrderDetails';
import checkIfLegalDocExist from '@salesforce/apex/ManageLegalDocumentController.legalDocExistForCompany';

const companyLegalDocuments = [
    { label: 'Document type', fieldName: 'Document_type__c', type: 'text' },
    { label: 'Status', fieldName: 'Status__c', type: 'text' },
    { label: 'Last ppdate date', fieldName: 'Last_status_update_date__c', type: 'datetime' },
    { label: 'CLM Document Link', fieldName: 'CLM_Document_Link__c', type: 'url',
    typeAttributes: {label: { fieldName: 'CLM Link' },value:{fieldName: 'CLM_Document_Link__c'}, target: '_blank'}} 
];

export default class ManageLegalDocument extends NavigationMixin(LightningElement) {

    @api recordId;
    @api objectApiName;
    missingRelevantInfo=false;
    showSaaSbutton=false;
    showDPAbutton=false;
    salesOrderSelectedAgreementType;
    columns = companyLegalDocuments;
    showCompanyLegalDocTable=false;
    legalDocExistForCompany;
    companyLegalDocsList;
    oppName;
    oppCompanyId;
    oppCompanyName;

    @wire(getSalesOrderInfo,{oppId:'$recordId'})
        getSalesOrderDetails({data, error}){
            console.log('data'+data);

            //Found Primary sales order with biling entity and opp is not closed won/lost
            if(data!=undefined){
                console.log('data'+data);
                this.missingRelevantInfo=false;
                this.salesOrderSelectedAgreementType=data.Legal_Agreement_Type__c;
                this.oppName=data.Opportunity.Name;
                this.oppCompanyId=data.Opportunity.Company__c;
                this.oppCompanyName=data.Opportunity.Company__r.Name;
                if (this.salesOrderSelectedAgreementType=='monday.com SaaS' || this.salesOrderSelectedAgreementType=='Customer SaaS' ) {
                    this.salesOrderSelectedAgreementType='SaaS Agreement';
                }
                //We only support SaaS and TOS + DPA Agreements (For Now)
                if (this.salesOrderSelectedAgreementType!='SaaS Agreement' && this.salesOrderSelectedAgreementType!='TOS + DPA') {
                    this.missingRelevantInfo=true;
                }
                //Check if there is a clm process under this SO legal agreement type
                else{
                    this.checkIfLegalDocExist();
                }
            }
            //Didnt found a quote type sales order with valid billing entity and open opp
            else if (data==undefined) {
                this.missingRelevantInfo=true;
            }
            else if (error) {
                this.missingRelevantInfo=true;
                this.error = error;
            }
            console.log('data'+data);

        }

checkIfLegalDocExist(){
    checkIfLegalDocExist({oppId: this.recordId, legalDocType: this.salesOrderSelectedAgreementType }).then((response)=>{
        //Found legal document type record by the so agreement type - call list of legal docs table
        if(response!=null){
            this.missingRelevantInfo=false;
            this.showCompanyLegalDocTable=true;
            this.companyLegalDocsList=response;
        } 
        //Didn't found legal document type record by the so agreement type 
        else if (this.salesOrderSelectedAgreementType=='SaaS Agreement' ) {
            this.legalDocExistForCompany=false;
            this.showSaaSbutton=true;
        }
        else if (this.salesOrderSelectedAgreementType=='TOS + DPA' ) {
            this.legalDocExistForCompany=false;
            this.showDPAbutton=true;
        }

    }).catch(error => {
        console.log(error.body.message);
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error in legalDocExistForCompany',
                message: error.body.message,
                variant: 'error',
            }),
        );
    });
}
//Each clm doc url will have a different url and therefore a different buttons
    InitSaasAgreement(event){
        var thisUrl ="https://uatna11.springcm.com/atlas/doclauncher/eos/Monday SaaS Agreement?aid=25283&eos[0].Id="+this.recordId+"&eos[0].System=Salesforce&eos[0].Type=Opportunity&eos[0].Name="+this.oppName+"&eos[0].ScmPath=/Salesforce/Companies/"+this.oppCompanyName+"/Opportunities/";
        window.open(thisUrl,'_blank');
    }

    InitDPA(event){
        var thisUrl ="https://uatna11.springcm.com/atlas/doclauncher/eos/Exhibit Form?aid=25283&eos[0].Id="+this.recordId+"&eos[0].System=Salesforce&eos[0].Type=Opportunity&eos[0].Name="+this.oppName+"&eos[0].ScmPath=/Salesforce/Companies/"+this.oppCompanyName+"/Opportunities/";
        window.open(thisUrl,'_blank');
    }        
    closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}