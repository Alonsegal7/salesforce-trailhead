public without sharing class Lead_StampsService {

    public static void run(List<Lead> newLeads, Map<Id,Lead> oldLeads){
        try {
            if(oldLeads == null) getValuesOnCreate(newLeads);
            handleStatusTimestamps(newLeads,oldLeads);
            handleOngoingUpdates(newLeads,oldLeads);
            ownerStamps(newLeads,oldLeads);
            markCompanyRelatedStampsUponCreaion(newLeads,oldLeads);
            handlePhoneChange(newLeads,oldLeads);
            handleMqlSql(newLeads,oldLeads);
        } catch(Exception e) {
            Utilities.sendDebugEmail('Error in Lead_StampsService',e,e.getMessage());
        }
    }

    /*usage: 
    1. check if the related company's arr is > 0
    2. check if the related company is an outbound company 
    updated the corresponding lead fields accordingly */
    public static void markCompanyRelatedStampsUponCreaion(List<Lead> newLeads, Map<Id,Lead> oldLeads){ //this runs on update as well b/c BB might update the Related_Company short time after lead creation. so business wise this is upon creation but the transaction can be update
        List<Lead> relevantLeads = new List<Lead>();
        Set<Id> relatedCompsIds = new Set<Id>();
        for(Lead lead: newLeads){
            if(lead.Related_Company__c != null && // only relevant when Related_Company__c is not null
                (oldLeads == null || //in insert
                (oldLeads.get(lead.Id).Related_Company__c == null && lead.CreatedDate.addHours(24) >= Datetime.now()))){ // or when Related_Company__c is changed from null and the change occures during the 24h post lead creation
                    relevantLeads.add(lead);
                    relatedCompsIds.add(lead.Related_Company__c);
            }
        }
        if(relevantLeads.isEmpty()){
            return;
        }
        Map<Id,Account> relatedCompsWithArr = new Map<Id,Account>([select Id from Account where ARR__c > 0 and Name != 'gmail.com' and Id in: relatedCompsIds]);
        Map<Id,Account> relatedOutboundComps = new Map<Id,Account>([select Id from Account where Named_Account__c = true and Name != 'gmail.com' and Id in: relatedCompsIds]);
        if(relatedCompsWithArr.isEmpty() && relatedOutboundComps.isEmpty()) {
            return;
        }
        for(Lead lead: relevantLeads){
            if(relatedCompsWithArr.containsKey(lead.Related_Company__c)){
                lead.Company_paying_on_lead_creation__c = true;
            }
            if(relatedOutboundComps.containsKey(lead.Related_Company__c)){
                lead.Named_Account_on_Creation__c = true;
            }
        }
    }

    public static void handleOngoingUpdates(List<Lead> newLeads, Map<Id,Lead> oldLeads){
        for (Lead lead : newLeads) {
            //set owner edit time
            if(lead.Owner_edit_time__c == null && 
                ((String.valueOf(lead.OwnerId).startsWith('005') && (oldLeads == null || !String.valueOf(oldLeads.get(lead.Id).OwnerId).startsWith('005'))) || // owner is user (not group) on insert or owner is updated from group to user
                (lead.Status == 'Unqualified' && (oldLeads == null || oldLeads.get(lead.Id).Status != 'Unqualified')))){ // status is Unqualified on insert/updated
                    lead.Owner_edit_time__c = Datetime.now();
            }
            //mark Reached Out To Timestamp
            if(lead.Reached_Out_To__c && lead.First_Reachout_Timestamp__c == null && (oldLeads == null || !oldLeads.get(lead.Id).Reached_Out_To__c)){ //reached out to is marked as true on insert/update and timestamp is null
                lead.First_Reachout_Timestamp__c = Datetime.now();
            }
        }
    }

    public static void getValuesOnCreate(List<Lead> newLeads){
        List<Lead> leadsForDistFirst = new List<Lead>();
        Set<Id> usersToQueryName = new Set<Id>();
        for (Lead lead : newLeads) {
            lead.First_Visitor_Id__c=lead.visitor_id__c;
            lead.Lead_created_date__c=Date.today();
            lead.First_Lead_Source__c = lead.LeadSource;
            lead.First_Sub_source__c = lead.Sub_source__c;
            lead.Account_Arr_on_Lead_Creation__c = lead.Account_ARR__c;
            lead.Type__c = lead.Account_ARR__c > 0 ? 'Expansion' : 'New Business';
            lead.Channel__c = lead.Channel_Lead_Source__c == 'None' ? '-' : lead.Channel_Lead_Source__c;
            lead.Received_timestamp__c = Date.today();
        }
    }

    public static void handlePhoneChange(List<Lead> newLeads, Map<Id,Lead> oldLeads){
        for (Lead lead : newLeads) {
            if ((oldLeads==null && (lead.Phone!=null || lead.Enriched_phone__c!=null))) {//New lead with phone
                lead.Distributed_with_Phone__c=true;
            }
            if (oldLeads==null && lead.Phone==null && lead.Enriched_phone__c!=null) {//New lead with enriched phone
                lead.Phone=lead.Enriched_phone__c;
                lead.Distributed_with_Phone__c=true;
            }
            if (oldLeads!=null && lead.Phone==null && oldLeads.get(lead.Id).Enriched_phone__c!=lead.Enriched_phone__c && lead.Enriched_phone__c!=null) {//Changed lead enriched phone
                lead.Phone=lead.Enriched_phone__c;
            } 
            if (oldLeads==null && lead.Phone==null && lead.Enriched_phone__c==null) {
                lead.Distributed_w_o_Phone_Number__c=true;
            }
        }   
    }           

    public static void handleMqlSql(List<Lead> newLeads, Map<Id,Lead> oldLeads){
        for (Lead lead : newLeads) {
            if (lead.SQL__c && (oldLeads==null || !oldLeads.get(lead.Id).SQL__c)) { //SQL timestamps
                lead.SQL_Timestamp__c=Date.today();
                lead.SQL_Timestamp_DT__c=datetime.now();
            }
            if (!lead.SQL__c && oldLeads != null && oldLeads.get(lead.Id).IsConverted != lead.IsConverted && lead.IsConverted) { //mark SQL and SQL timestamps on convert if SQL is false
                lead.SQL_Timestamp__c=Date.today();
                lead.SQL_Timestamp_DT__c=datetime.now();
                lead.SQL__c=true;
            }
            if (lead.Hubspot_Lifecycle_stage__c=='marketingqualifiedlead' && (oldLeads==null || oldLeads.get(lead.Id).Hubspot_Lifecycle_stage__c!='marketingqualifiedlead')) { // MQL and MQL timestamps
                lead.MQL__c=true;
                lead.MQL_Timestamp_DT__c=datetime.now();
            }
        }
    }

    public static void handleStatusTimestamps(List<Lead> newLeads, Map<Id,Lead> oldLeads){
        //only statuses in the following list are timestamped.
        Set<String> supportedStatuses = new Set<String>{'Unqualified','Nurturing','Received','Attempting','Contacted','Meeting Scheduled','Qualified'};
        StatusMetaDataList listOfMetaData = new StatusMetaDataList();
        for (Lead lead : newLeads) {
            if(!supportedStatuses.contains(lead.Status)) continue; //fix for leads with status baunced being stamped as qualified
            if (oldLeads==null || (oldLeads.get(lead.Id)!=null && lead.Status!=oldLeads.get(lead.Id).Status)) {
                //resubmittion statuses clear - if lead status changed from Unqualified to Recieved we clean all status timestamps
                if(oldLeads != null && lead.Status == 'Received' && oldLeads.get(lead.Id).Status == 'Unqualified'){
                    for (StatusMetaData statusMeta : listOfMetaData.listOfMeta) {
                        for (String stmpField : statusMeta.relatedTimeStampFields) { //fill the timestamp fields of the curr status
                            lead.put(stmpField, null);
                        }
                    }
                }
                //loop over statuses list to fill prev statuses timestamps if they are blank
                for (StatusMetaData statusMeta : listOfMetaData.listOfMeta) {
                    if ((lead.Status==statusMeta.Name || (statusMeta.Name!='Nurturing' && statusMeta.Name!='Unqualified'))) {
                        for (String stmpField : statusMeta.relatedTimeStampFields) { //fill the timestamp fields of the curr status
                            if (lead.get(stmpField)==null) {
                                if(stmpField.containsIgnoreCase('_dt_')) lead.put(stmpField,Datetime.now());
                                else lead.put(stmpField,Date.today());
                            }
                        }
                        if(statusMeta.Name == 'Attempting' && lead.Time_to_Attempting__c == null){ // time to attempting
                            lead.Time_to_Attempting__c = oldLeads == null ? 0 : (Datetime.now().getTime() - lead.CreatedDate.getTime())/60/1000;
                        }
                        if (lead.Status == statusMeta.Name) break; // when reached the curr lead status - exit
                    }
                }
            }
        }
    }

    public static void ownerStamps(List<Lead> newLeads, Map<Id,Lead> oldLeadsMap){
        Set<Id> usersIds = new Set<Id>();
        List<Lead> relevantLeads = new List<Lead>();
        for(Lead newLead: newLeads){
            if(String.valueOf(newLead.OwnerId).startsWith('005') && //relevant only for owners that are users - not queue
                (oldLeadsMap == null || //insert
                newLead.Status != oldLeadsMap.get(newLead.Id).Status || //status change
                (newLead.OwnerId != oldLeadsMap.get(newLead.Id).OwnerId && newLead.Status != 'Unqualified' && newLead.Status != 'Qualified'))){ //owner update on open leads
                    usersIds.add(newLead.OwnerId); //collect user ids
                    if(oldLeadsMap != null && String.valueOf(oldLeadsMap.get(newLead.Id).OwnerId).startsWith('005')) usersIds.add(oldLeadsMap.get(newLead.Id).OwnerId); //in case prev owner is a user we need to query those users for checking if their group is integration user
                    relevantLeads.add(newLead);
            }
        }
        if(relevantLeads.isEmpty()) {
            return;
        }
        Set<String> ownerFunctionsToExclude = new Set<String>{'Marketing','Product','Bot'};
        Map<Id,User> ownersMap = new Map<Id,User>([select Id, 
                                                    Function__c, 
                                                    Outbound__c, 
                                                    ManagerId, 
                                                    Manager.Team__c, 
                                                    Group__c, 
                                                    Business_Role__c, 
                                                    Segment__c, 
                                                    Seniority__c, 
                                                    Team__c, 
                                                    Office__c, 
                                                    Office_Region__c, 
                                                    Quota_Carrying__c, 
                                                    SDR_Transition_To_AE__c, 
                                                    Name, 
                                                    UserRole.Name 
                                                    from User 
                                                    where Id in :usersIds]);
        User currOwner;
        for(Lead leadRec: relevantLeads){
            if(ownersMap.get(leadRec.OwnerId).Group__c == 'Integration User') continue; // we do not stamp owners that have group = integration user
            currOwner = ownersMap.get(leadRec.OwnerId);
            //if lead is new or (lead is existing and first user assignment)
            if(oldLeadsMap == null 
                || leadRec.Owner_Name_Initial__c == null // no initial owner
                || !String.valueOf(oldLeadsMap.get(leadRec.Id).OwnerId).startsWith('005') //prev owner was queue
                || ownersMap.get(oldLeadsMap.get(leadRec.Id).OwnerId).Group__c == 'Integration User'){ //prev owner was user with group = integration user
                //stamp initial fields
                leadRec.Owner_Business_Role_Initial__c = currOwner.Business_Role__c;
                leadRec.Owner_Group_Initial__c = currOwner.Group__c;
                leadRec.Owner_Name_Initial__c = currOwner.Name;
                leadRec.Owner_Office_Initial__c = currOwner.Office__c;
                leadRec.Owner_Office_Region_Initial__c = currOwner.Office_Region__c;
                leadRec.Owner_Quota_Carrying_Initial__c = currOwner.Quota_Carrying__c;
                leadRec.Owner_Segment_Initial__c = currOwner.Segment__c;
                leadRec.Owner_Seniority_Initial__c = currOwner.Seniority__c;
                leadRec.Owner_Team_Initial__c = currOwner.Team__c;
                leadRec.Is_Owner_Outbound_Rep_Initial__c = currOwner.Outbound__c;
                leadRec.Owner_s_Function_Initial__c = currOwner.Function__c;
                if(oldLeadsMap == null) leadRec.Distributed_to_First__c = currOwner.Name; //only on create
            }
            //update live fields
            leadRec.Owner_Business_Role_Live__c = currOwner.Business_Role__c;
            leadRec.Owner_Group_Live__c = currOwner.Group__c;
            leadRec.Owner_Name_Live__c = currOwner.Name;
            leadRec.Owner_Office_Live__c = currOwner.Office__c;
            leadRec.Owner_Office_Region_Live__c = currOwner.Office_Region__c;
            leadRec.Owner_Quota_Carrying_Live__c = currOwner.Quota_Carrying__c;
            leadRec.Owner_Segment_Live__c = currOwner.Segment__c;
            leadRec.Owner_Seniority_Live__c = currOwner.Seniority__c;
            leadRec.Owner_Team_Live__c = currOwner.Team__c;
            leadRec.Is_Owner_Outbound_Rep_Live__c = currOwner.Outbound__c;
            leadRec.Owner_s_Function_Live__c = currOwner.Function__c;
            
            //updates on owner assignment (actual user owner, not group)
            if(oldLeadsMap == null || leadRec.OwnerId != oldLeadsMap.get(leadRec.Id).OwnerId){ //on insert or update of OwnerId
                // owner's manager and owner's manager team
                if(currOwner.UserRole.Name == 'Channel Managers'){ //owner is CPM
                    leadRec.Owner_s_Manager__c = leadRec.OwnerId;
                    leadRec.Owner_s_Manager_Team__c = currOwner.Team__c;
                } else if(!ownerFunctionsToExclude.contains(currOwner.Function__c)){
                    leadRec.Owner_s_Manager__c = currOwner.ManagerId;
                    leadRec.Owner_s_Manager_Team__c = currOwner.Manager.Team__c;
                }
                //sdr bdr stamps
                if(currOwner.Function__c == 'SDR' || currOwner.Business_Role__c == 'SDR' || currOwner.Function__c == 'BDR' || currOwner.Business_Role__c == 'BDR' || currOwner.SDR_Transition_To_AE__c){
                    leadRec.SDR_Name__c = leadRec.OwnerId;
                    leadRec.SDR_Name_for_reports__c = currOwner.Name;
                    leadRec.SDR_Team__c = currOwner.Team__c;
                    leadRec.SDR_Office_stamp__c = currOwner.Office__c;
                    leadRec.SDR_Manager__c = currOwner.ManagerId;
                    leadRec.SDR_Business_Role__c = currOwner.Business_Role__c;
                }
            } 
        }
    }

    public class StatusMetaData{
        public string Name {get;set;}
        public list<string> relatedTimeStampFields{get;set;}
        public StatusMetaData(string name, list<string> fields){
            this.name=name;
            this.relatedTimeStampFields=fields;
        }
    }
    public class StatusMetaDataList{
        public list<StatusMetaData> listOfMeta = new list<StatusMetaData>();
        public StatusMetaDataList(){
            listOfMeta.add(new StatusMetaData('Unqualified',new list<string>{'unqualified_timestamp__c','Unqualified_Timestamp_DT__c'}));
            listOfMeta.add(new StatusMetaData('Nurturing',new list<string>{'Nurturing_Timestamp__c'}));
            listOfMeta.add(new StatusMetaData('Received',new list<string>{'Received_Timestamp_DT__c','Received_timestamp__c'}));
            listOfMeta.add(new StatusMetaData('Attempting',new list<string>{'Attempting_timestamp__c','Attempting_Timestamp_DT__c'}));
            listOfMeta.add(new StatusMetaData('Contacted',new list<string>{'Contacted_timestamp__c','Contacted_Timestamp_DT__c'}));
            listOfMeta.add(new StatusMetaData('Meeting Scheduled',new list<string>{'Meeting_Scheduled_Timestamp_DT__c'}));
            listOfMeta.add(new StatusMetaData('Qualified',new list<string>{'Qualified_Timestamp_DT__c','Qualified_timestamp__c'}));
        }
    }
}