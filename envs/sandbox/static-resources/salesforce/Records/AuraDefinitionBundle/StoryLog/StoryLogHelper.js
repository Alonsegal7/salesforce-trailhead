({
    CONTROLLER: "StoryLogController",
    
    init: function(cmp) {
        var self = this,
            params = {
                actionName: "obtainInitData",
                objectType: cmp.get("v.sObjectName"),
                recordId: cmp.get("v.recordId"),
                monthsBackFromToday: cmp.get("v.numberOfMonths")
            };
        
        cmp.set("v.isLoading", true);
        
        this.executeApex(cmp, {
            controllerName: self.CONTROLLER,
            params: params
        })
        .then(function(data){
            cmp.set("v.criteria", data.criteriaMap);
            if (data.criteriaMap && data.criteriaMap.sourceTypes && data.criteriaMap.sourceTypes.includes("Activity")) {
                cmp.set("v.showTaskType", true);
                }
            cmp.set("v.storyLogItems", data.snapshotList);
            cmp.set("v.isLoading", false);
        })
        .catch(function(error){
            self.showToast({
                type: "error",
                message: error
            });            
            cmp.set("v.isLoading", false);
        });
        
        this.subscribeToStoryLogEvent(cmp);
    },
    
    obtainLogsByCriteria: function(cmp) {
        var criteriaMap = cmp.get("v.criteria");
        
        var self = this,
            params = {
                actionName: "obtainSnaphotsByFilter",
                objectType: cmp.get("v.sObjectName"),
                recordId: cmp.get("v.recordId"),
                criteriaMap: JSON.stringify(criteriaMap)
            };
        cmp.set("v.isLoading", true);
        
        this.executeApex(cmp, {
            controllerName: self.CONTROLLER,
            params: params
        })
        .then(function(data){
            cmp.set("v.storyLogItems", data);
            cmp.set("v.isLoading", false);
        })
        .catch(function(error){
            self.showToast({
                type: "error",
                message: error
            });            
            cmp.set("v.isLoading", false);
        });
    },
    
    subscribeToStoryLogEvent : function(cmp) {
        var self = this;
        const channel = '/event/StoryLogEvent__e';
        const replayId = -1;
        const empApi = cmp.find('empApi');
        empApi.onError($A.getCallback(function (error) { }));
        
        empApi.subscribe(channel, replayId, $A.getCallback(function(eventReceived) {
			
            if (cmp.get("v.recordId") == eventReceived.data.payload.ParentRecordId__c) {
                self.obtainLogsByCriteria(cmp);
            }
        }))
        .then(function(subscription) { });
    }
    
});