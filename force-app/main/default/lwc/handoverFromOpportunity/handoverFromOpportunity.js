import { LightningElement, api, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { CloseActionScreenEvent } from "lightning/actions";
import { NavigationMixin } from "lightning/navigation";
import { reduceErrors } from "c/ldsUtils";
import { refreshApex } from "@salesforce/apex";
import silverMedal from '@salesforce/resourceUrl/silverMedal';
import goldMedal from '@salesforce/resourceUrl/goldMedal';
import bronzeMedal from '@salesforce/resourceUrl/bronzeMedal';
import getUseCasePLV from "@salesforce/apex/HandoverFromOpportunity_Helper.getUseCasePLV";
import getComplexityPLV from "@salesforce/apex/HandoverFromOpportunity_Helper.getComplexityPLV";
import getHandoverFieldMapping from "@salesforce/apex/HandoverFromOpportunity_Helper.getHandoverFieldMapping";
import getCurrentQuoteLineItems from "@salesforce/apex/HandoverFromOpportunity_Helper.getCurrentQuoteLineItems";
import getObHoursMap from "@salesforce/apex/HandoverFromOpportunity_Helper.getObHoursMap";
import getContactNameById from "@salesforce/apex/HandoverFromOpportunity_Helper.getContactNameById";
import getExistingHandoverOnOpp from "@salesforce/apex/HandoverFromOpportunity_Helper.getExistingHandoverOnOpp";
import createRecordsApex from "@salesforce/apex/HandoverFromOpportunity_Helper.createRecords";
import COMPANY_ID from "@salesforce/schema/Opportunity.Company__c";
import ACCOUNT_ID from "@salesforce/schema/Opportunity.AccountId";
import NUM_OF_EMPLOYEES from "@salesforce/schema/Opportunity.Company_Employees__c";
import CONTACT_ID from "@salesforce/schema/Opportunity.ContactId";
import DH_SIGNER_ID from "@salesforce/schema/Opportunity.SyncedQuote.DH_Signer__c";
import DH_SIGNER_NAME from "@salesforce/schema/Opportunity.SyncedQuote.DH_Signer__r.Name";
import SYNCED_QUOTE_ID from "@salesforce/schema/Opportunity.SyncedQuoteId";
import COMMERCIAL_COMMENTS from "@salesforce/schema/Opportunity.SyncedQuote.Commercial_Comments__c";
import OPT_OUT_DAYS from "@salesforce/schema/Opportunity.SyncedQuote.Opt_Out__c";
import ADDENDUM_TO_SO from "@salesforce/schema/Opportunity.SyncedQuote.Addendum_to_SO__c";
import KIND_OF_CSM from "@salesforce/schema/Opportunity.SyncedQuote.CSM_Package__c";
import EXPECTED_TIER from "@salesforce/schema/Opportunity.Expected_Plan_Tier__c";
import SALES_USE_CASES from "@salesforce/schema/Opportunity.Use_Cases_PL__c";
import THRESHOLD_PASS_AM from "@salesforce/schema/Opportunity.Passed_AM_Threshold__c";
import THRESHOLD_PASS_CSM from "@salesforce/schema/Opportunity.Passed_CSM_Threshold__c";
import THRESHOLD_PASS_OB from "@salesforce/schema/Opportunity.Passed_Onboarding_Threshold__c";
import LEGAL_AGREEMENT_TYPE from "@salesforce/schema/Opportunity.SyncedQuote.Legal_Agreement_Type__c";
import ACCOUNT_CSM_FULLNAME from "@salesforce/schema/Opportunity.CSM_Name_Formula__c";

const oppFields = [
  COMPANY_ID,
  ACCOUNT_ID,
  CONTACT_ID,
  NUM_OF_EMPLOYEES,
  THRESHOLD_PASS_AM,
  THRESHOLD_PASS_CSM,
  THRESHOLD_PASS_OB,
  DH_SIGNER_ID,
  DH_SIGNER_NAME,
  SYNCED_QUOTE_ID,
  COMMERCIAL_COMMENTS,
  ADDENDUM_TO_SO,
  LEGAL_AGREEMENT_TYPE,
  KIND_OF_CSM,
  EXPECTED_TIER,
  SALES_USE_CASES,
  OPT_OUT_DAYS,
  ACCOUNT_CSM_FULLNAME
];

export default class HandoverFromOpportunity extends NavigationMixin(
  LightningElement
) {
  @api recordId;
  @api context = "Manual Creation";
  expendedFields = {};
  silverMedalIcon = silverMedal;
  goldMedalIcon = goldMedal;
  bronzeMedalIcon = bronzeMedal;
  oppData;
  companyId;
  accountId;
  quoteId;
  commercialComments = "";
  legalAgreementType = "None";
  addendumToSo = "None";
  kindOfCsm = "";
  kindOfIc = "";
  numberOfEmployees;
  optOutDays;
  securityReviewValue;
  activeSections = ["A", "B", "C", "D", "E", "F", "G"];
  isLoading = true;
  loadCustomSearch = false;
  modalHeader = "Create Handover";
  customError;
  error;
  showAmFields;
  showCsmFields;
  showObFields;
  showAdditionalUseCases = false;
  showOtherIntegration = false;
  showLanguageChoice = false;
  lockThresholds = false;
  hideSubmitButton = false;
  contactFieldsToCreate = ["Email", "FirstName", "LastName", "Title", "Phone"];
  obContactId;
  businessContactId;
  businessContactName;
  signatoryContactId;
  signatoryContactName;
  desicionContactId;
  isCreateNewObContact = false;
  isKeepAccount = false;
  isUrgent = false;
  isTalkedGrowth = false;
  isAdditionalUseCases = false;
  isPoc = false;
  useCases;
  additionalUseCases;
  integrationsChosen;
  complexityOptions;
  fieldMappings;
  recordsToCreateBefore = {};
  recordsToCreateAfter = {};
  newHandoverId;
  mappingErrorJson = {};
  fieldsDraftValues;
  fieldsToExcludeFromInputValidation = ["integrations", "commercial_comments"];
  hasExistingHandover = false;
  existingHandoverId;
  linkToExistingHO;
  csmFullName;

  productsData = [
    {
      productName: "CRM",
      productCode: "CRM",
      quantity: 0,
      ppu: 0,
      total: 0,
      currency: "",
      status: "Not Relevant",
      fieldName: "Sales_CRM__c",
      isLocked: false
    },
    {
      productName: "Marketers",
      productCode: "MKT",
      quantity: 0,
      ppu: 0,
      total: 0,
      currency: "",
      status: "Not Relevant",
      fieldName: "Marketing_Creative__c",
      isLocked: false
    },
    {
      productName: "Projects",
      productCode: "PROJ",
      quantity: 0,
      ppu: 0,
      total: 0,
      currency: "",
      status: "Not Relevant",
      fieldName: "Project_Management__c",
      isLocked: false
    },
    {
      productName: "Dev",
      productCode: "SOFT",
      quantity: 0,
      ppu: 0,
      total: 0,
      currency: "",
      status: "Not Relevant",
      fieldName: "Software_Developement__c",
      isLocked: false
    }
  ];
  get isEnterprise() {
    return this.numberOfEmployees > 1500;
  }
  get csmBadgeClass() {
    if (this.kindOfCsm) {
      if (this.kindOfCsm.includes("Gold")) return "csm_badge_gold";
      if (this.kindOfCsm.includes("Silver")) return "csm_badge_silver";
      if (this.kindOfCsm.includes("Bronze")) return "csm_badge_bronze";
    } else return;
  }

  get showSilverMedal(){
    if (this.kindOfCsm) {
      return this.kindOfCsm.includes("Silver");
    } else return;
  }

  get showGoldMedal(){
    if (this.kindOfCsm) {
      return this.kindOfCsm.includes("Gold");
    } else return;
  }

  get showBronzeMedal(){
    if (this.kindOfCsm) {
      return this.kindOfCsm.includes("Bronze");
    } else return;
  }

  get extendedOptOutDays() {
    if (this.optOutDays > 30) return true;
    else return false;
  }
  get optOutHelpText() {
    return `According to the signed SO, the customer has a ${this.optOutDays} opt out days. Please elaborate below on why the customer got this opt out window`;
  }
  get isHandoverNeeded() {
    return this.showAmFields || this.showCsmFields || this.showObFields;
  }
  get showSecurityReviewType() {
    return (
      this.securityReviewValue == "Required" ||
      this.securityReviewValue == "In Review" ||
      this.securityReviewValue == "Done"
    );
  }
  get onboardingTitle() {
    if (this.showObFields) {
      return `${this.kindOfIc} Services`;
    } else {
      return "Implementation Consulting";
    }
  }
  get showCsmOrObFields() {
    return this.showCsmFields || this.showObFields;
  }
  
  connectedCallback() {
    this.lockThresholds = this.context === "Close Process" ? true : false; //thresholds can only be tuned when running from manual context
    this.hideSubmitButton = this.context === "Close Process" ? true : false; //when ran from close process the submit will be done with the "Next" button of the component
  }

  @wire(getRecord, { recordId: "$recordId", fields: oppFields })
  wiredOpp({ data, error }) {
    if (data) {
      this.oppData = data;
      this.showAmFields = getFieldValue(data, THRESHOLD_PASS_AM);
      this.showCsmFields = getFieldValue(data, THRESHOLD_PASS_CSM);
      this.csmFullName = getFieldValue(data, ACCOUNT_CSM_FULLNAME);
      this.showObFields = getFieldValue(data, THRESHOLD_PASS_OB);
      this.isLoading = false;
      this.companyId = getFieldValue(data, COMPANY_ID);
      this.accountId = getFieldValue(data, ACCOUNT_ID);
      this.businessContactId = getFieldValue(data, CONTACT_ID);
      this.quoteId = getFieldValue(data, SYNCED_QUOTE_ID);
      if (this.quoteId) {
        this.commercialComments = getFieldValue(data, COMMERCIAL_COMMENTS);
        if (this.commercialComments)
          this.commercialComments = this.commercialComments.replace(
            /<[^>]*>?/gm,
            ""
          );
        this.addendumToSo = getFieldValue(data, ADDENDUM_TO_SO);
        this.legalAgreementType = getFieldValue(data, LEGAL_AGREEMENT_TYPE);
        this.kindOfCsm = getFieldValue(data, KIND_OF_CSM);
        this.signatoryContactId = getFieldValue(data, DH_SIGNER_ID);
        this.optOutDays = getFieldValue(data, OPT_OUT_DAYS);
        if (this.signatoryContactId) {
          this.signatoryContactName = getFieldValue(data, DH_SIGNER_NAME);
        }
      } else {
        this.isLoadingProducts = false;
      }
      this.numberOfEmployees = getFieldValue(data, NUM_OF_EMPLOYEES);
      if (this.businessContactId) {
        getContactNameById({ contactId: this.businessContactId })
          .then((data) => {
            this.businessContactName = data;
          })
          .catch((err) => {
            console.error(reduceErrors(err));
          })
          .finally(() => {
            if (
              (this.signatoryContactId && this.signatoryContactName) ||
              !this.signatoryContactId
            ) {
              this.loadCustomSearch = true;
            }
          });
      }
      if (
        !this.businessContactId ||
        (this.businessContactId && this.businessContactName)
      ) {
        this.loadCustomSearch = true;
      }
    } else if (error) {
      console.error(reduceErrors(error));
      this.isLoading = false;
    }
  }

  @wire(getUseCasePLV)
  wiredUseCaseValues({ error, data }) {
    if (data) {
      this.useCases = data;
    }
    if (error) {
      console.error(reduceErrors(error));
    }
  }

  @wire(getExistingHandoverOnOpp, { oppId: "$recordId" })
  wiredExistingHOs({ error, data }) {
    if (data) {
      try {
        this.hasExistingHandover = true;
        this.existingHandoverId = data;
        this.linkToExistingHO = "/" + this.existingHandoverId;
        console.log(
          `getExistingHandoverOnOpp found existing handover, id is: ${this.existingHandoverId}`
        );
        const indicateOnExistingToParent = new CustomEvent("foundexisting");
        this.dispatchEvent(indicateOnExistingToParent);
      } catch (e) {
        console.error(reduceErrors(e));
      }
    }
    if (error) {
      console.error(reduceErrors(error));
    }
  }

  @wire(getComplexityPLV)
  wiredComplexityValues({ error, data }) {
    if (data) {
      this.complexityOptions = data;
    }
    if (error) {
      console.error(reduceErrors(error));
    }
  }

  @wire(getHandoverFieldMapping, { oppId: "$recordId" })
  wiredFieldMapping({ error, data }) {
    if (data) {
      this.fieldMappings = data;
    }
    if (error) {
      console.error(reduceErrors(error));
    }
  }
  @wire(getCurrentQuoteLineItems, { quoteId: "$quoteId" })
  currentQLIs({ error, data }) {
    this.isLoading = true;
    if (data) {
      console.log("getCurrentQuoteLineItems products: " + JSON.stringify(data));
      data.forEach((lineItem) => {
        if (lineItem.Seats__c) {
          try {
            let currProductName =
              lineItem.Product_Identifier_SKU__c.split("-")[0];
            if (
              this.productsData.find(
                (line) => line.productCode === currProductName
              )
            ) {
              this.productsData.find(
                (line) => line.productCode === currProductName
              ).quantity = lineItem.Seats__c;
              this.productsData.find(
                (line) => line.productCode === currProductName
              ).ppu = lineItem.Net_Per_Unit__c;
              this.productsData.find(
                (line) => line.productCode === currProductName
              ).total = lineItem.DealHub_Net_Price__c;
              this.productsData.find(
                (line) => line.productCode === currProductName
              ).currency = lineItem.CurrencyIsoCode;
              this.productsData.find(
                (line) => line.productCode === currProductName
              ).status = "Monday Product Purchased";
              this.productsData.find(
                (line) => line.productCode === currProductName
              ).isLocked = true;
            }
          } catch (e) {
            console.error(reduceErrors(error));
            this.isLoadingProducts = false;
          }
        }
        if (lineItem.Product_Type__c === "Professional Services") {
          this.kindOfIc = "Professional";
        }
        if (
          lineItem.Product_Type__c === "Onboarding" &&
          this.kindOfIc != "Professional"
        ) {
          this.kindOfIc = "Onboarding";
        }
      });
      if (this.kindOfIc === "") this.kindOfIc = "Onboarding / Professional";
      this.isLoading = false;
    }
    if (error) {
      console.error(reduceErrors(error));
    }
  }
  expandAllSections() {
    this.activeSections = ["A", "B", "C", "D", "E", "F", "G"];
  }
  handleKeepChange(event) {
    this.isKeepAccount = event.target.checked;
  }
  handleUrgentAssignment(event) {
    this.isUrgent = event.target.checked;
  }
  handleTalkedGrowth(event) {
    this.isTalkedGrowth = event.target.checked;
  }
  handleAmNeededChange(event) {
    this.showAmFields = event.target.checked;
    this.expandAllSections();
  }
  handleCsmNeededChange(event) {
    this.showCsmFields = event.target.checked;
  }
  handleObNeededChange(event) {
    this.showObFields = event.target.checked;
  }
  handlePocChange(event) {
    this.isPoc = event.target.checked;
  }
  handleSecurityReviewChange(event) {
    this.securityReviewValue = event.detail.value;
  }
  handleContactLookupChange(event) {
    if (event.detail.data.recordId) {
      if (event.target.name === "business-poc") {
        this.businessContactId = event.detail.data.recordId;
      }
      if (event.target.name === "signatory-poc") {
        this.signatoryContactId = event.detail.data.recordId;
      }
      if (event.target.name === "desicion-poc") {
        this.desicionContactId = event.detail.data.recordId;
      }
      if (event.target.name === "onboarding-poc") {
        this.obContactId = event.detail.data.recordId;
      }
    }
  }
  handleAdditionalUseCasesToggle(event) {
    this.isAdditionalUseCases = event.target.checked;
    if (!this.isAdditionalUseCases) {
      this.showAdditionalUseCases = false;
    }
  }
  handleAdditionalUseCaseChange(event) {
    this.additionalUseCases = event.detail.value;
    this.showAdditionalUseCases = this.additionalUseCases.length > 0;
  }
  handleIntegrationsChange(event) {
    this.integrationsChosen = event.detail.value;
    this.showOtherIntegration = this.integrationsChosen.includes("Other");
  }
  handleLanguageNeeded(event) {
    this.showLanguageChoice = event.target.checked;
  }
  validateInputs() {
    if (this.context === "Close Process") {
      console.log("entered validateInputs from Close Process");
      //logic to validate required fields
      let inputValid = [
        ...this.template.querySelectorAll("lightning-input")
      ].reduce((val, inp) => {
        inp.reportValidity();
        return val && inp.checkValidity();
      }, true);
      // note: checkValidity is not avaiable for lightning-input-field!!!
      let inputFieldsValid = true;
      this.template
        .querySelectorAll("lightning-input-field")
        .forEach((element) => {
          if (
            !element.value &&
            !this.fieldsToExcludeFromInputValidation.includes(element.name)
          ) {
            console.log(
              `entered validateInputs from Close Process - found missing field ${JSON.stringify(
                element
              )}`
            );
            inputFieldsValid = false;
          }
          element.reportValidity();
        });
      console.log(
        "entered validateInputs from Close Process - passed lightning-input validations, inputFieldsValid: " +
          inputFieldsValid
      );
      if (!inputValid || !inputFieldsValid) {
        this.customError = "Some required fields seems to be missing";
        console.log(
          "entered validateInputs from Close Process - setting custom error and returning false"
        );
        return false;
      } else {
        console.log(
          "entered validateInputs from Close Process - passed and returning true"
        );
        return true;
      }
    }
    if (this.businessContactId === undefined) {
      this.customError = "Please choose a business contact for this handover";
      return false;
    }
    if (this.signatoryContactId === undefined) {
      this.customError = "Please choose a signatory contact for this handover";
      return false;
    }
    if (this.desicionContactId === undefined) {
      this.customError =
        "Please choose a desicion maker contact for this handover";
      return false;
    }
    if (this.showObFields && this.obContactId === undefined) {
      this.customError =
        "Please choose an onboarding contact for this handover";
      return false;
    }
    return true;
  }
  @api
  handleSubmit(event) {
    try {
      if (!this.hideSubmitButton) event.preventDefault(); //when the submit is done from the parent component there is no "event" payload, that's also why we are using the query selector to get the form values instead of using event.value
      if (this.validateInputs()) {
        this.isLoading = true;
        const fields = {};
        this.template
          .querySelectorAll("lightning-input-field")
          .forEach((element) => {
            fields[element.fieldName] = element.value;
          });
        this.expendedFields = fields;
        this.updateAutoMapping();
        console.log('this.obHours_map'+this.obHours_map);
        this.updateObHours();
        this.updateUserInputs();
        this.handleUseCasesToCreate(); //create a draft of the use cases, will only be submitted later on with "createRecords" to save loading time in the close process
        if (Object.keys(this.mappingErrorJson).length > 0) {
          this.updateErrors();
        }
        this.template
          .querySelector("lightning-record-edit-form")
          .submit(this.expendedFields);
      } else {
        console.log("entered handleSubmit - invalid inputs");
        this.showToast("Hold on", this.customError);
        this.expandAllSections();
      }
    } catch (e) {
      console.error(reduceErrors(e));
      this.isLoading = false;
    }
  }

  @wire(getObHoursMap, { oppId: "$recordId" })
  oBHoursMap({ error, data }) {
    if (data) {
      console.log("oBHoursMap: " + JSON.stringify(data));
      this.obHours_map = data;
    }
    if (error) {
      console.log("oBHoursMap error");
      console.error(reduceErrors(error));
    }
  }

  updateObHours(){
    this.expendedFields.Onboarding_Support_Hours__c = this.obHours_map.support;
    this.expendedFields.Onboarding_Advanced_Hours__c = this.obHours_map.adv;
    this.expendedFields.Onboarding_Advanced_Additional_Hours__c = this.obHours_map.add_adv;
  }

  updateUserInputs() {
    try {
      this.expendedFields.Source__c =
        this.context === "Close Process" ? "Close Process" : "Manual Creation";
      //section A
      this.expendedFields.Onboarding_Project_Required__c = this.showObFields
        ? "Yes"
        : "No";
      this.expendedFields.Urgent_Assignment__c = this.template.querySelector(
        '[data-id="is_urgent"]'
      )?.checked
        ? "Yes"
        : "No";
      this.expendedFields.Involve_CSM__c = this.showCsmFields ? "Yes" : "No";
      this.expendedFields.Keep_Account_Request__c = this.isKeepAccount;
      // section B
      this.expendedFields.Commercial_Comments__c = this.template.querySelector(
        '[data-id="commercial_comments"]'
      )?.value;
      this.expendedFields.Addendum_to_SO__c = this.addendumToSo;
      this.expendedFields.Legal_Agreement_Type__c = this.legalAgreementType;
      this.expendedFields.Is_this_a_POC__c =
        this.template.querySelector('[data-id="is_poc"]')?.checked;
      // section C
      this.expendedFields.Business_Point_of_Contact__c = this.businessContactId;
      this.expendedFields.Signatory_Contact__c = this.signatoryContactId;
      this.expendedFields.Decision_Maker__c = this.desicionContactId;
      if (this.obContactId)
        this.expendedFields.Onboarding_Main_Point_of_Contact__c =
          this.obContactId;
      // section D
      this.expendedFields.Short_Term_Growth__c = this.template.querySelector(
        '[data-id="short-term-growth"]'
      )?.value;
      this.expendedFields.Long_Term_Growth__c = this.template.querySelector(
        '[data-id="long-term-growth"]'
      )?.value;
      // section E
      this.expendedFields.Main_Solution__c = this.template.querySelector(
        '[data-id="pri-uc-name"]'
      )?.value;
      // section F
      this.expendedFields.Customer_asked_Language_Speaker_c__c =
        this.template.querySelector('[data-id="asked_lang"]')?.checked;
      this.expendedFields.Multiple_time_zones_support_required__c =
        this.template.querySelector('[data-id="asked_time_zone"]')?.checked;
    } catch (error) {
      console.error(reduceErrors(error));
      this.mappingErrorJson["User Inputs"] = JSON.stringify(
        reduceErrors(error)
      );
    }
  }
  updateAutoMapping() {
    try {
      var tempFields = this.expendedFields;
      this.fieldMappings.forEach(function (fm) {
        tempFields[fm.fieldName] = fm.fieldValue;
      });
      this.expendedFields = tempFields;
    } catch (error) {
      console.error(reduceErrors(error));
      this.mappingErrorJson["Auto Mapping"] = JSON.stringify(
        reduceErrors(error)
      );
    }
  }
  updateErrors() {
    try {
      this.expendedFields.Creation_Error_Content__c = JSON.stringify(
        this.mappingErrorJson
      );
      var userInputs = {};
      this.template
        .querySelectorAll(
          "lightning-input, lightning-slider, lightning-textarea, lightning-combobox"
        )
        .forEach((element) => {
          if (element.value) userInputs[element.label] = element.value;
          if (element.checked) userInputs[element.label] = element.checked;
        });
      this.template
        .querySelectorAll("c-search-component")
        .forEach((element) => {
          if (element.value) userInputs[element.name] = element.data.recordId;
        });
      this.expendedFields.Creation_Error_User_Inputs__c =
        JSON.stringify(userInputs);
    } catch (error) {
      console.error(reduceErrors(error));
    }
  }
  handleUseCasesToCreate() {
    //the list of all use cases to create, will always have the main use case and will always be called after the handover is created to have lookup between the use case to the handover
    let useCasesObjList = [];
    let primaryUseCaseJson = {
      name: this.template.querySelector('[data-id="pri-uc-name"]').value,
      complex: this.template.querySelector('[data-id="pri-uc-complex"]').value,
      users: this.template.querySelector('[data-id="pri-uc-users"]').value,
      desc: this.template.querySelector('[data-id="pri-uc-desc"]').value,
      main: true,
      handoverId: ""
    };
    useCasesObjList.push(primaryUseCaseJson);
    if (this.showAdditionalUseCases) {
      //creation and complexity
      this.template
        .querySelectorAll(".add-use-cases-complex")
        .forEach((ucAtt) => {
          let addUseCaseJson = {
            name: ucAtt.name,
            handoverId: "",
            main: false,
            complex: ucAtt.value
          };
          useCasesObjList.push(addUseCaseJson);
        });
      //add description for each use case
      this.template.querySelectorAll(".add-use-cases-desc").forEach((ucAtt) => {
        useCasesObjList.find((uc) => uc.name === ucAtt.name)["desc"] =
          ucAtt.value;
      });
      //add number of users for each use case
      this.template
        .querySelectorAll(".add-use-cases-users")
        .forEach((ucAtt) => {
          useCasesObjList.find((uc) => uc.name === ucAtt.name)["users"] =
            ucAtt.value;
        });
    }
    this.recordsToCreateAfter["use_cases"] = useCasesObjList;
  }
  addHandoverIdToUseCases() {
    console.log("entered addHandoverIdToUseCases");
    if (this.newHandoverId) {
      this.recordsToCreateAfter.use_cases?.forEach((uc) => {
        uc.handoverId = this.newHandoverId;
      });
    }
  }
  createRecords(recordsToCreate) {
    if (Object.keys(recordsToCreate).length > 0) {
      try {
        const result = createRecordsApex({ recordsMap: recordsToCreate });
      } catch (error) {
        this.isLoading = false;
        console.error(reduceErrors(error));
      }
    }
  }
  showToast(theTitle, theMessage) {
    const event = new ShowToastEvent({
      title: theTitle,
      message: theMessage,
      variant: "error"
    });
    this.dispatchEvent(event);
  }
  handleCancel() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }
  handleError(event) {
    let message = event.detail.detail;
    this.showToast("Failed to create handover", message);
    if (this.context === "Close Process") {
      const errorEventToParent = new CustomEvent("hoerror", {
        detail: message
      });
      this.dispatchEvent(errorEventToParent);
    }
  }
  handleSuccess(event) {
    try {
      this.newHandoverId = event.detail.id;
      const successEventToParent = new CustomEvent("hosuccess", {
        detail: event.detail
      });
      this.dispatchEvent(successEventToParent);
      if (this.context != "Close Process") {
        //success toast
        const newHandoverName = event.detail.fields.Name.value;
        this[NavigationMixin.GenerateUrl]({
          type: "standard__recordPage",
          attributes: {
            recordId: this.newHandoverId,
            actionName: "view"
          }
        }).then((url) => {
          const event = new ShowToastEvent({
            variant: "success",
            title: "Success!",
            message: "Handover {0} created! See it {1}!",
            messageData: [
              newHandoverName,
              {
                url,
                label: "here"
              }
            ]
          });
          this.dispatchEvent(event);
        });
      }
    } catch (error) {
      console.error(reduceErrors(error));
    } finally {
      this.isLoading = false;
      refreshApex(this.wiredExistingHOs);
    }
    //create use cases, happens after the close process is completed to save loading time
    try {
      this.addHandoverIdToUseCases();
      this.createRecords(this.recordsToCreateAfter);
    } catch (error) {
      console.log(
        "error creating use cases: " + JSON.stringify(this.recordsToCreateAfter)
      );
      console.error(reduceErrors(error));
    }
  }
}
