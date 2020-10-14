({
        navigateToValooto : function(component, event, helper) {
            var thisUrl ="https://"+window.location.hostname.replace('lightning.force', 'my.salesforce')+"/flow/Validate_Existing_Contract?oppId="+component.get("v.recordId")+"&retURL=/apex/valt__beforeCanvasPrep?param=CreateQuoteFrom&OppId="+component.get("v.recordId");
            console.log('Raz component.get("v.recordId"): '+component.get("v.recordId"));
            window.open(thisUrl,'_blank');
        },
        navigateToValootoView : function(component, event, helper) {
            var thisUrl ="https://"+window.location.hostname.replace('lightning.force', 'my.salesforce')+"/apex/valt__beforeCanvasPrep?Id="+component.get("v.recordId")+"&param=Quotes";        
            window.open(thisUrl,'_blank');        
        }
})