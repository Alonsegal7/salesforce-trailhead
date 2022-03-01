public without sharing class starRatingController {
    @AuraEnabled(cacheable=true)
    public static List<Star_Rating_Question__mdt> getQuestionsList(String surveyName) {
        return [
            SELECT Field_API_Name__c, Question_Text__c
            FROM Star_Rating_Question__mdt
            WHERE Is_Active__c = true and Survey_Name__c =: surveyName
        ];
    }

    @AuraEnabled
    public static sobject updateValues(Id recordId, String objectApiName, Map<String,String> valuesMap, String surveyFilledField) {
        try {
            string query = 'select Id from '+objectApiName+' where Id = \''+recordId+'\'';
            sobject recToUpdate = Database.query(query);
            for(String key: valuesMap.keySet()){
                recToUpdate.put(key, Decimal.valueOf(valuesMap.get(key))); //the answer fields must be of type Number
            }
            if(surveyFilledField != null && surveyFilledField != ''){
                recToUpdate.put(surveyFilledField, true);
            }
            Database.update(recToUpdate);
            return recToUpdate;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + e.getStackTraceString());
        }  
    }
}
