public without sharing class BigBrain_LeadPoolService {

    public static list<string> emailRecipients = new list<string>{'kseniasm@monday.com','ronilu@monday.com','michaelim@monday.com'};

    public static Set<String> domainsBlackList {
        get {
            if (domainsBlackList == null) {
                domainsBlackList = new Set<String>();
                for(Domains_Black_List__mdt dbl: [select id,MasterLabel from Domains_Black_List__mdt]){
                    domainsBlackList.add(dbl.MasterLabel);
                }            
            }
            return domainsBlackList;
        }
        set;
    }

    public static Map<String,Object> refreshSignups(list<string> pulse_account_ids, boolean is_limited){
        Map<String,Object> r = new Map<String,Object>();
        HttpResponse res = BigBrainAPI.refreshSignups(pulse_account_ids, is_limited);
        if(res.getStatusCode() == 200){
            Map<String,RefreshSignupData> pulseIdToLead_map = new Map<String,RefreshSignupData>();
            List<RefreshSignupData> refreshed_list = (List<RefreshSignupData>)JSON.deserialize(res.getBody(),List<RefreshSignupData>.class);

            //map pulse acc ids to leads
            //if limited - filter out all results where domain is null
            //we run on all raw signups with clean up reason = domain_null so we do not need results where domain is still null
            for(RefreshSignupData refreshed_su: refreshed_list){
                if(!is_limited || (refreshed_su.domain != null && refreshed_su.domain != '')) {
                    pulseIdToLead_map.put(refreshed_su.pulse_account_id, refreshed_su);
                }
            }
            if(pulseIdToLead_map.isEmpty()) {
                r.put('status','success');
                r.put('refreshed_cntr', 0);
                return r;
            }
            //query all relevant leads and update them with the refreshed data
            //we update the domain if limited = true only
            list<lead> leads_list = [select Id, primary_pulse_account_id__c, Signup_Cleanup_Reason__c, NumberOfEmployees from lead where primary_pulse_account_id__c in: pulseIdToLead_map.keySet()];
            Datetime dt_now = Datetime.now();
            for(lead l: leads_list){
                if(pulseIdToLead_map.containsKey(l.primary_pulse_account_id__c)){
                    RefreshSignupData refreshData = pulseIdToLead_map.get(l.primary_pulse_account_id__c);
                    if(is_limited) {
                        l.BB_Account_Domain__c = refreshData.domain; //we update domain only for raw signups where domain was null/gmail and changed
                        l.Signup_Cleanup_Reason__c = l.Signup_Cleanup_Reason__c.replace('domain_null','').replace(';;',';');
                    }
                    l.Current_score__c = refreshData.score;
                    l.Distributed_score__c = refreshData.score;
                    l.Engagement__c = refreshData.engagements;
                    if(l.NumberOfEmployees == null && refreshData.score_params != null) l.NumberOfEmployees = refreshData.score_params.company_size;
                    l.Last_Refresh_Data_From_BB__c = dt_now;
                }
            }
            Database.update(leads_list);
            r.put('status','success');
            r.put('refreshed_cntr', leads_list.size());
        } else {
            sendSlackBBError(res.getBody(), 'Failed refresh signups (status code ' + res.getStatusCode()+')', res.getStatusCode());
            r.put('status','error');
            r.put('refreshed_cntr', 0);
        }
        return r;
    }

    public static void getSignups(Datetime from_date_time, Datetime to_date_time, bb_signups_controls__c cs){
        try{
            HttpResponse res = BigBrainAPI.pullSignups(from_date_time, to_date_time); 
            system.debug('res body: '+res.getBody());
            if(res.getStatusCode() == 200){
                List<Signup> su_list = (List<Signup>)JSON.deserialize(res.getBody(),List<Signup>.class);  
                List<Lead> newLeads_list = new List<Lead>();
                for(Signup su: su_list){
                    if(su.account != null && su.account.data != null) {
                        lead l = createLead(su);
                        if(l.CountryCode == 'FR') newLeads_list.add(l); //FOR FR PILOT
                    }
                }
                if(!newLeads_list.isEmpty()) {
                    //check for dups by pulse account id and email
                    set<string> emails = new set<string>();
                    set<string> pulseIds = new set<string>();
                    map<string,lead> leadKeys = new map<string,lead>();
                    for(lead leadRec: newLeads_list){
                        if(leadRec.Email == null || leadRec.primary_pulse_account_id__c == null) return;
                        emails.add(leadRec.Email);
                        pulseIds.add(leadRec.primary_pulse_account_id__c);
                        leadKeys.put(leadRec.email + leadRec.primary_pulse_account_id__c, leadRec);
                    }
                    list<lead> existingLeads = [select Id, Email, primary_pulse_account_id__c from Lead where Email in: emails and primary_pulse_account_id__c in: pulseIds];
                    if(!existingLeads.isEmpty()){
                        for(lead leadRec: existingLeads){
                            String key = leadRec.email + leadRec.primary_pulse_account_id__c;
                            if(leadKeys.containsKey(key)){
                                leadKeys.remove(key);
                            }
                        }
                        List<Lead> updatedList = leadKeys.values();
                        Database.insert(updatedList);
                    } else {
                        Database.insert(newLeads_list);
                    }
                }
                updateCustomSetting(cs, to_date_time, true);
                Utilities.sendEmail('Successfull signups pull from '+ string.valueOf(from_date_time) + ' to ' + string.valueOf(to_date_time), string.valueOf(newLeads_list.size()) + ' signups pulled', emailRecipients); 
            } else {
                updateCustomSetting(cs, null, false);
                sendSlackBBError(res.getBody(), 'Failed signups pull from '+ string.valueOf(from_date_time) + ' to ' + string.valueOf(to_date_time), res.getStatusCode());
            }
        } catch (Exception e){
            updateCustomSetting(cs, null, false);
            Utilities.sendEmail('Failed signups pull from '+ string.valueOf(from_date_time) + ' to ' + string.valueOf(to_date_time), e.getMessage() + e.getStackTraceString(), emailRecipients); 
        }
    }

    private static void sendSlackBBError(string body, string subject, integer statusCode){
        string msg;
        Map<String,Object> resJson = (Map<String,Object>)JSON.deserializeUntyped(body);  
        if(resJson.containsKey('message')){
            msg = String.valueOf(resJson.get('message')).replace('\'','');
        }
        Utilities.sendEmail(subject, 'Status Code: '+statusCode+' Body: '+msg , emailRecipients); 
    }

    private static void updateCustomSetting(bb_signups_controls__c cs, Datetime success_datetime, Boolean is_success){
        if(cs == null) return;
        if(is_success){
            cs.number_of_failures_in_a_row__c = 0;
            if(cs.is_recovery__c) cs.active__c = false;
            else cs.last_success_datetime__c = success_datetime;
        } else {
            cs.number_of_failures_in_a_row__c++;
            if(cs.number_of_failures_in_a_row__c >= 5) cs.active__c = false;
        }
        Database.update(cs);
    }

    private static Lead createLead(Signup su){
        Lead newLead = new Lead(Created_From_Pull_Signups_BB__c = true);
        cleanUp(newLead, su.account.data, su.user.data.is_gmail);
        mapStaticValues(newLead);
        mapAccountData(newLead, su.account.data);
        defineNumOfEmployees(newLead, su.account.data.company_size, su.account.enrichments.last_enrichments_decisions);
        mapClearbitEnrichment(newLead, su.account.clearbit_enrichment);
        mapUserData(newLead, su.user.data);
        if(su.account.partner_utm != null) mapPartnerUTM(newLead, su.account.partner_utm);
        if(su.account.plan != null) mapAccountPlanFields(newLead, su.account.plan);
        system.debug('New Lead: ' + newLead);
        return newLead;
    }

    private static void mapStaticValues(Lead newLead){
        newLead.Status = 'New';
        newLead.LeadSource = 'Big Brain - Signup';
        newLead.RecordTypeId = Utilities.rawSignupRecordTypeId;
    }

    private static void mapPartnerUTM(Lead newLead, PartnerUTM partner_utm){
        newLead.Partner_UTM_Banner__c = partner_utm.banner;
        newLead.Partner_UTM_Campaign__c = partner_utm.campaign;
        newLead.Partner_UTM_Landing_Page__c = partner_utm.landing_page;
    }

    private static void mapAccountPlanFields(Lead newLead, AccountPlan plan){
        newLead.Plan_Period__c = plan.period;
        newLead.Plan_Seats__c = plan.max_user;
        newLead.Plan_Tier__c = plan.tier;
    }

    private static void defineNumOfEmployees(Lead newLead, String account_data_company_size, List<EnrichmentDecision> last_enrichments_decisions){
        String relevant_company_size = account_data_company_size; //default
        //check for enrichment decision for company size - if found, we take it
        for(EnrichmentDecision ed: last_enrichments_decisions){
            if(ed.field == 'company_size') {
                relevant_company_size = ed.value;
                break;
            }
        }
        try{
            newLead.NumberOfEmployees = Integer.valueOf(relevant_company_size);
        }catch(Exception ex){} //we set catch for cases when company size is not a number (f.e sometimes we get REDACTED_FORGOT)
    }

    private static void mapAccountData(Lead newLead, AccountData account_data){
        //mapping from account data
        //straight mapping
        newLead.Company = account_data.account_name;
        newLead.Account_was_disabled__c = account_data.disabled == null ? false : account_data.disabled;
        newLead.BB_Account_Domain__c = account_data.domain;
        newLead.Cluster__c = account_data.utm_cluster_id;
        newLead.MondayAccountName__c = account_data.account_name;
        newLead.Pricing_Version__c = account_data.pricing_version;
        newLead.primary_pulse_account_id__c = account_data.pulse_account_id;
        if(account_data.created_at != null) newLead.Sign_up_date__c = Utilities.convertDatetimeToDate(account_data.created_at);
        newLead.Slug__c = account_data.slug;
        newLead.APC__c = account_data.annual_predicted_collection_lock_28;
        newLead.First_Installed_Solution__c = account_data.first_solution_name_cluster_category;
        newLead.First_Installed_Template__c = account_data.template_name;
        newLead.Enabled_users__c = account_data.enabled_users;
        newLead.Number_of_titles_added__c = account_data.titles_added;
        newLead.Referral__c = account_data.referral_name;
        newLead.Team_Survey_Size__c = account_data.max_team_size;
        newLead.time_zone_offset__c = account_data.xi_timezone;
        newLead.Trial_start__c = account_data.trial_start;
        if(newLead.Trial_start__c != null){
            calcTrialEnd(newLead, account_data);
        }
        if(account_data.extra_data != null){
            if(account_data.extra_data.has_product_solutions != null) newLead.Product_A_B_Test__c = Boolean.valueOf(account_data.extra_data.has_product_solutions);
            newLead.Use_Case_Signup__c = account_data.extra_data.utm_sub_cluster_id;
        }
        newLead.monday_account_status__c = account_data.plan_id != null ? 'Paying Account' : (account_data.free_plan_id != null ? 'Free Tier' : 'Trial Account');
    }


    private static void mapClearbitEnrichment(Lead newLead, ClearbitEnrichment clearbit_enrichment){
        newLead.Account_Domains__c = listToString(clearbit_enrichment.account_domains);
        newLead.Tags__c = listToString(clearbit_enrichment.tags);
        newLead.Tech_Stack__c = listToString(clearbit_enrichment.tech);
        newLead.Amount_Raised__c = clearbit_enrichment.amount_raised;
        newLead.Annual_Revenue__c = clearbit_enrichment.annual_revenue;
        newLead.Company_Type__c = clearbit_enrichment.company_type;
        newLead.Estimated_Annual_Revenue__c = clearbit_enrichment.estimated_annual_revenue;
        newLead.Founded_Year__c = clearbit_enrichment.founded_year;
        newLead.Industry = clearbit_enrichment.industry;
        newLead.Industry_Group__c = clearbit_enrichment.industry_group;
        newLead.Sub_Industry__c = clearbit_enrichment.sub_industry;
        newLead.Market_Cap__c = clearbit_enrichment.market_cap;
        newLead.Parent_Domain__c = clearbit_enrichment.parent_domain;
        newLead.Sector__c = clearbit_enrichment.sector;
        newLead.Ticker__c = clearbit_enrichment.ticker;
        newLead.Ultimate_Parent_Domain__c = clearbit_enrichment.ultimate_parent_domain;
    }

    private static void mapUserData(Lead newLead, UserData user_data){
        //mapping from account data
        //straight mapping
        newLead.Email = user_data.email;
        newLead.City = user_data.xi_city;
        newLead.CountryCode = user_data.xi_country;
        newLead.Is_Private_Domain__c = user_data.is_gmail;
        newLead.MobilePhone = user_data.mobile;
        newLead.Phone = user_data.phone;
        newLead.Seniority__c = user_data.seniority;
        list<string> countryCodeWithStates = new list<string>{'US','MX','IT','IN','IE','CN','CA','BR','AU'};
        if(countryCodeWithStates.contains(newLead.CountryCode)) newLead.State = user_data.xi_region; //we set state only for countries that we have states in salesforce enabled to prevent the state error
        newLead.Title = user_data.computed_title;
        //mapping with logic
        setEnrichedPhone(newLead, user_data.enriched_phone);
        setLeadName(newLead, user_data.name);
    }

    private static void setEnrichedPhone(Lead newLead, String phone){
        if(phone == null) return;
        if(phone.length() <= 40) newLead.Enriched_phone__c = phone;
        else {
            newLead.Enriched_phone__c = phone.substring(0, 39);
        }
    }

    private static void calcTrialEnd(Lead newLead, AccountData account_data){
        //add days to trial start - trial_period (default 14) + bonus_trial_days
        Integer trial_period = account_data.trial_period;
        if(trial_period == null) trial_period = 14;
        Integer bonus_trial_days = account_data.bonus_trial_days;
        if(bonus_trial_days == null) bonus_trial_days = 0;
        newLead.Trial_End__c = newLead.Trial_start__c.addDays(trial_period + bonus_trial_days);
    }

    private static void setLeadName(Lead newLead, String fullname){ 
        if(fullname == '' || fullname == null) { //empty name
            newLead.LastName = 'Missing Name';
            return;
        }
        String trimmedName = fullname.trim();
        if(trimmedName.containsWhitespace()){ //more then 1 word -> split
            Integer i = trimmedName.indexOf(' ');
            String firstName = trimmedName.left(i+1);
            String lastName = trimmedName.right(trimmedName.length()-i-1);
            newLead.LastName = lastName.trim();
            newLead.FirstName = firstName.trim();
        } else {
            newLead.LastName = trimmedName;
        }
    }

    private static void cleanUp(Lead newLead, AccountData account_data, Boolean is_gmail){
        /* check for clean up reasons and add them to the field signup_cleanup_reason__c (multi-picklist) */
        list<String> cleanupReason_list = new list<String>();
        if(account_data.is_blocked) cleanupReason_list.add('is_blocked');
        if(account_data.is_student) cleanupReason_list.add('is_student');
        if(account_data.standalone_products_only) cleanupReason_list.add('standalone_products_only');
        if(account_data.purpose == 'School') cleanupReason_list.add('purpose_school');
        if(account_data.purpose != 'Work' && is_gmail) cleanupReason_list.add('purpose_not_work_domain_gmail');
        if(account_data.domain == null || account_data.domain == '') cleanupReason_list.add('domain_null');
        else if(domainsBlackList.contains(account_data.domain)) cleanupReason_list.add('domain_black_list');

        if(cleanupReason_list.isEmpty()) {
            System.debug('Signup has no cleanup reason');
        } else {
            newLead.signup_cleanup_reason__c = String.join(cleanupReason_list, ';');
            System.debug('Signup clean up reason: '+newLead.signup_cleanup_reason__c);
        }
    }

    public static string listToString(list<string> inputList){ //used to convert the lists of domains
        if(inputList == null || inputList.isEmpty()) return null;
        list<string> newList = new list<string>();
        for(string s: inputList){
            if(s != null) newList.add('"'+s+'"');
        }
        String res = newList.toString().replace('(', '[').replace(')', ']').trim();
        return res;
    }

    public class Signup {
        public UserObj user;
        public AccountObj account;
    }  
    
    public class UserObj {
        public UserData data;
        public Enrichment enrichments;
    }

    public class UserData {
        public String name;
        public String email;
        public String xi_city;
        public String xi_country;
        public String enriched_phone;
        public Boolean is_gmail;
        public String mobile;
        public String phone;
        public String seniority;
        public String xi_region;
        public String computed_title;
    }

    public class AccountObj {
        public AccountData data;
        public Enrichment enrichments;
        public AccountPlan plan;
        public PartnerUTM partner_utm;
        public ClearbitEnrichment clearbit_enrichment;
    }

    public class AccountData {
        public String account_name;
        public String domain;
        public String utm_cluster_id;
        public String company_size;
        public String pricing_version;
        public Boolean disabled;
        public String pulse_account_id;
        public DateTime created_at;
        public String slug;
        public String max_team_size;
        public Double xi_timezone;
        public DateTime trial_start;
        public String has_product_solutions;
        public String plan_id;        
        public String free_plan_id;
        public Integer trial_period;
        public Integer bonus_trial_days;
        public Boolean is_blocked;
        public Boolean is_student;
        public Boolean standalone_products_only;
        public String purpose;
        public Double annual_predicted_collection_lock_28;
        public String first_solution_name_cluster_category;
        public String template_name;
        public String referral_name;
        public Double enabled_users;
        public Double titles_added;
        public AccountExtraData extra_data;
    }

    public class AccountExtraData {
        public String has_product_solutions;
        public String utm_sub_cluster_id;
    }

    public class Enrichment {
        public List<LastEnrichment> last_enrichments;
        public List<EnrichmentDecision> last_enrichments_decisions;
    }

    public class LastEnrichment {
        public String source;
        //public String data; //we are not taking the enrichment data for now
    }

    public class EnrichmentDecision {
        public String field;
        public String value;
        public String entity;
        public String source;
    }

    public class AccountPlan {
        public string tier;
        public Double max_user;
        public string period;
    }

    public class PartnerUTM {
        public string banner;
        public string campaign;
        public string landing_page;
    }

    public class ClearbitEnrichment {
        public list<string> account_domains;
        public list<string> tags;
        public list<string> tech;

        public string company_type;
        public Double founded_year;
        public string logo;
        public string ticker;
        public Double amount_raised;
        public Double annual_revenue;
        public string estimated_annual_revenue;
        public Double market_cap;
        public string number_of_employees;
        public string industry;
        public string sub_industry;
        public string industry_group;
        public string sector;
        public string parent_domain;
        public string ultimate_parent_domain;
    }

    public class RefreshSignupData {
        public string pulse_account_id;
        public string domain;
        public double score;
        public double engagements;
        public ScoreParams score_params;
    }

    public class ScoreParams {
        public Integer company_size;
        public string country;
        public double enabled_users;
        public double engagement;
        public Boolean free_tier;
        public Boolean phone;
        public double signup_age;
        public double team_size;
        public string title;
    }
}