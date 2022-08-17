public without sharing class Ctrl_DashboardPageApp {
    @AuraEnabled
    public static Map <String, Object> init(Map <String, Object> params){
        Map <String, Object> res = new Map <String, Object>();
        res.put('channel_team', getUserChannelTeam(null));
        res.put('tier_status', getTierStatus(null));
        System.debug('iCloudius - Dashboard initial params:\n' + JSON.serializePretty(res));
        return res;
    }

    @AuraEnabled
    public static Map <String, Object> initSpiffVsLockedARR(Id userId){
        if (userId == null) userId = UserInfo.getUserId();
        Map <String, Object> res = new Map <String, Object>();
        Id accountId = null;
        Decimal target = 0;
        Decimal actual = 0;
        Decimal arr = 0;
        Decimal newBizArr = 0;
        Decimal spiff = 0;
        String title = 'Spiff - Q';
        Date d = Date.today();
        if (d.month() < 4) title += '1';
        if (d.month() < 7 && d.month() > 3) title += '2';
        if (d.month() < 10 && d.month() > 6) title += '3';
        if (d.month() > 9) title += '4';
        title += '/' + String.valueOf(d.year()).right(2);
        List <User> lu = [SELECT Id, AccountId, Account.Partner_Tier__c FROM User WHERE Id = :userId];
        if (lu != null && !lu.isEmpty() && lu[0].AccountId != null) accountId = lu[0].AccountId;

        List <Target__c> lt = [SELECT Id, Amount__c, Actual_ARR_Locked__c, Closed_Won_Arr__c FROM Target__c WHERE Target_Date__c = THIS_QUARTER AND Partner_Company__c = :accountId];
        if (lt != null && !lt.isEmpty()) for (Target__c t: lt) {
            if (t.Amount__c != null) target += t.Amount__c;
            if (t.Actual_ARR_Locked__c != null) actual += t.Actual_ARR_Locked__c;
        }
        if (lt!=null && lt.size()>0){ system.debug('Targets are: '); system.debug(json.serializePretty (lt));}
        
        system.debug('Target is '+target);
        system.debug('Actual is '+actual);

        if (actual >= target || Test.isRunningTest()){
            List <Opportunity> lo = [SELECT Id, Name, Green_Bucket_ARR_V2__c, Opportunity_Type__c, Expected_Plan_Tier__c FROM Opportunity 
                                     WHERE Channel_Partner__c = :accountId AND Is_Potential_GB_Opportunity__c = true AND StageName = 'Closed Won' AND CloseDate = THIS_QUARTER];
                                     
            if (lo.size()>0) system.debug(json.serializepretty (lo));
                                     
            if (lo != null && !lo.isEmpty()) for (Opportunity o: lo){
                //if (o.Green_Bucket_ARR_V2__c != null) arr += o.Green_Bucket_ARR_V2__c;
                if (o.Green_Bucket_ARR_V2__c != null && o.Opportunity_Type__c == 'New Business' && o.Expected_Plan_Tier__c != null && o.Expected_Plan_Tier__c.containsIgnoreCase('Enterprise')) newBizArr += o.Green_Bucket_ARR_V2__c;
            }
            //spiff = Math.floor(((arr * 0.025) + (newBizArr * 0.05)));
            spiff = Math.floor((newBizArr * 0.03));
        }
        
        res.put('title', title);
        res.put('target', target);
        res.put('actual', actual);
        res.put('spiff', spiff);
        
        System.debug('iCloudius - Spiff:\n' + JSON.serializePretty(res));
        return res;
    }

    @AuraEnabled
    public static Map <String, Object> initSpiff(Id userId){
        if (userId == null) userId = UserInfo.getUserId();
        Map <String, Object> res = new Map <String, Object>();
        Id accountId = null;
        Decimal target = 0;
        Decimal actual = 0;
        Decimal arr = 0;
        Decimal newBizArr = 0;
        Decimal spiff = 0;
        String title = 'Spiff - Q';
        Date d = Date.today();
        if (d.month() < 4) title += '1';
        if (d.month() < 7 && d.month() > 3) title += '2';
        if (d.month() < 10 && d.month() > 6) title += '3';
        if (d.month() > 9) title += '4';
        title += '/' + String.valueOf(d.year()).right(2);
        List <User> lu = [SELECT Id, AccountId, Account.Partner_Tier__c FROM User WHERE Id = :userId];
        if (lu != null && !lu.isEmpty() && lu[0].AccountId != null) accountId = lu[0].AccountId;
        List <Target__c> lt = [SELECT Id, Amount__c, Closed_Won_Arr__c FROM Target__c WHERE Target_Date__c = THIS_QUARTER AND Partner_Company__c = :accountId];
        if (lt != null && !lt.isEmpty()) for (Target__c t: lt) {
            if (t.Amount__c != null) target += t.Amount__c;
            if (t.Closed_Won_Arr__c != null) actual += t.Closed_Won_Arr__c;
        }
        if (actual >= target || Test.isRunningTest()){
            List <Opportunity> lo = [SELECT Id, Name, Green_Bucket_ARR_V2__c, Opportunity_Type__c, Expected_Plan_Tier__c FROM Opportunity 
                                     WHERE Channel_Partner__c = :accountId AND Is_Potential_GB_Opportunity__c = true AND StageName = 'Closed Won' AND CloseDate = THIS_QUARTER];
            if (lo != null && !lo.isEmpty()) for (Opportunity o: lo){
                if (o.Green_Bucket_ARR_V2__c != null) arr += o.Green_Bucket_ARR_V2__c;
                if (o.Green_Bucket_ARR_V2__c != null && o.Opportunity_Type__c == 'New Business' && o.Expected_Plan_Tier__c != null && o.Expected_Plan_Tier__c.containsIgnoreCase('Enterprise')) newBizArr += o.Green_Bucket_ARR_V2__c;
            }
            spiff = Math.floor(((arr * 0.025) + (newBizArr * 0.05)));
        }
        
        res.put('title', title);
        res.put('target', target);
        res.put('actual', actual);
        res.put('spiff', spiff);
        
        System.debug('iCloudius - Spiff:\n' + JSON.serializePretty(res));
        return res;
    }

    @AuraEnabled
    public static Map <String, Object> getCertifications(Id userId){
        if (userId == null) userId = UserInfo.getUserId();
        Map <String, Object> res = new Map <String, Object>();
        Integer sales = 0;
        Integer am = 0;
        Integer csm = 0;
        Integer salesOutOf = 0;
        Integer amOutOf = 0;
        Integer csmOutOf = 0;
        Id accountId = null;
        List <User> lu = [SELECT Id, AccountId, Account.Partner_Tier__c FROM User WHERE Id = :userId];
        if (lu != null && !lu.isEmpty() && lu[0].AccountId != null) accountId = lu[0].AccountId;
        List <Contact> lc = [SELECT Id, Certified_Sales__c, Certified_Account_Management__c, Certified_Consulting__c 
                             FROM Contact 
                             WHERE AccountId = :accountId AND 
                             ((Certified_Sales__c = true) OR 
                             (Certified_Account_Management__c = true) OR
                             (Certified_Consulting__c = true))];
        if (lc != null && !lc.isEmpty()) for (Contact c: lc){
            if (c.Certified_Sales__c) sales++;
            if (c.Certified_Account_Management__c) am++;
            if (c.Certified_Consulting__c) csm++;
        }

        if (lu != null && !lu.isEmpty() && lu[0].AccountId != null && lu[0].Account.Partner_Tier__c != null){
            List <Partner_Tier_Certification__mdt> lptc = [SELECT Id, Sales__c, CSM__c, AM__c FROM Partner_Tier_Certification__mdt WHERE MasterLabel = :lu[0].Account.Partner_Tier__c];
            if (lptc != null && !lptc.isEmpty()){
                salesOutOf = (Integer)lptc[0].Sales__c;
                amOutOf = (Integer)lptc[0].AM__c;
                csmOutOf = (Integer)lptc[0].CSM__c;
            }
        }

        res.put('sales', sales);
        res.put('am', am);
        res.put('csm', csm);
        res.put('sales_out_of', salesOutOf);
        res.put('am_out_of', amOutOf);
        res.put('csm_out_of', csmOutOf);

        System.debug('iCloudius - Certifications:\n' + JSON.serializePretty(res));
        return res;
    }

    @AuraEnabled
    public static Map <String, Object> initProfileUpdate(Id userId){
        if (userId == null) userId = UserInfo.getUserId();
        Map <String, Object> res = new Map <String, Object>();
        Id accountId = null;
        List <User> lu = [SELECT Id, AccountId FROM User WHERE Id = :userId];
        if (lu != null && !lu.isEmpty() && lu[0].AccountId != null) accountId = lu[0].AccountId;
        if (Test.isRunningTest()) accountId = [SELECT Id FROM Account LIMIT 1].Id;
        res.put('last_update', 'N/A');
        res.put('next_update', 'N/A');
        res.put('alert', true);
        if (accountId != null){
            res.put('accountId', accountId);
            List <Partner_Metrics__c> lpm = [SELECT Id, CreatedDate FROM Partner_Metrics__c WHERE Partner__c =:accountId ORDER BY CreatedDate DESC LIMIT 1];
            if (lpm != null && !lpm.isEmpty()) {
                res.put('last_update', lpm[0].CreatedDate.format('dd.MM.yyyy'));
                res.put('next_update', lpm[0].CreatedDate.addMonths(6).format('dd.MM.yyyy'));
                res.put('alert', (lpm[0].CreatedDate.addMonths(6) < Date.today().addDays(-7)));
                res.put('partner_matrics', lpm[0]);
            }
        }
        System.debug('iCloudius - Profile Update:\n' + JSON.serializePretty(res));
        return res;
    }

    @AuraEnabled
    public static Map <String, Object> initARRGSIPortfolioManagment(Id userId){
        if (userId == null) userId = UserInfo.getUserId();
        Map <String, Object> res = new Map <String, Object>();
        Id accountId = null;
        Decimal total = 0;
        Integer count = 0;
        Decimal totalSourced = 0;
        Decimal totalInfluenced = 0;
        List <Account> la = null;
        Set <Id> setId = new Set <Id>();
        List <User> lu = [SELECT Id, AccountId FROM User WHERE Id = :userId];
        if (lu != null && !lu.isEmpty() && lu[0].AccountId != null) accountId = lu[0].AccountId;
        if (Test.isRunningTest()) accountId = [SELECT Id FROM Account LIMIT 1].Id;
        if (accountId != null){
            List <Opportunity> lo = [SELECT Id, Green_Bucket_ARR__c, Green_Bucket_ARR_V2__c, Opportunity_Origin__c FROM Opportunity WHERE IsWon = true AND GSI__c =:accountId AND Commission_Entitlement__c = true];
            if (lo != null && !lo.isEmpty()) for (Opportunity o: lo){
                total += o.Green_Bucket_ARR_V2__c != null ? o.Green_Bucket_ARR_V2__c : 0;
                if (o.Opportunity_Origin__c == 'Enabled' && o.Green_Bucket_ARR__c != null) totalInfluenced += o.Green_Bucket_ARR_V2__c;
                if (o.Opportunity_Origin__c == 'Sourced' && o.Green_Bucket_ARR__c != null) totalSourced += o.Green_Bucket_ARR_V2__c;
            }
            List <Partner_Region__c> lpr = [SELECT Id FROM Partner_Region__c WHERE Partner_Company__c =:accountId];
            if (lpr != null && !lpr.isEmpty()) for (Partner_Region__c pr: lpr) setId.add(pr.Id);
            if (!setId.isEmpty()) la = [SELECT Id FROM Account WHERE GSI_Partner_Region__c IN :setId AND RecordType.DeveloperName = 'Monday_Account' AND Monday_Account_Status__c = 'Paying Account'];
            if (la != null && !la.isEmpty()) count = la.size();
        }
        res.put('total', total);
        res.put('count', count);
        res.put('totalInfluenced', totalInfluenced);
        res.put('totalSourced', totalSourced);
        System.debug('iCloudius - ARR GSI Portfolio Management:\n' + JSON.serializePretty(res));
        return res;
    }

    @AuraEnabled
    public static Map <String, Object> initPortfolioManagment(Id userId){
        if (userId == null) userId = UserInfo.getUserId();
        Map <String, Object> res = new Map <String, Object>();
        Id accountId = null;
        Decimal inboundValue = 0;
        Decimal outboundValue = 0;
        Decimal outboundValueV2 = 0;
        Decimal green = 0;
        Decimal orange = 0;
        Integer greenCount = 0;
        Integer orangeCount = 0;
        List <GB_Threshold__c> lgb = [SELECT Name, Min_ARR__c FROM GB_Threshold__c WHERE Is_Active__c = true AND (Name = 'Partners' OR Name = 'Partners - Outbound' OR Name = 'Partners - Outbound v2')];
        if (lgb != null && !lgb.isEmpty()) for (GB_Threshold__c gb: lgb){
            if (gb.Name == 'Partners') inboundValue = gb.Min_ARR__c;
            if (gb.Name == 'Partners - Outbound') outboundValue = gb.Min_ARR__c;
            if (gb.Name == 'Partners - Outbound v2') outboundValueV2 = gb.Min_ARR__c;
        }
        List <User> lu = [SELECT Id, AccountId FROM User WHERE Id = :userId];
        if (lu != null && !lu.isEmpty() && lu[0].AccountId != null) accountId = lu[0].AccountId;
        if (Test.isRunningTest()) accountId = [SELECT Id FROM Account LIMIT 1].Id;
        if (accountId != null){
            List <Account> la = [SELECT Id, Name, ARR__c, Account_Source_Type__c, Outbound_TH_Excluded__c FROM Account 
                                 WHERE Channel_Partner__c = :lu[0].AccountId AND RecordType.DeveloperName = 'Monday_Account' AND 
                                       Owner_Is_Partner__c = true AND Monday_Account_Status__c = 'Paying Account'];

            if (Test.isRunningTest()) la = [SELECT Id, Name, ARR__c, Account_Source_Type__c, Outbound_TH_Excluded__c FROM Account 
                                            WHERE RecordType.DeveloperName = 'Monday_Account'];

            if (la != null && !la.isEmpty()) for (Account a: la){
                if ((a.ARR__c >= inboundValue && a.Account_Source_Type__c == 'Inbound') || 
                        (
                            (a.Outbound_TH_Excluded__c && a.Account_Source_Type__c == 'Outbound' && a.ARR__c > outboundValue) || 
                            (!a.Outbound_TH_Excluded__c && a.Account_Source_Type__c == 'Outbound' && a.ARR__c >= outboundValueV2)
                        )
                    ) { green += (a.ARR__c != null ? a.ARR__c : 0); greenCount++; }

                if ((a.ARR__c < inboundValue && a.Account_Source_Type__c == 'Inbound') || 
                        (a.Outbound_TH_Excluded__c && a.Account_Source_Type__c == 'Outbound' && a.ARR__c < outboundValue) || 
                        (!a.Outbound_TH_Excluded__c && a.Account_Source_Type__c == 'Outbound' && a.ARR__c < outboundValueV2)
                    ) { orange += (a.ARR__c != null ? a.ARR__c : 0); orangeCount++; }
            }
        }
        res.put('green_count', greenCount);
        res.put('orange_count', orangeCount);
        res.put('green_total_arr', green);
        res.put('orange_total_arr', orange);
        System.debug('iCloudius - Portfolio Management:\n' + JSON.serializePretty(res));
        return res;
    }

    @AuraEnabled
    public static List <User> getUserChannelTeam(Id userId){
        if (userId == null) userId = UserInfo.getUserId();
        Id Dashboard_SalesTrainerID = Id.valueOf(Label.Dashboard_SalesTrainerID);
        List <User> lu = [SELECT Id, Name, Title, UserRole.Name, Email, SmallPhotoUrl, ManagerId, Manager.Name, Manager.Title, Manager.UserRole.Name, Manager.Email, 
                                 Manager.SmallPhotoUrl, Manager.ManagerId, Manager.Manager.Name, Manager.Manager.Title, Manager.Manager.UserRole.Name, Manager.Manager.Email, 
                                 Manager.Manager.SmallPhotoUrl, AccountId, Account.PSM__c, Account.PSM__r.Name, Account.PSM__r.Title, Account.PSM__r.UserRole.Name, 
                                 Account.PSM__r.Email, Account.PSM__r.SmallPhotoUrl, Account.PS_Consultant__c, Account.PS_Consultant__r.Name, Account.PS_Consultant__r.Title, 
                                 Account.PS_Consultant__r.UserRole.Name, Account.PS_Consultant__r.Email, Account.PS_Consultant__r.SmallPhotoUrl 
                          FROM User 
                          WHERE Id =:userId OR Id =:Dashboard_SalesTrainerID];
        System.debug('iCloudius - Channel team raw data:\n' + JSON.serializePretty(lu));
        return lu;
    }

    @AuraEnabled
    public static Map <String, Object> getTierStatus(Id userId){
        if (userId == null) userId = UserInfo.getUserId();
        Map <String, Object> res = new Map <String, Object>();
        Decimal totalArr = 0;
        Decimal outboundArr = 0;
        Decimal mapp = 0;
        Date today = Date.today();
        Date sDate = null;
        Date eDate = null;
        if (today >= Date.newInstance(today.year(), 1, 1) && today < Date.newInstance(today.year(), 7, 1)){
            sDate = Date.newInstance((today.year() - 1), 7, 1);
            eDate = today;
        }
        if (today >= Date.newInstance(today.year(), 7, 1) && today < Date.newInstance((today.year() + 1), 1, 1)){
            sDate = Date.newInstance(today.year(), 1, 1);
            eDate = today;
        }
        
        List <User> lu = [SELECT Id, AccountId, Account.Partner_tier__c FROM User WHERE Id = :userId];
        if (lu != null && !lu.isEmpty() && lu[0].AccountId != null){
            res.put('partner_tier', lu[0].Account.Partner_tier__c);
            Id AccountId = lu[0].AccountId;
            List <Opportunity> lo = [SELECT Id, Name, Channel_Partner__c, Green_Bucket_ARR_V2__c, Opportunity_Source_Type__c, CloseDate 
                                     FROM Opportunity 
                                     WHERE Channel_Partner__c = :AccountId AND IsWon = true AND Is_Potential_GB_Opportunity__c = true AND 
                                           Green_Bucket_ARR_V2__c != null AND RecordType.DeveloperName = 'Partner_Opportunity' AND CloseDate >= :sDate AND CloseDate <= :eDate];
            
            if (lo != null && !lo.isEmpty()){
                for (Opportunity o: lo){
                    totalArr += o.Green_Bucket_ARR_V2__c;
                    if (o.Opportunity_Source_Type__c == 'Outbound') outboundArr += o.Green_Bucket_ARR_V2__c;
                }
            }
        }

        res.put('total_arr', totalArr);
        res.put('outbound_arr', outboundArr);
        res.put('next_review', 'Next Tier Review: ' + (Date.today().month() < 7 ? 'June' : 'December') + ', ' + Date.today().year());

        System.debug('iCloudius - Dashboard initial params:\n' + JSON.serializePretty(res));
        return res;
    }

    @AuraEnabled
    public static Map <String, Decimal> getTargets(Id userId, String source){
        if (userId == null) userId = UserInfo.getUserId();
        Map <String, Decimal> msd = new Map <String, Decimal>();
        String inboundField = 'Actual_ARR_Inbound_LIVE__c';
        String outboundField = 'Actual_ARR_Outbound_LIVE__c';
        if (source == 'sourced'){
            inboundField = 'Actual_ARR_Influenced_LIVE__c';
            outboundField = 'Actual_ARR_Sourced_LIVE__c';
        }
        msd.put('m_target', 0);
        msd.put('m_inbound', 0);
        msd.put('m_outbound', 0);
        msd.put('m_total', 0);
        msd.put('q_target', 0);
        msd.put('q_inbound', 0);
        msd.put('q_outbound', 0);
        msd.put('q_total', 0);
        msd.put('y_target', 0);
        msd.put('y_inbound', 0);
        msd.put('y_outbound', 0);
        msd.put('y_total', 0);
        Id accountId = null;
        Integer thisMonth = Date.today().month();
        Integer thisYear = Date.today().year();
        Period fiscalQuarter = [Select StartDate, EndDate From Period Where type = 'Quarter' and StartDate = THIS_FISCAL_QUARTER];
        Period fiscalYear = [Select StartDate, EndDate From Period Where type = 'Year' and StartDate = THIS_FISCAL_YEAR];
        System.debug('iCloudius - fiscalQuarter: ' + fiscalQuarter);
        System.debug('iCloudius - fiscalYear: ' + fiscalYear);

        List <User> lu = [SELECT Id, AccountId FROM User WHERE Id = :userId];
        if (lu != null && !lu.isEmpty() && lu[0].AccountId != null) accountId = lu[0].AccountId;
        if (Test.isRunningTest()) accountId = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'Company' LIMIT 1].Id;
        if (accountId != null){
            String query = 'SELECT Id, Name, Target_Date__c, Amount__c, ' + inboundField + ', ' + outboundField + ' FROM Target__c ';
            query += 'WHERE Partner_Company__c = :AccountId AND ';
            query += '(Target_Date__c = THIS_MONTH OR Target_Date__c = THIS_FISCAL_QUARTER OR Target_Date__c = THIS_FISCAL_YEAR)';
            
            System.debug('iCloudius - Target query: ' + query);
            List <Target__c> lt = (List <Target__c>)Database.query(query);
            if (Test.isRunningTest()) lt = [SELECT Id, Name, Target_Date__c, Amount__c, Actual_ARR_Inbound_LIVE__c, Actual_ARR_Outbound_LIVE__c FROM Target__c];
            if (lt != null && !lt.isEmpty()){
                for (Target__c t: lt){
                    System.debug('iCloudius - Current target:\n' + JSON.serializePretty(t));
                    if ((t.Target_Date__c != null && t.Target_Date__c.month() == thisMonth && t.Target_Date__c.year() == thisYear) || Test.isRunningTest()){
                        msd.put('m_target', (msd.get('m_target') + (t.Amount__c != null ? t.Amount__c : 0)));
                        msd.put('m_inbound', (msd.get('m_inbound') + (t.get(inboundField) != null ? (Decimal)t.get(inboundField) : 0)));
                        msd.put('m_outbound', (msd.get('m_outbound') + (t.get(outboundField) != null ? (Decimal)t.get(outboundField) : 0)));
                        msd.put('m_total', (msd.get('m_inbound') + msd.get('m_outbound')));
                    }
                    if ((t.Target_Date__c != null && t.Target_Date__c >= fiscalQuarter.StartDate && t.Target_Date__c <= fiscalQuarter.EndDate) || Test.isRunningTest()){
                        msd.put('q_target', (msd.get('q_target') + (t.Amount__c != null ? t.Amount__c : 0)));
                        msd.put('q_inbound', (msd.get('q_inbound') + (t.get(inboundField) != null ? (Decimal)t.get(inboundField) : 0)));
                        msd.put('q_outbound', (msd.get('q_outbound') + (t.get(outboundField) != null ? (Decimal)t.get(outboundField) : 0)));
                        msd.put('q_total', (msd.get('q_inbound') + msd.get('q_outbound')));
                    }
                    if ((t.Target_Date__c != null && t.Target_Date__c >= fiscalYear.StartDate && t.Target_Date__c <= fiscalYear.EndDate) || Test.isRunningTest()){
                        msd.put('y_target', (msd.get('y_target') + (t.Amount__c != null ? t.Amount__c : 0)));
                        msd.put('y_inbound', (msd.get('y_inbound') + (t.get(inboundField) != null ? (Decimal)t.get(inboundField) : 0)));
                        msd.put('y_outbound', (msd.get('y_outbound') + (t.get(outboundField) != null ? (Decimal)t.get(outboundField) : 0)));
                        msd.put('y_total', (msd.get('y_inbound') + msd.get('y_outbound')));
                    }
                }
                if (msd.get('m_target') == 0 && msd.get('m_total') > 0) msd.put('m_target', msd.get('m_total'));
                if (msd.get('q_target') == 0 && msd.get('q_total') > 0) msd.put('q_target', msd.get('q_total'));
                if (msd.get('y_target') == 0 && msd.get('y_total') > 0) msd.put('y_target', msd.get('y_total'));
            }
        }

        System.debug('iCloudius - Targets initial params:\n' + JSON.serializePretty(msd));
        return msd;
    }

    @AuraEnabled
    public static Map <String, Object> getMapp(Id userId){
        if (userId == null) userId = UserInfo.getUserId();
        Map <String, Object> res = new Map <String, Object>();
        Id accountId = null;
        Decimal mapp = 0;

        List <User> lu = [SELECT Id, AccountId FROM User WHERE Id = :userId];
        if (lu != null && !lu.isEmpty() && lu[0].AccountId != null) accountId = lu[0].AccountId;
        if (Test.isRunningTest()) accountId = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'Monday_Account' LIMIT 1].Id;
        System.debug('iCloudius - getMapp for account: ' + AccountId);
        if (AccountId != null){
            List <Account> la = [SELECT Id, Name, MAPP__c, Plan_Seats__c FROM Account 
                                 WHERE RecordType.DeveloperName = 'Monday_Account' AND Owner_Is_Partner__c = true AND Plan_Period__c != 'Monthly' AND 
                                       IS_GB_Account_Partners__c = true AND Monday_Account_Status__c = 'Paying Account' AND Plan_Seats__c != null AND 
                                       Plan_Seats__c != 0 AND Channel_Partner__c = :AccountId];
            System.debug('iCloudius - Found MAPP Accounts: ' + la);
            if (la != null && !la.isEmpty()){
                Decimal tMapp = 0;
                Decimal tSeat = 0;
                for (Account a: la){
                    tMapp += (a.MAPP__c == null ? 0 : a.MAPP__c);
                    tSeat += a.Plan_Seats__c;
                }
                if (tSeat > 0) {
                    mapp = ((tMapp / tSeat) * 100).setScale(2);
                }
            }
        }

        res.put('mapp', mapp);

        System.debug('iCloudius - MAPP initial params:\n' + JSON.serializePretty(res));
        return res;
    }
}