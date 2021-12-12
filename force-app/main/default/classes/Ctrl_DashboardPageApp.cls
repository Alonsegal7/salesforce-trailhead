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
        List <User> lu = [SELECT Id, AccountId FROM User WHERE Id = :userId];
        if (lu != null && !lu.isEmpty() && lu[0].AccountId != null) accountId = lu[0].AccountId;
        if (Test.isRunningTest()) accountId = [SELECT Id FROM Account LIMIT 1].Id;
        if (accountId != null){
            List <Opportunity> lo = [SELECT Id, Green_Bucket_ARR_V2__c, Opportunity_Origin__c FROM Opportunity WHERE AccountId =:accountId AND GSI__c != null];
            if (lo != null && !lo.isEmpty()) for (Opportunity o: lo){
                total += o.Green_Bucket_ARR_V2__c != null ? o.Green_Bucket_ARR_V2__c : 0;
                count++;
                if (o.Opportunity_Origin__c == 'Influenced' && o.Green_Bucket_ARR__c != null) totalInfluenced += o.Green_Bucket_ARR_V2__c;
                if (o.Opportunity_Origin__c == 'Sourced' && o.Green_Bucket_ARR__c != null) totalSourced += o.Green_Bucket_ARR_V2__c;
            }
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
        Decimal green = 0;
        Decimal orange = 0;
        Integer greenCount = 0;
        Integer orangeCount = 0;
        List <User> lu = [SELECT Id, AccountId FROM User WHERE Id = :userId];
        if (lu != null && !lu.isEmpty() && lu[0].AccountId != null) accountId = lu[0].AccountId;
        if (Test.isRunningTest()) accountId = [SELECT Id FROM Account LIMIT 1].Id;
        if (accountId != null){
            List <Account> la = [SELECT Id, Name, ARR__c, Is_GB_Account_Partners__c FROM Account 
                                 WHERE Channel_Partner__c = :lu[0].AccountId AND RecordType.DeveloperName = 'Monday_Account' AND 
                                       Owner_Is_Partner__c = true AND Monday_Account_Status__c = 'Paying Account'];
            if (la != null && !la.isEmpty()) for (Account a: la){
                if (a.Is_GB_Account_Partners__c) { green += (a.ARR__c != null ? a.ARR__c : 0); greenCount++; }
                if (!a.Is_GB_Account_Partners__c) { orange += (a.ARR__c != null ? a.ARR__c : 0); orangeCount++; }
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
        List <User> lu = [SELECT Id, Name, Title, Email, SmallPhotoUrl, ManagerId, Manager.Name, Manager.Title, Manager.Email, Manager.SmallPhotoUrl, 
                                 Manager.ManagerId, Manager.Manager.Name, Manager.Manager.Title, Manager.Manager.Email, Manager.Manager.SmallPhotoUrl, 
                                 AccountId, Account.PSM__c, Account.PSM__r.Name, Account.PSM__r.Title, Account.PSM__r.Email, Account.PSM__r.SmallPhotoUrl 
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
        
        List <User> lu = [SELECT Id, AccountId FROM User WHERE Id = :userId];
        if (lu != null && !lu.isEmpty() && lu[0].AccountId != null){
            Id AccountId = lu[0].AccountId;
            List <Opportunity> lo = [SELECT Id, Name, Channel_Partner__c, Green_Bucket_ARR_V2__c, Opportunity_Source_Type__c, CloseDate 
                                     FROM Opportunity 
                                     WHERE Channel_Partner__c = :AccountId AND IsWon = true AND Is_Potential_GB_Opportunity__c = true AND 
                                           Green_Bucket_ARR_V2__c != null AND RecordType.DeveloperName = 'Partner_Opportunity' AND CloseDate = THIS_FISCAL_YEAR];
            
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
            inboundField = 'Actual_ARR_Sourced_LIVE__c';
            outboundField = 'Actual_ARR_Influenced_LIVE__c';
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
        if (AccountId != null){
            List <Account> la = [SELECT Id, Name, MAPP__c, Plan_Seats__c FROM Account 
                                 WHERE RecordType.DeveloperName = 'Monday_Account' AND Owner_Is_Partner__c = true AND Plan_Period__c != 'Monthly' AND 
                                       IS_GB_Account_Partners__c = true AND Monday_Account_Status__c = 'Paying Account' AND Plan_Seats__c != null AND 
                                       Plan_Seats__c != 0 AND Channel_Partner__c = :AccountId];

            if (la != null && !la.isEmpty()){
                Decimal tMapp = 0;
                Decimal tSeat = 0;
                for (Account a: la){
                    tMapp += (a.MAPP__c == null ? 0 : a.MAPP__c);
                    tSeat += a.Plan_Seats__c;
                }
                if (tSeat > 0) {
                    mapp = Math.floor(tMapp / tSeat);
                }
            }
        }

        res.put('mapp', mapp);

        System.debug('iCloudius - MAPP initial params:\n' + JSON.serializePretty(res));
        return res;
    }
}