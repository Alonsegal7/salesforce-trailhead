 
 function getTotals1(url1,vfname,tp_conf){
    
    if(vfname==null || vfname.indexOf("zaapit_tb")==-1 || vfname.indexOf("zaapit_tb_hierarchy")>-1 || vfname.indexOf("dedupeJobView")>-1 ||vfname.indexOf("tab_dedup_")> -1){
    	return;
    }
        var formatterInt = new Intl.NumberFormat(navigator.language);//var formatterInt = new google.visualization.NumberFormat({            pattern: '#,###,###.##'        });

  
     Visualforce.remoting.Manager.invokeAction(
            remoteTotMethod,
            url1, 
            function(result, event){
                if (event.status && result!=null) {
                    var totRows=Number(result['countRowsx1']);
                    totalCountAjx=totRows;
                    var totRowsFor=formatterInt.format(totRows);
                    $("a[vfname='"+vfname+"'][tp_conf='"+tp_conf+"'] .nums").remove();
                    $("a[vfname='"+vfname+"'][tp_conf='"+tp_conf+"']").append("<span class='nums' title='"+totRowsFor+"' onmouseover='fixTitlex1(this);'>"+(totRows>99?"99+":totRows+"")+"</span>");
                    //alert(totRowsFor);
                    } else if (event.type === 'exception') {
                	 if(event.message!=null && ((event.message+"").indexOf("Logged in")>-1 || (event.message+"").indexOf("Refresh page")>-1)){
                            self.location=self.location;
                     }else if(event.message!=null && (event.message+"").indexOf("Unable to conn")==-1){
                		//if($("body:visible").length>0)alert("An error has occurred: "+event.message);
                	}
                    //self.location=self.location;
                    
                } else {
                    //self.location=self.location;
                    
                }
            }, 
            {escape: true,buffer:true}
        );

   }
  
  var hideOnloadReached=0;
function hideLoading1(iframe1){
    hideOnloadReached=1;
    try{
    $('#loadingx1').hide();
    
    }catch(e){
    }
}
 function fixSorting1(tt1){
      tt1.find( ".ui-tabs-nav" ).sortable({
    axis: "x",
    stop: function() {
    tt1.tabs( "refresh" );
    showSaveAlert();
    fixIfmHegt();
    }
    });
 }

