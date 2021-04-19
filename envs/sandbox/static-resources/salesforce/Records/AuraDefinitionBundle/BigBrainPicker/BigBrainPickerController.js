({
	 onRender : function(component, event, helper){
        var frame = document.getElementById("bb");
        if(frame){
        	console.log("BigBrainPicker - onRender", frame.src);     
        }
        setTimeout(function(){
            var frame = document.getElementById("bb");
            var url = component.get("v.iframeUrl");
			if(frame){
               frame.src=frame.src + '#' + Math.random().toString(36).substring(7);
               console.log("BigBrainPicker - refresh iframe patch");
               /*console.log(frame.src.replace(/\/$/, ""));
               console.log(url);
               if(frame.src.replace(/\/$/, "") === url){
               		console.log("BigBrainPicker - refresh iframe patch");
               		frame.src=frame.src + '#' + Math.random().toString(36).substring(7);         
               }*/
            }
        }, 1400);
	}
})