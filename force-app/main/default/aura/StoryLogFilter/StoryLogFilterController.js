({
    handleSourceTypeChange: function(cmp, event, helper) {
        var sourceTypes = cmp.get("v.sourceTypeValues");
        cmp.set("v.showTaskType", sourceTypes.includes("Task"));
        helper.handleCriterionChange(cmp);
    },

    handleCriterionChange: function(cmp, event, helper) {
        helper.handleCriterionChange(cmp);
    },
    
    updateInputs: function(cmp, event, helper) {
        helper.updateInputs(cmp);
    }
})