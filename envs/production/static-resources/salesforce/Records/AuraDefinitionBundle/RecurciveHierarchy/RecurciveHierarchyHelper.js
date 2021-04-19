({
    increment: function(cmp) {
        var level = cmp.get("v.currentLevel");
        if (level) {
            var level2 = ++level;
            var level3 = ++level2;
            var level5 = level3 + 2;
            cmp.set("v.level2", level2);
            cmp.set("v.level3", level3);
            cmp.set("v.level5", level5);
            cmp.set("v.renderNext", true);
        }
    },
    
    invert: function(cmp, targetName) {
        var currentValue = cmp.get("v." + targetName);
        cmp.set("v." + targetName, !currentValue);
    },
    
    edit: function(recordId) {
        var editRecordEvent = $A.get("e.force:editRecord"); 
        editRecordEvent.setParams({
            "recordId": recordId
        });
        editRecordEvent.fire();
    }
});