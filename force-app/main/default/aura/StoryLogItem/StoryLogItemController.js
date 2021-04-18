({
	setIconSize : function(cmp, event, helper) {
		var logItem = cmp.get("v.logItem");
        
        if (logItem && logItem.iconName) {
            if (logItem.iconName.toLowerCase().includes("action:")) {
                	cmp.set("v.iconSize", "x-small");
            } else {
                cmp.set("v.iconSize", "");
            }
        }
        
	}
    
})