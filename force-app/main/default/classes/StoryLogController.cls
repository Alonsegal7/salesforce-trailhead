public with sharing class StoryLogController /*implements ISuperController*/ {/*

    public Response executeAction(Map<String, Object> params) {
        String actionName = (String) params.get('actionName');        
        if (actionName == 'obtainInitData') {
            return this.obtainInitData((String) params.get('objectType'),
                                       (String) params.get('recordId'),
                                       (Decimal) params.get('monthsBackFromToday'));
        } else if (actionName == 'obtainSnaphotsByFilter') {
            return new Response(this.obtainSnapshotsByFilter(
                					(String) params.get('objectType'),
                                    (String) params.get('recordId'),
                					(Map<String, Object>) JSON.deserializeUntyped((String) params.get('criteriaMap'))
                                ));
        } else {
            throw new StoryLogControllerException('INVALID_ACTION: ' + actionName);
        }
    }
        
    private Response obtainInitData(String objectType, String recordId, Decimal monthsBackFromToday) {
        Map<String, Object> responseObject = new Map<String, Object>();
        
        Date dateTo = Date.today(),
             dateFrom = (monthsBackFromToday != null && monthsBackFromToday >= 0) ? dateTo.addMonths(-monthsBackFromToday.intValue()) : null;
        
        Map<String, String> sourceTypeMap = StoryLogUtils.obtainSourceTypes(Schema.getGlobalDescribe().get(objectType));
        List<Map<String, String>> sourceValueToLabelList = new List<Map<String, String>>();
        for (String type_i : sourceTypeMap.keySet()) {
            sourceValueToLabelList.add(new Map<String, String> {
                'label' => sourceTypeMap.get(type_i),
                'value' => type_i
            });
        }

        List<Utils.PicklistValue> taskSubTypeOptions = Utils.buildPickListOptionsBySchema(Schema.Task.getSObjectType(), Schema.Task.Type, false);
        Set<String> taskSubTypeValues = new Set<String>();
        for (Utils.PicklistValue option_i : taskSubTypeOptions) {
            taskSubTypeValues.add(option_i.value);
        }
        Map<String, Object> criteriaMap = new Map<String, Object>{
                'sourceTypes' => sourceValueToLabelList,
                'sourceSupTypeOptions' => taskSubTypeOptions,
                'sourceSubTypes' => JSON.serialize(taskSubTypeValues),
                'sourceTypeValues' => JSON.serialize(sourceTypeMap.keySet()),
                'dateFrom' => (dateFrom != null) ? dateFrom : null,
                'dateTo' => dateTo
        };

        responseObject.put('criteriaMap', criteriaMap);
        responseObject.put('snapshotList', this.obtainSnapshotsByFilter(objectType, recordId, criteriaMap));
        return new Response(responseObject);
    }
    
    private List<Snapshot> obtainSnapshotsByFilter(String objectType, String recordId, Map<String, Object> criteriaMap) {
        List<Snapshot> snapshotList = new List<Snapshot>();
        String fields = String.join(Utils.getAllObjectFieldsApiNames('StoryLogSnapshot__c'), ',');

        String queryString = ' SELECT ' + fields + ', User__r.Name, StoryLogItemSetting__r.GroupLogs__c, (SELECT ' + fields + ' FROM ChildSnapshots__r)'
                           + ' FROM StoryLogSnapshot__c '
                           + ' WHERE ParentRecordId__c = :recordId '
                           + ' AND ParentSnapshot__c = null '
            			   + ' AND StoryLogItemSetting__r.IsActive__c = true '
            			   + ' AND StoryLogItemSetting__r.StoryLogSetting__r.IsActive__c = true ';
        if (String.isNotBlank(String.valueOf(criteriaMap.get('dateFrom')))) {
            Date dateFrom = Date.valueOf(String.valueOf(criteriaMap.get('dateFrom')));
            queryString += ' AND DAY_ONLY(DateTime__c) >= :dateFrom ';
        }
        if (String.isNotBlank(String.valueOf(criteriaMap.get('dateTo')))) {
            Date dateTo = Date.valueOf(String.valueOf(criteriaMap.get('dateTo')));
            queryString += ' AND DAY_ONLY(DateTime__c) <= :dateTo ';
        }
        if (String.isNotBlank((String) criteriaMap.get('sourceTypeValues'))) {
            List<String> sourceTypesList = (List<String>) JSON.deserialize((String) criteriaMap.get('sourceTypeValues'), List<String>.class);
            queryString += (!sourceTypesList.isEmpty())
                         ? ' AND StoryLogItemSetting__r.SourceAPIName__c IN :sourceTypesList '
                         : '';
        }

        if (String.isNotBlank((String) criteriaMap.get('sourceSubTypes'))) {
            List<String> subtypeList = (List<String>) JSON.deserialize((String) criteriaMap.get('sourceSubTypes'), List<String>.class);
            queryString += (!subtypeList.isEmpty())
                         ? ' AND (SubType__c = null OR SubType__c IN :subtypeList) '
                         : '';
        }
        queryString += ' ORDER BY DateTime__c DESC';
        System.debug(queryString);

        List<StoryLogSnapshot__c> logSnapshotList = Database.query(queryString);
        if (!logSnapshotList.isEmpty()) {
            for (StoryLogSnapshot__c storyLogSnapshot_i : logSnapshotList) {
                snapshotList.add(
                        new Snapshot(storyLogSnapshot_i, storyLogSnapshot_i.StoryLogItemSetting__r.GroupLogs__c)
                );
            }
        }
        return snapshotList;
    }

    public class Snapshot {
        @AuraEnabled
        public Id id { get; set; }
        @AuraEnabled
        public String sourceLabel { get; set; }
        @AuraEnabled
        public String sourceDetails { get; set; }
        @AuraEnabled
        public Id recordId { get; set; }
        @AuraEnabled
        public String descriptionHtml { get; set; }
        @AuraEnabled
        public String iconName { get; set; }
        @AuraEnabled
        public String snapshotType { get; set; }
        @AuraEnabled
        public Id doneByUserId { get; set; }
        @AuraEnabled
        public String doneByUserName { get; set; }
        @AuraEnabled
        public Datetime doneAt { get; set; }
        public Snapshot(StoryLogSnapshot__c storyLogSnapshot, Boolean isGrouped) {
            this.id = storyLogSnapshot.Id;
            this.sourceLabel = storyLogSnapshot.SourceLabel__c;
            this.iconName = storyLogSnapshot.IconName__c;
            this.doneByUserId = storyLogSnapshot.User__c;
            this.doneByUserName = storyLogSnapshot.User__r.Name;
            this.doneAt = storyLogSnapshot.DateTime__c;
            this.snapshotType = storyLogSnapshot.Type__c;
            this.sourceDetails = '';
            this.descriptionHtml = '';

            if (storyLogSnapshot.Type__c == 'FieldUpdate') {
                if (!isGrouped || storyLogSnapshot.ChildSnapshots__r.isEmpty()) {
                    this.descriptionHtml = storyLogSnapshot.ShortDescription__c;
                    this.sourceDetails = storyLogSnapshot.FieldLabel__c;
                } else if (!storyLogSnapshot.ChildSnapshots__r.isEmpty()) {
                    this.descriptionHtml += '<ul>';
                    for (StoryLogSnapshot__c chiLogSnapshot_i : storyLogSnapshot.ChildSnapshots__r) {

                        if (!this.sourceDetails.contains('...') && this.sourceDetails.length() + chiLogSnapshot_i.FieldLabel__c.length() < 82) {
                            this.sourceDetails += chiLogSnapshot_i.FieldLabel__c + ', ';
                        } else if (!this.sourceDetails.contains('...')) {
                            this.sourceDetails = this.sourceDetails.removeEnd(', ') + '... (' + storyLogSnapshot.ChildSnapshots__r.size() + ')';
                        }

                        this.descriptionHtml += '<li>' + chiLogSnapshot_i.ShortDescription__c + '</li>';
                    }
                    this.descriptionHtml += '</ul>';
                    this.sourceDetails = this.sourceDetails.removeEnd(', ');
                }
            } else if (storyLogSnapshot.Type__c == 'RelatedObject') {
                this.recordId = storyLogSnapshot.RecordId__c;
                this.sourceDetails = storyLogSnapshot.RecordName__c;
                this.descriptionHtml = storyLogSnapshot.ShortDescription__c;
            }
        }
    }
    
    public class StoryLogControllerException extends Exception {}*/
}