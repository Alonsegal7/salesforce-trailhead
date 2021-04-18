({
	fetchProducts : function(component, event) {
		var action = component.get("c.fetchProdcts");
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var records = response.getReturnValue();
				records.forEach(function(record) {
					record.linkName = '/' + record.Id;
					record.CheckBool = false;
				});
				component.set("v.prodList", records);
			}
		});
		$A.enqueueAction(action);
	}
})