({
	doInit : function(cmp, evt, hlp) {
		console.log('Lookup loading');
		var minimumKeys = cmp.get('v.minimumKeys');
		if (minimumKeys >  0) {
			var placeholder = cmp.get('v.placeholder');
			cmp.set('v.placeholder', 'Fill at least ' + minimumKeys + ' characters');
		}
	},
	itemSelected : function(cmp, evt, hlp) {
		hlp.itemSelected(cmp, evt, hlp);
	}, 
    serverCall :  function(cmp, evt, hlp) {
		hlp.serverCall(cmp, evt, hlp);
	},
    clearSelection : function(cmp, evt, hlp){
        hlp.clearSelection(cmp, evt, hlp);
    },
	gotoRecord : function (cmp, evt, hlp){
		var theURL = window.location.href;
		var target = evt.target;
		console.log('target: ' + target.id);
		if (theURL.indexOf('lightning') < 0){
			window.open('/' + target.id + '');
		} else {
			var navEvt = $A.get("e.force:navigateToSObject");
			navEvt.setParams({
				"recordId": target.id,
				"slideDevName": "related"
			});
			navEvt.fire();
		}
	},
	selectedItemChanged : function(cmp, evt, hlp){
		var selectedItem = cmp.get('v.selItem');
		if (!hlp.isEmpty(selectedItem)){
			
		}
	}
})