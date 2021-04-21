({
    doneRendering: function(cmp, event, helper) {
        var stage = cmp.get("v.simpleRecord.StageName");
        var userProfileName = cmp.get('v.CurrentUser')['Profile'].Name;
        if(userProfileName){
            console.log('Raz Ben Ron userProfileName: '+userProfileName);
            if ((stage=='Closed Won'||stage=='Closed Lost')&&userProfileName!=='System Administrator'){
                console.log('Raz Ben Ron stage: '+stage);
                cmp.set('v.doNotContinue', true);
                console.log('Raz Ben Ron in closed condition');
            } else {
                console.log('Raz Ben Ron in open condition');
                if(!cmp.get("v.isDoneRendering")&&stage){
                    console.log('Raz Ben Ron stage: '+stage);
                    cmp.set("v.isDoneRendering", true);
                    cmp.set('v.doNotContinue', false);
                    console.log('Raz cmp.get("v.recordId"): '+cmp.get("v.recordId"));
                    var thisUrl ="https://"+window.location.hostname.replace('lightning.force', 'my.salesforce')+"/apex/valt__beforeCanvasPrep?Id="+cmp.get("v.recordId")+"&param=Quotes";        
                    console.log('Raz thisUrl: '+thisUrl);
                    window.open(thisUrl,'_blank'); 
                    $A.get("e.force:closeQuickAction").fire();
                }
            }
        }
    }
  })