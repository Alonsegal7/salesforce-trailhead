({
	doInit: function (cmp, evt, hlp) {
		console.log('Billing Entity Relate Initializing...');
		hlp.loadInitialParameters(cmp, evt);
	},
	modeChanged : function(cmp, evt, hlp){
		cmp.set('v.currently_selected' , null);
		cmp.set('v.selection_mode', evt.getSource().get('v.label').toLowerCase());
	},
	cbChanged : function(cmp, evt, hlp){
		var source = evt.getSource();
		var sourceName = source.get('v.name');
		var currently_selected = cmp.get('v.currently_selected');
		if (currently_selected == sourceName) {
			cmp.set('v.currently_selected' , null);
		} else {
			cmp.set('v.selected_be', '');
			cmp.set('v.currently_selected' , sourceName);
			cmp.set('v.selection_mode', 'choose existing');
		}
	},
	beChanged : function(cmp, evt, hlp){
		var selectedBE = cmp.get('v.selected_be');
		cmp.set('v.currently_selected', null);
		cmp.set('v.selection_mode', 'search');
	},
	openNew : function(cmp, evt, hlp){
		cmp.set('v.form_new', true);
		cmp.set('v.selected_best_match', null);
		cmp.set('v.selected_more_option', null);
		cmp.set('v.selected_be', '');
		cmp.set('v.currently_selected', null);
		cmp.set('v.selection_mode', '');
	},
	closeNew : function(cmp, evt, hlp){
		cmp.set('v.form_new', false);
	},
	handleSubmit : function (cmp, evt, hlp) {
		console.log('New Billing Entity form attempt submit');
		evt.stopPropagation();
		evt.preventDefault();
		hlp.testUniqu(cmp, evt);
	},
	handleSuccess : function (cmp, evt, hlp) {
		var payload = evt.getParams().response;
		var id = payload.id;
		console.log('Saved Billing Entity Id: ' + id); 
		cmp.set('v.currently_selected', id);
		hlp.relate(cmp, evt);
	},
	handleError : function (cmp, evt, hlp) {
		console.log('Error here');
		//
	},
	relate : function(cmp, evt, hlp){
		hlp.relate(cmp, evt);
	},
    closeDialog : function(){
    	$A.get("e.force:closeQuickAction").fire();
    }
})