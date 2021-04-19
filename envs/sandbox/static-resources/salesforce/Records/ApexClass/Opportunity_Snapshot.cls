public without sharing class Opportunity_Snapshot implements Database.Batchable<sObject>, Database.Stateful,Schedulable{
    public Integer num=0;
    public Integer totalSnapsCreated=0;
    public Date dateInput;
    public Opportunity_Snapshot() {
    }

    public void execute(SchedulableContext sc) {
        try{
            Database.executeBatch(this,50);
        }catch(Exception e){
            Utilities.sendDebugEmail('Error in Opportunity_Snapshot ',e,e.getMessage());   
        }
    }
    public Database.querylocator start(Database.BatchableContext BC){
        string query='';
        try{
            //the snapshots are taken on Sundays/Wednesdays/1st day on the month/last day of the month, without duplications
            dateTime today=dateTime.now();
            dateTime tomorrow=today+1;
            query='select Id,CloseDate,Forecasted__c,Forecasted_ARR__c,Forecast_ARR__c,Probability,Record_Type__c,createddate, ';
            query+=' OwnerId,Owner.FirstName,Owner.LastName, Owner.Team__c,GB_opp__c,Green_Bucket_ARR__c,StageName, ';
            query+=' Owner.Manager.FirstName,Owner.Manager.LastName, Owner.Office__c,RecordType.Name ';
            query+=' from Opportunity WHERE CloseDate>=THIS_MONTH and  (CloseDate=THIS_QUARTER or CloseDate=NEXT_QUARTER) '; 
            if(!(today.format('E')=='Sun'||today.format('E')=='Wed'||today.day()==1||today.day()>tomorrow.day())&&!test.isRunningTest())
                query+=' limit 0 '; 
        }catch(Exception e){
            Utilities.sendDebugEmail('Error in Opportunity_Snapshot ',e,e.getMessage());   
        }
        return Database.getQueryLocator(query);  
    }

    public void execute(Database.BatchableContext bc, List<Opportunity> scope) {
        try{
            list<Opportunity_Snapshot__c> snapsToCreate= new list<Opportunity_Snapshot__c>();
            dateTime today=dateTime.now();
            dateTime tomorrow=today+1;
            boolean isOngoing=today.format('E')=='Sun'||today.format('E')=='Wed'?true:false;
            boolean isFirst=today.day()==1?true:false;
            boolean isLast=today.day()>tomorrow.day()?true:false;
            for(Opportunity opp: scope){
                Opportunity_Snapshot__c os= new Opportunity_Snapshot__c(name=string.valueof(datetime.now().format('dd/MM/YYYY HH:mm')),
                                                        Opportunity__c=opp.id,
                                                        Commit__c=opp.Forecasted__c?1:0,
                                                        Close_Date__c=opp.CloseDate,
                                                        Commit_ARR__c=opp.Forecasted_ARR__c,
                                                        Forecast_ARR__c=opp.Forecast_ARR__c,
                                                        GB_Opp__c=opp.GB_opp__c,
                                                        Green_bucket_ARR__c=opp.Green_Bucket_ARR__c,
                                                        Record_Type_Number__c=opp.Record_Type__c,
                                                        Probability__c=opp.Probability,
                                                        Owner__c=opp.Owner.FirstName+' '+opp.Owner.LastName,
                                                        Owner_Team__c=opp.Owner.Team__c,
                                                        Owner_Office__c=opp.Owner.Office__c,
                                                        Owner_Manager__c=opp.Owner.Manager.FirstName+' '+opp.Owner.Manager.LastName,
                                                        Opportunity_Record_Type__c=opp.RecordType.Name,
                                                        Stage__c=opp.StageName,
                                                        Opportunity_Created_Date__c=date.valueof(opp.Createddate),
                                                        Bi_Weekly_Snapshot__c=isOngoing,
                                                        End_of_Month__c=isLast,
                                                        Start_of_Month__c=isFirst,
                                                        Snapshot_Date__c=date.today());
                snapsToCreate.add(os);
            }
            num+=1;
            totalSnapsCreated+=snapsToCreate.size();
            insert snapsToCreate;
        }catch(Exception e){
            Utilities.sendDebugEmail('Error in Opportunity_Snapshot ',e,e.getMessage());   
        }
    }
    public void finish(Database.BatchableContext bc) {
        system.debug('Raz Ben Ron ERDU # of batchs: '+num);
        Utilities.sendEmail('Finished Opportunity_Snapshot Creation','# of Opportunity Snapshots created: '+totalSnapsCreated+' today: '+date.today()+' '+datetime.now().format('E'),new list<String>{label.SystemNotificationsDL});   
    }
}