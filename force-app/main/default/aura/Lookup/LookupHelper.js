({
	itemSelected : function(cmp, evt, hlp) {
        var target = evt.target;   
        var SelIndex = hlp.getIndexFrmParent(target, hlp, "data-selectedIndex");  
        if(SelIndex){
            var serverResult = cmp.get("v.server_result");
            var selItem = serverResult[SelIndex];
            if(selItem.val){
               cmp.set("v.selItem", selItem);
               cmp.set("v.last_ServerResult", serverResult);
            } 
            cmp.set("v.server_result", null); 
        } 
	}, 
    serverCall : function(cmp, evt, hlp) {  
        var target = evt.target;
        var searchText = target.value; 
        var minimumKeys = cmp.get('v.minimumKeys');
        var last_SearchText = cmp.get("v.last_SearchText");
        //Escape button pressed 
        if (evt.keyCode == 27 || !searchText.trim()) { 
            hlp.clearSelection(cmp, evt, hlp);
        }else if(searchText.trim() != last_SearchText  && (/\s+$/.test(searchText) || (minimumKeys >  0 && searchText!=null && typeof(searchText) == "string" && searchText.length >= minimumKeys)) ){ 
            //Save server call, if last text not changed
            //Search only when space character entered
         
            var objectName = cmp.get("v.objectName");
            var field_API_text = cmp.get("v.field_API_text");
            var field_API_val = cmp.get("v.field_API_val");
            var field_API_search = cmp.get("v.field_API_search");
            var query_literal = cmp.get("v.query_literal");
            var field_API_text_to_add = cmp.get("v.field_API_text_to_add");
            var limit = cmp.get("v.limit");
            var statusField = cmp.get("v.statusField");
            
            var action = cmp.get('c.searchDB');
            action.setStorable();
            
            action.setParams({
                objectName : objectName,
                fld_API_Text : field_API_text,
                fld_API_Val : field_API_val,
                lim : limit, 
                fld_API_Search : field_API_search,
                searchText : searchText,
                query_literal : query_literal,
                field_API_text_to_add : field_API_text_to_add,
                statusField : statusField
            });

            action.setCallback(this,function(a){
                this.handleResponse(a, cmp, hlp);
            });
            
            cmp.set("v.last_SearchText", searchText.trim());
            console.log('Server call made');
            $A.enqueueAction(action); 
        }else if(searchText && last_SearchText && searchText.trim() == last_SearchText.trim()){ 
            cmp.set("v.server_result", cmp.get("v.last_ServerResult"));
            console.log('Server call saved');
        }         
	},
    handleResponse : function (res, cmp, hlp){
        if (res.getState() === 'SUCCESS') {
            var retObj = JSON.parse(res.getReturnValue());
            if(retObj.length <= 0){
                var noResult = JSON.parse('[{"text":"No Results Found"}]');
                cmp.set("v.server_result", noResult); 
            	cmp.set("v.last_ServerResult", noResult);
            }else{
                cmp.set("v.server_result", retObj); 
            	cmp.set("v.last_ServerResult", retObj);
            }
        } else if (res.getState() === 'ERROR'){
            var errors = res.getError();
            if (errors) {
                if (errors[0] && errors[0].message) {
                    alert(errors[0].message);
                }
            } 
        }
    },
    getIndexFrmParent : function(target, hlp, attributeToFind){
        //User can click on any child element, so traverse till intended parent found
        var SelIndex = target.getAttribute(attributeToFind);
        while(!SelIndex){
            target = target.parentNode;
			SelIndex = hlp.getIndexFrmParent(target, hlp, attributeToFind);           
        }
        return SelIndex;
    },
    clearSelection: function(cmp, evt, hlp){
        cmp.set("v.selItem", null);
        cmp.set("v.server_result", null);
    },
	isEmpty : function (obj){
		return (obj == null || obj == '' || typeof(obj) == 'undefined' || obj == 'undefined');
	}
})