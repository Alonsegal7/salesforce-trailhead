({
    validate: function (cmp, event, helper) {
        //do apex call to validate and based on outcome call the method below
    },
    convertlead: function (cmp, event, helper) {
        console.log('Here');
        var leadid = cmp.get("v.recordId");
        //var leadid='00Q7Y000006u3eCUAQ';
        console.log('leadid: '+leadid);
        var baseURL = 'https://monday--partial.lightning.force.com';
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": baseURL + '/lightning/cmp/runtime_sales_lead__convertDesktopConsole?leadConvert__leadId='+ leadid
        });
        urlEvent.fire();
    }

})