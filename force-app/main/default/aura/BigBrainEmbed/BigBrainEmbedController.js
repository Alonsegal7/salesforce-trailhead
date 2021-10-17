({
	 onRender : function(component, event, helper){
        var frame = document.getElementById("bb-embed");
        if(frame){
        	console.log("BigBrainEmbed - onRender", frame.src);  
        }
        setTimeout(function(){
            var frame = document.getElementById("bb-embed");
            console.log("BigBrainEmbed - setTimeout");                    
            if(frame){
                if(frame.src == 'httsp://bigbrain.me/'){
					frame.src=frame.src;
					console.log("BigBrainPicker - refresh iframe patch", frame.src);                    
               	}
			}
        }, 1400);
	}
})