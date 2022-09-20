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
    //the size of the batch slice is determined by LeanData's multi-ccio value, default is 5 as of March 2022

    String setSpecificAvailabilityCustomCapping = 'Set Specific Availability - Custom Capping';
    String updateCappingTotals = 'Update Capping Totals';
    Map<String, SObject> userToObjectMap = new Map<String, SObject>();
    List<Partner_Region__c> partnerRegionList;
    Map<String, Partner_Region__c> partnerRegionQuotaMap;
    Map<Id, Lead_Quota__c> leadQuotaMap;
    List<Lead_Quota__c> leadQuotas;

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
        userToObjectMap = new Map<String, SObject>();
        partnerRegionQuotaMap = null;
        partnerRegionList = null;
        leadQuotaMap = null;
        leadQuotas = null;

        Set<Id> ownerIds = new Set<Id>();
        Set<Id> rrsWithConflictUsers = new Set<Id>();
        Set<Id> rrsWithConflictPartner = new Set<Id>();
        Set<Id> rrsWithConflictPartnerRegion = new Set<Id>();
        List<LeanData__Round_Robin_Setting__c> rrsList = new List<LeanData__Round_Robin_Setting__c>();
        Map<Id, Boolean> allMembersUnavailablePoolMap = new Map<Id, Boolean>();
        Set<Lead_Quota__c> leadQuotaResetList = new Set<Lead_Quota__c>();
        Set<Partner_Region__c> partnerRegionResetList = new Set<Partner_Region__c>();

        Map<String, Decimal> totalDailyQuotaPartnerRegion = new Map<String, Decimal>();
        userToObjectMap = new Map<String, SObject>();

        partnerRegionList = [SELECT Id, Name, Partner_Company__c, Country__c, Main_User__c, Daily_Leads_Quota__c, Current_Daily_Leads_Quota__c, Main_User_Email__c, Partner_Country_Quota__c, Current_Country_Daily_Quota__c, Partner_Country_Quota__r.Total_Country_Cap_For_Partners__c, Country_Quota_Type__c, Partner_Company__r.Region__c FROM Partner_Region__c];
        partnerRegionQuotaMap = new Map<String, Partner_Region__c>();
        for(Partner_Region__c pr : partnerRegionList){
          String userPartner = (String)pr.Main_User__c + pr.Country__c;
          partnerRegionQuotaMap.put(userPartner, pr);

          if(totalDailyQuotaPartnerRegion.get(pr.Country__c) == null){
            totalDailyQuotaPartnerRegion.put(pr.Country__c, pr.Current_Daily_Leads_Quota__c);
          } else if(pr.Current_Daily_Leads_Quota__c != null && pr.Current_Daily_Leads_Quota__c != 0){
            Decimal newTotal = ((Decimal) totalDailyQuotaPartnerRegion.get(pr.Country__c)) + pr.Current_Daily_Leads_Quota__c; 
            totalDailyQuotaPartnerRegion.put(pr.Country__c, newTotal);
          }

          userToObjectMap.put(userPartner, pr);
        }

        leadQuotaMap = new Map<Id, Lead_Quota__c>();
        leadQuotas = [SELECT Id, Current_Sign_Up_Quota__c, Sign_Up_Daily_Quota__c, Office_Region__c, User__c From Lead_Quota__c];

        for(Lead_Quota__c lq : leadQuotas){
          leadQuotaMap.put(lq.User__c, lq);
          userToObjectMap.put(lq.User__c, lq);
        }

        Lead_Quota__c currentLQ = null;

        Datetime dt = Datetime.now();
        Datetime twentyFourHoursAgo = Datetime.now().addHours(-24);
        Map<String, Time> currentTimes = new Map<String, Time>();
        Map<String, Time> sevenAMMap = new Map<String, Time>();
        
        rrsList = [SELECT Id, LeanData__Inactive_Reason__c, LeanData__OwnerId__c, LeanData__User_Owner__c, LeanData__User_Owner__r.Office_Region__c, LeanData__Status__c, LeanData__Pool__c,LeanData__Pool__r.LeanData__Grouping_Name__c, Set_Current_Day_Timestamp__c FROM LeanData__Round_Robin_Setting__c WHERE LeanData__Pool__c != null];
        for(LeanData__Round_Robin_Setting__c rrs : rrsList){
            //reset logic
            //if reset time set on RRS is != null && its after their reset time but today then nothing. if its after their rest time but not today then reset
            Boolean needToResetDailyTotals = FALSE;
            TimeZone tz;
            String tzString;
            String region;

            //these originally had different formats but keeping them separate in case the format changes again
            if(rrs.LeanData__Pool__r.LeanData__Grouping_Name__c.startsWith('S&P')){
             region = rrs.LeanData__Pool__r.LeanData__Grouping_Name__c.substringBetween('-');
            } else if(rrs.LeanData__Pool__r.LeanData__Grouping_Name__c.startsWith('Partners')){
             region = rrs.LeanData__Pool__r.LeanData__Grouping_Name__c.substringBetween('-');
            }

            String userPartnerLoop = rrs.LeanData__OwnerId__c + region;

            Partner_Region__c thisPartnerRegion = partnerRegionQuotaMap.get(userPartnerLoop);

            if(thisPartnerRegion != null && thisPartnerRegion.Partner_Company__r.Region__c != null){
              if(thisPartnerRegion.Partner_Company__r.Region__c == 'EMEA'){
                tz = TimeZone.getTimeZone('Asia/Jerusalem');
                tzString = 'Asia/Jerusalem';
              } else if(thisPartnerRegion.Partner_Company__r.Region__c == 'NAM'){
                tz = TimeZone.getTimeZone('America/New_York');
                tzString = 'America/New_York';
              } else if(thisPartnerRegion.Partner_Company__r.Region__c == 'APAC'){
                tz = TimeZone.getTimeZone('Pacific/Auckland');
                tzString = 'Pacific/Auckland';
              } else if(thisPartnerRegion.Partner_Company__r.Region__c == 'LATAM'){
                tz = TimeZone.getTimeZone('America/Brasilia');
                tzString = 'America/Brasilia';
              }
            } else {
              if(rrs.LeanData__User_Owner__r.Office_Region__c == 'EMEA'){
                tz = TimeZone.getTimeZone('Asia/Jerusalem');
                tzString = 'Asia/Jerusalem';
              } else if(rrs.LeanData__User_Owner__r.Office_Region__c == 'US'){
                tz = TimeZone.getTimeZone('America/New_York');
                tzString = 'America/New_York';
              } else if(rrs.LeanData__User_Owner__r.Office_Region__c == 'APAC'){
                tz = TimeZone.getTimeZone('Pacific/Auckland');
                tzString = 'Pacific/Auckland';
              }
            }

            Time myTime;
            Time sevenAM;

            if(currentTimes.get(tzString) != null){
              myTime = currentTimes.get(tzString);
              sevenAM = sevenAMMap.get(tzString);
            } else {
              myTime = (Time) JSON.deserialize('"' + dt.format('HH:mm:ss.sss', tz.getID()) + 'Z"', Time.class); 
              currentTimes.put(tzString, myTime);
              sevenAM = Time.newInstance(07,00,00, 000);
              if(tzString == 'Asia/Jerusalem'){
                sevenAM = sevenAM.addHours(3);
              } else if(tzString == 'America/New_York'){
                sevenAM = sevenAM.addHours(-4);
              } else if(tzString == 'Pacific/Auckland'){
                sevenAM = sevenAM.addHours(12);
              } else if(tzString == 'America/Brasilia'){
                sevenAM = sevenAM.addHours(-3);
              }
              sevenAMMap.put(tzString, sevenAM);
            }

            if(rrs.Set_Current_Day_Timestamp__c == null || rrs.Set_Current_Day_Timestamp__c < twentyFourHoursAgo || (myTime > sevenAM && rrs.Set_Current_Day_Timestamp__c < dt.addHours(-14))){
              needToResetDailyTotals = TRUE;
              rrs.Set_Current_Day_Timestamp__c = System.Now();
            }

            ownerIds.add(rrs.LeanData__OwnerId__c);

            if(thisPartnerRegion != null && needToResetDailyTotals){
              thisPartnerRegion.Current_Daily_Leads_Quota__c = 0;
              partnerRegionResetList.add(thisPartnerRegion);
            }

            if(thisPartnerRegion != null && thisPartnerRegion.Current_Daily_Leads_Quota__c != null && thisPartnerRegion.Daily_Leads_Quota__c != null && (thisPartnerRegion.Current_Daily_Leads_Quota__c >= thisPartnerRegion.Daily_Leads_Quota__c)){
              rrsWithConflictPartner.add(rrs.Id);
            } else {
              if(leadQuotaMap.get(rrs.LeanData__OwnerId__c) != null){
                currentLQ = leadQuotaMap.get(rrs.LeanData__OwnerId__c);

                if(needToResetDailyTotals && currentLQ != null){
                  currentLQ.Current_Sign_Up_Quota__c = 0;
                  leadQuotaResetList.add(currentLQ);
                }

                if(currentLQ.Current_Sign_Up_Quota__c >= currentLQ.Sign_Up_Daily_Quota__c){
                  rrsWithConflictUsers.add(rrs.Id);
                }
              }
            }

        }

        if(leadQuotaResetList.size() > 0){
          Database.update(new List<Lead_Quota__c>(leadQuotaResetList));
        }
        if(partnerRegionResetList.size() > 0){
          Database.update(new List<Partner_Region__c>(partnerRegionResetList));
        }

        Set<String> inactiveReasonSet;

        for(LeanData__Round_Robin_Setting__c rrs : rrsList){
            inactiveReasonSet = new Set<String>();
            if(rrsWithConflictPartner.contains(rrs.Id) || rrsWithConflictPartnerRegion.contains(rrs.Id) || rrsWithConflictUsers.contains(rrs.Id)){
                if(rrsWithConflictPartner.contains(rrs.Id)){
                  inactiveReasonSet.add('Partner at cap');
                } else if(rrsWithConflictUsers.contains(rrs.Id)){
                  inactiveReasonSet.add('Sales Rep at cap');
                }
                rrs.LeanData__Status__c = 'Unavailable';
                rrs.LeanData__Inactive_Reason__c = JSON.serialize(inactiveReasonSet);
            } else {
                if(rrs.LeanData__Status__c == 'Partner at cap' || rrs.LeanData__Status__c == 'Sales Rep at cap'){
                  rrs.LeanData__Status__c = 'Available';
                  rrs.LeanData__Inactive_Reason__c = JSON.serialize(inactiveReasonSet);
                }
            }
        }

        //Updating LeanData Out of the box Round Robin Objects to have LeanData Round Robin respect this custom capping
        Database.update(rrsList, TRUE);
        return 'Next Node';
      } else if(primaryLead != null && parameter == 'Update Capping Totals'){
        Id primaryLeadOwnerId = (Id) primaryLead.get('OwnerId');

        String countryISO;

        countryISO = countryMap.get((String)primaryLead.get('Country'));

        String currentString = (String)primaryLeadOwnerId + countryISO;

        SObject currentObject = userToObjectMap.get(currentString);

        if(currentObject == null){
          currentObject = userToObjectMap.get(primaryLeadOwnerId);
        }

        if(currentObject instanceof Partner_Region__c){
          if((Decimal)currentObject.get('Current_Daily_Leads_Quota__c') != null && (Decimal)currentObject.get('Current_Daily_Leads_Quota__c') != 0){
            currentObject.put('Current_Daily_Leads_Quota__c', ((Decimal)currentObject.get('Current_Daily_Leads_Quota__c')) + 1);
          } else {
            currentObject.put('Current_Daily_Leads_Quota__c', 1);
          }
        } else if(currentObject instanceof Lead_Quota__c){
          if((Decimal)currentObject.get('Current_Sign_Up_Quota__c') != null && (Decimal)currentObject.get('Current_Sign_Up_Quota__c') != 0){
            currentObject.put('Current_Sign_Up_Quota__c', ((Decimal)currentObject.get('Current_Sign_Up_Quota__c')) + 1);
          } else {
            currentObject.put('Current_Sign_Up_Quota__c', 1);
          }
        }

        if(currentObject != null){
          Database.update(currentObject);
        }

        return 'Next Node';
      }

      return 'Invalid Parameter';
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