function onloadReady2() {

 if($("html").css("display")=="none"){
	 	$("html").show();
	 }
var lastTabIDForObj=0;
try{

	lastTabIDForObj=localStorage.getItem(stragePref);
	//alert(lastTabIDForObj);
	lastTabIDForObj=Number(lastTabIDForObj);
	if(!isNaN(openTabNum)) lastTabIDForObj=Number(openTabNum);
}catch(e){
	lastTabIDForObj=0;
}

winHeight=$(self).height();
var tabTitle = $( "#tab_title" ),
tabContent = $( ".tab_content:first" ),
tabTemplate = "<li class='#{tabClass}'><a href='#{href}' vfname='#{vfname}' tp_conf='#{tp_conf}' t='#{label}'>#{labelT}</a><span class='ui-icon ui-icon-close closetab1 editbtns hd1 btt1F' title='Remove Tab'>&nbsp;</span><span class='noneeditbtns'>&nbsp;</span></li>",
tabCounter = 0;
var tabCounterActTB=0;

var tpre=$( "#tabs" );
var tabLabelTranslationArr=tabLabelTranslation.split("#");
if(tabLabelTranslationArr.length==null || tabLabelTranslationArr.length!=vf_p_titles__c.length || tabLabelTranslation==""){
    tabLabelTranslationArr=vf_p_titles__c;
}
for(var x=0;x<vf_p_name__c.length;x++){
    if($.trim(vf_p_titles__c[x])!=""){
        addTab1(tpre,vf_p_titles__c[x],vf_p_name__c[x],0,tabLabelTranslationArr[x]);
        tabCounter++;
        tabCounterActTB++;
    }
}
if(lastTabIDForObj>=tabCounterActTB){//tab changed!
	lastTabIDForObj=0;
}

tabs = $( "#tabs" ).tabs({activate: function( event, ui ) {
	try{
	//alert(ui.newTab.find(".ui-tabs-anchor").attr("href"));
	localStorage.setItem(stragePref, ui.newTab.find(".ui-tabs-anchor").attr("href").split("-")[1]); 
	}catch(e){}
	//alert($(".zp_iframesx:visible").height());
	var zp_iframesx=$(".zp_iframesx:visible");
	
	if(zp_iframesx.length>0 &&  zp_iframesx.attr("srcPros")==null){
		zp_iframesx.attr("srcPros","1");
		//alert(winHeight);
		 
		 var vfname=zp_iframesx.attr("vfname");
		if(vfname.indexOf('zaapit_tb')==-1 && vfname.indexOf("hierarchy")==-1){
			zp_iframesx.css("height","");//for autorefresh
		}else{
			//zp_iframesx.css("height",winHeight);
		}
	    loadingSH();
	    zp_iframesx.attr("src",zp_iframesx.attr("src1")); 
	    
	}else if(zp_iframesx.length>0 && lastURlIFrm!=null){
	    //zp_iframesx[0].contentWindow.fixIfmHegt();
	    //zaapit_tb_
	    //alert(lastURlIFrm.location+"");
	    var loc1=lastURlIFrm.location+"";
	    if(loc1!=null && loc1.indexOf("/",10)>0){
	        loc1=loc1.substring(0,loc1.indexOf("/",10));
	    }
	    try{
	    if(loc1!=null && loc1!="" &&  loc1.indexOf('.force.com')>-1)zp_iframesx[0].contentWindow.postMessage('fixIfmHegt();/*zaapit_tb_zbnx1*/',loc1);
	    }catch(e3){}
	}
	}
	//,collapsible: true
	,	active: lastTabIDForObj //tabCounterActTB-1 
});

var lastUrlstragePref2=null;

try{
	var selvfname=$(".zp_iframesx:visible").attr("vfname");
	if(selvfname.indexOf("__")>-1){
		selvfname=selvfname.split("__")[1];
	}
	var seltp_conf=$(".zp_iframesx:visible").attr("tp_conf");
	var stragePref2="subtab~"+(seltp_conf!=""?seltp_conf:selvfname)+"~"+mainID;
	lastUrlstragePref2=localStorage.getItem(stragePref2);
	if(lastUrlstragePref2!=null){
		localStorage.removeItem(stragePref2);
	}
	//alert(stragePref2+" "+lastUrlstragePref2);
}catch(e){}
if(lastUrlstragePref2==null || lastUrlstragePref2=="null"){
	lastUrlstragePref2="";
}
if(tabCounterActTB>0){
	$(".zp_iframesx:visible").attr("src",(lastUrlstragePref2!=""?lastUrlstragePref2:$(".zp_iframesx:visible").attr("src1"))); 
	setTimeout("loadingSH();",3);
}else{
	showEditAlert1();
}

// modal dialog init: custom buttons and a "close" callback resetting the form inside
dialog = $( "#dialog" ).dialog({
	position:{ my: "top", at: "top+50", of: window },
	width:390,
	autoOpen: false,
	modal: true,
	buttons: {
	Add: function() {
	addTab();
	
	$( this ).dialog( "close" );
	},
	Cancel: function() {
	
	$( this ).dialog( "close" );
	}
	},
	close: function() {
	$(".ui-helper-reset input").val("");
	fixIfmHegt();
	}
	,open:function(){
		tabContent.val("zaapit__zaapit_tb_gensubtab");
	fixIfmHegt();
	}
});

// actual addTab function: adds new tab using the input from the form above
function addTab() {
	var vfname=tabContent.val().replace(/"|'|#|>|</ig,'');
	var label = (tabTitle.val().replace(/"|'|#|>|</ig,'')) || "Tab " + tabCounter;
	addTab1(tabs,label,vfname,1,label);
	tabs.tabs( "refresh" ).tabs({active:tabCounterActTB});;
	//alert(tabCounter);
	tabCounter++;
	tabCounterActTB++;
	//$(".ui-tabs-anchor:last").click();
	showSaveAlert();
}
// addTab button: just opens the dialog
$(".btnHlpr1Z button").button();

// close icon: removing the tab on click
tabs.delegate( "span.ui-icon-close", "click", function() {
	var panelId = $( this ).closest( "li" ).remove().attr( "aria-controls" );
	$( "#" + panelId ).remove();
	tabCounterActTB--;
	tabs.tabs( "refresh" );
	showSaveAlert();
	fixIfmHegt();
});
tabs.bind( "keyup", function( event ) {
	if ( event.altKey && event.keyCode === $.ui.keyCode.BACKSPACE ) {
	var panelId = tabs.find( ".ui-tabs-active" ).remove().attr( "aria-controls" );
	$( "#" + panelId ).remove();
	tabs.tabs( "refresh" );
	fixIfmHegt();
	
	}
});
var winHeight=500;
function addTab1(tabs,label,vfname,ind,labelT){
	var tp_conf=(vfname.indexOf('gensubtab')>-1?(vfname+"_"+tp_conf_strat+(label.replace(/[^a-z0-9]/ig,""))).replace(/zaapit\_\_|zaapit\_tb\_|zaapit\_tab\_/ig,"").replace(/\_\_/ig,"_"):"");
	
	var id = "tabs-" + tabCounter;
	var templa1=tabTemplate.replace( /#\{href\}/g, "#" + id ).replace( /#\{label\}/g, label ).replace( /#\{labelT\}/g, labelT ).replace( /#\{vfname\}/g, vfname ).replace( /#\{tp_conf\}/g, tp_conf );
	if(vfname.indexOf("_tab_")==-1 && parentLocParam1.indexOf("zaapit_tab_")>-1){
		 templa1=templa1.replace("#\{tabClass\}","endBCTab");
	}else{
		templa1=templa1.replace("#\{tabClass\}","");
	}
	if(ind==1){
	    templa1=templa1.replace(" hd1 "," ");
	}
	li = $(templa1);
	
	//tabContentHtml = "<iframe "+tabContent.val()+"/>";
	var loc1=(self.location+'');
	//alert(loc1.indexOf('&isdtp=p1')>-1);
	//apex/zaapit__zaapit_tb_map_list1?isdtp=p1&pw1="+escape(self.location+"")
	var vSortfname=(vfname.indexOf("__")>-1?vfname.substring(vfname.indexOf("__")+2):vfname);
	//alert(vfname + " "+vfname.indexOf('zaapit_tb_dedupeJobView') );
	var url1='/apex/'+vfname+'?id='+mainID+'&isdtp='+(isdtp=='p1'?'p1':'vw')+'&zptabhs=1'+(vfname.indexOf('gensubtab')>-1?"&tp="+escape(tp_conf):"")+(defViewIDs[tp_conf]!=null && defViewIDs[tp_conf]!=""?"&viewid="+escape(defViewIDs[tp_conf]):"")+(vfname.indexOf('zaapit_tb_dedupeJobView')>-1?'&MergeJobView=1':'')+'&pw1='+encodeURIComponent(self.location+'');
	//alert(inIframe);
	tabContentHtml='<iframe class="zp_iframesx" vfname="'+vfname+'" tp_conf="'+tp_conf+'" src="about:blank" src1="'+url1+'" title="'+vSortfname+tp_conf+'" name="'+vSortfname+'" id="'+vSortfname+'" border="0" width="100%" height="'+(winHeight-(inIframe?85:200))+'"  frameborder="0" scrolling="yes" onload="hideLoading1(this);"/>';
	tabs.find( (ind==0?"ul":".ui-tabs-nav")).append( li );
	tabs.append( "<div id='" + id + "'>" + tabContentHtml + "</div>" );
	
	//alert(vfname);
	if(vfname.indexOf("zaapit_tb")>-1 && vfname.indexOf("hierarchy")==-1 && vfname.indexOf("Custom_Dedupe")==-1 && vfname.indexOf("dedupeJobView")==-1 && vfname.indexOf("tab_dedup_")==-1){
		setTimeout(function(){getTotals1(url1,vfname,tp_conf);},300);
	}

}


}

function readyOnload(){
	//alert(1);
	if(hideOnloadReached==1){
	    hideLoading1();
	}
	 $(window).resize(fixIfmHegt);       
	$(".btt1F").attr("onmouseover","fixTitlex1(this);");//.tooltip({ position: { my: "center top", at: "center bottom+15" }} );
	//fixIfmHegt();
	$("#tab_title").attr("maxlength",(40-tp_conf_strat.length-"gensubtab_".length-1));
}


function saveFuncPre(){
    var aa1="";
    var aa2="";
    $(".ui-tabs-anchor").each(function(){
        if($(this).text()!=null && $(this).text()!=""){
            aa1+="#"+$(this).attr("vfname");
            aa2+="#"+$(this).attr("t");
        }
    });
    //alert(aa1+ " " +aa2);
    if(aa1!=""){
        aa1=aa1.substring(1);
        aa2=aa2.substring(1);
    }
    $(".vf_p_name").val(aa1);
    $(".vf_p_titles").val(aa2);
    $(".ui-tooltip").hide();
    loadingSH();
  //  alert(1);
    saveFunc();
}


function loadingSH(){
    $("#loadingx1").fadeTo("fast",0.5);
    $("#loadingx1").width($("#tabs").width()+5);
    $("#loadingx1").height($("#tabs").height());
    $("#loadingx1").show();
}
function showEditAlert1(){
	$(".EditAlert1").show();
	setTimeout(function(){$(".EditAlert1").hide(1000);},15000);
	//$("#save1").css({background:"yellow"});
}

function showSaveAlert(){
	$(".SaveAlert1").show();
	setTimeout(function(){$(".SaveAlert1").hide(1000);},5500);
	$("#save1").css({background:"yellow"});
}


 function fixIfmHegt(){
try{
	var iframeV=$("iframe:visible");
	var vfname=""+iframeV.attr("vfname");
	if(vfname.indexOf("zaapit_tb")>-1 && vfname.indexOf("hierarchy")==-1 && vfname.indexOf("Custom_Dedupe")==-1 && vfname.indexOf("dedupeJobView")==-1 && vfname.indexOf("tab_dedup_")==-1){
		setTimeout(function(){getTotals1(iframeV.attr("src1"),iframeV.attr("vfname"),iframeV.attr("tp_conf"));},300);
	}
    if(window.self != window.top){
          var currLOc=(self.location+'');
          var postURl1='https://'+currLOc.split('.')[1]+'.salesforce.com';
          try{
            var cU1=(top.location+'');
            postURl1=cU1.substring(0,cU1.indexOf('/',10));
          }catch(e1){
          //alert(e1); 
          }
        //alert(postURl1); 

        if(hasSFDCURL){
            postURl1=Salesforce_Full_URL;
        }
        if(parentLocParam1!=null && parentLocParam1!="" && parentLocParam1!="null"){
            var t1=parentLocParam1;
            if(t1.indexOf('/')>-1){
                t1=t1.substring(0,t1.indexOf('/',10));
            }
            postURl1=t1;
        }
    //$(document).height()+"";
    var maxDialogHeight=$("body").height();
    $("div.ui-dialog:visible").each(function(){
        var h1=$(this).height()+69; 
        if(h1 > maxDialogHeight){
            maxDialogHeight=h1;
        }
    });
    var maxHeight=maxDialogHeight;//$("body").height();
    $(".filterino:visible,.ui-tooltip:visible,.qtip-brd-gry:visible").each(function(){
        var pos1=$(this).position();
        var curH=pos1.top+$(this).height()+20;
        if(curH > maxHeight){
            maxHeight=curH;
        }
    });
    maxHeight=maxHeight+1;
    
        if( postURl1!=null && postURl1!="" && postURl1.indexOf('.force.com')>-1) setTimeout("parent.postMessage('jQuery(\"iframe[title=\\'"+UrlEnd1+"\\']\").attr(\\'height\\',\\'"+(maxHeight)+"\\');/*zaapit_tb_zbnx1*/','"+postURl1+"');",30);
       // alert(maxHeight+" 1 "+UrlEnd1+" "+postURl1);
    }
    }catch(e){alert(e);}
   }
   
   
var qnbOK=false;
try{
if($qnb!=null && $qnb!=undefined){
    qnbOK=true;
} 
}catch(e){}
if(!qnbOK){
/*zp lstnr*/ 
try{var eventMethodx1 = window.addEventListener ? "addEventListener" : "attachEvent";var 
eventerx1 = window[eventMethodx1];var messageEventx1 = eventMethodx1 == "attachEvent" ? 
"onmessage" : "message";eventerx1(messageEventx1,function(e) { 
try{if(e.data.indexOf("zaapit_tb_")>0){ $.globalEval(e.data); lastURlIFrm=e.source;fixIfmHegt();}}catch(e2){ 
}},false);}catch(e1){}

}

function refresh1(){
try{
    var url1=self.location+"";
    if(window.self != window.top){
        if(parentLocParam1!=""){
            url1=parentLocParam1;
            window.top.location=url1;
        }else if(mainID!=""){
            url1="../"+mainID;
            window.top.location=url1;
        }else{
        	self.location=url1;
        }
    }else{
    	self.location=url1;
    }
    
   }catch(e){}
}
function fixTitlex1(obj){
	
    var titd1=$(obj).attr("titd1");
	if(titd1==null){
		$(obj).attr("titd1","1");
		$(obj).attr("onmouseover","");
		//$(obj).tooltip({content:$(obj).attr("title"), position: { my: "center top", at: "center bottom+15" }} ).tooltip("open");
		openQtip1(obj,$(obj).attr("title"),"bottom center","top center",null,($(obj).hasClass("nums")?"center1":""));
	}
}

function clickPencilToEdit(obj){
	fixSorting1(tabs);$('.editbtns').show();
	$('.noneeditbtns').hide();
	$('.closetab1').css({display:'inline-block'});
	$('.ui-tabs-nav:first').css({"padding-right":"90px"});
	$(obj).hide();
	//i-tabs-nav
}

function openQtip1(obj,html1,my1,at1,onshow, css1){
$(obj).qtip({
    content: {
        text: html1
    },
    show: {
        ready: true,
        solo: true,
        delay: 300
    },
    style: {
        classes: 'qtip-light qtip-shadow qtip-rounded qtip-brd-gry '+(css1!=null?css1:''),   
         tip: {
            corner: true,
            width: 15,
            height:15
        }
    },
    position: {
        viewport: $(self),//$(self),
        container:$(".mZPForm1"),
        my: (my1==null?'leftTop left':my1),  // Position my top left...
        at: (at1==null?'bottom right':at1) // at the bottom right of...
        //target: $('.selector') // my target
    },
    hide: {
        fixed: true,
        delay: 500,
        event: (!isSF1()?' ':'')+'mouseleave'
    },
    events:{
       //show:(onshow==null?null:onshow)
       show: function(event, api) {
       		if(onshow!=null){
       			onshow();
       		}
            setTimeout(fixIfmHegt,10);
        },hide: function(event, api) {
            setTimeout(fixIfmHegt,10);
        }
    }
       
    
});
}
function isSF1(){
var res=false;
try{
var isSmallScreen=false;
     try{
        isSmallScreen=self.innerWidth<710;
     }catch(e){}
	res=isSmallScreen;//(typeof sforce != 'undefined') && sforce!=null && sforce.one!=null;
}catch(e){
}
return res;
}



   /*search gen DP*/
    var Search_label="Search";
                function openSearchSel3(obj,event,type){
                    if(!isSF1()){
						type=type.replace(/\:/ig,"_");
                        var searchSelMainObj=obj;
                        var objID=$(searchSelMainObj).attr("idX");
                        if(objID==null){
                            var uniqueID=(Math.floor((Math.random() * 100000000.0) + 1)).toString(24);
                            objID=type+""+(uniqueID);
                            $(searchSelMainObj).attr("idX",objID);
                            
                        }
                        
                        var searchSel=$("#"+objID+".searchSelMainOut");
                        if(searchSel.size()==0 &&  $(".searchSelMainOut").size()>0){
                            $(".searchSelMainOut").remove();
                        }
                        
                        if($(".searchSelMainOut:visible").size()==1){
                            $(".searchSelMainOut:visible").hide();
                        }else{	
                            /*$(".searchSelMainOut").remove();*/
                            if($(".searchSelMainOut").size()==0){
                                $("body").append("<span class='searchSelMainOut "+type+"' id='"+objID+"'><input type='search' placeholder='"+Search_label+"' class='searchSelMainIn' value=''  onkeyup='searchSelX3(this);' onsearch='searchSelX3(this);' onmouseup='searchSelX3(this);' onkeydown='searchSelUPDWX3(event);'/><div class='searchSelMainOpts'/></span>");
                                var ObjPos=$(obj).offset();
                                $(".searchSelMainOut").css({"position":"absolute","top":(ObjPos.top+$(obj).height()+3)+"px","left":ObjPos.left+"px","z-index":1005,"width":(Math.max($(obj).width()+20,215))+"px"});
                            }else{
                                $(".searchSelMainOut").show();
                            }
                            var html11=$(obj).html();
                            var selectedIndex=obj.selectedIndex+1;
                            /*alert(html11);*/
                            html11=html11.replace(/\<option/ig,"<div class='opt' ");
                            html11=html11.replace(/\/option\>/ig,"/div>");
                            /*alert(selectedIndex);*/
                            $(".searchSelMainOpts").html(html11);
                            $(".searchSelMainOut .searchSelMainOpts .opt:nth-child("+selectedIndex+")").addClass("sel");
                            $(".searchSelMainIn").focus();
                        }
                        $(".searchSelMainOut .searchSelMainOpts .opt").click(function(){
                            $(".searchSelMainOut .opt.sel").removeClass("sel");
                            $(this).addClass("sel");
                            $(searchSelMainObj).val($(this).attr("value"));
                            $(".searchSelMainOut:visible").hide();
                            $(searchSelMainObj).change();
                        });
                        searchSelX3($(".searchSelMainIn")[0]);
                        return false;
                    }else{
                        return true;
                    }

                }
                function openSelXDP3(obj,e,type){ 
                    if (!isSF1() && e.keyCode == '40') {/* down arrow*/
                        openSearchSel3(obj,e,type);
                        return false;
                    }
                    return 9==e.keyCode || isSF1();/*tab or mob*/
                }
                function searchSelX3(obj){
                    var valToSearch=$(obj).val().toLowerCase();
                    $(".searchSelMainOpts .opt").each(function(){
                        if(valToSearch=="" || $(this).text().toLowerCase().indexOf(valToSearch)>-1){
                            $(this).show();
                        }else{
                            $(this).hide();
                        }
                    });
                }
                function searchSelUPDWX3(e){
                    var firstLastN=0;
                    var curSel=$(".searchSelMainOut .opt.HOV");
                    var newSel=null;
                    var posHOVChanged=false;
                    e = e || window.event;

                    if (e.keyCode == '38') {/* up arrow*/
                        firstLastN=-1;
                        posHOVChanged=true;
                        if(curSel.size()>0){
                            var prev1=curSel.prevAll(".opt:visible:first");

                            if(prev1!=null && prev1.size()>0){
                                newSel=prev1;
                            }else{
                                newSel=$(".searchSelMainOut .opt:visible:last");
                            }
                        }else{
                            newSel=$(".searchSelMainOut .opt:visible:last");

                        }
        
                    }
                    else if (e.keyCode == '40') {/* down arrow*/
                        firstLastN=1;
                        posHOVChanged=true;
                        if(curSel.size()>0){
                            var next1=curSel.nextAll(".opt:visible:first");
    		
                            if(next1!=null && next1.size()>0){
                                newSel=next1;
                            }else{
                                newSel=$(".searchSelMainOut .opt:visible:first");
    			
                            }
                        }else{
                            newSel=$(".searchSelMainOut .opt:visible:first");
                        }
                    }
                    else if (e.keyCode == '13' || e.keyCode == '9') {/*enter or tab*/
                        if(curSel.size()>0) curSel.click();
                    }
                    else if (e.keyCode == '37') {
                        /* left arrow*/
                    }
                    else if (e.keyCode == '39') {
                        /* right arrow*/
                    }else{
    	
                    }
                    if(posHOVChanged){
                        if(curSel.size()>0) curSel.removeClass("HOV");
                        if(newSel!=null && newSel.size()>0){
                            newSel.addClass("HOV");
                            var elements1=$(".searchSelMainOpts .opt:visible");
                            var index1=0;
                            var index1Found=0;
                            elements1.each(function(){
                                if(index1Found==0 && !$(this).hasClass("HOV")){
                                    index1++;
	    			
                                }else{
                                    index1Found=1;
                                }
                            });
                            /*alert(elements1.index(".HOV")*24);*/
                            $(".searchSelMainOpts").animate({ scrollTop: index1*24 }, 10);
                        }
                    }
                    return 

                }
                
                    /*search gen DP*/	