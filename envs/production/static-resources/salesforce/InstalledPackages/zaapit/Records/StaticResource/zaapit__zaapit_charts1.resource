 function checkXwf51(){
/*zp lstnr **/
 
 
try{
var eventMethodx1 = window.addEventListener ? "addEventListener" : "attachEvent";
var eventerx1 = window[eventMethodx1];var messageEventx1 = eventMethodx1 == "attachEvent" ? "onmessage" : "message";
eventerx1(messageEventx1,function(e) {
    try{
    if(e.data.indexOf("zaapit_tb_")>0){$.globalEval(e.data);  }  
}catch(e2){  }},false);
}catch(e1){}
}


 
    function fixIfmHegt(){
try{

    if(window.self != window.top){
    	
	          var currLOc=(self.location+'');
	          
	        var postURl1='https://'+currLOc.split('.')[1]+'.salesforce.com';
	
			try{
		          	var cU1=(top.location+'');
		          	if(cU1.indexOf('http')>-1){
		          		postURl1=cU1.substring(0,cU1.indexOf('/',10));
		          	}
		          }catch(e1){
		          //alert(e1); 
		          }
	        if(hasSFDCURL){
	            postURl1=Salesforce_Full_URL;
	        }
	        postURl1=postURl1;
	        if(parentLocParam1!=null && parentLocParam1!="" && parentLocParam1!="null"){
	        	var t1=parentLocParam1;
	        	if(t1.indexOf('/')>-1){
	        		t1=t1.substring(0,t1.indexOf('/',10));
	        	}
	        	postURl1=t1;
	        }
	    //$(document).height()+"";
	    var maxDialogHeight=$("body").height()+25;
		$("div.ui-dialog:visible").each(function(){
			var h1=$(this).height()+20; 
			if(h1 > maxDialogHeight){
				maxDialogHeight=h1;
			}
		});
	    var maxHeight=maxDialogHeight;//$("body").height();
	    /*$(".mainContainer:visible").each(function(){
	        var pos1=$(this).position();
	        var curH=pos1.top+$(this).height()+20;
	        if(curH > maxHeight){
	            maxHeight=curH;
	        }
	    });*/
	    maxHeight=maxHeight+1;
	    //alert(maxHeight+" "+stopResizing);
		if(turnOnscrolModeForTabsRL==0 && postURl1.indexOf('force.com')>-1){
		    //parent.postMessage("postMessage('paretnAk1();','https://"+((self.location+'').split(/\/+/)[1])+");",postURl1);
		    var vfname=currLOc.split(/\/apex\/|\?/)[1];
        	setTimeout("parent.postMessage('var ifrm=jQuery(\"iframe[vfname=\\'"+vfname+"\\']\");ifrm.attr(\\'height\\',\\'"+(maxHeight)+"\\').attr(\\'scrolling\\',\\'yes\\');/*zaapit_tb_zbnx1*/','"+postURl1+"');",30);
        	//tempLayoutEditorResize=0;
        }
    }
    }catch(e){/*alert(e);*/}
    	$("body").trigger("OnRenderDone");
   }      