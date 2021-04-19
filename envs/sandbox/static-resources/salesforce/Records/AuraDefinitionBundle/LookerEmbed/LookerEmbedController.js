({
	onRender : function(component, event, helper){
        debugger;
        var accountId = component.get('v.record.primary_pulse_account_id__c');
        var url = component.get('v.iframeUrl');
        console.log(accountId, url);
        console.log('url', url.replace("ACCOUNT_ID", accountId));
        component.set("v.finalUrl", url.replace("ACCOUNT_ID", accountId));
        /*
        var frame = document.getElementById("looker-embed");
        if(frame){
        	console.log("LookerEmbed - onRender", frame.src);
            frame.src=frame.src;
        }
        */
        /*        
        setTimeout(function(){
            var frame = document.getElementById("looker-embed");
            console.log("BigBrainEmbed - setTimeout");                    
            if(frame){
                if(frame.src == 'httsp://bigbrain.me/'){
					frame.src=frame.src;
					console.log("BigBrainPicker - refresh iframe patch", frame.src);                    
               	}
			}
        }, 1400);

        
        */
	}
})