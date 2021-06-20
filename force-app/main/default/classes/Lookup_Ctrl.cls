public class Lookup_Ctrl  {
	/**
     * Returns JSON of list of ResultWrapper to Lex Components
     * @objectName - Name of SObject
     * @fld_API_Text - API name of field to display to user while searching
     * @fld_API_Val - API name of field to be returned by Lookup Component
     * @lim   - Total number of record to be returned
     * @fld_API_Search - API name of field to be searched
     * @searchText - text to be searched
	 * @query_literal - Strongly typed SOQL part to add to the search query
	 * @field_API_text_to_add - API name of field to add to the text displayed to the user
     * */
    @AuraEnabled(cacheable=true)
    public static String searchDB(String objectName, String fld_API_Text, String fld_API_Val, 
                                  Integer lim, String fld_API_Search, String searchText, String query_literal, String field_API_text_to_add, String statusField ){
        
        searchText = '\'%' + String.escapeSingleQuotes(searchText.trim()) + '%\'';

		String query =  'SELECT ' + fld_API_Text + ', ' + fld_API_Val;
		if (String.isNotBlank(field_API_text_to_add)) query += ', ' + field_API_text_to_add;
        
        query += ' FROM ' + objectName + ' WHERE ';
		if (String.isNotBlank(statusField) && !Test.isRunningTest()) query += statusField + ' != \'Inactive\' AND ';
		
		if(fld_API_Search.contains('_OR_')){
			List<String> tempList = fld_API_Search.split('_OR_');
			query += '(';
			for (Integer i = 0; i < tempList.size(); i++){
				query += tempList[0] + ' LIKE ' + searchText;
				if (i < tempList.size() - 1) query += ' OR ';
			}
			query += ')';
		}
		else  query += fld_API_Search + ' LIKE ' + searchText;

		if(String.isNotBlank(query_literal)) { query += query_literal; }

        if (lim != null) query += ' LIMIT ' + lim;
        
        system.debug('iCloudius - Searching: ' + query);
        
        List<sObject> sobjList = Database.query(query);
        List<ResultWrapper> lstRet = new List<ResultWrapper>();
        
        for(SObject s : sobjList){
            ResultWrapper obj = new ResultWrapper();
            obj.objName = objectName;
            obj.text = String.valueOf(s.get(fld_API_Text)) ;
            if(String.isNotBlank(field_API_text_to_add) && s.get(field_API_text_to_add) != null && s.get(field_API_text_to_add) != ''){
            	obj.text = obj.text + ' | ' + String.valueOf(s.get(field_API_text_to_add));
            }
            obj.val = String.valueOf(s.get(fld_API_Val))  ;
            lstRet.add(obj);
        }
		
		return JSON.serialize(lstRet);
    }
    
    public class ResultWrapper {
        public String objName { get; set; }
        public String text { get; set; }
        public String val { get; set; }
    }
}