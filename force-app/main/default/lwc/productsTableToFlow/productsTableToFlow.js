import { LightningElement, wire, api } from 'lwc';
import {FlowNavigationNextEvent, FlowNavigationBackEvent} from 'lightning/flowSupport';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';  
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ERROR_GIF from '@salesforce/resourceUrl/errorReachGif';
import createProducts_SOR from '@salesforce/apex/dealhubAPI_CreateProductsService.createProductsForSOR';
import insertForecastQuote from '@salesforce/apex/OpportunityForecastCTRL.insertForecastQuote';
import removeLineItemsAndQuotes from '@salesforce/apex/OpportunityForecastCTRL.removeLineItemsAndQuotes';
import getPricesFromDealhub from '@salesforce/apex/dealhub_Product_Pricing_Service.getPricesFromDealhub';
import getCurrentForecast from '@salesforce/apex/OpportunityForecastCTRL.getCurrentQuoteLineItems';
import getCurrentContractProduct from '@salesforce/apex/OpportunityForecastCTRL.getCurrentContractProduct';
import { getRecord, getFieldValue,updateRecord } from 'lightning/uiRecordApi';
import PRICING_VERSION from '@salesforce/schema/Opportunity.Pricing_Version__c';
import CURRENCYISO from '@salesforce/schema/Opportunity.CurrencyIsoCode';
import PRIOR_ARR from '@salesforce/schema/Opportunity.Prior_ARR__c';
import EXPECTED_PLAN_TIER from '@salesforce/schema/Opportunity.Expected_Plan_Tier__c';
import CURRENT_ACCOUNT_PLAN_TIER from '@salesforce/schema/Opportunity.Account.Plan_Tier__c';
import SYNCED_QUOTE from '@salesforce/schema/Opportunity.SyncedQuoteId';
import SYNCED_QUOTE_PRICING_VERSION from '@salesforce/schema/Opportunity.SyncedQuote.Pricing_Version__c';
import SYNCED_QUOTE_TYPE from '@salesforce/schema/Opportunity.SyncedQuote.Document_Type__c';
import OPP_ARR from '@salesforce/schema/Opportunity.Green_Bucket_ARR_V2__c'; 
import EXCHANGE_RATE from '@salesforce/schema/Opportunity.USD_exchange_rate__c'; 
import CURRENT_ACCOUNT_CONTRACT from '@salesforce/schema/Opportunity.Account.Active_Contract__c';
import EXPECTED_QUOTE_TYPE from '@salesforce/schema/Opportunity.Expected_Quote_Type__c';
import CURRENCY_VALIDATION from '@salesforce/schema/Opportunity.validateCurrencyChange__c';

const fields = [CURRENCY_VALIDATION,EXPECTED_QUOTE_TYPE,CURRENT_ACCOUNT_CONTRACT,SYNCED_QUOTE_TYPE,SYNCED_QUOTE_PRICING_VERSION,EXCHANGE_RATE,OPP_ARR,PRICING_VERSION,CURRENCYISO,PRIOR_ARR,EXPECTED_PLAN_TIER,CURRENT_ACCOUNT_PLAN_TIER,SYNCED_QUOTE];

export default class ProductsTableToFlow extends LightningElement {

    columns = [
        { label: 'Product', fieldName: 'productName',type: 'text', initialWidth: null },
        { label: 'Unit Price', fieldName: 'price', type: 'currency',editable: true, initialWidth: null, //price = list unit price from the json file
        typeAttributes: 
        { 
            minimumFractionDigits: 1, 
            maximumFractionDigits: 1,
            currencyCode: 
            { fieldName: 'crrncy' }, 
            currencyDisplayAs: 'symbol' },
            
        },
        { label: 'Quantity', fieldName: 'quantity',  type: 'number', editable: true, initialWidth: null},
        { label: 'Discount %', fieldName: 'discount',  type: 'number', editable: true, initialWidth: null},
        { label: 'Total', fieldName: 'total', type: 'currency', initialWidth: null,
        typeAttributes: 
        { 
            minimumFractionDigits: 2, 
            maximumFractionDigits: 2,
            currencyCode: 
            { fieldName: 'crrncy' }, 
            currencyDisplayAs: 'code' }
    }
    ];
    
