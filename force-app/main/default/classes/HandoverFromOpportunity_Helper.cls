public without sharing class HandoverFromOpportunity_Helper {
  public class fieldMappingWrapper { //used to create the auto mapped fields and values
    @AuraEnabled
    public String fieldName;
    @AuraEnabled
    public Object fieldValue;
    public fieldMappingWrapper(String fieldName, Object fieldValue) {
      this.fieldName = fieldName;
      this.fieldValue = fieldValue;
    }
  }

  @AuraEnabled(cacheable=true)
  public static List<Object> getUseCasePLV() {
    try {
      return Utils.buildPickListOptionsBySchema(
        Schema.Handover__c.getSObjectType(),
        Schema.Handover__c.Main_Solution__c,
        false
      );
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
  //used seperate methods for getting picklist values (getUseCasePLV and getComplexityPLV) because buildPickListOptionsBySchema didn't work with dynamic value for the field name
  @AuraEnabled(cacheable=true)
  public static List<Object> getComplexityPLV() {
    try {
      return Utils.buildPickListOptionsBySchema(
        Schema.Handover__c.getSObjectType(),
        Schema.Handover__c.Client_Complexity__c,
        false
      );
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled(cacheable=true)
  public static List<Object> getHandoverFieldMapping(Id oppId) {
    //used for auto-mapped fields, will 1. pull the field mapping from the CMT and 2. fill the value for each field
    try {
      List<Handover_Field_Mapping__mdt> fieldMapping = [
        SELECT Field_API_Name_on_Handover__c, Field_API_Name_on_Opportunity__c
        FROM Handover_Field_Mapping__mdt
      ];
      String soqlFields = '';
      for (Handover_Field_Mapping__mdt fm : fieldMapping) {
        soqlFields += soqlFields == ''
          ? fm.Field_API_Name_on_Opportunity__c
          : ',' + fm.Field_API_Name_on_Opportunity__c;
      }
      String query =
        'SELECT ' +
        soqlFields +
        ' FROM Opportunity WHERE Id=\'' +
        oppId +
        '\' ';
      Opportunity opp = Database.query(query);
      List<Object> fieldsWithValues = new List<Object>(); //list that holds a key-value for each relevant field, didn't use map to easly access the values in JS
      for (Handover_Field_Mapping__mdt fm : fieldMapping) {
        fieldsWithValues.add(
          new fieldMappingWrapper(
            fm.Field_API_Name_on_Handover__c,
            opp.get(fm.Field_API_Name_on_Opportunity__c)
          )
        );
      }
      return fieldsWithValues;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled(cacheable=true)
  public static Map<String,Object> getObHoursMap(Id oppId) {
    try{
      Map<String,Object> hoursMap = new Map<String,Object>();
      Decimal support = 0;
      Decimal adv = 0;
      Decimal add_adv = 0;
      for(OpportunityLineItem oli: [SELECT Id, Product2.Name, PS_Hours__c FROM OpportunityLineItem WHERE Is_Primary__c = true and OpportunityId =: oppId and Product_Type__c = 'Onboarding' and Product2.Name != null]){
        if(oli.Product2.Name.containsIgnoreCase('Support')){
          support += oli.PS_Hours__c;
        } else if(oli.Product2.Name.containsIgnoreCase('Advanced Onboarding Hours') || oli.Product2.Name.containsIgnoreCase('Advanced Onboarding Package')){
          adv += oli.PS_Hours__c;
        } else if(oli.Product2.Name.containsIgnoreCase('Additional Advanced Onboarding Hours')){
          add_adv += oli.PS_Hours__c;
        }
      }
      hoursMap.put('support',support);
      hoursMap.put('adv',adv);
      hoursMap.put('add_adv',add_adv);
      return hoursMap;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static Map<String, Object> createRecords(
    Map<String, List<Map<String, Object>>> recordsMap
  ) {
    try {
      List<SObject> recordsToCreate = new List<SObject>(); //used sobject to allow adding additional objects to create in a single call, in case will be needed in the future
      Map<String, Object> createdRecordsMap = new Map<String, Object>(); //allows sending values back to the frontend, for example an id of a record that was created
      if (recordsMap.get('use_cases') != null) {
        //use cases creation
        List<Map<String, Object>> useCasesToCreate = recordsMap.get(
          'use_cases'
        );
        for (Map<String, Object> ucMap : useCasesToCreate) {
          recordsToCreate.add(
            new Use_Case__c(
              Use_Case_Type__c = (String) ucMap.get('name'),
              Client_Complexity__c = (String) ucMap.get('complex'),
              Estimated_Number_of_Users__c = Double.valueOf(ucMap.get('users')),
              Description__c = (String) ucMap.get('desc'),
              Main_Use_Case__c = (Boolean) ucMap.get('main'),
              Handover__c = (Id) ucMap.get('handoverId')
            )
          );
        }
      }
      insert recordsToCreate;
      return createdRecordsMap;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled(cacheable=true)
  public static List<QuoteLineItem> getCurrentQuoteLineItems(Id quoteId) {
    return [
      SELECT
        Product_Identifier_SKU__c,
        Net_Per_Unit__c,
        Seats__c,
        Discount,
        DealHub_Net_Price__c,
        List_Price__c,
        CurrencyIsoCode,
        Product_Type__c,
        Product_Name__c
      FROM QuoteLineItem
      WHERE quoteid = :quoteId
    ];
  }

  @AuraEnabled(cacheable=true)
  public static Id getExistingHandoverOnOpp(Id oppId) {
    try {
      return [
        SELECT Id
        FROM Handover__c
        WHERE Opportunity__c = :oppId
        ORDER BY CreatedDate DESC
        LIMIT 1
      ]
      ?.Id;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled(cacheable=true)
  public static string getContactNameById(Id contactId) {
    try {
      return [SELECT Name FROM Contact WHERE Id = :contactId]?.Name;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}