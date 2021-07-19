public class ConfigManager {
	public static boolean IsSandbox = [Select IsSandbox from Organization].IsSandbox;
    
    public static String getBigBrainWebhookUrl(){
        return getBigBrainBaseUrl() + '/salesforce/webhook';
    }

    public static String BillingCycleEP(String pulseId){
        return getBigBrainBaseUrl() + '/salesforce/billing_cycle/' + pulseId;
    }
    
    public static String getIConductQuoteSyncPID(){
        //return IsSandbox ? 'x23580' : 'x23495';
        return IsSandbox ? label.iConduct_Sync_Quote_PID_Sandbox : label.iConduct_Sync_Quote_PID;
    }
    
    public static String getIConductBillingEntitySyncPID(){
        //return IsSandbox ? 'x23581' : 'x23494';
        return IsSandbox ? label.iConduct_Sync_BE_PID_Sandbox : label.iConduct_Sync_BE_PID;
    }
    
    public static String get(String key){
        BigBrain_Setting__mdt config = getConfig();
        return String.valueOf(config.get(key));
    }
    
    public static String getBigBrainBaseUrl(){
        return IsSandbox ? 'https://data.bigbrainstaging.me' : 'https://data.bigbrain.me';
    }

    private static BigBrain_Setting__mdt getConfig(){
        BigBrain_Setting__mdt[] settings = [select id, Root_URL__c from BigBrain_Setting__mdt LIMIT 1];
        return settings[0];
    }
}