    @api jsonSkusData;
    @api psorTier;
    @api duration;
    @api pricingVersion;
    @api Products;
    @api crrncyIso;
    @api context;
    @api parentRecId;
    @api availableActions = [];
    @api recordId;
    @api contractId;
    @api productColumnWidth;
    @api unitPriceColumnWidth;
    @api quantityColumnWidth;
    @api discountColumnWidth;
    @api totalColumnWidth;
    @api submitAsPromise='false';
    tableErrors = { rows: {}, table: {} };
    data;
    listOfDrafts = [];
    dataError=false;
    coreProductQty = 0;
    errorReachGif=ERROR_GIF;
    totalList=0;
    totalNet=0;
    validateSubmit=false;
    showSubmitModal=false;
    productsToInsert = [];
    isLoading;    
    showProductsTable=false;
    error;
    oppCurrentCrrncy;
    oppCurrentPriVersion;
    currentForecastQuoteId;
    currStateData;
    isQuoteContext=false;
    currentStateIsContract=false;
    tiersOptions;
    tierSelection;
    priorArr = 0;
    oppExpectedPlan;
    accCurerentPlan;
    syncedQuote;
    oppData;
    currentContractCoreProductQty=0;
    addedArr=0;
    showTotalPricing=true;
    exchangeRate;
    pricingVersionForHtml;
    syncedQuotePricingVerision;
    submitButtonPosition;
    syncedQuoteType;
    ContractTypeVal='New Contract';
    disableTier=false;
    oppExpectedQuoteType;
    isProRated=false;
    disableContractType=false;
    modalFields = [CURRENCYISO];
    oppId;
    validateCurrencyChange;
    isLoadingModal;
    handledByCurrencyChangeProcess=false;
    listOfDraftsOnCurrencyChange=[];
    currencyValues;
    haveNonForecstDocument=false;
    productPricingObject;
    shouldRunCallout=false;

    @wire(getPicklistValues, { recordTypeId: '0121t000000LucvAAC', fieldApiName: CURRENCYISO })
    fetch({ data }) {
        if (data) {
            this.currencyValues=data.values;
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields: fields })
    fetchOppty({ data }) {//if is not under quote context, will not run
         if (data) { 
            this.oppData=data;
            this.oppId=data.id;
            this.isQuoteContext=true;
            this.shouldRunCallout = (this.oppCurrentCrrncy!=getFieldValue(data, CURRENCYISO) || parseInt(this.oppCurrentPriVersion)!= parseInt(getFieldValue(data, PRICING_VERSION)))? this.shouldRunCallout = true : this.shouldRunCallout=false;
            this.oppCurrentPriVersion = getFieldValue(data, PRICING_VERSION);
            this.validateCurrencyChange = getFieldValue(data, CURRENCY_VALIDATION);
            this.oppCurrentCrrncy = getFieldValue(data, CURRENCYISO);
            this.crrncyIso = getFieldValue(data, CURRENCYISO);
            this.priorArr = getFieldValue(data, PRIOR_ARR);
            this.syncedQuote = getFieldValue(data, SYNCED_QUOTE);
            this.addedArr= getFieldValue(data, OPP_ARR);
            this.exchangeRate= getFieldValue(data, EXCHANGE_RATE);
            this.syncedQuotePricingVerision=getFieldValue(data, SYNCED_QUOTE_PRICING_VERSION);
            this.syncedQuoteType=getFieldValue(data, SYNCED_QUOTE_TYPE);
            this.contractId=getFieldValue(data, CURRENT_ACCOUNT_CONTRACT);
            this.pricingVersionForHtml = this.oppCurrentPriVersion;
            this.resetValues();// for cases that we change pricing version or currency, reset on load, the calculation will run on draft on the runForecastProcessOnLoad process

            if (this.syncedQuoteType=='Quote' || this.syncedQuoteType=='Sales Order') {//is quote or sales order stop process
                this.haveNonForecstDocument=true;
                this.showProductsTable=false;
            }
            else if (this.handledByCurrencyChangeProcess==false) {//if process handled by currency change, do not take plan, type and tier
                this.oppExpectedPlan = getFieldValue(data, EXPECTED_PLAN_TIER);
                this.accCurerentPlan = getFieldValue(data, CURRENT_ACCOUNT_PLAN_TIER);
                this.oppExpectedQuoteType=getFieldValue(data, EXPECTED_QUOTE_TYPE);
                this.defineTier();
                this.defineQuoteType();
                this.runForecastProcessOnLoad();  
                this.calculateProductsPricing(this.listOfDrafts);
            }
        }
    }

    connectedCallback(){
        if(this.context=='quote'){  
            //for forecast type, show values as number and not currency
            this.columns[1].typeAttributes=null;
            this.columns[4].typeAttributes=null;
            this.columns[1].type='number';
            this.columns[4].type='number';
            this.columns[1].label='PPU';

            this.showTotalPricing=false;
            this.setTableWidth(); 

            this.tiersOptions = [
                { label: 'Standard', value: 'Standard'},
                { label: 'Pro', value: 'Pro'},
                { label: 'Enterprise', value: 'Enterprise'},    
            ];

            this.contractTypOptions = [
                { label: 'New Contract', value: 'New Contract'},
                { label: 'Pro-Rated', value: 'Pro-rated'}  
            ];
        }

        if(this.context=='PartnerSOR'){
            this.setTableWidth(); 
            this.tierSelection=this.psorTier;
            if (this.contractId!=null) {
                this.currentStateIsContract=true;
                 this.getContractProduct();
            }
           
            if (this.contractId==null) {
                //this.defineDealhubProductRequest(this.psorTier,this.crrncyIso,this.pricingVersion);
                this.setTableValues();
            }
        }
    }

