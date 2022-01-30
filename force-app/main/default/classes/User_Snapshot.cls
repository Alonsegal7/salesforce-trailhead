public without sharing class User_Snapshot implements Database.Batchable<sObject>,Database.Stateful,Schedulable{
    
    public Integer num=0;
    public Integer totalUsersFromQuery=0;
    public Integer totalSnapsCreated=0;
    public Integer totalSnapsErrors=0;
    public String errorsFound='';
    public Date dateInput;
    public map<String,Schema.FieldSetMember> userFieldByName;
    public map<String,Schema.FieldSetMember> snapshotFieldByName;
    public list<String> userHeaderFields;
    public list<String> snapshotHeaderFields;
    public id userId;
    public boolean forceCreation=false;

    public User_Snapshot() {

    }
    public User_Snapshot(id testUserId) {
        userId=testUserId;
    }
    public User_Snapshot(boolean forceCreationVar) {
        forceCreation=forceCreationVar;
    }
    @InvocableMethod
    public static void UserSnapManualRun(list<id> testUserId){
        Utilities.cleanFlexQueue();
        Database.executeBatch(new User_Snapshot(testUserId[0]));
    }

    public void execute(SchedulableContext sc) {
        try{
            Utilities.cleanFlexQueue();
            Database.executeBatch(this,50);
        }catch(Exception e){
            Utilities.sendDebugEmail('Error in User_Snapshot ',e,e.getMessage());   
        }
    }
    
    public Database.querylocator start(Database.BatchableContext BC){
        string query='';
        try{
            totalUsersFromQuery=0;
            if(forceCreation==null)
            forceCreation=false;
            //list and map of the user field set
            userHeaderFields = new list<String>();
            userFieldByName = new map<String,Schema.FieldSetMember>();
            string fieldsToQuery='';
            for (Schema.FieldSetMember fsm :SObjectType.User.FieldSets.User_Snapshot_Fields.getFields()){
                userHeaderFields.add(fsm.getFieldPath());
                userFieldByName.put(fsm.getFieldPath(),fsm);
                fieldsToQuery+=','+fsm.getFieldPath();
                System.debug('fsm: '+fsm);
            }
            System.debug('userHeaderFields: '+userHeaderFields);
            System.debug('fieldsToQuery: '+fieldsToQuery);
            //list and map of the userSnapshot field set
            snapshotHeaderFields=new list<String>();
            snapshotFieldByName=new map<String,Schema.FieldSetMember>();
            for (Schema.FieldSetMember fsm :SObjectType.User_Snapshot__c.FieldSets.Snapshot_Fields.getFields()){
                snapshotHeaderFields.add(fsm.getFieldPath());
                snapshotFieldByName.put(fsm.getFieldPath(),fsm);
                System.debug('fsm: '+fsm);
                System.debug('fsm.getFieldPath(): '+fsm.getFieldPath());
                System.debug('snapshotHeaderFields: '+snapshotHeaderFields);
            }
            System.debug('fieldsToQuery: '+fieldsToQuery);
            //snapshot all the active users that don't have a snapshot for the same day
            dateTime today=dateTime.now();
            dateTime tomorrow=today+1;
            query='select Id,Name, ';
            query+=' (select id from User_Snapshots__r order by Snapshot_Date__c desc limit 1) ';
            query+=fieldsToQuery; 
            query+=' from User WHERE IsActive = true'; 
            query+=' and Id NOT IN (SELECT User__c FROM User_Snapshot__c where Snapshot_Date__c=TODAY) ';
            if(userId!=null)
            query+=' and id=\''+userId+'\' ';
            if(!(today.format('E')=='Sun'||today.format('E')=='Wed'||today.day()==1||today.day()==10||today.day()>tomorrow.day()||userId!=null||forceCreation)&&!test.isRunningTest())
            query+=' limit 0 ';  
            
        }catch(Exception e){
            Utilities.sendDebugEmail('Error in User_Snapshot ',e,e.getMessage());   
        }
        System.debug('Database.getQueryLocator(query): '+Database.getQueryLocator(query));
        return Database.getQueryLocator(query);  
    }

    public void execute(Database.BatchableContext bc, List<User> scope) {
        try{
            list<User_Snapshot__c> snapsToCreate= new list<User_Snapshot__c>();
            if(forceCreation==null)
                forceCreation=false;
            dateTime today=dateTime.now();
            dateTime tomorrow=today+1;
            system.debug('User_Snapshot scope: '+scope);
            boolean isOngoing=today.format('E')=='Sun'||today.format('E')=='Wed'||forceCreation?true:false;
            boolean isFirst=today.day()==1?true:false;
            boolean isTenth=today.day()==10?true:false;
            boolean isLast=today.day()>tomorrow.day()?true:false;
            system.debug('User_Snapshot - userHeaderFields: '+userHeaderFields);
            system.debug('User_Snapshot - snapshotHeaderFields: '+snapshotHeaderFields);
            for(User user: scope){
                system.debug('User_Snapshot for loop user: '+user);
                User_Snapshot__c us= new User_Snapshot__c();
                us.User__c=user.Id;
                us.Name=string.valueof(datetime.now().format('dd/MM/YYYY HH:mm'));
                us.Snapshot_Date__c=date.today();
                us.Bi_Weekly_Snapshot__c=isOngoing;
                us.End_of_Month__c=isLast;
                us.Start_of_Month__c=isFirst;
                us.Tenth_of_Month__c=isTenth;
                for (Integer i=0;i<userHeaderFields.size();i++){
                    String userFieldName=userHeaderFields[i];
                    String userFieldType=string.valueof(userFieldByName.get(userFieldName).getType());
                    String snapFieldName=snapshotHeaderFields[i];
                    String snapFieldType=string.valueof(snapshotFieldByName.get(snapFieldName).getType());
                    Object value=user.get(userFieldName);
                    if(userFieldType=='DATETIME'&&snapFieldType=='DATE')
                        value=date.valueof(value);
                    us.put(snapFieldName,value);
                }
                if(user.User_Snapshots__r.size()>0)
                    us.Previous_Snapshot__c=user.User_Snapshots__r[0].id;
                snapsToCreate.add(us);
            }
            num+=1;
            system.debug('User_Snapshot snapsToCreate: '+snapsToCreate); 
            Database.SaveResult[] results = Database.insert(snapsToCreate, false);
            for (Database.SaveResult sr : results) {
                if (!sr.isSuccess()) {
                    for(Database.Error e : sr.getErrors()) {
                        Utilities.sendEmail('Error in User_Snapshot ',e.getMessage()+' '+e.getFields(),new list<string>{'biztech@monday.com'});
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
            totalSnapsCreated+=snapsToCreate.size();
            //insert snapsToCreate;
        }catch(Exception e){
            Utilities.sendDebugEmail('Error in User_Snapshot ',e,e.getMessage());   
        }
    }
    public void finish(Database.BatchableContext bc) {
        system.debug('User_Snapshot user Snapshot, # of batchs: '+num);
        Utilities.sendEmail('Finished User_Snapshot Creation','# of Snapshots to Create Today: '+totalUsersFromQuery+'<br/># of users Snapshots Created: '+totalSnapsCreated+'<br/> # of user Snapshots Failed: '+totalSnapsErrors+'<br/> Errors Found: '+errorsFound+' <br/>Date: '+date.today()+' '+datetime.now().format('E'),new list<String>{label.SystemNotificationsDL});   
    }
}
