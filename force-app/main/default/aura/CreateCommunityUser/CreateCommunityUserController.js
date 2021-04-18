({
	doInit : function(cmp, evt, hlp) {
        hlp.getInitials(cmp, evt);
    },
    closeDialog : function(){
    	$A.get("e.force:closeQuickAction").fire();
    }
})