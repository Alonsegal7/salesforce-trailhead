({
    doneRendering: function(cmp, event, helper) {
    console.log('in function');
      if(!cmp.get("v.isDoneRendering")){
        console.log('in if');
        cmp.set("v.isDoneRendering", true);
        console.log('Raz cmp.get("v.recordId"): '+cmp.get("v.recordId"));
        var thisUrl ="https://"+window.location.hostname.replace('lightning.force', 'my.salesforce')+"/apex/valt__beforeCanvasPrep?Id="+cmp.get("v.recordId")+"&param=Quotes";        
        window.open(thisUrl,'_blank'); 
        $A.get("e.force:closeQuickAction").fire();
      }
    }
  })