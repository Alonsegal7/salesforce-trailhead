import { LightningElement, wire, api } from 'lwc';
import {FlowAttributeChangeEvent, FlowNavigationNextEvent, FlowNavigationBackEvent} from 'lightning/flowSupport';
import MONDAY_LOGO from '@salesforce/resourceUrl/monday_products';
import ERROR_GIF from '@salesforce/resourceUrl/errorReachGif';
import createProducts_SOR from '@salesforce/apex/dealhubAPI_CreateProductsService.createProductsForSOR';

export default class ProductsTableToFlow extends LightningElement {
    columns = [
        /*{ label: 'SKU', fieldName: 'sku',type: 'text', initialWidth: 32},*/
        { label: 'Product Name', fieldName: 'productName',type: 'text', initialWidth: 232},
        { label: 'Unit Price', fieldName: 'price', type: 'currency',editable: true, initialWidth: 120, //price = list unit price from the json file
        typeAttributes: 
        { 
            minimumFractionDigits: 2, 
            maximumFractionDigits: 2,
            currencyCode: 
            { fieldName: 'crrncy' }, 
            currencyDisplayAs: 'code' },
            
        },
        { label: 'Quantity', fieldName: 'quantity',  type: 'number', editable: true, initialWidth: 130},
        { label: 'Discount %', fieldName: 'discount',  type: 'number', editable: true, initialWidth: 110},
        { label: 'Total Product Price', fieldName: 'total', type: 'currency', initialWidth: 230, 
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
    @api duration;
    @api pricingVersion;
    @api Products;
    @api crrncyIso;
    @api context;
    @api parentRecId;
    @api availableActions = [];
    tableErrors = { rows: {}, table: {} };
    validateQtyForPricingVersion;
    data;
    listOfDrafts = [];
    listIsEmpty=true;
    dataError=false;
    coreProductQty = 0;
    mondayLogo=MONDAY_LOGO;
    errorReachGif=ERROR_GIF;
    totalList=0;
    totalNet=0;
    validateSubmit=false;
    showSubmitModal=false;
    productsToInsert = [];
    isLoading;    

    foundAcc=false;
    accName;

   
    connectedCallback(){
        this.data = JSON.parse(this.jsonSkusData).skus;//Parse dealhub api response
        for (let i in this.data) {//set default value on load
            this.data[i].productName=this.Products.find(({ Product_Identifier__c }) => Product_Identifier__c === this.data[i].sku).Name;
            this.data[i].quantity=0;
            this.data[i].discount=0;
            this.data[i].total=0;
            this.data[i].crrncy=this.crrncyIso; 
            this.data[i].originalListPrice =this.data[i].price;
        }
    }   
    handleCellchange(event) { 
        this.dataError=false;
        if(this.listOfDrafts!=""){
            this.listIsEmpty=false;
        }

        this.handleListOfDrafts(event.detail.draftValues,this.listOfDrafts);//Map draft values
        this.validateError(this.listOfDrafts); //Validate draft values
        this.calculateProductsPricing(this.listOfDrafts);//Calculate pricing
    }
    handleListOfDrafts(currentDraft, listOfDraftsInput){//This function update the list with the last draft value of a specific line
        var singleCurrentDraftValue = {}
        var newCurrentDraftValue = {}
        var foundInList = false;

        //First, init event that will add to the list
            singleCurrentDraftValue['sku'] = currentDraft[0].sku;
            if (currentDraft[0].quantity!=null) {//I am a quantity event
                singleCurrentDraftValue['quantity'] = currentDraft[0].quantity;//Update the quantity to the init event
                if (singleCurrentDraftValue['sku'].includes('CORE')) {
                    this.coreProductQty=currentDraft[0].quantity;
                }
            }
            else{
                singleCurrentDraftValue['quantity'] = null;//If not, init the field on the JSON map
            }
            if (currentDraft[0].discount!=null) {//I am a discount event
                singleCurrentDraftValue['discount'] = currentDraft[0].discount;
            }
            else{
                singleCurrentDraftValue['discount'] = null;//If not, init the field on the JSON map
            }
            if (currentDraft[0].price!=null) {//I am a unit price event
                singleCurrentDraftValue['price'] = currentDraft[0].price;
            }
            else{
                singleCurrentDraftValue['price'] = null;//If not, init the field on the JSON map
            }
        
        //Now, check if the list is empty, if so, add the init event to the list
        if (this.listIsEmpty==true) {
            this.listOfDrafts.push(singleCurrentDraftValue);
        }

        //List is not empty, run on list, find and replace
        if(this.listIsEmpty==false){
            for(let i in listOfDraftsInput) {
                if (listOfDraftsInput[i].sku === singleCurrentDraftValue.sku) {//When Key (sku) is found, do:
                    foundInList=true;
                    newCurrentDraftValue['sku'] = singleCurrentDraftValue.sku;
                    if (singleCurrentDraftValue["quantity"]!=null) {//this is a qty event
                        newCurrentDraftValue['quantity'] = singleCurrentDraftValue.quantity;
                        if (listOfDraftsInput[i].discount!=null) {
                            newCurrentDraftValue['discount'] = listOfDraftsInput[i].discount;
                        }
                        if (listOfDraftsInput[i].discount==null){
                            newCurrentDraftValue['discount'] = null;
                        }
                        if (listOfDraftsInput[i].price!=null) {
                            newCurrentDraftValue['price'] = listOfDraftsInput[i].price;
                        }
                        if (listOfDraftsInput[i].price==null){
                            newCurrentDraftValue['price'] = null;
                        }
                        if (listOfDraftsInput[i].lineHasError!=null){
                            newCurrentDraftValue['lineHasError'] = listOfDraftsInput[i].lineHasError;
                        }
                        if (listOfDraftsInput[i].lineHasError==null){
                            newCurrentDraftValue['lineHasError'] = "false";
                        }
                    }
                    if (singleCurrentDraftValue["discount"]!=null) {//this is a discount event
                        newCurrentDraftValue['discount'] = singleCurrentDraftValue.discount;
                        if (listOfDraftsInput[i].quantity!=null) {
                            newCurrentDraftValue['quantity'] = listOfDraftsInput[i].quantity;
                        }
                        if (listOfDraftsInput[i].quantity==null){
                            newCurrentDraftValue['quantity'] = null;
                        }
                        if (listOfDraftsInput[i].price!=null) {
                            newCurrentDraftValue['price'] = listOfDraftsInput[i].price;
                        }
                        if (listOfDraftsInput[i].price==null){
                            newCurrentDraftValue['price'] = null;
                        }
                        if (listOfDraftsInput[i].lineHasError!=null){
                            newCurrentDraftValue['lineHasError'] = listOfDraftsInput[i].lineHasError;
                        }
                        if (listOfDraftsInput[i].lineHasError==null){
                            newCurrentDraftValue['lineHasError'] = "false";
                        }
                    }
                    if (singleCurrentDraftValue["price"]!=null) {//this is a unit price event
                        newCurrentDraftValue['price'] = singleCurrentDraftValue.price;
                        if (listOfDraftsInput[i].quantity!=null) {
                            newCurrentDraftValue['quantity'] = listOfDraftsInput[i].quantity;
                        }
                        if (listOfDraftsInput[i].quantity==null){
                            newCurrentDraftValue['quantity'] = null;
                        }
                        if (listOfDraftsInput[i].discount!=null) {
                            newCurrentDraftValue['discount'] = listOfDraftsInput[i].discount;
                        }
                        if (listOfDraftsInput[i].discount==null){
                            newCurrentDraftValue['discount'] = null;
                        }
                        if (listOfDraftsInput[i].lineHasError!=null){
                            newCurrentDraftValue['lineHasError'] = listOfDraftsInput[i].lineHasError;
                        }
                        if (listOfDraftsInput[i].lineHasError==null){
                            newCurrentDraftValue['lineHasError'] = "false";
                        }
                    }
                    listOfDraftsInput.splice(i,1);//Remove from list
                    this.listOfDrafts.push(newCurrentDraftValue); //update the new one
                }
            }
            if(foundInList==false){
                this.listOfDrafts.push(singleCurrentDraftValue);
            }
            console.log("listOfDrafts"+JSON.stringify(this.listOfDrafts));
        }
    }

    calculateProductsPricing(drafts){//we are alwys runing on all draft valus to auto calculate cases where a line hold an error, and the other isn't, when the error will removed, all the lines will be calculated and will show numbers
        this.totalList=0;
        this.totalNet=0;
        drafts.forEach(draftVal => {
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
         });

    }

    validateError(listOfDraftsToValidate) {
        this.validateSubmit=false;

        //First, sreset current status of all draft values
        listOfDraftsToValidate.forEach(resetError => {
            JSON.stringify(resetError.lineHasError="false");
          });
             this.tableErrors = {};
             this.tableErrors.rows = {};
                 listOfDraftsToValidate.forEach(draftVal => {
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
                            if (draftVal.sku.includes('CORE')==false && draftVal.discount==="" && parseInt(draftVal.quantity) > parseInt(this.coreProductQt)) {
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
                 });     
                }

                handleSubmit(){
                    this.isLoading=true;
                    if (this.validateSubmit==true || this.totalList==0) {
                        this.showSubmitModal=true;
                        this.isLoading=false;
                    }
                    if(this.validateSubmit==false && this.totalList>0){
                        this.isLoading=true;
                        this.productsToInsert=[];
                        //Get relevant products
                        this.data.forEach(singleProd => {
                            if(singleProd.total>0){
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
                                this.validateSubmit==true
                            }); 
                        }
                    }
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
            }