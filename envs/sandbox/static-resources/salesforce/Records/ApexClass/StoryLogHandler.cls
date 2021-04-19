/*************************************************************************
    * Created by: Synebo/ Anastasia Sapihora
    * Created date: 02 February 2020
    * Description:
************************************************************************/

public virtual class StoryLogHandler {

    @TestVisible
    private TriggerContext context;
    @TestVisible
    private static Map<String, LoopCount> loopCountMap;
    @TestVisible
    private Boolean isTriggerExecuting;
    private Schema.SObjectType sObjectType;
    public StoryLogUtils.StoryLogSetting storyLogSetting;
    private List<StoryLogSnapshot__c> storyLogSnapshots;
    private static Map<String, Map<String, StoryLogSnapshot__c>> storyLogSnapshotsMap;
    private List<StoryLogEvent__e> storyLogEventsList;

    public Map<Id, StoryLogItemSetting__c> storyLogItemSettingMap;

    static {
        loopCountMap = new Map<String, LoopCount>();
        storyLogSnapshotsMap = new Map<String, Map<String, StoryLogSnapshot__c>>();
    }

    public StoryLogHandler() {
        this.setTriggerContext();
        this.storyLogSnapshots = new List<StoryLogSnapshot__c>();
        this.storyLogEventsList = new List<StoryLogEvent__e>();
    }

    public void setSObjectType(Schema.SObjectType sObjectType) {
        this.sObjectType = sObjectType;
    }

    public Schema.SObjectType getSObjectType() {
        return this.sObjectType;
    }

    public void setStorySettings() {
        if (this.sObjectType == null || this.sObjectType.getDescribe() == null || !this.sObjectType.getDescribe().isAccessible()) {
            return;
        }

        this.storyLogSetting = StoryLogUtils.obtainStoryLogSettings(this.sObjectType);
        if (this.storyLogSetting == null) {
            return;
        }

        this.storyLogItemSettingMap = this.storyLogSetting.storyLogItemSettingMap;
    }

    public void setMaxLoopCount(Integer max) {
        String handlerName = getHandlerName();
        if (!StoryLogHandler.loopCountMap.containsKey(handlerName)) {
            StoryLogHandler.loopCountMap.put(handlerName, new LoopCount(max));
        } else {
            StoryLogHandler.loopCountMap.get(handlerName).setMax(max);
        }
    }

    public void clearMaxLoopCount() {
        this.setMaxLoopCount(-1);
    }

    public void run() {
        try {
            addToLoopCount();
        } catch (StoryLogHandlerException exc) {
            return;
        }

        if (this.storyLogSetting == null) {
            return;
        }

        if (this.context == TriggerContext.AFTER_INSERT && this.sObjectType.getDescribe().isCreateable()) {
            this.afterInsert();
        } else if (this.context == TriggerContext.AFTER_UPDATE && this.sObjectType.getDescribe().isUpdateable()) {
            this.afterUpdate();
        } else if (this.context == TriggerContext.AFTER_DELETE && this.sObjectType.getDescribe().isDeletable()) {
            this.afterDelete();
        } else if (this.context == TriggerContext.AFTER_UNDELETE && this.sObjectType.getDescribe().isUndeletable()) {
            this.afterUndelete();
        }

        if (this.context == TriggerContext.BEFORE_UPDATE) {
            Utils.updateRecursiveOldMap(Trigger.newMap);
        }

        this.createSnapshots();
        List<Database.SaveResult> saveResultList = EventBus.publish(this.storyLogEventsList);
    }

    public void addStoryLogEvent(Id parentRecordId) {
        this.storyLogEventsList.add(StoryLogUtils.generateStoryLogEvent(parentRecordId));
    }

    public void addSnapshot2(StoryLogSnapshot__c snapshot) {
        if (snapshot.Id != null) {
            return;
        }

        if (!storyLogSnapshotsMap.containsKey(snapshot.ParentRecordId__c)) {
            storyLogSnapshotsMap.put(snapshot.ParentRecordId__c, new Map<String, StoryLogSnapshot__c>());
        }
        System.debug('addSnapshot2');
        if (!storyLogSnapshotsMap.get(snapshot.ParentRecordId__c).containsKey(snapshot.StoryLogItemSetting__c + snapshot.FieldLabel__c + snapshot.GroupKey__c)) {
            storyLogSnapshotsMap.get(snapshot.ParentRecordId__c).put(snapshot.StoryLogItemSetting__c + snapshot.FieldLabel__c + snapshot.GroupKey__c, snapshot);
        }
    }

    public void addSnapshots(List<StoryLogSnapshot__c> snapshotList) {
        this.storyLogSnapshots.addAll(snapshotList);
        for (StoryLogSnapshot__c snapshot_i : snapshotList) {
            this.addSnapshot2(snapshot_i);
        }
    }

    public void createSnapshots() {
        this.storyLogSnapshots.clear();
        for (String key_i : storyLogSnapshotsMap.keySet()) {
            this.storyLogSnapshots.addAll(storyLogSnapshotsMap.get(key_i).values());
        }

        if (!this.storyLogSnapshots.isEmpty()) {
            Set<String> fieldNameSet = new Set<String>();
            Set<String> recordIdSet = new Set<String>();
            for (StoryLogSnapshot__c snapshot_i : this.storyLogSnapshots) {
                if (String.isNotBlank(snapshot_i.FieldName__c)) {
                    fieldNameSet.add(snapshot_i.FieldName__c);
                }
                if (String.isNotBlank(snapshot_i.RecordId__c)) {
                    recordIdSet.add(snapshot_i.RecordId__c);
                }
            }

            Map<String, StoryLogSnapshot__c> mmmm = new Map<String, StoryLogSnapshot__c>();
            Map<String, Id> mmmm2 = new Map<String, Id>();
            if (!fieldNameSet.isEmpty() || !recordIdSet.isEmpty()) {
                List<StoryLogSnapshot__c> existedSSnapshots = [
                        SELECT Id, FieldName__c, RecordId__c, OldValue__c, GroupKey__c, ParentSnapshot__c
                        FROM StoryLogSnapshot__c
                        WHERE (FieldName__c IN:fieldNameSet OR RecordId__c IN: recordIdSet) AND CreatedDate >= :Datetime.now().addMinutes(-10)
                ];
                if (!existedSSnapshots.isEmpty()) {
                    for (StoryLogSnapshot__c snapshot_i : existedSSnapshots) {
                        if (String.isNotBlank(snapshot_i.FieldName__c) && !mmmm.containsKey(snapshot_i.FieldName__c)) {
                            mmmm.put(snapshot_i.FieldName__c, snapshot_i);
                        }
                        if (String.isNotBlank(snapshot_i.RecordId__c) && !mmmm.containsKey(snapshot_i.RecordId__c)) {
                            mmmm2.put(snapshot_i.RecordId__c, snapshot_i.Id);
                        }
                    }
                }
            }

            Set<Id> tmpIdSet = new Set<Id>();
            List<StoryLogSnapshot__c> listToUpsert = new List<StoryLogSnapshot__c>();
            for (StoryLogSnapshot__c snapshot_i : this.storyLogSnapshots) {
                if (mmmm.containsKey(snapshot_i.FieldName__c) && snapshot_i.Id == null) {
                    snapshot_i.Id = mmmm.get(snapshot_i.FieldName__c).Id;
                    snapshot_i.OldValue__c = mmmm.get(snapshot_i.FieldName__c).OldValue__c;
                }
                if (mmmm2.containsKey(snapshot_i.RecordId__c) && snapshot_i.Id == null) {
                    snapshot_i.Id = mmmm2.get(snapshot_i.RecordId__c);
                }

                if (snapshot_i.Id != null && !tmpIdSet.contains(snapshot_i.Id) || snapshot_i.Id == null) {
                    tmpIdSet.add(snapshot_i.Id);
                    listToUpsert.add(snapshot_i);
                }
            }
            upsert listToUpsert;

            List<StoryLogSnapshot__c> groupList = [
                    SELECT Id, GroupKey__c
                    FROM StoryLogSnapshot__c
                    WHERE Id IN: listToUpsert AND IsGrouped__c = true
                    ORDER BY GroupKey__c
            ];
            if (!groupList.isEmpty()) {
                Map<String, Id> groupKeyToIdMap = new Map<String, Id>();
                for (StoryLogSnapshot__c storyLogSnapshot_i : groupList) {
                    if (!groupKeyToIdMap.containsKey(storyLogSnapshot_i.GroupKey__c)) {
                        groupKeyToIdMap.put(storyLogSnapshot_i.GroupKey__c, storyLogSnapshot_i.Id);
                    }
                }

                List<StoryLogSnapshot__c> toUpdate = new List<StoryLogSnapshot__c>();
                for (StoryLogSnapshot__c storyLogSnapshot_i : listToUpsert) {
                    if (String.isBlank(storyLogSnapshot_i.GroupKey__c) || storyLogSnapshot_i.IsGrouped__c) {
                        continue;
                    }
                    storyLogSnapshot_i.ParentSnapshot__c = groupKeyToIdMap.get(storyLogSnapshot_i.GroupKey__c);
                    toUpdate.add(storyLogSnapshot_i);
                }
                if (!toUpdate.isEmpty()) {
                    update toUpdate;
                }
            }

            this.storyLogSnapshots.clear();
        }
    }

    @TestVisible
    private void setTriggerContext() {
        this.setTriggerContext(null, false);
    }

    @TestVisible
    private void addToLoopCount() {
        String handlerName = getHandlerName();
        if (StoryLogHandler.loopCountMap.containsKey(handlerName)) {
            Boolean exceeded = StoryLogHandler.loopCountMap.get(handlerName).increment();
            if (exceeded) {
                Integer max = StoryLogHandler.loopCountMap.get(handlerName).max;
                throw new StoryLogHandlerException('Maximum loop count of ' + String.valueOf(max) + ' reached in ' + handlerName);
            }
        }
    }

    @TestVisible
    private void setTriggerContext(String ctx, Boolean testMode) {
        if (!Trigger.isExecuting && !testMode) {
            this.isTriggerExecuting = false;
            return;
        } else {
            this.isTriggerExecuting = true;
        }

        if ((Trigger.isExecuting && Trigger.isBefore && Trigger.isInsert) ||
                (ctx != null && ctx == 'before insert')) {
            this.context = TriggerContext.BEFORE_INSERT;
        } else if ((Trigger.isExecuting && Trigger.isBefore && Trigger.isUpdate) ||
                (ctx != null && ctx == 'before update')) {
            this.context = TriggerContext.BEFORE_UPDATE;
        } else if ((Trigger.isExecuting && Trigger.isBefore && Trigger.isDelete) ||
                (ctx != null && ctx == 'before delete')) {
            this.context = TriggerContext.BEFORE_DELETE;
        } else if ((Trigger.isExecuting && Trigger.isAfter && Trigger.isInsert) ||
                (ctx != null && ctx == 'after insert')) {
            this.context = TriggerContext.AFTER_INSERT;
        } else if ((Trigger.isExecuting && Trigger.isAfter && Trigger.isUpdate) ||
                (ctx != null && ctx == 'after update')) {
            this.context = TriggerContext.AFTER_UPDATE;
        } else if ((Trigger.isExecuting && Trigger.isAfter && Trigger.isDelete) ||
                (ctx != null && ctx == 'after delete')) {
            this.context = TriggerContext.AFTER_DELETE;
        } else if ((Trigger.isExecuting && Trigger.isAfter && Trigger.isUndelete) ||
                (ctx != null && ctx == 'after undelete')) {
            this.context = TriggerContext.AFTER_UNDELETE;
        }
    }

    protected virtual void afterUpdate() {
    }

    protected virtual void afterInsert() {
    }

    protected virtual void afterDelete() {
    }

    protected virtual void afterUndelete() {
    }

    @TestVisible
    public enum TriggerContext {
        BEFORE_INSERT, BEFORE_UPDATE, BEFORE_DELETE,
        AFTER_INSERT, AFTER_UPDATE, AFTER_DELETE,
        AFTER_UNDELETE
    }

    @TestVisible
    private class LoopCount {
        private Integer max;
        private Integer count;

        public LoopCount() {
            this.max = 5;
            this.count = 0;
        }

        public LoopCount(Integer max) {
            this.max = max;
            this.count = 0;
        }

        public Boolean increment() {
            this.count++;
            return this.exceeded();
        }

        public Boolean exceeded() {
            if (this.max < 0) return false;
            if (this.count > this.max) {
                return true;
            }
            return false;
        }

        public Integer getMax() {
            return this.max;
        }

        public Integer getCount() {
            return this.count;
        }

        public void setMax(Integer max) {
            if(this.max != -1) {
                this.max = max;
            }
        }
    }

    @TestVisible
    private String getHandlerName() {
        return String.valueOf(this).substring(0, String.valueOf(this).indexOf(':'));
    }

    public class StoryLogHandlerException extends Exception {
    }
}