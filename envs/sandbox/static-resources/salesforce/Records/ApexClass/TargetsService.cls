public class TargetsService {
	public static void updateSalesOnTargetCreation(Target__c[] targets){
        try{
            for(Target__c target : targets){
                if(target.User__c == null || target.Target_Date__c == null) continue;
                Sale__c[] sales = [select Id 
                                    from Sale__c 
                                    WHERE Target__c = null AND 
                                    ((RecordTypeId='0121t000000IQYOAA4' AND Owner__c=:target.User__c ) or /*internal*/
                                    (RecordTypeId='0121t000000IQYTAA4' AND Owner_s_Manager__c=:target.User__c)) /*partners*/
                                        AND CALENDAR_MONTH(Close_Date__c) = :target.Target_Date__c.month()
                                        AND CALENDAR_YEAR(Close_Date__c) = :target.Target_Date__c.year()];
                
                if(sales.size() > 0){
                    for(Sale__c sale : sales){
                        sale.Target__c = target.Id;    
                    }
                    update sales;    
                }
            }
        }catch(Exception e){
            Utilities.sendDebugEmail('Error in updateSalesOnTargetCreation ',e,e.getMessage());   
        }
    }
    
    public static void updateSaleTarget(Sale__c sale){
        try{
            if(sale == null) return;
            if(sale.Close_Date__c == null || sale.Owner__c == null){
                sale.Target__c = null;
                return;
            }
            list<Target__c> targets=new list<Target__c>();
            string query='select Id from Target__c where ';
            
            if(sale.RecordTypeId=='0121t000000IQYTAA4'&&sale.Owner_s_Manager__c!=null){//partners  
                query+=' User__c=\''+sale.Owner_s_Manager__c+'\'';
            }
            else{//internal
                query+=' User__c=\''+sale.Owner__c+'\'';
            }
            query+=' AND CALENDAR_MONTH(Target_Date__c)='+sale.Close_Date__c.month();
            query+=' AND CALENDAR_YEAR(Target_Date__c)='+sale.Close_Date__c.year();
            targets=Database.query(query);

            if(targets.size() > 0){
                sale.Target__c = targets[0].Id;
            }else{
                sale.Target__c = null;
            }
        }catch(Exception e){
            Utilities.sendDebugEmail('Error in updateSaleTarget ',e,e.getMessage());   
        }
    }
}