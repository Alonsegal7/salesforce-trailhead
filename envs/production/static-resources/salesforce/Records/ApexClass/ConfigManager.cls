public class ConfigManager {
	public static boolean IsSandbox = [Select IsSandbox from Organization].IsSandbox;
    
    public static String getBigBrainWebhookUrl(){
        return IsSandbox ? 
            'https://amiel-bb.ngrok.io/salesforce/webhook' :
        	'https://data.bigbrain.me/salesforce/webhook';
    }
    public static String BillingCycleEP(String pulseId){
        return IsSandbox ? 
            'https://amiel-bb.ngrok.io/salesforce/billing_cycle/'+pulseId :
            'https://bigbrain.me/salesforce/billing_cycle/'+pulseId;
            //'https://data.bigbrain.me/salesforce/billing_cycle/'+pulseId;
            
    }
    
    public static String getIConductQuoteSyncPID(){
        return IsSandbox ? 'x23580' : 'x23495';
    }
    
    public static String getIConductBillingEntitySyncPID(){
        return IsSandbox ? 'x23581' : 'x23494';
    }
    
    public static String get(String key){
        BigBrain_Setting__mdt config = getConfig();
        return String.valueOf(config.get(key));
    }
    
    private static BigBrain_Setting__mdt getConfig(){
        BigBrain_Setting__mdt[] settings = [select id, Root_URL__c from BigBrain_Setting__mdt LIMIT 1];
        return settings[0];
    }
}