    runForecastProcessOnLoad(){ //when wire record change - run full process 
        this.isLoading=true;
        if((this.syncedQuote!=null && this.syncedQuote!=undefined) && 
            (this.oppCurrentCrrncy!=undefined && 
            this.oppCurrentPriVersion!=undefined && 
            this.tierSelection!=undefined) && 
            this.syncedQuotePricingVerision==this.oppCurrentPriVersion && 
            this.tierSelection == this.oppExpectedPlan && this.currStateData==null &&
            this.syncedQuoteType=='Forecast'){ //I have existing forecast quote, call the server to get the forecast information back to the table

            this.currentForecastQuoteId=this.syncedQuote;
            getCurrentForecast({quoteId: this.currentForecastQuoteId}).then((currentState)=>{
                    if(currentState[0]!=null){ 
                        this.tierSelection=currentState[0].Quote.DH_Tier__c;
                this.setCurrentStateFields(currentState)//convert response to context object
                }
            }).catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Products Error - Please contact BizOps ',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
            });
        }
        else{
            this.currStateData=null;//if pricing version or currency is different then current forecast, refersh table data
            this.currentContractCoreProductQty=0;
        }
        if (this.shouldRunCallout==true && this.tierSelection!=null && this.oppCurrentCrrncy!=null && this.oppCurrentPriVersion!=null ) {
            this.defineDealhubProductRequest(this.tierSelection,this.oppCurrentCrrncy,this.oppCurrentPriVersion);
        }
        else{
            this.isLoading=false;
        }
    }


    setTableValues(){
        if (this.context==undefined ) return;
        console.log('set values');
        this.data =this.context=='quote' ? this.jsonSkusData : JSON.parse(this.jsonSkusData).skus;//Parse dealhub api response TODO - handle psor flow (on psor flow, api handled by the flow)
        this.data.forEach(entity => { //set values on load (also if we have exiting data, to allow additional products, init all data all the time)
            entity.productName=this.context=='quote' ? entity.productShortName : entity.productName;
            entity.quantity=0;
            entity.discount=0;
            entity.total=0;
            entity.crrncy=this.crrncyIso; 
            entity.originalListPrice =entity.price;
        });
         this.showProductsTable=true;
         this.isLoading=false;

        if (this.currStateData) {//do we have existing data? if so, add it to the draft list and calculate
            this.currStateData.forEach(singleData => {
                if (this.data.find(({ sku })  => sku === singleData.sku) != null){//make sure existing data is relevent to current table data
                if (this.currentStateIsContract==true){singleData.discount = singleData.netUnit > this.data.find(({ sku })  => sku === singleData.sku).price ? null : Math.abs(((singleData.netUnit - this.data.find(({ sku })  => sku === singleData.sku).price) /this.data.find(({ sku })  => sku === singleData.sku).price) * 100); }//for contract we are getting the discount by net
                const arrSingleData = [];
                arrSingleData.push(singleData);
                this.handleListOfDrafts(arrSingleData,this.listOfDrafts)//set drafts for existing data
            }
         });
        }

        if(this.handledByCurrencyChangeProcess==true){//if currency changed by modal, and we have existing forecast, it means that on load we capture the current state and kept the drafts. so now, we need to handle the new pricing
            this.listOfDrafts.forEach(draftVal => { 
                if (this.data.find(({ sku })  => sku === draftVal.sku)!=null ) {
                    draftVal.price = this.data.find(({ sku })  => sku === draftVal.sku).price;//get the price fro the dealhub response
                    draftVal.quantity = this.listOfDraftsOnCurrencyChange.find(({ sku })  => sku === draftVal.sku).quantity;//get draft value if changed before currency change
                    draftVal.discount = this.listOfDraftsOnCurrencyChange.find(({ sku })  => sku === draftVal.sku).discount;//get draft value if changed before currency change
                    }
                }); 
        }

            //this.validateError(this.listOfDrafts); //Validate draft values on load
            this.calculateProductsPricing(this.listOfDrafts);//Calculate pricing on load
    }
    handleListOfDrafts(currentDraft, listOfDraftsInput){//This function update the list with the last draft value of a specific line
        var singleCurrentDraftValue = {}
        var newCurrentDraftValue = {}        
        var objectFields = ['sku','quantity','discount','price','lineHasError'];

        //init first object with current draft values
        objectFields.forEach(field => { 
            singleCurrentDraftValue[field] = currentDraft.find(({ field })  => field === currentDraft.field)[field] != null ? currentDraft.find(({ field })  => field === currentDraft.field)[field] : null
        });
        //check if the draft val exist in list
        let relevantDraftSkuInList = listOfDraftsInput.find(({ sku })  => sku === singleCurrentDraftValue.sku);

        //search if exist to get values from prior draft, if found init new draft value with full current state
        if (relevantDraftSkuInList!= null &&relevantDraftSkuInList!= undefined ) {
            objectFields.forEach(field => { 
                newCurrentDraftValue[field] = singleCurrentDraftValue[field] != null &&  singleCurrentDraftValue[field] != undefined ? singleCurrentDraftValue[field] : relevantDraftSkuInList[field]
            });   
            listOfDraftsInput.splice(listOfDraftsInput.findIndex(drft => drft.sku ===singleCurrentDraftValue.sku),1);//Remove from list
            this.listOfDrafts.push(newCurrentDraftValue); //update the new one
        }
        else{//insert the draft to draft array
            this.listOfDrafts.push(singleCurrentDraftValue);
        }
        if (currentDraft[0]['sku'].includes('CORE')) {
            parseInt(this.coreProductQty=currentDraft[0].quantity) + parseInt(this.currentContractCoreProductQty);
        }
    }
    calculateProductsPricing(drafts){//we are alwys runing on all draft valus to auto calculate cases where a line hold an error, and the other isn't, when the error will removed, all the lines will be calculated and will show numbers
        this.totalList=0;//reset values on each calculation
        this.totalNet=0;//reset values on each calculation
        this.addedArr=0;//reset values on each calculation
        console.log('set calc price');

        drafts.forEach(draftVal => { 
            if (this.data.find(({ sku })  => sku === draftVal.sku) != null) {//check first if the draft sku exist in datatable
                let baseListPrice = draftVal.price != null ? this.data.find(({ sku })  => sku === draftVal.sku).price = draftVal.price : this.data.find(({ sku })  => sku === draftVal.sku).price = this.data.find(({ sku })  => sku === draftVal.sku).originalListPrice;
                if(draftVal.quantity!=null && draftVal.quantity!="" && (draftVal.lineHasError=="false" || draftVal.lineHasError==null)){
                    this.data.find(({ sku })  => sku === draftVal.sku).quantity = draftVal.quantity;   
                    this.data.find(({ sku })  => sku === draftVal.sku).total= draftVal.quantity *  baseListPrice * this.duration;
                    this.data.find(({ sku })  => sku === draftVal.sku).netUnit=baseListPrice;
                    this.totalList+=draftVal.quantity *  this.data.find(({ sku })  => sku === draftVal.sku).netUnit * this.duration;
                }
                if(draftVal.discount!=null && draftVal.discount!=""&& (draftVal.lineHasError=="false"|| draftVal.lineHasError==null)){
                    this.data.find(({ sku })  => sku === draftVal.sku).discount = draftVal.discount;  
                    draftVal.price != null ? this.data.find(({ sku })  => sku === draftVal.sku).price = draftVal.price : this.data.find(({ sku })  => sku === draftVal.sku).price = this.data.find(({ sku })  => sku === draftVal.sku).originalListPrice;
                    this.data.find(({ sku })  => sku === draftVal.sku).netUnit= baseListPrice * (1-(draftVal.discount / 100));
                    this.data.find(({ sku })  => sku === draftVal.sku).total= (draftVal.quantity *  this.data.find(({ sku })  => sku === draftVal.sku).netUnit * this.duration);
                }
                this.totalNet+=this.data.find(({ sku })  => sku === draftVal.sku).total;  
            }
         });    
         if(this.ContractTypeVal=='New Contract'){
         this.addedArr = this.totalNet != 0 ? this.totalNet * this.exchangeRate - this.priorArr : 0;
         }

         if(this.ContractTypeVal=='Pro-rated'){
            this.addedArr = this.totalNet != 0 ? this.totalNet * this.exchangeRate : 0;
         }

         if (this.handledByCurrencyChangeProcess==true) {
             this.handleSubmit();//if is handled by currency change process, create the new forecast after currnecy change and all calculations run (dealhub, draft and pricing)
        }
    }

    validateError(listOfDraftsToValidate) {
        this.getCurrentCoreAmount(this.tierSelection,listOfDraftsToValidate);
        this.validateSubmit=false;

        //First, sreset current status of all draft values
        listOfDraftsToValidate.forEach(resetError => {
            JSON.stringify(resetError.lineHasError="false");
          });
             this.tableErrors = {};
             this.tableErrors.rows = {};
                 listOfDraftsToValidate.forEach(draftVal => {
                    if (this.data.find(({ sku })  => sku === draftVal.sku) != null) {//check first if the draft sku exist in datatable
                        if (draftVal.quantity === "") {
                            this.validateSubmit=true;
                            JSON.stringify(draftVal.lineHasError="true");
                            JSON.stringify(this.data.find(({ sku })  => sku === draftVal.sku).total=0);
                            let errorMsgValue = {
                                title: 'We found 1 errors.',
                                messages: 'Quantity cannot be null',
                                fieldNames: 'quantity'
                            };
                            this.tableErrors.rows[draftVal.sku] = errorMsgValue;
                           }
                           if (draftVal.discount === "") {
                            this.validateSubmit=true;
                            JSON.stringify(draftVal.lineHasError="true");
                            JSON.stringify(this.data.find(({ sku })  => sku === draftVal.sku).total=0);
                            let errorMsgValue = {
                                title: 'We found 1 errors.',
                                messages: 'Discount cannot be null',
                                fieldNames: 'discount'
                                
                            };
                            this.tableErrors.rows[draftVal.sku] = errorMsgValue;
                           }
                           if (draftVal.discount > 100) {
                            this.validateSubmit=true;
                            JSON.stringify(draftVal.lineHasError="true");
                            JSON.stringify(this.data.find(({ sku })  => sku === draftVal.sku).total=0);
                            let errorMsgValue = {
                                title: 'We found 1 errors.',
                                messages: 'Discount cannot be more then 100%',
                                fieldNames: 'discount'
                                
                            };
                            this.tableErrors.rows[draftVal.sku] = errorMsgValue;
                           }
                           if (draftVal.discount < 0 || draftVal.quantity < 0) {
                            this.validateSubmit=true;
                            JSON.stringify(draftVal.lineHasError="true");
                            JSON.stringify(this.data.find(({ sku })  => sku === draftVal.sku).total=0);
                            let errorMsgValue = {
                                title: 'We found 1 errors.',
                                messages: 'Discount or quantity cannot be minus',
                                fieldNames: 'discount'
                                
                            };
                            this.tableErrors.rows[draftVal.sku] = errorMsgValue;
                           }
                           if (draftVal.discount === "" && draftVal.quantity === "") {
                            this.validateSubmit=true;
                            JSON.stringify(draftVal.lineHasError="true");
                            JSON.stringify(this.data.find(({ sku })  => sku === draftVal.sku).total=0);
                            let errorMsgValue = {
                                title: 'We found 2 errors.',
                                messages: ['Discount cannot be null','Quantity canot be null'],
                                fieldNames: ['quantity','discount']
                            };
                            this.tableErrors.rows[draftVal.sku] = errorMsgValue;
                           }
                           if (draftVal.sku.includes('CORE')==false && parseInt(draftVal.quantity) % 5 != 0 && parseInt(draftVal.quantity) > parseInt(this.coreProductQty)) {
                            this.validateSubmit=true;
                            JSON.stringify(draftVal.lineHasError="true");
                            JSON.stringify(this.data.find(({ sku })  => sku === draftVal.sku).total=0);
                            let errorMsgValue = {
                                 title: 'We found 2 errors.',
                                 messages: ['Please make sure to set the quantity in steps of 5','CORE Quantity must be higher then the add-on quantity'],
                                 fieldNames: 'quantity'    
                             };
                             this.tableErrors.rows[draftVal.sku] = errorMsgValue;
                            }
                            if (draftVal.sku.includes('CORE')==false && parseInt(draftVal.quantity) > parseInt(this.coreProductQty)) { 
                                this.validateSubmit=true;
                                JSON.stringify(draftVal.lineHasError="true");
                                JSON.stringify(this.data.find(({ sku })  => sku === draftVal.sku).total=0);
                                let errorMsgValue = {
                                    title: 'We found 1 error.',
                                    messages: 'CORE quantity must be higher then the add-on quantity',
                                    fieldNames: 'quantity'
                                };
                                this.tableErrors.rows[draftVal.sku] = errorMsgValue;
                            }
                            if (draftVal.sku.includes('CORE')==false && draftVal.discount==="" && parseInt(draftVal.quantity) > parseInt(this.coreProductQty)) {
                                this.validateSubmit=true;
                                JSON.stringify(draftVal.lineHasError="true");
                                JSON.stringify(this.data.find(({ sku })  => sku === draftVal.sku).total=0);
                                let errorMsgValue = {
                                     title: 'We found 2 errors.',
                                     messages: ['Discount cannot be empty','CORE quantity must be higher then the add-on quantity'],
                                     fieldNames: ['quantity','discount']    
                                 };
                                 this.tableErrors.rows[draftVal.sku] = errorMsgValue;
                                }
                            if ((parseInt(draftVal.quantity) === 0 || draftVal.quantity==="" || draftVal.quantity===null) && parseInt(draftVal.discount)>0) { 
                                this.validateSubmit=true;
                                JSON.stringify(draftVal.lineHasError="true");
                                JSON.stringify(this.data.find(({ sku })  => sku === draftVal.sku).total=0);
                                let errorMsgValue = {
                                    title: 'We found 1 error.',
                                    messages: 'Please make sure to define quantity for the discounted product',
                                    fieldNames: 'quantity'
                                };
                                this.tableErrors.rows[draftVal.sku] = errorMsgValue;
                            }
                            if (parseInt(draftVal.quantity) > 0 && parseInt(draftVal.quantity) % 5 != 0) {
                                this.validateSubmit=true;
                                JSON.stringify(draftVal.lineHasError="true");
                                JSON.stringify(this.data.find(({ sku })  => sku === draftVal.sku).total=0);
                                let errorMsgValue = {
                                    title: 'We found 1 errors.',
                                    messages: 'Quantity must be with the steps of 5',
                                    fieldNames: 'quantity'
                                };
                                this.tableErrors.rows[draftVal.sku] = errorMsgValue;
                            }
                            if (draftVal.price != null && draftVal.price < this.data.find(({ sku })  => sku === draftVal.sku).originalListPrice ) {
                                this.validateSubmit=true;
                                JSON.stringify(draftVal.lineHasError="true");
                                JSON.stringify(this.data.find(({ sku })  => sku === draftVal.sku).total=0);
                                let errorMsgValue = {
                                    title: 'We found 1 errors.',
                                    messages: 'You cant set product list price bellow original list price - Original List price is ' + this.data.find(({ sku })  => sku === draftVal.sku).originalListPrice +' Make sure to set the price above or equal the original' ,
                                    fieldNames: 'price'
                                };
                                this.tableErrors.rows[draftVal.sku] = errorMsgValue;
                            }
                        }
                 });     
                }

    handleSubmit(){
        this.isLoading=true;
        setTimeout(() => {//wait a bit in cases where the user set values to draft-val w/o event 
            console.log('submiting');
            if (this.validateSubmit==true || this.totalList==0) {
                this.showSubmitModal=true;
                this.isLoading=false;
            }
            if(this.validateSubmit==false && this.totalList>0){
                this.isLoading=true;
                this.productsToInsert=[];
                //Get relevant products
                this.data.forEach(singleProd => {
                    if((singleProd.total>0 || (singleProd.total==0 && singleProd.discount==100))){
                        this.productsToInsert.push(singleProd);
                    }
                });
                //Now, check context
                if(this.context=='PartnerSOR'){
                    let recId = this.parentRecId;
                    createProducts_SOR( {sor: recId, productsData: JSON.stringify(this.productsToInsert)}).then(()=>{
                        this.isLoading=false;
                        if (this.availableActions.find((action) => action === 'NEXT')) {
                            // navigate to the next screen
                            const navigateNextEvent = new FlowNavigationNextEvent();
                            this.dispatchEvent(navigateNextEvent);
                        }
                    }).catch(error => {
                        this.validateSubmit==true;
                        this.error=error;
                        console.log(this.error);
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Products Error - Please contact BizOps ',
                                message: error.body.message,
                                variant: 'error',
                            }),
                        );
                    }); 
                }
            
                if(this.context=='quote'){
                    if (this.submitAsPromise=='false') {
                        try {
                            insertForecastQuote( {oppId: this.oppData.id, productsData: JSON.stringify(this.productsToInsert), tier: this.tierSelection, contractType: this.ContractTypeVal});
                            this.calculateProductsPricing(this.listOfDrafts);//Calculate pricing again 
                            this.handledByCurrencyChangeProcess=false;
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Success!',
                                    message: '????Forecast Submitted Successfully???? (It might take a few seconds until the opportunity is updated)',
                                    variant: 'success',
                                }),
                            );
                            this.isLoading=false;
    
                        } catch (error) {
                            this.validateSubmit==true
                            this.isLoading=false;
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Products Error - Please contact BizOps ',
                                    message: error.body.message,
                                    variant: 'error',
                                }),
                            );
                        }
                    }
                    else{
                        insertForecastQuote( {oppId: this.oppData.id, productsData: JSON.stringify(this.productsToInsert), tier: this.tierSelection, contractType: this.ContractTypeVal}).then((res)=>{
                            console.log('inserting quote '+ this.oppCurrentCrrncy);
                            if (res[0]!=null) {
                                this.handledByCurrencyChangeProcess=false;
                                this.calculateProductsPricing(this.listOfDrafts);//Calculate pricing again after quote was inserted
                                this.syncedQuote=res[0].QuoteId;
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: 'Success!',
                                        message: '????Forecast Updated Successfully????',
                                        variant: 'success',
                                    }),
                                );
                            }
                            
                            this.isLoading=false;
                        }).catch(error => {
                            this.validateSubmit==true
                            this.isLoading=false;
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Products Error - Please contact BizOps ',
                                    message: error.body.message,
                                    variant: 'error',
                                }),
                            );
                        }); 
                    }

                }
            }
        }, '0202');

    }
    closeModalAction(){
        this.showSubmitModal=false;
    }
    handleBack(){
        if (this.availableActions.find((action) => action === 'BACK')) {
            // navigate to the back screen
            const navigateBackEvent = new FlowNavigationBackEvent();
            this.dispatchEvent(navigateBackEvent);
        }
    }
    
    setCurrentStateFields(state){//set the state (either existing forecast or contract) to the object fields to habndle on calculate
        let sku;
        let quantity;
        let discount;
        let list;
        let netUnit;

        if(this.currentStateIsContract==false){//current state it quote
            sku='Product_Identifier_SKU__c';
            quantity= this.isProRated==true? 'Added_Seats__c': 'Seats__c';//for pro-rated, treat quantity as added seats
            discount='Discount';
            list='List_Price__c';
        }
        if(this.currentStateIsContract==true){
            sku='SKU__c';
            netUnit='Net_Per_Unit__c';
        }
        state.forEach( obj => this.renameKey( obj, sku, 'sku' ) );
        state.forEach( obj => this.renameKey( obj, quantity, 'quantity' ) );
        state.forEach( obj => this.renameKey( obj, discount, 'discount' ) );
        state.forEach( obj => this.renameKey( obj, list, 'price' ) );
        state.forEach( obj => this.renameKey( obj, netUnit, 'netUnit' ) );
        this.currStateData=state;
    }

    renameKey ( obj, oldKey, newKey ) {
        obj[newKey] = obj[oldKey];
        delete obj[oldKey];
        }

        getContractProduct(){//for pro-rated types
        getCurrentContractProduct({contractId: this.contractId}).then((conProds)=>{
            if(conProds[0]!=null){ 
                this.currentContractCoreProductQty=conProds.find(({ SKU__c }) => SKU__c === 'CORE-PRO' || SKU__c === 'CORE-ENT' || SKU__c === 'CORE-STD').Quantity__c;
                this.coreProductQty = this.currentContractCoreProductQty;
               
                if(this.context='PartnerSOR'){
                    this.setTableValues(); // json price sent from flow - go direct to set table function
                    this.setCurrentStateFields(conProds);//convert response to context object
                }
            }

        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Products Error - Please contact BizOps ',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
        }); 
    }
    setTableWidth(){
        if (this.context=='quote') {
            if (window.screen.width>1800) {//for desktop screen, set the total for 210
                this.totalColumnWidth=210;
            }
            this.submitButtonPosition="12";
        }
        if (this.context=='PartnerSOR') {
            this.submitButtonPosition="6";
        }
        this.columns[0].initialWidth=this.productColumnWidth=parseInt(this.productColumnWidth);
        this.columns[1].initialWidth=this.unitPriceColumnWidth=parseInt(this.unitPriceColumnWidth);
        this.columns[2].initialWidth=this.quantityColumnWidth= parseInt(this.quantityColumnWidth);
        this.columns[3].initialWidth=this.discountColumnWidth= parseInt(this.discountColumnWidth);
        this.columns[4].initialWidth=this.totalColumnWidth=parseInt(this.totalColumnWidth);
    }
    resetValues(){
        this.totalList=0;
        this.totalNet=0;
        this.addedArr=0;
        this.coreProductQty=0;

        if (this.oppCurrentPriVersion=="8") {//v8 pricing are v6 pricing
            this.oppCurrentPriVersion="6"
        }
        if (this.syncedQuotePricingVerision=="8") {//v8 pricing are v6 pricing
            this.syncedQuotePricingVerision="6"
        }
    }
    handleTierChange(event){
        this.tierSelection=event.detail.value;
        this.resetValues();
        this.setProductsTableOutput(event.detail.value,this.isEligableForProducts(this.oppCurrentPriVersion),this.productPricingObject);
    }
    getCurrentCoreAmount(tier,draftList){
        if (draftList.find(({ sku }) => sku === this.convertTierToSku(tier)) !=null){//when tier changed, we need to get the correct core amout to run validation
            parseInt(this.coreProductQty=draftList.find(({ sku }) => sku === this.convertTierToSku(tier)).quantity) + parseInt(this.currentContractCoreProductQty);
        }
        else{
            this.coreProductQty=0;
        }
    }
    convertTierToSku(selectedTier){
        if (selectedTier=='Pro') {
            return 'CORE-PRO'
        }
        if (selectedTier=='Enterprise') {
            return 'CORE-ENT'
        }
        if (selectedTier=='Standard') {
            return 'CORE-STD'
        }
    }
    convertSkuToTier(sku){
        if (sku.includes('PRO')) {
            return 'Pro'
        }
        if (sku.includes('ENT')) {
            return 'Enterprise'
        }
        if (sku.includes('STD')) {
            return 'Standard'
        }
    }
    defineTier(){
        if ((this.oppExpectedPlan==null || this.oppExpectedPlan==undefined) && this.accCurerentPlan !=null && this.accCurerentPlan != undefined) {
            this.tierSelection= this.accCurerentPlan =='Basic' ? this.tierSelection='Standard' : this.tierSelection=this.accCurerentPlan;
        }
        else if (this.oppExpectedPlan!=null && this.oppExpectedPlan!=undefined) {
            this.tierSelection=this.oppExpectedPlan;
        }
        else {
            this.tierSelection='Enterprise';
        }
    }


     defineQuoteType(){//define values on load
        if(this.oppExpectedQuoteType==null || this.oppExpectedQuoteType==undefined){
            this.ContractTypeVal=='New Contract';
        }
        else{
            this.ContractTypeVal=this.oppExpectedQuoteType;
        }
        if(this.ContractTypeVal=='New Contract'){
            this.disableTier=false;
            this.isProRated=false;
        }
        if(this.ContractTypeVal=='Pro-rated'){
            this.disableTier=true;
            this.isProRated=true;
        }
        if(this.contractId==null || this.contractId == undefined){
            this.disableContractType=true;
        }
    }

    handleCurrencyChange(event){//curency changed - remove quote, qli, oli, update new currency, and add the new quote with the updated currency                
        const currency =event.detail.value;
        this.isLoading=true;

        const fields = {};
        fields.Id = this.oppId;
        fields.CurrencyIsoCode =currency;
        fields.Expected_ARR__c =0;
        const recordInput = { fields };

        this.listOfDrafts.forEach(draftVal => { //if the user changed values on existing forecast and then changed currency, keep the changed values to get before submit
            this.listOfDraftsOnCurrencyChange.push(draftVal);
            }); 

            if(this.syncedQuote!=null){
                this.handledByCurrencyChangeProcess=true;
                removeLineItemsAndQuotes( {oppty: this.oppId, syncedQuote: this.syncedQuote}).then(()=>{//remove quote qli and oli
                updateRecord(recordInput).then(() => {//update the new currency - wait until its updated and only then submit the new forecast (so the updated currency will be updated properly on the new quote)
                    this.crrncyIso=currency;
                        this.defineDealhubProductRequest(this.tierSelection,currency,this.oppCurrentPriVersion);
                })
                .catch(error => {
                    this.isLoading=false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Products Error - Please contact BizOps ',
                            message: error.body.message,
                            variant: 'error',
                        }),
                    );
                });
                
            }).catch(error => {
                this.isLoading=false;
                this.validateSubmit==true;
                this.error=error;
                console.log(this.error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Products Error - Please contact BizOps ',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
            }); 
        }
        else{//just update the new currency - the dealhub request will run on wire (due to currency change)
            updateRecord(recordInput).then(() => {
            })
            .catch(error => {
                this.isLoading=false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Products Error - Please contact BizOps ',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
            });
        }
    }

    async defineDealhubProductRequest(tier,crrncyCode, pricingVersion){
        this.duration=12;
        this.isLoading=true;
        try {
            let priceRes = await getPricesFromDealhub({tier: null, crrncyCode: crrncyCode, pricingVersion: "V"+pricingVersion, skusList: null });//send request to dh
            if(priceRes!=null && this.context!=undefined){
                this.productPricingObject=priceRes;
                this.setProductsTableOutput(tier,this.isEligableForProducts(pricingVersion),this.productPricingObject);
            }
        this.shouldRunCallout=false;
        } catch (error) {
            console.log('### error: '+error.body.message);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
        }
    }

    isEligableForProducts(pricingVersion){
        if (pricingVersion=="9" || pricingVersion=="10" ) {
            return true;
        }
        else{
            return false;
        }
    }
    setProductsTableOutput(tier,isEligableForProducts,pricingObject){
        let multiProductCharacter = isEligableForProducts==true ? 'Add-On' :'Stand-Alone';
        let data = JSON.parse(pricingObject);
        this.jsonSkusData = data.skus.filter(
            obj => 
            obj.tier == tier &&
            (obj.productCharacter == 'Stand-Alone' || obj.productCharacter == multiProductCharacter));

            this.setTableValues();
    }

    handleContractTypeChange(event){
        this.ContractTypeVal=event.detail.value;
        if (this.ContractTypeVal=='New Contract') {
            this.handleNewContract();
        }   
        if (this.ContractTypeVal=='Pro-rated') {
            this.handleProRated();
        }
    }

    handleProRated(){//pro-rated quantities will be added only. we handle added and total values directly from the server (on the ctrl)
        this.isProRated=true;
        this.disableTier=true;
        this.tierSelection=this.accCurerentPlan;
        this.setProductsTableOutput(this.tierSelection,this.isEligableForProducts(this.oppCurrentPriVersion),this.productPricingObject);
    }

    handleNewContract(){
        this.disableTier=false;
        this.isProRated=false;
        this.resetValues();
        this.defineTier();
        this.setProductsTableOutput(this.tierSelection,this.isEligableForProducts(this.oppCurrentPriVersion),this.productPricingObject);
    }
    
    handleCellchange(event) { 
        this.dataError=false;
        this.handleListOfDrafts(event.detail.draftValues,this.listOfDrafts);//Map draft values
        this.validateError(this.listOfDrafts); //Validate draft values
        this.calculateProductsPricing(this.listOfDrafts);//Calculate pricing
    }
}