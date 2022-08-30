public without sharing class Opportunity_Snapshot implements Database.Batchable<sObject>, Database.Stateful,Schedulable{
    public Integer num=0;
    public Integer totalOppsFromQuery=0;
    public Integer totalSnapsCreated=0;
    public Integer totalSnapsErrors=0;
    public String errorsFound='';
    public Date dateInput;
    public map<String,Schema.FieldSetMember> oppFieldByName;
    public map<String,Schema.FieldSetMember> snapshotFieldByName;
    public list<String> oppHeaderFields;
    public list<String> snapshotHeaderFields;
    public id oppId;
    public boolean forceCreation=false;

    public Opportunity_Snapshot() {
        //forceCreation=false;
    }
    public Opportunity_Snapshot(id testOppId) {
        oppId=testOppId;
        //forceCreation=false;
    }
    public Opportunity_Snapshot(boolean forceCreationVar) {
        forceCreation=forceCreationVar;
    }
    @InvocableMethod
    public static void OppSnapManualRun(list<id> testOppId){
        Utilities.cleanFlexQueue();
        Database.executeBatch(new Opportunity_Snapshot(testOppId[0]));
    }

    public void execute(SchedulableContext sc) {
        try{
            Utilities.cleanFlexQueue();
            Database.executeBatch(this,50);
        }catch(Exception e){
            Utilities.sendDebugEmail('Error in Opportunity_Snapshot ',e,e.getMessage());   
        }
    }
    public Database.querylocator start(Database.BatchableContext BC){
        string query='';
        try{
            string fieldsToQuery='';
            totalOppsFromQuery=0;
            if(forceCreation==null)
                forceCreation=false;
            oppHeaderFields=new list<String>();
            oppFieldByName=new map<String,Schema.FieldSetMember>();
            for (Schema.FieldSetMember fsm :SObjectType.Opportunity.FieldSets.Opportunity_Snapshot_Fields.getFields()){
                oppHeaderFields.add(fsm.getFieldPath());
                oppFieldByName.put(fsm.getFieldPath(),fsm);
                fieldsToQuery+=','+fsm.getFieldPath();
            }
            snapshotHeaderFields=new list<String>();
            snapshotFieldByName=new map<String,Schema.FieldSetMember>();
            for (Schema.FieldSetMember fsm :SObjectType.Opportunity_Snapshot__c.FieldSets.Snapshot_Fields.getFields()){
                snapshotHeaderFields.add(fsm.getFieldPath());
                snapshotFieldByName.put(fsm.getFieldPath(),fsm);
            }

            //the snapshots are taken on Sundays/Wednesdays/1st day on the month/last day of the month, without duplications
            dateTime today=dateTime.now();
            dateTime tomorrow=today+1;
            //query='select Id,CloseDate,Forecasted__c,Forecasted_ARR__c,Forecast_ARR__c,Probability,Record_Type__c,createddate, ';
            //query+=' OwnerId,Owner.FirstName,Owner.LastName, Owner.Team__c,GB_opp__c,Green_Bucket_ARR__c,StageName, ';
            //query+=' Owner.Manager.FirstName,Owner.Manager.LastName, Owner.Office__c,RecordType.Name, ';
            query='select Id,Name,RecordType.Name,Forecasted__c,Owner.Manager.name, ';
            query+=' (select id from Opportunity_Snapshots__r order by Snapshot_Date__c desc limit 1) ';
            query+=fieldsToQuery; 
            query+=' from Opportunity WHERE CloseDate >= LAST_N_MONTHS:3 and CloseDate <= NEXT_N_MONTHS:3 '; 
            query+=' and Id NOT IN (SELECT Opportunity__c FROM Opportunity_Snapshot__c where Snapshot_Date__c=today) ';
            if(oppId!=null)
                query+=' and id=\''+oppId+'\' '; 
            if(!(today.format('E')=='Sun'||today.format('E')=='Wed'||today.day()==1||today.day()==10||today.day()>tomorrow.day()||oppId!=null||forceCreation)&&!test.isRunningTest())
                query+=' limit 0 '; 
        }catch(Exception e){
            Utilities.sendDebugEmail('Error in Opportunity_Snapshot ',e,e.getMessage());   
        }
        return Database.getQueryLocator(query);  
    }

    public void execute(Database.BatchableContext bc, List<Opportunity> scope) {
        try{
            list<Opportunity_Snapshot__c> snapsToCreate= new list<Opportunity_Snapshot__c>();
            if(forceCreation==null)
                forceCreation=false;
            dateTime today=dateTime.now();
            dateTime tomorrow=today+1;
            boolean isOngoing=today.format('E')=='Sun'||today.format('E')=='Wed'||forceCreation?true:false;
            boolean isFirst=today.day()==1?true:false;
            boolean isTenth=today.day()==10?true:false;
            boolean isLast=today.day()>tomorrow.day()?true:false;
            system.debug('Raz Ben Ron OppSnap scope: '+scope);
            for(Opportunity opp: scope){
                Opportunity_Snapshot__c os= new Opportunity_Snapshot__c();
                os.Opportunity__c=opp.Id;
                os.Name=string.valueof(datetime.now().format('dd/MM/YYYY HH:mm'));
                os.Snapshot_Date__c=date.today();
                os.Opportunity_Record_Type__c=opp.RecordType.Name;
                os.Owner_Manager__c=opp.Owner.Manager.Name;
                os.Commit__c=opp.Forecasted__c?1:0;
                os.Bi_Weekly_Snapshot__c=isOngoing;
                os.End_of_Month__c=isLast;
                os.Start_of_Month__c=isFirst;
                os.Tenth_of_Month__c=isTenth;
                for (Integer i=0;i<oppHeaderFields.size();i++){
                    String oppFieldName=oppHeaderFields[i];
                    String oppFieldType=string.valueof(oppFieldByName.get(oppFieldName).getType());
                    String snapFieldName=snapshotHeaderFields[i];
                    String snapFieldType=string.valueof(snapshotFieldByName.get(snapFieldName).getType());
                    Object value=opp.get(oppFieldName);
                    if(oppFieldType=='DATETIME'&&snapFieldType=='DATE')
                        value=date.valueof(value);
                    os.put(snapFieldName,value);
                }
                if(opp.Opportunity_Snapshots__r.size()>0)
                    os.Previous_Snapshot__c=opp.Opportunity_Snapshots__r[0].id;
                snapsToCreate.add(os);
            }
            num+=1;
            system.debug('Raz Ben Ron oppSnap snapsToCreate: '+snapsToCreate); 
            Database.SaveResult[] results = Database.insert(snapsToCreate, false);
            for (Database.SaveResult sr : results) {
                if (!sr.isSuccess()) {
                    for(Database.Error e : sr.getErrors()) {
                        Utilities.sendEmail('Error in Opportunity_Snapshot ',e.getMessage()+' '+e.getFields(),new list<string>{'razbe@monday.com'});
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
            Utilities.sendDebugEmail('Error in Opportunity_Snapshot ',e,e.getMessage());   
        }
    }
    public void finish(Database.BatchableContext bc) {
        system.debug('Raz Ben Ron Opp Snapshot, # of batchs: '+num);
        Utilities.sendEmail('Finished Opportunity_Snapshot Creation','# of Snapshots to Create Today: '+totalOppsFromQuery+'<br/># of Opps Snapshots Created: '+totalSnapsCreated+'<br/> # of Opp Snapshots Failed: '+totalSnapsErrors+'<br/> Errors Found: '+errorsFound+' <br/>Date: '+date.today()+' '+datetime.now().format('E'),new list<String>{label.SystemNotificationsDL});   
    }
}