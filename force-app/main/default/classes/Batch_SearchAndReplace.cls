public class Batch_SearchAndReplace implements Database.Batchable<sObject>, Database.AllowsCallouts{

    private String query;
    private String field;
    private String value;
    private String textForEmail;
    private List<String> idsList = new List<String>();
  
    public Batch_SearchAndReplace(String q, String f, String v, String textForEmail){
       this.query = q;
       this.field = f;
       this.value = v;
       this.textForEmail = textForEmail;
    }
  
    public Database.QueryLocator start(Database.BatchableContext BC){
        try{
            return Database.getQueryLocator(query);
        }catch(Exception e){
            Utilities.sendEmail('Error in Apex Job Batch_SearchAndReplace: ', e.getMessage() + '\n' + e.getStackTraceString(), new List<String>{UserInfo.getUserEmail(),'biztech@monday.com'}); 
            return null;
        }
    }
  
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        try{
            for(sobject s : scope){
                s.put(field,value); 
                idsList.add(s.Id);
            }
            Database.update(scope);
        }catch(Exception e){
            Utilities.sendEmail('Error in Apex Job Batch_SearchAndReplace: ', e.getMessage() + '\n' + e.getStackTraceString(), new List<String>{UserInfo.getUserEmail(),'biztech@monday.com'}); 
        }
    }
  
    public void finish(Database.BatchableContext BC){
        Utilities.sendEmail(textForEmail+' is finished!', 'List of Ids updated: ' + idsList.toString(), new List<String>{UserInfo.getUserEmail(),'biztech@monday.com'}); 
    }
 }