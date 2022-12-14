public class Batch_SearchAndReplace implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{

    private String query;
    private String field;
    private String source_field;
    private String value;
    private String textForEmail;
    private Set<Id> idsToQuery;
    private String sobjectName;
    private Map<String,String> fieldsToValuesMap;
    public List<String> updatedIdsList = new List<String>();
    public List<String> emailRecepients = new List<String>{'kseniasm@monday.com'};

  
    public Batch_SearchAndReplace(String q, String f, String v, String textForEmail){
       this.query = q;
       this.field = f;
       this.value = v;
       this.textForEmail = textForEmail;
       if(UserInfo.getProfileId() == '00e1t000001bu2uAAA') emailRecepients.add(UserInfo.getUserEmail());
    }

    public Batch_SearchAndReplace(String q, String f, String v, String textForEmail, String source_f){
        this.query = q;
        this.field = f;
        this.source_field = source_f;
        this.textForEmail = textForEmail;
       if(UserInfo.getProfileId() == '00e1t000001bu2uAAA') emailRecepients.add(UserInfo.getUserEmail());
    }
  
    public Batch_SearchAndReplace(String q, Map<String,String> fieldsToValuesMap, String textForEmail){
        this.query = q;
        this.fieldsToValuesMap = fieldsToValuesMap;
        this.textForEmail = textForEmail;
        if(UserInfo.getProfileId() == '00e1t000001bu2uAAA') emailRecepients.add(UserInfo.getUserEmail());
     }

    public Batch_SearchAndReplace(Set<Id> idsToQuery, String sobjectName, String f, String v, String textForEmail){
        this.idsToQuery = idsToQuery;
        this.sobjectName = sobjectName;
        this.field = f;
        this.value = v;
        this.textForEmail = textForEmail;
        if(UserInfo.getProfileId() == '00e1t000001bu2uAAA') emailRecepients.add(UserInfo.getUserEmail());
    }

    public Batch_SearchAndReplace(Set<Id> idsToQuery, String sobjectName, Map<String,String> fieldsToValuesMap, String textForEmail){
        this.idsToQuery = idsToQuery;
        this.sobjectName = sobjectName;
        this.fieldsToValuesMap = fieldsToValuesMap;
        this.textForEmail = textForEmail;
        if(UserInfo.getProfileId() == '00e1t000001bu2uAAA') emailRecepients.add(UserInfo.getUserEmail());
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        try{
            if(query == null) query = 'select Id from ' + sobjectName + ' where Id in: idsToQuery';
            return Database.getQueryLocator(query);
        }catch(Exception e){
            Utilities.sendEmail('Error in Apex Job Batch_SearchAndReplace: ', e.getMessage() + '\n' + e.getStackTraceString(), emailRecepients); 
            return null;
        }
    }
  
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        try{
            for(sobject s : scope){
                if(fieldsToValuesMap != null && !fieldsToValuesMap.isEmpty()){
                    for(String f: fieldsToValuesMap.keySet()){
                        s.put(f, fieldsToValuesMap.get(f)); 
                    }
                } else if (field != null && value != null){
                    s.put(field,value); 
                } else if (field != null && source_field != null){
                    s.put(field,s.get(source_field)); 
                }
                updatedIdsList.add(s.Id);
            }
            Database.update(scope);
        }catch(Exception e){
            Utilities.sendEmail('Error in Apex Job Batch_SearchAndReplace: ', e.getMessage() + '\n' + e.getStackTraceString(), emailRecepients); 
        }
    }
  
    public void finish(Database.BatchableContext BC){
        Utilities.sendEmail(textForEmail+' is finished!', 'List of Ids updated: ' + updatedIdsList.toString(), emailRecepients); 
    }
 }