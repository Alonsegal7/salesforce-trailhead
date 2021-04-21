({
    CONTROLLER: "StoryLogController",
    
    updateInputs: function(cmp) {
        var criteria = cmp.get("v.criteria");
        cmp.set("v.dateFrom", criteria.dateFrom);        
        cmp.set("v.dateTo", criteria.dateTo);
        cmp.set("v.options", criteria.sourceTypes);
        cmp.set("v.subTypeOptions", criteria.sourceSupTypeOptions);
        
        cmp.set("v.sourceTypeValues", JSON.parse(criteria.sourceTypeValues));
        cmp.set("v.sourceSubTypes", JSON.parse(criteria.sourceSubTypes));
    },

    handleCriterionChange: function(cmp) {
        var prevCriteria = cmp.get("v.criteria"),
        	criteria = {
                dateFrom: cmp.get("v.dateFrom"),
                dateTo: cmp.get("v.dateTo"),
                sourceTypes: prevCriteria.sourceTypes,
                sourceSupTypeOptions: prevCriteria.sourceSupTypeOptions,
                sourceTypeValues: JSON.stringify(cmp.get("v.sourceTypeValues")),
                sourceSubTypes: JSON.stringify(cmp.get("v.sourceSubTypes"))
        };

        if (cmp.find("dateFromInput").checkValidity() && cmp.find("dateToInput").checkValidity()
            &&
            (prevCriteria["dateFrom"] != criteria["dateFrom"] ||
             prevCriteria["dateTo"] != criteria["dateTo"] ||
             prevCriteria["sourceSubTypes"] != criteria["sourceSubTypes"] ||
             prevCriteria["sourceTypeValues"] != criteria["sourceTypeValues"])) {
            	cmp.set("v.criteria", criteria);
            	cmp.getEvent("onFilterChange").fire();
        }
    }
})