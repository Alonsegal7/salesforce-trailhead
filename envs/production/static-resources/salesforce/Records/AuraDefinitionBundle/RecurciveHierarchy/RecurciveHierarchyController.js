({
    init: function(cmp, event, helper) {
        helper.increment(cmp);
    },
    
    iconClick: function(cmp, event, helper) {
        var targetName = event.currentTarget.id;
        helper.invert(cmp, targetName);
    },
    
    navigate: function(cmp, event, helper) {
        helper.navigateToSobject(event.currentTarget.id);
    },
    
    edit: function(cmp, event, helper) {
        debugger;
        var recordId = event.getSource().get("v.name");
        helper.edit(recordId);
    }
});