public without sharing class Sale_Snapshots implements Database.Batchable<sObject>, Database.Stateful,Schedulable{
    public Integer num=0;
    public Integer totalSnapsCreated=0;
    public Sale_Snapshots() {
    }
    public void execute(SchedulableContext sc) {
        try{
            Utilities.cleanFlexQueue();
            Database.executeBatch(this,50);
        }catch(Exception e){
            Utilities.sendDebugEmail('Error in Sale_Snapshots ',e,e.getMessage());   
        }
    }
    public Database.querylocator start(Database.BatchableContext BC){
        String query='';
        try{
            //the snapshots are taken on Sundays/Wednesdays/1st day on the month/last day of the month, without duplications
            dateTime today=dateTime.now();
            dateTime tomorrow=dateTime.now()+1;
            query='select Id,ARR__c,Close_Date__c,Expected_Plan_Seats__c,GB_Forecast_ARR__c,gb_sale__c,Is_Sale_Complete__c,Probability__c, ';
            query+=' Record_Type_Number__c,Sale_cycle__c,Owner__c,Owner__r.FirstName,Owner__r.LastName, Owner__r.Team__c,createddate, ';
            query+=' Owner__r.Manager.FirstName,Owner__r.Manager.LastName, Owner__r.Office__c,FinalSaleStatus__c,RecordType.Name ';
            query+=' from Sale__c WHERE Close_Date__c>=THIS_MONTH and  (Close_Date__c=THIS_QUARTER or Close_Date__c=NEXT_QUARTER) ';      
            if(!(today.format('E')=='Sun'||today.format('E')=='Wed'||today.day()==1||today.day()>tomorrow.day())&&!test.isRunningTest())
                query+=' limit 0 ';
        }catch(Exception e){
            Utilities.sendDebugEmail('Error in Sale_Snapshots ',e,e.getMessage());   
        }
        return Database.getQueryLocator(query); 
    }

    public void execute(Database.BatchableContext bc, List<Sale__c> scope) {
        try{
            list<Sale_Snapshot__c> snapsToCreate= new list<Sale_Snapshot__c>();
            dateTime today=dateTime.now();
            dateTime tomorrow=today+1;
            boolean isOngoing=today.format('E')=='Sun'||today.format('E')=='Wed'?true:false;
            boolean isFirst=today.day()==1?true:false;
            boolean isLast=today.day()>tomorrow.day()?true:false;
            for(Sale__c sale: scope){
                Sale_Snapshot__c ss= new Sale_Snapshot__c(name=string.valueof(datetime.now().format('dd/MM/YYYY HH:mm')),
                                                        Sale__c=sale.id,
                                                        ARR__c=sale.ARR__c,
                                                        Close_Data__c=sale.Close_Date__c,
                                                        Expected_Plan_Seats__c=sale.Expected_Plan_Seats__c,
                                                        GB_Forecast_ARR__c=sale.GB_Forecast_ARR__c,
                                                        GB_Sale__c=sale.gb_sale__c,
                                                        Final_Sale_Status__c=string.valueof(sale.Is_Sale_Complete__c),
                                                        Probability__c=sale.Probability__c,
                                                        Record_Type_Number__c=sale.Record_Type_Number__c,
                                                        Sale_Cycle__c=sale.Sale_cycle__c,
                                                        Sale_Owner__c=sale.Owner__r.FirstName+' '+sale.Owner__r.LastName,
                                                        Owner_Team__c=sale.Owner__r.Team__c,
                                                        Owner_Office__c=sale.Owner__r.Office__c,
                                                        Owner_Manager__c=sale.Owner__r.Manager.FirstName+' '+sale.Owner__r.Manager.LastName,
                                                        Sale_Status__c=sale.FinalSaleStatus__c,
                                                        Sale_Record_Type__c=sale.RecordType.Name,
                                                        Sale_Created_Date__c=date.valueof(sale.Createddate),
                                                        Bi_Weekly_Snapshot__c=isOngoing,
                                                        End_of_Month__c=isLast,
                                                        Start_of_Month__c=isFirst,
                                                        Snapshot_Date__c=date.today());
                snapsToCreate.add(ss);
            }
            num+=1;
            totalSnapsCreated+=snapsToCreate.size();
            insert snapsToCreate;
        }catch(Exception e){
            Utilities.sendDebugEmail('Error in Sale_Snapshots ',e,e.getMessage());   
        }
    }
    public void finish(Database.BatchableContext bc) {
        system.debug('Raz Ben Ron ERDU # of batchs: '+num);
        Utilities.sendEmail('Finished Sale_Snapshots Creation','# of Sale Snapshots created: '+totalSnapsCreated+' today: '+date.today()+' '+datetime.now().format('E'),new list<String>{label.SystemNotificationsDL});   
    }
}