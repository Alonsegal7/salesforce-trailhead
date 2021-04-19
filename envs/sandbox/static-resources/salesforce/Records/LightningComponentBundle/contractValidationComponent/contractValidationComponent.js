import { LightningElement,track,wire,api } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import contractFromBB from '@salesforce/apex/ContractValidationCopmController.getBBContract';
import createContract from '@salesforce/apex/ContractValidationCopmController.createContract';
import findContracts from '@salesforce/apex/ContractValidationCopmController.findExisingContracts';
import sendContractToBB from '@salesforce/apex/ContractValidationCopmController.sendContractToBB';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

export default class contractValidationComponent extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName;
    @track con={ 'sobjectType': 'Contract' };
    @track error;
    @track seats;
    @track listPrice;
    @track unitPrice;
    @track discount;
    @track accountId;
    @track startDate;
    @track tier;
    @track endDate;
    @track currency;
    @track paid;
    @track free;
    @track name;
    @track pulseContractId;
    @track pulseAccountId;
    @track contractId;
    @track pulseId;
    @track title='Confirm Account Previous Contract';
    @track message='';
    @track success=false;
    @track oppLocked=false;
    @track isLoading=true;
    @track noContract=false;
    @track linkToBB;
    @track period;
    @track pricingVersion;
    @track termMonths;
    migratedSeats;
    migratedUP;
    migratedFree;
    migratedPaid;
    migratedDiscount;
    migratedStart;
    migratedEnd;
    conName;
    listpriceDisabled=true;
    

    @wire(contractFromBB,{oppId:'$recordId'})
        wiredContract({data, error}){
            console.log('Raz Ben Ron in wire CV $recordId: '+'$recordId');
            //console.log('Raz Ben Ron data:',data);
            if(data){
                //console.log('Raz Ben Ron Contract from BB:',data);
                this.con=data;
                this.seats=this.con.Seats__c;
                this.migratedSeats=this.seats;
                this.listPrice=this.con.List_Price__c; 
                this.unitPrice=this.con.Unit_Price__c; 
                this.migratedUP=this.unitPrice;
                this.discount=(1-(this.con.Unit_Price__c/this.con.List_Price__c))*100;
                this.migratedDiscount=this.discount;
                this.accountId=this.con.AccountId; 
                this.startDate=this.con.StartDate;      
                this.endDate=this.con.EndDate; 
                this.migratedStart=this.con.StartDate; 
                this.migratedEnd=this.con.EndDate;
                this.tier=this.con.Tier__c;     
                this.pricingVersion=this.con.Pricing_Version__c; 
                this.pulseContractId=this.con.Pulse_Contract_Id__c;
                this.paid=this.con.Paid_Months__c; 
                this.migratedPaid=this.paid;
                this.free=this.con.Free_Months__c;
                this.migratedFree=this.free;      
                this.name=this.con.Name; 
                this.currency=this.con.CurrencyIsoCode; 
                this.pulseAccountId=this.con.Pulse_Account_Id__c;
                this.period=this.con.Period__c;
                this.linkToBB='https://bigbrain.me/accounts/'+this.pulseAccountId+'/profile';
                this.conName=this.tier+' - '+this.seats+' '+this.period+' - '+this.startDate;
                this.termMonths=this.free+this.paid;
                /*this.term=this.startDate-this.endDate;
                const diffDays = Math.ceil(Math.abs(new Date(this.startDate) - new Date(this.endDate)) / (1000 * 60 * 60 * 24)); 
                this.termMonths=Math.floor(diffDays/30);*/
                this.error = undefined;
            }
            else if (!data){
                console.log('response empty from BB:');
                if(this.recordId!==undefined&&this.recordId!=='undefined'){
                    this.goToDealHubNoContract();
                }
            }
            if (error) {
                console.log('Raz Ben Ron error in getContract from BB:',this.error);
                this.error = error;
                this.con = undefined;
            }
            this.isLoading=false;
        }
        @wire(findContracts,{oppId:'$recordId'})
        wiredExistingContracts({data, error}){
            if(data){
                //if there are already contracts under the opp, go directly to DealHub
                if(data.StageName=='Closed Won'){
                    this.dealHubLocked();
                }else if(data.Account.Active_Contract__c!==undefined){
                    console.log('Opportunity won or already an active contract on the MA');
                    this.goToDealHubScreen();
                }
                this.error = undefined;
            }
            else if (error) {
                console.log('Raz Ben Ron error in find existing contracts in SF:',this.error);
                this.error = error;
                this.con = undefined;
            }
        }

    handleUnitPrice(event){
        this.unitPrice=event.target.value;
        const num=1-(this.unitPrice/this.listPrice);
        //console.log(num);
        this.discount=Math.round((num + Number.EPSILON) * 100);
        //console.log(this.discount);
    }
    handleDiscount(event){
        this.discount=event.target.value;
        const num=this.listPrice*(1-this.discount/100);
        //console.log(num);
        this.unitPrice=Math.round((num + Number.EPSILON) * 100) / 100;
        //console.log(this.unitPrice);
    }
    handleListPrice(event){
        this.listPrice=event.target.value;
        const num=1-(this.unitPrice/this.listPrice);
        //console.log(num);
        this.discount=Math.round((num + Number.EPSILON) * 100);
        //console.log(this.unitPrice);
    }
    handlePaid(event){
        this.paid=event.target.value;
        if(this.paid=='')
            this.paid=0;
    }
    handleFree(event){
        this.free=event.target.value;
        if(this.free==''){
            this.free=0;
        }
    }
    handleSeats(event){
        this.seats=event.target.value;
    }
    handleStart(event){
        this.startDate=event.target.value;
    }
    handleEnd(event){
        this.endDate=event.target.value;
    }
    goToDealHubScreen(){
        this.success=true;
        this.title='Thank You!';
        console.log('Raz go to dealhub screen function');
    }
    dealHubLocked(){
        this.oppLocked=true;
        this.success=true;
        this.title='Opportunity Already Closed';
        this.message='The Opportunity is won, cant generate new quotes under this opportunity.';
        console.log('Raz hubspot locked function');
    }
    goToDealHubNoContract(){
        this.noContract=true;
        this.success=true;
        this.title='Thank You!';
        console.log('Raz no contract function');
    }
    get redirectToDH(){
        if(this.oppLocked==true)
            return false
        else
            return true
    }
    goToDealHub(event){
        console.log('record id: '+this.recordId);
        var thisUrl ="https://"+window.location.hostname.replace('lightning.force', 'my.salesforce')+"/apex/valt__beforeCanvasPrep?Id="+this.recordId+"&param=CreateQuoteFromOpp";
        console.log('Raz thisUrl: '+thisUrl);
        window.open(thisUrl,'_blank');
    }

    handleSave(){
        this.isLoading=true;
        let cont = { 'sobjectType': 'Contract' };
        cont.Seats__c=this.seats
        cont.Migrated_Seats__c=this.migratedSeats;
        cont.Tier__c=this.tier;
        //cont.AccountId=this.accountId;
        cont.List_Price__c=this.listPrice;
        cont.Unit_Price__c=this.unitPrice;
        cont.Migrated_Unit_Price__c=this.migratedUP;
        cont.Discount__c=this.discount;
        cont.Migrated_Discount__c=this.migratedDiscount;
        cont.StartDate=this.startDate
        cont.EndDate=this.endDate;
        cont.Migrated_Start_Date__c=this.migratedStart;
        cont.Migrated_End_Date__c=this.migratedEnd;
        cont.Paid_Months__c=this.paid;
        cont.Migrated_Paid_Months__c=this.migratedPaid;
        cont.Free_Months__c=this.free;
        cont.Migrated_Free_Months__c=this.migratedFree;
        cont.CurrencyIsoCode=this.currency;
        cont.Name=this.conName;
        cont.Pulse_Contract_Id__c=this.pulseContractId;
        cont.Pulse_Account_Id__c=this.pulseAccountId;
        cont.Period__c=this.period;
        cont.Pricing_Version__c=this.pricingVersion; 
        cont.Source__c='Migrated';
        cont.Status__c='Active';
        console.log('Raz Ben Ron period:',this.period);
        //console.log('Raz Ben Ron const.Tier__c:',cont.Tier__c);
        if(parseInt(this.termMonths)<(parseInt(this.free)+parseInt(this.paid))){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error Saving Contract',
                    message: 'Paid and Free months can\'t exceed the contract lenght',
                    variant: 'error',
                }),
            );  
            this.isLoading=false;
        }else{
            createContract( {contToCreate: cont}).then((resultContract)=>{
                this.contractId = resultContract.Id;
                console.log('this.contractId: '+this.contractId);
                const evt = new ShowToastEvent({
                    title: "Contract created",
                    message: "Record Created: "+this.contractId,
                    variant: "success"
                });
                this.dispatchEvent(evt);
                this.goToDealHubScreen();
                //this.success=true;
                //this.title='Thank You!';
                this.isLoading=false;
                sendContractToBB( {conToSend: resultContract}).then((response)=>{
                    console.log('this.contractId: '+this.contractId);
                    console.log('sent to BB');
                }).catch(error => {
                    console.log(error.body.message);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error Sending to BB',
                            message: error.body.message,
                            variant: 'error',
                        }),
                    );
                });
            }).catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error Creating Contract',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
            });
        }
        
    }
    get isListPriceDisabled() {
        if (this.listPrice !== 0&&this.listpriceDisabled) {
            console.log('Raz Ben Ron should be disabled:');
            return true;
        } else {
            console.log('Raz Ben Ron should NOT be disabled:');
            this.listpriceDisabled=false;
            return false;
        }
        return ;   
    }

}