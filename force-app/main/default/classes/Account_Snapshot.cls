public without sharing class Account_Snapshot implements Database.Batchable<sObject>, Database.Stateful,Schedulable{
    public Integer num=0;
    public Integer totalAccountsFromQuery=0;
    public Integer totalSnapsCreated=0;
    public Integer totalSnapsErrors=0;
    public String errorsFound='';
    public map<String,String> snapshotFieldByAccField;
    public id accountId;
    
    public Account_Snapshot() {
    }
    
    public Account_Snapshot(id testAccId) {
        accountId=testAccId;
    }
    @InvocableMethod
    public static void ManualRun(list<id> testAccId){
        Utilities.cleanFlexQueue();
        Database.executeBatch(new Account_Snapshot(testAccId[0]));
    }
    public void execute(SchedulableContext sc) {
        try{
            Utilities.cleanFlexQueue();
            Database.executeBatch(this,10);
        }catch(Exception e){
            Utilities.sendDebugEmail('Error in Account_Snapshot ',e,e.getMessage());   
        }
    }
    public Database.querylocator start(Database.BatchableContext BC){
        string query='';
        try{
            string fieldsToQuery='';
            totalAccountsFromQuery=0;
            snapshotFieldByAccField=new map<String,String>();
            for(Account_Snapshot_Mapping__mdt asm :[select id,Account_Field_API__c,Snapshot_Field_API__c 
                                                    from Account_Snapshot_Mapping__mdt]){
                snapshotFieldByAccField.put(asm.Account_Field_API__c,asm.Snapshot_Field_API__c);
                fieldsToQuery+=','+asm.Account_Field_API__c;
            }
            //

            dateTime today=dateTime.now();
            dateTime tomorrow=today+1;
            query='select Id,Name ';
            //query+=',(SELECT Id FROM Account_Snapshots__r ORDER BY Date__c DESC LIMIT 1) ';
            query+=fieldsToQuery;
            //get all paying customers (MAs), excluding accounts that already have a snapshot for today (to aviod dups)
            query+=' from Account where recordtype.developername=\'Monday_Account\' and ARR__c>0 '; 
            //query+=' and Id NOT IN (SELECT Account__c FROM Account_Snapshot__c where Date__c=today) ';
            if(accountId!=null)
                query+=' and id=\''+accountId+'\' '; 
            if(!(today.format('E')=='Sun'||today.day()==1||today.day()>tomorrow.day()||accountId!=null)&&!test.isRunningTest())
                query+=' limit 0 ';
            system.debug('Raz Ben Ron accSnap query: '+query); 
        }catch(Exception e){
            Utilities.sendDebugEmail('Error in Account_Snapshot ',e,e.getMessage());   
        }
        return Database.getQueryLocator(query);  
    }

    public void execute(Database.BatchableContext bc, List<Account> scope) {
        try{
            list<Account_Snapshot__c> snapsToCreate= new list<Account_Snapshot__c>();
            dateTime today=dateTime.now();
            dateTime tomorrow=today+1;
            boolean isOngoing=today.format('E')=='Sun'?true:false;
            boolean isFirst=today.day()==1?true:false;
            boolean isLast=today.day()>tomorrow.day()?true:false;

            //querying in execute to avoid CPU limit in start
            map<Id,Account> accountWithLatestSnapshot= new map<Id,Account>([select id,(SELECT Id,Date__c FROM Account_Snapshots__r ORDER BY Date__c DESC LIMIT 1)
                                                                            from Account where id in:scope]);
            for(Account acc: scope){
                system.debug('Raz Ben Ron Acc Name '+acc.Name); 
                Account_Snapshot__c os= new Account_Snapshot__c();
                os.Account__c=acc.Id;
                os.Name=acc.Name.left(61)+' - '+string.valueof(datetime.now().format('dd/MM/YYYY HH:mm'));
                os.Date__c=date.today();
                os.Weekly_Snapshot__c=isOngoing;
                os.End_of_Month__c=isLast;
                os.Start_of_Month__c=isFirst;
                if(accountId!=null)
                    os.Test_Snapshot__c=true;
                for (String accField: snapshotFieldByAccField.keySet()){
                    String accFieldName=accField;
                    String snapFieldName=snapshotFieldByAccField.get(accField);
                    os.put(snapFieldName,acc.get(accFieldName));
                }//
                list<Account_Snapshot__c> prevSnaps=accountWithLatestSnapshot.get(acc.Id).Account_Snapshots__r;
                if(prevSnaps.size()>0){
                    os.Previous_Snapshot__c=prevSnaps[0].Id;
                    //os.Previous_Snapshot__c=acc.Account_Snapshots__r[0].Id;
                }
                if(prevSnaps.size()==0||
                    (prevSnaps.size()>0&&prevSnaps[0].Date__c!=os.Date__c))//to avoid duplications
                    snapsToCreate.add(os);
            }
            num+=1;
            system.debug('Raz Ben Ron accSnap snapsToCreate: '+snapsToCreate); 
            Database.SaveResult[] results = Database.insert(snapsToCreate, false);
            for (Database.SaveResult sr : results) {
                if (!sr.isSuccess()) {
                    for(Database.Error e : sr.getErrors()) {
                        Utilities.sendEmail('Error in Account_Snapshot ',e.getMessage(),new list<string>{'razbe@monday.com'});
                        System.debug('The following error has occurred.');  
                        System.debug(e.getStatusCode() + ': ' + e.getMessage());
                        System.debug('Fields that affected this error: ' + e.getFields());
                        totalSnapsErrors+=1;
                        errorsFound+=e.getMessage()+', ';
                    }
                }else{
                    totalSnapsCreated+=1;
                }
            }
            totalAccountsFromQuery+=snapsToCreate.isEmpty()?0:snapsToCreate.size();
        }catch(Exception e){
            Utilities.sendDebugEmail('Error in Account_Snapshot ',e,e.getMessage());   
        }
    }
    public void finish(Database.BatchableContext bc) {
        system.debug('Raz Ben Ron Account Snapshot # of batchs: '+num);
        Utilities.sendEmail('Finished Account_Snapshot Creation','# of Snapshots to Create Today: '+totalAccountsFromQuery+'<br/># of Account Snapshots Created: '+totalSnapsCreated+'<br/> # of Account Snapshots Failed: '+totalSnapsErrors+'<br/> Errors Found: '+errorsFound+' <br/>Date: '+date.today()+' '+datetime.now().format('E'),new list<String>{label.SystemNotificationsDL});   
    }
}