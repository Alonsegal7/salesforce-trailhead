public class Batch_SearchAndReplace implements Database.Batchable<sObject>, Database.AllowsCallouts{

    private String query;
    private String field;
    private String value;
  
    public Batch_SearchAndReplace(String q, String f, String v){
       this.query = q;
       this.field = f;
       this.value = v;
    }
  
    public Database.QueryLocator start(Database.BatchableContext BC){
        try{
            return Database.getQueryLocator(query);
        }catch(Exception e){
            Utilities.sendDebugEmail('Error in Batch_SearchAndReplace: ',e,e.getMessage());   
            return null;
        }
    }
  
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        try{
            for(sobject s : scope){
                s.put(field,value); 
            }
            Database.update(scope);
        }catch(Exception e){
            Utilities.sendDebugEmail('Error in Batch_SearchAndReplace: ',e,e.getMessage());   
        }
    }
  
    public void finish(Database.BatchableContext BC){
    }
 }