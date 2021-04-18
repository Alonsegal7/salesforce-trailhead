global class LC_AccountHierarchy implements ILCController{
    
    private static final Integer MAX_PARENT_QUERY_LEVEL = 5;
    
    private String queryTemplate = 'SELECT Id, ParentId, Parent.ParentId, Parent.Parent.ParentId, ' + 
            + 'Parent.Parent.Parent.ParentId, Parent.Parent.Parent.Parent.ParentId, ' + 
            + 'Parent.Parent.Parent.Parent.Parent.ParentId FROM Account WHERE Id =: {0}';
    private String query = '';
    
    public Id highestParentId;
    public Id recordId;
    public Set<Id> accountIdSet = new Set<Id>();
    public Map<Id, Account> accountMap;
    
    public class LC_AccountHierarchyException extends Exception {}
    
    public Response executeAction(Map<String, Object> params) {
        String actionName = (String) params.get('actionName');
        String recordId = (String) params.get('recordId');
        system.debug('actionName ' + actionName);
        switch on actionName {
            when 'getHierarchy' {
                return this.getHierarchy(recordId);
            }
            when else {
                throw new LC_AccountHierarchyException('UNKNOWN ACTION '+actionName);
            }
        }
    }
    
    private Response getHierarchy(String recordId) {
        this.recordId = recordId;
        accountIdSet.add(recordId);
        highestParentId = getHighestParent(recordId) != null? getHighestParent(recordId) : recordId;
        
        system.debug('accountIdSet before querying' + accountIdSet);
        accountMap = queryRecords();
        
        system.debug('highestParentId ' + highestParentId);
        system.debug('accountMap ' + accountMap);
        
        return new Response(new Hierarchy(this, highestParentId));
    }
    
    private Id getHighestParent(String recordId) {
        query = String.format(queryTemplate, new List<String>{'recordId'});
        system.debug('query ' + query);
        Account accountRecord = Database.query(query);
        String getterField = 'ParentId';
        Id highestParentId = null;
        Integer i;
        Account currentAccount = accountRecord;
        for(i = 0; i < MAX_PARENT_QUERY_LEVEL; i++) {
            if(currentAccount.get(getterField) != null) {
                highestParentId = (Id) currentAccount.get(getterField);
                accountIdSet.add(highestParentId);
                currentAccount = (Account) currentAccount.getSobject('Parent');
            } else {
                break;
            }
        }
        system.debug('i ' + i);
        if(i == MAX_PARENT_QUERY_LEVEL) {
            system.debug('i = max');
           highestParentId = getHighestParent(highestParentId) != null? getHighestParent(highestParentId) : highestParentId;
        }
        return highestParentId;
    }
    
    private Map<Id, Account> queryRecords() {
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, ParentId, Name, BillingCountry, Plan_Name__c, owner.Name, RecordType.Name,
                                                           (SELECT Id, ParentId, Name, BillingCountry, Plan_Name__c, owner.Name, RecordType.Name FROM ChildAccounts), 
                                                           (SELECT Id, AccountId, Name FROM Contacts ORDER BY Name ASC), 
                                                           (SELECT Id, AccountId, Name, StageName, owner.Name FROM Opportunities ORDER BY Name ASC) 
                                                           FROM Account WHERE (Id =: highestParentId OR ParentId IN: accountIdSet)]);
        
        //get Account data that wasn't included in previous query(another branch/child under recordId)
        queryChildRecordsData(accountMap);
        return accountMap;
    }
    
    private void queryChildRecordsData(Map<Id, Account> accountMap) {
        Set<Id> queriedChildAccountIds = new Set<Id>();
        for(Account acc_i: accountMap.values()) {
            for(Account childAcc_i: acc_i.ChildAccounts) {
                queriedChildAccountIds.add(childAcc_i.Id);
            }
        } 
        system.debug('queriedChildAccountIds ' + queriedChildAccountIds);
        if(!queriedChildAccountIds.isEmpty()) {
        Map<Id, Account> childAccountMap = new Map<Id, Account>([SELECT Id, ParentId, Name, BillingCountry, Plan_Name__c, owner.Name, RecordType.Name,
                                                                (SELECT Id, ParentId, Name, BillingCountry, Plan_Name__c, owner.Name, RecordType.Name FROM ChildAccounts), 
                                                                (SELECT Id, AccountId, Name, Title FROM Contacts ORDER BY Name ASC), 
                                                                (SELECT Id, AccountId, Name, StageName, owner.Name FROM Opportunities ORDER BY Name ASC) 
                                                                FROM Account WHERE Id IN: queriedChildAccountIds]);
            
            queryChildRecordsData(childAccountMap);
            accountMap.putAll(childAccountMap);
        }
    }
    
    global class Hierarchy {
        @AuraEnabled
        global Account currentRecord{get;set;}
        @AuraEnabled
        global List<Hierarchy> childRecords {get;set;} 
        @AuraEnabled
        global Boolean showChilds {get;set;}
        @AuraEnabled
        global Boolean isOpened {get;set;}
        @AuraEnabled
        global Boolean isUnderlined {get;set;}
        
        global Hierarchy(LC_AccountHierarchy instance, Id currentRecordId) {
            this.currentRecord = instance.accountMap.get(currentRecordId);
            if(currentRecordId == instance.recordId) {
                showChilds = true;
                isUnderlined = true;
                if(currentRecordId == instance.highestParentId) {
                    isOpened = true;
                }
            } else if(instance.accountIdSet.contains(currentRecordId)) {
                showChilds = true;
                isOpened = true;
            }
            this.childRecords = new List<Hierarchy>();
            if(!currentRecord.ChildAccounts.isEmpty()) {
                for(Account childAcc_i: currentRecord.ChildAccounts) {
                    this.childRecords.add(new Hierarchy(instance, childAcc_i.Id));
                }
            }
        }
    }
}