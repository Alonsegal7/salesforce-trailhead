/**
@name: LeanDataCustomInterface
@Author: Kurt Jurgens from LeanData - kurt@leandata.com - support@leandata.com
@Created: 06-April-2022
@Description:  LeanData specific custom interface class to augment LeanData's 
out of the box product with additional functionality using global methods to override out of the box methods
@Version 1.0
**/
global with sharing class LeanDataCustomInterface extends LeanData.CustomInterface {
    //this class is initiated once per "batch slice"
    //the size of the batch slice is determined by LeanData's multi-ccio value, default is 5 as of March 2022, currently set in production at 15 as of Sep 2022

    String setSpecificAvailabilityCustomCapping = 'Set Specific Availability - Custom Capping';
    String updateCappingTotals = 'Update Capping Totals';
    Map<String, SObject> userToObjectMap;
    Set<Id> partnerRegionIdsToUpdate, leadQuotaIdsToUpdate, rrsWithConflictUsers, rrsWithConflictPartner;
    List<Partner_Region__c> partnerRegions, partnerRegionsToUpdate;
    List<Lead_Quota__c> leadQuotas, leadQuotasToUpdate;
    Map<String, Partner_Region__c> partnerRegionQuotaMap;
    Map<Id, Partner_Region__c> partnerRegionIdMap;
    Map<Id, Lead_Quota__c> leadQuotaMap;
    Map<Id, Lead_Quota__c> leadQuotaIdMap;

    //Definition of node types selectable in LeanData
    global override Map<String, List<String>> getMapOfCustomInterfaceNodeNamesToEdges(){
        Map<String, List<String>> customInterfaceMap = new Map<String, List<String>>();
        
        customInterfaceMap.put(setSpecificAvailabilityCustomCapping, new List<String>{'Next Node', 'False'});
        customInterfaceMap.put(updateCappingTotals, new List<String>{'Next Node', 'False'});

        return customInterfaceMap;
    }

    global override Set<String> getCustomLeadFields() {
    // fields that we are accessing on any Lead object.  These fields will be fetched in SOSL & SOQL queries
        return new Set<String> {'Partner_Company__c', 'Country'};
    }

    global override String customRoutingRule(SObject primary, Map<String, SObject> chosenSObjects, String parameter, Map<String, Object> additionalParameters) {
		Lead primaryLead;

		if(primary.getSObjectType() == Lead.sObjectType){
			primaryLead = (Lead) primary;
		}

		if(primaryLead != null && parameter == setSpecificAvailabilityCustomCapping){
			return 'Next Node';
		} else if(primaryLead != null && parameter == 'Update Capping Totals'){
			//Reset Setup Start
			//reset all data structures per batch slice
			if(userToObjectMap == null) userToObjectMap = new Map<String, SObject>();
			if(partnerRegionsToUpdate == null) partnerRegionsToUpdate = new List<Partner_Region__c>();
			if(partnerRegionQuotaMap == null) partnerRegionQuotaMap = new Map<String, Partner_Region__c>();
			if(leadQuotaMap == null) leadQuotaMap = new Map<Id, Lead_Quota__c>();
			if(leadQuotasToUpdate == null) leadQuotasToUpdate = new List<Lead_Quota__c>();
			if(rrsWithConflictUsers == null) rrsWithConflictUsers = new Set<Id>();
			if(rrsWithConflictPartner == null) rrsWithConflictPartner = new Set<Id>();
			if(partnerRegionIdsToUpdate == null) partnerRegionIdsToUpdate = new Set<Id>();
			if(leadQuotaIdsToUpdate == null) leadQuotaIdsToUpdate = new Set<Id>();
			if(partnerRegionIdMap == null) partnerRegionIdMap = new Map<Id, Partner_Region__c>();
			if(leadQuotaIdMap == null) leadQuotaIdMap = new Map<Id, Lead_Quota__c>();

			//SOQL once per batch slice
			if(partnerRegions == null){
				partnerRegions = [SELECT Id, Name, Partner_Company__c, Country__c, Main_User__c, Daily_Leads_Quota__c, Current_Daily_Leads_Quota__c, Main_User_Email__c, Partner_Country_Quota__c, Current_Country_Daily_Quota__c, Partner_Country_Quota__r.Total_Country_Cap_For_Partners__c, Country_Quota_Type__c, Partner_Company__r.Region__c FROM Partner_Region__c];
				
				for(Partner_Region__c pr : partnerRegions){
					String userPartner = (String)pr.Main_User__c + pr.Country__c;
					partnerRegionQuotaMap.put(userPartner, pr);
					partnerRegionIdMap.put(pr.Id, pr);

					userToObjectMap.put(userPartner, pr);
				}
			}

			//SOQL once per batch slice
			if(leadQuotas == null){
				leadQuotas = [SELECT Id, Current_Sign_Up_Quota__c, Sign_Up_Daily_Quota__c, Office_Region__c, User__c From Lead_Quota__c];
				for(Lead_Quota__c lq : leadQuotas){
					leadQuotaMap.put(lq.User__c, lq);
					leadQuotaIdMap.put(lq.Id, lq);
					userToObjectMap.put(lq.User__c, lq);
				}
			}

			//Update LeadQuota/Partner Region based on Recent LeanData Round Robin Start
			Id primaryLeadOwnerId = (Id) primaryLead.get('OwnerId');

			String countryISO;
			countryISO = countryMap.get((String)primaryLead.get('Country'));

			String quataKey = (String)primaryLeadOwnerId + countryISO;
			SObject relevantQuota = userToObjectMap.get(quataKey);

			if(relevantQuota == null){
				relevantQuota = userToObjectMap.get(primaryLeadOwnerId);
			}

			Boolean rechedDailyQuota = false;
			string rrsKey, currQuotaField, dailyQuotaField;
			decimal currQuotaCount;

			if(relevantQuota instanceof Partner_Region__c){
				currQuotaField = 'Current_Daily_Leads_Quota__c';
				dailyQuotaField = 'Daily_Leads_Quota__c';
			} else if(relevantQuota instanceof Lead_Quota__c){
				currQuotaField = 'Current_Sign_Up_Quota__c';
				dailyQuotaField = 'Sign_Up_Daily_Quota__c';
			}
			currQuotaCount = (Decimal)relevantQuota.get(currQuotaField);
			if(currQuotaCount != null && currQuotaCount != 0){
				relevantQuota.put(currQuotaField, currQuotaCount + 1);
			} else {
				relevantQuota.put(currQuotaField, 1);
			}
			if((Decimal)relevantQuota.get(currQuotaField) >= (Decimal)relevantQuota.get(dailyQuotaField)){
				rechedDailyQuota = true;
			}
			if(relevantQuota instanceof Partner_Region__c){
				userToObjectMap.put(quataKey, (Partner_Region__c) relevantQuota);
				partnerRegionIdsToUpdate.add((Id)relevantQuota.get('Id'));
				partnerRegionIdMap.put((Id)relevantQuota.get('Id'),(Partner_Region__c) relevantQuota);
				if(rechedDailyQuota) rrsKey = '%-'+countryISO+'-%';
			} else if(relevantQuota instanceof Lead_Quota__c){
				userToObjectMap.put(primaryLeadOwnerId, (Lead_Quota__c) relevantQuota);
				leadQuotaIdsToUpdate.add((Id)relevantQuota.get('Id'));
				leadQuotaIdMap.put((Id)relevantQuota.get('Id'),(Lead_Quota__c) relevantQuota);
			}
			///Update LeadQuota/Partner Region based on Recent LeanData Round Robin End
			
			if(rechedDailyQuota){ //update LeanData Round Robin Settings only if the quota we update is now full
				//has to be done per Lead in slice if there are new caps that get full as LeanData RR runs one record at a time
				Set<String> inactiveReasonSet = new Set<String>();
				string query_rrs = 'select Id from LeanData__Round_Robin_Setting__c where LeanData__OwnerId__c =: primaryLeadOwnerId';
				if(rrsKey != null) query_rrs += ' and LeanData__Pool__r.LeanData__Grouping_Name__c like: rrsKey';
				List<LeanData__Round_Robin_Setting__c> rrsToUpdate = Database.query(query_rrs);
				if(rrsKey != null){
					inactiveReasonSet.add('Partner at cap');
				} else {
					inactiveReasonSet.add('Sales Rep at cap');
				}
				for(LeanData__Round_Robin_Setting__c rrs: rrsToUpdate){
					rrs.LeanData__Status__c = 'Unavailable';
					rrs.LeanData__Inactive_Reason__c = JSON.serialize(inactiveReasonSet);
				}
				if(rrsToUpdate != null && !rrsToUpdate.isEmpty()) Database.update(rrsToUpdate);	
			}
			return 'Next Node';
		}
		return 'Invalid Parameter';
    }

    global override void batchCompleteCallback(){
        if(partnerRegionIdsToUpdate != null && partnerRegionIdsToUpdate.size() != 0){
          for(Id partnerQuotaId : partnerRegionIdsToUpdate){
            partnerRegionsToUpdate.add(partnerRegionIdMap.get(partnerQuotaId));
          }
          Database.update(partnerRegionsToUpdate);
        }

        if(leadQuotaIdsToUpdate != null && leadQuotaIdsToUpdate.size() != 0){
          for(Id leadQuotaId : leadQuotaIdsToUpdate){
            leadQuotasToUpdate.add(leadQuotaIdMap.get(leadQuotaId));
          }
          Database.update(leadQuotasToUpdate);
        }      

        //null/reset all data types per slice
        partnerRegionIdsToUpdate = null;
        leadQuotaIdsToUpdate = null;
        userToObjectMap = null;
        partnerRegionsToUpdate = null;
        partnerRegionQuotaMap = null;
        partnerRegionIdMap = null;
        leadQuotaMap = null;
        leadQuotaIdMap = null;
        leadQuotasToUpdate = null;
        rrsWithConflictUsers = null;
        rrsWithConflictPartner = null;
        partnerRegions = null;
        leadQuotas = null;
    }

    public static Map<String, String> countryMap = new Map<String, String> {
          'Andorra' => 'AD',
          'United Arab Emirates' => 'AE',
          'Armenia' => 'AM',
          'Argentina' => 'AR',
          'Austria' => 'AT',
          'Australia' => 'AU',
          'Azerbaijan' => 'AZ',
          'Belgium' => 'BE',
          'Bulgaria' => 'BG',
          'Bahrain' => 'BH',
          'Brunei Darussalam' => 'BN',
          'Bolivia' => 'BO',
          'Brazil' => 'BR',
          'Botswana' => 'BW',
          'Belarus' => 'BY',
          'Canada' => 'CA',
          'Switzerland' => 'CH',
          'Chile' => 'CL',
          'China' => 'CN',
          'Colombia' => 'CO',
          'Costa Rica' => 'CR',
          'Cyprus' => 'CY',
          'Czechia' => 'CZ',
          'Germany' => 'DE',
          'Denmark' => 'DK',
          'Ecuador' => 'EC',
          'Estonia' => 'EE',
          'Egypt' => 'EG',
          'Spain' => 'ES',
          'Ethiopia' => 'ET',
          'Finland' => 'FI',
          'France' => 'FR',
          'United Kingdom' => 'GB',
          'Georgia' => 'GE',
          'Ghana' => 'GH',
          'Greece' => 'GR',
          'Guatemala' => 'GT',
          'Hong Kong' => 'HK',
          'Honduras' => 'HN',
          'Croatia' => 'HR',
          'Hungary' => 'HU',
          'Indonesia' => 'ID',
          'Ireland' => 'IE',
          'Israel' => 'IL',
          'India' => 'IN',
          'Italy' => 'IT',
          'Japan' => 'JP',
          'Kenya' => 'KE',
          'South Korea' => 'KR',
          'Kuwait' => 'KW',
          'Kazakhstan' => 'KZ',
          'Lithuania' => 'LT',
          'Luxembourg' => 'LU',
          'Latvia' => 'LV',
          'Moldova' => 'MD',
          'Mauritius' => 'MU',
          'Mexico' => 'MX',
          'Malaysia' => 'MY',
          'Mozambique' => 'MZ',
          'Namibia' => 'NA',
          'Nigeria' => 'NG',
          'Netherlands' => 'NL',
          'Norway' => 'NO',
          'New Zealand' => 'NZ',
          'Oman' => 'OM',
          'Panama' => 'PA',
          'Peru' => 'PE',
          'Philippines' => 'PH',
          'Poland' => 'PL',
          'Portugal' => 'PT',
          'Paraguay' => 'PY',
          'Qatar' => 'QA',
          'Romania' => 'RO',
          'Serbia' => 'RS',
          'Russia' => 'RU',
          'Rwanda' => 'RW',
          'Saudi Arabia' => 'SA',
          'Sweden' => 'SE',
          'Singapore' => 'SG',
          'Slovenia' => 'SI',
          'Slovakia' => 'SK',
          'Senegal' => 'SN',
          'South Sudan' => 'SS',
          'El Salvador' => 'SV',
          'Eswatini' => 'SZ',
          'Thailand' => 'TH',
          'Turkey' => 'TR',
          'Taiwan' => 'TW',
          'Tanzania' => 'TZ',
          'Ukraine' => 'UA',
          'Uganda' => 'UG',
          'United States' => 'US',
          'Uruguay' => 'UY',
          'Uzbekistan' => 'UZ',
          'Vietnam' => 'VN',
          'South Africa' => 'ZA',
          'Zambia' => 'ZM',
          'Zimbabwe' => 'ZW'
        };
}