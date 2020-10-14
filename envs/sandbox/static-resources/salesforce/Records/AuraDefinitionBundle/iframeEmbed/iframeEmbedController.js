({
    onRender : function(component, event, helper){
       var frame = document.getElementById("bb-embed");
       if(frame){
           console.log("BigBrainEmbed - onRender", frame.src); 
           //var thisUrl ="https://"+window.location.hostname.replace('lightning.force', 'my.salesforce')+"/apex/valt__beforeCanvasPrep?Id=";
           var thisUrl ="https://service.valooto.com/salesforce/quotes?salesforceUserID=0053X00000BoB2nQAF&opportunityID=0061w00001ExwwdAAB&state=production";
           
           component.set("v.iframeUrl", thisUrl);   
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