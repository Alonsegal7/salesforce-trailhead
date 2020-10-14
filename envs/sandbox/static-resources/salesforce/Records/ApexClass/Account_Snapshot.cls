public without sharing class Account_Snapshot implements Database.Batchable<sObject>, Database.Stateful,Schedulable{
    public Integer num=0;
    public Integer totalAccountsFromQuery=0;
    public Integer totalSnapsCreated=0;
    public Integer totalSnapsErrors=0;
    public String errorsFound='';
    public map<String,Schema.FieldSetMember> accountFieldByName;
    public map<String,Schema.FieldSetMember> snapshotFieldByName;
    public list<String> accountHeaderFields;
    public list<String> snapshotHeaderFields;
    public id accountId;
    
    public Account_Snapshot() {
    }
    
    public Account_Snapshot(id testAccId) {
        accountId=testAccId;
    }
    @InvocableMethod
    public static void ManualRun(list<id> testAccId){
        Database.executeBatch(new Account_Snapshot(testAccId[0]));
    }
    public void execute(SchedulableContext sc) {
        try{
            Database.executeBatch(this,30);
        }catch(Exception e){
            Utilities.sendDebugEmail('Error in Account_Snapshot ',e,e.getMessage());   
        }
    }
    public Database.querylocator start(Database.BatchableContext BC){
        string query='';
        try{
            string fieldsToQuery='';
            accountHeaderFields=new list<String>();
            accountFieldByName=new map<String,Schema.FieldSetMember>();
            for (Schema.FieldSetMember fsm :SObjectType.Account.FieldSets.Account_Snapshot_Fields.getFields()){
                accountHeaderFields.add(fsm.getFieldPath());
                accountFieldByName.put(fsm.getFieldPath(),fsm);
                fieldsToQuery+=','+fsm.getFieldPath();
            }
            snapshotHeaderFields=new list<String>();
            snapshotFieldByName=new map<String,Schema.FieldSetMember>();
            for (Schema.FieldSetMember fsm :SObjectType.Account_Snapshot__c.FieldSets.Snapshot_Creation_Fields.getFields()){
                snapshotHeaderFields.add(fsm.getFieldPath());
                snapshotFieldByName.put(fsm.getFieldPath(),fsm);
            }
            
            dateTime today=dateTime.now();
            dateTime tomorrow=today+1;
            query='select Id,Name ';
            query+=fieldsToQuery;
            //get all paying customers (MAs), excluding accounts that already have a snapshot for today (to aviod dups)
            query+=' from Account where recordtype.developername=\'Monday_Account\' and ARR__c>0 '; 
            query+=' and Id NOT IN (SELECT Account__c FROM Account_Snapshot__c where Date__c=today) ';
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
            for(Account acc: scope){
                Account_Snapshot__c os= new Account_Snapshot__c();
                os.Account__c=acc.Id;
                os.Name=acc.Name.left(61)+' - '+string.valueof(datetime.now().format('dd/MM/YYYY HH:mm'));
                os.Date__c=date.today();
                os.Weekly_Snapshot__c=isOngoing;
                os.End_of_Month__c=isLast;
                os.Start_of_Month__c=isFirst;
                if(accountId!=null)
                    os.Test_Snapshot__c=true;
                for (Integer i=0;i<accountHeaderFields.size();i++){
                    String accFieldName=accountHeaderFields[i];
                    String snapFieldName=snapshotHeaderFields[i];
                    os.put(snapFieldName,acc.get(accFieldName));
                }
                snapsToCreate.add(os);
            }
            num+=1;
            system.debug('Raz Ben Ron accSnap snapsToCreate: '+snapsToCreate); 
            Database.SaveResult[] results = Database.insert(snapsToCreate, false);
            for (Database.SaveResult sr : results) {
                if (!sr.isSuccess()) {
                    for(Database.Error e : sr.getErrors()) {
                        Utilities.sendEmail('Error in Account_Snapshot ',e.getMessage()+' acc.snapsToCreate',new list<string>{'razbe@monday.com'});
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
            totalAccountsFromQuery+=snapsToCreate.size()==null?0:snapsToCreate.size();
            //insert snapsToCreate;
        }catch(Exception e){
            Utilities.sendDebugEmail('Error in Account_Snapshot ',e,e.getMessage()+' acc.snapsToCreate');   
        }
    }
    public void finish(Database.BatchableContext bc) {
        system.debug('Raz Ben Ron Account Snapshot # of batchs: '+num);
        Utilities.sendEmail('Finished Account_Snapshot Creation','# of Snapshots to Create Today: '+totalAccountsFromQuery+'<br/># of Account Snapshots Created: '+totalSnapsCreated+'<br/> # of Account Snapshots Failed: '+totalSnapsErrors+'<br/> Errors Found: '+errorsFound+' <br/>Date: '+date.today()+' '+datetime.now().format('E'),new list<String>{label.SystemNotificationsDL});   
    }
}