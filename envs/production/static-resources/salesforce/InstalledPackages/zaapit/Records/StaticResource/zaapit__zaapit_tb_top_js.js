function preAddRowBublein(obj){
	var titd1=$(obj).attr("titd1");
	closeOctrF1O();
	if(titd1==null){
		
		$(obj).attr("titd1","1");
		//alert(NumberOfNewRows);
		if(NumberOfNewRows==""){
			NumberOfNewRows="1";
		}
		var html1=$(obj).attr("title")+": <input type='text' class='addrowsINP' value='' onclick='stopProp1(event);' onkeyup='var v1=$(this).val().replace(/[^0-9]/ig,\"\");$(this).val(v1);NumberOfNewRows=v1;' onkeydown='if(event!=null && event.keyCode===13){preAddRow();return false;}'>";
        //$(obj).attr("onmouseover","");
		//$(obj).attr("title","");
		openQtip1(obj,html1,"bottom center","top center",function(){$(".addrowsINP").val(NumberOfNewRows.replace('.0',''));});
		//$(obj).tooltip({content:html1
		//,position: { my: "left top+5", at: "left bottom", collision: "flipfit"} 
		//,items:"[onmouseover]",hide: { effect: "fadeOut",delay:15000, duration: 300 },open:function(){$(".addrowsINP").val(NumberOfNewRows.replace('.0',''));}}).tooltip( "open" );
		
    }
}
function fixTitlex1(obj,stopP1){
		//alert($(obj).prop("tagName")+" "+$(obj).find("a.btt1[alnk]").length);
	if($(obj).attr("titd1")==null && $(obj).find("a[onblur]").length > 0){
		$(obj).attr("titd1","1");
		fixLnkIntById($(obj).find("a[onblur]")[0]);
		
	}
	if($(obj).attr("alnk")!=null || $(obj).find("a.btt1[alnk]").length > 0|| $(obj).hasClass("btt1") || isSF1() || isMobileRSMode() || $(obj).find("input,select,textarea").length>0){
		$(obj).attr("titd1","1");
	}
    var titd1=$(obj).attr("titd1");
    var tagName=$(obj).prop("tagName").toLowerCase();
    if(titd1==null && (tagName=="a" || tagName=="span" || tagName=="div" || tagName=="label")){
    	var _elm = obj;
	    var _hasScrollBar = false;
		
	    if ((_elm.clientHeight < _elm.scrollHeight) || (_elm.clientWidth < (_elm.scrollWidth-15)) || (!$(_elm).hasClass("thTxtzp") && $(_elm).width() > ($(_elm).parents("td:first").width()-15))|| $(_elm).hasClass("thTxtzp") ) {
	        _hasScrollBar = true;
	    }
	    if(_hasScrollBar){
	    	
        	$(obj).attr("titd1","1");
        	closeOctrF1O();
        	var ost1I=$(obj).find(".ost1I:visible");
        	var ost1P=$(obj).parents("td:first");
        	//_elm.clientWidth < _elm.scrollWidth || 
        	if(ost1I.length>0 && ost1I.width()+16> $(ost1P).width()){
        		ost1I.addClass("HOV");
        	}
        	if(stopP1==null && $(obj).prop("tagName")!="a" && $(obj).find("a").length==0 && $(obj).prop("tagName")!="LABEL"){
        		$(obj).click(stopProp1);
        	}
	        var tit=$(obj).attr("title");
	        var text=$.trim($(obj).text());
	       
	        
			//alert(text+"+++++"+text.indexOf("<br"));
	        if( tit==null && text!=null && text!='' && (_hasScrollBar || text.length>30)){
	            var html1=$(obj).html();
	            if($(obj).hasClass("oSt_zaapit__fieldsheaders__c") && html1.indexOf("&gt;")>-1){//in dedup job
	            	html1=$(obj).text();
	            }
	            //$(obj).css({"cursor":"help"});
	            //$(obj).attr("title",html1);
	            //alert(text);
	            //$(obj).tooltip({ content:html1,items: "[onmouseover]"}).tooltip( "open" );
	            if($(obj).hasClass("thTxtzp") || isInIframe()){
	            	openQtip1(obj,html1,"bottom center","top center");
	            }else{
	            	openQtip1(obj,html1);
	            }
	        }
        }
        
    }else{
    	$(obj).attr("titd1","1");
    }
}

function navigateZPPU(url){
	var url1=url;
	
	if(isSFLight1XV  || isSF1()){
		url1=url1.replace("isdtp=p1","xxx=1");
	}
	navigateZP(url1,window,"width=800, height=800", true);
}
function afix1(obj){
	var href=$(obj).attr("href");
	if($(obj).attr("target")=="" && href.indexOf("navigateZPPU")==-1){
		navigateZP(href,window.top,null, href.indexOf('force')==-1);
		return false;
	}
	return true;
}
function btnClk1(href,a,b){
	if(href.indexOf("retURL=")>-1){
	   href=href.replace(/retURL\=[^\&]+/,"retURL="+(parentLocParam1!="" && mainIDForURL==""?escape(parentLocParam1):currentURL));
	}
	if(isSFLight1XV){
		var slX=href.indexOf("/",8);
		if(b!=null && b=='edit' && slX>0 && href.indexOf("/",slX+1)>0){
			
			var id1=href.substring(slX+1,href.indexOf("/",slX+1));
			//alert(id1+" "+slX+" "+href.indexOf("/",slX+1));
			editRowZP(id1,self.location+'',window.top);
		}else{
			navigateZP((href.replace("isdtp=p1","").replace("?&","?")),window.top,null,true);
		}
	}else{
		var href1=href.replace("isdtp=p1","").replace("?&","?");
		navigateZP(href1,window.top,null,true);
	}
}
var registerClickToDialOv=false;
function openQtip1Ajax(obj,alnk,my1,at1,removeClick,fixLinks,noViewport){ 
var isSf1x=isSF1();
//alert(alnk + isSFLight1XV);
if(false && alnk!=null && alnk.indexOf("/m?isAjax")>-1 && ( alnk.indexOf("lightning.force.com")>-1 || isSFLight1XV)){
	return;
}

if(isSFLight1XV && !registerClickToDialOv && registerClickToDial!=null && alnk.indexOf("/m?")>-1){
	registerClickToDialOv=true;
	
	registerClickToDial=function(obj){
		$(obj).click(function(){
			var id1=$(this).parents("[alnk]:first").split("/")[1];
			phoneDialCell2(this,id1);
		}).css({
			"text-decoration": "underline",
		    "cursor": "pointer"
		    });
	};
}

if(isSf1x){
my1="center";
at1="center";
}
lastQtip1=$(obj).qtip({
    content: {
        text: function(event, api) {
            $.ajax({ url: alnk  ,statusCode: {302: function() {
		      top.location=top.location;
		    }}})
                .done(function(html) {//
                	if(fixLinks==null){
                	   html=html.replace(/<a /ig,"<a target='_blank' ").replace(/navigateToUrl/ig,"btnClk1").replace(/srcUp\(/ig,"navigateZPPU(");
                	    html=html.replace(/<div /i,"<div alnk='"+alnk+"' ");
                	}
                	if(alnk.indexOf("/ui/common/MRUHoverLoader")>-1){
                		var hoverIds=getParameterByNameJS("hoverIds",alnk);
                		if(hoverIds!=""){
                			 html=html.replace("<"+hoverIds+">","");
                		}
                	}
                    api.set('content.text', html);
                    fixIfmHegt();
                })
                .fail(function(xhr, status, error) {
                    
                   api.set('content.text', status + ': ' + error);
                })

            return "<div class='bbt1Loading'></div>";
        },
        button: true
    },
    show: {
        ready: true,
        solo: $(".Zstbl1WS"),
        delay: 300,
        modal:isSf1x
    },
    style: {
        classes: 'qtip-light qtip-shadow qtip-rounded qtip-brd-gry qtip-ajax',   
         tip: {
            corner: !isSf1x,
            width: 15,
            height:15
        }
    },
    position: {
        viewport: (noViewport!=null?$("body"):$(self)),
        my: (my1?my1:'top left'),  // Position my top left...
        at: (at1?at1:'bottom right') // at the bottom right of...
        ,target: (isSf1x?$("body"):$(obj)) // my target
        ,adjust:{method:"shift"}
    },
    hide: {
        fixed: true,
        delay: 500,
        event: (removeClick?"mouseleave":"click mouseleave")+""
    },
    events:{
       show: function(event, api) {
            fixIfmHegt();
        },hide: function(event, api) {
            fixIfmHegt();
        }
    }
    
});
}

function getParameterByNameJS( name ,url){
  name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
  var regexS = "[\\?&]"+name+"=([^&#]*)";
  var regex = new RegExp( regexS );
  var results = regex.exec( url );
  if( results == null )
    return "";
  else
    return decodeURIComponent(results[1].replace(/\+/g, " "));
}


var lastQtip1=null;
function openQtip1(obj,html1,my1,at1,onshow,modal,removeClick,useViewPort){
var isSf1x=isSF1();
if(!isSf1x){
	
	var pos= {
        
        container:$(".mZPForm1"),
        my: (my1==null?'top left':my1),  // Position my top left...
        at: (at1==null?'bottom right':at1), // at the bottom right of...
        //target: $('.selector') // my target
    };
    if(useViewPort==null){
    	pos.viewport=$(window);
    }
    
lastQtip1=$(obj).qtip({
    content: {
        text: html1,
        button: true
    },
    show: {
        ready: true,
        solo: $(".Zstbl1WS"),
        modal:(modal!=null),
        delay: 300
    },
    style: {
        classes: 'qtip-light qtip-shadow qtip-rounded qtip-brd-gry',   
         tip: {
            corner: !isSf1x,
            width: 15,
            height:15
        }
    },
    position:pos,
    hide: {
        fixed: true,
        delay: 500,
        event: (removeClick!=null?"mouseleave":"click mouseleave")+""
    },
    events:{
       show:(onshow==null?function(event, api) {
            setTimeout(fixIfmHegt,10);
        }:onshow)
        ,hide: function(event, api) {
            setTimeout(fixIfmHegt,10);
        }
    }
       
    
});
}
}
var positionL1= { my: "right-15 center", at: "left center" };
function fixTitlex2(obj,worksOnMob,pos,reopenQT,removeClick){
	if(reopenQT!=null){
		$(obj).removeAttr("titd1");
	}
	var titd1=$(obj).attr("titd1");
	$(obj).attr("titd1","1");
	if(titd1==null && (worksOnMob==null || worksOnMob==isMobileRSMode())){
		$(obj).attr("titd1","1");
		closeOctrF1O();
		if(pos!=null && pos=='L'){
			//$(obj).tooltip({ content:$(obj).attr("title"),position:positionL1}).tooltip( "open" );
			openQtip1(obj,$(obj).attr("title"),"center right","center left",null,null,removeClick);
		}else if(pos!=null && pos=='R'){
			
			openQtip1(obj,$(obj).attr("title"),"left center","right center",null,null,removeClick);
		}else if(pos!=null && pos=='B'){
			
			openQtip1(obj,$(obj).attr("title"),"top center","bottom center",null,null,removeClick,false);
		}else{
		 	//$(obj).tooltip({ content:$(obj).attr("title")}).tooltip( "open" );
		 	openQtip1(obj,$(obj).attr("title"),"bottom center","top center",null,null,removeClick);
		}
	}
}
var totChanged=0;
function cbAll(obj){
    var isCHK=$(obj).prop("checked");
    $(".lcbX input[type='checkbox']").each(function(){$(this).prop("checked",isCHK);});
}
function cbAllV(obj){

    $("input.lcbXAll").prop("checked",($(obj).prop("checked") && $("input.lcbXRow").length==$("input.lcbXRow:checked").length));
}

function fixCommuniPD1(){

    var loc1=(self.location+"");
  if(loc1.indexOf(".com/servlet/")==-1 && loc1.indexOf(".com/apex/")==-1 && !isInIframe()){
        $(".zen-select").each(function(){
            var thisO=$(this);
            var trigger=thisO.find(".zen-trigger");
            if(trigger.hasClass("zenfixZP")){
            	return false;
            }
            trigger.addClass("zenfixZP");
            var options=thisO.find(".zen-options");
            if(trigger.length==1 && options.length==1){
                trigger.click(function(){
                    if(!options.is(":visible")){
                        $(".zen-select .zen-options:visible").hide();
                    }
                    options.toggle();
                    return false;
                });
            }
        });
   }
    
}
var lastmarkChangeRW=null;
function markChangeRW(obj,refresh){

    var rowChanged=false; 
    var mTR=$(obj).parents("tr.dataRow:first");
	var valChnaged=$(obj).data("oldV")!=$(obj).val();
	if(valChnaged){
		$(obj).addClass("mFu1");
	}else{
		$(obj).removeClass("mFu1");
	}
    mTR.find("input,select,textarea").each(function(){
        rowChanged=rowChanged||$(this).data("oldV")!=$(this).val();
        if($(this).prop("checked")!=null && !$(this).parent().hasClass("lcbX")){
            rowChanged=rowChanged||$(this).data("oldCH")!=$(this).prop("checked");
        }
    });
	//alert($(obj).text()+ " "+rowChanged);
    if(rowChanged){
        if(!mTR.hasClass("marked")){
            totChanged++;
        }       
        mTR.addClass("marked");
        mTR.find(".lcbX input").prop("checked",true);
    }else{
        if(mTR.hasClass("marked")){
            totChanged--;
        }       
        mTR.removeClass("marked");
        mTR.find(".lcbX input").prop("checked",false);
    }
	if(lastmarkChangeRW!=null){
		try{
		window.clearTimeout(lastmarkChangeRW);
		}catch(e1){}
	}
    lastmarkChangeRW=window.setTimeout(function(){showChanged1(refresh);},150);
}
function showChanged1(refresh){
	lastmarkChangeRW=null;
	totChanged=$("#mainTBX1 tbody tr.marked .lcbX").length;
    $(".unSVNum").html(totChanged+"");
    if(totChanged!=0){
        $(".btnsSV").addClass("x");
    }else{
        $(".btnsSV").removeClass("x");
    }
    if(refresh==null){
        checkPosFixHeaderResize();
        checkFilterHeaderResize();
        checkColumnFreeze();
    }
}


function fixLnkIntById(obj){//LookupHoverDetail.getHover
	var element=$(obj);
	//alert(this);
	try{
	if(isSF1()){
        	element.attr("onmouseout","").attr("onmouseover","").attr("onfocus","").attr("onblur","");
        }else{
            if( Show_Hover_Preview_On_Name_Field=="true"){
				element.attr("onmouseout","").attr("onmouseover","").attr("onfocus","").attr("onblur","").attr("alnk","/{0}/m?isAjaxRequest=1&isdtp=p1").attr("afld","href").attr("objk","1").addClass("btt1").click(function(event){
        		var href1=$(this).attr("href");
        		if(href1.indexOf("javascript:srcUp(")>-1){
        			var h2=href1;
        			h2=unescape(h2);
        			h2=h2.split("'")[1];
        			if(h2.indexOf("?isdtp=vw")>-1){
        				h2=h2.substring(0,h2.indexOf("?isdtp=vw"));
        			}
        			if(h2.indexOf("?isdtp=p1")>-1){
                        h2=h2.substring(0,h2.indexOf("?isdtp=p1"));
                    }
        			//alert(h2);
        			navigateZP(h2,window.top,null,event.ctrlKey);
        		}else{
                	navigateZP(href1,window.top,null,event.ctrlKey);
                }
                //alert(event.ctrlKey);
                stopProp1(event);
               });

           }
       }
      // alert(1);
   }catch(e){}
}
   function fixLnkInternal(){
        try{
        /*if(window.self != window.top){
            $(".lnkPrp1 a[href!='']").click(function(){
                navigateZP($(this).attr("href"),window.top);
                return false;
            });
        }
        */
        if(false &&  !fixLinkStarted){
        fixLinkStarted=true;
        if(isSF1()){
        	$("#mainTBX1 a[onmouseout]").attr("onmouseout","").attr("onmouseover","").attr("onfocus","").attr("onblur","");
        }else{
        	if( false && Show_Hover_Preview_On_Name_Field=="true"){
        		$("#mainTBX1 span.ost1X a[onmouseover]").attr("onmouseout","").attr("onmouseover","").attr("onfocus","").attr("onblur","").attr("alnk","../{0}/m?isAjaxRequest=1").attr("afld","href").attr("objk","1").addClass("btt1").click(function(){
        		var href1=$(this).attr("href");
        		if(href1.indexOf("javascript:srcUp(")>-1){
        			var h2=href1;
        			h2=unescape(h2);
        			h2=h2.split("'")[1];
        			if(h2.indexOf("?isdtp=vw")>-1){
        				h2=h2.substring(0,h2.indexOf("?isdtp=vw"));
        			}
        			//alert(h2);
        			navigateZP(h2,window.top);
        		}else{
                	navigateZP(href1,window.top);
                }
                return false;
            });
        	}
        }
        fixLinkStarted=false;
        }
        }catch(e){}
   }
   var fixLinkStarted=false;
   var markCheckedRows=false;
   var isEditMode1=false;
   var cancleFocus1=false;
function fixOnload(){
//alert("fixOnload");
//if(true)reutrn;
    $(".availVals").html("<div class='ld1'></div>");
    $("#loadingx1").hide();
    //if(fixIfmHegt!=null)fixIfmHegt();
    if($(".foundX").length==0){
    	var txt1=$(".Zstbl1 h2.mainTitle").text();;
//        $(".Zstbl1 h2.mainTitle").append('<span class="foundX">'+$("#found1").html()+'</span>');
			var extraDescTitle=$(".extraDescTitle");
			var extraDescTitleHTML="";
			if(extraDescTitle.length!=0){
				extraDescTitleHTML="<span class=\"extraDescTx1\">"+extraDescTitle.html()+"</span>";
			}
        $(".Zstbl1 h2.mainTitle").html('<span class="t">'+txt1+'</span> '+extraDescTitleHTML+'<span class="foundX"></span>');
    }else{
        $(".foundX").html("");//$("#found1").html());
    }
    setTimeout( getTotals1,5);
    
    if( isEditMode1){

    $("td.btnicoflt").mouseover(function(){if(!cancleFocus1){$(".cancelBtn1").focus();}});
    $("#mainTBX1 tbody input, #mainTBX1 tbody select, #mainTBX1 tbody textarea").each(    function(){
    		if($(this).data("oldV")==null){
            $(this).data("oldV",$(this).val());
            if($(this).prop("checked")!=null && !$(this).parent().hasClass("lcbX")){
                $(this).data("oldCH",$(this).prop("checked"));
            }
            
	        if($(this).prop("tagName")=="SELECT" && $(this).attr("onchange")==null){
            	$(this).attr("onchange",'if(!$(this).parent().hasClass("lcbX")){markChangeRW(this,"1");}');
	        }else{
	            $(this).bind("focusout change",function(){
	                if(!$(this).parent().hasClass("lcbX")){
	                    markChangeRW(this,"1");
	                }
	            });
	        }
            
            /*.focus(function(){
                if(!$(this).parent().hasClass("lcbX")){
                    markChangeRW(this,"1");
                }
            }).focusout(function(){
                if(!$(this).parent().hasClass("lcbX")){
                    markChangeRW(this,"1");
                }
            });*/
			}
        });
        
    }
    if(markCheckedRows && isEditMode1 ){
        $("#mainTBX1 tbody tr").each(function(){markCheckedRow(this);});
        totChanged=$("#mainTBX1 tbody tr.marked .lcbX").length;
        showChanged1();
    }
        
    
    fixLnkInternal();
    $(".CBMU1").prop("checked","");
        
        try{
        if(refreshAfterSave!=null){
        //refreshAfterSave();
        }
        }catch(e){}
        
        if(!markCheckedRows){
            checkPosFixHeaderResize();
            checkFilterHeaderResize();
        }
        //alert(isSearchFocus1 + $(".seatchInptFZP:visible").length);
        /*if(isSearchFocus1){
            isFirstLoadPage=false;
            var seatchInptFZP=$(".seatchInptFZP:first:visible");
            if(!isInIframe() && seatchInptFZP.length>0){
                
                seatchInptFZP[0].focus();
                seatchInptFZP.val(seatchInptFZP.val());//end of word
            }
        }*/
        searchOnload1();

        prepareFilters2();
     
        //$("#scrollCntrls1").css({"top":(Math.round($(self).height()/2)-50)+"px"}).show();
        
    if(lastMassFunctionBtnCall!=null){
    	if($("#massUpdatein1").find(".errorMsg:first").length>0){
    		$.globalEval(lastMassFunctionBtnCall);
    	}
    	lastMassFunctionBtnCall=null;
    }
    
    if((sortByFieldforColor!=null && sortByFieldforColor!='' )){
    	try{
    	colorRowsByFieldChange(sortByFieldforColor,1, Enable_Sort_grouping2 && sortByFieldforColor2!="");//Enable_Sort_grouping2 && sortByFieldforColor2!="" is for level 2 detection, delay the saved groups
    	if(Enable_Sort_grouping2 && sortByFieldforColor2!="")colorRowsByFieldChange(sortByFieldforColor2,2,false);
    	}catch(e1){alert(e1);}
    	
    	AutoMarkCellsForMassMerge();
    	
    }
    if(fixCommuniZPD1Bool=="/**/"){
        	fixCommuniPD1();
    }
    if(false && isSF1()){
		lastColx1=3;
		$("#columnScrollW1 .l").fadeTo("fast",0.5);
		$("#columnScrollW1 .r").fadeTo("fast",1.0);
	}
	if(runMultiDepandantFix){
		retrySetmulti=0;
		if(lastCallfixMultiDependancefield!=null){
			clearTimeout(lastCallfixMultiDependancefield);
			lastCallfixMultiDependancefield=null;
		}
		lastCallfixMultiDependancefield=setTimeout(fixMultiDependancefield,30);
	}else{
		picklist.initAll=oldInitAll;
	}
	var hasDate1=false;
	$(".dateInput .dateFormat a[href]").each(function(){
		$(this).attr("onclick",$(this).attr("href")+";return false;");
		hasDate1=true;
	});
	if(hasDate1){
	   $(".dateInput input").on("click focus",function(){
		  var bh1=$("body").height();
		  //alert(bh1+" "+ $("#padBut1").height());
		  if(bh1<350 && $("#padBut1").height()<1){
		     $("#padBut1").height(350-bh1);
		     fixIfmHegt();
		  }
	   });
	}
	//return false;
	showHideRightFPan();

	//fix nextPrev (right side)
	if($('.prevBtn:disabled').length==0){
        $('.prevBtnF').removeClass("ui-state-disabled");
    }else{
        $('.prevBtnF').addClass("ui-state-disabled");
    }
    if($('.nextBtn:disabled').length==0){
        $('.nextBtnF').removeClass("ui-state-disabled");
    }else{
        $('.nextBtnF').addClass("ui-state-disabled");
    }
    
    if(isInIframe()){//&& !$("body").hasClass("inRLZ")
    	$("body").addClass("inRLZ");//in iframe
    }
    
    readyFixLKPX();
    
	$("body").trigger("OnLoadDone");
}

function showHideRightFPan(){
   try{
   		if(!isSF1() && !isInIframe()){
		   $("#scrollCntrls1").show();
		}
	}catch(e){
	}
}
var runMultiDepandantFix=true;
var lastCallfixMultiDependancefield=null;
var retrySetmulti=0;

function fixMultiDependancefield(){
var noMultPickLIst=false;
	var doneX=0;
	if(  $(".multiSelectPicklistTable:first").length>0){
		$(".multiSelectPicklistCell a").each(function(){
			$(this).attr("onclick",$(this).attr("href")+";return false;");
		});
		if(isEditMode1){
		try{
		if( retrySetmulti<=3 && (picklist==null || picklist.picklists==null || picklist.picklists.length==0)){
			retrySetmulti++;
			lastCallfixMultiDependancefield=setTimeout(fixMultiDependancefield,(fixMultiDependancefield+1)*150);
			return;
		}
		//alert($("select.iTb[multiple][selVal]").length+" "+retrySetmulti);
		$("select.iTb[multiple][selVal]").each(function(){
			var selVal=$(this).attr("selVal");
			if(selVal!=null){
				
				var curMPL= picklist.picklists[$(this).attr("id")];
				
				//alert(curMPL.initialValue.length);
				if(curMPL!=null && (curMPL.initialValue==null || curMPL.initialValue.length==0 || curMPL.initialValue.join(";")!=selVal) ){//
					var selSplit=selVal.split(";");
					var newArr=new Array();
					for(var i=0;i<selSplit.length;i++){
						if(selSplit[i]!=""){
							newArr.push(selSplit[i]);
							newArr.push(selSplit[i]);
						}
					}
					//alert(newArr);
					curMPL.initialValue=newArr;
					curMPL.loaded=!1;
					doneX++;
				}
				
			}
		});
		
		}catch(e){alert(e);}
		

		}
	}else{
			noMultPickLIst=true;
	}
	if(true ){//|| retrySetmulti==3 || doneX>0 || !isEditMode1
		try{
		picklist.initAll=oldInitAll;
		picklist.initAll();
		picklist.initAll=function(){};
			
		}catch(e){alert(e);}
	}
//alert($(".iTd .multiSelectPicklistTable").length);
}
function clearBtnFocusIn(){
    var par1=$(this).parents("span:first");
    par1.find(".ui-icon-circle-closeZP").addClass("ui-icon-circle-closeZPH").show();
    par1.find(".searchTxt").hide();
}
function clearBtnFocusOut(){
    if($.trim($(this).val())==""){
        $(this).parents("span:first").find(".ui-icon-circle-closeZP").hide("fade",1000);
    }
}
function clickSearchTxt(obj){//searchTxt
    $(obj).hide();
    $(obj).parents("span:first").find("input:first").click().focus();
}

function searchOnload1(){
   
    //$("#foundX").html($("#found1").html());
    //.keypress(function(){searchChanged(2500);})
    $("input.seatchInptFZP:first").keyup(function(event){
        var waitMilis=1;
        if (event!=null && event.keyCode===13){
            waitMilis=1;
            searchChanged(waitMilis);
        }else{
            waitMilis=(isSF1()?1650:1650);
            searchChanged(waitMilis);
        }
        //searchChanged(waitMilis);
    
    }).focusin(clearBtnFocusIn).focusout(clearBtnFocusOut);
    
     prepareFilters();
     
    //setTimeout('$(".seatchInptFZP").attr("onfocus","");',300);
   fixIfmHegt();
   
}

function prepareFilters(){
	 $("input.filterinoIPT").keypress(filterCol).keyup(filterCol).focusin(clearBtnFocusIn).focusout(clearBtnFocusOut);//.tooltip({content:Filter_box_help_Title});
     $(".filtDatex1Mnx").each(function(){
        var vx1=$(this).val().split("~");
        if(vx1.length>0){
            var origFl=$(this).parents("span:first").attr("origFl");
            $("."+origFl+"1").val(vx1[0]);
            if(vx1.length>1){
                $("."+origFl+"2").val(vx1[1]);
            }
        }
        
     });
     $(".filterObjShow1 input.inptFilter").keyup(function(event){
        if (event!=null && event.keyCode===13){ 
            setTimeout(clickVisFilerBtn,10);
        }
     });
}
function prepareFilters2(){
  $("input.filtDatex1").datepicker( { 
    dateFormat: "yy-mm-dd"
    ,changeMonth: true
    ,changeYear: true 
    }).change(function(){
        var origFl=$(this).attr("origFl");
        $("."+origFl).val($("."+origFl+"1").val()+"~"+$("."+origFl+"2").val());
        filterCol(null,100);;//13
        
     }).css({"width":"69px","height":"17px"}).keydown(function(){return false;});
}
     

function markCheckedRow(row){
    if(!$(row).hasClass("marked") && $(row).find(".lcbX input:checked").length==1){
        $(row).addClass("marked");
        $(row).find("td:first").append("<input type='hidden' class='mupdateX' name='mupdateX' value='1' oldV='2'/>");
        //markChangeRW($(row).find(".mupdateX"))
        //totChanged++;
    }
}

function fixAfterScrollG1(){
	
//alert("after scroll");
	
            if(posFixth!=null){
                window.clearTimeout(posFixth);
            }
            posFixth=setTimeout(fixAferScroll,50);
            //fixAferScroll();
    

}

var showCopyToMasterEM=true;
function checkXwf51(){
/*zp lstnr*/
try{
var eventMethodx1 = window.addEventListener ? "addEventListener" : "attachEvent";
var eventerx1 = window[eventMethodx1];var messageEventx1 = eventMethodx1 == "attachEvent" ? "onmessage" : "message";
eventerx1(messageEventx1,function(e) {
    try{
    if(e.data.indexOf("zaapit_tb_")>0){$.globalEval(e.data);  }  
}catch(e2){  }},false);
}catch(e1){}
}
var showCellMenu1TO1=null;

function ready4ZP(){
		
	 if($("html").css("display")=="none"){
	 	$("html").show();
	 }
	 if($("body").css("direction")=="rtl")$("html").attr("dir","rtl");
     checkXwf51();
     
     
     try{
         if(window.self != window.top){
        if(!isSF1P){
            $(self).resize(function(){
                paretnAk1();
            }); 
        }else{
             paretnAk1();
        }
        setTimeout(fixIfmHegt,50);
        if(turnOnscrolModeForTabsRL==0){
            setTimeout(showMsgConf,4000);   
        }
        fixCommuniZPD1Bool="---";  
   }else{
        
   }
   }catch(e){}
   if(!isEditMode1 && hasMassMerge!="true"){//&& $(".EditBtnX1:visible").length>0//cell menu
   
   		//$("body").delegate("tr[rowid].dataRow td[fld] ","click",function(e1){
   		 $("body").delegate("tr[rowid].dataRow td[fld] ","mouseover click",function(e1){
   		 	if(!isEditMode1){
   		 		//inlineEditRowMG(this);
   		 		//hideCellMenu1();
   		 		if(showCellMenu1TO1!=null){
   		 			clearTimeout(showCellMenu1TO1);
   		 		}
   		 		var curObj=this;
   		 		showCellMenu1TO1=setTimeout(function(){showCellMenu1(curObj);},(e1.type=='click'?1:690));
   		 	}
   		 	//stopProp1(e1);
   		 });
    
    }else if(!isSF1P && isEditMode1){
       /*$(".lcbX").each(function(){
        var rid=$(this).attr("rid");
        var num=$(this).attr("num");
        var t1="<a href='../"+rid+"' target='_blank' >"+Label_View_Row+"</a>";
        if((rid==null || rid=="") && num!=null && num!=""){
        	t1=Unmark_to_ignore_row;//"<a href='javascript:void(0);' onclick='disableNotice1=true;removeNewRows("+num+");'>"+Label_remove_Row+"</a>";
        }
        $(this).tooltip({content:t1,items:"input[type='checkbox']", position: { my: "right-15 center", at: "left center" }, hide: { duration: 2500 }} );
        });
        */
        $("body").delegate("td.CBL .lcbX","mouseover",function(e1){
				if(isEditMode1 && $(this).data("LinkHov1")==null){
					$(this).data("LinkHov1","1");
					
					var rid=$(this).attr("rid");
			        var num=$(this).attr("num");
			        var t1="<a href='../"+rid+"' target='_blank' >"+Label_View_Row+"</a>";
			        if((rid==null || rid=="") && num!=null && num!=""){
			        	t1=Unmark_to_ignore_row;//"<a href='javascript:void(0);' onclick='disableNotice1=true;removeNewRows("+num+");'>"+Label_remove_Row+"</a>";
			        }
					$(this).attr("title",t1);
					fixTitlex2(this,false,'L');
					
					
				}
		});
        
        
         if($( "body" ).data("lookupInputClick1")==null){
         	$( "body" ).data("lookupInputClick1","1");
	        $( "body" ).delegate(".lookupInput a", "click", function() {
				cancleFocus1=true;
				setTimeout(function(){cancleFocus1=false;},3500);
			});
		}
    }
    
   
     if(!isSF1P && $( "body" ).data("copycell")==null){
        $( "body" ).data("copycell","1");
        $("body").delegate(".copyCell","mousedown",function(e1){
			copyCellStart(this,e1);
		});
		$("body").delegate("td.iTd,td.CBL","mouseenter",function(e1){
			copyCellHOVER(this,e1);
		});
		$("body").delegate("td.iTd,td.CBL","mouseup",function(e1){
			copyCellEnd(this,e1);
		});
		
		if(hasMassMerge=="true"){
			/*$("#massUpdatein .muf1[fld]").each(function(){
				MassMergefieldsToAvilOv[$(this).attr("fld")]=true;
			});*/
			
						
			$("body").delegate("tr.dataRow td[fld]","click",function(e1){//copy to master
				var fld=$(this).attr("fld");
				var fldEdit=MassMergefieldsToAvilOv[fld];
				var fldAct=(MassMergefieldsToAvilOvAct[fld]+'');
				if(!isEditMode1 && fldEdit!=null && fldEdit && fldAct!="dest" && fldAct.indexOf("combineTA")==-1){//the field is not a destination for combine or the combine source
					var tr1=$(this).parents("tr.dataRow:first");
					var gnz=tr1.attr("gnz");
					var tpx=$("#mainTBX1 .headerRow th."+fld).attr("tpx")+"";
					if(!e1.ctrlKey  ||  
					(tpx!="1" && tpx!="4" && tpx!="11" && tpx!="9f" && tpx!="9") ||
					$("#massUpdatein .muf1[fld='"+fld+"'] select").length==1
					){//only when CTRL and string field//9f is long text
						$("tr.dataRow[gnz='"+gnz+"'] td[fld='"+fld+"'].copyCellMark").removeClass("copyCellMark");
					}
					$(this).toggleClass("copyCellMark");
					
					if(!tr1.find(".lcbXRow").is(":checked")){
			    		tr1.find(".lcbXRow").click();
			    	}
				}else if(!isEditMode1 && fldEdit==null && showCopyToMasterEM){
					var t1="Read Only Field";
					$(this).css({"cursor":"not-allowed"}).attr("title",t1);
					
					fixTitlex2(this,false);
				}
				
			});
			
			$("body").delegate("td.CBL .lcbX","mouseover",function(e1){//master mark
				if($(this).data("mergeHov1")==null && !isEditMode1){
					$(this).data("mergeHov1","1");
					var t1="<a href='javascript:void(0);' onclick='markAsMaster(\""+$(this).attr("rid")+"\");'>Mark as Master</a>";
					$(this).attr("title",t1);//
					$(this).find(".lcbXRow").click(function(){
						if(!$(this).prop("checked")){
							$(this).parents("tr:first").removeClass("gnzMSR");
							$(this).parents("tr:first").find(".copyCellMark").removeClass("copyCellMark");
						}
					});
					fixTitlex2(this,false,'L');
				}
			});
				
		}
	   }
   // $(".mZPForm1").click(function(){
   //     closeAllTooltips();
   // });
    
    runReadyJSIncZP();
    
    $(window).bind('beforeunload', function(eventObject) {
        var res=noticeUnsaveWin(eventObject);
        
        if(res!=null){
            return res;
        }
    });
	copyCellStarted1=false;
	
	if(currConf_name!="" && tp_conf!="" && tp_conf!=currConf_name){//open layout editor for new pages
		var tit1=$("#customizeViewx1").attr("title");
		if($("#customizeViewx1").data("ft1")==null){
			$("#customizeViewx1").data("ft1","1");
			$("#customizeViewx1").attr("title",tit1+" "+Create_a_new_Smart_Table);
		}
		$(".LE1X").click();
	}
	
}

function hideSuccess(){
	//alert(isQuickSaveLast+ " "+lastGirdTRNum);
	if(isQuickSaveLast){//after success quicksave
		var confirmM3=$(".confirmM3 img[alt='CONFIRM']:visible");
		if(confirmM3.size()>0){
			$(".mainTB1 .list tbody tr.dataRow .actW1").eq(lastGirdTRNum).click();
		}
	}
	isQuickSaveLast=false;//reset 
	lastGirdTRNum=0;
	setTimeout(function(){
		var confirmM3=$(".confirmM3 img[alt='CONFIRM']");
		confirmM3.parents(".confirmM3:first").hide(500);
		},6900);
}

function removeNewRows(num){
	$(".lcbX[num='"+num+"']").parents("tr.dataRow:first").remove();
	setTimeout(function(){disableNotice1=false;},500);
}

function ready3ZP(){


                if(!isMobileRSMode()){
                    //$(".btt1L").tooltip({ content: function() {return $(this).attr("title");},position: { my: "right-15 center", at: "left center" }} );
                    //$(".btt1[title]").tooltip({ content: function() {return $(this).attr("title");}});
                }else{
                    //$(".helpQMSFDC.btt1[title]").tooltip({ content: function() {return $(this).attr("title");}});
                }
                if(topLeftFilterIMG!=null && topLeftFilterIMG!="" && topLeftFilterIMG!="/s.gif"){ 
                    //alert(topLeftFilterIMG);
                    $(".topFilterSave img.pageTitleIcon").attr("src",topLeftFilterIMG);
                }
                
                if(!isSF1() && NOT_hideEditButton=="true"){
                    $("#mainTBX1").addClass("IErmo");
                }
}

function ready2ZP(){

topLeftFilterIMG=$(".topFilterSave .pageTitleIcon.userDefinedImage").attr("src");
//$(document).tooltip({
//    position: { my: "right-15 center", at: "left center" },
//   items:".btt1L"});
   
//$(document).tooltip({items:".btt1[title"});

    tooltipFix();
   $("body").mouseup(bdMouseUp);
   $("body").mousemove(bdMouseMove);
   
   try{

		if(returnFocus!=""){
			setTimeout(function(){scrollTopObjRow1("a[href='"+returnFocus+"']:first");},900);
		}
	}catch(e){
	
	
	}
	if(!isSF1() && autoShowGuides=="1"){
		var welcome_guide_meLS=getLS1("welcome_guide_me");
		//alert(welcome_guide_meLS);
		if(welcome_guide_meLS==null){
			setLS1("welcome_guide_me","1")
			setTimeout(function(){guideMe('welcome_guide_me',0);},1000);
		}
	}
	
	$("body").click(function(e){if(($(e.target).attr('onclick')+"").indexOf('openSearchSel')==-1 && $(e.target).parents(".searchSelMainOut:visible").size()==0)$(".searchSelMainOut:visible").hide();});
	setTimeout(trackgaX,1500);
}

function bdMouseMove(e){
	resizeColOv(e);
	moveColPos(e);
}
function bdMouseUp(e){
	resizeColSt(e);
	stopColPos(e);
}
function runReadyJSIncZP(){

//if(true)return;
    fixOnload();
    
    
     
        $(self).scroll(fixAfterScrollG1);
        
        if(EnableHorizontalScroll==1){
        	 $("#mainTBX1").scroll(fixAfterScrollG1);
        }
        $(self).resize(function(){
            if(posFixth!=null){
                window.clearTimeout(posFixth);
            }
            posFixth=setTimeout(fixAferResize,50);
            showHideRightFPan();
        });
        $("#handlebarContainer").click( function(){
                if(posFixth!=null){
                    window.clearTimeout(posFixth);
                }
                posFixth=setTimeout(fixAferResize,50);
        });
        
       // readyFixLKPX();
       // if(isSF1()){
        //	$( "div#mainTBX1" ).on( "swipeleft", function(){columnSwitch(-1);} );
        //	$( "div#mainTBX1" ).on( "swiperight", function(){columnSwitch(1);} );
       // }
     autoPinGraph();
     markFieldINlineEdit();
     
     if($( "body" ).data("DelopenLookup")==null){
     	$( "body" ).delegate("a.iTb[href*='openLookup']", "click", function(event) {
     		disableNotice1=true;
     		setTimeout(function(){disableNotice1=false;},500);
     	}).data("DelopenLookup","1");
     }
     
     $( "body" ).delegate(".ost1I a[href]", "click", function(event) {
		if($(this).attr("href").indexOf("javascript")==-1 && ($(this).attr("onclick")==null || $(this).attr("onclick")=="")){
			stopProp1(event);
			navigateZP($(this).attr("href"),top);
			return false;
		}
	});
     
}
var disableNotice1=false;
function markFieldINlineEdit(){
	if(!isSF1() && lastIDClicked!=null){
     	try{
	     	var td=$(".lcbX[rid='"+lastIDClicked+"']").parents("tr:first").find(".iTd."+lastFieldClicked);
	     	td.addClass("marked");
	     	var inputs=td.find("input:visible,select:visible,textarea:visible");
	     	if(inputs.length>0){
	     		inputs[0].focus();
	     		
	     		$("html, body").animate({ scrollTop: Math.max($(inputs[0]).offset().top-650,0) }, "fast");
	     		
	     	}
	     	
	     	td.removeClass("marked",3500,function(){});

	 	}catch(e){}
	 	lastIDClicked=null;
		lastFieldClicked=null;
	 }
}
function fixAferResize(){
    checkPosFixHeaderResize();
    checkFilterHeaderResize(); 
    checkColumnFreeze(1);
}

function fixAferScroll(){
    checkPosFixHeader();
    checkFilterHeaderResize();
    checkColumnFreeze();
}
function closeFilterx(){

    //close filter
    if(lastOpenCFilterId!=null && lastOpenCFilterSearchBID!=null && $("#"+lastOpenCFilterSearchBID).is(":visible")){
        $("#"+lastOpenCFilterId).click();
    }
}
function checkPosFixHeaderResize(){
//alert("111");
        widthWasSetScroll=false;
            $(".floatTopHead").remove();
            $("#btnicofltTB").removeClass("btnicofltTBTOP");
            $("#mainTBX1 table:first").width("");
            $("#mainTBX1 thead th").width("");
           $("#btnicofltTB").parents("div:first").width("").height("");
            $("#btnicofltTB").width("").height("");
            if( isScrollMode()){
                checkPosFixHeader();
            }
}

function checkFilterHeaderResize(){

    if(lastOpenCFilterId!=null && lastOpenCFilterSearchBID!=null ){
        if(isScrollModeVertical() && lastOpenCFilterId.indexOf("-2")==-1){
            lastOpenCFilterId=lastOpenCFilterId+"-2";
        }else if( !isScrollModeVertical() && lastOpenCFilterId.indexOf("-2")>-1){
            lastOpenCFilterId=lastOpenCFilterId.substring(0,lastOpenCFilterId.length-2);
        }
        if( $("#"+lastOpenCFilterSearchBID).is(":visible")){
                 $("#"+lastOpenCFilterSearchBID).hide();
                 $("#"+lastOpenCFilterId).click();
        }
    }
     
}
function isScrollModeVertical(){
			var res=!isSF1();
			if(res){
	            var pos1=$("#mainTBX1").offset();
	            var st1=$(self).scrollTop();
	            res=(st1!=null &&pos1!=null && pos1.top!=null && ( pos1.top <st1));
            }
            
            return res; 
}
function isScrollMode(){
			var res=!isSF1();
			if(res){
	            var pos1=$("#mainTBX1").offset();
	            var st1=$(self).scrollTop();
	            res=(st1!=null &&pos1!=null && pos1.top!=null && ( pos1.top <st1 || getCUrrScollLeft(true)>pos1.left));
            }
            
            return res; 
}

var posFixth=null;
var widthWasSetScroll=false;
function checkPosFixHeader(){
			if(isSF1())return;
            var pos1=$("#mainTBX1").offset();
            var st1=$(self).scrollTop();
            var sl1= getCUrrScollLeft(true);
            if(!isSF1() && st1!=null &&pos1!=null && pos1.top!=null && (pos1.top < st1 || sl1>pos1.left)){
                if($(".floatTopHead").length==0){
                    if(!widthWasSetScroll){
                        widthWasSetScroll=true;
                            //closeFilterx();
                            $(".btnicoflt").parents("table:first").attr("id","btnicofltTB");
                            $("#btnicofltTB").width(Math.min($("#btnicofltTB").width(),$(self).width()));
                                                
                            $("#btnicofltTB").height(Math.max($("#btnicofltTB").height(),59));
                            
                            var firstPrt=$("#btnicofltTB").parents("div:first");
                            firstPrt.attr("id","btnicofltTBD");
                            firstPrt.height(firstPrt.height());
                            
                        if($("#mainTBX1 table:first").css("width")!=""){
                        $("#mainTBX1 table:first").width($("#mainTBX1 table:first").width());
                        $("#mainTBX1 thead th").each(function(){
                        
                            $(this).width($(this).width());
                            $(this).height($(this).height());
                        });
                        $("#mainTBX1 tfoot td").each(function(){
                        
                            $(this).width($(this).width());
                            $(this).height($(this).height());
                        });
                        
                        }
                    }
                     
                    $("#btnicofltTB").addClass("btnicofltTBTOP");   
                    $("#mainTBX1").append("<table class=\"floatTopHead list\" cellspacing=\"0\" border=\"0\"><thead class=\"rich-table-thead\">"+$("#mainTBX1 thead").html()+"</thead></table>")
                    //$("#mainTBX1").append("<table class=\"floatTopFoot list\" cellspacing=\"0\" border=\"0\"><tfoot class=\"rich-table-thead\">"+$("#mainTBX1 tfoot").html()+"</tfoot></table>")
                    $(".floatTopHead thead th .fltIC").each(function(){
                        var curId=$(this).attr("id");
                        if(curId.indexOf("-2")==-1){
                            $(this).attr("id",curId+"-2");
                        }
                    });
                    $(".floatTopHead").width($("#mainTBX1 table:first").width());
                    
                }
                if(EnableHorizontalScroll!=1 ){//&& zptabhsP!="1"
                
                	$("#btnicofltTB").css({"left":Math.max(pos1.left-sl1,0)+"px","top":(pos1.top>st1?pos1.top-st1-$("#btnicofltTB").outerHeight()-5:0)+"px"});//(pos1.left-sl1)+
                }
                
                if(pos1.top < st1){//$(".floatTopHead").height()+ btnicofltTBTOP//div#btnicofltTBD//(openDialogAsMod()?-29:-17)
                	var top1=$("#btnicofltTB").outerHeight();
                	$(".floatTopHead").css({"left":(pos1.left-sl1)+"px","top":(top1)+"px"}).show();
                }else{
                	$(".floatTopHead").hide();
                }
                $("#scrollCntrls1").css({"top":(Math.round($(self).height()/2)-50)+"px"});
                
                $("#scrollCntrls1").show();


            }else{
                if($("#btnicofltTB").hasClass("btnicofltTBTOP")){
                    //closeFilterx();
                }
                $(".floatTopHead").remove();
                $("#btnicofltTB").removeClass("btnicofltTBTOP");
                
                //$("#scrollCntrls1").hide();
                
                
                
            }
}
function  noticeUnsaveWin(eventObject){
	totChanged=$("#mainTBX1 tbody tr.marked .lcbX").length;
    var res= (!disableNotice1 && !NOT_isEditOL && totChanged>0 ?"You have "+totChanged+" changed row"+(totChanged>1?"s":"")+"!\nIgnore the changes and continue?\n\n To save your changes please click the top Save Button.":null);
    return res;
}
function  noticeUnsave(){
	totChanged=$("#mainTBX1 tbody tr.marked .lcbX").length;
    var res= (NOT_isEditOL || totChanged==0 ||confirm("You have "+totChanged+" changed row"+(totChanged>1?"s":"")+"!\nIgnore the changes and continue?\n\n To save your changes please click the top Save Button."));
    return res;
}

function  noticeUnsaveCancelWork(){
	totChanged=$("#mainTBX1 tbody tr.marked .lcbX").length;
    var res= (NOT_isEditOL || totChanged==0 );
    if(!res){
        alert("You have "+totChanged+" changed row"+(totChanged>1?"s":"")+"!\nPlease save or cancel your work before using the filters.");
    }
    return res;
}
var isInIframeBool=null;
function isInIframe(){
	if(isInIframeBool==null){
		isInIframeBool=(!isSF1() && window.top!=null && window.top != self && parent.frames.length > 0);
	}
    return  isInIframeBool;
}
function  isIframex1(id1,pgRows,hideConfirm){
    var isIfrm= (window.top!=null && window.top != self && parent.frames.length > 0);
    var res=isIfrm;
    if(isIfrm && (hideConfirm=="true" || confirm("Long lists are only available as a sperate page.\nDo you want to open this list in a new page?"))){
        var pg1=Urlx1.split(/\?/);
        window.open(pg1[0]+"?id="+id1+"&pgRows="+pgRows);       
    }
    return res;
}
var lastValTosearchTBX1="";
var lastValTosearchTBX1LJZ=null;
var lastValTosearchTBX1Cnt=0;
function searchTBX1(milisWait){
    lastValTosearchTBX1Cnt++;
    if(lastValTosearchTBX1LJZ!=null){
        window.clearTimeout(lastValTosearchTBX1LJZ);
    }
    if(milisWait==null){
        milisWait=(isSF1()?1500:1650);
    }
    lastValTosearchTBX1=$('.seatchInptFZP:first').val();
    lastValTosearchTBX1LJZ=window.setTimeout("if(lastValTosearchTBX1Cnt=="+lastValTosearchTBX1Cnt+" && lastValTosearchTBX1!=null && noticeUnsaveCancelWork()){loadingSH();searchTB1(lastValTosearchTBX1);}",milisWait);
    //lastValTosearchTBX1LJZ=window.setTimeout("if(lastValTosearchTBX1Cnt=="+lastValTosearchTBX1Cnt+"){alert(lastValTosearchTBX1);}",milisWait);
}
function searchTB1(){
	if(confName.indexOf("tab_dedup_")>-1 && confName.indexOf("gensubtab_dedup_Jobs")==-1){
		tempLayerMessage2("<b>Searching dedupe field...</b>",3500);
	}
	if(confName.indexOf("tab_dedup_")>-1 && (parentLocParam1.indexOf("zaapit_tb_gensubtab_Custom_Dedupe")>-1 || confName.indexOf("tab_dedup_AM")>-1)){
		if(parentLocParam1.indexOf("//")==0 || parentLocParam1.indexOf("/")!=0){
			parentLocParam1=parentLocParam1.substring(parentLocParam1.indexOf("/",8));
		}
		parentLocParam1=parentLocParam1.replace(/\&str\=.*/,"");
		parentLocParam1=parentLocParam1+"&str="+encodeURIComponent(lastValTosearchTBX1);
		//alert(parentLocParam1);
		self.location=parentLocParam1;
	}else{
		searchTB(lastValTosearchTBX1);
	}
}
function loadingSH(){
	$(".cellMenu1").remove();
    $("#loadingx1").fadeTo(0,0.5);
    $("#loadingx1").width($("#mainTBX1").width());
    $("#loadingx1").height($("#mainTBX1").height());
    $("#loadingx1").show();
}
var lastFilterColJS=null;
var lastFilterCnt=0;


 function filterCol(event,extVal){
     var waitMilis=1;
        if ((event!=null && event.keyCode===13) || (extVal!=null && extVal==13)){
            waitMilis=1;
        }else if(extVal!=null && extVal>13){
            waitMilis=extVal;
        }else{
            waitMilis=(isSF1()?1500:1650);
        }
     if(lastFilterColJS!=null){
        window.clearTimeout(lastFilterColJS);
     }
     lastFilterCnt++;
     lastFilterColJS=window.setTimeout("if(lastFilterCnt=="+lastFilterCnt+" && lastFilterColJS!=null && noticeUnsaveCancelWork()){loadingSH();filterColsX();}",waitMilis);
    

 }
 var filterClicked=false;
 var lastOpenCFilterId=null;
 var lastOpenCFilterSearchBID=null;
function openCFilter(pobj,objId,fieldName,fieldCalss1,filterObjShowType,colName,objRefName,sortDir,event){
	trackEventX('openCFilter');
	clearColPos();
    stopResizing=0;
    var curObj=$("#"+objId);
     var parent1=$(pobj).parents("th:first");
     var isVis1=curObj.is(":visible");
      curObj.toggle(); 
    if(!isVis1 ){
        $(".filterino").hide();
       	curObj.show();
        //calc width and pos
        var position = parent1.position();
        var offset = parent1.offset();
        var scrollMode=isScrollMode();
        var sl1= getCUrrScollLeft(false);
        var sT1=$(self).scrollTop();
        var availVals=curObj.find(".availVals:first").width("");
        var fltTblOfw=curObj.find(".fltTblOfw:first").height("");
        //inner stuffScondClick
        var exptWidth2=(fltTblOfw.length>0 && fltTblOfw[0].scrollWidth >fltTblOfw.width()?fltTblOfw[0].scrollWidth:availVals.width());
        var expWidth=Math.max(Math.max(parent1.width(),120),exptWidth2);
    
        var expLeft=0;
        if(isSF1()){
        	//expLeft=0;
        }else if(scrollMode){
            expLeft=Math.round(offset.left-sl1);
        }else{
            expLeft=Math.round(offset.left+(!isSFLight1XV?-10:0));
        }
         //expLeft=Math.round((scrollMode?(Math.round(offset.left)-Math.round(sl1)):Math.round(position.left)));
        var bodyW=$("body").width()+(scrollMode?0:sl1);

        if( expLeft+expWidth>bodyW){
            expLeft=bodyW-expWidth-20;
        }
        if(isSF1()){
        	expLeft=5;
        }
        //alert(expLeft + " "+offset.top+ " " +parent1.height());
        if(!isSF1P){
        	curObj.css({ top: ((scrollMode?offset.top-sT1+9+parent1.height():$("#mainTBX1").position().top+9+parent1.height())), left: (expLeft),position:(scrollMode?"fixed":"absolute")});
        	//curObj.css({ top: ((scrollMode?offset.top-sT1+9+parent1.height():position.top-curObj.height()-9)), left: (scrollMode?offset.left-(sl1):position.left),position:(scrollMode?"fixed":"absolute")});
         
        	curObj.find("input:first").width(expWidth);
        }else{
        	curObj.css({"display":"block","position":"fixed","top":"46px","left":"0px","padding":"15px 10px","border":"1px solid #aaa;","width":"95%"});
        	var inp1=curObj.find("input:first").width("99%").attr("placeholder",Search_label).attr("type","search");
        	if(inp1.val()==" "){inp1.val("");}
        }
       
        
    }
   
    
      if(curObj.is(":visible")){
     	 var inp1=curObj.find("input:first");
      	if(inp1.val()==" "){inp1.val("");}
        if( curObj.find(".availVals").width()>20){
            var availVals=curObj.find(".availVals");
            var fltTblOfw=curObj.find(".fltTblOfw");
            curObj.find("input:first").width(Math.max(parent1.width(),(fltTblOfw.length>0 && fltTblOfw[0].scrollWidth >fltTblOfw.width()?fltTblOfw[0].scrollWidth:availVals.width())));
        }
        var firstinpt=curObj.find("input:first");
        if(firstinpt.is(":visible") ){
            isSearchFocus1=false;
            //firstinpt[0].focus();
            //firstinpt.val(firstinpt.val());//end of word
        }
        lastOpenCFilterId=$(pobj).attr("id");
        lastOpenCFilterSearchBID=objId;
        setTimeout(function(){loadDataFilter(fieldName,objId,fieldCalss1,filterObjShowType,colName,null,null,objRefName,sortDir);},1);
        //fixIfmHegt();
    }else{
        lastOpenCFilterId=null;
        lastOpenCFilterSearchBID=null;
        //fixIfmHegt();
    }
    fixIfmHegt();
    stopProp1(event);
        //filterClicked=false;
    setTimeout("filterClicked=false;",50);
    return false;
}
function scrollTop1(){
     $("html, body").animate({ scrollTop: 0 }, "slow");
}
function scrollBottom1(){
     $("html, body").animate({ scrollTop: $(document).height() }, "slow");
}
function scrollTopObjRow1(str){
		var obj1=$(str);
	if(obj1.length>0){
		var obj1Tr=obj1.parents("tr:first");
		if(obj1Tr.length>0){
     		$("html, body").animate({ scrollTop: Math.max((obj1Tr.offset().top-300),0) }, "slow");
     		obj1Tr.addClass("markedRowTA");
			obj1Tr.removeClass("markedRowTA",6000,function(){});
     	}
     }
}
function openDialogAsMod(){
    var t1=true;
    try{
        t1=navigator.userAgent.indexOf("Chrome")==-1 && navigator.userAgent.indexOf("Safari")==-1;;
    }catch(e1){}
    return t1;
}
var isMobileRSModeCH1=null;
function isMobileRSMode(){
    var t1=true;
    try{
    	if(isMobileRSModeCH1==null){
        	t1=navigator.userAgent.indexOf("iPhone")>-1 || navigator.userAgent.indexOf("iPad")>-1  ;
        	isMobileRSModeCH1=t1;
        }else{
        	t1=isMobileRSModeCH1;
        }
    }catch(e1){}
    return t1;
}
function stopProp1(event){
    if(event!=null &&event.preventDefault){
        event.returnValue = false;
        event.preventDefault();
        
    }
    if(event!=null && event.stopPropagation){
        event.stopPropagation();
        }
        
}
function pinGraph(gid,field1,autoPIn){
	var isBar="true"==$("#"+gid).attr("isBar");
	var chartType=$("#"+gid).attr("chartType");
	//alert("#"+gid+" "+chartType);
	if(chartType==null){
		chartType=false;
	}
	unPinGraph(field1);
	var topChartsFields="#"+$(".topChartsFields").val()+"#";
	if(topChartsFields.indexOf("#"+field1+"~")==-1){//+isBar+"#"
		$(".topChartsFields").val(topChartsFields.substring(1)+field1+"~"+chartType);
	}
	
	$(".filterino:visible").hide();
	var dialog=$("#"+gid).parents("div.ui-dialog:first");
	$("#topGraphs").append(dialog);
	//dialog.css({"position":"relative","z-index":"1","top":"0px","left":"0px","display":"inline-block"});
	 fixPinnedGraph(gid);
	//dialog.find(".ui-dialog-titlebar").unbind( "click" ).unbind( "mouseover" );
	fixIfmHegt();
	if(autoPIn==null)showSaveAlert();
}

function unPinGraph(field1){
				var topChartsFields=$(".topChartsFields").val();
			if(topChartsFields!=""){
				var topChartsFieldsArr=topChartsFields.split("#");
				var topChartsFields="";
				for(var i=0;i<topChartsFieldsArr.length;i++){
					if(topChartsFieldsArr[i]!=""){
						if(topChartsFieldsArr[i].indexOf(field1+"~")==-1 && topChartsFieldsArr[i]!=field1){
							topChartsFields+="#"+topChartsFieldsArr[i];
						}
					}
				}
				if(topChartsFields.indexOf("#")==0){
					topChartsFields=topChartsFields.substring(1);
				}
				$(".topChartsFields").val(topChartsFields);
			}
}

function refreshGraphs(){
	$(".graphsRefresh").click();
}

function autoPinGraph(){
	
	var topChartsFields=$(".topChartsFields").val();
	if(topChartsFields!=null && topChartsFields!=""){
		var topChartsFieldsArr=topChartsFields.split("#");
		//alert("autoPinGraph"+topChartsFieldsArr.length);
		if(topChartsFieldsArr!=null && topChartsFieldsArr.length>0){
			for(var i=0;i<topChartsFieldsArr.length;i++){
				var fldArr=topChartsFieldsArr[i].split("~");
					//alert(fldArr.length<=2);
					if(fldArr!=null && fldArr.length<=2 && topChartsFieldsArr[i].indexOf("_ChartsGrid")==-1){
						var fld1=fldArr[0];
						var isBar=(fldArr.length>1?fldArr[1]=="true":false);
						var chartType=(fldArr.length>1 && fldArr[1]!=""?fldArr[1]:"false");
						if(fld1!=null && fld1!=""){
							var cleanFld1=fld1.replace(/\./ig,"-");
							var obj1=$(".fltIC"+cleanFld1);
							if(obj1.length==0 && fld1.indexOf(".name")>0){
								cleanFld1=cleanFld1.replace("__r-name","__c");
								cleanFld1=cleanFld1.replace("-name","id");
								obj1=$(".fltIC"+cleanFld1);
							}
							var grus=obj1.attr("grus");
							//alert(grus);
							if(grus!=null && grus!=""){
								//alert(isBar)
								grus=grus.replace("chartType",chartType);//set isBar
								//alert(grus);
								$.globalEval("try{"+grus+"}catch(e1){}");
							}
						}
					}else if(topChartsFieldsArr[i].indexOf("_ChartsGrid")>-1){
						getGenSetting(topChartsFieldsArr[i],processComplexCharts);//do processComplexCharts after fetching settings
					}
			}
			
		}
			//setTimeout(function(){$(".pd1 select:visible").focus();},500);
	}

}

function processComplexCharts(topChartsFields){
if(topChartsFields!=null && topChartsFields!=""){
var topChartsFieldsArr=topChartsFields.split("#");
			for(var i=0;i<topChartsFieldsArr.length;i++){
				var fldArr=topChartsFieldsArr[i].split("~");
if(fldArr!=null && fldArr.length>=9){//complex charts
					    var isGeo1=false;
					    var autoPIn=false;
					    var filterIdSpan="cmplxCh"+i;
						var gwinId=filterIdSpan+"GWin";
						//var gwinId=filterIdSpan+"GWin";
        				var gwinIdIn=filterIdSpan+"GWinIn";
						var width1=Math.min((isGeo1&& false?800:Math.min(650,650)),$(self).width()-10);//$("#topGraphs").width()/2-10
       					var height1=( isGeo1&& false?450:Math.min(305,Math.max(250,250)));//$(self).height()/2-30
       					var chartID=gwinId;
       					var chartType =fldArr[3];
       					var chartLink ="";
       					var colName = fldArr[4];
						var amountFName= fldArr[2];
						var field1=fldArr[1];
						var amountFleild=fldArr[5];
						var title1=fldArr[0];
						var field2=fldArr[6];
						var title2=fldArr[7];
						var showCurrency=fldArr[8];
						var logscale=fldArr.length<9 || fldArr[9]=="1"?1:0;
       					
       					var funcStr="createChart('"+chartID+"','"+chartType+"','"+chartLink+"','"+colName+"','"+amountFleild+"','"+field1+"','"+amountFName+"','"+title1+"','"+field2+"','"+title2+"','"+showCurrency+"',null,"+logscale+")";
						 if($("#"+gwinId).length==0){
				            var graphTitle=fldArr[0];
				            ChartsArrayTitle[gwinId]=graphTitle;
				            $("body").append("<div id='"+gwinId+"' class='graphs' title='"+encodeHTML(graphTitle)+"' style='height:"+(height1)+"px;width:"+(width1)+"px;padding:0px;'><div id='"+gwinIdIn+"' class='graphsIn' style='height:"+(height1-55)+"px;width:"+(width1-10)+"px;'> <div class='ld1'></div></div></div>");
				            $("#"+gwinId).dialog({width:width1,height:height1
				                ,position: (autoPIn==null?{ my: "right bottom", at: "right bottom", of: "#mainTBX1" }:null)
				            ,close:function(){
				            	//closeGraph(gwinId,field1);
				            	//alert("Edit the layout to remove this chart");
				            	return false;
				            	}
				            ,open:function(){ 
				            	$("#"+gwinId).parents("div.ui-dialog:first").find(".ui-dialog-titlebar:first").append("<button  class=\"graphsRefresh ui-button ui-corner-all ui-widget ui-button-icon-only\" type=\"button\" onclick=\""+funcStr+";return false;\" role=\"button\" onmouseover=\"$(this).addClass('ui-state-hover');\" onmouseout=\"$(this).removeClass('ui-state-hover');\"><span class=\"ui-icon ui-icon-refresh\" title=\""+Refresh_Chart+"\"></span></button>");
				            	
				            	fixIfmHegt();
				            	},draggable:(autoPIn==null)
				            	
				            }
				            );
				            
				            var dialog=$("#"+gwinId).parents("div.ui-dialog:first");
							$("#topGraphs").append(dialog);
							//fixIfmHegt();
				        }else{
				            $("#"+gwinId+ " #"+gwinIdIn).html("<div class='ld1'></div>");
				            $("#"+gwinId).dialog({width:width1,height:height1,close:function(){
				            	//closeGraph(gwinId,field1);
				            	
				            	},open:fixIfmHegt,draggable:(autoPIn==null)});
				            	//fixPinnedGraph(gwinId);
				            //$("#"+gwinId).dialog("destroy");
				        }
				        //alert(fldArr);
				        
					     createChart(chartID,chartType,chartLink,colName,amountFleild,field1,amountFName,title1,field2,title2,showCurrency,null,logscale);
					     fixPinnedGraph(gwinId);
					}
	}
	}				
}
function closeGraph(gid,field1){
//alert(field1);
	var topChartsFields="#"+($(".topChartsFields").val())+"#";
	var field1C=field1;
	//topChartsFields.indexOf("#"+field1C+"#")==-1 && topChartsFields.indexOf("#"+field1C+"~")==-1 &&
	if(field1C.indexOf(".name")>0){//remove name version and after that the id version
		unPinGraph(field1C);
		field1C=field1C.replace("__r.name","__c");
		field1C=field1C.replace(".name","id");
	}
	if(topChartsFields.indexOf("#"+field1C+"~")>-1 ||topChartsFields.indexOf("#"+field1C+"#")>-1){
		unPinGraph(field1C);
	}
	//alert(topChartsFields+ "+++"+field1C);
	$("#"+gid).remove();
	ChartsArray[gid]=null;
	//closeAllTooltips();
    fixIfmHegt();
}

function fixPinnedGraph(gwinId){
	if($("#"+gwinId).length>0 && $("#"+gwinId).parents("#topGraphs").length>0){
       		var dialog=$("#"+gwinId).parents("div.ui-dialog:first");
			dialog.css({"position":"relative","z-index":"1","top":"0px","left":"0px","display":"inline-block"}); 
			$("#"+gwinId).dialog({
			  draggable: false
			});
			//alert(1);
        }
}

// instant charts 
var ChartsArray=new Array();
var ChartsArrayTitle=new Array();
var graphWasLoaded=0;
function createGarphsDataFilter(field1,filterIdSpan,fieldCalss1,filterObjShowType,amountFleild,amountFName,colName,filterCount1,hasGeo,resultData,fetchCount1,autoPIn,chartType,objRefName){
	//alert(chartType)
   var isBar=(chartType=="true" || chartType=="B");
   if(chartType=="B" || chartType=="P"){
   		hasGeo=false;
   }
   var fieldMap1=new Array();
   var maxResRows=500;
     var graphTitle="";
   try{
    var orderTH=8;
   var resultsHTML="";
   var useExpField=false;
   var boolValFirst=-1;
   var gwinId=filterIdSpan+"GWin";
        var gwinIdIn=filterIdSpan+"GWinIn";
      
   if(filterObjShowType=='1' || filterObjShowType=='12' || filterObjShowType=='4'  || filterObjShowType=='4f'  || filterObjShowType=='2'|| filterObjShowType=='6'|| filterObjShowType=='5'|| filterObjShowType=='7'){//text,bool,date,datetime,int,reference
        
        var isGeo1=("true"==hasGeo)&&(filterObjShowType=='1' ||filterObjShowType=='1f'  )&& (field1.indexOf("country")>-1);
        
        if(isBar==null){
        	isBar=null;
        }
        if(autoPIn==null){
        	autoPIn=null;
        }
       
        var funcStr="createGarphsDataFilter(\""+field1+"\",\""+filterIdSpan+"\",\""+fieldCalss1+"\",\""+filterObjShowType+"\",\""+amountFleild+"\",\""+amountFName+"\",\""+colName+"\",\""+filterCount1+"\",\""+hasGeo+"\",null,null,"+autoPIn+",\""+chartType+"\",\""+objRefName+"\")";
        $("#topGraphs").width($("#topGraphs").width());
        var width1=Math.min((isGeo1&& false?800:Math.min(650,650)),$(self).width()-10);//$("#topGraphs").width()/2-10
        var height1=( isGeo1&& false?450:Math.min(305,Math.max(250,250)));//$(self).height()/2-30
        if($("#"+gwinId).length==0){
            graphTitle=Graphs_title_field_per_col.replace("{0}",(amountFName==""?labelForObj:amountFName)).replace("{1}",colName);
            ChartsArrayTitle[gwinId]=graphTitle;
            $("body").append("<div id='"+gwinId+"' chartType='"+chartType+"' isBar='"+isBar+"' class='graphs' title='"+graphTitle+"' style='height:"+(height1)+"px;width:"+(width1)+"px;padding:0px;'><div id='"+gwinIdIn+"' class='graphsIn' style='height:"+(height1-55)+"px;width:"+(width1-10)+"px;'> <div class='ld1'></div></div></div>");
            
            $("#"+gwinId).dialog({width:width1,height:height1
                ,position: (autoPIn==null?{ my: "right bottom", at: "right bottom", of: "#mainTBX1" }:null)
            ,close:function(){
            	closeGraph(gwinId,field1);
            	}
            ,open:function(){ 
            	$("#"+gwinId).parents("div.ui-dialog:first").find(".ui-dialog-titlebar:first").append("<button type='button' class='graphsRefresh ui-button ui-corner-all ui-widget ui-button-icon-only' onclick='"+funcStr+"' role='button' onmouseover='$(this).addClass(\"ui-state-hover\");' onmouseout='$(this).removeClass(\"ui-state-hover\");'><span class='ui-icon ui-icon-refresh' title='"+Refresh_Chart+"'></span></button>").append("<button type='button' class='graphsPin ui-button ui-corner-all ui-widget ui-button-icon-only' onclick='pinGraph(\""+gwinId+"\",\""+field1+"\");' role='button' onmouseover='$(this).addClass(\"ui-state-hover\");' onmouseout='$(this).removeClass(\"ui-state-hover\");'><span class='ui-icon ui-icon-pin-w' title='"+Pin_Chart+"'></span></button>")
            	
            	if(autoPIn!=null){
            		pinGraph(gwinId,field1,autoPIn);
            	}
            	fixIfmHegt();
            	},draggable:(autoPIn==null)
            	
            }
            );
            //fixIfmHegt();
        }else{
            $("#"+gwinId+ " #"+gwinIdIn).html("<div class='ld1'></div>");
            $("#"+gwinId).dialog({width:width1,height:height1,close:function(){
            	closeGraph(gwinId,field1);
            	
            	},open:fixIfmHegt,draggable:(autoPIn==null)});
            	fixPinnedGraph(gwinId);
            //$("#"+gwinId).dialog("destroy");
        }
			unPinGraph(field1);
            $("#"+gwinId).dialog("moveToTop");
			$("#"+gwinId).attr("isBar",isBar);
			$("#"+gwinId).attr("chartType",chartType);
			$("#"+gwinId).parents(".ui-dialog:first").find(".graphsRefresh").attr("onclick",funcStr);
			$(".topChartsFields").val($(".topChartsFields").val()+"#"+field1+"~"+chartType);
			
			
        //loadingSH();
        var fieldSoql=field1;
        
        if(filterObjShowType=='7' && field1!='id' ){
            if(field1.indexOf("id")==field1.length-2){
                field1=field1.substring(0,field1.length-2)+"."+objRefName;
            }
            if(field1.indexOf("__c",Math.max(0,field1.length-4))==field1.length-3){
                field1=field1.substring(0,field1.length-1)+"r."+objRefName;//'zaapit__'+
            }
            fieldSoql=field1;
        }else if(filterObjShowType=='6' || filterObjShowType=='2'){
        	
        	switch(chartType){
	        	case "D":
	        		if(filterObjShowType=='6'){
	            		fieldSoql="DAY_ONLY("+field1+")";
	            	}
	            	break;
	        	case "M":
	            	fieldSoql="CALENDAR_YEAR("+field1+") f2,CALENDAR_MONTH("+field1+")";
	            	break;
	            case "W":
            	fieldSoql="CALENDAR_YEAR("+field1+") f2,WEEK_IN_YEAR("+field1+")";
            	break;
            	case "Q":
            	fieldSoql="CALENDAR_YEAR("+field1+") f2,CALENDAR_QUARTER("+field1+")";
            	break;
            	case "Y":
            	fieldSoql="CALENDAR_YEAR("+field1+")";
            	break;
            	default:
            		if(filterObjShowType=='6'){
	            		fieldSoql="DAY_ONLY("+field1+")";
	            	}
	            	break;
            }
            
            //useExpField=true;
        
        }
        
        var query1="";
        if(amountFleild!=null && amountFleild!=""){
            query1="SELECT "+(filterObjShowType=='12' && field1.indexOf('.')==-1?"toLabel("+field1+") l1,":"")+fieldSoql+" f1,count(id) c1,sum("+amountFleild+") s1 "+DBsubQery+" group by "+(fieldSoql.replace(" f2,",","))+" order by "+(filterObjShowType!='5' && filterObjShowType!='2' && filterObjShowType!='6'?" sum("+amountFleild+")desc, "+(fieldSoql.replace(" f2,"," asc,"))+" asc ":" "+(fieldSoql.replace(" f2,"," asc,"))+" asc, sum("+amountFleild+")desc " )+" limit "+maxResRows+DB_END_ALLROWS_Qery;
        }else{
            query1="SELECT "+(filterObjShowType=='12'  && field1.indexOf('.')==-1?"toLabel("+field1+") l1,":"")+fieldSoql+" f1,count(id) c1 "+DBsubQery+" group by "+(fieldSoql.replace(" f2,",","))+" order by "+(filterObjShowType!='5' && filterObjShowType!='2' && filterObjShowType!='6'?" count(id) desc,"+(fieldSoql.replace(" f2,"," asc,"))+" asc ":" "+(fieldSoql.replace(" f2,"," asc,"))+" asc, count(id) desc ")+" limit "+maxResRows+DB_END_ALLROWS_Qery;
        }
         //alert(query1);
    
    if(resultData==null && fetchCount1==null){
    Visualforce.remoting.Manager.invokeAction(
                remoteQueryAjax2,
                query1, 
                function(result, event){
                    if (event.status && result!=null) {
    
                        createGarphsDataFilter(field1,filterIdSpan,fieldCalss1,filterObjShowType,amountFleild,amountFName,colName,filterCount1,hasGeo,result,"1",autoPIn,chartType,objRefName);
                    
                     } else if (event.type === 'exception') {
                        if(event.message!=null && ((event.message+"").indexOf("Logged in")>-1 || (event.message+"").indexOf("Refresh page")>-1)){
                            self.location=self.location;
                        }else if(event.message!=null && (event.message+"").indexOf("Unable to connect")==-1){
                            if($("body:visible").length>0)alert("An error has occurred: "+event.message);
                        }
                    } else {
                        //self.location=self.location;
                        // $("#"+filterIdSpan+" .availVals").html("");
                        //alert(1);
                    }
                }, 
                {escape: true,buffer:true,timeout: 90000}
            );
            return;
            }

        var queryMore = true;
        var hasRows = false;
        var count1=0;
        var showButtons=false;
         var data = new google.visualization.DataTable();
             

            var records = resultData;
            if(records!=null && records.length>0){
                   
                for (var key in records[0]) {
                    //alert(key+" "+records[0][key]+" "+(typeof  records[0][key]));
                    fieldMap1[key.toLowerCase()]=key;
                    if(records[0][key]!=null && (typeof records[0][key]) == "object"){
                    
                        for (var key1 in records[0][key]) {
                            fieldMap1[key1.toLowerCase()]=key1;
                        }
                    }  
                }
                
            }else{
            	$("#"+gwinIdIn+"").html("<div style='margin:"+((height1/2)-30)+"px 0px 0px "+((width1/2)-69)+"px;color:#999999;'>"+No_Chart_Data+"</div>");
            }
            var type1="string";
            if(filterObjShowType=='5'){//int
                if(filterCount1<=orderTH){
                    type1="string";//
                }else{
                    type1="number";
                }
            }else if(filterObjShowType=='2' || filterObjShowType=='6'){//date
                type1=(isBar || (chartType+"").length<3?"string":"date");
            }
           // else if(isGeo1){
           //    type1="country";
           // }
            
            var FormatForX="MMM yyyy";
            switch(chartType){
	        	case "D":
	            	FormatForX="dd MMM yyyy";
	            	break;
	        	case "M":
	            	FormatForX="MMM yyyy";
	            	break;
	            case "W":
            		FormatForX="yyyy-'W'ww";	
            	break;
            	case "Q":
            		FormatForX="yyyy-Qqq";	
            	break;
            	case "Y":
            		FormatForX="yyyy";
            	break;
            	default:
	            	FormatForX="yyyy";
	            	break;
            }
            var formatterX = new google.visualization.DateFormat({pattern: FormatForX});
            var formatterCur = new google.visualization.NumberFormat(
                {prefix: orgDefCurrency});
            var formatterNum = new google.visualization.NumberFormat({pattern:"#"});
            var formatterNum3 = new google.visualization.NumberFormat({pattern:"#,###,###"});
            data.addColumn({type:type1, label:colName});
            data.addColumn({type:"number", id:'Total',label:(amountFName==null || amountFName==""?Total_text:amountFName)});
            data.addColumn({type:"string", id:'tooltip',role:"tooltip"});
             
            //data.addColumn({type:'string',role:'tooltip'});
            //data.addColumn('string', null);   
            
            //alert(records[0]);
            var expfieldsStart=(!useExpField?0:1);
            var expfieldsStart2=expfieldsStart+1;
            var countFname="c1";//'expr'+expfieldsStart;
            var sumFname="s1";//'expr'+expfieldsStart2;
            var fieldDotIdx=field1.indexOf(".");
            var field1Xnd=(fieldDotIdx>-1?field1.substring(fieldDotIdx+1):field1);
            var mainFieldName="f1";//(useExpField?"expr0":fieldMap1[field1Xnd]);
            data.addRows(records.length);
            
            for (var i = 0; i < records.length; i++) {
                hasRows=true;
                var val1=records[i][mainFieldName];
                var val2=records[i]["f2"];
                //alert(val1 + val2);
                 var val1Vis=(val2!=null?""+val2+"-":"")+val1;
                if(val1==null || val1==""){
                    val1Vis=Blanks_txt;
                } else if(val1.indexOf("&")>-1){
                    
                    val1=val1.replace("amp;","").replace("amp;","");
                    
                     val1Vis=val1;
                }
                if(filterObjShowType=='12' && records[i]["l1"]!=null && val1!=records[i]["l1"]){
                	val1Vis=val1+" ("+records[i]["l1"]+")";
                }
                
               
                
                var val1Count=records[i][countFname];
                var val2sum=records[i][sumFname];
                var objN="";
                if(filterObjShowType=='5'){//int
                    if(filterCount1<=orderTH){
                        data.setValue(i,0,val1+" ("+val1Count+")");
                    }else{
                        data.setValue(i,0,Number(val1));
                    }
                }else if(filterObjShowType=='2' || filterObjShowType=='6'){//date
                	//alert(chartType+ " " +((chartType+"")=="false"));
                    if(val1!=null && val1!=""){
                    	var darr=val1Vis.split(/\-/);
                    	
                    	if((chartType+"")=="false"){
                        	var d1=new Date(Number(darr[0]),darr[1],Number(darr[2]));
                       		data.setValue(i,0,d1 );
                        }else{
                        
                        	switch(chartType){
				        	case "D":
						            	var d1=new Date(Number(darr[0]),Number(darr[1])-1,Number(darr[2]));
		                        	var X=formatterX.formatValue(d1);
		                        	data.setValue(i,0,X);
				            	break;
				        	case "M":
						            	var d1=new Date(Number(darr[0]),Number(darr[1])-1,1);
		                        	var X=formatterX.formatValue(d1);
		                        	data.setValue(i,0,X);
				            	break;
				            case "W":
			            			var X=val2+"-W"+val1;
		                        	data.setValue(i,0,X);
			            	break;
			            	case "Q":
			            		var X=val2+"-Q"+val1;
		                        	data.setValue(i,0,X);
			            	break;
			            	case "Y":
			            		var X=val1Vis;
		                        	data.setValue(i,0,X);
			            	break;
			            	default:
				            	var X=val1Vis;
		                        	data.setValue(i,0,X);
				            	break;
			            }
            
                       		 
                        }
                    }else{
                        data.setValue(i,0,null);
                    }
                }else if(filterObjShowType=='4' || filterObjShowType=='4f'){//booleans
                    var valBoo=(val1+"")=="true";
                    val1Vis=(valBoo?"Yes":"No");
                    if(boolValFirst==-1){
                        boolValFirst=(valBoo?1:0);
                    }
                    data.setValue(i,0,val1Vis +" ("+val1Count+")");
                }else{
                    if(!isGeo1  &&  (amountFleild!=null && amountFleild!="")){
                        data.setValue(i,0,val1Vis +" ("+val1Count+")");
                    }else{
                        data.setValue(i,0,val1Vis);
                    }
                }
                if(val2sum!=null){
                    data.setValue(i,1,Number(val2sum==null || val2sum=="" ?0:val2sum));
                    //data.setValue(i,2,val1+": $"+val2sum+" ("+val1Count+")");
                    //alert(val1Count+ " "+val2sum);
                }else{
                    data.setValue(i,1,Number(val1Count==null || val1Count=="" ?0:val1Count));
                    //data.setValue(i,2,val1Count+"");
                    //data.setValue(i,2,val1+": "+val1Count+"");
                }
                var formatTooltip=(amountFleild!=null && amountFleild!="" && $("th.thw."+amountFleild+"[tpx]").size()>0 && $("th.thw."+amountFleild+"[tpx]").attr("tpx").indexOf("35")==0?formatterCur : formatterNum3);
                var tooltip1=colName+": "+(data.getValue(i,0)==null?Blanks_txt:data.getValue(i,0))+"\n"+(amountFName!=null && amountFName!=""?amountFName+": "+(val2sum==null || val2sum=="" ?formatTooltip.formatValue(0):formatTooltip.formatValue(val2sum)):"")+"\n"+Total_text+": "+formatterNum.formatValue(val1Count)+"";
                data.setValue(i,2,tooltip1);
                //data.setValue(i,3,field1+"="+val1);
				
            count1++;
            }
           
   
        //alert(data+ "\n\n "+amountFleild);
        if(hasRows){
         //var data = google.visualization.arrayToDataTable(dataPreG);

        
         
        if(amountFleild!=null && amountFleild!=""){
            var symbol= orgDefCurrency;
            //symbol=symbol.substring(0,1);
             var formatter = new google.visualization.NumberFormat(
                {prefix: symbol});
            formatter.format(data, 1); // Apply formatter to second column 
            // var formatter = new google.visualization.PatternFormat('{0}: {1}');
            // formatter.format(data, [0,1], 0); 
        }
        
       var useCustomselect=false;
            var options = null;//
          var chart=null;
         if(filterObjShowType=='5'){//int
          
             
            if(filterCount1<=orderTH){
                    /*options={chartArea:{top:0,height:"90%"}
                    ,colors:['blue','#CC0000','orange','#00CC00','#800080','#FFAA00','#00FFFF','#FF00AA','green','#AA00AA','#00AAAA','#AAAA00','#999900','#555500','lime']
                    // title: 'My Daily Activities'
                    };*/
                    options={chartArea:{top:10,width:"85%",height:"75%"},legend: { position: "none" }, vAxis: {format:'sort'},hAxis: {
				            
				          },tooltip:{isHtml:false}
				           ,vAxis: {format:'short',titleTextStyle:{bold:true},title:(amountFleild==''?'Record Count':'Sum of '+amountFName),logScale:true,scaleType:'mirrorLog'}
				           };
                chart = new google.visualization.ColumnChart(document.getElementById(gwinIdIn));
            }else{
                options={chartArea:{top:0,height:"95%"}
                ,colors:['blue','#CC0000','orange','#00CC00','#800080','#FFAA00','#00FFFF','#FF00AA','green','#AA00AA','#00AAAA','#AAAA00','#999900','#555500','lime']
                // title: 'My Daily Activities'
                };
                chart = new google.visualization.LineChart(document.getElementById(gwinIdIn));
            }
          }else if(filterObjShowType=='2' || filterObjShowType=='6'){//date
          
          
               options={chartArea:{top:5,height:"95%"}
            ,colors:['blue','#CC0000','orange','#00CC00','#800080','#FFAA00','#00FFFF','#FF00AA','green','#AA00AA','#00AAAA','#AAAA00','#999900','#555500','lime'],displayAnnotations:false,displayAnnotationsFilter:false,dateFormat:"dd MMM yyyy"
            // title: 'My Daily Activities'
            };
            if((chartType+"")=="false"){
	             //var formatter = new google.visualization.NumberFormat({prefix: symbol});
	            //formatter.format(data,1);  // Apply formatter to second column 
           		 chart = new google.visualization.AnnotationChart(document.getElementById(gwinIdIn));

             var rangechange= function () {
                var topping="";
                try{
                var selTot=chart.getVisibleChartRange();
                var start=selTot.start;
                var startStr=start.getFullYear()+"-"+(start.getMonth()+1<10?"0":"")+""+(start.getMonth()+1)+"-"+(start.getDate()<10?"0":"")+""+start.getDate();
                var end=selTot.end;
                var endStr=end.getFullYear()+"-"+(end.getMonth()+1<10?"0":"")+""+(end.getMonth()+1)+"-"+(end.getDate()<10?"0":"")+""+end.getDate();
                //alert(startStr + " " +endStr+ " ");
                $('#'+filterIdSpan+' .'+fieldCalss1+"1").val(startStr);
                $('#'+filterIdSpan+' .'+fieldCalss1+"2").val(endStr).change();
                //filterCol(null,100);//13
                }catch(e){}
                //$('#'+filterIdSpan+' .'+fieldCalss1).val(topping).focusin().keyup();
                };
                google.visualization.events.addListener(chart, 'rangechange', rangechange);
                 
                }else{//		column chart
                
                var titlehAxis="";
                	switch(chartType){
				        	case "D":
						           titlehAxis="Grouped by Day";
				            	break;
				        	case "M":
						            titlehAxis="Grouped by Month";
				            	break;
				            case "W":
			            			titlehAxis="Grouped by Weeks in Year";
			            	break;
			            	case "Q":
			            		titlehAxis="Grouped by Quarter";
			            	break;
			            	case "Y":
			            		titlehAxis="Grouped by Year";
			            	break;
			            	default:
				            	titlehAxis="Grouped by Year";
				            	break;
			            }
                
                	var formatter = new google.visualization.DateFormat({pattern: FormatForX});
                		//options={legend: { position: "none" }
                		options={chartArea:{top:10,width:"81%",height:"64%"},legend: { position: "none" },hAxis: {
				            title: titlehAxis,
				          },tooltip:{isHtml:( isIe8!="true")}
				           ,vAxis: {format:'short',titleTextStyle:{bold:true},title:(amountFleild==''?'Record Count':'Sum of '+amountFName)}//,logScale:true,scaleType:'mirrorLog'
				           };
                		formatter.format(data, 0);
                		
                		useCustomselect=true;
		            	chart = new google.visualization.ColumnChart(document.getElementById(gwinIdIn));
		            	
		            	
		            	 var selectHandler= function () {
				            var topping="";
				            try{
				            var selTot=chart.getSelection();
				            //alert(selTot);
				            var selectedItem = selTot[0];
				            if (selectedItem) {
				            	var formatter_gva = new google.visualization.DateFormat({pattern: "yyyy-MM-dd"});
				                topping = data.getValue(selectedItem.row, 0);//date
				                //alert(topping);
				                if(topping!=null){

					                var val1="";
					                var val1="";
					                switch(chartType){
							        	case "D":
									            	var dx=topping.split(" ");
								                	var dx1= ""+dx[1]+" "+dx[0]+", "+dx[2]+"";
								                	var ddx=new Date(dx1);
									                val1=formatter_gva.formatValue(ddx);
									                var date2=addXtoDate(ddx,0,0,0);//adding 1 day
									                val2=formatter_gva.formatValue(date2);
							            	break;
							        	case "M":
									       			var dx=topping.split(" ");
								                	var dx1= ""+dx[0]+" 1, "+dx[1]+"";
								                	var ddx=new Date(dx1);
									                val1=formatter_gva.formatValue(ddx);
									                var date2=addXtoDate(ddx,0,1,-1);//adding 1 month - one day
									                					                
									                val2=formatter_gva.formatValue(date2);
									                
							            	break;
							            case "W":
						            			var dx=topping.split("-W");
								                	var dx1= ""+dx[0]+" 1, Jan";
								                	var ddx=new Date(dx1);
								                	ddx=addXtoDate(ddx,0,0,(Number(dx[1])-1)*7);//adding week*7 the week start of the year
									                val1=formatter_gva.formatValue(ddx);
									                var date2=addXtoDate(ddx,0,0,6);//adding 7 days
									                val2=formatter_gva.formatValue(date2);
						            	break;
						            	case "Q":
						            		var dx=topping.split("-Q");
								                	var dx1= ""+dx[0]+" 1, Jan";
								                	var ddx=new Date(dx1);
								                	ddx=addXtoDate(ddx,0,(Number(dx[1])-1)*3,0);//adding week*7
									                val1=formatter_gva.formatValue(ddx);
									                var date2=addXtoDate(ddx,0,3,-1);//adding 7 days
									                val2=formatter_gva.formatValue(date2);
						            	break;
						            	case "Y":
						            				var dx=topping.split(" ");
								                	var dx1= ""+dx[0]+" 1, Jan";
								                	var ddx=new Date(dx1);
								                	ddx=addXtoDate(ddx,0,0,0);//adding week*7
									                val1=formatter_gva.formatValue(ddx);
									                var date2=addXtoDate(ddx,1,0,-1);//adding 1 year -1 day
									                val2=formatter_gva.formatValue(date2);
						            	break;
						            	default:
							            	titlehAxis="Grouped by Year";
							            	break;
						            }
					                
					                
					                $('#'+filterIdSpan+' .'+fieldCalss1+"1").val(val1).focusin().keyup().focusout().change();
					                $('#'+filterIdSpan+' .'+fieldCalss1+"2").val(val2).focusin().keyup().focusout().change();
			
				                }
				                
				            }
				            }catch(e){alert(e);}
				           // $('#'+filterIdSpan+' .'+fieldCalss1).val(topping).focusin().keyup().focusout();
				            filterCol(null,50);
				            };
				            
		       google.visualization.events.addListener(chart, 'select', selectHandler); 
                
            }
          }else if(filterObjShowType=='4' || filterObjShowType=='4f'){//booleans
              options={chartArea:{left:0,top:10,width:"100%",height:"95%"},tooltip:{isHtml:(isIe8!="true")}
                ,colors:[(boolValFirst==1?'#00AA00':'#CC0000'),(boolValFirst!=1?'#00AA00':'#CC0000'),'orange','#00CC00','#800080','#FFAA00','#00FFFF','#FF00AA','green','#AA00AA','#00AAAA','#AAAA00','#999900','#555500','lime']
                // title: 'My Daily Activities'
                };
           
                chart = new google.visualization.PieChart(document.getElementById(gwinIdIn));
          }else if(isGeo1){
                
                options={chartArea:{left:0,top:5,width:"100%",height:"95%"},displayMode:"regions"
                    //,colors:['blue','#CC0000','orange','#00CC00','#800080','#FFAA00','#00FFFF','#FF00AA','green','#AA00AA','#00AAAA','#AAAA00','#999900','#555500','lime']
                    // title: 'My Daily Activities'
                    };
               
                 chart = new google.visualization.GeoChart(document.getElementById(gwinIdIn));
                 
           //bar chart      
         /* }else if(field1.indexOf("status")>-1 || field1.indexOf("type")>-1|| field1.indexOf("stage")>-1){
          
           options={ hAxis: {title: colName}
                ,colors:["#0000FF"],vAxis:{logScale:true,scaleType:'mirrorLog',format:'short'}
                // title: 'My Daily Activities'
                };
                
                chart = new google.visualization.ColumnChart(document.getElementById(gwinIdIn));
          */  
          }else{
          if(isBar==null || !isBar){
              	options={chartArea:{left:0,top:10,width:"100%",height:(isSF1P ?"85%":"95%")},tooltip:{isHtml:(isIe8!="true")},legend:{textStyle:{fontSize:13.5},position:"right",width:"80%"}
            	,colors:['blue','#CC0000','orange','#00CC00','#800080','#FFAA00','#00FFFF','#FF00AA','green','#AA00AA','#00AAAA','#AAAA00','#999900','#555500','lime']
            	// title: 'My Daily Activities'
            	//,pieHole: 0.4
            	};
             	//var formatter = new google.visualization.PatternFormat(colName+": {0}  "+(amountFName==null || amountFName==""?Total_text:amountFName)+': {1}');
             	//formatter.format(data, [0,1], 2);

             	 
            	chart = new google.visualization.PieChart(document.getElementById(gwinIdIn));
            }else{
            	
            	options={legend: { position: "none" },hAxis:{logScale:true,scaleType:'mirrorLog',format:'short'},tooltip:{isHtml:(isIe8!="true")}
            	// title: 'My Daily Activities'
            	//,pieHole: 0.4
            	};

            	chart = new google.visualization.BarChart(document.getElementById(gwinIdIn));
            }
          }
          
          if(!useCustomselect){
	           var selectHandler= function () {
	            var topping="";
	            try{
	            var selTot=chart.getSelection();
	            //alert(selTot);
	            var selectedItem = selTot[0];
	            if (selectedItem) {
	                topping = data.getValue(selectedItem.row, 0);
	                //alert('The user selected ' + topping);
	                topping=new String(topping==null?"":topping);
	                if(topping!=null && topping.indexOf(" (")>-1){
	                    topping=topping.split(/ \(/)[0];
	                }
	                if(topping.indexOf(",")>-1 || topping.indexOf("'")>-1 ||topping.indexOf("\"")>-1 ||topping.indexOf("\\")>-1){
	                    topping=topping.replace(/\,|'|"|\\/ig,"_");
	                }
	                topping=topping.replace("&quot;","_");
	                topping=topping.replace("&#39;","_");
	                topping=topping.replace("\\","_");
	
	                if(topping==Blanks_txt){
	                    topping=" ,";//blanko filter
	                }else{
	                    topping=topping+",";
	                }
	                 //alert('The user selected ' + topping);
	            }
	            }catch(e){}
	            $('#'+filterIdSpan+' .'+fieldCalss1).val(topping).focusin().keyup().focusout();
	            filterCol(null,50);
	            };
	            google.visualization.events.addListener(chart, 'select', selectHandler); 
			}
			
			//var formatter = new google.visualization.PatternFormat(colName+": {0}\n"+(amountFName==null || amountFName==""?Total_text+': {1}':amountFName+': {1}\n'+Total_text+': {2}'));
           // formatter.format(data, [0,1,2], 2);

          
          google.visualization.events.addListener(chart, 'ready', function () {
		      ChartsArray[gwinId]=chart.getImageURI();
		      
		    });
          chart.draw(data, options);
          //ChartsArray[gwinId]=chart;
          
        }
        }
    }catch(e1){
        
            if(e1!=null && (e1+"").indexOf("INVALID_FIELD")>-1){
                alert("One of the below marked fields have access right issues: \n\n"+e1);
            }else if(e1!=null && (e1+"").indexOf("INVALID_SESSION_ID")>-1){
                self.location=self.location;
            }else if(e1!=null && (e1+"").indexOf("Unable to connect")==-1){
                alert("An error has occur: "+e1);
            }
        }
  }
  
function addXtoDate(date,years,months,days)
{
	var date2=new Date(date.getFullYear()+years,date.getMonth()+months,date.getDate()+days);
	//alert(date2);
    return date2;
}
    
function togglesGraphs1(){
//  $("#graphsRusx").html("Hello").show("slide", { direction: "left" }, 3000);
}
function togglesMaps1(){
    //$("#mapRusx").html("Hello").show("slide", { direction: "left" }, 3000);
}

  var lastTextareaObj=null;
  function fixDilalogIframeHeight(){
  	var isIfrm= (top != self && parent.frames.length > 0);
       var maxHieghtIframe=750;
       if($(window).height()<maxHieghtIframe || $("html,body").height()<maxHieghtIframe){
           if(!isIfrm){
                maxHieghtIframe=$(window).height();
                //alert(maxHieghtIframe);
           }else if(isIfrm ){
                lastBodyHeight=$("html,body").height();
                //alert(lastBodyHeight);
                //$("html,body").height(maxHieghtIframe);
                $("#padBut1").height(Math.max($("#padBut1").height(),maxHieghtIframe-$(self).height()));
                fixIfmHegt();
           } 
       }
  }
  
  var lastcurrLen1enhanceFuncInp=null;

  function setenhanceFuncInpTextSize(obj){

  	if(lastcurrLen1enhanceFuncInp!=null){
  		clearTimeout(lastcurrLen1enhanceFuncInp);
  		lastcurrLen1enhanceFuncInp=null;
  	}
  	lastcurrLen1enhanceFuncInp=setTimeout(function(){
  		var curlen=obj.value.length;
  		if(obj.maxlength!=null && curlen+1>maxlength) {
  			obj.value=obj.value.substring(0,maxlength);
  			curlen=obj.value.length;
  		}
  		$('#currLen1').html(curlen);
  	},500);
  }
  function enhanceFuncInp(obj,clsForName){
  
 	 
	
    if(obj!=null && Open_TextArea_in_a_dialog__c && $(obj).prop("tagName")!=null && $(obj).prop("tagName").toUpperCase()=="TEXTAREA"){
    fixDilalogIframeHeight();
    var formatterInt = new google.visualization.NumberFormat({
            pattern: '#,###,###.##'
        });
        lastTextareaObj=obj;
        $("#textAreaEditDialog1TA").val($(obj).val());
        $("#textAreaEditDialog1TA").attr("maxlength",$(obj).attr("maxlength"));
        if($(obj).attr("maxlength")!=null){
            $("#maxLen1").html(" / "+formatterInt.formatValue($(obj).attr("maxlength")));
            $("#currLen1").html($(obj).val().length);
            
        }else{
            $("#maxLen1").html("");
            $("#currLen1").html($(obj).val().length);
        }
        $(obj).parents("tr.dataRow:first").addClass("markedRowTA");
        
        $("#textAreaEditDialog1").dialog({
            resizable: true,
            height:500,
            width:(isSF1()?($(self).width()-20):500),
            modal: openDialogAsMod(),
            title: $("."+clsForName+":first").text(),
            buttons: [{
            text:OK_buttons,
            click: function() {
                $(obj).val($("#textAreaEditDialog1TA").val()).change();
                $( this ).dialog( "close" );
            }},{text:Cancel_button,
            click: function() {
                $( this ).dialog( "close" );
            }}]
            ,
             close: function( event, ui ) {
             	$(obj).parents("tr.dataRow:first").removeClass("markedRowTA",1000,function(){});
             	if(lastBodyHeight!=null){
                      $("#padBut1").height(0);
                      fixIfmHegt();
               }
             }
            });
        
        
    }
}

function refreshAfterSave(viewId){
    loadingSH();
    if(viewId==null)viewId="";
    var loc1=(self.location+"");
    var prefix="/apex/";
    if(loc1.indexOf("/servlet/")>-1){
        //prefix="/apex/"
    }else if(loc1.indexOf("/apex/")>-1){
        prefix="../apex/";
    }else if(!isSF1()){
        prefix="apex/";
    }
    //refersh();
    if(loc1.indexOf("zaapit__")>-1){
        prefix=prefix+"zaapit__";
    }

  	if(!isSF1()){
  		var url1=prefix+UrlEnd1+"?"+(mainID==""?"zba=1":"id="+encodeURIComponent(mainID))+(isInIframe()?"&inline=1":"")+sfdcTabNameParam+"&pw1="+escape(parentLocParam1)+"&tp="+tp_conf+"&tx111="+(new Date().getTime())+(loc1.indexOf("&isdtp=vw")>-1?"&isdtp=vw":"")+(loc1.indexOf("&isdtp=p1")>-1?"&isdtp=p1":"")+(viewId!=""?"&viewid="+escape(viewId):"");
    	navigateZP(url1,self);
    }else{
    	self.location=self.location;
    }
}

function showMoreCurs(obj){
	var titd1=$(obj).attr("titd1");
	var curValDC=$(obj).attr("curValDC");
	if(titd1==null && currencyCodeSTR!=null && currencyCodeSTR!="" && curValDC!=null && curValDC!="" && $(obj).parents("td:first").hasClass("cur")){
		$(obj).attr("titd1","1");
		var allCursHTML="";
		var currencyCodeSTRArr=currencyCodeSTR.split("#");
		for(var i=0;i<currencyCodeSTRArr.length;i++){
			var curRow=currencyCodeSTRArr[i].split("~");
			if(curRow.length==4 && (i==0 || curRow[2]==currencyDefISO || currencyCodeNum==2)){
			var symbol=curRow[2];
			var decimalplaces=curRow[3];
			var decimalplacesSTR="";
			for(var j=0;j<Number(decimalplaces);j++){
				decimalplacesSTR+="#";
			}
			//var formatterCurr = new google.visualization.NumberFormat({pattern: ' #,###,###'+(decimalplacesSTR!=""?"."+decimalplacesSTR:"")});
			    var formatterCurr = new Intl.NumberFormat(navigator.language, { style: 'currency', currency: symbol });//new google.visualization.NumberFormat({prefix: symbol	});
		       // var formatterInt = new Intl.NumberFormat(navigator.language);//new google.visualization.NumberFormat({	pattern: '#,###,###.##'});
				allCursHTML+="<tr><td>"+symbol+"</td><td align='right'>"+formatterCurr.format(Number(curValDC)*Number(curRow[0]))+"</td></tr>";
			}
		}
		if(allCursHTML!=null && allCursHTML!=""){
			//$(obj).attr("title","<table>"+allCursHTML+"</table>");
			$(obj).tooltip({content:("<table>"+allCursHTML+"</table>")}).tooltip( "open" );
		}
		
		//alert(allCursHTML);
	}else{
		fixTitlex1(obj);
	}
}

function getAllCurs(curValDC){
	var allCursHTML="";
	if(currencyCodeSTR!=null && currencyCodeSTR!="" && curValDC!=null && curValDC!=""){
		var currencyCodeSTRArr=currencyCodeSTR.split("#");
		var addCurs=0;
		for(var i=0;i<currencyCodeSTRArr.length && addCurs<2;i++){
			var curRow=currencyCodeSTRArr[i].split("~");
			if(curRow.length==4 && (i==0 || curRow[2]==currencyDefISO || currencyCodeNum==2)){
			
				var symbol=curRow[2];
				var decimalplaces=curRow[3];
				var decimalplacesSTR="";
				for(var j=0;j<Number(decimalplaces);j++){
					decimalplacesSTR+="#";
				}
				var formatterCurr = new google.visualization.NumberFormat({prefix:symbol,pattern: ' #,###,###'+(decimalplacesSTR!=""?"."+decimalplacesSTR:"")});
				allCursHTML+=(addCurs==1?"(":"")+"<span>"+formatterCurr.formatValue(Number(curValDC)*Number(curRow[0]))+"</span>"+(addCurs==1?")":" ");
				addCurs++;
			}
		}
	}
	//alert(allCursHTML);
	return allCursHTML;
}
var totRowsForFOUNDONQ=0;
//1.000000~true~USD~2#4.515000~false~ARS~2#1.077935~false~AUD~2#2.077000~false~BRL~2#1.047000~false~CAD~2#0.943000~false~CHF~2#505.945000~false~CLP~0#6.147000~false~CNY~2#1792.757000~false~COP~0#497.958000~false~CRC~0#19.901000~false~CZK~2#5.732500~false~DKK~2#0.768521~false~EUR~2#0.653040~false~GBP~2#7.759300~false~HKD~2#227.588250~false~HUF~0#9920.635000~false~IDR~0#3.638100~false~ILS~2#97.740000~false~JPY~0#1155.350000~false~KRW~0#7.991300~false~MOP~2#13.163500~false~MXN~2#6.109000~false~NOK~2#1.283532~false~NZD~2#2.667500~false~PEN~2#3.338300~false~PLN~2#32.945000~false~RUB~2#3.750400~false~SAR~2#6.753400~false~SEK~2#1.274400~false~SGD~2#1.934900~false~TRY~2#30.126000~false~TWD~2#10.101600~false~ZAR~2#";
var currencyCodeSTR="";
var currencyCodeNum=0;
var isLastPage=true;
 function getTotals1(){
    
       var symbol= currencyDefISO;
       //symbol=symbol.substring(0,1);
  
     Visualforce.remoting.Manager.invokeAction(
            remoteTotMethod,
            queryCOunt1, 
            function(result, event){
            	try{
                var formatterCurr = new Intl.NumberFormat(navigator.language, { style: 'currency', currency: currencyDefISO, "currencyDisplay":"symbol" });//new google.visualization.NumberFormat({prefix: symbol	});
		        var formatterInt = new Intl.NumberFormat(navigator.language);//new google.visualization.NumberFormat({	pattern: '#,###,###.##'});
            
            	var totRows=0;
                if (event.status && result!=null) {
                	totRows=Number(result['countRowsx1']);
                     if(NOT_hideTotalsRow){    
                        var key;
                        for (key in result) {//fetch all avil currencies
                        	if(key.indexOf('currencyCodeSTR#')>-1 && Number(result['currencyCodeNum'])>0){
                            		currencyCodeNum=Number(result['currencyCodeNum']);
	                        		//key="currencyCodeSTR#0.768521~false~EUR~2#";
	                        		//currencyCodeNum=1;
									currencyCodeSTR=key.split("CodeSTR#")[1];	
									//alert(currencyCodeSTR);                        		
	                        	}
                        }
                        
                        for (key in result) {
                        	if(key.indexOf('currencyCode')==-1){
	                            var spanTOT=$("tfoot .TOT-"+key);
	                            var tpx=spanTOT.attr("tpx");
	                            var ost1X=spanTOT.find(".ost1X");
	                            if(spanTOT.length>0){
	                            //alert(key+" "+spanTOT.hasClass("cur")+ " "+symbol);
	                              if(spanTOT.hasClass("cur") ){
	                              		ost1X.attr("curValDC",result[key]);
	                              		//alert(currencyCodeNum);
	                              		if(currencyCodeNum==0){
	                                    	ost1X.html(formatterCurr.format(result[key]));
	                                    	if(Number(totRows)>1) ost1X.attr("title","Avg: "+formatterCurr.format(Number(result[key])/Number(totRows))).attr("alnk","X").addClass("btt1");
	                                    }else{
	                                    	ost1X.html(getAllCurs(result[key]));
	                                    }
	                                }else{
	                                    ost1X.html(formatterInt.format(result[key])+(tpx=="8" || tpx=="8f"?"%":""));
	                                    if(Number(totRows)>1) ost1X.attr("title","Avg: "+formatterInt.format(Number(result[key])/Number(totRows))+(tpx=="8" || tpx=="8f"?"%":"")).attr("alnk","X").addClass("btt1");
	                                }
	                            }
                            }else{
                            	
                            }
                        }
                    }
                    //alert(totRows);
                    totalCountAjx=totRows;
                    var totRowsFor=formatterInt.format(totRows);
                    var foundTxt=Found_x_results.replace("{0}",totRowsFor);
                    var sortedByX="";
                    if($(".mainTB1 th.thw."+(sortBy.replace('.','-'))).length>0){
                    	foundTxt=foundTxt.replace("{1}",$.trim($(".mainTB1 th.thw."+(sortBy.replace('.','-'))).text())+" "+(sortDir=="desc"?"Descending":"Ascending"));
                    	foundTxt=foundTxt.replace("XXX","");
                    }else{
                    	foundTxt=foundTxt.split("XXX")[0];
                    }
                    $(".foundX").html(foundTxt).parent().show();
					totRowsForFOUNDONQ=totRowsFor;
                    var Page_x_of_y=Page_x_of_y_ORIG;
                    var foundPages=Math.round(totRows/maxRowsPerPageCls+0.499);
                    var maxPageOfset=6000/maxRowsPerPageCls;
                    maxPageOfsetGlb=maxPageOfset;
                    if(foundPages==0){
                        foundPages=1;
                    }
                    var currPage=currPageCls;
                    Page_x_of_y=Page_x_of_y.replace("{0}",(currPage+1)).replace("{1}",formatterInt.format(foundPages));
                    Page_x_of_y=Page_x_of_y.replace("{3}",(showEntries!=""?" <span style='color:#696969;margin-left:5px;'>["+showEntries+" "+of_entries+" "+totRows+"]</span>":""));
                    $("#Page_x_of_y").html(Page_x_of_y);
                    var tCurPgScrl=(currPage+1)+" / "+formatterInt.format(foundPages);
                    $(".curPgScrl").html(tCurPgScrl);
                    $(".curPgScrlW").attr("title",tCurPgScrl);
                    isLastPage=((currPage+1)==foundPages);
                    //alert(result['countRowsx1']);
                    var numPageLinks="";
                     for(var i=Math.max(0,currPage-5);i<Math.min(foundPages,Math.max(0,currPage-5)+10);i++){
                        numPageLinks+="<a href='javascript:void(0);' onclick='jumpToClk("+i+","+maxPageOfset+");' "+(i>maxPageOfset?"style='color:#aaaaaa;'":"")+" class='"+(currPage==i?"m":"n")+"'>"+(i+1)+"</a>";
                     }

                    $("#numPageLinks").html(numPageLinks);
                    $("#srachPan2NP").show();
                    //$(".grisLastPagex1:last").html((isLastPage!=null?"+":""));
                } else if (event.type === 'exception') {
                	 if(event.message!=null && ((event.message+"").indexOf("Logged in")>-1 || (event.message+"").indexOf("Refresh page")>-1)){
                            self.location=self.location;
                     }else if(event.message!=null && (event.message+"").indexOf("Unable to conn")==-1 && (event.message+"").indexOf("Starting position")==-1 ){
                		if($("body:visible").length>0)alert("An error has occurred: "+event.message);
                	}
                    //self.location=self.location;
                    $("#srachPan2NP").show();
                } else {
                    //self.location=self.location;
                    $("#srachPan2NP").show();
                }
                
                
                var activefilters="";
                var activefiltersTit="";
                $("input.filterinoIPT").each(function(){
                	var inpX=$(this).parents("span[inpX]:first").attr("inpX");
                	var fname=$("."+inpX+":first").text();
                	var fval=$(this).val();
                	//alert(fname+" "+fval);
                	if($.trim(fval)!=""){
                		var mid=$(this).parents("span.filterino:first").attr("id");
                		if(fval.indexOf(" ,")==0){
                		    fval=Blanks_txt+fval.substring(1);
                		}else if(fval.match(/^R[0-9]+\,.*/)){
                			fval=fval.substring(1);
                			fval=fval.replace(/\,/ig," - ");
                		
                		}
						if(fval.lastIndexOf(",")==fval.length-1){
                			fval=fval.substring(0,fval.length-1);
                		}
                		if($(this).hasClass("filtDatex1Mnx")){
                			fval=fval.replace("~"," - ");
                		}
                		fval=fval.replace(/\,/ig,", ");
                		var TextToAdd="<b>"+fname+":</b> "+fval+"<br/>";
                		if(activefilters.indexOf(TextToAdd)==-1){
            				activefiltersTit=activefiltersTit+"<b>"+fname+":</b> "+fval+"  <a class='clearFlt2' href='javascript:void(0);' onclick='$(\"#"+mid+" .clearFlt\").click();'>"+label_clear+"</a><br/>";
            				activefilters=activefilters+"<b>"+fname+":</b> "+fval+"<br/>";
            			}
                		
                	}
                });
                $('input.seatchInptFZP').each(function(){
                		var fname=Search_label;
                	    var fval=$(this).val();
                	    if($.trim(fval)!=""){
                		  activefiltersTit=activefiltersTit+"<b>"+fname+":</b> "+fval+"  <a class='clearFlt2' href='javascript:void(0);' onclick='$(\".seatchInptFZPW2 .filterinoIPTCS1\").click();'>"+label_clear+"</a><br/>";
                		  activefilters=activefilters+"<b>"+fname+"</b> "+fval+"<br/>";
                		}
                });
                
                if(activefilters.length>0){
                	//activefilters=activefilters.substring(1);
                	$(".activefilters").html(activefilters);
                	$(".activefilters").attr("title",activefiltersTit);
                	$(".activefiltersW").show();
                }else{
                	$(".activefiltersW").hide();
                }
                
                
                $("body").trigger("OnGetTotalDone");
                }catch(e){alert(e);}
            }, 
            {escape: true,buffer:true,timeout: 90000}
        );
   }
   
   //***** sub totals *****
   function getSubTotals1(apiField,mainVal,headerTpx,apiField2,mainVal2,headerTpx2,grpR){//apiField2 for grouping
     //var hideSumline=queryCOunt1.indexOf("countRowsx1 FROM")>-1;
   	var orgidAPI=apiField;
   	var orgidAPI2=apiField2;
   	
    	if(apiField.length>2 &&apiField.indexOf('id')==apiField.length-2){
    		apiField=apiField.substring(0,apiField.length-2)+".name";
    	}
    	if(apiField.indexOf("-")>-1){
    		apiField=apiField.replace(/\-/ig,".");
    	}
    	if((headerTpx=="7" || headerTpx=="7f") &&apiField.indexOf("__c")>-1 ){
    		apiField=apiField.replace("__c","__r.name");
    	}
    	if(headerTpx2=="2" || headerTpx2=="2f" ){
    		mainVal2=dateTOSqlDate(mainVal2);
    	}
    	if(headerTpx=="2" || headerTpx=="2f" ){
    		mainVal=dateTOSqlDate(mainVal);
    	}
    	if(headerTpx=="61" || headerTpx=="61f" ){
    		mainVal=timeTOSqlTime(mainVal)+"";//+"" for null
    	}
    	
    	if(headerTpx2=="61" || headerTpx2=="61f" ){
    		mainVal2=timeTOSqlTime(mainVal2)+"";//+"" for null
    	}
    	
    	if(apiField2!=null){
    	
    		if(apiField2.length>2 &&apiField2.indexOf('id')==apiField2.length-2){
	    		apiField2=apiField2.substring(0,apiField2.length-2)+".name";
	    	}
	    	if(apiField2.indexOf("-")>-1){
	    		apiField2=apiField2.replace(/\-/ig,".");
	    	}
	    	if((headerTpx2=="7" || headerTpx2=="7f") &&apiField2.indexOf("__c")>-1 ){
	    		apiField2=apiField2.replace("__c","__r.name");
	    	}	
    	}
    	
       var symbol= orgDefCurrency;
       //symbol=symbol.substring(0,1);
       

  	if(apiField2!=null && headerTpx2!=null && headerTpx2==5){
  		mainVal2=mainVal2.replace(/\,/ig,"");
  	}
  	if(headerTpx!=null && headerTpx==5){
  		mainVal=mainVal.replace(/\,/ig,"");
  	}
  	//alert(mainVal+" "+grpR);
     Visualforce.remoting.Manager.invokeAction(
            remoteTotMethod,
            queryCOunt1+(queryCOunt1.indexOf("where")>-1 ?" and ":" where ")+apiField+"="+(headerTpx!=5 && headerTpx!="2" && headerTpx!="2f" && headerTpx!="61" && headerTpx!="61f"?"'":"")+(mainVal.replace(/'/ig,"\\'"))+(headerTpx!=5 && headerTpx!="2" && headerTpx!="2f" && headerTpx!="61" && headerTpx!="61f"?"'":"") +(apiField2!=null?" and "+apiField2+"="+(headerTpx2!=5 && headerTpx2!="2" && headerTpx2!="2f" && headerTpx2!="61" && headerTpx2!="61f" ?"'":"")+(mainVal2.replace(/'/ig,"\\'"))+(headerTpx2!=5 && headerTpx2!="2" && headerTpx2!="2f"  && headerTpx2!="2f" && headerTpx2!="61" && headerTpx2!="61f"?"'":""):""),   
            function(result, event){
	            var formatterCurr = new Intl.NumberFormat(navigator.language, { style: 'currency', currency: currencyDefISO, "currencyDisplay":"symbol" });//new google.visualization.NumberFormat({prefix: symbol	});
		        var formatterInt = new Intl.NumberFormat(navigator.language);//new google.visualization.NumberFormat({	pattern: '#,###,###.##'});
		        
                if (event.status && result!=null) {
                	var totRows=Number(result['countRowsx1']);

                     if(NOT_hideTotalsRow){    
                        if(totRows<=1){
                   			$("tbody .totalRow[hn1='"+escape(mainVal)+"'][grpR='"+grpR+"']").remove();
                   		}else{
                   		
	                        var key;
	                        for (key in result) {//fetch all avil currencies
	                        	if(key.indexOf('currencyCodeSTR#')>-1 && Number(result['currencyCodeNum'])>0){
	                            		currencyCodeNum=Number(result['currencyCodeNum']);
		                        		//key="currencyCodeSTR#0.768521~false~EUR~2#";
		                        		//currencyCodeNum=1;
										currencyCodeSTR=key.split("CodeSTR#")[1];	
										//alert(currencyCodeSTR);                        		
		                        	}
	                        }
	                        for (key in result) {
	                        	if(key.indexOf('currencyCode')==-1){
	                        		//console.log("tbody .totalRow[hn1='"+escape(mainVal)+"'][grpR='"+grpR+"'] .TOT-"+key);
		                            var spanTOT=$("tbody .totalRow[hn1='"+escape(mainVal)+"'][grpR='"+grpR+"'] .TOT-"+key);
		                            
		                             var tpx=spanTOT.attr("tpx");
		                            //alert(spanTOT.length); 
		                            var ost1X=spanTOT.find(".ost1X");
		                            if(spanTOT.length>0){
		                            //alert(key+" "+spanTOT.hasClass("cur")+ " "+symbol);
		                             	if(spanTOT.hasClass("cur") ){
		                              		ost1X.attr("curValDC",result[key]);
		                              		//alert(currencyCodeNum);
		                              		if(currencyCodeNum==0){
		                                    	ost1X.html(formatterCurr.format(result[key]));
		                                    	ost1X.attr("title","Avg: "+formatterCurr.format(Number(result[key])/Number(totRows))).attr("alnk","X").addClass("btt1");
		                                    }else{
		                                    	ost1X.html(getAllCurs(result[key]));
		                                    }
		                                }else{
		                                    ost1X.html(formatterInt.format(result[key])+(tpx=="8" || tpx=="8f"?"%":""));
		                                    ost1X.attr("title","Avg: "+formatterInt.format(Number(result[key])/Number(totRows))+(tpx=="8" || tpx=="8f"?"%":"")).attr("alnk","X").addClass("btt1");
		                                }
		                            }
	                            }else{
	                            	
	                            }
	                        }
	                    }
	                        var totRowsFor=formatterInt.format(totRows);
		                    //if(mainVal.indexOf("Blue")>-1)alert(escape(mainVal) + " " +headerTpx2 +" "+grpR+ " "+totRows);
		                    //alert(grpR+" "+totRows);
		                    $(".list tbody .grpx[hn1='"+escape(mainVal)+"'][grpR='"+grpR+"'] .count1").html("("+totRows+")");
                    }else{
                   			 var totRowsFor=formatterInt.format(totRows);
		                    //if(mainVal.indexOf("Blue")>-1)alert(escape(mainVal) + " " +headerTpx2 +" "+grpR+ " "+totRows);
		                    $(".list tbody .grpx[hn1='"+escape(mainVal)+"'][grpR='"+grpR+"'] .count1").html("("+totRows+")");
                    }
                    
                

                } else if (event.type === 'exception') {
                	 if(event.message!=null && ((event.message+"").indexOf("Logged in")>-1 || (event.message+"").indexOf("Refresh page")>-1)){
                       //     self.location=self.location;
                     }else if(event.message!=null && (event.message+"").indexOf("Unable to conn")==-1){
                		//if($("body:visible").length>0)alert("An error has occurred: "+event.message);
                	}
                    
                } else {
                   
                }
                
             
                
                $("body").trigger("OnGetSubTotalDone");
            }, 
            {escape: true,buffer:true,timeout: 90000}
        );
   }
   
   
   function paretnAk1(){
        openPOInst=false;
        $('#postinstMsg').hide();
   }
   
    function showMsgConf(){
        var unVisH=$("body").height()-$(self).height();
        //alert(unVisH);
        if(unVisH>0 && openPOInst){
            $('#postinstMsg').show();
        }else{
            paretnAk1();
        }
   }
   
      function clearPx(str){
        if(str!=null && str.indexOf("px")>-1){
            str=str.substring(0,str.length-2);
        }
        return str;
   }
   function selAllFlt(obj){
        var checked=$(obj).prop("checked");
        if(checked==null){
            checked="";
        }
        $(obj).parents(".fltTblOfw:first").find("input[type='checkbox']").prop("checked",checked);
   }
   function selOneFlt(obj){
   		if($(obj).attr('id').indexOf('__xx')>-1 && $(obj).parents(".fltTblOfw:first").find(".xfilt1:first").prop("checked") && $(obj).parents(".fltTblOfw:first").find(".xfilt1:checked").length>1){
   			alert(Blanks_none_black);
   		}
        $(obj).parents(".fltTblOfw:first").find(".xfilt1All").prop("checked",($(obj).parents(".fltTblOfw:first").find(".xfilt1").length==$(obj).parents(".fltTblOfw:first").find(".xfilt1:checked").length));
   }
   var disableMiddleNameFIx=false;
   function selectFilterExCBOX(filterIdSpan,fieldCalss1){
        var selectedVals="";
        var allCBOX=$("#"+filterIdSpan+" .availVals .fltTblOfw .xfilt1All");
        if(allCBOX.length>0){
            if(allCBOX.prop("checked")){
                selectedVals="";
            }else{
                $("#"+filterIdSpan+" .availVals .fltTblOfw input.xfilt1[type='checkbox']:checked").each(function(){
                    var curV1=$(this).val();
                    if(curV1.indexOf(",")>-1){
                        curV1=curV1.replace(/\,/ig,"_");
                    }
                    //contacts middle name fix
                    if(!disableMiddleNameFIx &&((filterIdSpan.indexOf("name")>-1 && tableX1=="contact") ||(filterIdSpan.indexOf("-name")>-1 && filterIdSpan.indexOf("contact")>-1)|| (filterIdSpan.indexOf("whoid")>-1 && tableX1=="task")|| (filterIdSpan.indexOf("whoid")>-1 && tableX1=="event")|| filterIdSpan.indexOf("contact__c")>-1)){
                        curV1=curV1.replace(/ .[^ ]+ /ig," * ");
                    }
                    selectedVals+=curV1+",";
                });
            }
        }
        
        if(selectedVals==""){
            var hasNoneEmpty=false;
            $("#"+filterIdSpan+" .filterObjShow1").find("select,input[type!='radio']").each(function(){
                hasNoneEmpty=hasNoneEmpty||$.trim($(this).val())!="";
                selectedVals+=","+($.trim($(this).val())==""?" ":$.trim($(this).val()));
            }); 
            var isBlanksRadioMarked=$("#"+filterIdSpan+" .filterObjShow1 .b1.rangeX1Rad input[type='radio']:checked").length>0;
            var isSearchRadioMarked=$("#"+filterIdSpan+" .filterObjShow1 .s1.rangeX1Rad input[type='radio']:checked").length>0;
            if(!isBlanksRadioMarked &&hasNoneEmpty && selectedVals!=""){
                selectedVals="R"+selectedVals.substring(1);
            }else if(isBlanksRadioMarked){
            	selectedVals="-";
            }else{
                selectedVals="";
            }
        }else{
            $("#"+filterIdSpan+" .filterObjShow1 .inptFilter").val("");//clear range
        }
        
        if(selectedVals==""){
            selectedVals=$("."+fieldCalss1).val();
            if(selectedVals.indexOf("R")==0 && $("#"+filterIdSpan+" .filterObjShow1 input").length>0){
                selectedVals="";
            }
        } 
        closeFilterx();
        //$("#"+filterIdSpan+" .availVals ").html("<div class='ld1'></div>");
        $("#"+filterIdSpan+" .searchTxt").hide();
        $("."+fieldCalss1).val(selectedVals);//filterinoIPT
        filterCol(null,13);//run filter now
   }
   
   
   var tempLayoutEditorResize=0;
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
	        if(parentLocParam1!=null && parentLocParam1!="" && parentLocParam1!="null"){
	        	var t1=parentLocParam1;
	        	if(t1.indexOf('/')>-1){
	        		t1=t1.substring(0,t1.indexOf('/',10));
	        	}
	        	postURl1=t1;
	        }
	    //$(document).height()+"";
	    var maxDialogHeight=$("body").height()+35;
		$("div.ui-dialog:visible").each(function(){
			var h1=$(this).height()+20; 
			if(h1 > maxDialogHeight){
				maxDialogHeight=h1;
			}
		});
	    var maxHeight=maxDialogHeight;//$("body").height();
	    $(".srachPan2NP,.filterino:visible,.ui-tooltip:visible,.qtip-brd-gry:visible").each(function(){
	        var pos1=$(this).position();
	        var curH=pos1.top+$(this).outerHeight()+20;
	        if(curH > maxHeight){
	            maxHeight=curH;
	        }
	    });
	    maxHeight=maxHeight+1;
	    //alert(maxHeight+" "+stopResizing);
	    //alert(postURl1);
	    if(postURl1!=null && (postURl1.indexOf('lforce.com')>-1 || postURl1.indexOf('.force.com')>-1)){
			if(turnOnscrolModeForTabsRL==0 ){
			    //parent.postMessage("postMessage('paretnAk1();','https://"+((self.location+'').split(/\/+/)[1])+");",postURl1);
	        	setTimeout("parent.postMessage('var ifrm=jQuery(\"iframe[title=\\'"+UrlEnd1+tp_conf+"\\']\");ifrm.attr(\\'height\\',\\'"+(maxHeight)+"\\').attr(\\'scrolling\\',\\'yes\\');/*zaapit_tb_zbnx1~"+maxHeight+"~*/','"+postURl1+"');",30);
	        	tempLayoutEditorResize=0;
	        }else if(turnOnscrolModeForTabsRL==1 && stopResizing==0 && zptabhsP==""){
	        	setTimeout("parent.postMessage('var ifrm=jQuery(\"iframe[title=\\'"+UrlEnd1+tp_conf+"\\']\");var h1=Math.max(550,(jQuery(self).height()-ifrm.offset().top)-20); ifrm.attr(\\'height\\',h1).height(h1).attr(\\'scrolling\\',\\'yes\\').css({\\'overflow-y\\':\\'scroll\\'});/*zaapit_tb_zbnx1~650~*/','"+postURl1+"');",30);
	        	stopResizing=1;
	        }
        }
    }
    }catch(e){}
    	$("body").trigger("OnRenderDone");
   }
   
   var FilterReplaceLabelNameArr=null;
   function subsituteValueFilters(val){
	  	 var tempRes=val;
	  	 try{
	   		if(FilterReplaceLabelNameArr==null){
	   			FilterReplaceLabelNameArr=new Array();
	   			
		   			if(FilterReplaceLabelName.indexOf("~")>-1){
		   				var tmp=FilterReplaceLabelName.split("#");
		   				//alert(tmp.length);
		   				for(var i=0;i<tmp.length;i++){
		   					var tv=tmp[i].split("~");
		   					FilterReplaceLabelNameArr[tv[0]]=tv[1];
		   				}
		   			}
	   			
	   		}
	   		if(FilterReplaceLabelNameArr!=null){
		   		tempRes=FilterReplaceLabelNameArr[val];
		   		if(tempRes==null){
		   			tempRes=val;
		   		}
	   		}
	   		
	   		if(tempRes.indexOf("&")>-1){
	   			if(tempRes.indexOf("&lt;")>-1){
	   				tempRes=tempRes.replace(/\&lt\;/ig,"<").replace(/\&gt\;/ig,">").replace(/\<[^\>]+\>/ig,"");
	   			}	
	   			tempRes=$('<div/>').html(tempRes).text();
	   		}
		}catch(e){
				
		}
		return tempRes;
   }
   
   function preValueFiltInpt(val){
   		var tempRes=val; 
		if(tempRes.indexOf("&")>-1){
	   			if(tempRes.indexOf("&lt;")>-1){
	   				tempRes=tempRes.replace(/\&lt\;/ig,"<").replace(/\&gt\;/ig,">").replace(/\<[^\>]+\>/ig,"*");
	   			}	
	   			tempRes=$('<div/>').html(tempRes).text();
	   		}
	   	if(tempRes.indexOf("'")>-1 ||tempRes.indexOf("\"")>-1 ||tempRes.indexOf("\\")>-1||tempRes.indexOf(",")>-1){
	   		tempRes=tempRes.replace(/\,|'|"|\\/ig,"_");
	   	}
		return tempRes;
   }
   
   var stopResizing=0;
 function loadDataFilter(field1,filterIdSpan,fieldCalss1,filterObjShowType,colName,resultData,fetchCount1,objRefName,sortDir){
 	var isExternalObj=tableX1Z.indexOf('__x')>-1;
 	if(isExternalObj && filterObjShowType.indexOf('f')==-1){
 		filterObjShowType+='f';	
 		//alert(filterObjShowType);
 	}
 	var fieldOrig1=field1;
 	stopResizing=0;
 	var notTextArea=filterObjShowType!='9' && filterObjShowType!='9f';
   var fieldMap1=new Array();
   var maxResRows=(loadfilter_maxResRows=="" || isNaN(loadfilter_maxResRows)?250:Number(loadfilter_maxResRows));
   try{
   if(hide_multi_value_filters__c || $("#"+filterIdSpan+" .availVals .btnD").length>0 ){
        return false;
   }
   var resultsHTML="";
   var useFormulaField=false;
   var showButtons=false;
   var showGraph=false;
   //alert(fetchCount1+' '+filterObjShowType + ' '+resultData);
   if((filterObjShowType=='1' || filterObjShowType=='12' || filterObjShowType=='9' || filterObjShowType=='9f' ||  (filterObjShowType=='1f' && NOT_Disable_formula_fields_groupings__c )||   (!isExternalObj && filterObjShowType=='2f' && NOT_Disable_formula_fields_groupings__c )||(filterObjShowType=='10f' && NOT_Disable_formula_fields_groupings__c )||  filterObjShowType=='4' || (!isExternalObj && filterObjShowType=='4f') ||filterObjShowType=='2'|| filterObjShowType=='6'|| filterObjShowType=='5'|| filterObjShowType=='7' || (filterObjShowType=='7f' && NOT_Disable_formula_fields_groupings__c ) || filterObjShowType=='11' || (filterObjShowType=='x' && field1.indexOf("date")==-1 ))){//text,bool,date,int,reference
        showGraph=((filterObjShowType=='4f' || filterObjShowType.indexOf('f')==-1) && filterObjShowType!='11'&& filterObjShowType!='x');//not formula or X;
       
        //loadingSH();
        var fieldSoql=field1;
        var fieldSoqlSort=field1;
        if((filterObjShowType=='7' || filterObjShowType=='7f') && field1!='id' ){
            //field1=field1.substring(0,field1.length-2)+"."+objRefName;
            if(field1.indexOf("id")==field1.length-2){
                field1=field1.substring(0,field1.length-2)+"."+objRefName;
            }
            if(field1.indexOf("__c",Math.max(0,field1.length-4))==field1.length-3){
                field1=field1.substring(0,field1.length-1)+"r."+objRefName;//'zaapit__'+
            }

            fieldSoql=field1;
            if(!isExternalObj){
            	fieldSoqlSort=field1;
            }
        }else if(filterObjShowType=='6'){
            fieldSoql="DAY_ONLY("+field1+")";

        }
        var query1="";
        if(filterObjShowType=='1f' || filterObjShowType=='7f'){
            maxResRows=50;//50 Groups
            field1=""+field1;//zaapit__
            fieldSoql=""+fieldSoql;//zaapit__
            var limitF=limitFORIG;
            if(limitF=="" || isNaN(limitF) || Number(limitF)<=0){
                limitF="3000";
            }else{
                limitF=Math.round(Number(limitF));
            }
            useFormulaField=true;
            if(isExternalObj && fieldSoqlSort.indexOf("__r")>-1){
            	fieldSoqlSort=fieldSoqlSort.split("__r")[0]+"__c";	
            }
            query1="SELECT "+fieldSoql+" "+DBsubQery+" order by "+fieldSoqlSort+" limit "+limitF+DB_END_ALLROWS_Qery;
            //alert(limitF+ " " +isNaN(limitF) + " "+Number(limitF) );
            
            if(resultData==null && fetchCount1==null){
            
                Visualforce.remoting.Manager.invokeAction(
                remotequeryAjax2CountFL,
                query1, 
                function(result, event){
                    if (event.status && result!=null) {
    
                        loadDataFilter(fieldOrig1,filterIdSpan,fieldCalss1,filterObjShowType,colName,result,"1",objRefName,sortDir);
                    
                     } else if (event.type === 'exception') {
                        //self.location=self.location;
                         if(event.message!=null && ((event.message+"").indexOf("Logged in")>-1 || (event.message+"").indexOf("Refresh page")>-1)){
                            self.location=self.location;
                        }else if(event.message!=null && (event.message+"").indexOf("Unable to conn")==-1){
                			if($("body:visible").length>0)alert("An error has occurred: "+event.message);
                		}
                         $("#"+filterIdSpan+" .availVals").html("");
                    } else {
                        //self.location=self.location;
                       // alert(event.type+"");
                         $("#"+filterIdSpan+" .availVals").html("");
                    }
                }, 
                {escape: true,buffer:true,timeout: 90000}
            );
                return;
            }
        }else if( filterObjShowType=='11' || filterObjShowType=='10f' ){
            maxResRows=50;//50 Groups
            field1=""+field1;//zaapit__
            fieldSoql=""+fieldSoql;//zaapit__
            var limitF=limitFORIG;
            if(limitF=="" || isNaN(limitF) || Number(limitF)<=0){
                limitF="3000";
            }else{
                limitF=Math.round(Number(limitF));
            }
            useFormulaField=true;
            query1="SELECT "+fieldSoql+" "+DBsubQery+" limit "+limitF+DB_END_ALLROWS_Qery;
            //alert(limitF+ " " +isNaN(limitF) + " "+Number(limitF) );
            //alert(query1);
            if(resultData==null && fetchCount1==null){
            
                Visualforce.remoting.Manager.invokeAction(
                remotequeryAjax2CountMPLX,
                query1, 
                function(result, event){
                    if (event.status && result!=null) {
    
                        loadDataFilter(fieldOrig1,filterIdSpan,fieldCalss1,filterObjShowType,colName,result,"1",objRefName,sortDir);
                    
                     } else if (event.type === 'exception') {
                        //self.location=self.location;
                         if(event.message!=null && ((event.message+"").indexOf("Logged in")>-1 || (event.message+"").indexOf("Refresh page")>-1)){
                            self.location=self.location;
                        }else if(event.message!=null && (event.message+"").indexOf("Unable to conn")==-1){
                			if($("body:visible").length>0)alert("An error has occurred: "+event.message);
                		}
                         $("#"+filterIdSpan+" .availVals").html("");
                    } else {
                        //self.location=self.location;
                       // alert(event.type+"");
                         $("#"+filterIdSpan+" .availVals").html("");
                    }
                }, 
                {escape: true,buffer:true,timeout: 90000}
            );
                return;
            }

        }else if(notTextArea ){
        	//,max(id)
        	
        	
            query1="SELECT "+(filterObjShowType=='12'  && field1.indexOf('.')==-1?"toLabel("+field1+") l1,":"")+fieldSoql+" f1,count(id) c1 "+DBsubQery+" group by "+fieldSoql+" order by "+fieldSoql+" "+(filterObjShowType=='6' || filterObjShowType=='2'?sortDir:"asc")+" limit "+maxResRows+DB_END_ALLROWS_Qery;
            
            if(fieldSoql.indexOf('__xx.')>-1){
		  		var f1=fieldSoql.split("__xx.");
	            if(f1.length>=3){
	            	var fieldSoqlF=fieldsetFilerXXMap[fieldSoql];
	            	//alert(fieldSoqlF);
	            	if(fieldSoqlF!=null && $.trim(fieldSoqlF)!=""){
	            		fieldSoqlF=" and ( "+$.trim(fieldSoqlF)+" )";
	            	}else{
	            		fieldSoqlF="";
	            	}
	            	//alert(".fltIC"+(field1.replace(/\./,"-"))+".fltIC");
	            	var ajxg = $(".fltIC"+(field1.replace(/\./ig,"-"))+".fltIC").attr("ajxg");
		  			query1="SELECT "+f1[2]+" f1,count(id) c1 FROM "+f1[0]+" WHERE "+f1[1]+" in (SELECT id "+DBsubQery+" ) "+(fieldSoqlF)+ (ajxg!=null && $.trim(ajxg)!=""?" and "+ajxg:"")+" group by "+f1[2]+" order by "+f1[2]+" limit "+maxResRows+DB_END_ALLROWS_Qery;
		  			//alert(query1);
	         	}
	  		}
            if(resultData==null && fetchCount1==null){
        
                Visualforce.remoting.Manager.invokeAction(
                remoteQueryAjax2,
                query1, 
                function(result, event){
                    if (event.status && result!=null) {
                        if(fieldSoql.indexOf('__xx.')>-1){
                           result.splice(0, 0, {"c1":"N/A","f1":""}).join();
                           //alert(result[1]);
                        }
                        loadDataFilter(fieldOrig1,filterIdSpan,fieldCalss1,filterObjShowType,colName,result,"1",objRefName,sortDir);
                    
                     } else if (event.type === 'exception') {
                        //self.location=self.location;
                         if(event.message!=null && ((event.message+"").indexOf("Logged in")>-1 || (event.message+"").indexOf("Refresh page")>-1)){
                            self.location=self.location;
                        }else if(event.message!=null && (event.message+"").indexOf("Unable to conn")==-1){
                			if($("body:visible").length>0)alert("An error has occurred: "+event.message);
                		}
                         $("#"+filterIdSpan+" .availVals").html("");
                    } else {
                        //self.location=self.location;
                        //alert(event.type+"");
                         $("#"+filterIdSpan+" .availVals").html("");
                    }
                }, 
                {escape: true,buffer:true,timeout: 90000}
            );
                return;
            }
        }
         //alert(query1);
        


        var lastVal=null;
        var lastCountf=0;
        var queryMore = notTextArea;
        var hasRows = true;
        var count1=0;
        if(notTextArea) resultsHTML+="<thead><tr><td><input type='checkbox' class='xfilt1All' name='selectAll' id='"+filterIdSpan+"-A' onclick='selAllFlt(this);'></td><td><label for='"+filterIdSpan+"-A'>"+Select_All+"</label></td><td >#</td></tr></thead><tbody>";
        
        while (queryMore && count1<maxResRows) {
            var records = resultData;//result.getArray("records");
            if(records!=null && records.length>0){
                
                for (var key in records[0]) {
                    //alert(key+" "+records[0][key]+" "+(typeof  records[0][key]));
                    fieldMap1[key.toLowerCase()]=key;
                    if(records[0][key]!=null && (typeof records[0][key]) == "object"){
                    
                        for (var key1 in records[0][key]) {
                            fieldMap1[key1.toLowerCase()]=key1;
                        }
                    }  
                }
                
            }else{
                queryMore=false;
                continue;
            }
            
            var fieldDotIdx=field1.indexOf(".");
            var field1Xnd=(fieldDotIdx>-1?field1.substring(fieldDotIdx+1):field1);
            //var expfieldsStart=(!useExpField?0:1);
            var countFname="c1";//'expr'+expfieldsStart;
            var labelFname="l1";
            var mainFieldName="f1";//(!useFormulaField?"f1":fieldMap1[field1Xnd]);
            //alert(records[0]);
            var dateFormatPatren=dateFormatPatrenORIG;
            var defaultDateFormat=(dateFormatPatren=="-"?true:false);
            var formatter_gva = (defaultDateFormat?null:new google.visualization.DateFormat({pattern: dateFormatPatren}));
            //alert(records[0]);
                for (var i = 0; i < records.length; i++) {
                    hasRows=true;
                    var val1=records[i][mainFieldName];
                    var val1Count=records[i][countFname];
                    var objN="";
                    //alert(val1+ " "+mainFieldName);
                 	var val1Label=val1;
                    if(val1!=null && val1.indexOf("T")>-1 && val1.match(/[0-9]{4}\-[0-9]{2}\-[0-9]{2}T.*/ig) ){
                        val1=val1.replace("T"," ");
                        val1=val1.replace("Z","");
                        val1=val1.replace(".000","");
                    }
                    
                    if(filterObjShowType=='12' && records[i][labelFname]!=null){
                    	val1Label=records[i][labelFname];
                    }
                    //alert(val1Label)
                        try{
                        	if(!defaultDateFormat &&(filterObjShowType=='2'|| filterObjShowType=='2f'|| filterObjShowType=='6')){//date
	                        	var td1=val1Label.split("-");
	                        	var dto= new Date(Number(td1[0]),(Number(td1[1])-1),Number(td1[2]));
	                        	val1Label=formatter_gva.formatValue(dto);
	                        	//alert(dto+ " "+val1Label);
                        	}
                        }catch(e){}
                    
                    resultsHTML+="<tr>";
                 resultsHTML+="<td><input type='checkbox' class='xfilt1' name='xfilt1' value='"+preValueFiltInpt(val1==null || val1==""?" ":val1)+"' onclick='selOneFlt(this);' id='"+filterIdSpan+"-"+count1+"'></td><td class='v1'><div class='vl1'><label for='"+filterIdSpan+"-"+count1+"' onmouseover='fixTitlex1(this);'>"+(val1==null || val1==""?Blanks_txt:subsituteValueFilters(val1Label))+"</label></div></td><td class='gray'>"+(val1Count==null?"":val1Count)+"</td>";
                 
                resultsHTML+="</tr>";
                count1++;
                }
            
            
            queryMore = false;

        }

                    
         if(count1==maxResRows){
               resultsHTML+="<tr>";
               var bottomMSg=(Showing_first_X_rows).replace("{0}",maxResRows+"");
               resultsHTML+="<td colspan='3' align='center' style='color:#a1a1a1;font-size:8pt;'>"+bottomMSg+"</td>";
               resultsHTML+="</tr>";
         }
        //alert(resultsHTML);
        if(hasRows){
            resultsHTML=("<div class='fltTblOfw'><table class='fltTblOf'>"+resultsHTML+"</table></div>");
            showButtons=true; 
        }else{
            $("#"+filterIdSpan+" .availVals").html("");
        }
        
        }else if(filterObjShowType=='1f' && !(NOT_Disable_formula_fields_groupings__c )){
            showButtons=true;
            if(lastCountf>0){
                 resultsHTML+="<tr>";
                 resultsHTML+="<td><input type='checkbox' class='xfilt1' name='xfilt1' value='"+preValueFiltInpt(lastVal==null || lastVal==""?" ":lastVal)+"' onclick='selOneFlt(this);' id='"+filterIdSpan+"-"+count1+"'></td><td class='v1'><div class='vl1'><label for='"+filterIdSpan+"-"+count1+"' onmouseover='fixTitlex1(this);'>"+(lastVal==null || lastVal==""?Blanks_txt:subsituteValueFilters(lastVal))+"</label></div></td><td class='gray'>"+(lastCountf==null?"":lastCountf)+"+</td>";
                 
                resultsHTML+="</tr>";
                count1++;
            }
        }else if(filterObjShowType=='6'){//datetime
            //$("#"+filterIdSpan+" .availVals").html("");
            //showButtons=true;
        }else if(filterObjShowType=='8f' || filterObjShowType=='8' || filterObjShowType=='3' || filterObjShowType=='35' || filterObjShowType=='3f' || filterObjShowType=='35f'){//numbers
         

                //var formatterCurr = new Intl.NumberFormat(navigator.language, { style: 'currency', currency: currencyDefISO, "currencyDisplay":"symbol" });//new google.visualization.NumberFormat({prefix: symbol	});
		        var formatterInt = new Intl.NumberFormat(navigator.language);//new google.visualization.NumberFormat({	pattern: '#,###,###.##'});
		        
            var inpFieldsO=$("#"+filterIdSpan+" .filterObjShow1 .inptFilter");
            if(inpFieldsO[0]!=null && $("#"+filterIdSpan+" .availVals .btnD").length==0){
                var query1="SELECT min("+field1+") s1,max("+field1+") s2 "+DBsubQery+" "+DB_END_ALLROWS_Qery;

                 showButtons=true;
                 showGraph=false;         
                       
                Visualforce.remoting.Manager.invokeAction(
                remoteQueryAjax2,
                query1, 
                function(result, event){
                    if (event.status && result!=null) {
    
                           var records = result;

                             if(records.length>0){
                                var min1=Math.floor(Number(records[0]["s1"])).toFixed(0);
                                var max1=Math.ceil(Number(records[0]["s2"])).toFixed(0);
                                  $(inpFieldsO[0]).attr("title",Min_title+" "+formatterInt.format(min1));
                                  $(inpFieldsO[1]).attr("title",Max_Title+" "+formatterInt.format(max1));
                                  //alert(records[0].s2);
                                  //inpFieldsO.tooltip();
                            }
                    
                     } else if (event.type === 'exception') {
                        if(event.message!=null && ((event.message+"").indexOf("Logged in")>-1 || (event.message+"").indexOf("Refresh page")>-1)){
                        	self.location=self.location;
                        }else if(event.message!=null && (event.message+"").indexOf("Unable to conn")==-1){
                        	if($("body:visible").length>0)alert("An error has occurred: "+event.message);
                       	}
                         $("#"+filterIdSpan+" .availVals").html("");
                    } else {
                        //self.location=self.location;
                         $("#"+filterIdSpan+" .availVals").html("");
                    }
                }, 
                {escape: true,buffer:true,timeout: 90000}
            );
               
            }
            
        }

        if(filterObjShowType=='4' ||filterObjShowType=='4f'){//booleans
            resultsHTML=resultsHTML.replace('>true<','><img class="checkImg" width="21" height="16" title="Checked" alt="Checked" src="/img/checkbox_checked.gif"><');
            resultsHTML=resultsHTML.replace('>false<','><img class="checkImg" width="21" height="16" title="Not Checked" alt="Not Checked" src="/img/checkbox_unchecked.gif"><');
        }
       
       
	 if(showButtons){
	   $("#"+filterIdSpan+" .extBtns").html("");
	  }
        
        var copyToTA="";
        if("true" ==hasMassMerge && hasMassMerge && $("#massUpdatein .muf1[fld='"+field1+"']").length>0 && (filterObjShowType=='1' || filterObjShowType=='12' || filterObjShowType=='9' || filterObjShowType=='9f') ){//editable text field
        	 $("#massUpdatein .muf1[fld!='"+field1+"']").each(function(){
        	 	var fld=$(this).attr("fld");
        	 	var tpx=$("th.thw."+fld).attr("tpx")
        	 	if(tpx=="1" || tpx=="9f" || tpx=="9"){
        	 		copyToTA+="<option value='combineTA~"+fld+"' "+(("combineTA~"+fld)==(""+MassMergefieldsToAvilOvAct[field1])?"selected":"")+">Combine non-master with "+fld+"</option>";
        	 	}
        	 });
        	 if(copyToTA!=""){
        	 	copyToTA+="<option value='dest' "+(("dest")==(""+MassMergefieldsToAvilOvAct[field1])?"selected":"")+">Combine Destination (auto)</option>";
        	 }
        }
        $("#"+filterIdSpan+" .extBtns").append(
                
                ( "true" ==hasMassMerge &&  $("#"+filterIdSpan+" .combineVals").length==0 && $("#massUpdatein .muf1[fld='"+field1+"']").length>0 &&(filterObjShowType=='1'
                || filterObjShowType=='12'//picklist
                || filterObjShowType=='2'//date
                || filterObjShowType=='3'//curr
                || filterObjShowType=='3f'//curr
                || filterObjShowType=='6'//datetime
                || filterObjShowType=='4' //boolean
                || filterObjShowType=='35'//curr
                || filterObjShowType=='5'//number
                || filterObjShowType=='8'//percent
                || filterObjShowType=='9'//percent
                || filterObjShowType=='9f'//percent
                || filterObjShowType=='11'//multipicklist
                )?"<span style='line-height:20px;padding: 4px;width: 99%;display:block;' title='Select the mass merge strategy that you want to apply: <br/>1) No strategy <br/>2) Copy If empty: Copy the field value from non-master rows to the master row if the master-field is empty during Mass Merge <br/>3) Combine: combine field values during Mass Merge from all the rows into 1 field on the master/surviving row. <br/>4) Combine the non-master field value: copy+combine non-master rows field-values into a different text/textarea field  + copy the non-master value to the master field if the master-field is empty e.g. copy phone numbers from all the rows to a new text field and copy the phone to the master&#39;s phone field if empty. This option ignores repeating values, emails & multi-picklist are combined by semi-colonm other fields are combined by a comma. ' onmouseover='fixTitlex2(this,false,\"R\");' ><select name='combineVals' class='combineVals' style='width: 99%;' onchange='combineColValues(\""+field1+"\",this);'><option value=''>Select Merge Strategy</option><option value='copyIFEmpty' "+("copyIFEmpty"==(""+MassMergefieldsToAvilOvAct[field1])?"selected":"")+">Copy if Empty</option>"+
                (!(filterObjShowType=='2'//date
                || filterObjShowType=='6'//datetime
                || filterObjShowType=='4' //boolean
                || filterObjShowType=='3'//curr
                || filterObjShowType=='3f'//curr
                || filterObjShowType=='35'//curr
                || filterObjShowType=='5'//number
                || filterObjShowType=='8'//percent
                )
                &&$("#massUpdatein .muf1[fld='"+field1+"'] select").length!=1//0 or 2 is ok
                ?"<option value='combine' "+("combine"==(""+MassMergefieldsToAvilOvAct[field1])?"selected":"")+">Combine Values</option>"+copyToTA
                :"")+
                
                "</select> </span>":""));
            //alert("showButtons "+showButtons);    
        if(showButtons ){
        	//filterObjShowType=='2'||filterObjShowType=='6'
			
            
            	var showGeo1=NOT_DisableGeoMaps__c && (filterObjShowType=='1' ||filterObjShowType=='1f'  )&& (field1.indexOf("country")>-1);
                $("#"+filterIdSpan+" .extBtns").append(
                               
                (NOT_Hide_graph_link_on_filter__c && showGraph && count1>0?
                (filterObjShowType=="1" || filterObjShowType=="12" || filterObjShowType=="1f" ||filterObjShowType=='7'?""+
                 "<ul class='chartsFilterMenu' style='border: 0px;'><li><div class='menuItemFlt GraphLnk'>"+Instant_Graph+"</div>"+
                "<ul class='hd1'>"+
                "<li ><div g='P'>Pie Chart</div></li><li ><div g='B'>Bar Chart</div></li>"+(showGeo1?"<li ><div g='GEO'>GEO Chart</div></li>":"")+"</ul>"+
                "</ul>"
                :
				(filterObjShowType=='2'||filterObjShowType=='6'?
				//dates:
			
				 "<ul class='chartsFilterMenu' style='border: 0px;'><li><div class='menuItemFlt GraphLnk'>"+Instant_Graph+"</div>"+
                "<ul class='hd1'>"+
                "<li ><div g='false'>Trend Line Chart</div></li><li ><div g='D'>Group by Day</div></li> "+
                (field1!="activitydate"?
                "<li ><div  g='W'>Group by Week</div></li> <li ><div  g='M'> Group by Month</div></li> <li ><div  g='Q'>Group by Quarter</div></li><li><div  g='Y'>Group by Year</div></li> "
                :"")+
                "</ul>"+
                
                "</li><li><div>Date Filters</div>"+
                "<ul class='hd1'>"+
                "<li ><div>Days</div><ul>"+
                "<li><div m='D' f='1' t='1'>Tomorrow</div></li>"+
                "<li><div m='D' f='0' t='0'>Today</div></li>"+
                "<li><div m='D' f='-1' t='-1'>Yesterday</div></li>"+
                "</ul></li>  <li ><div>Weeks</div><ul>"+
                "<li><div m='W' f='1' t='1'>Next Week</div></li>"+
                "<li><div m='W' f='0' t='0'>This Week</div></li>"+
                "<li><div m='W' f='0' t='D'>This Week to Date</div></li>"+
                "<li><div m='W' f='-1' t='-1'>Last Week</div></li>"+
                "</ul></li> <li ><div>Months</div><ul>"+
                "<li><div m='M' f='1' t='1'>Next Month</div></li>"+
                "<li><div m='M' f='0' t='0'>This Month</div></li>"+
                 "<li><div m='M' f='0' t='D'>This Month to Date</div></li>"+
                "<li><div m='M' f='-1' t='-1'>Last Month</div></li>"+
                "</ul></li> <li ><div>Quarters</div><ul>"+
                "<li><div m='Q' f='1' t='1'>Next Quarter</div></li>"+
                "<li><div m='Q' f='0' t='0'>This Quarter</div></li>"+
                "<li><div m='Q' f='0' t='D'>This Quarter to Date</div></li>"+
                "<li><div m='Q' f='-1' t='-1'>Last Quarter</div></li>"+
                
                "</ul></li> <li ><div>Years</div><ul>"+
                "<li><div m='Y' f='1' t='1'>Next Year</div></li>"+
                "<li><div m='Y' f='0' t='0'>This Year</div></li>"+
                "<li><div m='Y' f='0' t='D'>This Year to Date</div></li>"+
                "<li><div m='Y' f='-1' t='-1'>Last Year</div></li>"+
                
                /*"</ul></li> <li><div>Fiscal Year</div><ul>"+
                "<li><div m='FY' f='1' t='1'>Next Year</div></li>"+
                "<li><div m='FY 'f='0' t='0'>This Year</div></li>"+
                "<li><div m='FY' f='0' t='D'>This Year to Date</div></li>"+
                "<li><div m='FY 'f='-1' t='-1'>Last Year</div></li>"+
                
               */
                "</ul></li> </ul>"+
                "</li></ul>"
				:
				//none-date
                "<a href='javascript:void(0);' class='menuItemFlt GraphLnk' onclick='createGarphsDataFilter(\""+field1+"\",\""+filterIdSpan+"\",\""+fieldCalss1+"\",\""+filterObjShowType+"\",\""+Amount_field_For_Graphs__c+"\",\""+amountFieldName+"\",\""+colName+"\",\""+count1+"\",\""+NOT_DisableGeoMaps__c+"\",null,null,null,null,\""+objRefName+"\");return false;'>"+Instant_Graph+"</a>"))
                :"")
                
              
                );
                
            if(filterObjShowType=='2'||filterObjShowType=='6' ||filterObjShowType=='1' ||filterObjShowType=='12' ||filterObjShowType=='1f' ||filterObjShowType=='7'){
            $(".chartsFilterMenu:visible").menu({
			      select: function( event, ui ) {
			      	var selDiv=ui.item.find(">div[m]:first,>div[g]:first");
			      	if(selDiv.length>0){
			      		var formatterX = new google.visualization.DateFormat({pattern: 'yyyy-MM-dd'});	
			      		var today=new Date();
			      		var cYear=today.getFullYear();
			      		var cMonth=today.getMonth();
			      		var cDay=today.getDate();
			      		var cWeekDay=today.getDay();
				      	var m=selDiv.attr("m");
				      	var g=selDiv.attr("g");
				      	var f=selDiv.attr("f");
				      	var t=selDiv.attr("t");
				      	//alert(g +" "+ m);
				      	if(m!=null && m!=""){//filter by
					      	switch(m){
					      		case 'D':
						      			var val1=formatterX.formatValue(addXtoDate(today,0,0,Number(f)));
						                $('#'+filterIdSpan+' .'+fieldCalss1+"1").val(val1).focusin().keyup().focusout().change();
						                
						                var val2=formatterX.formatValue(addXtoDate(today,0,0,Number(t)));
						                $('#'+filterIdSpan+' .'+fieldCalss1+"2").val(val2).focusin().keyup().focusout().change();
				      			break;
					      		case 'W':
					      				var val1=formatterX.formatValue(addXtoDate(today,0,0,Number(f)*7+-1*cWeekDay));
						                $('#'+filterIdSpan+' .'+fieldCalss1+"1").val(val1).focusin().keyup().focusout().change();
						                
						                var val2=formatterX.formatValue((t=="D"?today:addXtoDate(today,0,0,((Number(t)+1)*7 -1 -1*cWeekDay))));
						                $('#'+filterIdSpan+' .'+fieldCalss1+"2").val(val2).focusin().keyup().focusout().change();
					      		break;
					      		case 'M':
					      				var val1=formatterX.formatValue(addXtoDate(today,0,Number(f),-1*cDay+1));
						                $('#'+filterIdSpan+' .'+fieldCalss1+"1").val(val1).focusin().keyup().focusout().change();
						                
						                var val2=formatterX.formatValue((t=="D"?today:addXtoDate(today,0,Number(t)+1,-1*cDay)));
						                $('#'+filterIdSpan+' .'+fieldCalss1+"2").val(val2).focusin().keyup().focusout().change();
					      		break;
					      		case 'Q':
					      				var startOFQDiff=cMonth-Math.floor((cMonth)/4)*3;
					      				var val1=formatterX.formatValue(addXtoDate(today,0,-1*startOFQDiff + Number(f)*3,-1*cDay+1));
						                $('#'+filterIdSpan+' .'+fieldCalss1+"1").val(val1).focusin().keyup().focusout().change();
						                
						                var val2=formatterX.formatValue((t=="D"?today:addXtoDate(today,0,-1*startOFQDiff +(Number(t)+1)*3,-1*cDay)));
						                $('#'+filterIdSpan+' .'+fieldCalss1+"2").val(val2).focusin().keyup().focusout().change();
					      		break;
					      		case 'Y':
					      				var val1=formatterX.formatValue(addXtoDate(today,Number(f),-1*cMonth,-1*cDay+1));
						                $('#'+filterIdSpan+' .'+fieldCalss1+"1").val(val1).focusin().keyup().focusout().change();
						                
						                var val2=formatterX.formatValue((t=="D"?today:addXtoDate(today,Number(t)+1,-1*cMonth,-1*cDay)));
						                $('#'+filterIdSpan+' .'+fieldCalss1+"2").val(val2).focusin().keyup().focusout().change();
					      		break;
					      	/*	case 'FY':
					      			var val1=formatterX.formatValue(addXtoDate(today,Number(f),-1*cMonth,-1*cDay+1));
					                $('#'+filterIdSpan+' .'+fieldCalss1+"1").val(val1).focusin().keyup().focusout().change();
					                
					                var val2=formatterX.formatValue((t=="D"?today:addXtoDate(today,Number(t)+1,-1*cMonth,-1*cDay)));
					                $('#'+filterIdSpan+' .'+fieldCalss1+"2").val(val2).focusin().keyup().focusout().change();
					      		break;
					      		*/
					      	}
				      	}else if(g!=null && g!=""){//create chart grouped by
				      	
				      	//alert(filterIdSpan + " " +$("."+filterIdSpan+"[grus]").length);
			        	var grus=$(".fltIC"+(fieldOrig1.replace(/\./ig,"-"))+"[grus]:visible").attr("grus");
							//alert(fieldOrig1+" "+grus);
							if(grus!=null && grus!=""){
								if(g!="GEO"){
									grus=grus.replace("'1','chartType","'0','"+g).replace("NOT_DisableGeoMaps__c","false");//set chart type & disable geo
								}else{
									grus=grus.replace("'1','chartType","'0','"+g);//set isBar & not autopin
								}
								//alert(grus);
								$.globalEval("try{"+grus+"}catch(e1){alert(e1);}");
							}
				      	}
				      	//alert(m+ " "+f + " "+t+" "+g);
			      	}
			      }
			    });
			    }
			    
            if(isEditMode1 && $("input.iTb.inpSt_"+fieldOrig1+"[type='text']:first,textarea.iTb.inpSt_"+fieldOrig1+":first").length>0){
                $("#"+filterIdSpan+" .extBtns").append("<a href='javascript:void(0);' class='menuItemFlt findRepLnk' onclick='searchAndReplacePopUpF(\""+fieldOrig1+"\");return false;'>"+find_Replace+"</a>");
            }
            //alert(resultsHTML);
            if(notTextArea){ $("#"+filterIdSpan+" .availVals").html(resultsHTML+"<div class='btnD'><button class='btn filterBtnExcelStl' onclick='selectFilterExCBOX(\""+filterIdSpan+"\",\""+fieldCalss1+"\");' type='button' >"+filter_ex_Btn+"</button><button class='btn' onclick='closeFilterx();' type='button' style='margin-left:5px;' >"+Cancel_filter_button+"</button></div>");
            }else{
            	$("#"+filterIdSpan+" .availVals").html("");
            }
             var curObj=$("#"+filterIdSpan);
             var availVals=curObj.find(".availVals");
             if(isSF1()){
             	availVals.width("99%"); 
             }else{
             	availVals.width(availVals.width());
             }
             /*calc new left!*/
             var scrollMode=isScrollMode();
              var sl1= getCUrrScollLeft();
            var fltTblOfw=curObj.find(".fltTblOfw");
            if(!isSF1()) {
            	fltTblOfw.width(availVals.width()-20);//fltTblOfw.width());
            }else{
            	fltTblOfw.width("95%");
            }      
            var exptWidth=(fltTblOfw.length>0 && fltTblOfw[0].scrollWidth >fltTblOfw.width()?fltTblOfw[0].scrollWidth:availVals.width());
            var bodyW=$("body").width()+(scrollMode?0:sl1);
            var curLeft=curObj.css("left");
            if(curLeft!=null && curLeft.indexOf("px")>-1){
                curLeft=Number(curLeft.substring(0,curLeft.length-2));
            }
            //alert(curLeft+ " "+exptWidth+" "+ bodyW+ " "+( curLeft+exptWidth>bodyW));
            if(curLeft!=null && curLeft+exptWidth>bodyW){
                curLeft=Math.round(bodyW-exptWidth-20);
                if(!isSF1()){
		        	curObj.css({"left":curLeft});
		        }
                //curObj.css({"left":curLeft});
                //alert("curLeft: "+curLeft);
            }
            if(!isSF1()) curObj.find("input:first").width(exptWidth); 
        }else{
            $("#"+filterIdSpan+" .availVals").html("");
        }
        fixIfmHegt();
        

        //fixOnload();
        }catch(e1){
		//alert(e1);
            if(e1!=null && (e1+"").indexOf("INVALID_FIELD")>-1){
                alert("One of the below marked fields have access right issues: \n\n"+e1);
            }else if(e1!=null && (e1+"").indexOf("INVALID_SESSION_ID")>-1){
                self.location=self.location;
            }else{

            }
            $("#"+filterIdSpan+" .availVals").html("");
        }
    
   }
   
   var isjumpToClk=false;
    function jumpToClk(p,m){
    if(p>m){
        alert(unavailable_page);
        return;
    }
    if(!noticeUnsave()){
    	return false;
    }else{
    	savedGroups1();
    	isjumpToClk=true;
    	loadingSH();
    	scrollTop1();
    	jumpTo(p);
    };
        
   }
   
   function nextPrev(p){
   	
  	 p=Number(p);
    if(p>maxPageOfsetGlb){
        setTimeout(function(){alert(unavailable_page);},50);
        return false;
    }else{
        if(!noticeUnsave()){
        return false;
        }else{
        loadingSH();
        return true;
        };
    }
   }
   
   function openExportWindow(){
   trackEventX('openExportWindow');
    if(totalCountAjx>maxRowToExport){
    	if($("#showLimitExport").html().indexOf("{0}")>-1){
    		$("#showLimitExport").html($("#showLimitExport").html().replace("{0}",maxRowToExport));
    	}
        $("#showLimitExport").show();
    }else{
        $("#showLimitExport").hide();
    }
    var width1=380;
    var isSF1x1=isSF1();
    var maxWidth=$(self).width()+(isSF1x1?-10:-100);
	if(width1==null){
		width1=maxWidth;
	}else if(width1>maxWidth){
		width1=maxWidth;
	}
    $("#exportDialog1").dialog({
    resizable: true,
    //height:140,
    width:380,
    modal: true,
    buttons: [{
    text:Save_File_button,
   click: function() {
   		var or1='';
   		or1=$($("#fileTypePD")[0][$("#fileTypePD")[0].selectedIndex]).attr("or1");
   		if(or1==null || or1==""){
   			or1="0";
   		}
   		//alert(or1);
        createFile($("#fileTypePD").val(),or1);
        $( this ).dialog( "close" );
    }},
	{text:Cancel_button,
    click: function() {
        $( this ).dialog( "close" );
    }
    }]
    });
   }

   function createFile(type,or1){
   if(type=="csvUNLMT"){
   		runUnlimitedExport(type,or1);
   }else{
	    var loc1=(self.location+"");
	    $("#fileType").val(type);
	    $("#fileq").val(fileq);
	    $("#or1").val(or1);
	    //alert(or1);
	    $("#export_to_form #vid").val(mainViewID);
	    //loadingSH();
	
	    if(loc1.indexOf("zaapit.")==-1 || loc1.indexOf(".com/apex/")==-1 || loc1.indexOf("/servlet/")>-1 || parentLocParam1.indexOf("/servlet/")>-1){
	        $("#export_to_form").attr("method","get");
	    }
	
	    var prefix="/apex/";
	    if(loc1.indexOf("/servlet/")>-1){
	        //prefix="/apex/"
	    }else if(loc1.indexOf("/apex/")>-1){
	        prefix="../apex/";
	    }else{
	        prefix="apex/";
	    }
	    if(export_to_url!="-" && export_to_url!=""){
	   	 	$("#export_to_form").attr("method","post");
	    	prefix=export_to_url+"/apex/";
	    }
	    $("#export_to_form").attr("action",prefix+"zaapit__export_to_file");
	    
	    $("#export_to_form")[0].submit();
	    //setTimeout("fixOnload();",5000);
    }
    //win1.focus();
}

var unlimitedExportresultContent="";
var unlimitedExportFieldArr=null;
function runUnlimitedExport(type,or1){

	unlimitedExportresultContent="";
	 var fileqX1=fileq.substring(0,fileq.indexOf('ORDER BY'));
	 var fields0=$.trim(fileq.substring(fileq.indexOf("SELECT")+7,fileq.indexOf("FROM")));
	 var fields1=fields0.split(/[ ]*\,[ ]*/ig);
	unlimitedExportFieldArr=fields1;
	
		for(var i2=0;i2<fields1.length;i2++){
			var head1=fields1[i2];
			if(head1==null)head1="";
			var thEl=$("#mainTBX1 thead th."+(head1.replace(/\./ig,"-"))+" a span:first");
			//alert(head1+ " "+thEl.size() );
			if(thEl.size()==0 && head1.indexOf(".name")>-1){
				thEl=$("#mainTBX1 thead th."+(head1.replace(".name","id"))+" a span:first");
			}
			head1=head1.replace("__c","").replace("__r","").replace(/\_/ig," ");
			//alert(head1);
			var head1X=(thEl.size()>0?$.trim(thEl.text())+(head1.indexOf("id")==head1.length-2?" Id":""):head1);;
			var head2=fields1[i2].replace("__c","");
			unlimitedExportresultContent+="\""+(head1X.replace(/"/ig,"\"\""))+"\",";
		}
	
	
	RecordsAllProgTexts1="Starting...#Stop#Stopping...#Current Progress: #Complete!#Close#Are you sure you want to export {0} rows?#Export all rows";

 	openAllRecords(RecordsAllProgTexts1,runUnlimitedExport2,200,false,null,fileqX1,exportunlimitedSaveDOne);

}
function exportunlimitedSaveDOne(){
	if(unlimitedExportresultContent!=""){
	$.ajax({url:saveASJSURL,dataType: "script", success:function() { 

			var text = unlimitedExportresultContent;
			  var date1=new Date();
			  var filename = "csv_export_"+date1.getDate()+"_"+(date1.getMonth()+1)+"_"+date1.getFullYear()+"_"+date1.getHours()+"_"+date1.getMinutes()+"_"+date1.getSeconds()+".csv";
			  var blob = new Blob([text], {type: "text/plain;charset=utf-8"});
			  saveAs(blob, filename+"");
	 }});
	}
}
function runUnlimitedExport2(records){
	//alert(records);
	var fields1=unlimitedExportFieldArr;
	var regExComma = new RegExp(",", "ig");
	var regExComma2 = new RegExp("\"", "ig");
	for(var i1=0;i1<records.length;i1++){

				unlimitedExportresultContent+="\n";
				for(var i2=0;i2<fields1.length;i2++){
					var fld1=fields1[i2];
					var res1=records[i1][fld1];
					
					if(res1==null) res1="";
					
					if(res1!=null && res1.indexOf(",")>-1){
						res1=res1.replace(regExComma," ");
					}
					if(res1!=null && res1.indexOf("\"")>-1){
						res1=res1.replace(regExComma2,"\"\"");
					}
					unlimitedExportresultContent+="\""+res1+"\",";
				}

		}
		
		doAllRecordsAll('1'); 
}

function dateTOSqlDate(date1){
	//headerTpx
	var res=date1;
	if(res!="" ){
		try{
			var d1=new Date(res);
			res=d1.getFullYear()+"-"+padZero2Char(d1.getMonth()+1)+"-"+padZero2Char(d1.getDate());
		}catch(e){}
	}
	return res;
}

function timeTOSqlTime(time1){
	//headerTpx
	var res=time1;
	if(res!=""){
		try{
			
			var t1=res.split(/\:|\ /);
			if(!isNaN(t1[0])){
				var h=Number(t1[0]);
				if(h<12 && t1[2]=="PM")h+=12;
				if(h<10) h="0"+h;
				var m=Number(t1[1]);
				if(m<10) m="0"+m;
				res=h+":"+m+":00Z";
			}
		}catch(e){}
	}else{
		res=null;
	}
	return res;
}
function padZero2Char(n){
	if(n<10){
		n="0"+n;
	}
	return n
}

//var lastGroupingPerGroup
var valsGrouping=null;
var valsGroupingCount=0;
function colorRowsByFieldChange(field1, level,delayGoupLoading){
	///Enable_Sort_coloring//Enable_Sort_grouping
	field1=field1.replace(/\./ig,"-");
	if($("th.thw."+field1+":first").length==0){
		alert("Field \""+field1+"\" is not available for grouping/shading, please add field as a column and make sure it is visible for your user or unmark the enable-grouping/apply-shading checkbox under edit-layout>sort-settings");
		return;
	}
	
	var filedRows=$("#mainTBX1 tbody .dataRow td.iTd."+field1+" span, #mainTBX1 tbody .dataRow .ost1X.oSt_"+field1+"");
	var inpMode=0;
	var inpElementT=0;//span
	var hasMiltiRowGroup=false;
	if(filedRows.length>0 && $(filedRows[0]).find(".checkImg").length>0){
	 		inpElementT=2; //checkbox
	 	
	}
	if((inpElementT==0 && isEditMode1) || filedRows.length==0 || $(filedRows[0]).hasClass("hd1")){
	 	filedRows=$("#mainTBX1 tbody .dataRow input.inpSt_"+field1+",#mainTBX1 tbody .dataRow select.inpSt_"+field1+",#mainTBX1 tbody .dataRow textarea.inpSt_"+field1+", #mainTBX1 tbody .dataRow td.iTd."+field1+" span[id]");
	 	inpMode=1;
	 	if(filedRows.length>0 && $(filedRows[0]).prop("tagName").toLowerCase()=="span"){
	 		inpElementT=0; 
	 	}else{
	 		inpElementT=1;
	 	}
	}
	
	//alert(inpElementT);
	var numOfCells=0;
	if( filedRows.length>0){
		var count1=0;
		var countDiff=0;
		var currS="tcx"+(countDiff%2);
		var groupNum=countDiff;
		var lastVal=(inpMode==0 || inpElementT==0 || inpElementT==2?(inpElementT==2?$.trim($(this).find(".checkImg").attr("alt")):$.trim($(filedRows[0]).text())):$.trim($(filedRows[0]).val()));
		if(lastVal!=null && lastVal.indexOf("]]>")>-1){
				lastVal=$.trim(lastVal.substring(lastVal.indexOf("]]>")+3));
		}
		if(lastVal!=null && lastVal.indexOf("//")>-1){
				lastVal=lastVal.substring(lastVal.indexOf("//")+2);
		}
		var headerName=(Enable_Sort_grouping?$.trim($("th.thw."+field1+" .thTxtzp:first").html()):"");
		var headerTpx=(Enable_Sort_grouping?$.trim($("th.thw."+field1+"").attr("tpx")):"");
		var showSubTot=NOT_hideTotalsRow && (headerTpx=="1" || headerTpx=="12" || headerTpx=="61"  || headerTpx=="61f"|| headerTpx=="1f" || headerTpx=="7" || headerTpx=="7f" || headerTpx=="2" || headerTpx=="2f");
		var lastCountSpn=null;
		var lastCount=null;
		var lastcurrVal="";
		var isFirstInGroup=true;
		var EmptyRow="";
		var lastmainTR=null;
		var lastGRP=0;
		var lastGRPUsed=0;
		var lastgnz="";
		if(level==1){
			valsGrouping=new Array();
		}else{
			lastGRP=Number($(".rowGrouping1 span[grp]:last").attr("grp"))+1;
			lastGRPUsed=lastGRP-1;
		}
		//alert(lastGRP);
		valsGroupingCount=0;
		filedRows.each(function(){
			var currVal=(inpMode==0 || inpElementT==0 || inpElementT==2?(inpElementT==2?$.trim($(this).find(".checkImg").attr("alt")):$.trim($(this).text())):$.trim($(this).val()));
			if(currVal.indexOf("]]>")>-1){
				currVal=$.trim(currVal.substring(currVal.indexOf("]]>")+3));
			}
			if(currVal.indexOf("//")>-1){
				currVal=currVal.substring(currVal.indexOf("//")+2);
			}
			
			var mainTR=$(this).parents("tr.dataRow:first");
			var currgnz=mainTR.attr("gnz");
			if(lastgnz=="") lastgnz=currgnz;
			if(mainTR.attr("mrk"+level+"x")==null){
				
				//alert(currVal+" "+lastVal);
				mainTR.attr("mrk"+level+"x","1");
				var rowValueChanged=currVal!=lastVal || (level==2 && lastgnz!=currgnz);
				if(rowValueChanged){
					countDiff++;
					if(Enable_Sort_coloring){
						currS="tcx"+(countDiff%2);
					}
					groupNum=countDiff;
					isFirstInGroup=true;
				}
				
				if(level==1){
							//mainTR.attr("grpM",field1+"~"+currVal+"~"+headerTpx);
							valsGrouping.push(field1+"~"+currVal+"~"+headerTpx);
				}
				if(Enable_Sort_grouping && (rowValueChanged || count1==0)){
					if(numOfCells==0){
						numOfCells=mainTR.find(">td").length;
						if(showSubTot){
							 EmptyRow=mainTR.parents("table").find("tfoot tr.totalRow").clone();
							 EmptyRow.find(".ost1X").each(function(){$(this).html("");});
							 EmptyRow.find(".newRowACTCOL").remove();
							 EmptyRow="<tr class='totalRow lev"+level+"' hn1='{hn}' grpR='{grpR}'>"+EmptyRow.html()+"</tr>";
						 }
						 //alert(EmptyRow);
						//alert(numOfCells);
					}    //<a href='javascript:void(0);' onclick='filterColgroup(this,\""+field1+"\");' title='Click to Filter' onmouseover='fixTitlex2(this);'></a>
					//alert(lastCount);
					
					var hn12=lastcurrVal;
					var hn1=lastVal;
					var hn12Next=currVal;
					var hn1=lastVal;
					if(headerTpx=="2" || headerTpx=="2f"){//if date
						hn12=dateTOSqlDate(lastcurrVal);
						hn1=dateTOSqlDate(lastVal);
						hn12Next=dateTOSqlDate(currVal);
						hn12Next=dateTOSqlDate(currVal);
					}
					if(headerTpx=="61" || headerTpx=="61f"){//if date
						hn12=timeTOSqlTime(lastcurrVal);
						hn1=timeTOSqlTime(lastVal);
						hn12Next=timeTOSqlTime(currVal);
						hn12Next=timeTOSqlTime(currVal);
					}
					
					
					if(lastmainTR!=null)
					lastmainTR.next().before((showSubTot&&lastCount!=null && lastCount>1?EmptyRow.replace("{hn}",escape(hn12)).replace("{grpR}",(lastGRPUsed)+""):""));

					mainTR.before("<tr class='grpx lev"+level+"' hn1='"+escape(hn12Next)+"' grpR='"+(lastGRP+count1)+"'><td colspan='"+numOfCells+"' class='rowGrouping1 "+field1+"' ><span class='ui-icon ui-icon-triangle-1-s uiColps' onclick='collapseExp(this);' grp='"+(lastGRP+count1)+"'></span><span class='hn1'>"+headerName+"</span>:<span class='ml5 hn2'>"+(currVal==null || currVal==''?Blanks_txt:currVal)+"</span><span class='count1'/></td></tr>");
					if(true || lastCount!=null && lastCount>1) {
						if(showSubTot){
							if(level==1){
								//mainTR.attr("grpM",field1+"~"+lastcurrVal+"~"+headerTpx);
								//valsGrouping[valsGroupingCount]=field1+"~"+lastcurrVal+"~"+headerTpx;
								getSubTotals1(field1,lastcurrVal,headerTpx,null,null,null,lastGRPUsed);
								//lastGRPUsed=lastGRP+count1;
							}else if(level==2 && lastCount!=null){
								//alert(mainTR.attr("grpM"));
								var grpM=valsGrouping[valsGroupingCount-1].split("~");//mainTR.attr("grpM").split("~");
								//alert(valsGroupingCount+"+++"+grpM);
								getSubTotals1(field1,lastcurrVal,headerTpx,grpM[0],grpM[1],grpM[2],lastGRPUsed);
								//lastGRPUsed=lastGRP+count1;
							}
						}else{
							
						}
					}
					lastGRPUsed=lastGRP+count1;
					lastcurrVal=currVal; 
					hasMiltiRowGroup=hasMiltiRowGroup || lastCount!=null && lastCount>1;
					//alert(valsGrouping[valsGroupingCount-1]+" "+lastCount);
					if(lastCount!=null )lastCountSpn.html("("+lastCount+(false && count1==viewRowCount?"<span class=\"grisLastPagex1\"/>":"")+")");//
					//else lastCountSpn=null;//single rows
					lastCount=0;
					lastCountSpn=mainTR.prev().find(".count1");
					
					
				}
				count1++;
				if(lastCount!=null && mainTR.hasClass("dataRow"))lastCount++;
				if(level==1){
					mainTR.addClass(currS);
				 	
				}else {
					//mainTR.attr("gnz"+level,groupNum);
					//alert(lastgnz+" "+currgnz)
					lastgnz=currgnz;
				}
				mainTR.attr("gnz",groupNum);//groupnumzaapit
				
				lastmainTR=mainTR; 
				if(hasMassMerge=="true" && isFirstInGroup){
					//mainTR.addClass("gnzMSR");
				}
				//alert(currS);
				lastVal=currVal;
				isFirstInGroup=false;
			}
			valsGroupingCount++;
		});
		if(lastCount!=null )lastCountSpn.html("("+(lastCount)+")");
		if(Enable_Sort_grouping){
			
			//alert(lastmainTR.length + "+++"+lastVal +"+++"+lastCount); 
			if(showSubTot&&lastmainTR!=null && lastCount!=null && lastCount>0) { 
				var hn1=lastVal;
					if(headerTpx=="2" || headerTpx=="2f"){//if date
						hn1=dateTOSqlDate(lastVal);
					}
					if(headerTpx=="61" || headerTpx=="61f"){//if time
						hn1=timeTOSqlTime(lastVal);
					}
					
					
				lastmainTR.after(EmptyRow.replace("{hn}",escape(hn1)).replace("{grpR}",(lastGRPUsed)+""));
				//getSubTotals1(field1,lastVal,headerTpx);
				if(level==1){
					//alert(field1+"~"+lastcurrVal+"~"+headerTpx+"~"+lastGRPUsed); 
					getSubTotals1(field1,lastcurrVal,headerTpx,null,null,null,lastGRPUsed);
					
				}else if(level==2){
					var grpM=valsGrouping[valsGrouping.length-1].split("~");//lastmainTR.attr("grpM").split("~");//valsGroupingCount
					getSubTotals1(field1,lastcurrVal,headerTpx,grpM[0],grpM[1],grpM[2],lastGRPUsed);
				}
			}else if(!showSubTot&&lastmainTR!=null && lastCount!=null && lastCount>0) { 
				//show correct counts
				
				if(level==1){
					//alert(field1+"~"+lastcurrVal+"~"+headerTpx+"~"+lastGRPUsed); 
					getSubTotals1(field1,lastcurrVal,headerTpx,null,null,null,lastGRPUsed);
					
				}else if(level==2){
					var grpM=valsGrouping[valsGrouping.length-1].split("~");//lastmainTR.attr("grpM").split("~");//valsGroupingCount
					getSubTotals1(field1,lastcurrVal,headerTpx,grpM[0],grpM[1],grpM[2],lastGRPUsed);
				}
			}
			
			//$(".headerRow .CBL").html("<span class='ui-icon ui-icon-triangle-1-s uiColps' onclick='collapseExpAll(this);'></span>"+$(".headerRow .CBL").html());
			if(!delayGoupLoading && (isjumpToClk || returnFocus!=""))reloadLastSavedGroups();
			if(!delayGoupLoading)fixIfmHegt();
			//if(hasMiltiRowGroup){

			//}
			
		}//alert(1);
		
	}

}

function filterColgroup(obj,fieldName){
	var val1=$.trim($(obj).text());
	val1=val1.replace(/^\$|\%$|USD$|EUR$|ILS$|AUD$|BRL$|CAD$|CHF$|CNY$|GBP$|HKD$|JPY$|MXN$|NZD$|RUB$|SGD$/g,"");
	
	val1=val1.replace(/\,/,"");
	$(".filterinoIPT.inpf"+fieldName).click().val(val1);
	selectFilterExCBOX("fl"+fieldName,"inpf"+fieldName);
}
var oldAddRowMarkings=null;
function preAddRow(chooseRT){
var tbName=tableX1Z;
var url=newlink1;
	if(chooseRT!=null && chooseRT==1 && url.indexOf('chooseRecordType')==0){
		var urlX=url.split('~');
		var tb1=urlX[1];
		var tb1Label=urlX[2];
		var key3=urlX[3];
		var defVals=urlX[4];
		var newlink=urlX[5];	
		chooseRecordTypeZ(tb1,tb1Label,top,tbName,key3,newlink,defVals,1);
	}else{
		preAddRow2(null);
	}
}
function preAddRow2(recordType){
	trackEventX('preAddRow');
	if(isNaN(NumberOfNewRows)){
		NumberOfNewRows="1";
	}else{
		NumberOfNewRows=Math.round(NumberOfNewRows)+"";
	}
	//alert(NumberOfNewRows);
	var res=true;
	oldAddRowMarkings=new Array();
	var checkedRows=$("#mainTBX1 tbody tr .lcbX input:checked");
	checkedRows.each(function(){
		oldAddRowMarkings.push($(this).parents(".lcbX:first").attr("rid"));
	});
	//alert(checkedRows.length+" "+oldAddRowMarkings);
	totChanged=checkedRows.length;
	if(true || totChanged==0){
		loadingSH();
		addNewRowAF(NumberOfNewRows,recordType);
		res= true;
	}else{
		alert(saveWorkBeforeNewRow);
		res= false;
	}
	return true;
}

//** m o b i l e **
var windDestGlobal=window;
var winpramsGlobal=null;
function editRowZP(recordId,url,win1){
	if(isSF1() ){
		try{
			sforce.one.editRecord(recordId);
			//alert("edit");
		}catch(e){}
	}else if(isSFLight1XV){
		sforce.one.editRecord(recordId);
	}else{
		navigateZP("../"+recordId+"/e?retURL="+url+escape((unescape(url).indexOf("?")>-1?"&":"?")+"viewId="+(mainViewIDTemp!=""?mainViewIDTemp:mainViewID)+sfdcTabNameParam+"&tp="+escape(tp_conf)),win1);
	}
}
function chooseRecordTypeZ(tb1,tbLabel,win1,tbName,key3,newlink,defVals,addRowMode){
		trackEventX('chooseRecordTypeZ');
		
	
		$('#chooseRecordTypeZ').remove(); 

		$('body').append( 
		'<div id="chooseRecordTypeZ" title="Select '+tbLabel+' Record Type">' + 
		'<div style="margin:10px;font-weight:bold;">Record Type for new '+tbLabel+':'+ 
		''+
		'<span id="recordTypeSelZW"><select name="recordTypeSelZ" id="recordTypeSelZ"><option value="">Loading options...</option></select><br></span>' +

		'<div id="descRT1"></div></div></div>' + 
		'' 

		); 
		
		//open window
		 var buttons1=new Array();
			
		buttons1.push({
		text: "Create New "+tbLabel, 
		click: function() {
			var rtID=$("#recordTypeSelZ").val(); 
			  if(rtID==""){
			  	alert("Please select a record type!");
			  }else{
			  	if(addRowMode==null){
			  		var url=newlink+"&RecordType="+rtID+"&ent="+tb1;//"/"+key3+"/e?
			  		newObjZPCont1(tbName,url,win1,rtID,defVals);
			  	}else{
			  		preAddRow2(rtID);
			  	}
			  }
		
		jQuery( this ).dialog( "close" ); 
		} 
		});
		
		
		buttons1.push({
		text: "Cancel", 
		click: function() { 
		jQuery( this ).dialog( "close" ); 
		} 
		});
		
		$( "#chooseRecordTypeZ" ).dialog({ 
		resizable: false, 
		width: (isSF1()?($("body").width()-10):490), 
		height:(isSFLight1XV?250:220), 
		//modal: true, 
		buttons: buttons1
		}); 
			fixIfmHegt();
		
		//fetch data
		//var queryZZZ="SELECT Id,Name,isactive,SobjectType,DeveloperName,Description  FROM recordtype WHERE isactive=true and SobjectType='"+tb1+"' order by name asc"; 
		Visualforce.remoting.Manager.invokeAction( 
		remotegetRTForUser, 
		tb1, 
		function(result, event){ 

		if (event.status && result!=null) { 

		var innerHtml = ''; 
		var records=result; 
		for(var i=0; i<records.length; i++){ 
		innerHtml += 
		'<option value="' + records[i][0] + '" desc="'+(records[i][2]!=null && records[i][2]!=""? (records[i][1] +': '+records[i][2]).replace(/\"/ig,""):"")+'" '+(records[i][3]=='1'?'selected':'')+'>'+records[i][1] +'</option>'; 
		}

		$('#recordTypeSelZW').html('<select name="recordTypeSelZ" id="recordTypeSelZ">'+innerHtml+'</select>');
		$("#recordTypeSelZ").change(function(){$("#descRT1").html($(this[this.selectedIndex]).attr("desc"));});
		var recordTypeSelZ=$("#recordTypeSelZ")[0]; 
		$("#descRT1").html($(recordTypeSelZ[recordTypeSelZ.selectedIndex]).attr("desc"));
		} else if (event.type === 'exception') { 
		if(event.message!=null && ((event.message+"").indexOf("Logged in")>-1 || (event.message+"").indexOf("Refresh page")>-1)){ 
		self.location=self.location; 
		}else if(event.message!=null && (event.message+"").indexOf("Unable to connect")==-1){ 
		if($("body:visible").length>0)alert("An error has occurred: "+event.message); 
		} 
		} else { 
		//self.location=self.location; 
		// $("#"+filterIdSpan+" .availVals").html(""); 
		//alert(1); 
		} 

		}, 
		{escape: true,buffer:true,timeout: 90000} 
		); 
		
		
		
		
}
function newObjZP(tbName,url,win1){
	

	if(url.indexOf('chooseRecordType')==0){
		var urlX=url.split('~');
		var tb1=urlX[1];
		var tb1Label=urlX[2];
		var key3=urlX[3];
		var defVals=urlX[4];
		var newlink=urlX[5];	
		chooseRecordTypeZ(tb1,tb1Label,win1,tbName,key3,newlink,defVals);
	}else{
		var urlX=url.split('~');
		newObjZPCont1(tbName,urlX[0],win1,null,urlX[1]); 
	}
}
function newObjZPCont1(tbName,url,win1,rtID,defVals){//rtID recordType
	if(isSF1() || isSFLight1XV){
		try{
			var defX=defVals.split(':');
			var defJ={};
			if(defX.length>1){
				for(var i=0;i<defX.length;i=i+2){
					defJ[defX[i+0]]=defX[i+1];
				}
			}
			//alert(defVals+" "+defJ);
			sforce.one.createRecord(tbName,rtID,defJ);
			//alert("edit");
		}catch(e){
			if((e.message).indexOf("Invalid target")>-1 || (e.message).indexOf("expected pattern")>-1){//cross domain
				parent.postMessage('sforce.one.createRecord("'+tbName+'","'+rtID+'",'+JSON.stringify(defJ)+');/*zaapit_tb_zbnx1~650~*/','*');
			}else{
				navigateZP(url,win1);
			}
		}
	}else{
		navigateZP(url,win1);
	}
}

var lastnavigateZP=0;
function navigateZP(url,windDest,winprams,isPopup){//windDestetination (send parent if needed), winprams for new window
//alert(url.length);
try{
if(windDest!=null){
	windDestGlobal=windDest;
}else{
	windDestGlobal=window;
}
if(winprams!=null){
	winpramsGlobal=winprams;
}else{
	winpramsGlobal=null;
}
try{
if(!isSF1()){
	var domain1=(Urlx1.indexOf("zaapit__")>-1 || Urlx1.indexOf("zaapit.")>-1?"zaapit__":"c__");
	var loc1=(self.location+"");
	var locX1=loc1.split("?")[0];
	var urlxxx=(locX1)+"?viewId="+(mainViewIDTemp!=""?mainViewIDTemp:mainViewID)+sfdcTabNameParam+"&retFoc="+escape(url)+(mainID!=""?"&id="+mainID:"")+(loc1.indexOf("isdtp=vw")>-1?"&isdtp=vw":"")+(loc1.indexOf("&isdtp=p1")>-1?"&isdtp=p1":"")+"&pw1="+escape(parentLocParam1)+"&tp="+escape(tp_conf);
	//var bookie="lastlist="+urlxxx;
	if(!isSFLight1XV && url.indexOf("retURL")==-1){
		var top_loc=null;
		try{
			top_loc=""+top.location.src;
			//alert(top_loc);
		}catch(e3){}
		if(url.length<2000)url=url+(url.indexOf("?")==-1?"?":"&")+"retURL="+escape((top_loc==null && mainID!=""?"/"+mainID:urlxxx));
	}
	try{
	var stragePref2="subtab~"+UrlEnd1+"~"+mainID;

		localStorage.setItem(stragePref2, urlxxx); 
	//alert(stragePref2+" "+"/apex/"+domain1+urlxxx );
	}catch(e){}
	//document.cookie=bookie;
	//alert(isInIframe());
	if(!isInIframe()){
		history.pushState({}, $(".curSelectedView").val(), urlxxx);
	}
}else{
	//document.cookie="lastlist=";
}
}catch(e1){}
//alert((url.split("?")[0]));
//alert(url.match(/^[\.]{0,2}\/[a-z0-9]+$/ig));
//alert(sforce.console!=null);
//https://zaapit-dev-ed.lightning.force.com/one/one.app#/alohaRedirect/005d0000000xpdc
//url.split("?")[0]

var tempIDURL=url.split("?")[0];
if(tempIDURL.indexOf("/one/one.app#/alohaRedirect/")>-1){
	tempIDURL=tempIDURL.substring(tempIDURL.indexOf("/one/one.app#/alohaRedirect/")+"/one/one.app#/alohaRedirect/".length-1);
}
//alert(tempIDURL + " " +tempIDURL.indexOf("/one/one.app#/alohaRedirect/")+ " "+isPopup+ " "+isSFLight1XV);

	if((isSF1() || isSFLight1XV)&& (tempIDURL).match(/^[\.]{0,2}\/[a-z0-9]+$/ig)){//redirect to single ID: "/safdsgsdf036"
		var currnavigateZP=new Date().getTime();
		if(lastnavigateZP+300<currnavigateZP){
			navigateZPObjID((tempIDURL).substring(url.indexOf('/')+1));
		}
		lastnavigateZP=currnavigateZP;
	}else{
		if((isSF1())){
			NavMobZP(url,false);//isredirect
//		}else if(sforce.console!=null){
	//		alert("console");//
//			     sforce.console.getEnclosingPrimaryTabId(openSubtab);
        
      //  var openSubtab = function openSubtab(result) {
            //Now that we have the primary tab ID, we can open a new subtab in it
        //    var primaryTabId = result.id;
         //   sforce.console.openSubtab(primaryTabId , url, true, 
         //       null, null, null, 'zp_salesforceSubtab');
        //};
        }else if(isPopup!=null && isPopup){
        //alert(2);
        	window.open(url,'_blank',winpramsGlobal);
        }else if(isSFLight1XV){
        //alert(3);
        	redirectNormal1(url);
		}else{
		//alert(4);
			redirectNormal1(url);
		}
	}
	}catch(e){
	//alert(e);
		redirectNormal1(url);
	}
	
}
function NavMobZP(url,isredirect){
	try{
	if(url.indexOf("/back.jsp")>-1){
		sforce.one.back(true);
	}else{
		sforce.one.navigateToURL(url,isredirect);//isredirect
		
	}
	}catch(e){
		redirectNormal1(url);
	}
}

function navigateZPObjID(recordId){
try{
	if(sforce!=null && sforce.one!=null){
		sforce.one.navigateToSObject(recordId,"detail");
	}else{
		redirectNormal1("/"+recordId);
	}
	}catch(e){
		redirectNormal1("/"+recordId);
	}
}
function redirectNormal1(url){
	if(winpramsGlobal==null){
		try{
			var win=window.open(url,"_top");
			if(win==null){
				var win1=window.open(url,"_blank");
				var timer = setInterval(function() {   
			    if(win1.closed) {  
			        clearInterval(timer);  
			        jumpToClk(currPageCls,600);
			    }  
				}, 1000);
			}
		}catch(e){
			
		}
	}else{
		windDestGlobal.open(url,"popup1",winpramsGlobal);
	}
}
function isSF1(){
var res=false;
try{
	res=isSF1XV;//(typeof sforce != 'undefined') && sforce!=null && sforce.one!=null;
}catch(e){
}
return res;
}
function addnewRow(){
	try{
		//alert(oldAddRowMarkings.length);
		if(oldAddRowMarkings!=null && oldAddRowMarkings.length>0){
			var strxx1="";
			for(var irx=0;irx<oldAddRowMarkings.length;irx++){
				if(oldAddRowMarkings[irx]!=null){
					$(".RID"+oldAddRowMarkings[irx]).attr("checked","checked").each(function(){
					markCheckedRows=true;
					//markCheckedRow($(this).parents("tr:first"));//each for new rows
					});
				}
			}
			oldAddRowMarkings=null;
		}
	}catch(e){}
	fixOnload();
	scrollBottom1();
	
	$("#mainTBX1 table.list tbody tr.dataRow:last").addClass("markedRowTA");
	$("#mainTBX1 table.list tbody tr.dataRow:last").removeClass("markedRowTA",5000,function(){});
	
	$("body").trigger("addNewRowsDone");
}
function openGenWindow1(src1,title1,width1,height1,buttons,closeFunc,isPost,popupBaseName){
	if(popupBaseName==null){
		popupBaseName="generalWinIframe1";
	}else{
		$("#"+popupBaseName).remove();
		var popupX=$($("#generalWinIframe1")[0].outerHTML.replace(/generalWinIframe1/ig,popupBaseName));
		popupX.find("iframe").attr("src","about:blank");
		$("body").append(popupX);
	}
	var isSF1x1=isSF1();
	var maxWidth=$(self).width()+(isSF1x1?-10:-50);
	if(width1==null){
		width1=maxWidth;
	}else if(width1>maxWidth){
		width1=maxWidth;
	}
	$("#"+popupBaseName+"IDIframe")[0].src="about:blank";
	
	$("#"+popupBaseName).removeClass("hd1");
	var iframeH=(height1==null?($(self).height()+(isSF1x1?0:-100)):(height1-100))-3;
	//alert(iframeH);
	$("#"+popupBaseName+"IDIframe").height(iframeH);
	$("#"+popupBaseName+"").dialog({
            resizable: true,
            height:(height1==null?($(self).height()+(isSF1x1?0:-50)):(height1)),
            width:width1,
            modal: true,
            title: title1,
            buttons: buttons,
             close: function(){
             	if(closeFunc!=null) closeFunc();
             	$("#"+popupBaseName+"").dialog("close");
             }
            });
            
	//"+popupBaseName+"Name
	//alert(isPost+ " "+ src1+ " "+popupBaseName);
	if(isPost==null	){
		$("#"+popupBaseName+"IDIframe").attr("src",src1);
	}else{
		var sourceX=src1.split("?");
		postToIframe(sourceX[1],src1.replace(/\&ids\=[^\&]+/,"").replace(/\&bdq\=[^\&]+/,""),""+popupBaseName+"Name");
	}
}

function postToIframe(data,url,target){
	$('#postToIframe').remove();
    $('body').append('<form action="'+url+'" method="post" target="'+target+'" id="postToIframe" class="hd1"></form>');
    var datax1=data.split(/\=|\&/ig);
    	for(var i=0;i<datax1.length && datax1.length>2;i=i+2){
    		var in1='<input type="hidden" name="'+datax1[i]+'" value="'+unescape(datax1[i+1]).replace(/"/ig,"_")+'" />';
    		//alert(in1);
        	$('#postToIframe').append(in1);
        }
    //alert($('#postToIframe').html());
    setTimeout(function(){$('#postToIframe').submit();},300);
}

function closeGenWindow1(){
	$("#generalWinIframe1").dialog("close");
}
function chtrflnx1(obj){
	$(obj).find(".zen-mediaExt").each(function(){
		if($(this).attr("data-chatter-subscribe")==null	){
			$(this).attr("data-chatter-subscribe","0");
		}
		//alert($(this).css("display"));
		if($(this).css("display")=="inline"){
			$(this).css("display","inline-block");
		}
	});
	
}

function chtrinos1(id1,obj){
try{
	
	var idURL=id1;
	if(idURL!=null && idURL.length==18){
		idURL=idURL.substring(0,15);
	}
	var action="new";
	if($(obj).hasClass("chtrW1true")){
		action="delete";
	}

	if(action=="new"){
		
 Visualforce.remoting.Manager.invokeAction(
                remotesetFollowChatterSts,
                id1,true, 
                function(result, event){
                	//alert(result + " "+event);
                    if (event.status && result!=null) {
                    		if(Number(result)>0){
				    			$(obj).addClass("chtrW1true");
								$(obj).removeClass("chtrW1false");
							}else{
								alert("We could not complete your request due to an error, make sure you havn't exceeded the Salesforce chatter follow-limit of 500 rows!");
							}
                     } else if (event.type === 'exception') {
                        //self.location=self.location;
  
                    } else {
      
                    }
                }, 
                {escape: true,buffer:true,timeout: 90000}
            );

		
		
	}else{

			 Visualforce.remoting.Manager.invokeAction(
                remotesetFollowChatterSts,
                id1,false, 
                function(result, event){
                //alert(result + " "+event);
                    if (event.status && result!=null) {
		    			$(obj).addClass("chtrW1false");
						$(obj).removeClass("chtrW1true");
                     } else if (event.type === 'exception') {
                        //self.location=self.location;
  
                    } else {
      
                    }
                }, 
                {escape: true,buffer:true,timeout: 90000}
            );
            

	}
	
	}catch(e){
		alert(e);
	}
}


function octrF1(id1){
	var obj="input.RID"+id1+"";
	fixDilalogIframeHeight();
	$(obj).parents("tr.dataRow:first").addClass("markedRowTA");
	var pw1=(parentLocParam1==""?self.location:parentLocParam1)+"";
	if(pw1.indexOf("servlet.Integration")>-1){
		pw1="/"+mainIDForURL;
	}
	setTimeout(function(){openGenWindow1("../apex/zaapit__chatterPreview?id="+id1+"&isdtp=p1&pw1="+escape(pw1),chatter_feed_title,850,null,null,function(){
	$("#generalWinIframe1IDIframe")[0].src="about:blank";
		$(obj).parents("tr.dataRow:first").removeClass("markedRowTA",1000,function(){});
     	if(lastBodyHeight!=null){
              $("#padBut1").height(0);
              fixIfmHegt();
      	}
	});
	},200);
}

var lastHoverCount1=1;
function octrF1O(obj,show){
	var OF1=$(obj).parents(".chtr1:first").find(".OF1");
	//var titd1=$(obj).attr("titd1");
	//alert(titd1);
	$(obj).removeAttr("mouseover","").removeAttr("mouseout","")
	openQtip1(obj,OF1.html());
	OF1.remove()
/*
	lastHoverCount1++;
	var curlastHoverCount1=lastHoverCount1;
	
	if(show){
		setTimeout(function(){if(curlastHoverCount1==lastHoverCount1){$(".ui-tooltip:visible").hide();$(".OF1:visible").hide();OF1.show().addClass("db");}},500);
	}else{
		setTimeout(function(){OF1.hide().removeClass("db");},5500);
	}
	*/
	
}
function closeOctrF1O(){
	lastHoverCount1++;
	$(".OF1:visible").hide();
}
var lastGirdTRNum=0;
function omActF1(id1,obj,altName){
	if(id1==""){	
	    if(!confirm("Click ok to quick-create this new record and to open the related information popup")) return false;
		var tr1=$(obj).parents("tr:first");
		lastGirdTRNum=$(".mainTB1 .list tbody tr.dataRow").index(tr1);
		//alert(lastGirdTRNum);
		onSave1(true);//quick save
		return;
	}
	fixDilalogIframeHeight();
	var rowName=altName;
	if(obj!=null){
		var row=$(obj).parents("tr.dataRow:first").addClass("markedRowTA");
		rowName=$.trim(row.find(".ost1X.oSt_name:first").text());
	}
	if(rowName!=""&& rowName.length<250){
		rowName=" - "+rowName;
	}
	var moreAction_Linkx=moreAction_Link.replace("{0}",id1);
	var pw1=(parentLocParam1==""?self.location:parentLocParam1)+"";
	if(pw1.indexOf("servlet.Integration")>-1){
		pw1="/"+mainIDForURL;
	}
	setTimeout(function(){openGenWindow1(moreAction_Linkx+(moreAction_Linkx.indexOf("?")==-1?"?":"&")+"pw1="+escape(pw1),moreAction_title+rowName,moreAction_windowWidth,null,null,function(){
	$("#generalWinIframe1IDIframe")[0].src="about:blank";
		if(obj!=null) $(obj).parents("tr.dataRow:first").removeClass("markedRowTA",1000,function(){});
     	if(lastBodyHeight!=null){
              $("#padBut1").height(0);
              fixIfmHegt();
      	}
	});
	},200);
}
var StratResize=false;
var StratResizeObj=null;
var StratResizeLWI=null;
function resizeColSr(obj,e){
	if(!isScrollModeVertical() & !isSF1()){
		stopProp1(e);
		StratResize=true;
		StratResizeObj=obj;
		$("body").addClass("noselect1");
		var height=$("#mainTBX1").height();
		$(".resizex1,.resizex2").height(height).show();
		var ph1=$(StratResizeObj).parents("th:first");
		var mainTBX1=$("#mainTBX1").position()
		var ph1O=ph1.offset();
		
		//alert(ph1.width());
		$(".resizex1").css({left:(ph1O.left+(!isSFLight1XV?-10:0)),top:mainTBX1.top});
		$(".resizex2").css({left:(ph1O.left+ph1.width()+(!isSFLight1XV?-10:5)),top:mainTBX1.top});
		//alert("resizeColSr");
		StratResizeLWI=ph1.width();
	}
}
function resizeColSt(){
//alert("resizeColSt "+StratResizeLWI);
	if(StratResize){
	StratResize=false;
	var col=$(StratResizeObj).attr("fld");
	var p1=$(StratResizeObj).parents(".thw:first");
	var ph1=$(StratResizeObj).parents("th:first");
	var pf1=$(".mainTB1 td.TOT-"+col+" .oSt_"+col+"");
	ph1.css({"width":StratResizeLWI}).find(".thTxtzp").css({"width":(StratResizeLWI-17)+"px"});
	p1.css({"min-width":StratResizeLWI+"px"});
	pf1.css({"width":StratResizeLWI});
	$(".oSt_"+col+",span.inpSt_"+col).width(StratResizeLWI);  
	//ph1.find("a:first,.thTxtzp").css({"width":(StratResizeLWI-17)});
	//ph1.css({"width":StratResizeLWI});
	$(".resizex1,.resizex2").hide();
	
	$("body").removeClass("noselect1");
	Visualforce.remoting.Manager.invokeAction(
                remotesetColumnWidth1,
                col,p1.width(),currConf_name, mainViewID, 
                function(result, event){
                	//alert(result + " "+event);
                    if (event.status && result!=null) {
				    		//alert(result + 'Saved');
				    		$(".columnsWidthXZ").val(result);
                     } else if (event.type === 'exception') {
  
                    } else {
      
                    }
                }, 
                {escape: true,buffer:true,timeout: 90000}
            );
            
            //p1.css({"min-width":StratResizeLWI});
	//alert("2");
	}
}
function getCUrrScollLeft(considerInsideScroll){
	//return $(self).scrollLeft(); 
	return (EnableHorizontalScroll==1?(considerInsideScroll!=null && considerInsideScroll?$("#mainTBX1").scrollLeft():0):$(self).scrollLeft());
}
function resizeColOv(e){
	if(StratResize){
		var p1=$(StratResizeObj).parents(".thw:first");
		var ph1=$(StratResizeObj).parents("th:first");
		var pl=ph1.offset().left;
		var mp=e.clientX+ getCUrrScollLeft(false); 
		//alert(getCUrrScollLeft(true));
		if(mp>pl+10 ){
			StratResizeLWI=mp-pl;
			
			//p1.css({"min-width":StratResizeLWI});
			$(".resizex2").css({left:(mp-7)});
		}else{
			//p1.css({"min-width":ph1.width()});
			$(".resizex2").css({left:(pl+10)});
		}
		//alert(mp + " "+pl);
	}
}
function openActionsMob(obj){
	if($(obj).hasClass("clk")){
		$(obj).removeClass("clk");
	}else{
		$(obj).addClass("clk");
	}
}
function btnMenuSF1(obj){
	//$("body").height(650);
    if($(obj).hasClass("clk")){
		$(obj).removeClass("clk");
	}else{
		$(obj).addClass("clk");
	}
}
	//https://www.salesforce.com/us/developer/docs/ajax/Content/sforce_api_ajax_queryresultiterator.htm
	
	
	function saveIgnoreErrors(){
    
        if(confirm("Do you want to skip the marked error-rows & save?")){
            if(currePlacex1RedErrors!=""){
                $(currePlacex1RedErrors.substring(1)).each(function(){
                    $(this).find("input:checked").prop("checked",false);
                });
            }
            loadingSH();
            saveFunc();
        }
}
var onloadbodayColSwOn=false;
var lastColx1=3;
function columnSwitch(addCol){
	if(!onloadbodayColSwOn){
		onloadbodayColSwOn=true;
		$("body").bind("OnLoadDone",function(){
		    //alert(lastColx1);
			var lastCol=lastColx1;
			lastColx1=3;
			var dif=lastCol-lastColx1;
			//alert(lastCol+" 1 "+lastColx1);
			for(var i=0;i < dif;i++){
				columnSwitch(1);
			}
		});
	}
	var headers=$("#mainTBX1 table .headerRow th");
	var headersLen=headers.length;
	var visCol=lastColx1+addCol+1;
	//alert(HideCol+" "+visCol);
	if(visCol>3 && headersLen>=visCol){ 
		$("body.sf1 .Zstbl1 .apexp table.list>thead>tr>th:nth-child("+visCol+"), body.sf1 .Zstbl1 .apexp table.list>tbody>tr>td:nth-child("+visCol+"), body.sf1.Zstbl1 .apexp table.list>tfoot>tr>td:nth-child("+visCol+")").removeClass("columnHDMOB").addClass("columnVISMOB");
		//"+
		 //",body.sf1 .Zstbl1 .apexp table.list>thead>tr>th:nth-child("+(visCol+1)+"), body.sf1 .Zstbl1 .apexp table.list>tbody>tr>td:nth-child("+(visCol+1)+"), body.sf1.Zstbl1 .apexp table.list>tfoot>tr>td:nth-child("+(visCol+1)+")
		
		if(visCol+1<=headersLen){
			$("body.sf1 .Zstbl1 .apexp table.list>thead>tr>th:nth-child("+(visCol+1)+"), body.sf1 .Zstbl1 .apexp table.list>tbody>tr>td:nth-child("+(visCol+1)+"), body.sf1 .Zstbl1 .apexp table.list>tfoot>tr>td:nth-child("+(visCol+1)+")").removeClass("columnHDMOB").addClass("columnVISMOB");
		}
		if(3<visCol-1){
			$("body.sf1 .Zstbl1 .apexp table.list>thead>tr>th:nth-child("+(visCol-1)+"), body.sf1 .Zstbl1 .apexp table.list>tbody>tr>td:nth-child("+(visCol-1)+"), body.sf1 .Zstbl1 .apexp table.list>tfoot>tr>td:nth-child("+(visCol-1)+")").addClass("columnHDMOB").removeClass("columnVISMOB");
		}
		if(headersLen>=visCol+1){
			$("body.sf1 .Zstbl1 .apexp table.list>thead>tr>th:nth-child("+(visCol+1)+"), body.sf1 .Zstbl1 .apexp table.list>tbody>tr>td:nth-child("+(visCol+1)+"), body.sf1 .Zstbl1 .apexp table.list>tooft>tr>td:nth-child("+(visCol+1)+")").addClass("columnHDMOB").removeClass("columnVISMOB");
		}
	
		lastColx1+=addCol;
	}
	$("#columnScrollW1 .l").fadeTo("fast",(visCol>4?1.0:0.5));
	$("#columnScrollW1 .r").fadeTo("fast",(headersLen>=visCol+1?1.0:0.5));
	//setTimeout(function(){closeAllTooltips();},2500);
}

function refreshListQuick(){
	jumpToClk(currPageCls,600);
}
function openMassCreate(configName,fieldAPI,windowTitle,selectRowRequired,clearTabCache,params,afvq,afvqT,skipIfExists,funcOnceDone){//skipIfExists=1/0
	var checked1=$(".lcbX input:checked"); 
	var CBAll=$("input.lcbXAll").is(":checked");
	//alert(skipIfExists);
	if(selectRowRequired!=null && selectRowRequired==1 && checked1.length==0){
		alert("Please select at least one row");
	}else{
		var ids=""; 
		if(checked1.length>0){
			checked1.each(function(){
			    ids+="~"+$(this).parents(".lcbX:first").attr("rid");
			});
			ids=ids.substring(1);
			
		}
		if(afvqT==null)afvqT="";
		if(afvq==null)afvq="";
		var funcOnCloseX=clearcheckBoxes;
		if(funcOnceDone!=null){
			funcOnCloseX=function(){
				funcOnceDone();
				clearcheckBoxes();
			}
		}
		openGenWindow1("../apex/zaapit__masscreate?tp="+escape(configName)+"&fld="+escape(fieldAPI)+"&ids="+escape(ids)+"&isdtp=p1&afvqT="+escape(afvqT)+"&afvq="+escape(afvq)+"&bdq="+escape(DBsubQery)+"&cba="+escape(CBAll)+"&cbaCount="+escape(totalCountAjx)+(params!=null?"&params="+escape(params):"")+"&six="+escape(skipIfExists),windowTitle,600,650,null,funcOnCloseX,"1");
		//openWindowZP("../apex/zaapit__masscreate?tp="+configName+"&fld="+fieldAPI+"ids="+ids+"&isdtp=p1",windowTitle);
	}
	fixIfmHegt();
	if(clearTabCache!=null){
		try{
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
				setTimeout("parent.postMessage('$(\"iframe[name=\\'"+clearTabCache+"\\']\").attr(\\'src\\',\\'about:blank\\').height(99);/*zaapit_tb_zbnx1~99~*/','"+postURl1+"');",100);
			}
		}catch(e1){
			alert(e1);
		}
		
	}
}

function clearcheckBoxes(){
	$(".lcbXAll:checked").prop("checked","");
	$(".lcbX input:checked").prop("checked",""); 
}

/*********** zp lookup zintext*****************/

var lastOpenParamsZP=null;
function openWindowZP(url,windowTitle,onload1){
	if($("#ZPdialogSR").length>0){
		$("#ZPdialogSR").remove();
	}
    if($("#ZPdialogSR").length==0){
        $("body").append("<div id='ZPdialogSR' style='display:none;overflow:"+(isSF1()?"scroll":"none")+";'><div style='-webkit-overflow-scrolling:touch;'><iframe src='about:blank' width='100%' height='100%' name='ZPdialogSRIF' id='ZPdialogSRIF' frameborder='0' style='margin:0px;' "+(isSF1()?"scrolling='yes'":"")+" /></div></div>");
    }
    lastOpenParamsZP=[url,windowTitle];
    //$("html,body").height($(self).height());
    $("#padBut1").height(Math.max($("#padBut1").height(),($(self).height()-$(".Zstbl1WS").height())));
    
    var height1=$(self).height()-200;
    
    var width1=$(self).width()-100;
    $("#ZPdialogSRIF").height(height1-50);
    
    $("#ZPdialogSRIF").attr("src",url);
  
	if(onload1!=null)onload1();
    $( "#ZPdialogSR" ).dialog({
      height: height1,
      width: width1,
      title:windowTitle,
      modal: true
    });
	
}
function closeWindowZP(){
    lastOpenParamsZP=null;
    $( "#ZPdialogSR" ).dialog("close");
}


function fixContent1(){
	try{
	if($("#ZPdialogSRIF")[0].document==null){
		//alert("0");
		self.setTimeout(fixContent1,1000);
	}else{
		//alert("1");
	}
	}catch(e){
		//alert(e);
	}
}   
latInputLU1keyUpCount=0;
var latInputLU1=null; 
function openSearchLUDL(windowTitle,inputConnect,lnk1){
	latInputLU1Link=lnk1;
	latInputLU1=$(inputConnect).data('inp');
	$("#autoSearchLU").show();
	$("#autoSearchLU").unbind( "keyup", false )
	$("#autoSearchLU").keyup(function(){latInputLU1keyUpCount++; var latInputLU1keyUpCountT=latInputLU1keyUpCount;setTimeout(function(){if(latInputLU1keyUpCount==latInputLU1keyUpCountT)lookUpSearchx1();},250);});
	$("#autoSearchLU").val($(latInputLU1).val());
	$("#OptionResult").hide();
	
    var height1=$(window).height()/2;
    if(height1>800){
    	height1="800";
    }else if(height1<350){
    	height1="350";
    }
    var width1=$(window).width()-100;
    if(width1>500){
    	width1="500";
    }
	$("#ZPdialogLU").dialog({
	  position: { my: "center top", at: "center top"},
      height: height1,
      width: width1,
      title:windowTitle,
      modal: true
    });
    lookUpSearchx1();
} 
var latInputLU1Link=null; 
function lookUpSearchx1(){
	//alert($(latInputLU1).val());
	//latInputLU1Link=lnk1;
	var lnk1=latInputLU1Link.replace("LookupPage","LookupResultsFrame");
	if($.trim($("#autoSearchLU").val())==""){//show recent
		//lnk1=
		$("#searchResult").hide();
		$("#recentItems1").show();
	}else{
		$("#searchResult").show();
		$("#recentItems1").hide();
		lnk1=lnk1+"&lksrch="+encodeURIComponent($("#autoSearchLU").val())+"&go=+Go%21+&lkenhmd=SEARCH_NAME";
	}
	$("#itemRes1").html("Loading...");
	//$("#itemRes1").load(lnk1);
	$.ajax({
		url: lnk1,
		success: function(  data, textStatus,  jqXHR ){
			try{
			var resultHTML="";
			var tbData=(data+"");
			//alert(tbData);
			var f1=tbData.indexOf("class=\"list\"");
			var t1=tbData.indexOf("</table>",f1);
			if(f1>-1 ){
				tbData="<table "+tbData.substring(f1,t1+8);
				var i1=0;
				//alert($(tbData+"").find("tr.dataRow").length +" \n\n"+tbData+"");
				$(tbData+"").find("tr.dataRow").each(function( ) {
						//alert($(this).text());
						var sel1=$(this).find("a.dataCell");
						var txt=sel1.text();
						var onclick=null;
						if(sel1.attr("onclick").indexOf("top.window.opener.")==0){
							onclick=sel1.attr("onclick").substring("top.window.opener.".length);
						}
						if(onclick!=null && onclick.indexOf("\\\"")>-1){
							onclick=onclick.replace(/\"/g,"&quot;");
						}
						var txt2="";
						$(this).find("td.dataCell").each(function(){
							if($.trim($(this).text())!="")txt2+=" | "+$(this).text();
						});
						if(txt2.length>3){
							txt2=txt2.substring(3);
						}
						resultHTML+="<a href=\"javascript:void(0);\" onclick=\"lookUpSearchx1Sel(this);"+(onclick!=null?onclick+";":"")+"\" class=\"sel l"+(i1%2)+"\"><span class=\"m\">"+txt+"</span> <span class=\"ext\">"+txt2+"</span></a>";
						i1++;

				});
				$("#itemRes1").html(resultHTML);
			}else{
			//alert(f1+"  "+t1);
			$("#itemRes1").html("<b style=\"color:red;\">Please enter a search string at least 2 characters long.</b><br>");//+(data+"")
			}
			
			}catch(e){alert(e);}
		}
		});
}
function lookUpSearchx1Sel(obj){
	disableNotice1=true;
	$(latInputLU1).val($(obj).find(".m").text()).change();
	var mu_afchange=$(latInputLU1).attr("mu_afchange");
	if(mu_afchange!=null && mu_afchange!=""){
		mu_afchange=mu_afchange.replace(/\\'/ig,"'");
		$.globalEval("try{"+mu_afchange+"}catch(e1){}");
	}
	$("#ZPdialogLU").dialog("close");
	setTimeout(function(){disableNotice1=false;},500);
}




function openSearchLUDL2(windowTitle,inputConnect,lnk1){
	latInputLU1Link=lnk1;
	latInputLU1=$(inputConnect).data('inp');
	$("#autoSearchLU").hide();
	
	$("#OptionResult").show();
	$("#searchResult").hide();
	$("#recentItems1").hide();
		
    var height1=$(window).height()/2;
    if(height1>800){
    	height1="800";
    }
    var width1=$(window).width()-100;
    if(width1>500){
    	width1="500";
    }
	$("#ZPdialogLU").dialog({
	  position: { my: "center top", at: "center top"},
      height: height1,
      width: width1,
      title:windowTitle,
      modal: true
    });
    lookUpSearchx2();
} 

function lookUpSearchx2(){
	//alert($(latInputLU1).val());
	//latInputLU1Link=lnk1;
	var lnk1=latInputLU1Link;
	lnk1=lnk1.replace(/:/ig,"_");
	var resultHTML="";
	try{
	$.globalEval("globalLInkTrans2=cb_"+lnk1+";");
	var arr1=globalLInkTrans2;
	if(arr1!=null && arr1.length>0){
		for(var x1=0;x1<arr1.length;x1++){
			resultHTML+="<a href=\"javascript:void(0);\" onclick=\"lookUpSearchx1Sel(this)\" class=\"sel l"+(x1%2)+"\"><span class=\"m\">"+arr1[x1]+"</span></a>";
		}
		$("#itemRes1").html(resultHTML);
	}else{
		$("#itemRes1").html("<b style=\"color:red;\">Data Not Found.</b><br>");
	}
	}catch(e){
		$("#itemRes1").html("<b style=\"color:red;\">Data Not Found.</b><br>");
	}
}


function isIERLModeLUOV(){
	var t1=false;
	try{
		
        t1=!disableLUOv&& isInIframe();
        t1=t1&navigator.userAgent.indexOf("Chrome")==-1 && navigator.userAgent.indexOf("Safari")==-1 && navigator.userAgent.indexOf("Firefox")==-1;
    }catch(e1){}
	return t1;
}
var skiplookupCLass="";
var disableLUOv=false;
var globalLInkTrans1="";
var globalLInkTrans2="";
function readyFixLKPX(){
//alert(isSFLight1XV);
if(isIERLModeLUOV() || isSF1() || isSFLight1XV || $("body").hasClass("light1")){//|| isSFLight1XV
try{
$( window ).on( "orientationchange", function( event ) {

var width1=$(window).width();
var height1=$(window).height();
if(isSF1P){//in SF 1 app
	if(height1>1000 &&$("body").hasClass("sf1")){
		$("body").removeClass("sf1").addClass("light1");
	}else if(width1>1000 &&$("body").hasClass("light1")) { 
		$("body").addClass("sf1").removeClass("light1");
	}
}
//$( "#orientation" ).text( "This device is in " + event.orientation + " mode!" );
    //var t1=lastOpenParamsZP;
    //closeWindowZP();
    //openWindowZP(t1[0],t1[1]);
    if(lastOpenParamsZP!=null && $("#ZPdialogSRIF").is(":visible")){
        var height1=$(window).height()-200;
        
        var width1=$(window).width()-100;
        $("#ZPdialogSRIF").height(height1-50);
        $( "#ZPdialogSR" ).dialog({height: height1, width: width1});
    }
	
	if($("#ZPdialogLU").length>0 && $("#ZPdialogLU").is(":visible")){
		var height1=$(window).height()/2;
		if(height1>800){
			height1="800";
		}
		if(height1<300){
			height1="800";
		}
		var width1=$(window).width()-100;
		if(width1>500){
			width1="500";
		}
		$("#ZPdialogLU").dialog({height: height1, width: width1});
    }
});
}catch(e1){}

//top.window.opener=window;
		
		if($("#ZPdialogLU").length==0){
			$("body").append("<div id=\"ZPdialogLU\" style=\"display:none;overflow:"+(isSF1()?"scroll":"none")+";\"><style>#ZPdialogLU .sel{width:100%;display:block;padding:5px;}#ZPdialogLU .sel.l1{background:#efefef;} #recentItems1{background:#e5e5e5;font-weight:bold;margin-top:5px;padding:5px;}#OptionResult,#searchResult{background:#e5e5e5;font-weight:bold;padding:5px;margin-top:5px;}.searchCLR1{display:none;z-index:1500;right:10px;}</style><div ><input type=\"search\" id=\"autoSearchLU\" autocorrect=\"off\" name=\"autoSearchLU\" style=\"width:100%;-webkit-appearance:searchfield;-webkit-appearance:searchfield;\" placeholder=\""+Search_label+"\"><span class=\"searchCLR1\" onclick=\"$(\\\"#autoSearchLU\\\").val(\\\"#autoSearchLU\\\").focus();\"></span></div><div id=\"searchResult\" style=\"display:none;\">Search Results</div><div id=\"OptionResult\" style=\"display:none;\">Options</div><div id=\"recentItems1\">Recent Items</div><div id=\"itemRes1\"></div> </div>");
		}
//alert(1);
	$(".lookupIcon").each(function(event1){
		try{
		//stopProp1(event1);
		var firstA=$(this).parents("a:first");
		var h1=firstA.attr("href"); 
		h1=$.trim(unescape(h1));
		//alert(h1);
		if(h1.length>25 && h1.indexOf("javascript: openLookup(")>-1 ){ 
			var lnk=h1.substring(23,h1.length-1);
			var inp1=firstA.parents(".lookupInput:first").find("input:first");
			if(!firstA.hasClass("inpSt_pricebookentryid")&& (skiplookupCLass=="" ||!firstA.hasClass(skiplookupCLass))){
			//$.globalEval("globalLInkTrans1="+lnk+";");
			//var lnk1=globalLInkTrans1;//.replace("LookupPage","LookupResultsFrame");
			//latInputLU1Link=lnk1;
			//var newOnclick="openWindowZP('"+lnk1+"','"+firstA.attr("title").replace("(New Window)","")+"');return false;";
			
			var newOnclick="openSearchLUDL('"+(firstA.attr("title").replace("(New Window)",""))+"',this,"+lnk+");return false;";//lnk1
			
			
			//alert(globalLInkTrans1);
			firstA.attr("href","javascript:void(0);");
			firstA.data("inp",inp1);
			
			firstA.attr("onclick",newOnclick);
			
			inp1.data("inp",inp1);
			
			
			//firstA.remove();
			
			if(isMobileRSMode())inp1.attr("onclick",newOnclick);//newOnclick
			
			//openSearchLUDL((firstA.attr("title").replace("(New Window)","")),this,lnk1);
			}else{
				inp1.attr("onclick",h1);//newOnclick
			}

		}
	}catch(e){
	//alert(e);
	}
	});
	
	
	
	$("a>.comboboxIcon").each(function(){
		try{
		var firstA=$(this).parents("a:first");
		var h1=firstA.attr("href"); 
		h1=$.trim(unescape(h1));
		//alert(h1);
		if(h1.length>27 && h1.indexOf("javascript:openPopupFocus(")>-1){ 
			var lnk=h1.substring(27,h1.length-1);
			lnk=lnk.substring(0,lnk.indexOf("'"));
			$.globalEval("globalLInkTrans2='"+lnk+"';");
			var lnk1=globalLInkTrans1;
			lnk1=(firstA.attr("id")==null  || firstA.attr("id")==""?firstA.attr("name"):firstA.attr("id"))
			var inp1=null;
			if(firstA.hasClass("mZPFormInlineMFLD")){
				inp1=firstA.parents("div:first").find("input:first");
			}else{
				inp1=firstA.parents("td:first").find("input:first");
			}
			var newOnclick="openSearchLUDL2('"+($(this).attr("title").replace("(New Window)",""))+"',this,'"+lnk1+"');return false;";
			
			
			//alert(globalLInkTrans1);
			firstA.attr("href","javascript:void(0);");
			firstA.data("inp",inp1);
			firstA.attr("onclick",newOnclick);
			
			inp1.data("inp",inp1);
			
			//inp1.attr("onclick",newOnclick);

		}
	}catch(e){
	alert(e);
	}
	});
	
	
	}
	
}

/*********** zp lookup zintext*****************/


var lastIDClicked=null;
var lastFieldClicked=null;
var massInlineERowClick=false;
function inlineEdiZP(obj,e){
	//
	//alert(noticeUnsaveCancelWork());
	if(NOT_hideEditButton=="true"){
	
		if(e!=null && e.target!=null){
			try{
				var o1=$(e.target);
				//alert(e.target.tagName);
				var td=(e.target.tagName.toLowerCase()=="td"?$(e.target):o1.parents("td:first"))
				lastFieldClicked=td.attr("fld");
				lastIDClicked=$(obj).find(".lcbX:first").attr("rid");
				//alert(lastFieldClicked+" "+lastIDClicked);	
				
				disableTextSel1();
        
			}catch(e){
			//alert(e);
			}
		}
		
		loadingSH();filpEditModeJS();
	}
	
	/*
	massInlineERowClick=true;
	if(noticeUnsaveCancelWork()){
	
	
	
		$(".lcbX input:checked").prop("checked","");

		var markedTR=$("#mainTBX1 tr.markedRowTA");//edit mode
		if(markedTR.length>0){
			markedTR.removeClass("markedRowTA");
		}
		var tr1=$(obj).addClass("markedRowTA");//.parents("tr:first")
		tr1.find(".lcbX input").click();
		
		openMassUpdate("3");
	}
	*/
}

function disableTextSel1(){
			if (window.getSelection)
		        window.getSelection().removeAllRanges();
		    else if (document.selection)
		        document.selection.empty()
}

    var allCheckedMassUpdate=false;
    var openMassUpdate_lastopMode=null;
    
  function openMassUpdate(opMode){
  	trackEventX('openMassUpdate');
  	/*if($(".lcbX input:checked").length==0 ){
  		alert(Please_select_at_least_one_row); 
  		return;
  	}*/
   	openMassUpdate_lastopMode=opMode;
    var massDups=(opMode!=null && opMode=="2");
    var massInlineERow=(opMode!=null && opMode=="3");
    
   if($(".lcbX input:checked").length==0 ){
            cbAll($("input.lcbXAll").prop("checked","checked")[0]);
            allCheckedMassUpdate=true;
            /*if(confirm("No rows were selected, do you want to use them all?")){
                
            }else{
                return;
            }*/
        }
        
        //alert($( "#massUpdate" ).height());
        var massUpdateHeight=$( "#massUpdate" ).height()+50;
        if(massUpdateHeight<100){
            massUpdateHeight=massUpdateFieldToUpdate_size*26+300;
        }

        //alert($(self).height()+" "+$(window).height()+" "+$( "#massUpdate" ).height()+ "+++"+massUpdateHeight);
        lastHeightBodyMU=$("html,body").height();
         if($("html,body").height()<massUpdateHeight){
              //$("html,body").height(massUpdateHeight);
              $("#padBut1").height(Math.max($("#padBut1").height(),massUpdateHeight-$("html,body").height()));
                        //fixIfmHegt();
         }
        
        if(massUpdateHeight>$(self).height()){
            lastHeightBMU=$(self).height();
            //$(self).height(massUpdateHeight); 
            $("#padBut1").height(Math.max($("#padBut1").height(),massUpdateHeight-$(self).height()));
            //fixIfmHegt();
        }
        var scrollTopx=$(self).scrollTop();
        var top1=scrollTopx +(($(self).height()>850?850:$(self).height())-massUpdateHeight)/2;
        var chartst=$("#topGraphs").position().top+$("#topGraphs").height();
        if(chartst!=null  && top1<chartst){
        	top1=chartst+50;
        }
        if(top1<0 || top1 < scrollTopx+(scrollTopx>0?75:0)){
            top1=scrollTopx+(scrollTopx>0?75:0);
        }
        var left1= getCUrrScollLeft()+($(self).width()-$( "#massUpdate" ).width())/2;
        if(left1<0){
            left1=0;
        }
        
        if(massDups){
            
            $(".massUp1").hide();
            $(".massEdit1").hide();
            $(".massDup1").show();
            $(".massUpdateGearBtn").hide();
            
        }else if(massInlineERow){
        	 $(".massDup1").hide();
            $(".massUp1").hide();
            $(".massEdit1").show();
            $(".massUpdateGearBtn").show();
        }else{
            $(".massDup1").hide();
            $(".massEdit1").hide();
            $(".massUp1").show();
            $(".massUpdateGearBtn").show(); 
        }
        
        $( "#massUpdate" ).css({top:top1+"px",left:left1+"px"});
        $( "#massUpdate" ).show();
        
        fixIfmHegt();
        

        // $( "#massUpdate")[0].scrollIntoView(true);
    $( "#massUpdate .dateFormat a" ).each(function(){
        if($(this).attr("href")!=null && $(this).attr("href").indexOf("DatePicker.")>=0){
        //  $(this).attr("onfocus","");
        //  $(this).css("width","auto");
        $(this).click(function(){
            $(this).parents("tr:first").find("input[type=text]").click();;//datepicker
            });
        }
    });
    
   
    }
              
function isOneMUOptSelected(){
    var res1=$(".CBMU1:checked").length>0;
    if(!res1){
        alert("Please select at least one field to update.");
    }
    return res1;
}

function btnMassUodate(update,hideAlert){
    var res1=isOneMUOptSelected();
    if(res1){
    	var checkedLength=$(".lcbX input:checked").length;
    		if(licenseStatus!='Active' && licenseStatus!='ActiveP' &&(checkedLength>50 || getStoredNumPPL("btnMassUodate")>7)){ 
				licenseReqMessage("During the free trial the mass-update options are limited to 50 rows per shot / 7 shots in total."); 
				return; 
			} 
            if(!update || (hideAlert!=null && checkedLength==1 )|| confirm("Are you sure you want to update "+checkedLength+" selected row(s)?")){
        	if(hideAlert==null){
        		lastMassFunctionBtnCall='openMassUpdate()';
        	}else if(hideAlert!=null && checkedLength==1 && update ){//in edit row mode
            	lastMassFunctionBtnCall='inlineEdiZP($(".lcbX input:checked").parents("tr:first"))';
            }
            
            loadingSH();
			scrollTop1();
            if(update){
            	if(checkedLength<=massActionsDefBatchSize){
                massUpdateRowsNSave(update);
                }else{
                	//alert("mass update selected async");
                	//openAllmassActionAll(massActionAllProgTexts,runFunctionOnIdsMassActionAll,runFunctionOnIdsMaxRowsAll)
                	openAllmassActionAll("Starting to mass update the selected rows...#Stop#Stopping...#Current Progress: #Complete!#Close#Are you sure?\n\nThis is the second and last confirm for Mass Update the selected rows!#Mass Update Selected Rows",updateRowsInMassUpdateAsync,massActionsDefBatchSize,true);
                	
                }
            }else{
                massUpdateRows(update);
            }
            $("#massUpdate").hide();
            mucloseFix();
        }
    }
    return res1;
}

function btnMassDuplicate(massDupAll,obj){
    lastMassFunctionBtnCall='openMassUpdate(2)';
	var checkedLength=(massDupAll?totalCountAjx:$(".lcbX input:checked").length);
    var res1=true;//isOneMUOptSelected();
    if(res1 && checkedLength>0){
    	var DBsubQeryToUse='SELECT max(id) mid '+DBsubQery;
        Visualforce.remoting.Manager.invokeAction(
                remoteQueryAjax2,
                DBsubQeryToUse,
                function(result, event){
                	//alert(event.type+"\n "+event.status +" \n"+result+"\n"+result.length+"\n"+result[0]+"\n");
                    if (event.status && result!=null) {
    					if(result!=null && result.length>0 && result[0].mid!=''){
                        	//alert(result[0].mid);
                        	startMassCloneWithMaxID(massDupAll,result[0].mid,checkedLength,obj);
                        }
                    
                     } else if (event.type === 'exception') {
                        if(event.message!=null && ((event.message+"").indexOf("Logged in")>-1 || (event.message+"").indexOf("Refresh page")>-1)){
                            self.location=self.location;
                        }else if(event.message!=null && (event.message+"").indexOf("Unable to connect")==-1){
                            if($("body:visible").length>0)alert("An error has occurred: "+event.message);
                        }
                    } else {
                        //self.location=self.location;
                        // $("#"+filterIdSpan+" .availVals").html("");
                        //lastMassFunctionBtnCall=null;
                        	//searchChanged(1);
                    }
                }, 
                {escape: true,buffer:true,timeout: 90000}
            );
    }
    if(checkedLength==0){
    	alert("Please select at least row!");
    }
    return res1;
}
function startMassCloneWithMaxID(massDupAll,maxId,checkedLength,obj){
	
    	if(licenseStatus!='Active' && licenseStatus!='ActiveP' &&(checkedLength>10 || getStoredNumPPL("btnMassDuplicate")>7)){ 
				licenseReqMessage("During the free trial the mass-clone option is limited to 10 rows per shot / 7 shots in total."); 
				return; 
			} 
       	 if(confirm("Are you sure you want to clone "+(!massDupAll? checkedLength+" selected":"All ("+totalCountAjx+") the")+" row(s)?")){
         
             if(obj!=null){
                $(obj).tooltip('close');
            }   
            
            if(massDupAll){
                //massDuplicateRows();
                openAllmassActionAll("Starting Mass Clone...#Stop#Stopping...#Current Progress: #Complete!#Close#Are you sure?\n\nThis is the second and last confirm for MASS CLONE ALL!#Mass Clone All Rows",massCloneAsync,massActionsDefBatchSize,false,maxId);//
                
            }else{
            	
            	openAllmassActionAll("Starting Mass Clone...#Stop#Stopping...#Current Progress: #Complete!#Close#Are you sure?\n\nThis is the second and last confirm for MASS CLONE Selected!#Mass Clone Selected Rows",massCloneAsync,massActionsDefBatchSize,true,maxId);//selected mode-true
            
                //massDuplicateRowsRegular();
            }
            $("#massUpdate").hide();
            mucloseFix();
        }else{
             if(obj!=null){
                $(obj).tooltip('close');
            }
        }
}
function massCloneAsync(ids){
	massDuplicateRowsRegular(ids);
}
function massCloneDone(){
	messageCellMActionALL=($(".messageCell").length>0?$.trim($(".messageCell").text()):"");
	//alert('+++'+messageCellMActionALL+'+++'); 
	doAllmassActionAll("1"); 
	hideSuccess();
}

function searchChanged(milisWait){
        isSearchFocus1=true;
        searchTBX1(milisWait);
}

function revertOldValsMU(){
	    	$("#massUpdatein1 .muf1 input[oldVal],#massUpdatein1 .muf1 select[oldVal],#massUpdatein1 .muf1 textarea[oldVal]").each(function(){
	    				var oldVal=$(this).attr("oldVal");
	    				if(this.tagName.toLowerCase()=="input" && $(this).attr("type").toLowerCase()=="checkbox"){
	    					$(this).prop("checked",oldVal);
	    				}else{
	    					$(this).val(oldVal);
	    				}
                 		
                 		$(this).removeAttr("oldVal");
                 	});
}
   function massUpdateAllRows(){
   
  	 if(licenseStatus!='Active' && licenseStatus!='ActiveP' &&(totalCountAjx>50 || getStoredNumPPL("btnMassUodate")>7)){ 
				licenseReqMessage("During the free trial the mass-update options are limited to 50 rows per shot / 7 shots in total."); 
				return; 
		} 
			
   		markCheckedRows=false;
     	//lastMassFunctionBtnCall='openMassUpdate()';
        var res1=isOneMUOptSelected();
        if(massUpdateProgTextsArr==null){
			massUpdateProgTextsArr=massUpdateProgTexts.split("#");
		}else if(totalCountAjx<=0){
         	alert(mass_update_0_rows);
         }
        				//Are you sure you want to update all the rows
         if(totalCountAjx>0 && res1 && confirm(massUpdateProgTextsArr[6]+" ("+totRowsForFOUNDONQ+")?")){
			 clearcheckBoxes();
             loadingSH();
             $("#massUpdate").hide();
             mucloseFix();
             openAllMassUpdate();
         }
     }
     function closeMassupdate(){
	     if(allCheckedMassUpdate){cbAll($('input.lcbXAll').prop('checked','')[0]); allCheckedMassUpdate=false;}
	     $('#massUpdate').hide();
	     if($("#massUpdatein1").find(".errorMsg:first").length>0){//remove validations error
	        $("#massUpdatein1").find("input[type='text']").val("");
	     }
	     revertOldValsMU();
	     
	     mucloseFix();
	     fixIfmHegt();
	     var markedTR=$("#mainTBX1 tr.markedRowTA");//edit mode
	     if(markedTR.length>0){
	         markedTR.find(".lcbX input:checked").prop("checked","");
	         markedTR.removeClass("markedRowTA",1500,function(){});
	     }
     }
     function mucloseFix(){
	     if(lastHeightBMU!=null){
	        //$(self).height(lastHeightBMU);
	        //$("html,body").height(lastHeightBodyMU);
	         $("#padBut1").height(0);
	        lastHeightBMU=null;
	        lastHeightBodyMU=null;
	     }
     }
     var handelAdds1count=0;
  function handelAdds1(html1){//charts are us
  	if( !isSF1()){
  		handelAdds1count++;
  		var currhandelAdds1count=handelAdds1count;
  		//google-visualization-tooltip
			var tooltipOrig=html1.replace("  ","<br/>");//$(this).html();
			var markedSection=null;
			var i1=0;
			$(".graphs svg>g path[stroke-width='6.5']:first, .graphs svg>g>g>g rect[stroke-width='1']:first").each(function(){
				if( markedSection==null){
					markedSection=this;
				}
				i1++;
			});
			if( markedSection==null){
				markedSection=$(".graphs svg>g ellipse[stroke-width='1']");
			}
			//alert($(markedSection).length);
			if($(markedSection).length>0 ){
			
				
				var path1=$(markedSection);//$(markedSection).find("path:last");
				var d1=(path1.attr("d")+"").split(/[a-z\,\ ]+/ig);
				var h1=(path1.attr("height")+"");
				//alert(h1);
				var my1='bottom',at1='top';
				if(Number(d1[2])<Number(d1[4])){//bottom
					my1="top";
					at1="bottom";
				}
				if(isNaN(h1)){
					my1="center";
					at1="center";
				}
				//alert(Number(d1[3])+" "+(Number(d1[8])-Number(d1[3]))+" "+path1.attr("d"));
				if(Number(d1[3])>Number(d1[8])-Number(d1[3])){//right side
					my1="right "+my1;
					at1="left "+at1;
				}else{
					my1="left "+my1;
					at1="right "+at1;
				}
				path1.qtip({
				    content: {
				        text: tooltipOrig,
				        button:true
				    },
				    show: {
				        ready: true,
				        solo: $(".Zstbl1WS"),
				        delay: 100
				        //event: 'mouseenter mouseover'
				    },
				    style: {
				        classes: 'qtip-light qtip-shadow qtip-rounded qtip-brd-gry',   
				         tip: {
				            corner: true,
				            width: 15,
				            height:15
				        }
				    },
				    position: {
				        viewport: $(self),//$(self),
				        container:$(".mZPForm1"),
				       my: my1,
	        		   at: at1,
				      
				    },
				    hide: {
				        fixed: true,
				        delay: 100,
				        event: (!isSF1()?'click ':'')+'mouseleave'
				    },
				    events:{
				       show:function(event, api){
				       	if(currhandelAdds1count!=handelAdds1count || path1.parents(".graphs:first").length==0){
				       		 event.preventDefault();
				       	}
				       }
				    }
				       
				    
				});
			}
  	}
  }               
function tooltipFix(){
if( !isSF1()){

$( "body" ).delegate(".btt1[alnk]", "mouseover", function() {
 
		closeOctrF1O();
        $(".lookupHoverDetail:visible").hide();
        var result="";
        var alnk=$(this).attr("alnk");
        var afld=$(this).attr("afld");
        var objk=$(this).attr("objk");
        var href=$(this).attr("href");
        var textFld=$(this).text();
        if(textFld==null){
        	textFld="";
        }
        if(alnk==null || alnk==undefined){
            alnk="";
        } 

        if(afld=="href" && href!=null && href!="" &&( (href.indexOf("/")>-1 && href.indexOf("http")==0) || href.indexOf("javascript:srcUp(")==0 || (href.indexOf("/")==0 && href.substring(1).match(/[a-zA-Z0-9]{15,20}/)))){
            var href1=href;
            if(href1.indexOf("javascript:srcUp(")>-1){
                    var h2=href1;
                    h2=unescape(h2);
                    h2=h2.split("'")[1];
                    if(h2.indexOf("?isdtp=vw")>-1){
                        h2=h2.substring(0,h2.indexOf("?isdtp=vw"));
                    }
                    if(h2.indexOf("?isdtp=p1")>-1){
                        h2=h2.substring(0,h2.indexOf("?isdtp=p1"));
                    }
                    //alert(href1);
                    href1=h2;
                    var h3=href1;
                    if(h3.indexOf("https://")==0 && h3.indexOf(".com/")>-1){
                    	h3=h3.substring(h3.indexOf(".com/")+4);
                    }
                    $(this).attr("href",h3);
					if(!isSFLight1XV) $(this).attr("onclick",href); 
					afld=href1.substring(href1.indexOf("/",9)+1);
			}else if( href.indexOf("http")==-1 && href.indexOf("/")==0 && href.substring(1).match(/[a-zA-Z0-9]{15,20}/)){//simple ID with /
				afld=href.substring(1);
            }else{
            	afld=href1.substring(href1.indexOf("/",9)+1);
            }
            
            //alert(afld+" " +href);
        }
        if(alnk.indexOf("{0}")>-1){
        	if(alnk.indexOf("/ui/common/MRUHoverLoader")>-1){
        		var afldT=afld;
        		if(afld.length>15){
        			afldT=afldT.substring(0,15);
        		}
        		alnk=alnk.replace(/\{0\}/ig,afldT);//replace all params
        	}else{
            	alnk=alnk.replace(/\{0\}/ig,afld);//replace all params
            }
        }
        if(alnk!=null && alnk!=undefined && alnk!="" && alnk.indexOf("retURL")==-1 && alnk.indexOf("?")>-1){
            alnk=alnk+"&retURL="+escape((window.location+''));
            //alert(alnk);
        }
        //alnk=alnk.replace(/&amp;/ig,'&');
        //alert(alnk);
        var id1=$(this).attr("id");
        if(id1=='' || id1==undefined){
            id1='bbt1X'+curBbt1ID;
            curBbt1ID++;
            $(this).attr("id",id1);
        }
        if(this==LastOpenToolTipObj){
            return $("#"+id1+"D").parent().html();
        }
        try{
          //$(".ui-tooltip:visible").hide();
        }catch(e){}
        LastOpenToolTipObj=this;
        var title=$(this).attr("title");
        //alert(alnk+ " "+ objk);
        if( alnk!='' && alnk!='undefined' && objk=='1'  && alnk!=undefined){
            
            //result="<div id='"+id1+"D' class='bbt1XD' ><div class='bbt1Loading'><"+"script"+">$('.bbt1XD:visible').load('"+alnk+"',fixIfmHegt);<"+"/script"+"></div></div>";
            openQtip1Ajax(this,alnk);
        }else if( alnk!='' && alnk!='undefined' && objk=='0' && alnk!=undefined){
           result="<div id='"+id1+"D' class='bbt1XD'><div class='ir'><img width='280' src='"+alnk+"' onload='$(\".bbt1Loading:visible\").hide();' alt='"+Preview_not_Available+"'/></div><div class='h'><a href='"+alnk+"' target='_blank' class='btn'>"+View_Download+"</a></div></div>";
            setTimeout("$(\".bbt1Loading:visible\").hide();",2000);
            if(textFld.toLowerCase().indexOf("pdf")>-1) result="<div id='"+id1+"D' class='bbt1XD'><div class='ir'><div class='bbt1Loading'></div><object width='300' data='"+alnk+"' standby='Loading...' onload='$(\".bbt1Loading:visible\").hide();'> <div class='fnspt1'>Preview not Available</div> </div><div class='h'><a href='"+alnk+"' target='_blank' class='btn'>"+View_Download+"</a></div> <"+"script"+">setTimeout(\"$('#"+id1+"D').find('.bbt1Loading:first').hide()\",500);<"+"/"+"script"+"></object>";
            openQtip1(this,result);
        }else{
            result=title;
            openQtip1(this,result);
        }


});

/*
$(document).tooltip({ 
   position: { my: "left top", at: "right bottom", collision: "none"},//flipfit
   items:".btt1[alnk]",
    content: function() {
    	closeOctrF1O();
        $(".lookupHoverDetail:visible").hide();
        var result="";
        var alnk=$(this).attr("alnk");
        var afld=$(this).attr("afld");
        var objk=$(this).attr("objk");
        var href=$(this).attr("href");
        var textFld=$(this).text();
        if(textFld==null){
        	textFld="";
        }
        if(alnk==null || alnk==undefined){
            alnk="";
        } 

        if(afld=="href" && href!=null && href!="" &&( (href.indexOf("/")>-1 && href.indexOf("http")==0) || href.indexOf("javascript:srcUp(")==0)){
            var href1=href;
            if(href1.indexOf("javascript:srcUp(")>-1){
                    var h2=href1;
                    h2=unescape(h2);
                    h2=h2.split("'")[1];
                    if(h2.indexOf("?isdtp=vw")>-1){
                        h2=h2.substring(0,h2.indexOf("?isdtp=vw"));
                    }
                    //alert(href1);
                    href1=h2;
            }
            afld=href1.substring(href1.indexOf("/",9)+1);
            //alert(afld);
        }
        if(alnk.indexOf("{0}")>-1){
            alnk=alnk.replace(/\{0\}/ig,afld);//replace all params
        }
        if(alnk!=null && alnk!=undefined && alnk!="" && alnk.indexOf("retURL")==-1 && alnk.indexOf("?")>-1){
            alnk=alnk+"&retURL="+escape((window.location+''));
            //alert(alnk);
        }
        //alnk=alnk.replace(/&amp;/ig,'&');
        //alert(alnk);
        var id1=$(this).attr("id");
        if(id1=='' || id1==undefined){
            id1='bbt1X'+curBbt1ID;
            curBbt1ID++;
            $(this).attr("id",id1);
        }
        if(this==LastOpenToolTipObj){
            return $("#"+id1+"D").parent().html();
        }
        try{
          $(".ui-tooltip:visible").hide();
        }catch(e){}
        LastOpenToolTipObj=this;
        var title=$(this).attr("title");
        //alert(alnk+ " "+ objk);
        if( alnk!='' && alnk!='undefined' && objk=='1'  && alnk!=undefined){
            
            result="<div id='"+id1+"D' class='bbt1XD' ><div class='bbt1Loading'><"+"script"+">$('.bbt1XD:visible').load('"+alnk+"',fixIfmHegt);<"+"/script"+"></div></div>";
        }else if( alnk!='' && alnk!='undefined' && objk=='0' && alnk!=undefined){
           result="<div id='"+id1+"D' class='bbt1XD'><div class='ir'><img width='280' src='"+alnk+"' onload='$(\".bbt1Loading:visible\").hide();' alt='"+Preview_not_Available+"'/></div><div class='h'><a href='"+alnk+"' target='_blank' class='btn'>"+View_Download+"</a></div></div>";
            setTimeout("$(\".bbt1Loading:visible\").hide();",2000);
            //result="<div id='"+id1+"D' class='bbt1XD'><div class='bbt1Loading'></div><object width='300' data='"+alnk+"' standby='Loading...' onload='$(\".bbt1Loading:visible\").hide();'> <div class='fnspt1'>Preview not Available</div><"+"script"+">setTimeout(\"$('#"+id1+"D').find('.bbt1Loading:first').hide()\",500);<"+"/"+"script"+"></object>";
        }else{
            result=title;
        }
        //alert(result);
        
        return result;
    },
    tooltipClass: "alnk-tooltip-styling",
    hide: { effect: "fadeOut",delay:3000, duration: 300 }
    ,open:function(event, ui){
        fixIfmHegt();
    }
    ,close:function(event, ui){
        fixIfmHegt();
    }
   });
   
   */
   }
}                 


function saveView(){
if(!noticeUnsave()){return false;}else{
    if($.trim($(".curSelectedView").val())==""){
        openSaveView();
    }else{
        loadingSH();
        saveViewAF($(".curSelectedView").val(),$(".curSelectedView option:selected").text(),false); 
    }
    }
}

function openSaveView(){
if(!noticeUnsave()){return false;}else{
    
    $("#newViewForm").dialog({
     //    height: (maxHieghtIframe-40),
     //   width: 750,
         modal: openDialogAsMod()
		//,appendTo: ".mZPForm1"
         ,close: function( event, ui ) {
           
            if(lastBodyHeight!=null){
                   //$("html,body").height(lastBodyHeight);
                    $("#padBut1").height(0);
                   fixIfmHegt();
            }
         },
    buttons: [{
    text:Save_File_button,
   click: function() {
        loadingSH();
        saveViewAF('',$("#newViewName:visible").val(),$("#newViewNameCB:visible").is(":checked"),$(".curSelectedView").val());
        //$("#topSaved1").show();
        //setTimeout('$("#topSaved1").hide(500);',1500);
        $( this ).dialog( "close" );
        $("#newViewForm").dialog("destroy");
        $(".searchSelMainOut").remove();
    }},
    {text:Cancel_button,
    click: function() {
        $( this ).dialog( "close" );
        $("#newViewForm").dialog("destroy");
    }
    }]
                                      });
                                      
        }                              
}
function deleteView(){
if(!noticeUnsave()){return false;}else{

if(confirm(Delete_this_view)){
    loadingSH();
    deleteView1x($(".curSelectedView").val());
}
}
}
function showEditAlert1(){
$(".EditAlert1").show();
setTimeout(function(){$(".EditAlert1").hide(1000);},15000);
//$("#save1").css({background:"yellow"});
}

function showSaveAlert(){
$(".SaveAlert1").show().fadeIn();
setTimeout(function(){$(".SaveAlert1").fadeOut();},5500);
$("#save1").css({background:"yellow"});
}


function copyValuesX1(){
	try{
	var checked1=$(".lcbX input:checked"); 
	if(!isEditMode1){ 
	alert("Please switch to edit mode before using this button"); 
	}else if(checked1.length==0){ 
	alert("Please select at least one row"); 
	}else{ 
	var ix1=1; 
	if($(".topCNum").length==0){ 
	$("th.thw").each(function(){ 
	if(ix1>0){ 
	$(this).append("<div style='position:relative;' class='topCNum'><div style='position:absolute;top:-50px;border:1px solid #333333;background:#efefef;padding:5px;'>"+ix1+"</div></div>"); 
	} 
	ix1++; 
	}); 
	}else{ 
	$(".topCNum").show(); 
	} 
	setTimeout(function(){
	try{
	var col2= prompt("Copy Column #:", 2); 
	if(col2!=null){ 
	var col1= prompt("Copy Column #"+col2+" into column #:", 1); 
	col1=new Number(col1)+2; 
	col2=new Number(col2)+2; 
	//alert(col1); 
	$(".lcbX input:checked").each(function(){ 
	var firstTr=$(this).parents("tr:first"); 
	var cVal=""; 
	var cFrom=firstTr.find("td:nth-child("+col2+")").find("input:visible, textarea:visible, select:visible"); 
	if(cFrom.length==0){ 
	cVal=firstTr.find("td:nth-child("+col2+")").text();
	 //alert(cVal+"_1");
	}else{ 
	cVal=cFrom.val(); 
	//alert(cVal+"_2");
	} 
	firstTr.find("td:nth-child("+col1+")").find("input:visible ,textarea:visible, select:visible").val(cVal).focus().click(); 
	
	//alert(cVal); 
	}); 
	} 
	}catch(e){}
	$(".topCNum").hide();
	},250);
	} 
	}catch(e){}
	
}
  
//var massUpdateProgTexts="Starting Mass Update...#Stop#Stopping...#Current Progress: #Complete!#Close#Are you sure you want to update all the rows";
var massUpdateProgTextsArr=null;
var openAllMassUpdateLastID='';
 var progressbarMU = null,
      progressLabel = null;
var stopMassUpdateAll=false;
var stopMassUpdateAllError=false; 
function reoloadAfterMUALLROWS(){
	 finishMUALLROW($('.seatchInptFZP:first').val());
}     
function openAllMassUpdate(){ 
	progressbarMU=null;
	progressLabel=null;
	openAllMassUpdateLastID='';
	lastBtachSizeDone=0;
	stopMassUpdateAll=false;
	stopMassUpdateAllError=false;
	$("#massUpdateAllDialog").remove();											//Starting Mass Update...
	$("body").append("<div id='massUpdateAllDialog'><div class='progress-label'>"+massUpdateProgTextsArr[0]+"</div><div id='progressbarMU' style='margin-top:15px;'></div></div>");
	progressLabel = $( ".progress-label" );
	progressbarMU = $( "#progressbarMU" );
	var massUpdateAllDialog=$("#massUpdateAllDialog").dialog({
            resizable: true,
            //height:500,
            width:(isSF1()?($(self).width()-20):500),
            modal: openDialogAsMod(),
            title: Mass_Update_all_items,
            buttons: [{
            text:massUpdateProgTextsArr[1], //stop
            click: function() {
               stopMassUpdateAll=true;
                massUpdateAllDialog.dialog( {"buttons":[{
			          text: massUpdateProgTextsArr[2], //Stopping...#
			          click: function(){
			          //$( this ).dialog( "close" );
			          }
			        }]});
            }}]
            ,
            open: function() {
         		 //progressTimer = setTimeout( progress, 2000 );
         		 progressbarMU.progressbar({
			      value: false,
			      max:totalCountAjx,
			      change: function() {
			      	var val1=progressbarMU.progressbar( "value" );
			      	if(val1==null){val1=0;}
			      						//"Current Progress: " 
			        progressLabel.html( massUpdateProgTextsArr[3] + Math.round((val1/totalCountAjx)*100.0) + "% ("+val1+" / "+totalCountAjx+")" );
			      },
			      complete: function() {
			        progressLabel.text( massUpdateProgTextsArr[4] );//"Complete!"
			        stopMassUpdateAll=true;
			        changeMUBtns();
			        //$(".ui-dialog button:visible").last().focus();
			        lastMassFunctionBtnCall=null;
			        
                      reoloadAfterMUALLROWS();//searchChanged(1);
			      }
			    });
 				if(!stopMassUpdateAll)doAllMassUpdate();
       		},
             close: function( event, ui ) {
             	$( this ).dialog( "close" );
             }
            });
            
}
function changeMUBtns(){
	$("#massUpdateAllDialog").dialog( {"buttons":[{
			          text: massUpdateProgTextsArr[5], //"Close"
			          click: function(){
			          $( this ).dialog( "close" );
			          } 
			        }]});
}
var msgMassUpdateAllRows="";
var messageCell="";;
var lastBtachSizeDone=0;
function doAllMassUpdate(done){

	msgMassUpdateAllRows=$.trim($(".msgMassUpdateAllRowsID").html());
	//alert("msgMassUpdateAllRows:" + msgMassUpdateAllRows+" " +done);
	
	
	messageCell=($(".messageCell").length>0?$.trim($(".messageCell").text()):"");
	if(done!=null){
		if((msgMassUpdateAllRows!=null && msgMassUpdateAllRows!="") || (messageCell!=null && messageCell!="")){
			//alert(messageCell);
			if(messageCell!=null ){
				//alert(messageCell);
				
				$("#massUpdateAllDialog").remove();
				fixOnload();
				openMassUpdate();
				stopMassUpdateAllError=true;
				
			}else{
				//fixMultiDependancefield();
				//alert(msgMassUpdateAllRows);
			}
			if(msgMassUpdateAllRows!=null && msgMassUpdateAllRows!="") alert(msgMassUpdateAllRows);//to see the IDS
			
		}else{
		
			//stopMassUpdateAll=true;
			var val = progressbarMU.progressbar( "value" );
			if(val==null || val==false){
				val=0;
			}
			//alert(val+" "+lastBtachSizeDone+" "+totalCountAjx);
 			progressbarMU.progressbar( "value", (val + lastBtachSizeDone) );
 			if((val + lastBtachSizeDone) >= totalCountAjx){
 				stopMassUpdateAll=true;
 				//alert(1);
 			}
 			
 		}
	}
	if(stopMassUpdateAllError){
		return;
	}
	if(stopMassUpdateAll){
		changeMUBtns();
		//massUpdateAllDialog.dialog("close"); 
		 //searchChanged(1);
		 reoloadAfterMUALLROWS();
		return;
	}
	lastBtachSizeDone=0;
	//alert("openAllMassUpdateLastID: "+openAllMassUpdateLastID);
	$('.message.errorM3').remove();currePlacex1RedErrors="";
	Visualforce.remoting.Manager.invokeAction(
                remotequeryAjax2GetIDSX,
                DBsubQery,
                openAllMassUpdateLastID, 
                massActionsDefBatchSize, //200
                DB_END_ALLROWS_Qery,
                function(result, event){
                	//alert(event.type+"\n "+event.status +" \n"+result+"\n"+result.length+"\n"+result[0]+"\n");
                    if (event.status && result!=null) {
    					if(result!=null && result.length>0 && !stopMassUpdateAll){
                        	openAllMassUpdateLastID=result[result.length-1];
                        	var toUpdate=result.join(";");
                        	//alert((result+'').length+' ' +openAllMassUpdateLastID);
                        	lastBtachSizeDone=result.length;
                        	
 							massUpdateALLRowsAF(toUpdate);//doAllMassUpdate('1'); 
                        }else if(result!=null && result.length==0 && !stopMassUpdateAll){//no result then products where changed during the proccess > done
                        	var CurNum = Number(progressbarMU.progressbar( "value" ));
                        	lastBtachSizeDone=totalCountAjx-CurNum;
                        	stopMassUpdateAll=true;
                        	doAllMassUpdate('1'); 
                        }else{
                        	//lastBtachSizeDone=0;
                        	//openAllMassUpdateLastID='';
                        	//doAllMassUpdate('1');
                        	if(stopMassUpdateAll){
                        		changeMUBtns();
                        	}
                        }
                    
                     } else if (event.type === 'exception') {
                        if(event.message!=null && ((event.message+"").indexOf("Logged in")>-1 || (event.message+"").indexOf("Refresh page")>-1)){
                            self.location=self.location;
                        }else if(event.message!=null && (event.message+"").indexOf("Unable to connect")==-1){
                            if($("body:visible").length>0)alert("An error has occurred: "+event.message);
                        }
                    } else {
                        //self.location=self.location;
                        // $("#"+filterIdSpan+" .availVals").html("");
                        //lastMassFunctionBtnCall=null;
                        	//searchChanged(1);
                    }
                }, 
                {escape: true,buffer:true,timeout: 90000}
            );
            
}
function closeAllTooltips(){
	//$(".ui-tooltip:visible").hide();
	if(lastQtip1!=null){
		lastQtip1.qtip("hide");
		lastQtip1=null;
	}
}
function getLabel(str,func1){
	Visualforce.remoting.Manager.invokeAction(
            remoteGetCustomLabel,
            str, 
            function(result, event){
                if (event.status && result!=null) {
                	//alert("XXX"+result+"XXX");
                	func1(result);
                	
                } else if (event.type === 'exception') {
                	 if(event.message!=null && ((event.message+"").indexOf("Logged in")>-1 || (event.message+"").indexOf("Refresh page")>-1)){
                            self.location=self.location;
                     }else if(event.message!=null && (event.message+"").indexOf("Unable to conn")==-1){
                		if($("body:visible").length>0)alert("An error has occurred: "+event.message);
                	}

                } else {
 
                }

            }, 
            {escape: false,buffer:true,timeout: 90000}
        );
}

function getGenSetting(str,func1){

var queryZZZ="SELECT Id,Name,field1__c,field2__c,field3__c FROM zaapit_general_settings__c where name='"+str+"' order by name asc"; 
Visualforce.remoting.Manager.invokeAction(
                remoteQueryAjax2,
                queryZZZ, 
                function(result, event){
                //alert(event.status + " "+event.type +" "+ result.length);
                    if (event.status && result!=null && result.length>0) {
    					var res=checkNull(result[0].field1__c)+checkNull(result[0].field2__c)+checkNull(result[0].field3__c);
                    	func1(res);
                     } else if (event.type === 'exception') {
                        if(event.message!=null && ((event.message+"").indexOf("Logged in")>-1 || (event.message+"").indexOf("Refresh page")>-1)){
                            self.location=self.location;
                        }else if(event.message!=null && (event.message+"").indexOf("Unable to connect")==-1){
                            if($("body:visible").length>0)alert("An error has occurred: "+event.message);
                        }
                    } else {
                        //self.location=self.location;
                        // $("#"+filterIdSpan+" .availVals").html("");
                        //alert(1);
                    }
                }, 
                {escape: true,buffer:false,timeout: 90000}
            );
}
function checkNull(str){
	return (str==null?"":str);
}

var guideInAction=0;
var guideMeLabel=null;
var guideMeStr=null;//JQ selector~~~title~~~text/html to display~~~prev button name~~~next button name###next guide...
var lastGuidesel1=null;
function guideMe(str,startPos){

if($(window).width()<700){
		alert("This guide is not available on mobile devices");
			return;
}
	guideInAction=1;
	try{
	if(str!=null){
		//guideMeStr=str;
			guideMeLabel=str;
		    getLabel(str,function(result){
		    	guideMeStr=result;
				   guideMe(null,startPos); 
		    });
	}else{
		var guides=guideMeStr.split("###");
		var guide1=guides[Math.min(Math.max(0,startPos),guides.length-1)].split("~~~");
		var sel1=guide1[0],title1=guide1[1], html1=guide1[2],prevTxt=guide1[3],nextBTxt=guide1[4];
		if(startPos>=0 && guides.length-1>=startPos && $(sel1).length==0){
		// element not found
			guideInAction=0;
			getLabel("follow_instruction_guide",function(result){
		    	alert(result);
		    });
		}else if(startPos>=0 && guides.length-1>=startPos){
			lastGuidesel1=sel1;
			//if($.trim(guide1[0])!=""){
			//	$(guide1[0]).click();
			//}
			var nextSec=html1+"<br/>"+"<span style='float:left;margin-top:10px;margin-right:10px;'>"+$(".powerByX").html()+"</span><span style='float:right;'>"+
			(startPos==0 && guideMeLabel=="welcome_guide_me"?"<button onclick='rmLS1(\"welcome_guide_me\");guideMe(null,-1);' class='btn' type='button'>"+Later_label+"</button>":"")+
			($.trim(prevTxt)!="-"?"<button onclick='guideMe(null,"+(-1)+")' class='btn' type='button'>"+prevTxt+"</button>":"")+
			($.trim(nextBTxt)!="-"?"<button onclick='guideMe(null,"+(startPos+1)+")' class='btn' type='button'>"+nextBTxt+"</button>":"")+"</span>";
			//openQtip1(sel1,nextSec,"top center","bottom center",null,"1",false);
			
			var pos1=(sel1=="body"?{"top":0,"left":0}:$(sel1).position());
			var bodyx=$("body,html");
			var bw=bodyx.width();
			var bh=bodyx.width();
			var at1=(Number(pos1.left)<Number(bw)/2?"right top":"left top")+" "+(Number(pos1.top)<Number(bh)/2?"top":"bottom");
			var my1=(Number(pos1.left)>=Number(bw)/2?"right bottom":"left bottom")+" "+(Number(pos1.top)>=Number(bh)/2?"top":"bottom");
			 $("html, body").animate({ scrollTop: Math.max(0,Number(pos1.top)-bh/3),scrollLeft: Math.max(0,Number(pos1.left) -bw/3)}, "fast",function(){
			 
			 $(sel1).qtip({
				zindex:20005,
			    content: {
			        text: nextSec,
			        title:title1,
			        button: true
			    },
			    show: {
			        ready: true,
			        solo: $("#guideHolders1"),
			        modal:false
			    },
			    style: {
			        classes: 'qtip-cream qtip-shadow qtip-rounded qtip-brd-guide',   
			         tip: {
			            corner: (sel1!="body"),
			            width: 15,
			            height:15
			        }
			    },
			    position: {
			        viewport: $(self),//$(self),
			        container:$("#guideHolders1"),
			        my: (sel1!="body"?my1:"center"),  // Position my top left...
			        at: (sel1!="body"?at1:"center"), // at the bottom right of...
			        target: (sel1!="body"?$(sel1):$(".btnBox")) // my target
			    },
			    hide: {
			        fixed: true,
			        delay: 500,
			        event: false
			    },events:{
					hide: function(event, api) {
			            guideInAction=0;
			        },
			    	show:function(event, api){
			    		if(guideInAction!=1){
			    			stopProp1(event);
			    		}
			    	}
			    }
	
			});
			 
			 });
			

		}else{
			$(sel1).qtip().hide();
			if(lastGuidesel1!=null){
				$(lastGuidesel1).qtip().hide();
			}
			guideInAction=0;
		}
	}
	}catch(e){alert(e);}
}

function collapseExpAll(obj){
	reCloseGroups=1;
	var collapse1=$(obj).hasClass("ui-icon-triangle-1-s");
	if(collapse1){//to collpas
		$(obj).removeClass("ui-icon-triangle-1-s");
		$(obj).addClass("ui-icon-triangle-1-e");
		$(".uiColps.ui-icon-triangle-1-s[grp]").click();
	}else{
		$(obj).addClass("ui-icon-triangle-1-s");
		$(obj).removeClass("ui-icon-triangle-1-e");
		$(".uiColps.ui-icon-triangle-1-e[grp]").click();
	}
	reCloseGroups=0;
	savedGroups1();
}
function collapseExp(obj){
	$(".secTB1,.secTHW1").remove();//remove freezecolumns to recreate them...
	$(obj).disableSelection();
	
	var collapse1=$(obj).hasClass("ui-icon-triangle-1-s");
	var tr1=$(obj).parents("tr:first");//rowGrouping1
	var level=(tr1.hasClass("lev1")?1:2);
	var next1=tr1.next();
	var count1=0;
	if(collapse1){//to collpase
		$(obj).removeClass("ui-icon-triangle-1-s");
		$(obj).addClass("ui-icon-triangle-1-e");
		while(next1!=null && ( (level==1 && (next1.hasClass("lev2") || next1.hasClass("dataRow"))) || (level==2  && next1.hasClass("dataRow" )))){
			count1++;
			next1.hide();
			if(level==1 && next1.hasClass("lev2") && next1.find(".ui-icon-triangle-1-e").length>0){//if level 2 is closed change icon to "open"
				var nextClosed=next1.find(".ui-icon-triangle-1-e");
				nextClosed.addClass("ui-icon-triangle-1-s");
				nextClosed.removeClass("ui-icon-triangle-1-e");
			}
			next1=next1.next();
		}
		
	}else{
		$(obj).addClass("ui-icon-triangle-1-s");
		$(obj).removeClass("ui-icon-triangle-1-e");
		while(next1!=null && ( (level==1 && (next1.hasClass("lev2") || next1.hasClass("dataRow"))) || (level==2  && next1.hasClass("dataRow" )))){
			count1++;
			next1.show();
			next1=next1.next();
		}
	}
	//tr1.find(".count1").html("("+count1+")");
	
	savedGroups1();
}

function collapseFilterSF1(obj){
	$(obj).disableSelection();
	var collapse1=$(obj).hasClass("ui-icon-triangle-1-s");
	var th1=$(obj).parents("th:first");//rowGrouping1
	var next1=th1.next().next();
	var count1=0;
	if(collapse1){//to collpase
		$(obj).removeClass("ui-icon-triangle-1-s");
		$(obj).addClass("ui-icon-triangle-1-e");
		while(next1!=null && next1.attr("gnz")!=null){
			count1++;
			next1.hide();
			next1=next1.next();
		}
		
	}else{
		$(obj).addClass("ui-icon-triangle-1-s");
		$(obj).removeClass("ui-icon-triangle-1-e");
		while(next1!=null && next1.attr("gnz")!=null){
			count1++;
			next1.css({"display":"block"});
			next1=next1.next();
		}
	}
	//tr1.find(".count1").html("("+count1+")");
	
}

function rmLS1(str){
	try{
		localStorage.removeItem(str); 
	}catch(e){}
}

function getLS1(str){
	var val="X";
	try{
		val=localStorage.getItem(str); 
	}catch(e){}
	return val;
}
function setLS1(str,val){
	try{
		val=localStorage.setItem(str,val); 
	}catch(e){}
}
function getLastSavedGroupsName(){
	return UrlEnd1+tp_conf+"~"+(mainViewIDTemp!=""?mainViewIDTemp:mainViewID)+"~"+sortByFieldforColor+"~"+currPageCls+new Date().toLocaleDateString(); 
}
var reCloseGroups=0;
function savedGroups1(){
   	if(reCloseGroups==0){
   		var saveGroups="";
   		$(".uiColps.ui-icon-triangle-1-e").each(function(){//closed
   			var grp=$(this).attr("grp");
   			saveGroups+="~"+grp;
   		});
   		if(saveGroups!=""){
   			setLS1(getLastSavedGroupsName(),saveGroups.substring(1));
   		}else{
   			rmLS1(getLastSavedGroupsName());
   		}
   		
   	}
}
function reloadLastSavedGroups(){
   		var groups=getLS1(getLastSavedGroupsName());
   		//alert(groups);
   		if(groups!=null && groups!="" && groups!="X"){
   		   	reCloseGroups=1;
   			var sel1=".uiColps.ui-icon-triangle-1-s[grp='"+(groups.replace(/~/ig,"'],.uiColps.ui-icon-triangle-1-s[grp='"))+"']";
   			//alert(sel1);
   			$(sel1).click();		
   			reCloseGroups=0;
   			rmLS1(getLastSavedGroupsName());
   		}
}
var isQuickSaveLast=false;
function onSave1(isQuickSave){
	
	//remove shorot hadashot bli bedika
	var okToSave=true;
	var count1=0;
	var error_enter_valueX=error_enter_value.split("#");
	var errorMessage='<div class="errorMsg errorMsgX"><strong>'+error_enter_valueX[0]+'</strong>'+error_enter_valueX[1]+'</div>';
	var errorMessageG='<div class="message errorM3" role="alert"><table border="0" cellpadding="0" cellspacing="0" class="messageTable" style="padding:0px;margin:0px;"><tbody><tr valign="top"><td><img alt="ERROR" class="msgIcon" src="/s.gif" title="ERROR"></td><td class="messageCell"><div class="messageText"><span  style="color:#cc0000"><h4>'+error_enter_valueX[0]+'</h4></span>'+error_enter_valueX[1]+'<br></div></td></tr><tr><td></td><td></td></tr></tbody></table></div>';
	$(".requiredInput .errorMsg").remove();
	$(".lcbX").each(function(){
		//alert($(this).find(".lcbXRow").is(":checked"));
		if($(this).find(".lcbXRow")!=null && $(this).find(".lcbXRow").is(":checked")){
			var row=$(this).parents("tr.dataRow:first");//.remove();
			row.find(".requiredInput select").each(function(){
				if(($(this).attr("multiple")==null || $(this).attr("multiple")=="") && $(this).val()==""){
					$(this).parents(".requiredInput:first").append(errorMessage);
					okToSave=false;
				}else{
					$(this).parents(".requiredInput:first").find(".errorMsgX").remove();
				
				}
			});
			row.find(".requiredInput input[type='text']").each(function(){
				if($(this).val()==""){
					$(this).parents(".requiredInput:first").append(errorMessage);
					okToSave=false;
				}else{
					$(this).parents(".requiredInput:first").find(".errorMsgX").remove();
				
				}
			});
			
			row.find(".requiredInput textarea").each(function(){
				if($(this).val()==""){
					$(this).parents(".requiredInput:first").append(errorMessage);
					okToSave=false;
				}else{
					$(this).parents(".requiredInput:first").find(".errorMsgX").remove();
				
				}
			});

			count1++;
		}
	});
	
	if(okToSave){
		 loadingSH();
		 if(isQuickSave)isQuickSaveLast=true;
		 saveNow(isQuickSave);
	}else{
		$("span[id*='mainTB1Err']:first").html(errorMessageG);
		fixIfmHegt();
	}
	
	//return okToSave;
	//alert(count1);
	
} 


var copyCellfirstCell=null;
var copyCellFld=null;
var copyCellStarted1=false;
function copyCellStart(obj,e1){
//alert(1);
	$(".copyCellMark").removeClass("copyCellMark");
	copyCellfirstCell=obj;
	$(obj).attr('unselectable', 'on').css('user-select', 'none').on('selectstart', false);
	copyCellStarted1=true;
	copyCellFld=$(obj).attr("fld");
	
	copyCellHOVER($(obj).parents("td.iTd:first,td.CBL:first"),e1);
	stopProp1(e1);
}
function copyCellHOVER(obj,e1){
	//
	//alert(copyCellStarted1+" "+$(obj).hasClass("copyCellMark") +" "+$(obj).hasClass(copyCellFld)+" "+copyCellFld);
	if(copyCellStarted1 && !$(obj).hasClass("copyCellMark") && $(obj).hasClass(copyCellFld)){
		$(obj).addClass("copyCellMark");
	}
	
}
function copyCellEnd(obj,e1){
	//alert(3)
	if(copyCellStarted1){
	
	copyCellStarted1=false;
	var cells=$(".copyCellMark");
	var p1=$(copyCellfirstCell).parents("td.copyCellMark:first");
	var inp=p1.find("input[type='checkbox']:visible");
	if(inp!=null && inp.length==1){
		cells.find("input[type='checkbox']:visible").prop("checked",inp.prop("checked")).change();
	}else{
		inp=p1.find("input:visible");
		try{
		if(inp!=null && inp.length==1){
			cells.find("input:visible").val(inp.val()).change();
		}
		inp=p1.find("select:visible");
		if(inp!=null && inp.length==1){
			cells.find("select:visible").val(inp.val()).change();
		}
		
		inp=p1.find("textarea:visible");
		if(inp!=null && inp.length==1){
			cells.find("textarea:visible").val(inp.val()).change();
		}
		}catch(e1){}
		
	}
	cells.removeClass("copyCellMark");
	}
	
}


function searchAndReplacePopUpF(field){
	//$(".fltIC"+field+":first").click();//close filter
	closeFilterx(); 
	//$("#searchAndReplacePopUp").remove();
	//$("body").append("");
	$("#mainTBX1 tbody td."+field).addClass("marked");
		 $("#searchAndReplacePopUp").dialog({
         modal: false
		//,appendTo: ".mZPForm1"
         ,close: function( event, ui ) {
           $("#mainTBX1 tbody td."+field).removeClass("marked");
         },
    buttons: [{
    text:"Replace",
   click: function() {
   		var spop=$("#searchAndReplacePopUp");
   		if(spop.find(".searchAndReplaceSEL").val()=="replace"){
        	searchAndReplace(field,spop.find('.f').val(),spop.find('.r').val(),spop.find('.regex').is(":checked"),spop.find('.Match').is(":checked"),0);
        	  $( this ).dialog( "close" );
 		}else{
 		//alert(spop.find('.searchAndReplaceOp').val()+" "+spop.find('.searchAndReplaceCalcVal').val());
 			var val1=spop.find('.searchAndReplaceCalcVal').val();
 			if(val1=="" || isNaN(val1)){
				alert("Please enter a valid number!");
				$(".searchAndReplaceCalcVal").focus();
			}else{
 				searchAndReplaceCalculate(field,spop.find('.searchAndReplaceAction').val(),spop.find('.searchAndReplaceCalcVal').val(),0);
 				  $( this ).dialog( "close" );
 			}
 		}
      
  
    }},
    {text:Cancel_button,
    click: function() {
        $( this ).dialog( "close" );
    
    }
    }]
                                      });
}
function searchAndReplace(field,find,replace1,regex,match,all){
	try{
	if(!regex){
		find=find.replace(/\./ig,"\\.").replace(/\,/ig,"\\,").replace(/\|/ig,"\\|").replace(/\-/ig,"\\-").replace(/\$/ig,"\\$").replace(/\^/ig,"\\^");
	}
	//alert(find);
	var patt = new RegExp(find,(!match?"i":"")+"g");
	//var pattSearch = new RegExp(".*"+find+".*",(!match?"i":"")+"");
	var rows=$("#mainTBX1 .dataRow .lcbXRow"+(all==1?"":":checked"));
	if(rows.length==0){
		rows=$("#mainTBX1 .dataRow .lcbXRow");
	}
	rows.each(function(){
	$(this).parents("tr.dataRow:first").find("input[type='text'].iTb.inpSt_"+field+":visible, textarea.iTb.inpSt_"+field+":visible").each(function(){
		
	   if($(this).val().match(patt)){
	   	 $(this).val($(this).val().replace(patt,replace1)).change();
	   }
		
	});
	
	});
	}catch(e){
		alert("Error: "+e);
	}
}
var searchAndReplaceCalculateEval1=0;
function searchAndReplaceCalculate(field,Op1,val1,all){
	try{
	//alert(Op1.match(/\*|\/|\-|\+/)+ " "+!isNaN(val1));
	if(Op1.match(/\*|\/|\-|\+/) && val1!="" && !isNaN(val1)){
	var rows=$("#mainTBX1 .dataRow .lcbXRow"+(all==1?"":":checked"));
	if(rows.length==0){
		rows=$("#mainTBX1 .dataRow .lcbXRow");
	}
	rows.each(function(){
	$(this).parents("tr.dataRow:first").find("input[type='text'].iTb.inpSt_"+field+":visible, textarea.iTb.inpSt_"+field+":visible").each(function(){
		
	   if($(this).val()!="" && !isNaN($(this).val().replace(/\,/ig,""))){
	   	searchAndReplaceCalculateEval1="";
	   	jQuery.globalEval("try{searchAndReplaceCalculateEval1=("+($(this).val().replace(/\,/ig,""))+""+Op1+val1+");}catch(e){}");
	   	if(searchAndReplaceCalculateEval1!="" && !isNaN(searchAndReplaceCalculateEval1) && (searchAndReplaceCalculateEval1+"").indexOf(".")>-1){
	   		searchAndReplaceCalculateEval1=searchAndReplaceCalculateEval1.toFixed(2);
	   	}
	   	 $(this).val(searchAndReplaceCalculateEval1).change();
	   }
		
	});
	
	});
	}else{
		
	}
	}catch(e){
		alert("Error: "+e);
	}
}

function massTransData(object1, o1f1Name,o1f2Nameid, object2, o2f1Name){
	$.ajax({url:'/soap/ajax/35.0/connection.js',dataType: "script", success:function() {
	try{
	var objX1Arr=new Array();
	// query the record
	var checkedIds=new Array();;
	$(".lcbX input:checked").each(function(){
		checkedIds.push($(this).parents(".lcbX:first").attr("rid"));
	});
	if(checkedIds.length==0){
		alert("Please select at least row!");
	}else if(confirm("Are you sure you want to update "+checkedIds.length+" "+object2+"."+o2f1Name+"(s)"+" based on data taken from  the selected "+object1+"."+o1f1Name+"(s)")){
		var qr = sforce.connection.query("SELECT "+o1f1Name+", "+o1f2Nameid+" FROM "+object1+" where Id in('" +checkedIds.join("','")+ "')");
		var records = qr.getArray("records");
		for (var i=0; i< records.length; i++) {
			var record = records[i];
			var objX1 = new sforce.SObject(object2);
			objX1[o2f1Name]=record[o1f1Name];
			objX1.Id=record[o1f2Nameid];
			objX1Arr.push(objX1);
		}
		 var result = sforce.connection.update(objX1Arr);
		 if (result!=null && result[0].getBoolean("success")) {
			alert(objX1Arr.length+" "+object2+(objX1Arr.length>1?"s were":" was")+" updated successully.");//\n\n\n more info: "+result
		 }else{
			alert("Error during update: "+result);
		 }
		 jumpToClk(currPageCls,600); 
	 }
	 }catch(e){
		alert("Error: "+e);
	 }
	 }});
}

/**mass merge all / Create a Merge Job **/

function checkSyntaxMassMargeAll(){
	if($("#totalDupes").html().indexOf("Calculating")>-1){
		setTimeout(function(){
			if($("#totalDupes").html().indexOf("Calculating")>-1){
				$("#totalDupes").html("");
			}
		},45000);
		return;
	}
	var FieldSelLCIn=$("#FieldSelLCIn").val(); 
	var FieldSelDUPESIn=$("#FieldSelDUPESIn").val();
	var MassMergeAllSOQLFilter=$("#MassMergeAllSOQLFilter").val(); 
	$("#totalDupes").html("<span style='color:#999999;'>Calculating...</span>");
	
	var queryZZZ="SELECT count(id) countRowsx1, count_distinct("+FieldSelDUPESIn+") c1 FROM "+lastmainObjToMerge+" "+(MassMergeAllSOQLFilter!=""?" where "+MassMergeAllSOQLFilter:"")+" "; 
		
	Visualforce.remoting.Manager.invokeAction( 
		remoteTotMethod,//remoteQueryAjax2SC, //countRowsx1==c2
		queryZZZ, 
		function(result, event){ 
		$("#totalDupes").html("");
		$("#CSMMALL").html("");
		if (event.status && result!=null && result.countRowsx1!=null) { 
			var innerHtml = ''; 
			var records=result; 
			//alert(records)
			records.c2=records.countRowsx1;
			$("#totalDupes").html("<span id='totalDupes1'>"+(records.c2-records.c1)+"</span> / <span id='totalDupes2'>" +records.c2+"</span>");
			$("#CSMMALL").html('<span style="color:#00AA00;font-weight:bold;margin-left: 7px;display:inline-block;">Syntax OK!</span>');
		} else if (event.type === 'exception') { 
		if(event.message!=null && ((event.message+"").indexOf("Logged in")>-1 || (event.message+"").indexOf("Refresh page")>-1)){ 
		self.location=self.location; 
		}else if(event.message!=null && (event.message+"").indexOf("Unable to connect")==-1){
		 	$("#CSMMALL").html('<div style="color:#AA0000;font-weight:bold;margin: 15px 5px;">Syntax Error: '+event.message+' </div>');
			if($("body:visible").length>0)alert("Error while validaing Syntax: "+event.message+" \n\nMain Test query: "+queryZZZ); 
		} 
		} else { 
			//alert(event.message);
		//self.location=self.location; 
		// $("#"+filterIdSpan+" .availVals").html(""); 
		//alert(1); 
		} 

		}, 
		{escape: true,buffer:true,timeout: 90000} 
		); 
}




function cloneMergeJob(id1){
	
	
	var c1=$('.lcbX input:checked').length;
if(id1==null && c1.length!=1 ){
   alert('Please select the row that you want to clone.');
   return false;
}else{ 
	var rid=(id1!=null? id1:c1.parents(".lcbX:first").attr("rid"));
	

	
	var queryZZZ="SELECT Columns_Filters__c FROM zaapit__zaapit_editable_tb__c where id='"+rid+"' "; 
		
	Visualforce.remoting.Manager.invokeAction( 
		remoteQueryAjax2, 
		queryZZZ, 
		function(result, event){ 
		if (event.status && result!=null && result.length>0) { 
			var settingToCopy=result[0].Columns_Filters__c;
			if(settingToCopy==null || settingToCopy==''){
				settingToCopy= "{}";
			}
			//alert(settingToCopy);
			try{
			settingToCopy=jQuery.parseJSON(settingToCopy.replace(/&quot;/ig,'"'));
			}catch(e1){}
			//alert(settingToCopy);
			openMassMergeALL(settingToCopy["mainObject"],settingToCopy["FieldSelDUPES"],settingToCopy["FieldSelLC"],settingToCopy,settingToCopy["FieldSelLCAD"]);
		} else if (event.type === 'exception') { 
		if(event.message!=null && ((event.message+"").indexOf("Logged in")>-1 || (event.message+"").indexOf("Refresh page")>-1)){ 
		self.location=self.location; 
		}else if(event.message!=null && (event.message+"").indexOf("Unable to connect")==-1){
		 	$("#CSMMALL").html('<div style="color:#AA0000;font-weight:bold;margin: 15px 5px;">Syntax Error: '+event.message+' </div>');
			if($("body:visible").length>0)alert("Error while validaing Syntax: "+event.message+" \n\nMain Test query: "+queryZZZ); 
		} 
		} else { 
			//alert(event.message);
		//self.location=self.location; 
		// $("#"+filterIdSpan+" .availVals").html(""); 
		//alert(1); 
		} 

		}, 
		{escape: true,buffer:true,timeout: 90000} 
		); 
		
		}
}

function createNewSFField(){
	var win1=window.open("/p/setup/field/NewCustomFieldStageManager?entity="+lastopenMassMergeALL[5]+"&retURL=%2Fapex%2Fzaapit__closewin&appLayout=setup&tour=&isdtp=p1","new_field","width=800,height=800");
	var timer = setInterval(function() {   
    if(win1.closed) {  
        clearInterval(timer);  
        openMassMergeALL(lastopenMassMergeALL[0],lastopenMassMergeALL[1],lastopenMassMergeALL[2],lastopenMassMergeALL[3],lastopenMassMergeALL[4],lastopenMassMergeALL[5]);
    }  
	}, 1000); 
}

var lastopenMassMergeALL=null
function openMassMergeALL(mainObjToMerge,mainDedupField,FieldSelLCDef,autoFilVales,FieldSelLCADir,mainObjToMergeRC){//var mainObjToMerge="Lead"; 
trackEventX('massMergeAllJob');

lastopenMassMergeALL=[mainObjToMerge,mainDedupField,FieldSelLCDef,autoFilVales,FieldSelLCADir,mainObjToMergeRC];

if(mainObjToMerge!=null)mainObjToMerge=mainObjToMerge.toLowerCase();
if(mainDedupField==null || mainDedupField==''){
	mainDedupField=sortBy;
}
if( FieldSelLCDef==null){
	if((sortBy2!=null && sortBy2!="" && sortBy2!="null")){
		FieldSelLCDef = sortBy2;
	}else{
		FieldSelLCDef="CreatedDate";
	}
}
lastmainObjToMerge=mainObjToMerge;
var MainObjectNamefield='name';//isNameField

if((mainObjToMerge=="case" || mainObjToMerge=="task" || mainObjToMerge=="event" || mainObjToMerge=="note") && (mainDedupField==null || mainDedupField=='Name')){
	if( mainObjToMerge=="note"){
		mainDedupField='title';
	}else{
		mainDedupField='subject';
	}
	MainObjectNamefield=mainDedupField;
}
//alert(mainObjToMerge+" "+mainDedupField)
if(isEditMode1){
	alert("Creating a new merge Job only works in view-mode, Save / Cancel your changes first."); 
	return;
}

function getOptionsForNums(num,start){
	var html1="";
	if(start==null) start=0;
	for(var i=start;i<num;i++){
		html1+='<option value="'+i+'">'+i+'</option>';
	}
	return html1;
}

		function appendTags(){ 
		$('#dialog-mass-merge-all').remove(); 
		var stdMergeObjs=mainObjToMerge=='lead'|| mainObjToMerge=='contact'|| mainObjToMerge=='account';
		$('body').append( 
		'<div id="dialog-mass-merge-all" title="Mass Merge Job">' + 
		'<div style="margin:10px 0px;font-weight:bold;">Mass Merge Job Options:'+ 
		'</div>'+
		
		'<div style="margin-top:5px;"><span style="width:205px;display:inline-block;">Object:</span> <span id="mainObject">'+mainObjToMerge+'</span>'+
				'</div>'+
		'<div style="margin-top:5px;"><span style="width:205px;display:inline-block;">Main duplicates criteria '+(mainObjToMergeRC!=null && mainObjToMergeRC.indexOf("__c")==-1?'(<a href="javascript:void(0);" class="btt1" onclick="createNewSFField();" onmouseover="fixTitlex2(this,false,\'B\',null,true);"  title="Click this link to add a new formula field with custom dedupe logic <a  target=\'_blank\' href=\'https://sc2.zaapit.com/pdf/ZaapIT_Getting_Started_Training.pdf?page=25#page=25\'>Show me some exmaples</a>"><span class="t" style="padding-left: 1px;">New</a>)':'')+':</span> <span id="FieldSelDUPES">Loading...</span>'+
		'<a  class="helpLink btt1 helpQMSFDC" href="javascript:void(0);" onmouseover="fixTitlex2(this,false,\'B\',null,true);"  title="Choose the main field that will dictate the potential duplicates, potential duplicates are defined as 2+ rows with the exact same field-value. To create a custom dedupe-logic use a SF formula field. Click the new link on the left to create such a formula field. <a  target=\'_blank\' href=\'https://sc2.zaapit.com/pdf/ZaapIT_Getting_Started_Training.pdf?page=25#page=25\'>Show me some exmaples</a>"><span class="t" style="padding-left: 1px;"></span></a>'+
    
		'</div>'+
		'<div style="margin-top:5px;"><span style="width:205px;display:inline-block;">Master selection field:</span> <span id="FieldSelLC">Loading...</span>'+
		'<a  class="helpLink btt1 helpQMSFDC" href="javascript:void(0);" onmouseover="fixTitlex2(this,false,\'B\',null,true);"  title="The master record is selected based on the this field (use the next step to select the logic i.e. Latest/Earliest or Greatest/Smallest value). <br/><br/>If you need to use a custom sorting-logic, create a formula field and then select it here..."><span class="t" style="padding-left: 1px;"></span></a>'+
		'</div>'+
		' <div style="margin-top:3px;"><span style="width:205px;display:inline-block;">Master selection order:</span> <select id="FieldSelLCAD" style="width:  58%;margin-top:5px;"><option value="asc">Ascending Order / Earliest</option> <option value="desc" '+( (FieldSelLCADir!=null && FieldSelLCADir=="asc") || (FieldSelLCADir==null && sortBy2!="null" && sortBy2!="" && sortDir2=="asc" )?'':'selected')+'>Descending Order / Latest</option> </select>'+
		'<a  class="helpLink btt1 helpQMSFDC" href="javascript:void(0);" onmouseover="fixTitlex2(this,false,\'B\',null,true);"  title="The master row is selected based on the <b>Latest/Earliest or Greatest/Smallest</b> Master-selection-field value. <br/><br/>If you need to use a custom sorting-logic, create a formula field and select it in the previous step as Master-selection-field."><span class="t" style="padding-left: 1px;"></span></a>'+
		
		'<div style="margin-top:5px;color:#999999">Auto select the master row with the Latest/Earliest field value.</div>'+
		'</div>' + 
		
		
		
		' <div style="margin-top:3px;"><span style="width:205px;display:inline-block;">Copy Fields:</span> <select id="copyFieldOpts" onchange="var selIDx=this.selectedIndex;if(selIDx<3){$(\'.copyFieldOptsIn\').each(function(){this.selectedIndex=selIDx;});}" style="width: 58%;margin-top:5px;"><option value="No">Don\'t Copy / Use Master</option> <option value="CopyEmpty">Copy If Empty</option><option value="Yes">Always Overwrite</option><option value="Manual">Manual Selection</option> </select>'+
		'<a  class="helpLink btt1 helpQMSFDC" href="javascript:void(0);" onmouseover="fixTitlex2(this,false,\'B\',null,true);"  title="Use this option to overwrite or merge the master\'s fields with the non-master fields: <br/> 1) copy if empty: copy the non-master field to a master fields when the master field is empty. <br/> 2) Always overwrite the master value (ignoring the current master value). <br/> 3) Combine Values: combine the values from the non-master rows with the master row (this option ignores repeating values, the values are combined by a comma or semi-colon for multi-picklists).<br/> 4) Combine non-master values with a different field: combine the non-master field with a different master text field (This option ignores repeating values and assign the value to the master-field if empty e.g.  save different emails/phones to multiple field with 1 master field)"><span class="t" style="padding-left: 1px;"></span></a>'+
		
		'<span id="FieldsToOver">Loading...</span>'+
		'</div>' + 
		
		' <div style="margin-top:10px;"><span style="width:205px;display:inline-block;">Merge Related Lists:</span> '+
		(stdMergeObjs?' Automatically (contacts/accounts/leads) ':
		'<select id="copyRLOpts" onchange="var selIDx=this.selectedIndex;if(selIDx<2){$(\'.copyRLOptsIn\').each(function(){this.selectedIndex=selIDx;});}" style="width:  58%;margin-top:5px;"><option value="No">Don\'t Merge</option> <option value="Yes">Merge Records</option><option value="Manual">Manual Selection</option> </select>'+
		'<a  class="helpLink btt1 helpQMSFDC" href="javascript:void(0);" onmouseover="fixTitlex2(this,false,\'B\',null,true);"  title="Use this option to merge the related lists, the related rows will be re-parented based on the object\'s permission. In case a related can not be re-parented the app will try shallow clone it."><span class="t" style="padding-left: 1px;"></span></a>'+
		
		'<span id="RLToOver">Loading...</span>'+
		'</div>') + 
 

		'<div style="margin-top:15px;width:99%;"><span style="display:block;width:99%;">Custom advanced / SOQL filter:</span> '+
		'<div style="width:99%;margin-top:3px;"><textarea id="MassMergeAllSOQLFilter" style="width:99%;height:85px;" onchange="checkSyntaxMassMargeAll();">'+(lastmainObjToMerge.toLowerCase()=='lead'?' isconverted=false and ':'')+mainDedupField+'!=\'\'</textarea>'+
		'</div>'+
		'<div style="margin-top:3px;"><button onclick="OpenFilterWizardDedupManager(\''+mainObjToMerge+'\',\'#MassMergeAllSOQLFilter\');" type="button" class="btn" style=" background: #ffffe0 !important;" >SOQL Filter Wizard</button><button onclick="checkSyntaxMassMargeAll();" class="btn" type="button" >Check Syntax & Recalculate totals</button><span id="CSMMALL"></span></div>'+
		
		'</div>'+
		
		'<div style="margin-top:10px;"><input type="checkbox" name="runDaily" id="runDaily"  class="runDaily" value="1"/> Run automaticlly on <select id="RDdayOfMonth" onclick="$(\'#RDdayOfWeek\').val(\'?\');" style="width:115px;"><option value="*">Day of month</option>'+getOptionsForNums(28,1)+'<option value="?">Use Day of Week</option></select> or '+
		'<select id="RDdayOfWeek"  onclick="$(\'#RDdayOfMonth\').val(\'?\');"><option value="?">Day of week</option><option value="SUN">SUN</option><option value="MON">MON</option><option value="TUE">TUE</option><option value="WED">WED</option><option value="THU">THU</option><option value="FRI">FRI</option><option value="SAT">SAT</option></select>'+
		' / time: <select id="RDHour"><option value="*">Every hour</option>'+getOptionsForNums(24)+'</select> : <select id="RDMin" style="width:55px;">'+getOptionsForNums(60)+'</select>  ' +
		'<a  class="helpLink btt1 helpQMSFDC" href="javascript:void(0);" onmouseover="fixTitlex2(this,false,null,null,true);"  title="Run this cleanup automatically on a spesific day and/or time of the day. <br/>Make sure to enable history tracking for the current object, this will allow you to generate a merge-report on the history table (filter/search for merged records).<br/><br/> <b>To cancel/suspend the merge job unmark the active checkbox next to the job-row on the job\'s tab or go to setup>search>Scheduled Jobs>delete the right job</b>"><span class="t" style="padding-left: 1px;"></span></a>'+
		'</div>'+
		'<div style="margin-top:10px;"><span style="width:105px;display:inline-block;">Batch Size:</span> <span id="batchSize"><select class="batchSizeSel"><option value="2" '+(!stdMergeObjs?'selected':'')+'>2</option><option value="4" >4</option><option value="10" >10</option><option value="25">25</option><option value="50" '+(stdMergeObjs?'selected':'')+'>50</option></select></span>'+
		'<a  class="helpLink btt1 helpQMSFDC" href="javascript:void(0);" onmouseover="fixTitlex2(this,false,null,null,true);"  title="When merging objects other than contacts/accounts/leads the maximum batch size is being influenced by the number of related lists, when marking 5+ related lists keep the batch size on 2."><span class="t" style="padding-left: 1px;"></span></a>'+
		'</div>'+
		
		'<div style="margin-top:20px;"><span style="width:205px;display:inline-block;font-weight:bold;">Total duplicates to merge:</span> <span id="totalDupes">Loading...</span></div>'+
		
		
		'<div style="margin-top:10px;color:#999999">Tip #1: If you want to see your data prior to running the merge job then please use the run daily option and then click the view duplicates link next to the job. (if needed you can delete or de-activate the job\'s record present under the Jobs tab to cancel/stop the merge job)</div>'+
		'<div style="margin-top:10px;color:#999999">Tip #2: Backup your Salesforce data on a regular basis, this practice can be very handy in case you will need to compare or restore old records. <a href="https://help.salesforce.com/articleView?id=admin_exportdata.htm&type=5" target="_blank">Click here for more details</a>.</div>'+
		//'Mass Email Name <input type="text" name="descriptionME" id="descriptionME" />' + 


		'' + 
		'' 

		); 

		} 

		function createPopupWindow(){ 
		
		 var buttons1=new Array();
		
		if(Enable_ZaapIT_s_Layout_Editor=="true"){
			buttons1.push({
			text: "Create Merge Job", 
			click: function() { 
			
			if($("#totalDupes1").length==0 ){
				checkSyntaxMassMargeAll();
			}else{
				startMassMergeAll(); 
				jQuery( this ).dialog( "close" );
			} 
			}});
			
			buttons1.push({
			text: "Preview Duplicates / Manual Mass Merge", 
			click: function() { 
			
			if($("#totalDupes1").length==0 ){
				checkSyntaxMassMargeAll();
			}else{
				startMassMergeAll(true); 
				jQuery( this ).dialog( "close" );
			} 
			}});
			
			}else{
				buttons1.push({ 
			text: "Only the app's admin can create a Merge Job",
			click: function() { 
			jQuery( this ).dialog( "close" );
			}}); 
		}
		
		
		buttons1.push({
		text: "Cancel", 
		click: function() { 
		jQuery( this ).dialog( "close" ); 
		} 
		});
		
		$( "#dialog-mass-merge-all" ).dialog({ 
		resizable: false, 
		width: (isSF1()?($("body").width()-10):690), 
		height:(Math.min($(window).height()-10,1200)), 
		//modal: true, 
		buttons: buttons1
		}); 
			fixIfmHegt();
		} 

		function messagePopupWindow(message,button){ 
		
		 var buttons1=new Array();
		 if(button!=null) buttons1.push(button);
		 
		 buttons1.push({
		text: "Close", 
		click: function() { 
		jQuery( this ).dialog( "close" ); 
		} 
		});
		$( "#dialog-popup-alert" ).remove();
		if($( "#dialog-popup-alert" ).length==0){
			$('body').append( '<div id="dialog-popup-alert" title="Mass Merge Job"></div>');
		} 
		$( "#dialog-popup-alert" ).html(message).dialog({ 
		resizable: false, 
		width: 400, 
		height:250, 
		//modal: true, 
		buttons: buttons1}); 
		
		} 

		function fetchData(){ 
		
		//lead fields
		Visualforce.remoting.Manager.invokeAction( 
		remotequeryAjax2GetTbFields, 
		mainObjToMerge, 
		function(result, event){ 

		if (event.status && result!=null) { 

		var innerHtml = ''; 
		var innerHtmlRL = ''; 
		var innerHtmlGroupable = ''; 
		var innerHtmlOverwrite ='';
		var innerHtmlstrFields ='';
		var innerHtmlstrSep ='<div/><select class="copyFieldOptsInX copyFieldOptsInSEP hd1"><option value=";">Separate by Semicolon</option><option value=",">Separate by Comma</option><option value=" ">Separate by Space</option><option value="NL">Separate by New Line</option><option value="|">Separate by |</option><option value=".">Separate by .</option></select>';
		var records=result; 
		//alert(records[records.length-1].name);
		var combineTASel='';
		for(var i=0; i<records.length; i++) {
			if(records[i].childRel=="0" && records[i].name.indexOf("__xx")==-1 && records[i].Updateable=='true') {
			var type1=records[i].type.toLowerCase();
			if(type1.indexOf('area')>-1 || type1.indexOf('text')>-1  || type1.indexOf('string')>-1  || type1.indexOf('phone')>-1   || type1.indexOf('email')>-1  ){
						innerHtmlstrFields += 
						'<option value="' + records[i].name.toLowerCase() + '">'+records[i].label +'</option>';
						
						combineTASel+='<option value="combineTA-XXXXX~' + records[i].name.toLowerCase() + '">Combine non-master with '+records[i].label +'</option>';;
			}
			}
					
		}
					
		for(var i=0; i<records.length; i++) {
			var type1=records[i].type.toLowerCase();
			var isText=type1.indexOf('area')>-1 || type1.indexOf('text')>-1  || type1.indexOf('string')>-1  || type1.indexOf('phone')>-1   || type1.indexOf('email')>-1;
			if(records[i].childRel=="0" && records[i].name.indexOf("__xx")==-1 && (records[i].Updateable=='true' || records[i].Createable=='true' || records[i].sortable=='true')) {//&& records[i].Updateable=='true'
				if(records[i].isNameField=='true' ){
				 	MainObjectNamefield=records[i].name.toLowerCase();
				 }
			
				if(records[i].sortable=='true'){
					innerHtml += 
					'<option value="' + records[i].name.toLowerCase() + '">'+records[i].label +'</option>';
				}
					var type1=records[i].type.toLowerCase();
					//if( records[i].name.toLowerCase().indexOf('soci')>-1)alert( records[i].name.toLowerCase()+ " "+type1+ " "+records[i].sortable);
					if(type1.indexOf('area')==-1 && type1.indexOf('date')==-1 && type1.indexOf('number')==-1 && type1.indexOf('boolean')==-1 && type1.indexOf('checkbox')==-1 && records[i].sortable=='true'){
						innerHtmlGroupable += 
						'<option value="' + records[i].name.toLowerCase() + '">'+records[i].label +'</option>';
					}

					
				
				if(records[i].childRel=="0" && records[i].name.indexOf('__xx')==-1 && records[i].Updateable=='true' && records[i].name.toLowerCase()!='individualid') {	
					//alert(type1);
					var nameForReplace=records[i].name.replace(/\\_/ig,'\\\\_');
					innerHtmlOverwrite+='<div id="DivFieldsToOver'+i+'" class="DivFieldsToOver"  style="padding:3px;width:97%;border-bottom:1px solid #a5a5a5;display:block;padding:3px;"> <span style="display:inline-block;width:201px;">'+records[i].label +':</span> '+// || type1.indexOf('picklist')>-1
					'<select class="copyFieldOptsIn '+type1+'FT CF-' + records[i].name + '" onchange="$(\'#copyFieldOpts\')[0].selectedIndex=3;" style="width: 63%;"><option value="No-' + records[i].name + '">Don\'t Copy / Use Master</option> <option value="CopyEmpty-' + records[i].name + '">Copy If Empty</option><option value="Yes-' + records[i].name + '">Always Overwrite</option>'+(type1.indexOf('multipicklist')>-1 ||type1.indexOf('text')>-1 || type1.indexOf('string')>-1 || type1.indexOf('phone')>-1 ?'<option value="MergeVal-' + records[i].name + '">Combine Values</option>':'')+(isText?combineTASel.replace(/XXXXX/ig,nameForReplace):'')+' </select><span class="copyFieldOptsInFLD">  <select class="copyFieldOptsInX copyFieldOptsInFIELD hd1">'+(true ?'':innerHtmlstrFields)+'</select>'+(true ?'':innerHtmlstrSep)+'</span>'+
					'</div>';
					//var chooseFLD=$(this).parents(\'div:first\').find(\'.copyFieldOptsInX\');chooseFLD.hide();if($(this).val().indexOf(\'AddValFld-\')>-1){chooseFLD.show();}if($(this).val().indexOf(\'MergeVal-\')>-1){$(chooseFLD[1]).show();}
				}
				//alert(records[i].childRel+" "+type1+" "+records[i].name);
				 
				}else if(records[i].name.indexOf('__xx')>-1 && 
				//records[i].name.indexOf('Content')==-1 &&
				//records[i].name.indexOf('Attachment')==-1 &&
				//records[i].name.indexOf('Files')==-1 &&
				//records[i].name.indexOf('Feed')==-1 &&
				records[i].Createable=='true'  && records[i].Updateable=='true' && records[i].Queryable=='true' ){//&& records[i].RLFieldUpdateable=='true'
					
					//alert(type1);
					innerHtmlRL+='<div id="DivRLToOver'+i+'" class="DivRLToOver"  style="padding:3px;width:97%;border-bottom:1px solid #a5a5a5;display:block;padding:3px;"> <span style="display:inline-block;width:201px;">'+(records[i].label!=null?records[i].label: records[i].referenceTo)+':</span> '+
					'<select class="copyRLOptsIn CRL-' + (records[i].name.replace(/\./ig,"-")) + '" onchange="$(\'#copyRLOpts\')[0].selectedIndex=2;" style="width: 63%;"><option value="No-' + records[i].name + '">Don\'t Merge</option> <option value="Yes-' + records[i].name + '-'+records[i].RLFieldUpdateable+'" >Merge Rows</option></select>'+
					'</div>';
				
				} 
			}

			$('#FieldSelLC').html('<select name="FieldSelLCIn" id="FieldSelLCIn" style="width:  58%;" onmousedown="return isSF1();" onclick=" return openSearchSel3(this,event,this.id);" onkeydown="return openSelXDP3(this,event,this.id);">'+innerHtml+'</select>');
			$("#FieldSelLCIn").val(FieldSelLCDef.toLowerCase()); 
			
			$('#FieldSelDUPES').html('<select name="FieldSelDUPESIn" id="FieldSelDUPESIn" style="width:  58%;" onmousedown="return isSF1();" onclick=" return openSearchSel3(this,event,this.id);" onkeydown="return openSelXDP3(this,event,this.id);" onchange="$(\'#MassMergeAllSOQLFilter\').val((lastmainObjToMerge.toLowerCase()==\'lead\'?\' isconverted=false and \':\'\')+$(this).val()+\'!=\\\'\\\'\');checkSyntaxMassMargeAll();">'+innerHtmlGroupable+'</select>');
			if($('#FieldSelDUPESIn').html().indexOf("\""+mainDedupField.toLowerCase()+"\"")>-1){
				$("#FieldSelDUPESIn").val(mainDedupField.toLowerCase()); 
			}else{
				var newMainObjectNamefield=$("#FieldSelDUPESIn").val();
				$("#MassMergeAllSOQLFilter").val($("#MassMergeAllSOQLFilter").val().toLowerCase().replace(""+MainObjectNamefield+"!=''",newMainObjectNamefield+"!=null"));
				MainObjectNamefield=newMainObjectNamefield;
				
			}
			//alert('MainObjectNamefield: '+MainObjectNamefield);
			
			
			var FieldsToOverH=Math.max($(self).height()/5,120);
			$('#FieldsToOver').css({"display":"block", "width":"98%", "height":FieldsToOverH+"px", "overflow":"auto","margin-top":"5px","border":"1px solid #a5a5a5"}).html(''+innerHtmlOverwrite+'');
			
			if(innerHtmlRL!=""){
				$('#RLToOver').css({"display":"block", "width":"98%", "height":FieldsToOverH+"px", "overflow":"auto","margin-top":"5px","border":"1px solid #a5a5a5"}).html(''+innerHtmlRL+'');
			}else{
				$('#RLToOver').height(20).html("<div>No related lists were found!</div>");
			}
			if(autoFilVales!=null){
				if(autoFilVales['FieldOverWrite']!=null && $('#copyFieldOpts').length>0){
					var arr1=autoFilVales['FieldOverWrite'].split(";");
					for(var i1=0;i1<arr1.length;i1++){
						var str=arr1[i1].split("-");
						if(str.length>1){
							var e1=$(".CF-"+str[1].split("~")[0]);
							if(e1.length>0){
								e1.val(arr1[i1]);
							}
						}
					}
					$('#copyFieldOpts')[0].selectedIndex=3;
				}
				if(autoFilVales['CopyRL']!=null && $('#copyRLOpts').length>0){
					//alert(autoFilVales['CopyRL']);
					var arr1=autoFilVales['CopyRL'].split(";");
					for(var i1=0;i1<arr1.length;i1++){
						var str=arr1[i1].split("-");
						if(str.length>1){
							var e1=$(".CRL-"+(str[1].replace(/\./ig,"-")));
							if(e1.length>0){
								e1.val(arr1[i1]);
							}
						}
					}
					$('#copyRLOpts')[0].selectedIndex=2;
				}
				
				$("#MassMergeAllSOQLFilter").val(autoFilVales["MassMergeAllSOQLFilter"].replace(/&\#39;/ig,"'").replace(/&gt;/ig,">").replace(/&lt;/ig,"<"));
			}
			checkSyntaxMassMargeAll();
		} else if (event.type === 'exception') { 
		if(event.message!=null && ((event.message+"").indexOf("Logged in")>-1 || (event.message+"").indexOf("Refresh page")>-1)){ 
		self.location=self.location; 
		}else if(event.message!=null && (event.message+"").indexOf("Unable to connect")==-1){ 
		if($("body:visible").length>0)alert("An error has occurred: "+event.message); 
		} 
		} else { 
		//self.location=self.location; 
		// $("#"+filterIdSpan+" .availVals").html(""); 
		//alert(1); 
		} 

		}, 
		{escape: true,buffer:true,timeout: 90000} 
		); 
		
		}
		
		
		
		function startMassMergeAll(previewMode){ 
			//loadingSH();
			
			var checkedLength=Number($("#totalDupes1").text());
			if(licenseStatus!='Active' && licenseStatus!='ActiveP' && previewMode==null && ( checkedLength>5 || getStoredNumPPL("AutoMergeJobX")>7)){ 
					licenseReqMessage("During the free trial the Merge-Jobs / Auto-Merge options are limited to 5 rows per shot / 7 shots in total."); 
					return; 
			}
			
			if(licenseStatus!='Active' && licenseStatus!='ActiveP' && previewMode!=null && ( getStoredNumPPL("AutoMergePreviewJobX")>7)){ 
					licenseReqMessage("During the free trial the Preview-Job option is limited to 7 shots in total."); 
					return; 
			}
			
			if( previewMode==null && licenseStatus!='ActiveP' && checkedLength>5 ){ 
					licenseReqMessage("The auto merge job option is not included with your license. \nContact sales@zaapit.com for more details!"); 
					return; 
			}
			//alert(checkedIdsArr[currentLeadIdx]);
			//lead_MasterLabel~find account 0/1~find contact 0/1~owenrid~create opportunity 0/1
			//copyFieldOptsIn
			var options={}
			options["mainObject"]=mainObjToMerge;
	   		options["FieldSelDUPES"]=$("#FieldSelDUPESIn").val();
	   		options["FieldSelLC"]=$("#FieldSelLCIn").val();
	   		options["FieldSelLCAD"]=$("#FieldSelLCAD").val();
	   		options["MassMergeAllSOQLFilter"]=$("#MassMergeAllSOQLFilter").val().replace("~","_");
	   		options["limit1"]=5000;
	   		options["previewMode"]=(previewMode!=null && previewMode);
	   		options["mergeLimit"]=Number($(".batchSizeSel").val());
	   		options["continueFromVal"]="";
	   		options["ExpectedTotalRows"]=$("#totalDupes2").text();
	   		options["ExpectedRowsToMerge"]=$("#totalDupes1").text();
			options["scdualeJob"]=(($(".runDaily").is(":checked")?"1":"0")+'');
			options["hours"]=$("#RDHour").val();
			options["mins"]=$("#RDMin").val();
			options["dayofweek"]=$("#RDdayOfWeek").val();
			options["dayofmonth"]=$("#RDdayOfMonth").val();
			options["nextRun"]=(options["scdualeJob"]=="1"?("Every: "+(options["dayofmonth"]!="?" && options["dayofmonth"]!="*" ?" day " +options["dayofmonth"]+" of month ":"")+(options["dayofweek"]!="?"? " week on " +options["dayofweek"]+" ":"")+options["hours"]=="*"?"Hour":"Day")+': '+options["hours"]+":"+options["mins"]:"One Time");
			options["MainObjectNamefield"]=MainObjectNamefield;
			
			options["FieldOverWrite"]="";
			$(".copyFieldOptsIn").each(function(){
				options["FieldOverWrite"]+=";"+$(this).val();
			});
			
			options["CopyRL"]="";
			$(".copyRLOptsIn").each(function(){
				options["CopyRL"]+=";"+$(this).val();
			});
			options["TS20"]=new Date().getTime().toString(24);
			options["TS24"]="ZaapIT Merge Job ("+mainObjToMerge+"-"+(options["FieldSelDUPES"].length>10?options["FieldSelDUPES"].substring(0,10):options["FieldSelDUPES"])+"-"+(options["TS20"])+')'+(options["scdualeJob"]=="0"?"-nosched":"");
			/*var options=mainObject+"~"+
			  FieldSelDUPES+"~"+
			  FieldSelLC+"~"+
			  FieldSelLCAD+"~"+
			  MassMergeAllSOQLFilter+"~"+
			  limit1+"~"+
			  mergeLimit+"~"+
			  continueFromVal+"~"+
			  scdualeJob+"~"+
			  hours+"~"+
			  mins+"~"+
			  FieldOverWrite;*/
			
		Visualforce.remoting.Manager.invokeAction( 
		remoteAutoMergeRecords, 
		JSON.stringify(options), 
		function(result, event){ 
		var continueMerge=true;
		
		if (event.status && result!=null) { 
		
			messagePopupWindow(((result+"").indexOf("Job Created Successfully")>-1?"<div style='font-size:11pt;padding:10px 5px;font-weight:bold;'>Job Created Successfully</div> <div style='color:#696969;font-size:9pt;padding:10px 5px;'>A new merge job was created successfully. You can monitor the job's progress from dedup-manager &gt; Jobs tab</div>"
			:((result+"").indexOf("Custom Dedupe Created Successfully")>-1?"<div style='font-size:11pt;padding:10px 5px;font-weight:bold;'>Preview / Custom Dedupe Created Successfully</div> <div style='color:#696969;font-size:9pt;padding:10px 5px;'>Click the view details link next to the latest preview row to see / merge the duplicates</div>":
			"Error while creating Merge Job, send the folloing message to support@zaapit.com for assistance:<div style='color:#999999'>"+result+"</div>")));
			jumpToClk(currPageCls,600); 
			
		} else if (event.type === 'exception') { 
		if(event.message!=null && ((event.message+"").indexOf("Logged in")>-1 || (event.message+"").indexOf("Refresh page")>-1)){ 
		self.location=self.location; 
		}else if(event.message!=null && (event.message+"").indexOf("Unable to connect")==-1 ){ 
		//if($("body:visible").length>0)alert("An error has occurred: "+event.message); 
			messagePopupWindow("Error while creating Merge Job, send the folloing message to support@zaapit.com for assistance:	<div style='color:#999999'>"+event.message+"</div>");
		} 
		} else { 
		//self.location=self.location; 
		// $("#"+filterIdSpan+" .availVals").html(""); 
		//alert(1); 
		} 

		}, 
		{escape: true,buffer:true,timeout: 90000} 
		); 

		
		} 
			if(mainObjToMerge==null || mainObjToMerge==""){
				var html1='<div style="font-weight:bold; margin: 10px 0px;width:98%;">Please select the main object for the Merge process:</div>'+
				'<div id="mainObjPreDiv" style="margin-top: 14px;"><b>Loading...</b></div>';
				//<select id="mainObjPre" style="width: 96%;height: 34px;margin-top: 14px;"><option value="Lead">Lead</option><option value="Contact">Contact</option><option value="Account">Account</option><select>
				
				var button1={
				text: "Select Main Object", 
				click: function() { 
					var mainObjPreX=$("#mainObjPre")[0];
					openMassMergeALL($("#mainObjPre").val(),mainDedupField,FieldSelLCDef,null,null,mainObjPreX.options[mainObjPreX.selectedIndex].getAttribute("valueRC"));
					jQuery( this ).dialog( "close" ); 
				}};
				//alert(html1);
				messagePopupWindow(html1,button1);
				
				
					Visualforce.remoting.Manager.invokeAction( 
		remoteQueryAjax2GetTablesETL, 
		"",//extra STR 
		function(result, event){ 

		if (event.status && result!=null) { 

		var innerHtml = ''; 
		var innerHtmlGroupable = ''; 
		var innerHtmlOverwrite ='';
		
		var records=result; 
		for(var i=0; i<records.length; i++) {
			 	innerHtml+='<option value="'+records[i].name+'" valueRC="'+records[i].nameRC+'" '+(records[i].name=='lead'?'selected':'')+'>'+records[i].label+'</option>';//records[i].name.toLowerCase();
			
		}
		$('#mainObjPreDiv').html('<select id="mainObjPre" style="width: 96%;height: 34px;" onmousedown="return isSF1();" onclick=" return openSearchSel3(this,event,this.id);" onkeydown="return openSelXDP3(this,event,this.id);">'+innerHtml+'<select>');
		
		if(records.length>=250){
			loadMoreObjectsForSelection(1);
		}
		
		
		} else if (event.type === 'exception') { 
		if(event.message!=null && ((event.message+"").indexOf("Logged in")>-1 || (event.message+"").indexOf("Refresh page")>-1)){ 
		self.location=self.location; 
		}else if(event.message!=null && (event.message+"").indexOf("Unable to connect")==-1){ 
		if($("body:visible").length>0)alert("An error has occurred: "+event.message); 
		} 
		} else { 
		//self.location=self.location; 
		// $("#"+filterIdSpan+" .availVals").html(""); 
		//alert(1); 
		} 

		}, 
		{escape: true,buffer:true,timeout: 90000} 
		); 
		
		
			}else{ 
				appendTags(); 
				createPopupWindow(); 
				fetchData(); 
			}

		} 

		
		
		
		

/**  mass merge**/
function createJQpopup(id1,title1,buttons,message){
 var buttons1=buttons;
 
		if($( "#"+id1 ).length==0){
			$('body').append( '<div id="'+id1+'" title="'+title1+'"></div>');
		} 
		$( "#"+id1 ).html(message).dialog({ 
		resizable: false, 
		width: 450, 
		height:250, 
		//modal: true, 
		buttons: buttons1}); 
}

function massMergeXSel(mainObjToMerge){
	createJQpopup("chooseMerge1","Mass Merge",[{
		text: "Mass Merge Selected Records", 
		click: function() { 
			if(Enable_Sort_coloring){
				massMergeX(mainObjToMerge);
			}else{
				alert("Please mark the 'Apply shading to alternate rows' checkbox under the edit layout link before you start the mass merge process!");
			}
			jQuery( this ).dialog( "close" ); 
		} 
		},{
		text: "Create Merge Job", 
		click: function() { 
			openMassMergeALL(mainObjToMerge);
			jQuery( this ).dialog( "close" ); 
		} 
		},{
		text: "Cancel", 
		click: function() { 
			jQuery( this ).dialog( "close" ); 
		} 
		}],"<div style='padding:7px;'>Please select the type of mass merge that you would like to perform.</div>"
	)
}
var lastmainObjToMerge="";
function massMergeX(mainObjToMerge){
	massMergeX1(mainObjToMerge);//
}



function fetchDataMassMergeSel(mainObjToMerge){ 
		
		//lead fields
		Visualforce.remoting.Manager.invokeAction( 
		remotequeryAjax2GetTbFields, 
		mainObjToMerge, 
		function(result, event){ 

		if (event.status && result!=null) { 

		var innerHtml = ''; 
		var innerHtmlRL = ''; 
		var innerHtmlGroupable = ''; 
		var innerHtmlOverwrite ='';
		var innerHtmlstrFields ='';
		var innerHtmlstrSep ='<div/><select class="copyFieldOptsInX copyFieldOptsInSEP hd1"><option value=";">Separate by Semicolon</option><option value=",">Separate by Comma</option><option value=" ">Separate by Space</option><option value="NL">Separate by New Line</option><option value="|">Separate by |</option><option value=".">Separate by .</option></select>';
		var records=result; 
		//alert(records[records.length-1].name);

					
		for(var i=0; i<records.length; i++) {
			var type1=records[i].type.toLowerCase();
			var isText=type1.indexOf('area')>-1 || type1.indexOf('text')>-1  || type1.indexOf('string')>-1  || type1.indexOf('phone')>-1   || type1.indexOf('email')>-1;
				if(records[i].childRel=="0" && records[i].name.indexOf("__xx")==-1 && records[i].sortable=='true') {
					if(records[i].isNameField=='true'){
					 	MainObjectNamefield=records[i].name.toLowerCase();
					 }
				}
					

				if(records[i].name.indexOf('__xx')>-1 && 
				//records[i].name.indexOf('Content')==-1 &&
				//records[i].name.indexOf('Attachment')==-1 &&
				//records[i].name.indexOf('Files')==-1 &&
				//records[i].name.indexOf('Feed')==-1 &&
				records[i].Createable=='true'  && records[i].Updateable=='true' && records[i].Queryable=='true' ){//&& records[i].RLFieldUpdateable=='true'
					
					//alert(type1);
					//alert(records[i].name+" "+AutoMarkCustomCopyRL[records[i].name]);
					innerHtmlRL+='<div id="DivRLToOver'+i+'" class="DivRLToOver"  style="padding:3px;width:97%;border-bottom:1px solid #a5a5a5;display:block;padding:3px;"> <span style="display:inline-block;width:150px;">'+(records[i].label!=null?records[i].label: records[i].referenceTo)+':</span> '+
					'<select class="copyRLOptsIn" onchange="$(\'#copyRLOpts\')[0].selectedIndex=2;" style="width: 58%;"><option value="No-' + records[i].name + '">Don\'t Merge</option> <option value="Yes-' + records[i].name + '-'+records[i].RLFieldUpdateable+'" '+(AutoMarkCustomCopyRL!=null && AutoMarkCustomCopyRL['Yes-'+records[i].name+ '-'+records[i].RLFieldUpdateable]!=null?'selected':'')+'>Merge Rows</option></select>'+
					'</div>';
				
				} 
			}

			if(innerHtmlRL!=""){
				$('#RLToOver').css({"display":"block", "width":"98%", "overflow":"auto","margin-top":"5px","border":"1px solid #a5a5a5"}).html(''+innerHtmlRL+'');
			}else{
				$('#RLToOver').height(20).html("<div>No related lists were found!</div>");
			}

		} else if (event.type === 'exception') { 
		if(event.message!=null && ((event.message+"").indexOf("Logged in")>-1 || (event.message+"").indexOf("Refresh page")>-1)){ 
		self.location=self.location; 
		}else if(event.message!=null && (event.message+"").indexOf("Unable to connect")==-1){ 
		if($("body:visible").length>0)alert("An error has occurred: "+event.message); 
		} 
		} else { 
		//self.location=self.location; 
		// $("#"+filterIdSpan+" .availVals").html(""); 
		//alert(1); 
		} 

		}, 
		{escape: true,buffer:true,timeout: 90000} 
		); 
		
		}
		
var massMergeX1RLSel="";
function massMergeX1(mainObjToMerge,seq){//var mainObjToMerge="Lead"; 
trackEventX('massMergeX');
if(mainObjToMerge!=null){
	mainObjToMerge=mainObjToMerge.toLowerCase();
}
lastmainObjToMerge=mainObjToMerge;
if(mainObjToMerge!="contact" && mainObjToMerge!="account" && mainObjToMerge!="lead" && seq==null){//none standard object


			
var button1={
				text: "Start Mass Merge", 
				click: function() { 
					massMergeX1RLSel="";
					$(".copyRLOptsIn").each(function(){
						massMergeX1RLSel+=";"+$(this).val();
					});
					massMergeX1(mainObjToMerge,1);
				jQuery( this ).dialog( "close" ); 
				}};
				
  messagePopupAlert(' <div style="margin-top:10px;"><span style="width:154px;display:inline-block;">Merge Related Lists:</span> '+
		(mainObjToMerge=='lead'|| mainObjToMerge=='contact'|| mainObjToMerge=='account'?' Automatically (contacts/accounts/leads) ':
		'<select id="copyRLOpts" onchange="var selIDx=this.selectedIndex;if(selIDx<2){$(\'.copyRLOptsIn\').each(function(){this.selectedIndex=selIDx;});}" style="width:  45%;margin-top:5px;"><option value="No">Don\'t Merge</option> <option value="Yes">Merge Records</option><option value="Manual">Manual Selection</option> </select>'+
		'<a  class="helpLink btt1 helpQMSFDC" href="javascript:void(0);" onmouseover="fixTitlex2(this,false,null,null,true);"  title="Use this option to merge the related lists, the related rows will be re-parented based on the object\'s permission. In case a related can not be re-parented the app will try shallow clone it."><span class="t" style="padding-left: 1px;"></span></a>'+
		
		'<br/><span id="RLToOver" style="display:block;width:98%;height:350px;">Loading...</span>')+
		'</div>',"Merge Options",button1,450,550);
		fetchDataMassMergeSel(mainObjToMerge);
		return;
}else{
	if(seq==null){
		massMergeX1RLSel="";
	}
}

var checkedLength=$("#mainTBX1 .list .dataRow .lcbXRow:checked").length;
if(licenseStatus!='Active' && licenseStatus!='ActiveP' && (checkedLength>5 || getStoredNumPPL("massMergeX")>7)){ 
		licenseReqMessage("During the free trial the mass-merge option is limited to 5 rows per shot / 7 shots in total."); 
		return; 
} 
if(isEditMode1){
	alert("Mass Merge only works in view-mode, Save / Cancel your changes first."); 
	return;
}
if(checkedLength<2){ 
alert("Please select the rows you want to merge.\nYou must select at least 2 rows in each color-based-row-group that you want to merge."); 
}else{ 
var groupCount=0; 
var allGroupsok=true; 
var ix=1; 
var arrToMerge=new Array(); 
$("#mainTBX1 .list .dataRow").each(function(){ 
if(!$(this).hasClass("tcx"+ix)){ 
ix=1-ix; 

if(arrToMerge.length==1){ 
allGroupsok=false; 
} 
if(arrToMerge.length>0){ 
groupCount++; 
} 
arrToMerge=new Array(); 

}else{ 

} 
if($(this).find(".lcbXRow").prop("checked")){ 
var idX=$(this).find(".lcbXRow").parents(".lcbX").attr("rid"); 
arrToMerge.push(idX); 
} 
}); 
if(arrToMerge.length==1){ 
allGroupsok=false; 
} 
if(arrToMerge.length>0){ 
groupCount++; 
} 

if(!allGroupsok){ 
alert("One of the selected groups has 1 selected row to merge - please select more than 2 rows for each group."); 
}else{ 
if(confirm("Mass Merge process overview: \n1) The first selected row in each color-based-row-group will be the master i.e. unless you mark the master (in purple) by hovering the row's checkbox & click the mark as master link.\n\n2) Click on a field to copy it's content to the master-row during the merge process.\n\n3) Use the checkboxes to restrict the rows you want to merge.\nYOU SHOULD DO THE ABOVE PRIOR TO CLICKING OK\n\n Do you want to start the mass merge process on the below selected color-based-row-groups (only the current page will be merged)?") 
&& confirm("\n\nAre you sure you want to merge the selected groups ("+groupCount+")? \n\n ") 
){ 
loadingSH(); 
//start merge

arrToMergeRequests=new Array(); 
totalMerged=0;
continueToNextGroup=true; 
startMerge1();

} 
} 

}
}//end mass merge


var arrToMergeRequests=new Array(); 
var totalMerged=0;
var continueToNextGroup=true; 
function startMerge1(){

var ix=1; 

var arrToMerge=new Array(); 
var overwriteFields={};
$("#mainTBX1 .list .dataRow").each(function(){ 
if(!$(this).hasClass("tcx"+ix)){ 
ix=1-ix; 
if(continueToNextGroup && arrToMerge.length>1){ 
var arrToMergeT=arrToMerge.slice(1,arrToMerge.length); 
while(arrToMergeT.length>0){ 
var masterRecord=arrToMerge[0];
var recordToMergeIds=arrToMergeT.slice(0,Math.min(2,arrToMergeT.length)); 
var tempArr=new Array();
tempArr[0]=masterRecord;
tempArr[1]=recordToMergeIds;
tempArr[2]=JSON.stringify(overwriteFields);
arrToMergeRequests.push(tempArr);

//alert(Res); 
//arrToMergeRequests.push(masterRecord); 
if(arrToMergeT.length>2){ 
arrToMergeT=arrToMergeT.slice(2,arrToMergeT.length); 
}else{ 
arrToMergeT=new Array(); 
} 
} 
} 
arrToMerge=new Array(); 
overwriteFields={};
}else{ 

} 
if($(this).find(".lcbXRow").prop("checked")){ 
	var idX=$(this).find(".lcbXRow").parents(".lcbX:first").attr("rid");
	var tr1=$(this); 
	
	if(tr1.hasClass("gnzMSR")){//master
		arrToMerge.unshift(idX);//place first
	}else{
		arrToMerge.push(idX);
		//overwrite fields
	}
		tr1.find("td.copyCellMark[fld]").each(function(){
			var old1=overwriteFields[$(this).attr("fld")];
			var cimg=$(this).find("img.checkImg");
			var cbMark=(cimg.length>0 && cimg.attr("src")=="/img/checkbox_checked.gif");//checked
			var tpx=$("#mainTBX1 .headerRow th."+$(this).attr("fld")).attr("tpx")+"";
			//alert(cbMark+ " "+tpx);
			if(old1==null || cbMark){
				overwriteFields[$(this).attr("fld")]=idX;
			}else if(tpx=="1" || tpx=="11" || tpx=="9f" || tpx=="9"){//11 multipicklist
				overwriteFields[$(this).attr("fld")]=old1+"~"+ idX;
			}
		}); 
		var combineTA1="";
		tr1.find("td.combineTA1[fld]").each(function(){
			var fld1=$(this).attr("fld");
			var combinefield=$(this).attr("combinefield");
			if(combinefield==""){
				combinefield=(MassMergefieldsToAvilOvAct[fld1].split("~")[1]);
			}
			var cm1=fld1+"~"+combinefield;//(MassMergefieldsToAvilOvAct[fld1].split("~")[1]);//from field~to field
			//alert(cm1+ " " +combineTA1.indexOf(cm1));
			if(combineTA1.indexOf(';'+cm1)==-1){
				combineTA1+=";"+cm1;
			}
		});
		if(combineTA1!=""){
			overwriteFields["combineTA"]=combineTA1;
		}
		if(massMergeX1RLSel!=""){
			overwriteFields["CopyRL"]=massMergeX1RLSel;
		}
} 

}); 

if(continueToNextGroup && arrToMerge.length>1){
 
var arrToMergeT=arrToMerge.slice(1,arrToMerge.length); 
while(arrToMergeT.length>0){ 
var masterRecord=arrToMerge[0]; 
var recordToMergeIds=arrToMergeT.slice(0,Math.min(2,arrToMergeT.length)); 
var tempArr=new Array();
tempArr[0]=masterRecord;
tempArr[1]=recordToMergeIds;
tempArr[2]=JSON.stringify(overwriteFields);
arrToMergeRequests.push(tempArr);

//alert(Res); 
//arrToMergeRequests.push(masterRecord); 
if(arrToMergeT.length>2){ 
arrToMergeT=arrToMergeT.slice(2,arrToMergeT.length); 
}else{ 
arrToMergeT=new Array(); 
}
} 
} 

startMerge2(0);

//end merge
}

var hadError=false;
function startMerge2(idx){
	
		if(continueToNextGroup&& arrToMergeRequests.length>idx){
			
		var tempArr=arrToMergeRequests[idx]
	Visualforce.remoting.Manager.invokeAction(
                remoteMassMerge,
                 lastmainObjToMerge,
                tempArr[0],
				tempArr[1].join("~"),
				tempArr[2],				
                function(result, event){
                    if (event.status && result!=null) {

						if(result[0]=='OK'){ 
							for(var x1=0;x1<tempArr[1].length;x1++){ 
							var tempID=tempArr[1][x1]; 
							$(".lcbX[rid='"+tempID+"']").parents("tr:first").css({"background":"#CCCCCC"}); 
							} 
						}else{ 
						$(".lcbX[rid='"+tempArr[0]+"']").parents("tr:first").css({"background":"#FFCCCC"}); 
						alert("Error during merge: "+result[1]+" \n\n Master Record Id: "+tempArr[0]+" \n\n"); 
						continueToNextGroup=confirm("Do you want to continue the merge process (skip the current group & continue)?\n\n");
						hadError=true; 
						var foundZ1=false;
						for(var i=idx+1;i<arrToMergeRequests.length && !foundZ1;i++){
							if(arrToMergeRequests[i][0] !=arrToMergeRequests[idx][0]){
								foundZ1=true;
								idx=i-1;
							}
						} 
                        }
                        totalMerged++;
						startMerge2(idx+1);
                     } else if (event.type === 'exception') {
                        if(event.message!=null && ((event.message+"").indexOf("Logged in")>-1 || (event.message+"").indexOf("Refresh page")>-1)){
                            self.location=self.location;
                        }else if(event.message!=null && (event.message+"").indexOf("Unable to connect")==-1){
                            if($("body:visible").length>0)alert("An error has occurred: "+event.message);
                        }
                    } 
                }, 
                {escape: true,buffer:true,timeout: 90000}
            );
			}else{
		
		
			$("#loadingx1").hide(); 
			if(!continueToNextGroup && totalMerged>0 && confirm("The following Grayed out rows were merged successfully.\n\n Do you want to refresh the table?")){ 
			jumpToClk(currPageCls,600); 
			}else if(continueToNextGroup && totalMerged>0){ 
			 
			// alert(Res); 
			tempLayerMessage("Mass Merge has finished "+(!hadError?" successfully ":"<br/>")+"<br/>The affected rows where saved as a CSV under the Files tab",!hadError);
			jumpToClk(currPageCls,600); 
			} 

			}
	
    }
    function markAsMaster(idx){
    	var obj=$(".lcbX[rid='"+idx+"']");
    	if(!obj.find(".lcbXRow").is(":checked")){
    		obj.find(".lcbXRow").click();
    	}	
    	var tr1=(obj).parents("tr:first");
    	var gnz=tr1.attr("gnz");
    	$("#mainTBX1 tbody tr[gnz='"+gnz+"']").removeClass("gnzMSR");
    	tr1.addClass("gnzMSR");
    }
    var MassMergefieldsToAvilOv=new Array();
    
    function drillDown(confName){
	    var checkedIds=""; 
		$(".lcbX input:checked").each(function(){ 
			checkedIds+="~"+$(this).parents(".lcbX:first").attr("rid"); 
		}); 
		if(checkedIds==""){ 
			alert(Please_select_at_least_one_row); 
		}else{ 
			window.open("/apex/zaapit__zaapit_tb_GeneralWL?isdtp=p1&tp="+confName+"&viewid=&id="+escape(checkedIds.substring(1)),"_blank"); 
		
		} 
		return false;
	}



	/****mass convert***remotemassConvert*/
	
	function openMassConvert(){
		trackEventX('openMassConvert');
		var checkedLength=$(".lcbX input:checked").length;
		if(licenseStatus!='Active' && licenseStatus!='ActiveP' && ( checkedLength>5 || getStoredNumPPL("MassConvert")>7)){ 
			licenseReqMessage("During the free trial the mass-convert option is limited to 5 rows per shot / 7 shots in total."); 
			return; 
 
		} 
				var checkedIds=""; 
				var checkedIdsArr=new Array(); 
				var currentLeadIdx=0;
		var checkedId1=""; 
		var leadCount=0; 
		$(".lcbX input:checked").each(function(){ 
		checkedId1=$(this).parents(".lcbX:first").attr("rid"); 
		//alert(checkedId1.length); 
		if(checkedId1!=null && checkedId1.length==18){ 
		//checkedId1=checkedId1.substring(0,15); 
		} 
		checkedIds+=","+checkedId1; 
		checkedIdsArr.push(checkedId1);
		leadCount++; 
		}); 
		if(leadCount<1){ 
		alert("Please select at least one row"); 
		}else{ 


		function appendTags(){ 
		$('#dialog-mass-convert').remove(); 

		$('body').append( 
		'<div id="dialog-mass-convert" title="Mass Convert">' + 
		'<div style="margin:10px;font-weight:bold;">Mass convert Options:'+ 
		'</div>'+
		'<input type="checkbox" name="contactFind" id="contactFind" checked/> Find Contact <div style="color:#696969;margin-bottom:15px;margin-top:3px;">Try to find an existing contact by using lead\'s email (before you create a new Contact & Account)</div>' +
		
		'<input type="checkbox" name="overwriteContactLeadSource" id="overwriteContactLeadSource"/> Overwrite the lead-source  <div style="color:#696969;margin-top:3px;margin-bottom:15px;">Overwrite the contact\'s lead-source with the lead\'s source when a matching contact is found</div>' +
		 
		'<input type="checkbox" name="accountFind" id="accountFind" checked/> Find Account <div style="color:#696969;margin-top:3px;margin-bottom:15px;">Try to find an existing account before you create a new account by comparing the lead\'s <span id="LeadFieldSelLC">Loading...</span> field against the Account\'s <span id="AccountFieldSelLC">Loading...</span> field</div>' + 
 
		'<span style="display:inline-block;width:95px;">Opportunities:</span> <select name="createOpp" id="createOpp"><option value="0">Don\'t create any opportunities </option><option value="1">Create for each converted lead</option><option value="2">Create for the first converted lead</option></select>  <div style="color:#696969;margin-top:3px;margin-bottom:15px;">Create an opportunity for each/first converted lead</div>' +
		
		'<span style="display:inline-block;width:95px;">Owner:</span> <span id="ownerSelLC"></span> <div style="color:#696969;margin-top:3px;margin-bottom:15px;">An owner for the new contacts / Accounts / Opportunities</div>'+
		'<input type="checkbox" name="sendEmailToOwner" id="sendEmailToOwner"/> Send email to owner <div style="color:#696969;margin-top:3px;margin-bottom:15px;">Send email to owner upon new contact/account creation/conversion. </div><br>' +
		
		'<span style="display:inline-block;width:95px;">Lead Status:</span> <span id="LeadStatusSelLC"></span></br></br> '+ 
		
				
		//'Mass Email Name <input type="text" name="descriptionME" id="descriptionME" />' + 


		'' + 
		'' 

		); 

		} 

		function createPopupWindow(){ 
		
		 var buttons1=new Array();
			buttons1.push({ 
		text: "Mass Convert - Selected ("+($(".lcbX input:checked").length)+")",
		click: function() { 
		if(($("#LeadFieldSelLCID").val()=='Company' && $("#AccountFieldSelLCID").val()=="Name") || confirm("Are you sure you want convert the selected lead(s)?")){
		startMassConvert(); 
		jQuery( this ).dialog( "close" ); 
		}
		}});
		if(Enable_ZaapIT_s_Layout_Editor=="true" && $("input.lcbXAll:first").is(":checked")){
			buttons1.push({
			text: "Mass Convert - ALL ("+totRowsForFOUNDONQ+")", 
			click: function() { 
			startMassConvertALL(); 
			jQuery( this ).dialog( "close" ); 
			}});
		}
		buttons1.push({
		text: "Cancel", 
		click: function() { 
		jQuery( this ).dialog( "close" ); 
		} 
		});
		
		$( "#dialog-mass-convert" ).dialog({ 
		resizable: false, 
		width: (isSF1()?($("body").width()-10):490), 
		height:(isSFLight1XV?610:600), 
		//modal: true, 
		buttons: buttons1
		}); 
			fixIfmHegt();
		} 

		function messagePopupWindow(message){ 
		$( "#dialog-mass-convert" ).html(message).dialog({ 
		resizable: false, 
		width: 400, 
		height:250, 
		//modal: true, 
		buttons: { 

		Close: 
		function() { 
		$( this ).dialog( "close" ); 
		} 
		},close:function(){ 
		$(".lcbX input:checked").click(); 
		} 
		}); 
		} 

		function fetchData(){ 

		//lead ownerid
		var queryZZZ="SELECT Id,Name FROM user where isactive=true and (not profile.name  like '%Community%') order by name asc limit 5000"; 
		Visualforce.remoting.Manager.invokeAction( 
		remoteQueryAjax2, 
		queryZZZ, 
		function(result, event){ 

		if (event.status && result!=null) { 

		var innerHtml = ''; 
		var records=result; 
		for(var i=0; i<records.length; i++) 
		innerHtml += 
		'<option value="' + records[i].Id + '">'+records[i].Name +	'</option>'; 

		$('#ownerSelLC').html('<select name="ownerSelLCID" id="ownerSelLCID"><option value="">Lead Owner</option>'+innerHtml+'</select>'); 
		} else if (event.type === 'exception') { 
		if(event.message!=null && ((event.message+"").indexOf("Logged in")>-1 || (event.message+"").indexOf("Refresh page")>-1)){ 
		self.location=self.location; 
		}else if(event.message!=null && (event.message+"").indexOf("Unable to connect")==-1){ 
		if($("body:visible").length>0)alert("An error has occurred: "+event.message); 
		} 
		} else { 
		//self.location=self.location; 
		// $("#"+filterIdSpan+" .availVals").html(""); 
		//alert(1); 
		} 

		}, 
		{escape: true,buffer:true,timeout: 90000} 
		); 
		
		//lead status
		var queryZZZ2="SELECT Id,MasterLabel FROM LeadStatus WHERE IsConverted=true order by MasterLabel asc"; 
		Visualforce.remoting.Manager.invokeAction( 
		remoteQueryAjax2, 
		queryZZZ2, 
		function(result, event){ 

		if (event.status && result!=null) { 

		var innerHtml = ''; 
		var records=result; 
		for(var i=0; i<records.length; i++) 
			innerHtml += 
				'<option value="' + records[i].MasterLabel + '">'+records[i].MasterLabel +'</option>'; 

			$('#LeadStatusSelLC').html('<select name="LeadStatusSelLCID" id="LeadStatusSelLCID">'+innerHtml+'</select>'); 
		} else if (event.type === 'exception') { 
		if(event.message!=null && ((event.message+"").indexOf("Logged in")>-1 || (event.message+"").indexOf("Refresh page")>-1)){ 
		self.location=self.location; 
		}else if(event.message!=null && (event.message+"").indexOf("Unable to connect")==-1){ 
		if($("body:visible").length>0)alert("An error has occurred: "+event.message); 
		} 
		} else { 
		//self.location=self.location; 
		// $("#"+filterIdSpan+" .availVals").html(""); 
		//alert(1); 
		} 

		}, 
		{escape: true,buffer:true,timeout: 90000} 
		); 
		
		
		//lead fields
		Visualforce.remoting.Manager.invokeAction( 
		remotequeryAjax2GetTbFields, 
		'Lead', 
		function(result, event){ 

		if (event.status && result!=null) { 

		var innerHtml = ''; 
		var records=result; 
		for(var i=0; i<records.length; i++) 
			if(records[i].childRel=="0" && records[i].name.indexOf("__xx")==-1) innerHtml += 
				'<option value="' + records[i].name + '">'+records[i].label +'</option>'; 

			$('#LeadFieldSelLC').html('<select name="LeadFieldSelLCID" id="LeadFieldSelLCID">'+innerHtml+'</select>');
			$("#LeadFieldSelLCID").val("Company"); 
		} else if (event.type === 'exception') { 
		if(event.message!=null && ((event.message+"").indexOf("Logged in")>-1 || (event.message+"").indexOf("Refresh page")>-1)){ 
		self.location=self.location; 
		}else if(event.message!=null && (event.message+"").indexOf("Unable to connect")==-1){ 
		if($("body:visible").length>0)alert("An error has occurred: "+event.message); 
		} 
		} else { 
		//self.location=self.location; 
		// $("#"+filterIdSpan+" .availVals").html(""); 
		//alert(1); 
		} 

		}, 
		{escape: true,buffer:true,timeout: 90000} 
		); 
		
		
		//account fields
		Visualforce.remoting.Manager.invokeAction( 
		remotequeryAjax2GetTbFields, 
		'Account', 
		function(result, event){ 

		if (event.status && result!=null) { 

		var innerHtml = ''; 
		var records=result; 
		for(var i=0; i<records.length; i++) 
			if(records[i].childRel=="0" && records[i].name.indexOf("__xx")==-1) innerHtml += 
				'<option value="' + records[i].name + '">'+records[i].label +'</option>'; 

			$('#AccountFieldSelLC').html('<select name="AccountFieldSelLCID" id="AccountFieldSelLCID">'+innerHtml+'</select>'); 
			$("#AccountFieldSelLCID").val("Name");
		} else if (event.type === 'exception') { 
		if(event.message!=null && ((event.message+"").indexOf("Logged in")>-1 || (event.message+"").indexOf("Refresh page")>-1)){ 
		self.location=self.location; 
		}else if(event.message!=null && (event.message+"").indexOf("Unable to connect")==-1){ 
		if($("body:visible").length>0)alert("An error has occurred: "+event.message); 
		} 
		} else { 
		//self.location=self.location; 
		// $("#"+filterIdSpan+" .availVals").html(""); 
		//alert(1); 
		} 

		}, 
		{escape: true,buffer:true,timeout: 90000} 
		); 
		
		
		
		} 

		function startMassConvert(){ 
			loadingSH();
			//alert(checkedIdsArr[currentLeadIdx]);
			//lead_MasterLabel~find account 0/1~find contact 0/1~owenrid~create opportunity 0/1
			var options=$("#LeadStatusSelLCID").val()+"~"+($("#accountFind").prop("checked")?1:0)+"~"+($("#contactFind").prop("checked")?1:0)+"~"+$("#ownerSelLCID").val()+"~"+($("#createOpp").val()==1 || ($("#createOpp").val()==2&& currentLeadIdx==0)?1:0)+"~"+$("#LeadFieldSelLCID").val()+"~"+$("#AccountFieldSelLCID").val()+'~0~'+($("#overwriteContactLeadSource").prop("checked")?1:0)+"~0~"+($("#sendEmailToOwner").prop("checked")?1:0)+"~ ~";
		Visualforce.remoting.Manager.invokeAction( 
		remotemassConvert, 
		checkedIdsArr[currentLeadIdx], //id
		options, 
		function(result, event){ 
		var continueMerge=true;
		
		if (event.status && result!=null) { 
		
		if((result+"").indexOf("OK")==0){ 
			$(".lcbX[rid='"+checkedIdsArr[currentLeadIdx]+"']").parents("tr:first").css({"background":"#CCCCCC"}); 
			//messagePopupWindow('<br><span class="ui-icon ui-icon-check" style="float:left;margin-right:10px;display:inline-block;"></span><b>Your email(s) have been submitted for processing.</b><br><br>The Mass-Mailer result will be sent to you via email.'); 

		}else{ 
			$(".lcbX[rid='"+checkedIdsArr[currentLeadIdx]+"']").parents("tr:first").css({"background":"#FFCCCC"}); 
			continueMerge=confirm('Error while converting lead: '+result+'\n\nDo you want to continue the merge process?'); 
			hadError=true;
		} 
			currentLeadIdx++;
			if(continueMerge&& currentLeadIdx<=checkedIdsArr.length-1){
				startMassConvert();
			}else{
				tempLayerMessage("Mass Convert has finished "+(!hadError?" successfully ":"<br/>"),!hadError);
				jumpToClk(currPageCls,600); 
			}
		} else if (event.type === 'exception') { 
		if(event.message!=null && ((event.message+"").indexOf("Logged in")>-1 || (event.message+"").indexOf("Refresh page")>-1)){ 
		self.location=self.location; 
		}else if(event.message!=null && (event.message+"").indexOf("Unable to connect")==-1 ){ 
		if($("body:visible").length>0)alert("An error has occurred: "+event.message); 
		} 
		} else { 
		//self.location=self.location; 
		// $("#"+filterIdSpan+" .availVals").html(""); 
		//alert(1); 
		} 

		}, 
		{escape: true,buffer:true,timeout: 90000} 
		); 

		
		} 

		appendTags(); 
		fetchData(); 
		createPopupWindow(); 


		} 
	}
	
	
	function startMassConvertALL(){
		
			if(licenseStatus!='Active' && licenseStatus!='ActiveP' && ( totalCountAjx>5 || getStoredNumPPL("MassConvert")>7)){ 
				licenseReqMessage("During the free trial mass-convert-all is limited to 5 rows per shot / 7 shots in total."); 
				return false; 
			}else if(!confirm('Are you sure you want to Convert ALL the rows ('+totRowsForFOUNDONQ+')?\n\nPlease note that the filters and search will remain the same after the conversion is completed.\nMeaning, you will see 0 results on this page.')){
				return false;
			}
			
			openAllmassActionAll("Starting Mass Convert...#Stop#Stopping...#Current Progress: #Complete!#Close#Are you sure?\n\nThis is the second and last confirm for MASS CONVERT ALL!#Mass Convert All Rows",convertRowInMassConvertAll,1);
			
	}

	function convertRowInMassConvertAll(leadid){
			//alert(leadid);
			//alert(checkedIdsArr[currentLeadIdx]);
			//lead_MasterLabel~find account 0/1~find contact 0/1~owenrid~create opportunity 0/1~lead's field Company~account field Name~convertOnlyWhenAMatchingContactWasFound~overwriteContactLeadSourceWhenExist~convertOnlyWhenAMatchingAccountWasFound~sendEmailToOwner~opportunityName
			var options=$("#LeadStatusSelLCID").val()+"~"+($("#accountFind").prop("checked")?1:0)+"~"+($("#contactFind").prop("checked")?1:0)+"~"+$("#ownerSelLCID").val()+"~"+($("#createOpp").val()==1 || ($("#createOpp").val()==2&& currentLeadIdx==0)?1:0)+"~"+$("#LeadFieldSelLCID").val()+"~"+$("#AccountFieldSelLCID").val()+'~0~'+($("#overwriteContactLeadSource").prop("checked")?1:0)+"~0~"+($("#sendEmailToOwner").prop("checked")?1:0)+"~ ~";
		Visualforce.remoting.Manager.invokeAction( 
		remotemassConvert, 
		leadid, //id
		options, 
		function(result, event){ 
		var continueMerge=true;
		
		if (event.status && result!=null) { 
		
		if((result+"").indexOf("OK")==0){ 
			messageCellMActionALL=""; 
			//doAllmassActionAll("1"); 
		}else{ 
			messageCellMActionALL="Error while converting a lead"; 
			//doAllmassActionAll("1"); 
			continueMerge=confirm('Error while converting a lead: '+result+'\n\nDo you want to continue the merge process?'); 
			hadError=true;
		} 
			if(continueMerge){
				messageCellMActionALL=""; 
			
			}
			doAllmassActionAll("1"); 
		} else if (event.type === 'exception') { 
		if(event.message!=null && ((event.message+"").indexOf("Logged in")>-1 || (event.message+"").indexOf("Refresh page")>-1)){ 
		self.location=self.location; 
		}else if(event.message!=null && (event.message+"").indexOf("Unable to connect")==-1 ){ 
			messageCellMActionALL="An error has occurred: "+event.message; 
			doAllmassActionAll("1"); 
		} 
		} else { 
		//self.location=self.location; 
		// $("#"+filterIdSpan+" .availVals").html(""); 
		//alert(1); 
		} 

		}, 
		{escape: true,buffer:true,timeout: 90000} 
		); 

		
} 


	function tempLayerMessage(text,ok){
		$(".msgOKgGLCont").remove();
		if(ok){
			text="<div class='msgOKGL'>"+text+"</div>";
		}else{
			text=text+" <br/><a href=\"javascript:void(0);\" onclick=\"$('.msgOKgGLCont').hide();\" style=\"margin-left:45%;font-size:12px;\">Close</a>";
		}
		$("body").append($("<div class='msgOKgGLCont'>"+text+"</div>"));
		if(ok){
			setTimeout(function(){
				$(".msgOKgGLCont").hide();
			},5500);
		}else{
			setTimeout(function(){
				$(".msgOKgGLCont").hide();
			},30000);
		}
		hadError=false;
	}
	
	function tempLayerMessage2(text,milis,top,left){
		$(".msgOKgGLCont").remove();
		$("body").append($("<div class='msgOKgGLCont'>"+text+"</div>"));
		if(top!=null && left!=null){
			$(".msgOKgGLCont").css({"top":top,"left":left});
		}
		setTimeout(function(){
				$(".msgOKgGLCont").hide();
			},milis);
		hadError=false;
	}
	
	
	function openCondWin(){
		openGenWindow1("../apex/zaapit__zaapit_tb_viewstyle?id="+escape(currConf_name+"~"+$.trim($(".curSelectedView").val()))+"&tbname="+tableX1+"&isdtp=p1",Conditional_Formatting,1390,Math.max($(self).height()-50,550),null,function(){
		loadingSH();
		//self.location.reload();//jumpToClk(currPageCls,600);
		//alert(self.location.href);
		//self.location.href=self.location.href;
		refreshAfterSave();
		});
		fixIfmHegt();
	}
	
	function openCondWinMini(svid){
		var tempMark=new Array();
		var checkedRows=$("#mainTBX1 tbody tr .lcbX input:checked");
		if(checkedRows.length>0){
			checkedRows.each(function(){
				tempMark.push($(this).parents(".lcbX:first").attr("rid"));
			});
		}else{
			tempMark.push(lastIEID);
		}
		openGenWindow1("../apex/zaapit__View_Style_Mini_Editor?"+(svid!=""?"id="+svid:"A=1")+"&vid="+escape(currConf_name+"~"+$.trim($(".curSelectedView").val()))+"&tbname="+tableX1+"&ids="+escape(tempMark.join("~"))+"&fld="+lastIEFLD+"&rowsNum="+(tempMark.length)+"&isdtp=p1",Conditional_Formatting,480,530,null,function(){showCellMenuX1();});
		/*function(){
		loadingSH();
		//self.location.reload();//jumpToClk(currPageCls,600);
		//alert(self.location.href);
		//self.location.href=self.location.href;
		refreshAfterSave();
		}*/
		fixIfmHegt();
	}
	
	
	function markRowsLedg(tablex1,conditionEnc,pageIDS,cssName,vid){
		if(pageIDS!=null && pageIDS!=''){
			var queryZZZ="SELECT Id FROM "+tablex1+" where ("+decodeURIComponent(conditionEnc).replace(/\+/ig,' ')+") and id in ('"+(decodeURIComponent(pageIDS).replace(/\~/ig,"','"))+"')";
			Visualforce.remoting.Manager.invokeAction( 
			remoteQueryAjax2, 
			queryZZZ, 
			function(result, event){ 
	
			if (event.status && result!=null) { 
	
				var markRows = ''; 
				var records=result; //alert(result);
				for(var i=0; i<records.length; i++){ 
					markRows+=",tr.dataRow[rowid='"+(records[i].Id)+"']";
				} 
				//alert(markRows);
				if(markRows!="," && markRows!=""){
					$((markRows.substring(1))).addClass(cssName).attr("svid",vid);
					//$("."+cssName).parents(".legendCont:first").show();
				}else{
					$("."+cssName).parents(".legendCont:first").hide();
				}
				
				//alert(markRows);
			} else if (event.type === 'exception') { 
				if(event.message!=null && ((event.message+"").indexOf("Logged in")>-1 || (event.message+"").indexOf("Refresh page")>-1)){ 
					self.location=self.location; 
				}else if(event.message!=null && (event.message+"").indexOf("Unable to connect")==-1){ 
				if($("body:visible").length>0)alert("An error has occurred: "+event.message); 
				} 
			} else { 
			//self.location=self.location; 
			// $("#"+filterIdSpan+" .availVals").html(""); 
			//alert(1); 
			} 
	
			}, 
			{escape: true,buffer:true,timeout: 90000} 
			); 
		}
		
	}
	
	function checkColumnFreeze(resize){
		setTimeout(function(){checkColumnFreeze1(resize);},50);
	}

	function checkColumnFreeze1(resize,setColFreezeNum){
			var mainTB1=$(".mainTB1");
			var p1 = $("#mainTBX1 .list .headerRow th.thw:first").position();
				if(numColumnsFreezeCols>0 && !isSF1()  || (setColFreezeNum!=null && numColumnsFreezeCols!=setColFreezeNum )){//(navigator.userAgent.indexOf("Chrome")>-1 || navigator.userAgent.indexOf("Firefox")>-1)
				if(resize!=null){
					$(".secTB1,.secTHW1").remove();
					mainTB1.removeAttr("hasSecTB");
				}
				var minusLeft=0;
				var minusTop=-10;
				var nav1=navigator.userAgent;
				if(nav1.indexOf("Chrome")==-1 && nav1.indexOf("Firefox")==-1){//IE
						minusTop=-6;
				}
				if(nav1.indexOf("Firefox")>-1){
					minusTop=0;
				}
				
				if(!isInIframe()){
					minusLeft=10;
					minusTop=96;
					if(nav1.indexOf("Firefox")>-1){
						minusTop=111;
					}
					if(nav1.indexOf("Chrome")==-1 && nav1.indexOf("Firefox")==-1){//IE
						minusTop=103;
					}
				}
			
			
			
			if(mainTB1.attr("hasSecTB")==null && $(".secTB1").length==0 && $(".secTHW1").length==0){
			mainTB1.attr("hasSecTB","1");
			if(setColFreezeNum!=null){
				numColumnsFreezeCols=setColFreezeNum;
			}
			var keepCols=numColumnsFreezeCols;
			//$(".secTB1").remove();
			//.mainTB1 table.list tbody td[fld],.mainTB1 table.list tbody td.iTd,.mainTB1 table.list thead th.thw
			$(".mainTB1 table.list tr").each(function(){
			//	$(this).width($(this).width());
				$(this).height($(this).height());
			});
			
			
			var tb1=$(".mainTB1 table.list:first").clone();
			tb1.find("tbody tr.dataRow,thead tr").each(function(){
				var thwNum=0;
				if($(this).css("display")!="none"){
					$(this).find("th,td").each(function(){
						
						if($(this).hasClass("thw") || $(this).attr("fld")!=null ||$(this).hasClass("iTd")){
							thwNum++;
						}
						if(thwNum==0 || thwNum>keepCols){
							$(this).remove();
						}else{
							$(this).css({"padding":"4px 2px 4px 5px"});
							if($(this).find("input,select").length>0){
								$(this).find("input,select").attr("readonly","readonly").attr("id","").attr("name","").attr("onclick","");
								$(this).find("input,select").css({"background":"#eeeeee","border":"1px solid #aaaaaa"});
				
							}
						}
					});
				}
			});
			//tb1.find("tbody tr.totalRow")
			tb1.find("tfoot").remove();
			tb1.find(".fltIC,wd1").remove();
			tb1.width("auto");
			//tb1.find("th.thw").width("auto");
			var thw1=tb1.find("tr.headerRow").clone()
			//var colWidth=thw1.width();
		
			thw1.find(".fltIC,.wd1").remove();

			var secTHW1=$("<span class='secTHW1'/>").append("<table border='0' cellspacing='0' cellpadding='0' width='100%' class='list'><thead>"+thw1.html()+"</thead></table>").css({"white-space":"no-wrap","display":"inline-block"});
			secTHW1.css({"border-right":"3px solid #eeeeff"}).find("tr").addClass("headerRow");
			var secTB1=$("<span class='secTB1'/>").append(tb1);
			
			 secTB1.find(".rowGrouping1").html("");
			  secTB1.find("tbody tr.totalRow").each(function(){var h1=$(this).height();if(h1==0) h1=13;$(this).html("<td colspan='"+keepCols+"'/>");});//height='"+h1+"'
			 
			$(".mainTB1").append(secTB1);
			$(".mainTB1").append(secTHW1);
			
			}
			//alert(p1.left+" "+$(self).scrollLeft());
			var mainTBX1=$("#mainTBX1:first");
			var mainTBX1OffsetTop=mainTBX1.offset().top;
			var mainTBX1OffsetLeft=mainTBX1.offset().left;
				
			if(mainTBX1OffsetLeft+10<$(self).scrollLeft()){
				
				

				$(".secTB1").css({"position":"fixed","top":(mainTBX1OffsetTop-$(self).scrollTop())+"px","left":"0px","z-index":"3","border-right":"3px solid #eeeeff"}).show();
				var floatTopHead=$(".btnicofltTBTOP:first");
				
				if(floatTopHead.is(":visible") && p1.top<$(self).scrollTop()){
					//$(".secTHW1 tr:first").width($(".secTB1").width()).css({"white-space":"no-wrap"});
					if(!$(".secTHW1").hasClass("widthFixed1")){
						$(".secTHW1").addClass("widthFixed1");
						$(".secTHW1 th").each(function(){
							var th1=$("#mainTBX1 .list thead tr.headerRow ."+($(this).attr("class").replace(/ /ig,".")));
							var width1=th1.width();
							var height1=th1.height();
							//alert(width1)
							$(this).width(width1).css({"border-right":"1px solid #e0e0e0","padding-right":"0px","height":height1+"px"});//,"background":"#FFFFFF"
							$(this).find("a").css({"text-decoration":"none"});
						});//,"background":"#f5f5f5" 
					}
					$(".secTHW1").width($(".secTB1").width()).css({"white-space":"no-wrap","display":"inline-block","position":"fixed","top":($("#btnicofltTB").position().top+$("#btnicofltTB").outerHeight())+"px","left":0+"px","z-index":"5"}).show();
				}else{
					$(".secTHW1").hide();
				}
			}else{
				$(".secTB1").hide();
				$(".secTHW1").hide();
			}
			if( $(".secTHW1").is(":visible")&& $(".secTHW1").position().top< $(".secTB1").position().top){
				$(".secTHW1").hide();
			}
			
		
			}
			
			}

	var startColPos_last=null;
	var startColPos_lastTXT=null;
	var startColPos_origCOl=null;
	var lastCOLMouseXY=null;
function startColPos(obj,e){
	startColPos_last=null;
	moveColPos_started=0;
	moveColPos_post=0;
	var isLeftClick=false;
	//alert(e.which)
   switch (e.which) {
        case 1:
            //alert('Left Mouse button pressed.');
            isLeftClick=true;
            break;
        case 2:
           // alert('Middle Mouse button pressed.');
            break;
        case 3:
        	
           // alert('Right Mouse button pressed.');
            break;
        default:
           // alert('You have a strange Mouse!');
    }
	if(isLeftClick && !isScrollMode()&& !isSF1()){
			lastCOLMouseXY=e.pageY+" "+e.pageX;
		$(obj).disableSelection().attr('unselectable', 'on')
                 .css('user-select', 'none')
                 .on('selectstart', false);
		$("body").disableSelection();
		startColPos_last=obj;
		startColPos_lastTXT=$(startColPos_last).text();
		$(".colPosMov,.colMarker").remove();
		$("body").append("<div class='colPosMov'><span class='ico'></span><div class='in'>"+startColPos_lastTXT+"</div></div><div class='colMarker'></div>");
		
		var cols=0;
			var origCOl=0;
			$(".mainTB1 .list th").each(function(){
				if($(this).attr("class")==$(startColPos_last).attr("class")){
					origCOl=cols;
				}
				cols++;
			});
			startColPos_origCOl=origCOl;
	}
}	

jQuery.fn.tagName = function() {
  return this.prop("tagName");
};

var moveColPos_started=0;
var moveColPos_post=0;
function moveColPos(e,finalSet){
	var obj=e.target;
	var curCOLMouseXY=e.pageY+" "+e.pageX;
	if(obj!=null && startColPos_last!=null && curCOLMouseXY!=lastCOLMouseXY){
		moveColPos_started=1;
			moveColPos_post=0;
			var cols=0;
			var currCOl=0;
		var thisTD=obj;
		//alert($(thisTD).prop("tagName"))
		if($(thisTD).tagName()!=null && $(thisTD).tagName()!="TD" && $(thisTD).tagName()!="TH"){
			thisTD=$(thisTD).parents("td:first,th:first")[0];
		}
		if($(obj).parents(".mainTB1:first").length==1){ //on table
			$(obj).parents("tr:first").find("th,td").each(function(){
				if($(this).attr("class")==$(thisTD).attr("class")){
					currCOl=cols;
				}
				cols++;
			});
			
			//if(finalSet!=null)alert($(thisTD).tagName()+" " +currCOl+" "+$(obj).parents(".mainTB1:first").length + " "+$(obj).parents("tr:first").find("th,td").length);
		}else{//not on table
			
		}
		if(currCOl>1){//position marker
			moveColPos_post=currCOl;
		}
		if(finalSet==null){
			$(".colPosMov").css({             
	            top: (e.pageY + 20) + "px",             
	            left: (e.pageX + 20) + "px",     
	            display:"block"
	        });   
	        if(currCOl>1){
		        var currTH=$(".mainTB1 .list thead tr th:eq("+moveColPos_post+")");
		        var currTHPOS=currTH.offset();
		        $(".colMarker").css({             
		            top: (currTHPOS.top-8) + "px",             
		            left: (currTHPOS.left-3) + "px",     
		            display:"block"
		        });
		        if(startColPos_origCOl!=currCOl){
		        	$(".colPosMov").find(".ico").removeClass("no").addClass("ok");
		        }else{
		        	$(".colPosMov").find(".ico").removeClass("ok").addClass("no");
		        }   
	        }else{
	        	$(".colPosMov").find(".ico").removeClass("ok").addClass("no");
	        }
        }
	}
}
function stopColPos(e){
	
	if(startColPos_last!=null){
		if(moveColPos_post==0){
			moveColPos(e,1);
		}
		
		var cols=0;
		var origCOl=0;
		$(".mainTB1 .list th").each(function(){
			if($(this).attr("class")==$(startColPos_last).attr("class")){
				origCOl=cols;
			}
			cols++;
		});
		if(moveColPos_post>0 && moveColPos_post!=origCOl){
			 $(".mainTB1 .list tr").each(function() { 
	            $(this).children(":eq("+moveColPos_post+")").before($(this).children(":eq("+origCOl+")"));
	        });
	       $(".colPosMov,.colMarker").remove();
	       //$(".filterino").remove();
	       reorderColumns(origCOl,moveColPos_post);
	       setTimeout(showSaveAlert,500);
        }else if( moveColPos_post==0 || moveColPos_post==origCOl){
        	var currTH=$(".mainTB1 .list thead tr th:eq("+origCOl+")");
		        var currTHPOS=currTH.offset();
		        $(".colMarker").animate({             
		            top: (currTHPOS.top-8) + "px",             
		            left: (currTHPOS.left-3) + "px"
		        },function(){$(".colMarker").remove();});  
		        $(".colPosMov").animate({             
		            top: (currTHPOS.top) + "px",             
		            left: (currTHPOS.left) + "px"
		        },function(){$(".colPosMov").remove();}); 
        }
		startColPos_last=null;
		stopProp1(e);
		$("body").enableSelection();
		setTimeout(function(){moveColPos_started=0;},500);
		return false;
	 }
	 setTimeout(function(){moveColPos_started=0;},500);
}
function clearColPos(){
	$(".colPosMov,.colMarker").remove();
	startColPos_last=null;
}

function massDeleteSelected(){
	trackEventX('massDeleteSelected');
var c1=$('.lcbX input:checked').length;
if(c1==0){
   alert('Please select at least one row.');
   return false;
}else if(licenseStatus!='Active' && licenseStatus!='ActiveP' &&( c1>50 || getStoredNumPPL("massDelete")>7)){ 
		licenseReqMessage("During the free trial mass-delete is limited to 50 rows per shot / 7 shots in total."); 
		return false; 
}else if(!confirm('Are you sure you want to delete the selected rows ('+c1+')?')){ 
	return false;
}else{
	loadingSH();
	return true;
}

}
/*
function massDeleteAll(){

	if(licenseStatus!='Active' && licenseStatus!='ActiveP' && totalCountAjx>50){ 
			licenseReqMessage("During the free trial mass-delete is limited to 50 rows per shot."); 
			return false; 
	}else if(!confirm('Are you sure you want to DELETE ALL the rows ('+totRowsForFOUNDONQ+')?\n\nPlease note that the filters and search will remain the same after the deletion is completed.\nMeaning, you will see 0 results on this page.')|| !confirm('Are you sure?\n\nThis is the second and last confirm for Delete ALL!')){
		return false;
	}else{
		loadingSH();
		return true;
	}
}
*/

function trackEventX(str){
	try{
	var orgid_subscr_pg=orgID+"~"+EntitySubscription_SubscriberId+"~"+confName+"";
	ga('send', 'event', str, ''+orgid_subscr_pg, {'campaignName':'zp-app','eventLabel':str,
	  'campaignSource':orgID,
	  'campaignMedium': 'app',
	  'utm_content' :"main"});
	  }catch(e3){}
}
function filpEditModeJS(){
	trackEventX('filpEditModeJS1');
	filpEditModeJS1();
}
function trackgaX(){
	try{
	var language = window.navigator.userLanguage || window.navigator.language;
	if(language==null){
		language="-";
	}
	language=escape(language);
	var availHeight=window.screen.availHeight;
	var availWidth=window.screen.availWidth;
	var colorDepth=escape(screen.colorDepth);
	var loc5=(self.location.href+"");
	var loc5Rel=escape(loc5.substring(loc5.indexOf(".com")+4));
	loc5=escape(loc5);
	var orgid_subscr_pg=orgID+"~"+EntitySubscription_SubscriberId+"~"+confName;
	//var ga1="https://www.google-analytics.com/__utm.gif?utm_campaign=zp-app&utmwv=4&utmn="+new Date().getTime()+"&utmhn=zaapit.com&utmcs=-&utmsr="+availWidth+"x"+availHeight+"&utmsc="+colorDepth+"&utmul="+language+"&utmje=1&utmcn=1&utmdt=title&utmhid=20160915553&utm_source=zp-app&utm_content="+orgID+"&utme="+EntitySubscription_SubscriberId+"&utm_medium=app&utmac=UA-25982415-1&utmp="+loc5Rel+"&utmr="+(loc5)+"";
	//if($("#imageTRKga").length>0){
	//	$("#imageTRKga").attr("src",ga1);
	//}
	
	  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
	  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
	  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
	  })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');
	
	  ga('create', 'UA-25982415-3', {'campaignName':'zp-app',
	  'campaignSource':orgID,
	  'campaignMedium': 'app',
	  'utm_content' :"main"});
	  ga('send', 'pageview');
	  trackEventX('enterPage');
	  /*ga('send', 'event', 'enterPage', ''+orgid_subscr_pg, {'campaignName':'zp-app',
	  'campaignSource':'zp-app',
	  'campaignMedium': 'app',
	  'utm_content' :"main"});
	  */
	  //alert("+++");
	  }catch(e3){}
}

function setFavMob(curView,favView){
		var clear=(curView==" " && favView=="-") || curView==favView;
		var favView=(!clear?curView:"");
		if(favView==" "){
			favView="-";
		}
		//alert(favView);
		$(".curSelectedView").attr("fav",favView).change();
}
var searchSelMainObj=null;
function openSearchSel(obj,event){
	if(!isSF1()){
		searchSelMainObj=obj;
		
		var searchSel=$("#viewDPSP1.searchSelMainOut");
		//$(".searchSelMainOut").remove();
		var objID="viewDPSP1";
		if($(".searchSelMainOut:visible").size()>=1){
            $(".searchSelMainOut:visible").each(function(){
            	if($(this).attr("id")!=objID) $(this).hide();
            });
        }
                        
			
			//$(".searchSelMainOut").remove();
			if(searchSel.length==0){
				$("body").append("<span id='viewDPSP1' class='searchSelMainOut'><input type='search' placeholder='"+Search_label+"' class='searchSelMainIn' value='' onkeyup='searchSelX(this);' onsearch='searchSelX(this);' onmouseup='searchSelX(this);' onkeydown='searchSelUPDWX(event);'/><div class='searchSelMainOpts'/></span>");
				var ObjPos=$(obj).offset();
				$("#viewDPSP1.searchSelMainOut").css({"position":"absolute","top":(ObjPos.top+$(obj).height()+3)+"px","left":ObjPos.left+"px","z-index":1005,"width":($(obj).width()+35)+"px"});
			}else{
            	if(searchSel.is(":visible")){
               		searchSel.hide();
               	}else{
               		searchSel.show();
               	}
            }
			var html11=$(obj).html();
			//alert(html11);
			html11=html11.replace(/\<option/ig,"<div class='opt' ");
			html11=html11.replace(/\<\/option\>/ig,"<span class='fav' onmouseover='fixTitlex2(this,false,\"B\");' title='Save this view as my favorite view.<br/>Your favorite view will be auto-selected for you on your next visit.'>&#x2605;</span></div>");
			$("#viewDPSP1 .searchSelMainOpts").html(html11);
			$("#viewDPSP1.searchSelMainOut .searchSelMainOpts .opt[selected]").addClass("sel");//.append("");
			
			$("#viewDPSP1 .searchSelMainIn:visible").focus();
			$("#viewDPSP1.searchSelMainOut .opt .fav").click(function(e){
				if($(this).parents(".opt:first").hasClass("m")){
					$(searchSelMainObj).attr("fav","");
				}else{
					var favView=$(this).parents(".opt:first").attr("value");
					if(favView==" "){
						favView="-";
					}
					//alert(favView);
					$(searchSelMainObj).attr("fav",favView);
				}
				//stopProp1(e);
			});
		
			var favView=$(searchSelMainObj).attr("fav");
			if(favView=="-"){
				favView=" ";
			}
			//alert("+++"+favView+"+++");
			$("#viewDPSP1.searchSelMainOut .opt[value='"+favView+"']").addClass("m");
			$("#viewDPSP1.searchSelMainOut .searchSelMainOpts .opt").click(function(){
				$("#viewDPSP1.searchSelMainOut .opt.sel").removeClass("sel");
				$(this).addClass("sel");
				$(searchSelMainObj).val($(this).attr("value")).change();
				$("#viewDPSP1.searchSelMainOut:visible").hide();
			});
		searchSelX($("#viewDPSP1 .searchSelMainIn")[0]);
		return false;
	}else{
		return true;
	}

}
function openSelXDP(obj,e){ 

	if (!isSF1() && e.keyCode == '40') {// down arrow
		openSearchSel(obj,e);
		return false;
	}
	return isSF1();
}
function searchSelX(obj){
	var valToSearch=$(obj).val().toLowerCase();
	$(obj).parents(".searchSelMainOut:first").find(".searchSelMainOpts .opt").each(function(){
		if(valToSearch=="" || $(this).text().toLowerCase().indexOf(valToSearch)>-1){
			$(this).show();
		}else{
			$(this).hide();
		}
	});
}
function searchSelUPDWX(e){
	var firstLastN=0;
	var curSel=$(".searchSelMainOut .opt.HOV");
	var newSel=null;
	var posHOVChanged=false;
    e = e || window.event;

    if (e.keyCode == '38') {// up arrow
    	firstLastN=-1;
    	posHOVChanged=true;
    	if(curSel.length>0){
    		var prev1=curSel.prevAll(".opt:visible:first");

    		if(prev1!=null && prev1.length>0){
    			newSel=prev1;
    		}else{
    			newSel=$(".searchSelMainOut .opt:visible:last");
    		}
    	}else{
    		newSel=$(".searchSelMainOut .opt:visible:last");

    	}
        
    }
    else if (e.keyCode == '40') {// down arrow
   	 	firstLastN=1;
        posHOVChanged=true;
        if(curSel.length>0){
    		var next1=curSel.nextAll(".opt:visible:first");
    		
    		if(next1!=null && next1.length>0){
    			newSel=next1;
    		}else{
    			newSel=$(".searchSelMainOut .opt:visible:first");
    			
    		}
    	}else{
    		newSel=$(".searchSelMainOut .opt:visible:first");
    	}
    }
    else if (e.keyCode == '13' || e.keyCode == '9') {//enter or tab
       if(curSel.length>0) curSel.click();
    }
    else if (e.keyCode == '37') {
       // left arrow
    }
    else if (e.keyCode == '39') {
       // right arrow
    }else{
    	
    }
    if(posHOVChanged){
	    if(curSel.length>0) curSel.removeClass("HOV");
	    if(newSel!=null && newSel.length>0){
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
	    	//alert(elements1.index(".HOV")*24);
    		$(".searchSelMainOpts").animate({ scrollTop: index1*24 }, 10);
	    }
    }
    return 

}

/************************/
/*   mass actions all   */
/************************/
var massActionAllProgTextsArr=null;
var openAllmassActionAllLastID='';
var progressbarMAll = null;
var progressLabelMAll = null;
var stopmassActionAll=false;
var stopmassActionAllError=false; 
var runFunctionOnIdsMassActionAll1=null;
var isSelectedRowsModesMassActionAll1=false;
var runFunctionOnIdsMaxRowsAll1=massActionsDefBatchSize;//200
var totalCountAjxMassActions=0;
var massActionmaxID='';
//var massActionAllProgTexts="Starting Mass Update...#Stop#Stopping...#Current Progress: #Complete!#Close#Are you sure you want to update all the rows#Mass Update All Rows (title)";

function openAllmassActionAll(massActionAllProgTexts,runFunctionOnIdsMassActionAll,runFunctionOnIdsMaxRowsAll,isSelectedRowsMode,maxID){
	totalCountAjxMassActions=totalCountAjx;
	if(isSelectedRowsMode==null){
		isSelectedRowsMode=false;
	} 
	isSelectedRowsModesMassActionAll1=(isSelectedRowsMode==true);
	//alert("isSelectedRowsModesMassActionAll1: "+isSelectedRowsModesMassActionAll1);
	if(isSelectedRowsModesMassActionAll1){
		totalCountAjxMassActions=$(".lcbX input:checked").length;
	}
	massActionmaxID=(maxID!=null && maxID!=""?maxID:'');
	
	runFunctionOnIdsMassActionAll1=runFunctionOnIdsMassActionAll;
	if(runFunctionOnIdsMaxRowsAll==null){
		runFunctionOnIdsMaxRowsAll1=massActionsDefBatchSize;
	} else{
		runFunctionOnIdsMaxRowsAll1=runFunctionOnIdsMaxRowsAll;
	}
	massActionAllProgTextsArr=massActionAllProgTexts.split("#");
	if(!isSelectedRowsModesMassActionAll1 && !confirm(massActionAllProgTextsArr[6])){//
		return false;
	}
	progressbarMAll=null;
	progressLabelMAll=null;
	openAllmassActionAllLastID='';
	lastBtachSizeDoneMActionALL=0;
	stopmassActionAll=false;
	stopmassActionAllError=false;
	msgmassActionAllAllRows="";
	messageCellMActionALL="";
	lastBtachSizeDoneMActionALL=0;
	
	$("#massActionAllAllDialog").remove();											//Starting Mass Update...
	$("body").append("<div id='massActionAllAllDialog'><div class='progresslabelMactALL'>"+massActionAllProgTextsArr[0]+"</div><div id='progressbarMAll' style='margin-top:15px;'></div></div>");
	progressLabelMAll = $( ".progresslabelMactALL" );
	progressbarMAll = $( "#progressbarMAll" );
	var massActionAllAllDialog=$("#massActionAllAllDialog").dialog({
            resizable: true,
            //height:500,
            width:(isSF1()?($(self).width()-20):500),
            modal: openDialogAsMod(),
            title: massActionAllProgTextsArr[7],//title
            buttons: [{
            text:massActionAllProgTextsArr[1], //stop
            click: function() {
               stopmassActionAll=true;
                massActionAllAllDialog.dialog( {"buttons":[{
			          text: massActionAllProgTextsArr[2], //Stopping...#
			          click: function(){
			          //$( this ).dialog( "close" );
			          }
			        }]});
            }}]
            ,
            open: function() {
         		 //progressTimer = setTimeout( progress, 2000 );
         		 progressbarMAll.progressbar({
			      value: false,
			      max:totalCountAjxMassActions,
			      change: function() {
			      	var val1=progressbarMAll.progressbar( "value" );
			      	if(val1==null){val1=0;}
			      						//"Current Progress: " 
			        progressLabelMAll.html( massActionAllProgTextsArr[3] + Math.round((val1/totalCountAjxMassActions)*100.0) + "% ("+val1+" / "+totalCountAjxMassActions+")" );
			      },
			      complete: function() {
			        progressLabelMAll.text( massActionAllProgTextsArr[4] );//"Complete!"
			        stopmassActionAll=true;
			        changeMActionALLBtns();
			        //$(".ui-dialog button:visible").last().focus();
			        lastMassFunctionBtnCall=null;
			        
                     searchChanged(1);
			      }
			    });
 				if(!stopmassActionAll)doAllmassActionAll();
       		},
             close: function( event, ui ) {
             	$( this ).dialog( "close" );
             }
            });
            
}
function changeMActionALLBtns(){
	fixOnload();
	$("#massActionAllAllDialog").dialog( {"buttons":[{
			          text: massActionAllProgTextsArr[5], //"Close"
			          click: function(){
			          fixOnload();
			          $( this ).dialog( "close" );
			          } 
			        }]});
}
var msgmassActionAllAllRows="";
var messageCellMActionALL="";
var lastBtachSizeDoneMActionALL=0;
function doAllmassActionAll(done){

	//msgmassActionAllAllRows=$.trim($(".msgmassActionAllAllRowsID").html());
	//alert($(".messageCellMActionALL").length + " "+done);
	//messageCellMActionALL=($(".messageCellMActionALL").length>0?$.trim($(".messageCellMActionALL").text()):"");
	if(done!=null){
		if((msgmassActionAllAllRows!=null && msgmassActionAllAllRows!="") || (messageCellMActionALL!=null && messageCellMActionALL!="")){
			//alert(messageCellMActionALL);
			if(messageCellMActionALL!=null ){
				alert(messageCellMActionALL);
				//$("#massActionAllAllDialog").remove(); 
				//fixOnload();
				changeMActionALLBtns();
				stopmassActionAllError=true;
				
			}else{
				//fixMultiDependancefield();
				alert(msgmassActionAllAllRows);
			}
			
		}else{
		
			//stopmassActionAll=true;
			var val = progressbarMAll.progressbar( "value" );
			if(val==null || val==false){
				val=0;
			}
			//alert(val+" "+lastBtachSizeDoneMActionALL+" "+totalCountAjxMassActions);
 			progressbarMAll.progressbar( "value", (val + lastBtachSizeDoneMActionALL) );
 			if((val + lastBtachSizeDoneMActionALL) >= totalCountAjxMassActions){
 				stopmassActionAll=true;
 				//alert(1);
 			}
 			
 		}
	}
	if(stopmassActionAllError){
		$("body").trigger("stopmassActionAllNOTOK");
		return;
	}
	if(stopmassActionAll){
		changeMActionALLBtns();
		//massActionAllAllDialog.dialog("close"); 
		 searchChanged(1);
		 $("body").trigger("stopmassActionAllOK");
		return;
	}
	lastBtachSizeDoneMActionALL=0;
	//alert("openAllmassActionAllLastID: "+openAllmassActionAllLastID);
	var DBsubQeryToUse=DBsubQery;

	if(isSelectedRowsModesMassActionAll1){
		var arrIDs=new Array();
		$(".lcbX input:checked").each(function(){
			arrIDs.push($.trim($(this).parents(".lcbX:first").attr("rid")));
		});
		DBsubQeryToUse=DBsubQeryToUse+(DBsubQeryToUse.indexOf('where')>-1?" and ":" where ")+" id in ('"+(arrIDs.join("','"))+"')";
	}
	if(massActionmaxID!=null && massActionmaxID!=""){
		DBsubQeryToUse=DBsubQeryToUse+(DBsubQeryToUse.indexOf('where')>-1?" and ":" where ")+" id <= '"+massActionmaxID+"'";
	}
	//alert("DBsubQeryToUse: " +DBsubQeryToUse);
	$('.message.errorM3').remove();currePlacex1RedErrors="";
	Visualforce.remoting.Manager.invokeAction(
                remotequeryAjax2GetIDSX,
                DBsubQeryToUse,
                openAllmassActionAllLastID, 
                runFunctionOnIdsMaxRowsAll1, 
                DB_END_ALLROWS_Qery,
                function(result, event){
                	//alert(event.type+"\n "+event.status +" \n"+result+"\n"+result.length+"\n"+result[0]+"\n");
                    if (event.status && result!=null) {
    					if(result!=null && result.length>0 && !stopmassActionAll ){
                        	openAllmassActionAllLastID=result[result.length-1];
                        	var toUpdate=result.join(";");
                        	//alert(result+' ' +openAllmassActionAllLastID);
                        	//var CurNum = Number(progressbarMAll.progressbar( "value" ));
                        	lastBtachSizeDoneMActionALL=result.length;
                        	
 							runFunctionOnIdsMassActionAll1(toUpdate);//doAllmassActionAll('1');//,(CurNum+lastBtachSizeDoneMActionALL==totalCountAjxMassActions) 
 						}else if(result!=null && result.length==0 && !stopmassActionAll){//no result then products where changed during the proccess > done
                        	var CurNum = Number(progressbarMAll.progressbar( "value" ));
                        	lastBtachSizeDoneMActionALL=totalCountAjxMassActions-CurNum;
                        	stopmassActionAll=true;
                        	doAllmassActionAll('1'); 
                        }else{
                        	//lastBtachSizeDoneMActionALL=0;
                        	//openAllmassActionAllLastID='';
                        	//doAllmassActionAll('1');
                        	if(stopmassActionAll){
                        		changeMActionALLBtns();
                        	}
                        }
                    
                     } else if (event.type === 'exception') {
                        if(event.message!=null && ((event.message+"").indexOf("Logged in")>-1 || (event.message+"").indexOf("Refresh page")>-1)){
                            self.location=self.location;
                        }else if(event.message!=null && (event.message+"").indexOf("Unable to connect")==-1){
                            if($("body:visible").length>0)alert("An error has occurred: "+event.message);
                        }
                    } else {
                        //self.location=self.location;
                        // $("#"+filterIdSpan+" .availVals").html("");
                        //lastMassFunctionBtnCall=null;
                        	//searchChanged(1);
                    }
                }, 
                {escape: true,buffer:true,timeout: 90000}
            );
            
}

/*** mass delete all ***/
function startMassDeleteALL(){
		
			if(licenseStatus!='Active' && licenseStatus!='ActiveP' && (totalCountAjx>50 || getStoredNumPPL("massDelete")>7)){ 
				licenseReqMessage("During the free trial mass-delete-all is limited to 50 rows per shot / 7 shots in total."); 
				return false; 
			}else if(!confirm('Are you sure you want to DELETE ALL the rows ('+totRowsForFOUNDONQ+')?\n\nPlease note that the filters and search will remain the same after the delete is completed.\nMeaning, you will see 0 results on this page.')){
				return false;
			}
			var batchSize=massActionsDefBatchSize;
			if(massActionsDefBatchSize>100){
				batchSize=100;
			}else{
				batchSize=massActionsDefBatchSize;
			}
			openAllmassActionAll("Starting Mass Delete All...#Stop#Stopping...#Current Progress: #Complete!#Close#Are you sure?\n\nThis is the second and last confirm for MASS DELETE ALL!#Mass Delete All Rows",deleteRowsInMassdeleteAll,batchSize);
			
	}
	
	function updateRowsInMassUpdateAsync(rowids){
			//alert(rowids);
			//$('.message.errorM3:visible').remove();
			massUpdateALlAFMAS(rowids);
	}
	function updateRowsInMassUpdateAsyncTempCompleted(rowids){
		messageCellMActionALL=$.trim(($('.messageCell:visible').length>0?$.trim($('.messageCell:visible').text()):''));
		//alert($('.message.errorM3').text()+ " "+currePlacex1RedErrors+ " "+messageCellMActionALL);
		//alert(currePlacex1RedErrors);
	  if((currePlacex1RedErrors!=null && currePlacex1RedErrors.length>1) || (messageCellMActionALL!=null && messageCellMActionALL.length>1)) {
	  	  //alert("+++"+currePlacex1RedErrors+"+++"+messageCellMActionALL+"+++");
		  //$(currePlacex1RedErrors.substring(1)).addClass("Error_Fields1");
		  //$('#massActionAllAllDialog').remove();
		  if(currePlacex1RedErrors.length>0 && (messageCellMActionALL == null || messageCellMActionALL.length==0)) {
		  		messageCellMActionALL='The marked row(s) could not be updated, please review and try again!';
		  		$('#massActionAllAllDialog').remove();
		  		fixOnload();
		  }else{
		  	$('#massActionAllAllDialog').remove();
		  	fixOnload();
		  }
		  //openMassUpdate(); 
		  	
	   }else{
	   		
	   }
	   
	   doAllmassActionAll('1');
	   
		
	}

	function deleteRowsInMassdeleteAll(rowids){
			//alert(leadid);
			//alert(checkedIdsArr[currentLeadIdx]);
			//lead_MasterLabel~find account 0/1~find contact 0/1~owenrid~create opportunity 0/1
		Visualforce.remoting.Manager.invokeAction( 
		remotemassDelete, 
		rowids+"#"+tableX1, //id

		function(result, event){ 
		var continueDelete=true;
		
		if (event.status && result!=null) { 
		
		if((result+"").indexOf("OK")==0){ 
			messageCellMActionALL=""; 
			//doAllmassActionAll("1"); 
		}else{ 
			messageCellMActionALL="An error has occurred while deleting rows: "+result+""; 
			//doAllmassActionAll("1"); 
			hadError=true;
		} 
			doAllmassActionAll("1"); 
		} else if (event.type === 'exception') { 
		if(event.message!=null && ((event.message+"").indexOf("Logged in")>-1 || (event.message+"").indexOf("Refresh page")>-1)){ 
		self.location=self.location; 
		}else if(event.message!=null && (event.message+"").indexOf("Unable to connect")==-1 ){ 
			messageCellMActionALL="An error has occurred: "+event.message; 
			doAllmassActionAll("1"); 
		} 
		} else { 
		//self.location=self.location; 
		// $("#"+filterIdSpan+" .availVals").html(""); 
		//alert(1); 
		} 

		}, 
		{escape: true,buffer:true,timeout: 90000} 
		); 
}

function openMassDeletePopup(){
		
		if(Enable_ZaapIT_s_Layout_Editor=="true" && $("input.lcbXAll:first").is(":checked") && $(".lcbX input:checked").length>0){
		 var buttons1=new Array();
			buttons1.push({ 
		text: "Mass Delete - Selected ("+($(".lcbX input:checked").length)+")",
		click: function() { 
			massDeleteSelectedX1();
		jQuery( this ).dialog( "close" ); 
		}});

			buttons1.push({
			text: "Mass Delete - ALL ("+totRowsForFOUNDONQ+")", 
			click: function() { 
			startMassDeleteALL()
			jQuery( this ).dialog( "close" ); 
			}});

		buttons1.push({
		text: "Cancel", 
		click: function() { 
		jQuery( this ).dialog( "close" ); 
		} 
		});
		$( "#dialog-mass-delete" ).remove();
		$( "body" ).append("<div title='Mass Delete' id='dialog-mass-delete' style='padding:10px;font-weight:bold;vertical-align:middle;'> Would you like to delete the selected rows or all the rows?</div>");
		$( "#dialog-mass-delete" ).dialog({ 
		resizable: false, 
		width: (isSF1()?($("body").width()-10):450), 
		height:(isSFLight1XV?220:200), 
		//modal: true, 
		buttons: buttons1
		}); 
			fixIfmHegt();
			}else{
				massDeleteSelectedX1();
			}

} 

function massDeleteSelectedX1(){
	if(massDeleteSelected()){
		massDeleteRows1();
	}
}

//attachDetachBtn works only on enterprise+ orgs
function attachDetachBtn(){
		var adduploadDNP=0; 
		
		$("body").delegate( ".dataRow .oSt_attachment__xx-parentid__xx-name a[x!='0']", "mouseover", function(e) { 
		stopProp1(e); 
		$(this).parents(".oSt_attachment__xx-parentid__xx-name:first").removeAttr("onmouseover").removeAttr("data-hasqtip").removeAttr("aria-describedby"); 
		$(this).attr("x","1").attr("onmouseover","stopProp1(event);return false;"); 
		
		var t1="<a href='javascript:void(0);' onclick='removeAttachment(\""+$(this).attr("href")+"\");'>Remove</a>"; 
		$(this).attr("title",t1); 
		fixTitlex2(this,false,'L'); 
		
		}); 
		
		removeAttachment=function(idHref){ 
		
		$.ajax({url:'/soap/ajax/35.0/connection.js',dataType: "script", success:function() { 
		loadingSH(); 
		var attchId=idHref.substring(idHref.indexOf("/")+1); 
		var result = sforce.connection.deleteIds([attchId]); 
		if(!result[0].getBoolean("success")){ 
		alert('Delete failed.\n\n'+result); 
		$("#loadingx1").hide(); 
		} 
		else { 
		//alert(1); 
		adduploadDNP=0; 
		$(".seatchInptFZP").keyup(); 
		
		} 
		
		}}); 
		
		} 
		addDragANdDropAttach=function(){ 
		if(adduploadDNP==0 && $(".uploadDNP").length==0){ 
		adduploadDNP=1; 
		$(".list tbody .dataRow[rowID!=''] .attachment__xx-parentid__xx-name").append("<input type='file' class='uploadDNP' onchange='handleFileSelect(this,event);'/>"); 
		} 
		
		} 
		
		handleFileSelect= function(obj,evt) { 
		loadingSH(); 
		var files = evt.target.files; // FileList object 
		// Loop through the FileList and render image files as thumbnails. 
		for (var i = 0, f; f = files[i]; i++) { 
		
		
		
		var reader = new FileReader(); 
		
		// Closure to capture the file information. 
		reader.onload = (function(theFile) { 
		return function(e) { 
		//$(".fileX1").val(e.target.result) 
		//alert(e.target.result); 
		var arr1=e.target.result.split(":")[1].split(","); 
		//alert(arr1.length+"\n"+e.target.result); 
		$.ajax({url:'/soap/ajax/35.0/connection.js',dataType: "script", success:function() { 
		var attch = new sforce.SObject("Attachment"); 
		attch.ParentId=$(obj).parents("tr:first").attr("rowid"); 
		attch.Body=$.trim(arr1[1]);//e.target.result; 
		attch.IsPrivate =false; 
		attch.Name = theFile.name; 
		attch.Description = theFile.name; 
		attch.ContentType = arr1[0];//theFile.name.substring(theFile.name.indexOf(".")+1); 
		var result = sforce.connection.create([attch]); 
		if(!result[0].getBoolean("success")){ 
		alert('Upload failed.\n\n'+result); 
		$("#loadingx1").hide(); 
		} 
		else { 
		//alert(1); 
		adduploadDNP=0; 
		$(".seatchInptFZP").keyup(); 
		
		} 
		
		}}); 
		
		}; 
		})(f); 
		
		// Read in the image file as a data URL. 
		reader.readAsDataURL(f);//,"UTF-8"//,"Base64" 
		} 
		} 
		addDragANdDropAttach2= function(){ 
		addDragANdDropAttach(); 
		$("body").bind("OnRenderDone",function(){ 
		adduploadDNP=0; 
		addDragANdDropAttach(); 
		}); 
		} 
		
		addDragANdDropAttach2();
}


/*** Inline editing ***/
function loadingSH2(){
	
    $("#loadingx2").fadeTo(0,0.5);
    $("#loadingx2").width($(".mZPFormInlineE1").width());
    $("#loadingx2").height($(".mZPFormInlineE1").height());
    $("#loadingx2").show();
}
function inlineEditCancel(){
	$(".mZPFormInlineE1").hide();
	$("td.marked").removeClass("marked");
	inlineEditF1Cancel();
	showCellMenuX1();
}
function inlineEditF1SaveX1(){
	loadingSH2();
	inlineEditF1Save();
}
var lastIEFLD="";
var lastIEID="";
function saveIERowSaveDone(){
	if($(".mZPFormInlineE1 .message.confirmM3 img[alt='CONFIRM']").length>0){
		var massage1=$(".mZPFormInlineE1 .message.confirmM3 .messageText").text();
		var ele1=$("#mainTBX1 table tr[rowid='"+lastIEID+"'].dataRow td[fld='"+lastIEFLD+"'] .ost1X .ost1I");
		if(!isSF1())tempLayerMessage2("<div class='msgOKGL'>"+massage1+"</div>",2500,Math.max(0,ele1.position().top-100),Math.max(0,$(self).width/2-100));
		var newVal=$.trim($(".mZPFormInlineMFLDTXT").html());
		ele1.html(newVal).parents("td:first").removeClass("marked").addClass("markedG");
		setTimeout(function(){
			$("td.markedG").removeClass("markedG");
		},1500);
		inlineEditCancel();
	}
}
function inlineEditF1Open(){
	//alert($(".mZPFormInlineE2 input.mZPFormInlineMFLD,.mZPFormInlineE2 select.mZPFormInlineMFLD,.mZPFormInlineE2 textarea.mZPFormInlineMFLD").length);
	if($(".mZPFormInlineE2 input.mZPFormInlineMFLD,.mZPFormInlineE2 select.mZPFormInlineMFLD,.mZPFormInlineE2 textarea.mZPFormInlineMFLD").length==0){
		var errorMsg=$(".mZPFormInlineE1BTN .message.errorM3").text();
		inlineEditCancel();
		var ele1=$("#mainTBX1 table tr[rowid='"+lastIEID+"'].dataRow td[fld='"+lastIEFLD+"'] .ost1X").css({"cursor":"not-allowed"});
		if(errorMsg.indexOf("Dependent picklist are not supported")>-1){
			tempLayerMessage2("<b>Dependent picklist can only be edit by mass-inline-editing (use the top edit button instead).</b>",4500,ele1.position().top+20,ele1.position().left);
		}else{
			tempLayerMessage2("<b>This field is not editable"+(lastIEFLD.indexOf(".")>-1?" / The lookup object is not editable":"")+"</b>",3500,ele1.position().top+20,ele1.position().left);
		}
	}else{
		if($(".mZPFormInlineE1 .lookupInput,.mZPFormInlineE1 a>.comboboxIcon").length>0){
			readyFixLKPX();
		}
		$(".mZPFormInlineE1 input").focus();
		
	}
}
function inlineEditRowMG(obj){

	var fld=$(obj).attr("fld");
	var rowid=$(obj).parents("tr:first").attr("rowid");
	lastIEFLD=fld;
	lastIEID=rowid;
	if(fld.indexOf("__xx")==-1){//multi value column
		hideCellMenu1();
		$(obj).addClass("marked");
		$(".mZPFormInlineE2,.mZPFormInlineE1BTN").html("");
		$(".mZPFormInlineE1").css({"display":"inline-block"}).show();
		loadingSH2();
		var left1=$(obj).position().left;
		var top1=$(obj).position().top;
		if( isSF1() && left1==0){
			left1=($(self).width()/2 - $(".mZPFormInlineE1").width()/2);
			top1=$(self).height()/4;
		}
		
		$(".mZPFormInlineE1").css({"top":top1,"left":left1});
		
		inlineEditF1(rowid,fld);
	}else{
		var ele1=$("#mainTBX1 table tr[rowid='"+lastIEID+"'].dataRow td[fld='"+lastIEFLD+"'] .ost1X");
		tempLayerMessage2("<b>Multi-value columns are not editable</b>",3500,ele1.offset().top-20,ele1.offset().left);
		//showCellMenuX1();
	}
}
var lastshowCellMenu1=null;
function hideCellMenu1(){
	$(".cellMenu1").hide();
	$(".cellMenu1").css({"top":"-9999px"});//mobile fix after open
	$(".markedA").removeClass("markedA");
}
function showCellMenuX1(){
	$(".cellMenu1").show();
	
}
var showFastInlineForClass=(confName=="gensubtab_dedup_Jobs"?".zaapit__show_as_default__c, .zaapit__columnswidth__c":"");//enable the edit for active column
var cellMenuBlock=false;
var showPhoneDialer=null;
function showCellMenu1(obj){
	//alert($(obj).position().top + " "+$(obj).offset().top)
	var editEnabled=$(".EditBtnX1").length>0;
	lastshowCellMenu1=obj;
	$(".markedA").removeClass("markedA");
	$(obj).addClass("markedA");
	if(showPhoneDialer==null) showPhoneDialer=isSFLight1XV && registerClickToDial!=null;
	
	if(!cellMenuBlock&&$(".cellMenu1").length==0){
		cellMenuBlock=true;
		setTimeout("cellMenuBlock=false;",500);
		$("body").append("<div class='cellMenu1'>"+
		(showPhoneDialer?"<button class='phone hd1' onclick='phoneDialCell(lastshowCellMenu1);' title='Dial Number'></button>":"")+
		"<button onclick='inlineEditRowMG(lastshowCellMenu1);' class='edit' title='Edit'></button>"+
		(colorPickerEnable?"<button class='color' onclick='colorCell(lastshowCellMenu1);hideCellMenu1();' title='Choose Color'></button>":"")+
		"</div>");
	}
	if($(".cellMenu1").length>0){
		if(editEnabled || (showFastInlineForClass!="" && $(obj).is(showFastInlineForClass))){
			$(".cellMenu1 .edit").removeClass("hd1");	
		}else{
			$(".cellMenu1 .edit").addClass("hd1");
		}
	}
	if(isSFLight1XV){
		var isPhoneField=$(obj).attr("fld").indexOf("phone")>-1
		if(isPhoneField){
			$(".cellMenu1 .phone").removeClass("hd1");	
		}else{
			$(".cellMenu1 .phone").addClass("hd1");	
		}
	}
	
	var Menu1Width=$(".cellMenu1").width();
	var Menu1Height=$(".cellMenu1").height();
	var widthX=(!isSF1()?$(obj).offset().left+$(obj).width():$(self).width()-10-Menu1Width-25);//-Menu1Width//$(obj).width()
	var heightX=(!isSF1()?$(obj).offset().top:$(obj).offset().top);//-Menu1Width
	$(".cellMenu1:visible").css({"top":heightX,"left":widthX});
	
}

function phoneDialCell(obj){
	var trID=$(obj).parents("tr:first").attr("rowid");
	var phone1=$.trim($(obj).text());
	//alert(phone1+" "+trID);
	Sfdc.lightningClickToDial.dial(phone1, trID );
	//$(".cellMenu1").hide();
	//$(".cellMenu1").css({"top":"-9999px"});
	$(".cellMenu1 .phone").addClass("markedYel");
	setTimeout(function(){$(".cellMenu1 .phone").removeClass("markedYel");},1500);
	tempLayerMessage2("Dailing "+phone1+"",1500,$(obj).offset().top+50,$(obj).offset().left );

}

function phoneDialCell2(obj,rowID){
	var trID=rowID;
	var phone1=$.trim($(obj).text());
	//alert(phone1+" "+trID);
	Sfdc.lightningClickToDial.dial(phone1, trID );
	tempLayerMessage2("Dailing "+phone1+"",1500,$(obj).offset().top+50,$(obj).offset().left );
}

var colorPickerEnable=true;
function colorCell(obj){
	var fld=$(obj).attr("fld");
	var tr1=$(obj).parents("tr:first");
	var svid=tr1.attr("svid");
	if(svid==null)svid="";
	var rowid=tr1.attr("rowid");
	lastIEFLD=fld;
	lastIEID=rowid;
	openCondWinMini(svid);
}

function showMoreBtnsTop(obj){
	var btnsMore=$(".btnBoxMoreAct2").clone();
	btnsMore.find("input[type],button,a").each(function(){
		if(!$(this).hasClass("btnMore")){
			$(this).remove();
		}else{
			$(this).click(closeAllTooltips);
		}
	});
	$(obj).attr("title","<div class='btnMenu1'>"+btnsMore.html()+"</div>");
	$(obj).removeAttr("onclick");
	fixTitlex2(obj,false,'B',null,1);
}



/**** charts complex*****/

  function createChart(chartID,chartType,chartLink,colName ,amountFName,field1,amountFleild,title1,field2,title2,showCurrency,resultData,logscale1){
  
  	if(logscale1==null){
  		logscale1=1;
  	}
   var boolValFirst=-1;
  if(charts_colors==""){
  	// getLabel("charts_colors",function(x){charts_colors=eval(x); $("#"+chartID+" .graphsRefresh").click();});
  	 //return;
  }
  $("#"+chartID+ "In").html("<div class='ld1'></div>");
  	var maxResRows=50000;
  	
  	var amoundField=amountFleild;
  	var amountDis='sum('+amoundField+')';
  	if(amoundField=='count'){
  		amountDis='count(Id)';
  	}
    var query1="SELECT "+field1+" f1,"+(field2!=""?field2+" f2,grouping("+field2+") g1,":"")+amountDis+" s1,count(Id) c1 "+DBsubQery+" "+(amoundField.toLowerCase()!="count" ?(DBsubQery.indexOf("where")>-1?" and ":" where ") +amoundField+"!=null":"")+" group by "+(+field2!=""?"ROLLUP("+field1+","+field2+")":""+field1)+" order by "+(chartType=="3"?field1+" desc"   : (field1.toLowerCase().indexOf('calendar_')==0? field1+" asc ": amountDis+" desc,"+field1+" asc "))+" limit "+maxResRows+DB_END_ALLROWS_Qery;
  
  //field1,filterIdSpan,fieldCalss1,chartType,colName,resultData,fetchCount1){
  	var tooltipHTMl="true";
  	//var chartType=chartType;
  	var isBar=false;
  	var isGeo1 =false;
  	var gwinIdIn=chartID+"In";
  	var height1=$("#"+gwinIdIn+"").height();
  	var width1=$("#"+gwinIdIn+"").width();
  	 if(resultData==null ){
  	 var query1D=query1;//decodeURIComponent(query1).replace(/\+/ig," ");
    Visualforce.remoting.Manager.invokeAction(
                remoteQueryAjax2,
                query1D, 
                function(result, event){
                //alert(event.status + " "+event.type +" "+ event.message);
                    if (event.status && result!=null) {
    					createChart(chartID,chartType,chartLink,colName ,amountFName,field1,amountFleild,title1,field2,title2,showCurrency,result,logscale1);
                    
                     } else if (event.type === 'exception') {
                        if(event.message!=null && ((event.message+"").indexOf("Logged in")>-1 || (event.message+"").indexOf("Refresh page")>-1)){
                            self.location=self.location;
                        }else if(event.message!=null && (event.message+"").indexOf("Unable to connect")==-1){
                            if($("body:visible").length>0)alert("An error has occurred: "+event.message);
                        }
                    } else {
                        //self.location=self.location;
                        // $("#"+filterIdSpan+" .availVals").html("");
                        //alert(1);
                    }
                }, 
                {escape: true,buffer:false,timeout: 90000}
            );
            return;
            }

        var queryMore = true;
        var hasRows = false;
        var count1=0;
        var showButtons=false;
         var data = new google.visualization.DataTable();
          var fieldMap1=new Array();   

            var records = resultData;
            if(records!=null && records.length>0){
                   
                for (var key in records[0]) {
                    //alert(key+" "+records[0][key]+" "+(typeof  records[0][key]));
                    fieldMap1[key.toLowerCase()]=key;
                    if(records[0][key]!=null && (typeof records[0][key]) == "object"){
                    
                        for (var key1 in records[0][key]) {
                            fieldMap1[key1.toLowerCase()]=key1;
                        }
                    }  
                }
                
            }else{
            	$("#"+gwinIdIn+"").html("<div style='margin:"+((height1/2)-30)+"px 0px 0px "+((width1/2)-69)+"px;color:#999999;'>"+No_Chart_Data+"</div>");
            }
            var type1="string";
            if(chartType=='3'){//date
                type1="date";
            }  else if(chartType=='5'){
               //type1="country";
            }
            var multiDimentionMode=(field2!=null && field2!='');
            data.addColumn({type:type1, label:colName});
            var multiValArr=new Array();
            var multiValArrP=new Array();
            var multiValArr2=new Array();
            var multiValArrP2=new Array();
            if(multiDimentionMode){
            	
            	var curPos=1;
            	var curPos0=0;
            	//alert(records.length);
	            for (var i = 1; i < records.length; i++) {//starts at 1 (null,null)
	                var val1=records[i]['f2'];
	                var val0=records[i]['f1'];
	                var g1=records[i]['g1'];//none sum rows g1==0
	                if(g1==0 && multiValArr2[val1]==null){
	                	multiValArr2[val1]=curPos;
	                	multiValArrP2.push(val1);
	                	curPos++;
	                }
	                if(g1==1 && multiValArr[val0]==null){
	                	multiValArr[val0]=curPos0;
	                	multiValArrP.push(val0);
	                	curPos0++;
	                }
	            }
	            
	            for (var i = 0; i < multiValArrP2.length; i++) {
	            	data.addColumn({type:"number", label: multiValArrP2[i]});
	            }
	            
	            data.addRows(multiValArrP.length);
	            for (var i = 0; i < multiValArrP.length; i++) {
	            	var val1=multiValArrP[i];
	            	var val1Vis=val1;
	            	if(val1==null || val1==""){
	                    val1Vis=Blanks_txt;
	                } else if(val1.indexOf("&")>-1){
	                    
	                    val1=val1.replace("amp;","").replace("amp;","");
	                    
	                     val1Vis=val1;
	                }
	                if(chartType=='3' && val1!=null && val1!=''){
	                	data.setValue(i,0,new Date(val1));
	                }else{
	                	data.setValue(i,0,val1Vis +"");
	                }
	            	
	            	if(chartType=='3' || chartType=='1' || chartType=='1p' || chartType=='2' || chartType=='8'){  
	            	 for (var j = 0; j < multiValArrP2.length; j++) {
	            		data.setValue(i,1+j,0);
	            	 }
	            	}
	            }
	           
	            if(multiValArrP.length>7 && chartType=='6'){
	            	var cont1=$("#"+gwinIdIn+"").parents(".chart:first");
	            	var multi1=1.5;//Math.max((multiValArrP.length/20),1.5);
	            	cont1.height(cont1.height()*multi1);
	            	$("#"+gwinIdIn+"").height($("#"+gwinIdIn+"").height()*multi1);
	            }
            }else{
            	data.addColumn({type:"number", id:'Total',label:(chartType=='9' || chartType=='10'?'Total':'')});//(amountFName==null || amountFName==""?Total_text:amountFName)
            	if(chartType=='10'){//dupes
            		data.addColumn({type:"number", label:"Duplicates"});
            		data.addRows(Math.max(records.length,2));
            	}else{
            		data.addRows(records.length);
            	}
            	
            }
             
            //data.addColumn({type:'string',role:'tooltip'});
            //data.addColumn('string', null);   
            
            //alert(records[0]);
           // var expfieldsStart=(!useExpField?0:1);
            //var expfieldsStart2=expfieldsStart+1;
            var countFname="c1";//'expr'+expfieldsStart;
            var sumFname="s1";//'expr'+expfieldsStart2;
            var fieldDotIdx=field1.indexOf(".");
            var field1Xnd=(fieldDotIdx>-1?field1.substring(fieldDotIdx+1):field1);
            var mainFieldName="f1";//(useExpField?"expr0":fieldMap1[field1Xnd]);
            
            
            for (var i = 0; i < records.length; i++) {
                hasRows=true;
                var val1=records[i][mainFieldName];
                var valcd1=records[i]['cd1'];
                var valcd2=records[i]['cd2'];
                var val2=records[i]['f2'];
                var val1Orig=val1;
                 var val1Vis=val1;
                if(val1==null || val1==""){
                    val1Vis=Blanks_txt;
                } else if(val1.indexOf("&")>-1){
                    
                    val1=val1.replace("amp;","").replace("amp;","");
                    
                     val1Vis=val1;
                }
                
               
                
                var val1Count=records[i][countFname];
                var val2sum=records[i][sumFname];
                var objN="";
                //if(!isNaN(val1)){//int
                    	//data.setValue(i,0,val1+" ("+val1Count+")");
                       // data.setValue(i,0,Number(val1));
                if(!multiDimentionMode){
	                if(chartType=='3'){//date
	                    if(val1!=null && val1!=""){
	                        var darr=val1.split(/\-/);
	                        data.setValue(i,0,new Date(darr[0],(Number(darr[1])-1),darr[2]));
	                    }else{
	                        data.setValue(i,0,null);
	                    }
	                }else if(chartType=='4' || chartType=='4f'){//booleans
	                    var valBoo=(val1+"")=="true";
	                    val1Vis=(valBoo?"Yes":"No");
	                    if(boolValFirst==-1){
	                        boolValFirst=(valBoo?1:0);
	                    }
	                    data.setValue(i,0,val1Vis +" ("+val1Count+")");
	                }else if(chartType=='5'){//country
	                    data.setValue(i,0,val1Vis);
	                }else if(chartType=='9' && (amountFleild==null || amountFleild=="")){//grid
	                	 data.setValue(i,0,val1Vis);
	                }else if(chartType=='10'){//dupes
	                	
	                	var v1=Number(val1Count==null || val1Count=="" ?0:val1Count);
	                	var v2=Number(valcd1==null || valcd1=="" ?0:valcd1);
	                	var v3=Number(valcd2==null || valcd2=="" ?0:valcd2);
	                	if(val1Vis=='false'){//overall charts
	                		var row1x=0;
	                		if(v2>0 && v1>v2){
			                	data.setValue(0,0,"Name");
			                	data.setValue(0,1,v1);
			                	data.setValue(0,2,(v1-v2));//dupes
			                	row1x++;
		                	}
		                	if(v3>0 && v1>v3){
		                		//alert(query1);
		                		if(query1.indexOf('count_distinct%28phone')>-1){ 
		                			data.setValue(row1x,0,"Phone");
		                		}else{
			                		data.setValue(row1x,0,"Email");
			                	}
			                	data.setValue(row1x,1,v1);
			                	data.setValue(row1x,2,(v1-v3));//dupes
		                	}
	                	}else{
		                	if(v2>0 && v1>v2){
			                	data.setValue(count1,0,val1Vis);
			                	data.setValue(count1,1,v1);
			                	data.setValue(count1,2,(v1-v2));//dupes
		                	}
	                	}
	                }else{
	                    //if(!isGeo1  &&  (amountFleild!=null && amountFleild!="")){
	                        data.setValue(i,0,val1Vis +" ("+val1Count+")");
	                    //}else{
	                    //    data.setValue(i,0,val1Vis);
	                    //}
	                }
	                if(chartType!='10'){
		                if(val2sum!=null){
		                    data.setValue(i,1,Number(val2sum==null || val2sum=="" ?0:val2sum));
		                    //data.setValue(i,2,val1+": $"+val2sum+" ("+val1Count+")");
		                }else{
		                    data.setValue(i,1,Number(val1Count==null || val1Count=="" ?0:val1Count));
		                    //data.setValue(i,2,val1+": "+val1Count+"");
		                }
	                }
	            }else{
	            	var useNum=val2sum;
	            	if(useNum==null){
	            		useNum=val1Count;
	            	}
	            	if(useNum==null || useNum==""){
	            		useNum=0;
	            	}
	            	if(records[i]['g1'] ==0 && multiValArr[val1Orig]!=null && multiValArr2[val2]!=null){
	            		data.setValue(multiValArr[val1Orig],multiValArr2[val2],Number(useNum));
	            	}
	           		 
	            }
                //data.setValue(i,3,field1+"="+val1);

            count1++;
            }
           
   
        //alert(data+ "\n\n "+amountFleild);
        if(hasRows){
         //var data = google.visualization.arrayToDataTable(dataPreG);

        
         
        if(amountFleild!=null && amountFleild!=""){
            var symbol= orgDefCurrency;
            //symbol=symbol.substring(0,1);
            if(showCurrency=="0"){
            	symbol=null;
            }
             var formatter = new google.visualization.NumberFormat(
                {prefix: symbol,pattern: 'short'});
             // Apply formatter to second column
            if(multiValArrP2.length>0){
            	for(var j=0;j<multiValArrP2.length;j++){
            		formatter.format(data, j+1);
            	}
            }else{
            	formatter.format(data, 1);
            } 
            // var formatter = new google.visualization.PatternFormat('{0}: {1}');
            // formatter.format(data, [0,1], 0); 
        }
        
       
            title1=decodeURIComponent(title1).replace(/\+/ig," ");
            ChartsArrayTitle[chartID]=title1;
            chartLink=decodeURIComponent(chartLink).replace(/\+/ig," ");
            var options = null;//
          var chart=null;
         if(chartType=='1'){//ColumnChart
                    options={chartArea:{width:"45%",height:"50%"},isStacked: true,hAxis:{title: colName,titleTextStyle:{bold:true}}
                    ,colors:charts_colors
                   // ,title: title1
                   ,vAxis: {format:'short',titleTextStyle:{bold:true},title:(amountFleild==''?'Record Count':'Sum of '+amountFName),logScale:logscale1==1,scaleType:(logscale1==1?'mirrorLog':null)}
                    };
                if(!multiDimentionMode){
                    var formatter = new google.visualization.PatternFormat(colName+": {0} \n "+(amountFName==null || amountFName==""?Total_text:amountFName)+': {1}');
             		formatter.format(data, [0,1], 1);
             	} 
                chart = new google.visualization.ColumnChart(document.getElementById(gwinIdIn));
            }else if(chartType=='1p'){//ColumnChart not stacked
                    options={chartArea:{width:"45%",height:"50%"},isStacked: false,hAxis:{title: colName,titleTextStyle:{bold:true}}
                    ,colors:charts_colors
                   // ,title: title1
                   ,vAxis: {format:'short',titleTextStyle:{bold:true},title:(amountFleild==''?'Record Count':'Sum of '+amountFName),logScale:logscale1==1,scaleType:(logscale1==1?'mirrorLog':null)}
                    };
                if(!multiDimentionMode){
                    var formatter = new google.visualization.PatternFormat(colName+": {0} \n "+(amountFName==null || amountFName==""?Total_text:amountFName)+': {1}');
             		formatter.format(data, [0,1], 1);
             	} 
                chart = new google.visualization.ColumnChart(document.getElementById(gwinIdIn));
            }else if(chartType==2){//LineChart
                options={isStacked: true,colors:charts_colors,chartArea:{width:"69%"}
            ,vAxis:{format:'short',titleTextStyle:{bold:true},logScale:logscale1==1,scaleType:(logscale1==1?'mirrorLog':null)}
                //,title: title1
                };
                if(!multiDimentionMode){
                	var formatter = new google.visualization.PatternFormat(colName+": {0} \n "+(amountFName==null || amountFName==""?Total_text:amountFName)+': {1}');
             		formatter.format(data, [0,1], 1);
             	} 
                chart = new google.visualization.LineChart(document.getElementById(gwinIdIn));
          }else if(chartType=='3'){//date line chart
          
               options={isStacked: true,chartArea:{width:"50%",height:"55%"},colors:charts_colors
               ,vAxis: {format:'short',titleTextStyle:{bold:true}}
            //,title: title1
            };
            	if(!multiDimentionMode){
           	 		var formatter = new google.visualization.PatternFormat(colName+": {0} \n "+(amountFName==null || amountFName==""?Total_text:amountFName)+': {1}');
             		formatter.format(data, [0,1], 1); 
             	}
            //chart = new google.visualization.AnnotationChart(document.getElementById(gwinIdIn));
            chart = new google.visualization.LineChart(document.getElementById(gwinIdIn));

             var rangechange= function () {
                var topping="";
                try{
                /*var selTot=chart.getVisibleChartRange();
                var start=selTot.start;
                var startStr=start.getFullYear()+"-"+(start.getMonth()+1<10?"0":"")+""+(start.getMonth()+1)+"-"+(start.getDate()<10?"0":"")+""+start.getDate();
                var end=selTot.end;
                var endStr=end.getFullYear()+"-"+(end.getMonth()+1<10?"0":"")+""+(end.getMonth()+1)+"-"+(end.getDate()<10?"0":"")+""+end.getDate();
                //alert(startStr + " " +endStr+ " ");
                $('#'+filterIdSpan+' .'+fieldCalss1+"1").val(startStr);
                $('#'+filterIdSpan+' .'+fieldCalss1+"2").val(endStr).change();
                */
                //filterCol(null,100);//13
                }catch(e){}
                //$('#'+filterIdSpan+' .'+fieldCalss1).val(topping).focusin().keyup();
                };
                //google.visualization.events.addListener(chart, 'rangechange', rangechange);
                 
            
          }else if(chartType=='4' || chartType=='4f'){//booleans pie
              options={chartArea:{width:"100%"},tooltip:{isHtml:(tooltipHTMl!="true")}//chartArea:{width:"100%",height:"75%"},
                ,colors:[(boolValFirst==1?'#00AA00':'#CC0000'),(boolValFirst!=1?'#00AA00':'#CC0000'),'orange','#00CC00','#800080','#FFAA00','#00FFFF','#FF00AA','green','#AA00AA','#00AAAA','#AAAA00','#999900','#555500','lime']
                //,title: title1
                };
                var formatter = new google.visualization.PatternFormat(colName+": {0} \n "+(amountFName==null || amountFName==""?Total_text:amountFName)+': {1}');
             formatter.format(data, [0,1], 1); 
                chart = new google.visualization.PieChart(document.getElementById(gwinIdIn));
          }else if(chartType=='5'){// geo chart
                
                //chartArea:{left:0,top:5,width:"100%"},displayMode:"regions"
                options={
                    colorAxis: {colors: ['#AAAAFF','#3333FF']} 
                   //title: title1
                    };
                    var formatter = new google.visualization.PatternFormat(colName+": {0} \n "+(amountFName==null || amountFName==""?Total_text:amountFName)+': {1}');
             	formatter.format(data, [0,1], 1); 
                 chart = new google.visualization.GeoChart(document.getElementById(gwinIdIn));
                 //$("#"+gwinIdIn).parents(".chart:first").find(".title:first").show();
                 
           //bar chart      
         /* }else if(field1.indexOf("status")>-1 || field1.indexOf("type")>-1|| field1.indexOf("stage")>-1){
          
           options={ hAxis: {title: colName}
                ,colors:["#0000FF"]
                // title: 'My Daily Activities'
                };
                
                chart = new google.visualization.ColumnChart(document.getElementById(gwinIdIn));
          */      
          
          }else if(chartType=='0'){//pie chart
              	options={chartArea:{width:"100%"},tooltip:{isHtml:(tooltipHTMl!="true")}
            	,colors:charts_colors
            	//,title: title1
            	//,pieHole: 0.4
            	
            	};
             	var formatter = new google.visualization.PatternFormat(colName+": {0} \n "+(amountFName==null || amountFName==""?Total_text:amountFName)+': {1}');
             	formatter.format(data, [0,1], 1); 
            	chart = new google.visualization.PieChart(document.getElementById(gwinIdIn));
            }else if(chartType=='6'){//bar chart
            	
            	options={chartArea:{width:(field2==''?"69%":"55%"),height:"63%"},isStacked: field2!='',hAxis:{format:'short',titleTextStyle:{bold:true},title:(amountFleild==''?'Record Count':'Sum of '+amountFName),logScale:logscale1==1,scaleType:(logscale1==1?'mirrorLog':null)}
            	//,title: title1
            	,colors:charts_colors
            	//,pieHole: 0.4
            	 	,vAxis: {
			          title: colName,titleTextStyle:{bold:true}
			        }
			      ,legend: { position: (field2!=''?"right":"none") }  
            	};
             	//var formatter = new google.visualization.PatternFormat("{0}: {1}");
             	//formatter.format(data, [0,1], 1); 
             	if(!multiDimentionMode){
             		var formatter = new google.visualization.PatternFormat(colName+": {0} \n "+(amountFName==null || amountFName==""?Total_text:amountFName)+': {1}');
             		formatter.format(data, [0,1], 1); 
            	}
            	chart = new google.visualization.BarChart(document.getElementById(gwinIdIn));
             }else if(chartType=='7'){//Donut chart
              	options={chartArea:{width:"100%"},tooltip:{isHtml:(tooltipHTMl!="true")}//chartArea:{width:"100%",height:"75%"},
            	,colors:charts_colors
            	//,title: title1
            	,pieHole: 0.4
            	};
             	var formatter = new google.visualization.PatternFormat(colName+": {0} \n "+(amountFName==null || amountFName==""?Total_text:amountFName)+': {1}');
             	formatter.format(data, [0,1], 1); 
            	chart = new google.visualization.PieChart(document.getElementById(gwinIdIn));
            } else if(chartType=='8'){//line chart
          		//legend: 'none',
               options={isStacked: true,colors:charts_colors,chartArea:{width:"69%"}
            ,vAxis:{format:'short',titleTextStyle:{bold:true},logScale:logscale1==1,scaleType:(logscale1==1?'mirrorLog':null)}
            };
            
            //chart = new google.visualization.AnnotationChart(document.getElementById(gwinIdIn));
            var formatter = new google.visualization.PatternFormat(colName+": {0} \n "+(amountFName==null || amountFName==""?Total_text:amountFName)+': {1}');
             	formatter.format(data, [0,1], 1); 
            chart = new google.visualization.AreaChart(document.getElementById(gwinIdIn));
	       	} else if(chartType=='9'){//table chart
	          		
	               options={isStacked: true,colors:charts_colors,legend: 'none',chartArea:{width:"100%"}
	            //,title: title1
	            };
	            
	            //chart = new google.visualization.AnnotationChart(document.getElementById(gwinIdIn));
	           // var formatter = new google.visualization.PatternFormat(colName+": {0} \n "+(amountFName==null || amountFName==""?Total_text:amountFName)+': {1}');
	           //  	formatter.format(data, [0,1], 1); 
	            chart = new google.visualization.Table(document.getElementById(gwinIdIn));
	            
	         }else if(chartType=='10'){//dupes bar chart
            	//alert(amountFleild);
            	options={chartArea:{width:"45%",height:"69%"},hAxis:{format:'short',titleTextStyle:{bold:true},title:(amountFleild==''?'Record Count':'Sum of '+amountFName),logScale:logscale1==1,scaleType:(logscale1==1?'mirrorLog':null)}
            	//,title: title1
            	,colors:charts_colors
            	//,pieHole: 0.4
            	 	,vAxis: {
			          title: colName,titleTextStyle:{bold:true}
			        }
			        ,bars: 'horizontal'
            	};
             	//var formatter = new google.visualization.PatternFormat("{0}: {1}");
             	//formatter.format(data, [0,1], 1); 
             	//if(!multiDimentionMode){
             	//	var formatter = new google.visualization.PatternFormat(colName+": {0} \n "+(amountFName==null || amountFName==""?Total_text:amountFName)+': {1}');
             	//	formatter.format(data, [0,1], 1); 
            	//}
            	chart = new google.visualization.BarChart(document.getElementById(gwinIdIn));
	       	}
          //if(options!=null) options["animation"]= {"startup": true};
          
           var selectHandler= function () {
            var topping="";
            var topping2="";
            try{
            var selTot=chart.getSelection();
            //alert(selTot);
            var selectedItem = selTot[0];
            if (selectedItem) {
                topping = data.getValue(selectedItem.row, 0);
                topping2 = (field2!=""?data.getColumnLabel(selectedItem.column):"");
                //alert('The user selected '+selectedItem.row+" "+ topping + " "+topping2);
                topping=new String(topping==null?"":topping);
                topping2=new String(topping2==null?"":topping2);
                if(topping!=null && topping.indexOf(" (")>-1){
                    topping=topping.split(/ \(/)[0];
                }
                if(topping.indexOf(",")>-1 || topping.indexOf("'")>-1 ||topping.indexOf("\"")>-1 ||topping.indexOf("\\")>-1){
                    topping=topping.replace(/\,|'|"|\\/ig,"_");
                }
                topping=topping.replace("&quot;","_");
                topping=topping.replace("&#39;","_");
                topping=topping.replace("\\","_");

                if(topping==Blanks_txt){
                    topping=" ,";//blanko filter
                }else{
                    topping=topping+",";
                }
                 //alert('The user selected ' + topping);
            }
            }catch(e){}
            //alert(topping);;//field1
            var field1Filter=field1.replace(/\./ig,'-');
            var field1Filter2=field2.replace(/\./ig,'-');
            if(field1Filter.toLowerCase().indexOf('calendar_')>-1){
            	tempLayerMessage2("<b>Aggregate date columns cannot be used as filters, use the date column filter instead</b>",2500);
            }else if($('#fl'+field1Filter+' .inpf'+field1Filter).length==0){
            	tempLayerMessage2("<b>Add the "+field1Filter+" column to enable this filter...</b>",2500);
            }else{
            	$('#fl'+field1Filter+' .inpf'+field1Filter).val(topping).focusin().keyup().focusout();
            	if(field2!="" && $('#fl'+field1Filter2+' .inpf'+field1Filter2).length>0){
            		$('#fl'+field1Filter2+' .inpf'+field1Filter2).val(topping2).focusin().keyup().focusout();
            	}
            	filterCol(null,50);
            }
            
            
            
            //window.open(chartLink,"_blank","width=1200,height=690");
            };
            google.visualization.events.addListener(chart, 'select', selectHandler); 

 		google.visualization.events.addListener(chart, 'ready', function () {
		      ChartsArray[chartID]=chart.getImageURI();
		       
		    });
		    
          chart.draw(data, options);
         
          
        }
        
  }

  function encodeHTML(str){
	  return $('<div/>').text(str).html();
  }
  
  var cellSeperatorEZImport="\t";
  function handleFileSelectEzImport(evt,func1) {
    var filesEZImport = evt.target.files; // FileList object

    // Loop through the FileList and render image files as thumbnails.
    for (var i = 0, f; f = filesEZImport[i]; i++) {
		//alert(f.name);
      // Only process image files.
      if (!f.type.match('text.*') && !f.type.match('application/vnd.ms-excel') && f.type.indexOf("csv")==-1 && f.name.indexOf(".csv")==-1 && f.name.indexOf(".txt")==-1) {//text/tab/csv
      	alert("Please choose a CSV / Tab-delimited / Unicode Text File!");
      	$(".fileX1EZImport").removeClass("loadingx1");
        continue;
      }
	  if(f.type.match('text.*') && f.type.indexOf("csv")==-1 && f.name.indexOf(".csv")==-1){
	  	//cellSeperatorEZImport="\t";/tab
	  	$("#fileTypeEZImport").val("TAB");
	  }else{
	  	//cellSeperatorEZImport=",";//csv
	  	$("#fileTypeEZImport").val("CSV");
	  }
      var reader = new FileReader();

      // Closure to capture the file information.
      reader.onload = (function(theFile) {
        return function(e) {
        	var text=e.target.result;
        	var textP=(text.length>5000?text.substring(0,5000)+"\n --preview cut --":text);
        	$(".fileX1EZImport").data("fulltxt",text);
        	$(".fileX1EZImport").val(func1!=null?textP:text);
			if(func1!=null)func1();
        };
      })(f);

      // Read in the image file as a data URL.
      reader.readAsText(f,"UTF-8");//$("#encode1EZImport").val()
    }
  }
  
  var addADVImpSetsTDef=null;
    function openEasyImport(easyOnly){
    	if(easyOnly==null){
		       var buttons1=new Array();
					buttons1.push({ 
				text: "Simple / Inline Import",
				click: function() { 
				 	openEasyImportX1();
					jQuery( this ).dialog( "close" ); 
				}
				});
				
				buttons1.push({ 
				text: "Advanced Import",
				click: function() { 
				 	openAdvancedImport(addADVImpSetsTDef);
					jQuery( this ).dialog( "close" ); 
				}
				});
				
		    	messagePopupAlert("<br/>Would you like to import the file as inline rows or to use the advanced-import*? <div style='color:#696969;margin-top:10px;font-size:8pt;'>*Deduplication and field selection options are available with the advanced import</div>","Import files",buttons1);
    	}else{
    		openEasyImportX1();
    	}
    }
  function openEasyImportX1(){
  		fileX1EZImport="";
		$('#dialog-easy-import').remove(); 

		$('body').append( 
		'<div id="dialog-easy-import" title="Easy Import">' + 
		'<form id="easyimportform">'+
		'<div style="margin:5px 0px 10px 0px;font-weight:bold;">Choose a CSV / Tab-delimited / Unicode Text File or paste the file content directly from your spreadsheet:</div>'+
                   //'Choose File Encoding: <select id="encode1EZImport" onchange="$(\'#files\').val(\'\');$(\'#fileX1EZImport\').val(\'\');"><option value="UTF-8">UTF-8 File (default)</option><option value="ISO-8859-1">ISO-8859-1 File</option></select>' +
                   '<div style="margin:0px 0px 10px 0px;">Choose / Drag file: <input type="file" id="files" name="files[]" style="border:1px solid #d5d5d5;padding:5px;"/></div>'+
                    
		'<div style="margin:0px 0px 5px 0px">File Content <span style="float:right;margin-top:-5px;margin-right:3px;"><select id="fileTypeEZImport" style="color:#696969"><option value="TAB">Tab-delimited / Unicode / Copy-Paste</option><option value="CSV">CSV</option></select></span>: </div>'+
		' <Textarea class="fileX1EZImport" id="fileX1EZImport" style="width:99%;height:190px;white-space:pre"/>'+ 
		'<div><ul style="color:#696969;margin:10px 0px 0px 0px;font-size:9pt;padding:0px;"><li>The first line should have the column names as they appear on the grid/table, you can use a full or partial list of the column names.</li><li>This import only imports the columns that you have on the grid/table, missing columns will be skipped/ignored.</li><li>The imported records will be saved once you hit the save button on the grid/table, SF validation rules and security settings will be enforced.</li></ul></div>'+
		'</form>'
		); 
   var buttons1=new Array();
			buttons1.push({ 
		text: "Add content as new rows (Preview)",
		click: function() { 
		 runEasyImport(this);
		
		}
		});
		
		buttons1.push({
		text: "Cancel", 
		click: function() { 
		jQuery( this ).dialog( "close" ); 
		} 
		});
		
		$( "#dialog-easy-import" ).dialog({ 
		resizable: false, 
		width: (isSF1()?($("body").width()-10):Math.min($("body").width()-10,990)), 
		height:(isSFLight1XV?510:480), 
		//modal: true, 
		buttons: buttons1,
		open:function(){
		  	document.getElementById('files').addEventListener('change', handleFileSelectEzImport, false); 
				     fixIfmHegt();
           	}
		}); 

  
  }
   function setCharAt(str,index,chr) {
		    if(index > str.length-1) return str;
		    return str.substring(0,index) + chr + str.substring(index+1);
	}
  function getFileRows(str,Sep1){
	 if(str.indexOf("\"")>-1){
	  	var isQuoteOpen=false;
	  	var strLen=str.length;
	  	for(var i=0;i<strLen;i++){
	  		if(isQuoteOpen && str.charAt(i)=='"' &&(i==strLen-1 || str.charAt(i+1)=='\n' || str.charAt(i+1)=='\r' || str.charAt(i+1)==Sep1)){
	  			isQuoteOpen=false;
	  		}else if(!isQuoteOpen && str.charAt(i)=='"' &&(strLen==0 || str.charAt(i-1)=='\n' || str.charAt(i-1)=='\r' || str.charAt(i-1)==Sep1)){
	  			isQuoteOpen=true;
	  		}
	  		if(isQuoteOpen && str.charAt(i)=='\n' ){
	  			str=setCharAt(str,i,"\\n");
	  			strLen++;
	  			i++;
	  		}
	  	}
	  }
	  return str.split(/\n/ig);
  	
  }
  function getRowCells(str,sep1,cellReg,sepText){
  	if(str.indexOf("\"")>-1){
  	  	var isQuoteOpen=false;
	  	var strLen=str.length;
	  	var sepTextM1=sepText.length-1;
	  	var qouteStack=0;
	  	//var lastQoutPose=0;
	  	for(var i=0;i<strLen;i++){
	  	
	  		if(isQuoteOpen && str.charAt(i)=="\""){//closed quotes
	  			qouteStack++;
	  		}else{
	  			qouteStack=0;
	  		}
	  		if(isQuoteOpen && str.charAt(i)=="\"" && (qouteStack%2==1) &&(i==strLen-1 || str.charAt(i+1)=='\n' || str.charAt(i+1)=='\r' || str.charAt(i+1)==sep1)){
	  			isQuoteOpen=false;
	  		}else if(!isQuoteOpen && str.charAt(i)=="\"" &&(i==0 || str.charAt(i-1)=='\n' || str.charAt(i-1)=='\r' || str.charAt(i-1)==sep1)){
	  			isQuoteOpen=true;
	  			//lastQoutPose=i;
	  		}
	  		if(isQuoteOpen && str.charAt(i)==sep1){
	  			str=setCharAt(str,i,sepText);
	  			//isQuoteOpen=false;
	  			//alert(lastQoutPose)
	  			strLen+=sepTextM1;
	  			i+=sepTextM1;
	  		}
	  	}
	}
	var resultArr=str.split(cellReg);
	for(var i=0;i<resultArr.length;i++){
		if(resultArr[i].indexOf(sepText)>-1){
			resultArr[i]=resultArr[i].split(sepText).join(sep1);
		}
		//alert("+++"+sep1+"+++"+resultArr[i]+"+++"+( resultArr[i].charAt(0)=="\"" && resultArr[i].charAt(resultArr[i].length-1)=="\""));
		if(sep1=="," && resultArr[i]!="" && resultArr[i].charAt(0)=="\"" && resultArr[i].charAt(resultArr[i].length-1)=="\""){
			resultArr[i]=resultArr[i].substring(1,resultArr[i].length-1);
		}
		
	}
  	return resultArr;
  }
  function removeCellQuotes(cellStr){
	  	var str=cellStr;
	  	if(str.length>2 && str.charAt(0)=='"'){
	  		str=str.substring(1,str.length-1);
	  		str=str.replace(/\\n/ig,"\n").replace(/\\t/ig,"\t").replace(/\~\~/ig,",").replace(/\"\"/ig,"\"");
	  	}
		return str;

  }
  
  function makeUniqueArr(a1){
  		var a = new Array(), aseen = new Array();
  		for (var i = 0; i < a1.length; i++) {
	        a[a1[i]] = true;
	    }
	    
	    for (var k in a) {
        if(a[k] && k!='remove')aseen.push(k);
    }

    return aseen;
  }
  function arrDiff (a1, a2) {

    var a = new Array(), diff = new Array();

    for (var i = 0; i < a1.length; i++) {
        a[a1[i]] = true;
        //alert(a1[i]);
    }
    for (var i = 0; i < a2.length; i++) {
        if (a[a2[i]]) {
            a[a2[i]]=false;
        } else {
            a[a2[i]] = true;
        }
    }
    
    for (var k in a) {
        if(a[k] && k!='remove')diff.push(k);
    }

    return diff;
}
  
  
  var fileX1EZImport="";
  function runEasyImport(obj){
  
	  $.expr[":"].containsUC = $.expr.createPseudo(function(arg) {
	    return function( elem ) {
	        return $(elem).text().toUpperCase().indexOf(arg.toUpperCase()) >= 0;
	    };
	});

  	fileX1EZImport=$("#fileX1EZImport").val();
	  	if(fileX1EZImport!=""){
	  		jQuery( obj ).dialog( "close" ); 
	    	$("body").bind("addNewRowsDone", function() {
	    	try{
	    	var Sep1=($("#fileTypeEZImport").val()=="TAB"?"\t":",");
	    	var sepText=(Sep1=="\t"?"\\t":"~~");//inside comma
		  	var tabDelFile= fileX1EZImport;
		  	var rows=getFileRows(tabDelFile,Sep1);//tabDelFile.split(/\n/ig);
		  	var headers=new Array();
		  	var headersTPX=new Array();
		  	var actualRows=$(".dataRow[rowid='']");
		  	var cellReg=new RegExp(Sep1,"ig");
		  	for(var i=0;i<rows.length;i++){
		  		var cells=getRowCells(rows[i],Sep1,cellReg,sepText);//rows[i].split(cellReg);
		  		if(i==0 || cells.length==headers.length){
			  		for(var j=0;j<cells.length;j++){
			  			if(i==0){//header
			  				headers[j]=null;
			  				var columnX=$("span.thw:containsUC('"+cells[j]+"'):first");
			  				if(columnX.length==1){
			  					headers[j]=columnX.find("span.wd1[fld]").attr("fld");
			  					if(headers[j]==""){
			  						headers[j]=null;
			  					}else{
			  						headersTPX[j]=columnX.parents("th.thw[tpx]:first").attr("tpx");
			  					}
			  				}
			  			}else{
			  				if(headers[j]!=null){
			  					var headTXP=headersTPX[j];
			  					if(headTXP!=null && headTXP!="11"){//not multipicklist or picklist
			  						if(headTXP=="2"){//date
			  							var val=removeCellQuotes(cells[j]);
			  							if(val!=null && val!="" && val.match(/[0-9]+\-[0-9]+\-[0-9]+T[0-9]+\:[0-9]+\:[0-9]+.*/g)){//case date + time + zone
			  								val=new Date(val);
			  								val=(val.getMonth()+1)+"/"+val.getDate()+"/"+val.getFullYear();
			  							}
			  							$(actualRows[i-1]).find(".iTb.inpSt_"+headers[j]+":visible").val(val).change();
			  						}else if(headTXP=="6"){//datetime
			  							var val=removeCellQuotes(cells[j]);
			  							if(val!=null && val!="" && val.match(/[0-9]+\-[0-9]+\-[0-9]+T[0-9]+\:[0-9]+\:[0-9]+.*/g)){//case date + time + zone
			  								val=new Date(val);
			  								  var hours = val.getHours();
											  var minutes = val.getMinutes();
											  var ampm = hours >= 12 ? 'pm' : 'am';
											  hours = hours % 12;
											  hours = hours ? hours : 12; // the hour '0' should be '12'
											  minutes = minutes < 10 ? '0'+minutes : minutes;
											  var strTime = hours + ':' + minutes + ' ' + ampm;
			  								val=(val.getMonth()+1)+"/"+val.getDate()+"/"+val.getFullYear()+" "+strTime;
			  							}
			  							$(actualRows[i-1]).find(".iTb.inpSt_"+headers[j]+":visible").val(val).change();
			  						}else{
					  					var s1=$(actualRows[i-1]).find(".iTb.inpSt_"+headers[j]+":visible").val(removeCellQuotes(cells[j])).change();
										if(s1.length==1 && s1[0].tagName=="SELECT" && s1.val()==null){//not selected
												$(actualRows[i-1]).find("td.iTd."+headers[j]+" .ost1XEMP").html("<span class='errorMSG1X maxwith350s' onmouseover='fixTitlex1(this);'>Option Not Available: "+removeCellQuotes(cells[j])+"</span>").removeAttr("onmouseover").show();
										}
									}
				  				}else if(headTXP!=null && headTXP=="11"){//multipicklist
				  					var valx=removeCellQuotes(cells[j]).replace(/\n|\r/ig," ").replace(/[ ]+/ig," ").trim().split(/[ ]*\;[ ]*/);
				  					valx=makeUniqueArr(valx);
				  					var s1=$(actualRows[i-1]).find("select.iTb.inpSt_"+headers[j]+"").val(valx);
				  					var s1V=s1.val();
				  					if(s1V==null){
				  						$(actualRows[i-1]).find("td.iTd."+headers[j]+" .ost1XEMP").html("<span class='errorMSG1X maxwith350s' onmouseover='fixTitlex1(this);'>Options Not Available: "+removeCellQuotes(cells[j])+"</span>").removeAttr("onmouseover").show();
				  					}else if(s1V.length!=valx.length){
				  						var arrDiff1=arrDiff(s1V,valx);
				  						if(arrDiff1.length>0){
				  							$(actualRows[i-1]).find("td.iTd."+headers[j]+" .ost1XEMP").html("<span class='errorMSG1X maxwith350s' onmouseover='fixTitlex1(this);'>Options Not Available: "+(arrDiff1.join(", "))+"</span>").removeAttr("onmouseover").show();
				  						}
				  					}
			  						var e1=$(actualRows[i-1]).find("td.iTd."+headers[j]+" td.multiSelectPicklistCell a[href]:first");
			  						if(s1.length>0 && e1.length>0 ){
			  							$.globalEval(decodeURIComponent(e1.attr("href")));
			  						}

				  				}	
			  				}
			  			}
			  		}	
			  	}else{
			  		//skipping row
			  	}
		  	}
	
			setTimeout(function(){
			$("body").unbind("addNewRowsDone");
			},100);
			}catch(e){alert(e);}
			});
			NumberOfNewRows=fileX1EZImport.split(/\n/ig).length-1;//add empty rows
			if(addADVImpSetsTDef==null || addADVImpSetsTDef['recordtypeid-val']==null || addADVImpSetsTDef['recordtypeid-val']==''){
				preAddRow();
			}else{
				preAddRow2(addADVImpSetsTDef['recordtypeid-val']);
			}
		}else{
			alert("Please select a file or paste its content to the file content textarea!");
		}
  }
  
function setBatchSize1(obj, th1){
	if(!isNaN($(obj).val()) && Number($(obj).val())>0 && Number($(obj).val())<=200){
		massActionsDefBatchSize=Number($(obj).val()); 
	}else if(th1==null){
		setTimeout(function(){setBatchSize1(obj,"1");},1500);
	}else{
		$(obj).val(massActionsDefBatchSize);
	}
}
function getStoredNumPPL(str){
	var strVal=getLS1(str);
	if(strVal==null || strVal=="" || strVal=="X"){
		strVal="0";
	}
	var valInt=Number(strVal);
	valInt++;
	setLS1(str,valInt+"");
	return valInt;
}

function sendMassEMailStart(obj){
var checkedIds=""; 
var checkedId1=""; 
var leadCount=0; 
$(".lcbX input:checked").each(function(){ 
checkedId1=$(this).parents(".lcbX:first").attr("rid"); 
//alert(checkedId1.length); 
if(checkedId1!=null && checkedId1.length==18){ 
//checkedId1=checkedId1.substring(0,15); 
} 
checkedIds+=","+checkedId1; 
leadCount++; 
}); 
if(leadCount<1){ 
alert("Please select at least one row!"); 
}else{ 


function appendTags(){ 
$('#dialog-mass-email').remove(); 

$('body').append( 
'<div id="dialog-mass-email" title="Mass Emails">' + 
'<div >' + 

'<div style="margin:10px;font-weight:bold;">1) Select an email template:</div> ' + 
'' + 
'<div id="email-template" style="max-height:250px;overflow:auto;;width:100%;"> <div class="bbt1Loading"></div></div>' + 

'</div>'+ 
'<div style="margin:10px;font-weight:bold;">2) Processing Options:'+ 
'</div>'+ 
'<input type="checkbox" name="bccME" id="bccME" checked/> BCC me on one message<br>' + 
'<input type="checkbox" name="storeActME" id="storeActME" checked/> Store an Activity for each message<br>' + 
'<input type="checkbox" name="useSignatureME" id="useSignatureME"/> Use my signature<br>' + 
//'Mass Email Name <input type="text" name="descriptionME" id="descriptionME" />' + 


'' + 
'' 

); 

} 

function createPopupWindow(){ 
var emailsToSend=$(".lcbX input:checked").length;
var selRows="Send - Selected ("+(emailsToSend)+")"; 
var allRows="Send - All Rows ("+(totalCountAjx)+")"; 
$( "#dialog-mass-email" ).dialog({ 
resizable: false, 
width: (isSF1()?($("body").width()-10):490), 
height:550, 
//modal: true, 
buttons: [{ 

text:selRows, 
click:function() { 
	if(licenseStatus!='Active' && licenseStatus!='ActiveP' && (emailsToSend>200 || getStoredNumPPL("massEmailsX")>7)){ 
		licenseReqMessage("During the free trial the Mass Emails option is limited to 200 rows per shot / 7 shots in total."); 
		jQuery( this ).dialog( "close" ); 
		return; 
	}
	sendMail(); 
}}, { 
text:allRows, 
click:function() { 

	if(licenseStatus!='Active' && licenseStatus!='ActiveP' && (totalCountAjx>200 || getStoredNumPPL("massEmailsX")>7)){ 
			licenseReqMessage("During the free trial the Mass Emails option is limited to 200 rows per shot / 7 shots in total."); 
			jQuery( this ).dialog( "close" ); 
			return; 
	}
	sendMailAll(); 
}, 

},{ 
text:"Cancel", 
click:function() { 
jQuery( this ).dialog( "close" ); 


} } 
] 
}); 

} 

function messagePopupWindow(message){ 
$( "#dialog-mass-email" ).html(message).dialog({ 
resizable: false, 
width: 400, 
height:250, 
//modal: true, 
buttons: { 

Close: 
function() { 
$( this ).dialog( "close" ); 
} 
},close:function(){ 
$(".lcbX input:checked").click(); 
} 
}); 
} 

function fetchEmailTemplates(){ 

var queryZZZ="SELECT Id,Name FROM EmailTemplate order by name asc"; 
Visualforce.remoting.Manager.invokeAction( 
remoteQueryAjax2, 
queryZZZ, 
function(result, event){ 

if (event.status && result!=null) { 

var innerHtml = ''; 
var records=result; 
for(var i=0; i<records.length; i++) 
innerHtml += 
'<div class="maxwith350s" onmouseover="fixTitlex1(this);"><input type="radio" name="emailTemp" value="' + records[i].Id + '"/> <a href="/' + records[i].Id + '" target="_blank">Preview' + 

'</a> ' + 
records[i].Name + 
'</div>'; 

$('#email-template').html(innerHtml); 
} else if (event.type === 'exception') { 
if(event.message!=null && ((event.message+"").indexOf("Logged in")>-1 || (event.message+"").indexOf("Refresh page")>-1)){ 
self.location=self.location; 
}else if(event.message!=null && (event.message+"").indexOf("Unable to connect")==-1){ 
if($("body:visible").length>0)alert("An error has occurred: "+event.message); 
} 
} else { 
//self.location=self.location; 
// $("#"+filterIdSpan+" .availVals").html(""); 
//alert(1); 
} 

}, 
{escape: true,buffer:true,timeout: 90000} 
); 
} 
function sendMailAll(){ 

var templateId = $.trim($("input[name='emailTemp']:checked").val()); 
//alert(templateId ); 
if( templateId!=''){ 
$(".lcbX input:checked").click(); 
$( "#dialog-mass-email" ).parents(".ui-dialog:first").hide(); 
openAllmassActionAll("Starting Mass Emails...#Stop#Stopping...#Current Progress: #Complete!#Close#Are you sure you want to send the selected email-template to all the "+obj+"?#Mass Emails All Rows",sendMail1,200); 
}else{ 
alert("Please select a template!"); 
} 
} 
function sendMail1(emailID){ 

var templateId = $.trim($("input[name='emailTemp']:checked").val()); 
var contactIds = emailID.split(";"); 


Visualforce.remoting.Manager.invokeAction( 
remotesendMassEmails, 
contactIds.join(","), 
templateId, 
$("#storeActME").prop("checked"),//saveAsActivity 
$("#bccME").prop("checked"),//bccSender 
$("#useSignatureME").prop("checked"),//useSignature 
null,//replyTo 'noreply@salesforce.com' 
function(result, event){ 

if (event.status && result!=null) { 

if((result+"")=="OK"){ 
//messagePopupWindow('<br><span class="ui-icon ui-icon-check" style="float:left;margin-right:10px;display:inline-block;"></span><b>Your email(s) have been submitted for processing.</b><br><br>The Mass-Mailer result will be sent to you via email.'); 
messageCellMActionALL=""; 
doAllmassActionAll("1"); 
}else{ 
//messagePopupWindow('Your email(s) were not submitted due to an Error:<br>'+result); 
messageCellMActionALL='Your email(s) were not submitted due to an Error:<br>'+result; 
doAllmassActionAll("1"); 
} 

} else if (event.type === 'exception') { 
if(event.message!=null && ((event.message+"").indexOf("Logged in")>-1 || (event.message+"").indexOf("Refresh page")>-1)){ 
self.location=self.location; 
}else if(event.message!=null && (event.message+"").indexOf("Unable to connect")==-1){ 
messageCellMActionALL="An error has occurred: \n\n"+((event.message+"").indexOf("MASS_MAIL_LIMIT_EXCEEDED")>-1?"You reached your daily Salesfore email-limit - continue tommorow!":""+event.message); 
$("#massActionAllAllDialog").remove();	
//	alert("An error has occurred: "+event.message); 
doAllmassActionAll("1"); 

} 
} else { 
//self.location=self.location; 
// $("#"+filterIdSpan+" .availVals").html(""); 
//alert(1); 
} 

}, 
{escape: true,buffer:true,timeout: 90000} 
); 



} 


function sendMail(emailID){ 
var checkedIdsX=""; 
$(".lcbX input:checked").each(function(){ 
checkedId1=$(this).parents(".lcbX:first").attr("rid"); 

checkedIdsX+=","+checkedId1; 
}); 
var contactIds = checkedIdsX.substring(1).split(","); 
var templateId = $.trim($("input[name='emailTemp']:checked").val()); 
//alert(templateId ); 
if( contactIds.length>0 && templateId!=''){ 

Visualforce.remoting.Manager.invokeAction( 
remotesendMassEmails, 
contactIds.join(","), 
templateId, 
$("#storeActME").prop("checked"),//saveAsActivity 
$("#bccME").prop("checked"),//bccSender 
$("#useSignatureME").prop("checked"),//useSignature 
null,//replyTo 'noreply@salesforce.com' 
function(result, event){ 

if (event.status && result!=null) { 

if((result+"")=="OK"){ 
messagePopupWindow('<br><span class="ui-icon ui-icon-check" style="float:left;margin-right:10px;display:inline-block;"></span><b>Your email(s) have been submitted for processing.</b><br><br>The Mass-Mailer result will be sent to you via email.'); 

}else{ 
messagePopupWindow('Your email(s) were not submitted due to an Error:<br>'+result); 
} 

} else if (event.type === 'exception') { 
if(event.message!=null && ((event.message+"").indexOf("Logged in")>-1 || (event.message+"").indexOf("Refresh page")>-1)){ 
self.location=self.location; 
}else if(event.message!=null && (event.message+"").indexOf("Unable to connect")==-1){ 
if($("body:visible").length>0)alert("An error has occurred: \n\n"+((event.message+"").indexOf("MASS_MAIL_LIMIT_EXCEEDED")>-1?"You reached your daily Salesfore email-limit - continue tommorow!":""+event.message)); 
} 
} else { 
//self.location=self.location; 
// $("#"+filterIdSpan+" .availVals").html(""); 
//alert(1); 
} 

}, 
{escape: true,buffer:true,timeout: 90000} 
); 

}else{ 
alert("Please select a template!"); 
} 
} 

appendTags(); 
fetchEmailTemplates(); 
createPopupWindow(); 


} 
return false;

}//sendMassEMailStart


function licenseReqMessage(messageStart){//"During the free trial the Mass Emails option is limited to 200 rows per shot / 7 shots in total.
	messagePopupAlert("<div style=\"padding:15px;\">"+messageStart+"<br/><br/>Use our website <a href=\"http://www.zaapit.com/page/pricing\" target=\"_blank\">http://www.zaapit.com/page/pricing</a> or contact <a href=\"mailto:sales@zaapit.com?subject=ZaapIT License\">sales@zaapit.com</a> to activate your license! </div>","License required");
}

	function messagePopupAlert(message,title1,button,width1,height1){ 
		
		 var buttons1=new Array();
		 if(button!=null && button.length==null){
		 	 buttons1.push(button);
		 }else if(button!=null && button.length!=null){
		 	buttons1=button;
		 }
		 
		 buttons1.push({
		text: "Close", 
		click: function() { 
		jQuery( this ).dialog( "close" ); 
		} 
		});
		if(width1==null){
			width1=450;
		}
		if(height1==null){
			height1=270;
		}
		$("#dialog-popup-alert").remove();
		if($( "#dialog-popup-alert" ).length==0){
			$('body').append( '<div id="dialog-popup-alert" title="'+(title1!=null?title1:'')+'"></div>');
		} 
		$( "#dialog-popup-alert" ).html(message).dialog({ 
		resizable: false, 
		width: width1, 
		height:height1, 
		//modal: true, 
		buttons: buttons1}); 
		
		} 
		
		
		
		/**
		 * main lookuup
		 * mainLookupPU pricebooksentryid
		 * mainLookupLC name
		 
		 * autoFillComp: [{"if":"field1JQ=XXX","&&":"field2=YYY","true":"fieldJQX=fieldJQY","false":"fieldJQZ=fieldJQP"},//if not contains . then fixed value
		 * 				  {"if":"field1JQ=fieldX1JQ","&&":"","true":"fieldJQX1=fieldJQY1","false":"fieldJQZ2=fieldJQP2"}]//if not contains . then fixed value
				 */
        function addSelectedRowsToParent(mainLookupPU, mainLookupLC, autoFillComp){
        
        	//var autoFillX=".inpSt_unitprice~.oSt_unitprice .ost1I span~td.iTd.listprice~.oSt_unitprice .ost1I span~td.pricebookentry-productcode.iTd~.oSt_productcode .ost1I span~td.iTd.pricebookentry-productcode~.oSt_productcode .ost1I span";
       		//var autoFillX2="";
        	//var autoFillXAll="";
            var CBs=$(".lcbXRow:checked");
            if(CBs.length==0){
                alert("Please select at least 1 row!");
            }else{
                //alert(CBs[0])
                top.window.opener.$("body").bind("addNewRowsDone",function(){
                	setTimeout(function(){
                    //top.window.opener.filldus();
                    var count1=0;
                    //autoFillXAll=autoFillX+autoFillX2;
                    
                    top.window.opener.$(".lcbXRow.RID").each(function(){
                        if(top.window.opener.$(this).parents("tr:first").find(".lookupInput input.iTb.inpSt_"+mainLookupPU).val()=="" && count1<CBs.length){
                            //alert(1);
                            var tr1=top.window.opener.$(this).parents("tr:first");
                            var tr2=$(CBs[count1]).parents("tr:first");
                            //alert(tr2.find(".name .oSt_name a[afld]").attr("afld"));
                            tr1.find("."+mainLookupPU+".iTd input[name*='lkold']").val(tr2.find(".oSt_"+mainLookupLC+" a:first").text());
                            tr1.find("."+mainLookupPU+".iTd input[name*='lkid']").val(tr2.find("."+mainLookupLC+" .oSt_"+mainLookupLC+" a[afld]").attr("afld"));
                            
                            var nameXX1=tr2.find(".oSt_"+mainLookupLC+" a:first").text();
                            tr1.find(".iTb.inpSt_"+mainLookupPU+"").val(nameXX1);
                            var commandX1=new Array();
                            if(top.window.opener.autoFillSpans!=null)top.window.opener.autoFillSpans.push(commandX1);
                            try{
                            	
                                for(var i=0;i<autoFillComp.length;i++){
                                	var ifArr=autoFillComp[i]["if"].split("=");
                                	var IfandArr=autoFillComp[i]["&&"].split("=");
                                	var cond=(ifArr.length<2||(ifArr.length>1 && $.trim(tr2.find(ifArr[0]).text())== (ifArr[1].indexOf(".")==-1?ifArr[1]:$.trim(tr2.find(ifArr[1]).text())) ))&&
                                		(IfandArr.length<2||(IfandArr.length>1 && $.trim(tr2.find(IfandArr[0]).text())== (IfandArr[1].indexOf(".")==-1?IfandArr[1]:$.trim(tr2.find(IfandArr[1]).text())) ));
                                	//alert(	cond+ "+++"+autoFillComp[i][cond+""]+"+++"+ifArr+"+++"+tr2.find(ifArr[0]).text());
                                	if(autoFillComp[i][cond+""]!=null){
                                		var doxArr=autoFillComp[i][cond+""].split("|");
                                		for(var j=0;j<doxArr.length;j++){
		                                	var dox1=doxArr[j].split("=");
		                                	
		                                    var p1=tr1.find(dox1[0]);
		                                    var p2=(dox1[1].indexOf(".")==-1? dox1[1]:tr2.find(dox1[1]).text());
		                                    if(p1.length>0){
		                                        var val2=$.trim(p2);
		                                        val2=$.trim(val2);
		                                        //alert(val2);
		                                        if(p1[0].tagName!=null && ((p1[0].tagName=="INPUT" && p1[0].type!="checkbox") || p1[0].tagName=="SELECT")){
		                                            val2=$.trim(val2.replace("$","").replace("€","").replace("USD","").replace("SGD","").replace("CAD","").replace("AUD","").replace("ARS","").replace("MXN","").replace("EUR","").replace("GBP","").replace("JPY","").replace("KRW","").replace("CNY","").replace("BRL","").replace("ILS","").replace("RUB","").replace("INR",""));
		                                            p1.val(val2).change();
		                                        }else if(p1[0].tagName!=null && p1[0].tagName=="INPUT" && p1[0].type=="checkbox"){
		                                        	p1.prop("checked",(val2=="checked")).change();
		                                        }else{
		                                            p1.html(val2);
		                                            //commandX1.push([autoFillXArr[i],val2]);
		                                        }
		                                    }
	                                    }
                                    }
                                }
                            }catch(e){
                                alert(e);
                            }
                            //alert(1);
                            if(!top.window.opener.$(this).is(":checked")){
                                top.window.opener.$(this).click();
                            }
                            count1++;
                            
                        }
                    });
                    CBs.click();
                    
                    top.window.opener.$("body").unbind("addNewRowsDone");
                    },100);
                });
                var old1NOR=top.window.opener.NumberOfNewRow;
                top.window.opener.NumberOfNewRows=CBs.length;
                top.window.opener.preAddRow();
                top.window.opener.NumberOfNewRows=old1NOR;
                
                
                
                
            }
        }
        
        
        
        
/**importo advanced import**/

function handleFileSelectADVImport(evt){
	$(".fileX1EZImport").addClass("loadingx1");
	handleFileSelectEzImport(evt,addADVImpFieldsSelection);
	
}

var addADVImpSets=[];
function addADVImpFieldsSelection(){


Visualforce.remoting.Manager.invokeAction(
                        remotequeryAjax2GetTbFields,
                        advancedImporttableX1, 
                        function(result, event){
                            if (event.status && result!=null) {

						fileX1EZImport=$("#fileX1EZImport").val();
								if(fileX1EZImport!=""){
									var cellMap=new Array();
									var selectOpt="<option value=''>Please Select / Custom Value</option>";
									var Sep1=($("#fileTypeEZImport").val()=="TAB"?"\t":",");
									var sepText=(Sep1=="\t"?"\\t":"~~");//inside comma
								  	var tabDelFile= fileX1EZImport;
								  	var rows=getFileRows(tabDelFile,Sep1);//tabDelFile.split(/\n/ig);
								  	var cellReg=new RegExp(Sep1,"ig");
							  		var cells=getRowCells(rows[0],Sep1,cellReg,sepText);
							  		$(".fieldSelectionIn").html("");
							  		for(var i=0;i<cells.length;i++){
							  			var tempN=cells[i].replace(/["\,~]+/ig,'').toLowerCase();
							  			if(cells[i]!="")selectOpt+="<option value='"+i+"'>"+(cells[i].replace(/[\"\,~]+/ig,''))+"</option>";
							  			cellMap[tempN]=i;
							  			
							  		}
							  	$(".fieldSelection").removeClass("hd1");
                                var isFirstChild=true;
                                var tbCont1="<table cellpadding='4' width='99%' cellspacing='0' class='fieldSelectionInTB'><thead><tr><th>SF Fields</th><th>Expected Value</th><th>Select content Column</th><th>Selected Value</th><th> <span class='helpQMSFDC' onmouseover='fixTitlex2(this,false,\"R\",1);' title='Use this field to detect Duplicates'>Unique / Dupe</span></th></tr></thead><tbody>";
                                var tbCont1In="";
                                var funcsTorun=new Array();
                                for(var i=0;i<result.length;i++){
                                    //alert(result[i].label+" "+result[i].name+ " "+result[i].relationshipName);
                                    if(result[i].name!=null && result[i].childRel==0 ){
                                        var isChilds=false;
                                        
                                        if(result[i].type!='CHILDS'){ 
                                            //sel1+="<option cr=\""+result[i].childRel+"\" value=\""+result[i].name+"\" ref=\""+result[i].referenceTo+"\" rn=\""+result[i].relationshipName+"\" tp=\""+result[i].type+"\" isref=\"0\">"+result[i].label+"</option>";
                                            var tempN=cellMap[result[i].label.toLowerCase()];
                                            var def=addADVImpSets[result[i].name.toLowerCase()];
                                            var defV=addADVImpSets[result[i].name.toLowerCase()+"-val"];
                                            var defDupe=addADVImpSets[result[i].name.toLowerCase()+"-dupe"];
                                            var defchooseType=addADVImpSets[result[i].name.toLowerCase()+"-chooseType"];
                                            var devVal="";
                                            if(def!=null){
                                            	var defArr=def.split("|");
                                            	for(var j=0;j<defArr.length;j++){
                                            		if(cellMap[defArr[j]]==null){
                                            			devVal+="|"+defArr[j];
                                            		}else{
                                            			devVal+="|"+cellMap[defArr[j]];
                                            		}
                                            	}
                                            	devVal="Column:"+devVal.substring(1);
                                            	//alert(devVal);
                                            }
                                            if(defV!=null){
                                            	devVal=defV;
                                            }
                                            //if(result[i].referenceToFull!=null )alert(result[i].referenceToFull);
                                            var typeChoose=result[i].type;
                                            if(result[i].referenceToFull!=null){
                                            	var tc1=result[i].referenceToFull.split("#");
                                            	var typeChoose1="<option>ID</option>";
                                            	for(var z1=0;z1<tc1.length;z1++){
                                            		typeChoose1+="<option>"+tc1[z1]+"</option>";
                                            	}
                                            	typeChoose="<select style='max-width: 195px;' name='"+(result[i].name+"-"+result[i].type+"-"+result[i].Createable+"").toLowerCase()+"' class='chooseType' title='Non existing values are treated as nulls' onmouseover='fixTitlex2(this,false,\"R\",1);'>"+typeChoose1+"</select>";
                                            	
                                            	if(defchooseType!=null && defchooseType!=""){
                                            		var x1=(result[i].name+"-"+result[i].type+"-"+result[i].Createable+"").toLowerCase();
                                            		funcsTorun.push([x1,defchooseType,function(x1,defchooseType){
                                            		if($(".chooseType[name='"+x1+"']").html().indexOf(defchooseType)==-1){
                                            			$(".chooseType[name='"+x1+"']").append("<option>"+defchooseType+"</option>");
                                            		}
                                            		$(".chooseType[name='"+x1+"']").val(defchooseType);
                                            		}]);
                                            	}
                                            }
                                            if(result[i].Createable!="true"){
                                            	typeChoose+=" <sup style='color:#696969;'>RO</sup>";
                                            }
                                            if(result[i].type =="BOOLEAN"){
                                            	var x1=".fldInput"+result[i].name;
                                            	funcsTorun.push([x1,null,function(x1){
                                            	$(x1).autocomplete({
            									source: ["TRUE","FALSE"],minLength: 0
          									  	}).attr("onclick",'$(this).autocomplete( "search", "" )');
          									  	}]);
          									}else if(result[i].type =="PICKLIST"){
          										var arr1=result[i].PicklistValues.split("#");
          										var x1=".fldInput"+result[i].name;
          										funcsTorun.push([x1,arr1,function(x1,arr1){
                                            	$(x1).autocomplete({
            									source: arr1,minLength: 0
          									  	}).attr("onclick",'$(this).autocomplete( "search", "" )');
          									  	}]);
          									}
          									
                                           tbCont1In=(devVal=="" && tempN==null?tbCont1In:"")+"<tr class='imR "+(result[i].Createable=="true"?"":"ro1 hd1")+"' r='"+i+"' name='"+result[i].name+"'><td><span class='l'>"+result[i].label+"</span></td><td>"+(typeChoose)+"</td><td> <select class='fldM A-"+i+"' name='A-"+i+"-"+result[i].name+"' onchange='$(this).parents(\".imR:first\").find(\".fldInput\").val(($(this).val()==\"\"?\"\":\"Column:\"+$(this).val()))'>"+(tempN!=null?selectOpt.replace("'"+tempN+"'>","'"+tempN+"' selected>"):selectOpt)+"</select></td><td> <input type='text' name='"+(result[i].name+"-"+result[i].type+"-"+result[i].Createable).toLowerCase()+"' placeholder='Map / Actual Value' autocomplete='off' class='fldInput fldInput"+result[i].name+" "+(result[i].type.toLowerCase().indexOf('date')>-1?"datePick":"")+"' value='"+(devVal!=""?devVal:(tempN!=null?"Column:"+tempN:""))+"' ></td><td><input type='checkbox' name='dupe' class='dupe' "+(defDupe!=null?"checked":"")+"> </td></tr>"+(devVal!="" || tempN!=null?tbCont1In:"");  
                                        }else{
                                            /*isChilds=true;
                                            if(isFirstChild){
                                                isFirstChild=false;
                                                if(addSubChilds==null){
                                                    sel1+="<optgroup label=\" --- Child Relationships ---\"></optgroup>";
                                                }
                                            }*/
                                        }
                                      //  if((!isChilds ||addSubChilds==null)&&result[i].referenceTo!=null && result[i].referenceTo.indexOf("ActivityHistory")==-1 && result[i].referenceTo.indexOf("OpenActivity")==-1){
                                      //      sel1+="<option value=\""+result[i].referenceTo+"\" ref=\""+result[i].referenceTo+"\" rn=\""+result[i].relationshipName+"\" isref=\"1\">"+result[i].referenceTo+" ("+result[i].label+") &gt;</option>";
                                      //  }
                                    }
                                }
                                tbCont1+=tbCont1In+"</tbody></table><div style='padding:5px;'><button name='showHideRO' class='btn' type='button' onclick='$(\".fieldSelectionInTB tr.imR.ro1\").toggleClass(\"hd1\"); return false;'> Show / Hide Readonly Field </button> - Use this option to search for existing rows or to detect duplicates</div>";
                                	$(".fieldSelectionIn").append(tbCont1);
                                	for(var z2=0;z2<funcsTorun.length;z2++){
                                		funcsTorun[z2][2](funcsTorun[z2][0],funcsTorun[z2][1]);
                                	}
								}else{
									alert("Please select a file or paste its content to the file content textarea!");
								}
								
								$(".fileX1EZImport").removeClass("loadingx1");
								$(".fieldSelectionIn .datePick").datepicker( { 
								    dateFormat: "yy-mm-dd"
								    ,changeMonth: true
								    ,changeYear: true 
								    });

				
								
	

                             } else if (event.type === 'exception') {
                                if(event.message.indexOf("Logged in?")>-1){
                                    top.location=top.location;
                                }else{
                                    alert(event.message);
                                }
                            } else {
                                alert(event.message);
                            }
                        }, 
                        {escape: true,buffer:true,timeout: 90000}
                    );
                    
		  	
}
function loadMoreObjectsForSelection(seq){
	$("#mainObjPre").css({"background":"#E5E5E5 url('/img/loading.gif') 91% 50% no-repeat"});
	Visualforce.remoting.Manager.invokeAction( 
				remoteQueryAjax2GetTablesETL, 
				seq+"",//extra STR 
				function(result, event){ 
		
				if (event.status && result!=null) { 
		
					var innerHtml = ''; 
					var innerHtmlGroupable = ''; 
					var innerHtmlOverwrite ='';
					
					var records=result; 
					for(var i=0; i<records.length; i++) {
						 	innerHtml+='<option value="'+records[i].name+'" '+(records[i].name=='lead'?'selected':'')+'>'+records[i].label+'</option>';//records[i].name.toLowerCase();
						
					}
					$("#mainObjPre").append(innerHtml);
					$(".searchSelMainOut:visible").remove();
					if(records.length>=250){
						$("#mainObjPre").css({"background":"#E5E5E5 url('/img/loading.gif') 91% 50% no-repeat"});
						loadMoreObjectsForSelection(seq+1);
					}else{
						$("#mainObjPre").css({"background":"#ffffff"});
					}
				} else if (event.type === 'exception') { 
				if(event.message!=null && ((event.message+"").indexOf("Logged in")>-1 || (event.message+"").indexOf("Refresh page")>-1)){ 
				self.location=self.location; 
				}else if(event.message!=null && (event.message+"").indexOf("Unable to connect")==-1){ 
				if($("body:visible").length>0)alert("An error has occurred: "+event.message); 
				} 
				} else { 
				//self.location=self.location; 
				// $("#"+filterIdSpan+" .availVals").html(""); 
				//alert(1); 
				} 
		
				}, 
				{escape: true,buffer:true,timeout: 90000} 
				); 
}
function openAdvImportJob(){
	var html1='<div style="font-weight:bold; margin: 10px 0px;width:98%;">Please select the main object for the import job:</div>'+
				'<div id="mainObjPreDiv" style="margin-top: 14px;"><b>Loading...</b></div>';
				
				var button1={
				text: "Select Main Object", 
				click: function() { 
				openAdvancedImport(null,$("#mainObjPre").val());
				jQuery( this ).dialog( "close" ); 
				}};
				//alert(html1);
				messagePopupAlert(html1,"Import Job",button1);
				
				
					Visualforce.remoting.Manager.invokeAction( 
		remoteQueryAjax2GetTablesETL, 
		"",//extra STR 
		function(result, event){ 

		if (event.status && result!=null) { 

		var innerHtml = ''; 
		var innerHtmlGroupable = ''; 
		var innerHtmlOverwrite ='';
		
		var records=result; 
		for(var i=0; i<records.length; i++) {
			 	innerHtml+='<option value="'+records[i].name+'" '+(records[i].name=='lead'?'selected':'')+'>'+records[i].label+'</option>';//records[i].name.toLowerCase();
			
		}
		$('#mainObjPreDiv').html('<select id="mainObjPre" style="width: 96%;height: 34px;" onmousedown="return isSF1();" onclick=" return openSearchSel3(this,event,this.id);" onkeydown="return openSelXDP3(this,event,this.id);">'+innerHtml+'<select>');
		
		
		if(records.length>=250){
			loadMoreObjectsForSelection(1);
		}
		
		} else if (event.type === 'exception') { 
		if(event.message!=null && ((event.message+"").indexOf("Logged in")>-1 || (event.message+"").indexOf("Refresh page")>-1)){ 
		self.location=self.location; 
		}else if(event.message!=null && (event.message+"").indexOf("Unable to connect")==-1){ 
		if($("body:visible").length>0)alert("An error has occurred: "+event.message); 
		} 
		} else { 
		//self.location=self.location; 
		// $("#"+filterIdSpan+" .availVals").html(""); 
		//alert(1); 
		} 

		}, 
		{escape: true,buffer:true,timeout: 90000} 
		); 
}

var advancedImporttableX1="";
  function openAdvancedImport(addADVImpSetsT,tableX1temp){
  		if(addADVImpSetsT==null){
  			addADVImpSetsT=[];
  		}
  		if(tableX1temp!=null && tableX1temp!=''){
  			advancedImporttableX1=tableX1temp;
  		}else{
  			advancedImporttableX1=tableX1;
  		}
  		
  		addADVImpSets=addADVImpSetsT;
  		fileX1EZImport="";
		$('#dialog-easy-import').remove(); 

		$('body').append( 
		'<div id="dialog-easy-import" title="Advanced Import">' + 
		'<form id="easyimportform">'+
		'<div style="margin:5px 0px 10px 0px;font-weight:bold;">1) Choose a CSV / Tab-delimited / Unicode Text File or paste the file content directly from your spreadsheet:</div>'+
                   //'Choose File Encoding: <select id="encode1EZImport" onchange="$(\'#files\').val(\'\');$(\'#fileX1EZImport\').val(\'\');"><option value="UTF-8">UTF-8 File (default)</option><option value="ISO-8859-1">ISO-8859-1 File</option></select>' +
                   '<div style="margin:0px 0px 10px 0px;">Choose / Drag file: <input type="file" id="files" name="files[]" style="border:1px solid #d5d5d5;padding:5px;"/></div>'+
                    
		'<div style="margin:0px 0px 5px 0px">File Content / Preview <span style="float:right;margin-top:-5px;margin-right:3px;"><select id="fileTypeEZImport" onchange="if($(\'.fileX1EZImport\').val()!=\'\')addADVImpFieldsSelection();" style="color:#696969"><option value="TAB">Tab-delimited / Unicode / Copy-Paste</option><option value="CSV" >CSV</option></select></span>: </div>'+
		' <Textarea class="fileX1EZImport" id="fileX1EZImport" style="width:99%;height:69px;white-space:pre" onchange="$(\'.contADVIm\').hide();addADVImpFieldsSelection();" onclick="$(\'.contADVIm\').show();"/><div style="width:230px;padding:5px;" class="contADVIm ui-state-default ui-corner-all hd1" onclick="$(this).hide();" ><span class="ui-icon ui-icon-circle-triangle-s" style="display: inline-block;vertical-align: -3px;"></span> Recalculate Field Mapping</div>'+ 
		'<div class="fieldSelection hd1" style="margin-top:15px;"><b>2) Fields Mapping:</b><div class="fieldSelectionIn" style="margin-top: 5px;max-height:195px;width:99%;overflow:auto;padding:5px 0px;border:1px solid #aaaaaa;"> - Upload file first - </div>'+
		'<div style="margin-top:5px;margin-bottom:0px;"><span style="display:inline-block;width:250px">Decimal / Currency value cleanup:</span> <select  name="skipInvalidNums" class="skipInvalidNums" ><option value="asis">Use numbers as is</option><option value="skip" '+('1'==addADVImpSets['skipInvalidNums'] || 'skip'==addADVImpSets['skipInvalidNums']?'selected':'')+'>Skip invalid numbers during import</option><option value="removeComma" '+('removeComma'==addADVImpSets['skipInvalidNums']?'selected':'')+'>Remove commas from numbers - select this option when commas are used as the thousands separator</option> <option value="removeDot" '+('removeDot'==addADVImpSets['skipInvalidNums']?'selected':'')+'>Remove dots from numbers - select this option when dots are used as the thousands separator</option> </select></div>'+
		'<div style="margin-top:5px;"><span style="display:inline-block;width:250px">Empty cells strategy:</span> <select  name="skipEmptyCells" class="skipEmptyCells" ><option value="skip">Skip / Ignore empty values</option><option value="use" '+('use'==addADVImpSets['skipEmptyCells']?'selected':'')+'>Don\'t ignore empty values - update empty values</option></select></div>'+
		'<div style="margin-top:5px;"><span style="display:inline-block;width:250px">Duplicates strategy:</span> <select name="detectDupes" class="detectDupes"><option value="update">Update existing Rows (upsert)</option><option value="skip">Skip duplicates</option><option value="create">Create duplicates</option></select></div>'+
		'<div style="color:#696969;margin-top:5px;">RO: Use the read-only fields to search for dupes/existing records.</div></div>'+
		'</form>'
		); 
   var buttons1=new Array();
			buttons1.push({ 
		text: "Import Rows",
		click: function() { 
		 runAdvImport(this);
		
		}
		});
		
		buttons1.push({
		text: "Close", 
		click: function() { 
		jQuery( this ).dialog( "close" ); 
		} 
		});
		
		$( "#dialog-easy-import" ).dialog({ 
		resizable: false, 
		width: (isSF1()?($("body").width()-10):Math.min($("body").width()-10,1100)), 
		height:(isSFLight1XV?655:625), 
		//modal: true, 
		buttons: buttons1,
		open:function(){
		  	document.getElementById('files').addEventListener('change', handleFileSelectADVImport, false); 
				     fixIfmHegt();
           	}
		}); 

  
  }
  
  
  function runAdvImport(obj){
  		fileX1EZImport=$(".fileX1EZImport").data("fulltxt");
			if(fileX1EZImport==null || fileX1EZImport==""){
		  		fileX1EZImport=$("#fileX1EZImport").val();
		  	}
	  	if(fileX1EZImport!=""){
	  		var vals="";
	  		$(".fldInput").each(function(){vals+=$(this).val();});
	  		if(vals==""){
	  			alert("Please select/set at least 1 selected value!");
	  		}else{
	  			var imp1=AdvImportObj(fileX1EZImport);
	  		}
	  	}else{
			alert("Please select a file or paste its content to the file content textarea!");
		}
  }
  
  function AdvImportObj(fileX1EZImport){
  	  var AdvImportObjProgTextsArr="Starting Import...#Stop#Stopping...#Current Progress: #Complete!#Close#Are you sure?\n\nThis is the second and last confirm for import!#Import Rows".split("#");
	  $.expr[":"].containsUC = $.expr.createPseudo(function(arg) {
	    return function( elem ) {
	        return $(elem).text().toUpperCase().indexOf(arg.toUpperCase()) >= 0;
	    };
	});
	
	
function initProgress(totalCount){
		$("#AdvImportObjDialog").remove();
		$("body").append("<div id='AdvImportObjDialog'><div class='progress-label'>"+AdvImportObjProgTextsArr[0]+"</div><div id='AdvImportprogbar' style='margin-top:15px;'></div><div id='importErr' style='height:69px;overflow:auto;margin-top:5px;'></div></div>");
	AdvImportproLabel = $( ".progress-label" );
	AdvImportprogbar = $( "#AdvImportprogbar" );
	
	var AdvImportObjDialog=$("#AdvImportObjDialog").dialog({
            resizable: true,
            height:300,
            width:(isSF1()?($(self).width()-20):500),
            modal: openDialogAsMod(),
            title: AdvImportObjProgTextsArr[7],
            buttons: [{
            text:AdvImportObjProgTextsArr[1], //stop
            click: function() {
               stopAdvImportObj=true;
                AdvImportObjDialog.dialog( {"buttons":[{
			          text: AdvImportObjProgTextsArr[2], //Stopping...#
			          click: function(){
			          //$( this ).dialog( "close" );
			          }
			        }]});
            }}]
            ,
            open: function() {
         		 //progressTimer = setTimeout( progress, 2000 );
         		 AdvImportprogbar.progressbar({
			      value: false,
			      max:totalCount,
			      change: function() {
			      	var val1=AdvImportprogbar.progressbar( "value" );
			      	if(val1==null){val1=0;}
			      						//"Current Progress: " 
			        AdvImportproLabel.html( AdvImportObjProgTextsArr[3] + Math.round((val1/totalCount)*100.0) + "% ("+val1+" / "+totalCount+")" );
			      },
			      complete: function() {
			        AdvImportproLabel.text( AdvImportObjProgTextsArr[4] );//"Complete!"
			        stopAdvImportObj=true;
			        changeImportBtns();
			        
                     searchChanged(1);//
                  }
			 });
 				//
       		},
             close: function( event, ui ) {
             	$( this ).dialog( "close" );
             }
            });
} // initProgress

function changeImportBtns(){
	$("body").trigger("OnAdvImportDone");//use importErr for text
	$("#AdvImportObjDialog").dialog( {"buttons":[{
			          text: AdvImportObjProgTextsArr[5], //"Close"
			          click: function(){
			          $( this ).dialog( "close" );
			          } 
			        }]});
}

			var stopAdvImportObj=false;
  			var AdvImportproLabel=null;
  			var AdvImportprogbar=null
	    	var Sep1=($("#fileTypeEZImport").val()=="TAB"?"\t":",");
	    	var sepText=(Sep1=="\t"?"\\t":"~~");//inside comma
		  	var tabDelFile= fileX1EZImport;
		  	var rows=getFileRows(tabDelFile,Sep1);//tabDelFile.split(/\n/ig);
		  	
		  	if(licenseStatus!='Active' && licenseStatus!='ActiveP' && (rows.length>200 || getStoredNumPPL("advImport")>7)){ 
					licenseReqMessage("During the free trial the advanced import is limited to 200 rows per shot / 7 shots in total."); 
					//jQuery( this ).dialog( "close" ); 
					return; 
			}
		
		  	var headers=new Array();
		  	//var headersTPX=new Array();
		  	var actualRows=$(".dataRow[rowid='']");
		  	var cellReg=new RegExp(Sep1,"ig");
		  	var detectDupes=$(".detectDupes").val();
		  	var skipInvalidNums=$(".skipInvalidNums").val()+"";
		  	var skipEmptyCells=$(".skipEmptyCells").val()+"";
		  	var useEmptyLookups=addADVImpSets['useEmptyLookups'];
		  	var skipRowsEmptyLookups=addADVImpSets['skipRowsEmptyLookups'];
		  	var currRow=0;
		  	var currAdvImportObj=this;
		  	initProgress(rows.length);
		  	
		  	start();
		  	
		  function start(){
		  		var listRow=[];
		  		var lastcurrRow=currRow;
		  		var fields="";
		  		var batchSizeAI=addADVImpSets['batchSize'];//batchSize in settings
		  		if(batchSizeAI==null || isNaN(batchSizeAI)){
		  			batchSizeAI=50;
		  		}
		  		for(var z=0;z<batchSizeAI && currRow<rows.length;z++){
		  		var cells=getRowCells(rows[currRow],Sep1,cellReg,sepText);//rows[i].split(cellReg);
		  		//alert(cells.length+" "+headers.length+ " "+cells);
		  		if(currRow==0 || cells.length==headers.length){
		  			var objX={};
			  		
			  			if(currRow==0){//header
			  				for(var j=0;j<cells.length;j++){
			  					headers[j]=cells[j].replace(/["\,]/ig,"");
			  					}
			  			}else{
			  				//objX
			  				$(".fieldSelectionIn .fldInput").each(function(){
			  					var val=$(this).val();
			  					if(val!=""){
				  					if(val.indexOf("Column:")>-1){//column to values
				  						var vArr=val.split(":")[1].split("|");
				  						val="";
				  						for(var k=0;k<vArr.length;k++){
				  							if(!isNaN(vArr[k])){
				  								val+=" "+cells[Number(vArr[k])];
				  							}else{
				  								val+=" "+vArr[k];
				  							}
				  						}
				  					}
				  					objX[this.name]=$.trim(val);
				  					
				  					if(fields.indexOf("|"+this.name)==-1)fields+="|"+this.name;
			  					}
			  				});
			  				
			  			}
			  		
			  		if(currRow>0) listRow.push(objX);
			  	}else{
			  		//skipping empty row
			  	}
			  		currRow++;
			  	}
			  		var dupe="";
			  			$(".fieldSelectionIn .dupe:checked").each(function(){
			  				dupe+="|"+$(this).parents("tr:first").find(".fldInput").attr("name");
			  			});
			  			if(dupe!=""){
			  				dupe=dupe.substring(1);
			  			}
			  			fields=fields.substring(1);
			  			var chooseType='';
			  			$(".fieldSelectionIn .chooseType").each(function(){
			  				chooseType+="|"+$(this).attr("name")+"~"+$(this).val();
			  			});
			  			var json={"tableX1":advancedImporttableX1,"listObj":listRow,"useEmptyLookups":useEmptyLookups,"skipRowsEmptyLookups":skipRowsEmptyLookups,"skipEmptyCells":skipEmptyCells,"skipInvalidNums":skipInvalidNums,"detectDupes":detectDupes,"dupeFields":dupe,"fields":fields,"chooseType":chooseType};
			  			
			  			
			  			 Visualforce.remoting.Manager.invokeAction(
			                remoteCreateRow,
			                JSON.stringify(json), 
			                function(result, event){
			                    if (event.status && result!=null) {
			    					//alert(result+"\n\n"+result.replace(/\&quot\;/ig,"\"").replace(/\&\#39\;/ig,"'").replace(/\\/ig,""));
			    					result=jQuery.parseJSON(result.replace(/\&quot\;/ig,"\"").replace(/\&\#39\;/ig,"'").replace(/\\/ig,"").replace(/\n/ig,"<br/>"));
			    					//alert(result);
			                        //result
			                        
			                        	var val = AdvImportprogbar.progressbar( "value" );
										if(val==null || val==false){
											val=0;
										}
							 			AdvImportprogbar.progressbar( "value", (val + (currRow-lastcurrRow)) );
			                        if(result["status"]!=null && result["status"]=="OK"){

			                        }else{
			                        	//stopAdvImportObj=true;
			                        	$("#importErr").append("Error importing rows ("+lastcurrRow+":"+(currRow-1)+"), "+result["message"]+"<br/>");
			                        }
			                        if(!stopAdvImportObj && currRow<rows.length){
			                        	//currRow++;
			                        	start();
			                        }
			                        if(stopAdvImportObj){
			                        	changeImportBtns();
			                        }
			                    
			                     } else if (event.type === 'exception') {
			                        if(event.message!=null && ((event.message+"").indexOf("Logged in")>-1 || (event.message+"").indexOf("Refresh page")>-1)){
			                            self.location=self.location;
			                        }else if(event.message!=null && (event.message+"").indexOf("Unable to connect")==-1){
			                            if($("body:visible").length>0)alert("An error has occurred: "+event.message);
			                        }
			                    } else {
			                        //self.location=self.location;
			                        // $("#"+filterIdSpan+" .availVals").html("");
			                        //alert(1);
			                    }
			                }, 
			                {escape: true,buffer:true,timeout: 90000}
			            );
			  		
			  	
			  	
		  }	
		  			
		
  }
  
  /* advanced import end*/
  
  
//showCopyToMasterEM
function AutoMarkNoneEmpty(){
	if(licenseStatus!='Active' && licenseStatus!='ActiveP' &&( getStoredNumPPL("AutoMarkNoneEmpty")>7)){ 
	licenseReqMessage("During the free trial this option is limited to 7 shots in total!"); 
	return; 
	} 
	showCopyToMasterEM=false;
	var markedCB=$("input.lcbXRow:checked"); 
	if(markedCB.length==0){ 
	alert("Please select the rows that you want to merge"); 
	}else{ 
	var CBReverse=$(markedCB.get().reverse()); 
	CBReverse.each(function(){ 
	var p1=$(this).parents("tr:first"); 
	var flds=p1.find("td[fld]"); 
	flds.each(function(){ 
	var fld=$(this); 
	if(!fld.hasClass("copyCellMark")){
		if($.trim(fld.text())!=""){ 
			fld.click(); 
		}else if(fld.find("img[src*='checkbox_checked.gif']").length>0){
			fld.click();
		} 
	}
	}); 
	}); 
	}
	showCopyToMasterEM=true;
}

function combineColValues(field1,obj){
	var fld1=($(obj).val()!=""?"+":"-")+field1+"-"+$(obj).val();
	loadingSH();
	saveConfDupe(fld1);
}

var AutoMarkCustomCopyRL=null;
function AutoMarkCellsForMassMerge(){
	 if(!isSF1P && hasMassMerge=="true" && !isEditMode1){
			$("#massUpdatein .muf1[fld]").each(function(){
				MassMergefieldsToAvilOv[$(this).attr("fld")]=true;
			});
			
			var DupeSettingsLL=DupeSettings.split("!!!");
			if(DupeSettingsLL.length>1){
				var AutoMarkCustomCopyRLX=DupeSettingsLL[1].split(";");
				AutoMarkCustomCopyRL=new Array();
				for(var i=0;i<AutoMarkCustomCopyRLX.length;i++){
					AutoMarkCustomCopyRL[AutoMarkCustomCopyRLX[i]]=1;
				}
				//alert(AutoMarkCustomCopyRLX);
			}
			var DupeSettingsArr1=DupeSettingsLL[0].split("#");
			MassMergefieldsToAvilOvAct=new Array();
			if(DupeSettingsArr1.length>0){//combine
				showCopyToMasterEM=false;
				for(var i=0;i<DupeSettingsArr1.length;i++){
					var fldx=DupeSettingsArr1[i];
					var fldxArr=fldx.split("-");
					if(fldxArr.length!=2 || fldxArr[0]=="")continue;
					MassMergefieldsToAvilOvAct[fldxArr[0]]=fldxArr[1];
					var fldEdit=MassMergefieldsToAvilOv[fldxArr[0]];
					if(fldxArr[1]=="combine"){
						if(fldEdit){
							$("#mainTBX1 .dataRow td."+fldxArr[0]).addClass("copyCellMark");
						}
					}else if(fldxArr[1]=="copyIFEmpty"){

						var fieldsReverse=$($("#mainTBX1 .dataRow td."+fldxArr[0]+"[fld='"+fldxArr[0]+"']").get().reverse()); 
						fieldsReverse.each(function(){ 
							var fld=$(this); 
							if(!fld.hasClass("copyCellMark")){
								if($.trim(fld.text())!=""){ 
									fld.click(); 
								}else if(fld.find("img[src*='checkbox_checked.gif']").length>0){
									fld.click(); 
								} 
							}

						}); 
					}else if(fldxArr[1].indexOf("combineTA~")>-1){
						var arr1=fldxArr[1].split("~");//
						MassMergefieldsToAvilOvAct[arr1[1]]="dest";//mark the destination
						$("#mainTBX1 .dataRow td."+arr1[1]).each(function(){ 
							var fld=$(this); 
							if($.trim(fld.text())!=""){ 
								$(this).addClass("combineTA2");
							}else{
								var tr1=$(this).parents("tr.dataRow:first");
								var gnz=tr1.attr("gnz");
								var firstTR=$("tr.dataRow[gnz='"+gnz+"']:first");//first tr in the group
								if(tr1.attr("rowid")==firstTR.attr("rowid")){
									fld.addClass("combineTA2");
								}
							}
						}); 
						var fieldsReverse=$($("#mainTBX1 .dataRow td."+fldxArr[0]+"[fld='"+fldxArr[0]+"']").get().reverse()); 
						fieldsReverse.each(function(){ 
							var fld=$(this); 
							if($.trim(fld.text())!=""){ 
								var tr1=$(this).parents("tr.dataRow:first");
								var gnz=tr1.attr("gnz");
								var firstTR=$("tr.dataRow[gnz='"+gnz+"']:first");//first tr in the group
								if(tr1.attr("rowid")!=firstTR.attr("rowid")){
									fld.addClass("combineTA1").attr("combineField",arr1[1]);
								}
							}

						}); 
					}
				}
				showCopyToMasterEM=true;
				$("input.lcbXRow,input.lcbXAll").prop("checked",false);
			}
	 }
}



function Merge_Accounts(){

if(licenseStatus!='Active' && licenseStatus!='ActiveP' && getStoredNumPPL("Merge_Accounts")>10){ 
				licenseReqMessage("During the free trial the merge-accounts option is limited to 10 shots in total."); 
				return; 
		} 
		
var checkedIds=""; 
var checkedId1=""; 
var accName="";
var leadCount=0; 
$(".lcbX input:checked").each(function(){ 
checkedId1=$(this).parents(".lcbX:first").attr("rid"); 
accName=$.trim($(this).parents("tr:first").find(".oSt_name").text());
checkedIds+="&cid="+checkedId1; 
leadCount++; 
}); 
if(leadCount>3){ 
alert("Please select up to 3 Accounts to merge!"); 
}else if(leadCount<2){ 
alert("Please select at least 2 Accounts to merge!"); 
}else{ 
var win1=window.open("/merge/accmergewizard.jsp?currentStage=0&goNext=Next&buttonPressed=0&currentStage=0&srchbutton=Find Accounts"+checkedIds+"&retURL=%2Fapex%2Fzaapit__Merge_Completed&isdtp=p1&srch="+encodeURIComponent(accName),"Merge_Leads","height=800,width=800,top=100,left=100,fullscreen=0,scrollbars=yes");

var timer = setInterval(function() { 
if(win1.closed) { 
clearInterval(timer); 
//$(".seatchInptFZP").keyup(); 
jumpToClk(currPageCls,600);
} 
}, 1000); 
} 
return false;

}

function Auto_Mark(){
	if(licenseStatus!='Active' && licenseStatus!='ActiveP'){ 
alert("This is a premium feature – contact sales@zaapit.com to activate!"); 
return; 
} 
var ix=1;$(".list .dataRow").each(function(){ 
if(!$(this).hasClass("tcx"+ix)){ 
ix=1-ix; 
}else{ 
$(this).find(".lcbXRow").click(); 
} 
});
}


function add_to_campignContact(){
openMassCreate('AddCntToCmapign','ContactId','Add Contacts to Campaign','1',null,null,null,null,1);

}
function add_to_campignLead(){
openMassCreate('AddCntToCmapignLeads','LeadId','Add Leads to Campaign','1',null,null,null,null,1);
}



function send_mass_emails_outlook(){
var emails="";
var emailSearch=0;
$(".lcbX input:checked").each(function(){
  emailSearch=1;
  var email=$.trim($(this).parents("tr:first").find("td.email").text());
  if(email!=""){
    emails+=";"+email;
  }
});

if(emails=="" && emailSearch==0){
 alert("Please select at least one row"); 
}else if(emails=="" && emailSearch==1){
 alert("Please add the email-column to the layout"); 

}else{
emails=emails.substring(1);
top.location="mailto:"+escape(emails);
$("button:contains('Create Tasks')").click();
}
return false;
}

function merge_contact1(){

if(licenseStatus!='Active' && licenseStatus!='ActiveP' && getStoredNumPPL("merge_contact1")>10){ 
				licenseReqMessage("During the free trial the merge-contacts option is limited to 10 shots in total."); 
				return; 
		} 
var checkedIds="";
var checkedId1="";
var contOrg="";
var acc1="";
var contactCount=0;
$(".lcbX input:checked").each(function(){
checkedId1=$(this).parents(".lcbX:first").attr("rid");
contOrg=contOrg+",.RID"+checkedId1;
if(checkedId1!=null && checkedId1.length>15){
  checkedId1=checkedId1.substring(0,15);
}
checkedIds+="&cid="+checkedId1;
contactCount++;
});
if(contactCount>3){
alert("Please select up to 3 Contacts to merge!");
}else if(contactCount<2){
alert("Please select at least 2 Contacts to merge!");
}else{
var href1= ""; 
$(contOrg.substring(1)).each(function(){
  var fndA=$(this).parents("tr:first").find(".oSt_accountid").find("a[id*='lookup']:first");
  if(fndA.length>0){
    try{
       //alert(fndA.attr("id"));
       href1 = (fndA.attr("id")+"").substring(6,21);
    }catch(e1){}
  }
});
//alert(href1 + " "+contOrg);
if(href1!=null && href1!=""){
acc1=href1;
//acc1=(href1!=null && href1!="undefined"?href1.split(".com/")[1]:""); //href1.split(".com/")[1];
var win1=window.open("/merge/conmergewizard.jsp?buttonPressed=0"+checkedIds+"&currentStage=0&goNext=Next&id="+acc1+"&retURL=%2Fapex%2Fzaapit__Merge_Completed&srch=&visited_0=1&isdtp=p1" ,"Merge_Contacts","height=800,width=800,top=100,left=100,fullscreen=0,scrollbars=yes");
win1.focus();

var timer = setInterval(function() {
if(win1.closed) {
clearInterval(timer);
//$(".seatchInptFZP").keyup();
jumpToClk(currPageCls,600);

}
}, 1000);
}else{/*account not found*/
  alert("Please assign one of the selected contacts to an account before merging the contacts!");

}
}
return false;
}

function convertlead1(){

if(licenseStatus!='Active' && licenseStatus!='ActiveP' && getStoredNumPPL("convertlead1")>10){ 
				licenseReqMessage("During the free trial the convert-leads option is limited to 10 shots in total."); 
				return; 
		} 
var checkedIds=""; 
var checkedId1=""; 
var contOrg=""; 
var acc1=""; 
var contactCount=0; 
$(".lcbX input:checked").each(function(){ 
checkedId1=$(this).parents(".lcbX:first").attr("rid"); 
contOrg=contOrg+",.RID"+checkedId1; 
if(checkedId1!=null && checkedId1.length>15){ 
checkedId1=checkedId1.substring(0,15); 
} 
checkedIds+="&id="+checkedId1; 
contactCount++; 
}); 
if(contactCount>1 || contactCount<1){ 
alert("Please select exactly 1 lead to convert!"); 
}else{ 

var win1=window.open("/lead/leadconvert.jsp?retURL=%2Fapex%2Fzaapit__Convert_Completed&isdtp=p1"+checkedIds ,"Merge_Contacts","height=800,width=800,top=100,left=100,fullscreen=0,scrollbars=yes"); 
win1.focus(); 

var timer = setInterval(function() { 
if(win1.closed) { 
clearInterval(timer); 
//$(".seatchInptFZP").keyup(); 
jumpToClk(currPageCls,600); 
} 
}, 1000); 

} 

}


function mergeLeads1(){

		if(licenseStatus!='Active' && licenseStatus!='ActiveP' && getStoredNumPPL("mergeLeads1")>10){ 
				licenseReqMessage("During the free trial the merge-leads option is limited to 10 shots in total."); 
				return; 
		} 
var checkedIds=""; 
var checkedId1=""; 
var leadCount=0;
$(".lcbX input:checked").each(function(){ 
checkedId1=$(this).parents(".lcbX:first").attr("rid");
checkedIds+="&cid="+checkedId1; 
leadCount++;
});
if(leadCount>3){ 
alert("Please select up to 3 leads to merge!"); 
}else if(leadCount<2){ 
alert("Please select at least 2 leads to merge!"); 
}else{ 
var win1=window.open("/lead/leadmergewizard.jsp?currentStage=0&goNext=Merge%20Leads&id="+checkedId1+"&p1=1&p3=1&p4=1&p6=1&p7=&p8=&visited_0=1"+checkedIds+"&retURL=%2Fapex%2Fzaapit__Merge_Completed&isdtp=p1","Merge_Leads","height=800,width=800,top=100,left=100,fullscreen=0,scrollbars=yes");

var timer = setInterval(function() {   
    if(win1.closed) {  
        clearInterval(timer);  
        //$(".seatchInptFZP").keyup(); 
        jumpToClk(currPageCls,600);
    }  
}, 1000); 
} 
return false;
}

function openMassUpdateGearMenu(obj,fieldName){
	var FieldType='name';
	if(fieldName.indexOf('phone')>-1){
		FieldType='phone';
	}else if(fieldName.indexOf('state')>-1 ||  fieldName.indexOf('province')>-1){
		FieldType='state';
	}else if(fieldName.indexOf('country')>-1){
		FieldType='country';
	}else if(fieldName.indexOf('postalcode')>-1){
		FieldType='zipcode';
	}else if(fieldName.indexOf('zipcode')>-1){
		FieldType='zipcode';
	}else if(fieldName.indexOf('email')>-1){
		FieldType='email';
	}
	//$(".MassUpdateGearMenu").remove();
	var menu="<div class='MassUpdateGearMenu' style='border: 0px;color:#aaaaaa;'> Apply a Text Format:"+
(FieldType=="name" || FieldType=="email"?"<div><button type='button' onclick='chooseMUFormat(\""+fieldName+"\",this)' class='btn btnMore'>Lowercase</button></div>":"")+
    (FieldType=="name" || FieldType=="email"?"<div><button type='button' onclick='chooseMUFormat(\""+fieldName+"\",this)' class='btn btnMore'>Uppercase</button></div>":"")+
    (FieldType=="name"?"<div><button type='button' onclick='chooseMUFormat(\""+fieldName+"\",this)' class='btn btnMore'>Propercase Name: Init Cap</button></div>":"")+
    (FieldType=="name"?"<div><button type='button' onclick='chooseMUFormat(\""+fieldName+"\",this)' class='btn btnMore'>Propercase Names Init Caps</button></div>":"")+
    (FieldType=="country"?"<div><button type='button' onclick='chooseMUFormat(\""+fieldName+"\",this)' class='btn btnMore'>Country 2 Chars</button></div>":"")+
    (FieldType=="country"?"<div><button type='button' onclick='chooseMUFormat(\""+fieldName+"\",this)' class='btn btnMore'>Country 3 Chars</button></div>":"")+
    (FieldType=="country"?"<div><button type='button' onclick='chooseMUFormat(\""+fieldName+"\",this)' class='btn btnMore' title='English'>Country Long Names (En)</button></div>":"")+
    (FieldType=="state"?"<div><button type='button' onclick='chooseMUFormat(\""+fieldName+"\",this)' class='btn btnMore'>States 2 Chars (US/CA)</button></div>":"")+
    (FieldType=="state"?"<div><button type='button' onclick='chooseMUFormat(\""+fieldName+"\",this)' class='btn btnMore'>States Long Names (US/CA)</button></div>":"")+
    (FieldType=="zipcode"?"<div><button type='button' onclick='chooseMUFormat(\""+fieldName+"\",this)' class='btn btnMore'>Zip Code Clean (keep 0-9)</button></div>":"")+
    (FieldType=="zipcode"?"<div><button type='button' onclick='chooseMUFormat(\""+fieldName+"\",this)' class='btn btnMore'>Zip Code Clean (keep 0-9,a-z)</button></div>":"")+
    (FieldType=="phone"?"<div><button type='button' onclick='chooseMUFormat(\""+fieldName+"\",this)' class='btn btnMore' title='Format: (000) 000-0000 x0000'>US phone format</button></div>":"")+
    "</div>";
	$(obj).attr("title","<div class='gearMenu1'>"+menu+"</div>");
	$(obj).removeAttr("onclick");
	fixTitlex2(obj,false,'B',null,1);
}
function chooseMUFormat(fieldName,obj){
	var valA=$(obj).text().replace(/[^a-z0-9]/ig,"_").toUpperCase().split("_");
	var val=valA[0];
	if(valA.length>1){
		val+="_"+valA[1];
	}
	$("#massUpdatein .muf1."+fieldName+" input.iTb:visible").val("!!"+val).click();
}

var plotOnMapSets={};
function plotOnMap(latField,longField, add1F, add2F, add3F, add4F, add5F,calcGeo){
	plotOnMapSets={};
	if(calcGeo==null) calcGeo=true;
	var checkedIds="";
	var checkNum=0;
	$(".lcbX input:checked").each(function(){
	 checkedIds+=",'"+$(this).parents(".lcbX:first").attr("rid")+"'";
	 checkNum++;
	});
	
	openGenWindow1('about:blank','Map - '+(checkedIds==''?'All':''+checkNum+' Selected '),'75%',null,null,null,null,"mapWinPOPUP");
	var maxResRows=50000;

	var query1="SELECT Id,"+latField+","+longField+","+add1F+","+add2F+","+add3F+","+add4F+","+add5F+" "+DBsubQery+(DBsubQery.indexOf(" where ")>-1?" and ":" where " )+" "+(calcGeo?"id":latField)+"!=null "+(checkedIds!=""?" and id in ("+checkedIds.substring(1)+")":"") +"  order by id limit "+maxResRows+DB_END_ALLROWS_Qery;
	//console.log(query1);
	    Visualforce.remoting.Manager.invokeAction(
                remoteQueryAjax2,
                query1, 
                function(result, event){
                    if (event.status && result!=null) {
                    	var records = result;

                         if(records.length>0){
                         
                         	plotOnMapSets.records=records;
                         	plotOnMapSets.latField=latField;
                         	plotOnMapSets.longField=longField;
                         	plotOnMapSets.add1F=add1F;
                         	plotOnMapSets.add2F=add2F;
                         	plotOnMapSets.add3F=add3F;
                         	plotOnMapSets.add4F=add4F
                         	plotOnMapSets.add5F=add5F;
                         	plotOnMapSets.objectName=tableX1Z;
                         	openGenWindow1('/apex/zaapit__zaapit_maps1','Map - '+(checkedIds==''?'All':''+checkNum+' Selected '),'75%',null,null,null,null,"mapWinPOPUP");
                         	
                         }
                      } else if (event.type === 'exception') {
                        if(event.message!=null && ((event.message+"").indexOf("Logged in")>-1 || (event.message+"").indexOf("Refresh page")>-1)){
                            self.location=self.location;
                        }else if(event.message!=null && (event.message+"").indexOf("Unable to connect")==-1){
                            if($("body:visible").length>0)alert("An error has occurred: "+event.message);
                        }
                    } else {
                        //self.location=self.location;
                        // $("#"+filterIdSpan+" .availVals").html("");
                        //alert(1);
                    }
                }, 
                {escape: true,buffer:true,timeout: 90000}
            );
              
}

function plotAddressMap(addressPrefix,calcGeo){//"Billing"
	plotOnMap(addressPrefix+"Latitude",addressPrefix+"Longitude", "Name", addressPrefix+"Street", addressPrefix+"State", addressPrefix+"Postalcode", addressPrefix+"Country",calcGeo);
}
function plotAddressMapTaskEvents(addressPrefix,calcGeo){//"Billing"
	plotOnMap(addressPrefix+"Latitude",addressPrefix+"Longitude", "Subject", addressPrefix+"Street", addressPrefix+"State", addressPrefix+"Postalcode", addressPrefix+"Country",calcGeo);
}

function OpenFilterWizardDedupManager(mainTb,jsObj){
	var conditionpoup='<div id="multiSelFldsWRp2" title="Choose a Field"></div> <div id="multiSelFldsWRp3" class="hd1" title="Add a Condition"> <div style="padding:5px;display:block;border:1px solid #eeeeee;margin-bottom:10px;"> 1) Select a Field: </div><div id="multiSelFldsWRp3in" /> <div style="padding:5px;display:block;border:1px solid #eeeeee;margin-bottom:10px;margin-top:10px;"> <span> 2) Add Condition: </span> <select name="RLRFAndOr1" id="RLRFAndOr1"> <option value=" ">-</option><option value="AND">AND</option><option value="OR">OR</option> </select><input tyle="text" value="Select a Field" id="RLRF" class="RLRF" style="" onclick="initFieldPicker(this);"/><select name="RLRFOp1" id="RLRFOp1" onchange="RLRFOp1Change();" style="width: 171px;"><optgroup label="Texts" typeValid="text"><option value="{0}=\'{1}\'">equals</option><option value="{0}!=\'{1}\'">not equal to</option><option value="{0} like \'{1}%\'">starts with</option><option value="{0} like \'%{1}%\'">contains</option><option value="(not {0} like \'%{1}%\')">does not contain</option><option value="{0} &lt; \'{1}\'">less than</option><option value="{0} &gt; \'{1}\'">greater than</option><option value="{0} &lt;= \'{1}\'">less or equal</option><option value="{0} &gt;= \'{1}\'">greater or equal</option><option value="{0} in (\'{1}\')">includes</option><option value="(not {0} in (\'{1}\'))">excludes</option></optgroup><optgroup label="Numbers" typeValid="number"><option value="{0}={1}">equals</option><option value="{0}!={1}">not equal to</option><option value="{0} &lt; {1}">less than</option><option value="{0} &gt; {1}">greater than</option><option value="{0} &lt;= {1}">less or equal</option><option value="{0} &gt;= {1}">greater or equal</option><option value="{0} in ({1})">includes</option><option value="(not {0} in ({1}))">excludes</option></optgroup><optgroup label="Dates" typeValid="date"><option value="{0}={1}">equals</option><option value="{0}!={1}">not equal to</option><option value="{0} &lt; {1}">less than</option><option value="{0} &gt; {1}">greater than</option><option value="{0} &lt;= {1}">less or equal</option><option value="{0} &gt;= {1}">greater or equal</option><option value="{0} = TODAY">equals today</option><option value="{0} = LAST_N_DAYS:{1}">equals last n days</option><option value="{0} = NEXT_N_DAYS:{1}">equals next n days</option><option value="{0} = LAST_N_QUARTERS:{1}">equals last n quarters</option><option value="{0} = NEXT_N_QUARTERS:{1}">equals next n quarters</option><option value="{0} = LAST_N_YEARS:{1}">equals last n years</option><option value="{0} = NEXT_N_YEARS:{1}">equals next n years</option></optgroup><optgroup label="Multi Picklists" typeValid="multiPL"><option value="{0} includes (\'{1}\')">includes</option><option value="{0} excludes (\'{1}\')">excludes</option><option value="{0}=\'{1}\'">equals</option><option value="{0}!=\'{1}\'">not equal to</option></optgroup><optgroup label="Check Boxes" typeValid="checkbox"><option value="{0}={1}">equals</option><option value="{0}!={1}">not equal to</option></optgroup></select><input type="text" name="condvalue" id="condvalue" value="" style="width:138px;" autocomplete="off"/><button id="mainPAdvanceFilter" disabled="disabled" onclick="appendToFieldVal(\'RLRF\',\'RLRF-TA\');" type="button" class="btnDisabled" style="font-size:13pt;line-height: 13px;vertical-align: -2px;">+</button></div><div style="padding:5px;display:block;border:1px solid #eeeeee;margin-bottom:10px;"> 3) Edit Condition: </div><textarea id="RLRF-TA" class="RLRF-TA"/> <div style="" id="ValidIssue"></div></div>';
	if($("#multiSelFldsWRp2").length==0){
		$("body").append(conditionpoup);
	}
	conditionPickX_tableName=mainTb;
	//conditionPickX($(MassMergeAllSOQLFilter)[0]);
		selectSoqlFieldCon($(MassMergeAllSOQLFilter)[0]);
	//conditionPickX.selectSoqlField();
}



//*********************  conditionPickX  *******************
var conditionPickX_tableName="";
 
  var dbclickblocker=0;
         var RLRFOp1FType="";

         var lastSelectSoqlFieldConObj2=null;
        function selectSoqlFieldSel1(ColumnNameA,ColumnAPIA,FieldLinkA,FieldAJAXA,FieldReq,FieldDefaultVal,ftype){  
           
            //alert(ColumnAPIA+ " "+$(".RLRF").length);
            $(".RLRF").val(ColumnAPIA).change();
            lastSelectSoqlFieldConObj2=$(".RLRF")[0];
             $(lastSelectSoqlFieldConObj2).addClass("marked");
              setTimeout(function(){$(lastSelectSoqlFieldConObj2).removeClass("marked")},2500);
            $("#multiSelFldsWRp2").dialog("close");
            closeMultiSelRel();
            
        }
        function RLRFOp1Change(){
            $("#condvalue").val('');
            var selRLRFOp1=$("#RLRFOp1")[0];
            var selOption=selRLRFOp1.options[selRLRFOp1.selectedIndex];
            var typeValid=$(selOption.parentNode).attr("typeValid");//optgroup
            if(typeValid!=null && typeValid!=""){
                if($("#condvalue").attr("t1")=="checkbox"){
                    $("#condvalue").attr("t1","");
                    $("#condvalue").autocomplete("destroy").attr("onclick","");
                }else if($("#condvalue").attr("t1")=="date"){
                    $("#condvalue").attr("t1","");
                    $("#condvalue").datepicker( "destroy" );
                }
                
                if(typeValid=="date" && $("#RLRFOp1").val().indexOf(":{1}")==-1){
                    $("#condvalue").datepicker({"dateFormat":"yy-mm-dd"+(RLRFOp1FType=="DATETIME"?"'T00:00:00Z'":"")});
                    $("#condvalue").attr("t1","date");
                }else  if(typeValid=="checkbox"){
                    $("#condvalue").attr("t1","checkbox");
                    $("#condvalue").autocomplete({
                    source: ["TRUE","FALSE"],minLength: 0
                    }).attr("onclick",'$(this).autocomplete( "search", "" )');
                }
            }
        }
        var RLRFOp1FType="";
        function selectSoqlFieldSel2(ColumnNameA,ColumnAPIA,FieldLinkA,FieldAJAXA,FieldReq,FieldDefaultVal,ftype){  
           
           $("#RLRF").val(ColumnAPIA).addClass("marked");
           setTimeout(function(){$("#RLRF").removeClass("marked")},2500);
            RLRFOp1FType=ftype;
            var optgroups=$("#RLRFOp1").data("optgroup");
            if(optgroups==null){
                optgroups=$("#RLRFOp1").clone();
                $("#RLRFOp1").data("optgroup",optgroups);
                //alert(optgroups.find("[typeValid='multiPL']").length);
            }
            //optgroups=$(optgroups);
            $("#RLRFOp1 optgroup").remove();
            //alert(RLRFOp1FType);
            if(RLRFOp1FType.indexOf("DATE")>-1){
                $("#RLRFOp1").append( optgroups.find("[typeValid='date']").clone());    
            }else if(RLRFOp1FType=="NUMBER" || RLRFOp1FType=="DOUBLE" || RLRFOp1FType=="CURRENCY"){
                $("#RLRFOp1").append( optgroups.find("[typeValid='number']").clone());  
            }else if(RLRFOp1FType=="MULTIPICKLIST"){
                $("#RLRFOp1").append( optgroups.find("[typeValid='multiPL']").clone());
            }else if(RLRFOp1FType=="BOOLEAN"){
                $("#RLRFOp1").append( optgroups.find("[typeValid='checkbox']").clone());    
            }else{
                $("#RLRFOp1").append( optgroups.find("[typeValid='text']").clone());
            }
            //$("#multiSelFldsWRp2").dialog("close");
            //closeMultiSelRel();
            RLRFOp1Change();
            $("#mainPAdvanceFilter").removeAttr("disabled").removeClass("btnDisabled").addClass("btn");
            
            //alert(ColumnAPIA+ " "+$(".RLRF").length);
           // $(".RLRF").val(ColumnAPIA).change();
            
            //$("#multiSelFldsWRp3").dialog("close");
            //closeMultiSelRel();
            
        }
        
        var lastSelectSoqlFieldConObj=null;
        
        function selectSoqlFieldCon(obj){
           $("#RLRF").addClass("RLRF");
        lastSelectSoqlFieldConObj=obj;
        var x1=dbclickblocker;
        dbclickblocker++;
         if(x1>0) return;
             $("#ValidIssue").hide().html("");
             $("#RLRF-TA").val($(obj).val());
            $("#mainPAdvanceFilter").attr("disabled","disabled").removeClass("btn").addClass("btnDisabled");
            $("#RLRF").val("");
            //$(obj).addClass("RLRF");
            //$("#mainPAdvanceFilter").attr("disabled","disabled").removeClass("btn").addClass("btnDisabled");
            //$(".RLRF").val("");
            $("#multiSelFldsWRp3").dialog({position: { my: "center", at: "top" },minHeight: 200,width:Math.min(800,$(self).width()-10),modal: true,buttons:{"Validate & Add Condition":function(){
                validateSOQL1();

            },"Cancel":function(){
                $("#multiSelFldsWRp3").dialog("close");
            }}
            ,close:function(){ closeMultiSelRel(); }});
            useMultiSelRel("multiSelFldsWRp3in",selectSoqlFieldSel2);
            getRLfields(conditionPickX_tableName,0);
                
        }
        function initFieldPicker(obj){
            //$("#multiSelFlds").remove();
            //$("#"+wraperid).html('<div id="multiSelFlds" class="hd1" ><div class="loadingx1"></div></div>');
            $(obj).val("");
            getRLfields(conditionPickX_tableName,0);
        }
        
        function selectSoqlField(obj){
        var x1=dbclickblocker;
        dbclickblocker++;
         if(x1>0) return;

            $(obj).addClass("RLRF");
            //$("#mainPAdvanceFilter").attr("disabled","disabled").removeClass("btn").addClass("btnDisabled");
            $(".RLRF").val("");
            $("#multiSelFldsWRp2").dialog({minHeight: 200,width:Math.min(800,$(self).width()-10),modal: true,close:function(){ $(".RLRF").removeClass("RLRF"); closeMultiSelRel();}});
            useMultiSelRel("multiSelFldsWRp2",selectSoqlFieldSel1);
            getRLfields(conditionPickX_tableName,0);
                
        }
        
        var useMultiSelRelFunctionName=null;
        function useMultiSelRel(wraperid,func1){ 
            $("#multiSelFlds").remove();
            useMultiSelRelFunctionName=func1;
            $("#"+wraperid).html('<div id="multiSelFlds" class="hd1" ><div class="loadingx1"></div></div>');
        }
        
        
        
        function getRLfields(table1,idsM,scroll1,addSubChilds){
            if(idsM==0){
                $("#multiSelFlds .fldsSel,#multiSelFlds .Youhaveselected").remove();
            }
            $("#multiSelFlds").removeClass("hd1");
            if(scroll1!=null)$(self).scrollTop($("#multiSelFlds").position().top-250);
            
           
//            alert(1);
           $("#multiSelFlds .loadingx1").show();
         Visualforce.remoting.Manager.invokeAction(
                        remotequeryAjax2GetTbFields,
                        table1, 
                        function(result, event){
                            if (event.status && result!=null) {
                             dbclickblocker=0;
                                $("#multiSelFlds .loadingx1").hide();
                                var sel1="<select size=\"9\" class=\"fldsSel\" c=\""+(idsM+1)+"\" onclick=\"selectRefFeilds(this,"+(idsM+1)+");\" >";
                                var isFirstChild=true;
                                for(var i=0;i<result.length;i++){
                                    //alert(result[i].label+" "+result[i].name+ " "+result[i].relationshipName);
                                    if(result[i].name!=null && result[i].childRel==0 ){
                                        var isChilds=false;
                                        
                                        if(result[i].type!='CHILDS'){ 
                                            sel1+="<option cr=\""+result[i].childRel+"\" value=\""+result[i].name+"\" ref=\""+result[i].referenceTo+"\" rn=\""+result[i].relationshipName+"\" tp=\""+result[i].type+"\" isref=\"0\">"+result[i].label+"</option>";  
                                        }else{
                                            isChilds=true;
                                            if(isFirstChild){
                                                isFirstChild=false;
                                                if(addSubChilds==null){
                                                    sel1+="<optgroup label=\" --- Child Relationships ---\"></optgroup>";
                                                }
                                            }
                                        }
                                        if((!isChilds ||addSubChilds==null)&&result[i].referenceTo!=null && result[i].referenceTo.indexOf("ActivityHistory")==-1 && result[i].referenceTo.indexOf("OpenActivity")==-1){
                                            sel1+="<option value=\""+result[i].referenceTo+"\" ref=\""+result[i].referenceTo+"\" rn=\""+result[i].relationshipName+"\" isref=\"1\">"+result[i].referenceTo+" ("+result[i].label+") &gt;</option>";
                                        }
                                    }
                                }
                                 sel1+="</select>";
                                 if($(".Youhaveselected").length==0){
                                    	$("#multiSelFlds").append(sel1);
                                    	$("#multiSelFlds").scrollLeft($("#multiSelFlds").width());
                                }
                                //loadingSH();
                             } else if (event.type === 'exception') {
                                if(event.message.indexOf("Logged in?")>-1){
                                    top.location=top.location;
                                }else{
                                    alert(event.message);
                                }
                            } else {
                                alert(event.message);
                            }
                        }, 
                        {escape: true,buffer:true,timeout: 90000}
                    );
        }
        
        function selectRefFeilds(obj,idsM){
        var selObj=obj.options[obj.selectedIndex];
        var ref=$(selObj).attr("ref");
        var value=$(selObj).attr("value");
        var rn=$(selObj).attr("rn");
        var isref=$(selObj).attr("isref");
        //alert(ref+" "+isref);
        $(".fldsSel").each(function(){
                if(Number($(this).attr("c"))>Number(idsM)){
                    $(this).remove();
                }
            });
            $(".Youhaveselected").remove();
        if(isref=="1"){ 
            getRLfields($(obj).val(),idsM,null,"noChilds");
        }else{
            var xxx=insertFldWzrdAppend();
            var youSel="<div c='"+(idsM+1)+"' class='Youhaveselected'><div class='i'>You have selected:<br><div class='l'> "+xxx[0]+"</div><div class='g'>Type: "+xxx[1]+"</div><div class='g'>API Name: "+xxx[2]+"</div><input type='button' class='btn' value='Insert' onclick='insertFldWzrdAppend(1);'></div></div>";
            $("#multiSelFlds").append(youSel);
            $(".Youhaveselected").height($(".fldsSel:first").height()+2);
            $("#multiSelFlds").scrollLeft($("#multiSelFlds").width());
            
        }
    }
    
    function insertFldWzrdAppend(x){
        var selFld="";
            var selFldN="";
            var selFldTp="";
            var size1=$(".fldsSel").length;
            
            $(".fldsSel").each(function(index){
                var rn1=$(this.options[this.selectedIndex]).attr("rn");
                var tp1=$(this.options[this.selectedIndex]).attr("tp");
                if(rn1== null || rn1=='' || index ==size1-1){//last sel1
                    rn1=$(this).val();
                    selFldTp=tp1;
                }
                selFld+="."+rn1;
                selFldN=$(this.options[this.selectedIndex]).text();
            });
            if(selFld!=""){
                selFld=selFld.substring(1);
                
                //$("#ColumnNameA").val(selFldN);
                //$("#ColumnAPIA").val(selFld);
                //alert(selFldTp);
                if(x!=null && x==1)useMultiSelRelFunctionName(selFldN,selFld,'','','','',selFldTp);
            }
            return [selFldN,selFldTp,selFld];
    }
    
              
        function closeMultiSelRel(){
            $("#multiSelFlds").remove();
        } 
        
        
        
        function appendToFieldVal(obj,o2){
            var tmp=$("."+o2).val();
            var RLRFAndOr1=$("#RLRFAndOr1").val();
            if($.trim(RLRFAndOr1)==""){
                RLRFAndOr1="AND";
            }
            var RLRFOp1=$("#RLRFOp1").val();
            RLRFOp1=RLRFOp1.replace("&lt;","<").replace("&gt;",">");
            var objVal=$("#"+obj).val();//field name
            var val1=$("#condvalue").val();//value
            //alert(val1+" "+RLRFOp1);
            if(val1.indexOf("{")>-1 && RLRFOp1.indexOf("'{")>-1 ){
                RLRFOp1=RLRFOp1.replace(/\'/ig,"");
            }
            var objValX=objVal.split("__xx.");
            if(objValX.length==3){
                objVal=objValX[2];
                RLRFOp1="id  in (select "+objValX[1]+" from "+objValX[0]+" where "+RLRFOp1+") ";
            }
            var out1=RLRFOp1.replace("{0}",objVal);
            
        
            if(RLRFOp1.indexOf("'")==-1 && $.trim(val1)==""){//empty not str
                val1="null";
            } 
            out1=out1.replace("{1}",val1);
            if(RLRFOp1.indexOf("('{1}')")>-1){
                out1=out1.replace(/\,/ig,"','");
            }
            $("."+o2).val(($.trim(tmp)==""?"":tmp+" "+RLRFAndOr1+" ")+out1);
        } 
        
          
        
        function validateSOQL1(){
            if($('#RLRF-TA').val()==""){
            $("#multiSelFldsWRp3").dialog("close");
            }else{
         var query1="SELECT id FROM "+conditionPickX_tableName+" where "+$('#RLRF-TA').val()+" limit 1";
         //alert(query1);
         Visualforce.remoting.Manager.invokeAction(
                        remoteQueryAjax2SC,
                        query1, 
                        function(result, event){
                            if (event.status && result!=null) {
                                
                                 $(lastSelectSoqlFieldConObj).val($('#RLRF-TA').val()).change();;//alert($('#RLRF-TA').val());
                                 $(lastSelectSoqlFieldConObj).addClass("marked");
                                   setTimeout(function(){$(lastSelectSoqlFieldConObj).removeClass("marked")},2500);
                                $("#multiSelFldsWRp3").dialog("close");
                
                             } else if (event.type === 'exception') {
                                $("#ValidIssue").html("Validation failed - please revise your condition.<br/><br/> SOQL issue: "+event.message).show();
                            } else {
                                 $("#ValidIssue").html("Validation failed - please revise your condition.<br/><br/> SOQL issue: "+event.message).show();
                            }
                        }, 
                        {escape: true,buffer:true,timeout: 90000}
                    );
        }
        }

    
    /*search gen DP*/
    
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
                        
                        //$(".searchSelMainOut").remove();
                        var searchSel=$("#"+objID+".searchSelMainOut");
                        //if(searchSel.size()==0 &&  $(".searchSelMainOut").size()>0){
                        //    $(".searchSelMainOut").remove();
                        //}
                        
                        
                        if($(".searchSelMainOut:visible").size()>=1){
                            $(".searchSelMainOut:visible").each(function(){
                            	if($(this).attr("id")!=objID) $(this).hide();
                            });
                        }
                        	
                            /*$(".searchSelMainOut").remove();*/
                            
                            if($("#"+objID+".searchSelMainOut").size()==0){
                                $("body").append("<span class='searchSelMainOut "+type+"' id='"+objID+"'><input type='search' placeholder='"+Search_label+"' class='searchSelMainIn' value='' onkeyup='searchSelX3(this);' onsearch='searchSelX3(this);' onmouseup='searchSelX3(this);' onkeydown='searchSelUPDWX3(event);'/><div class='searchSelMainOpts'/></span>");
                                var ObjPos=$(obj).offset();
                                $("#"+objID+".searchSelMainOut").css({"position":"absolute","top":(ObjPos.top+$(obj).height()+3)+"px","left":ObjPos.left+"px","z-index":1005,"width":(Math.max($(obj).width()+20,215))+"px"});
                                
                                 var html11=$(obj).html();
		                        var selectedIndex=obj.selectedIndex+1;
		                        /*alert(html11);*/
		                        html11=html11.replace(/\<option/ig,"<div class='opt' ");
		                        html11=html11.replace(/\/option\>/ig,"/div>");
		                        /*alert(selectedIndex);*/
		                        $("#"+objID+" .searchSelMainOpts").html(html11);
		                        $("#"+objID+".searchSelMainOut .searchSelMainOpts .opt:nth-child("+selectedIndex+")").addClass("sel");
		                       
		                        
		                        $("#"+objID+".searchSelMainOut .searchSelMainOpts .opt").click(function(){
		                            $("#"+objID+".searchSelMainOut .opt.sel").removeClass("sel");
		                            $(this).addClass("sel");
		                            $(searchSelMainObj).val($(this).attr("value"));
		                            $("#"+objID+".searchSelMainOut:visible").hide();
		                            $(searchSelMainObj).change();
		                        });
                        
                            }else{
                            	if(searchSel.is(":visible")){
                               		searchSel.hide();
                               	}else{
                               		searchSel.show();
                               		var ObjPos=$(obj).offset();
                               		searchSel.css({"position":"absolute","top":(ObjPos.top+$(obj).height()+3)+"px","left":ObjPos.left+"px","z-index":1005,"width":(Math.max($(obj).width()+20,215))+"px"});
                                
                               	}
                            }
                        $("#"+objID+" .searchSelMainIn:visible").focus();
                        searchSelX3($("#"+objID+" .searchSelMainIn")[0]);
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
                    $(obj).parents(".searchSelMainOut:first").find(".searchSelMainOpts .opt").each(function(){
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
                    
                    
                    
                    
                    
/**************************/
/*   Records all fetcher  */
/****************************/
var RecordsAllProgTextsArr=null;
var openAllRecordsAllLastID='';
var progressbarRecordsAll = null;
var progressLabelRecordsAll = null;
var stopRecordsAll=false;
var stopRecordsAllError=false; 
var runFunctionOnIdsRecordsAll1=null;
var isSelectedRowsModesRecordsAll1=false;
var runFunctionOnIdsMaxRowsAll1=200;//200
var totalCountAjxRecordsAll=0;
var runFunctionRecordsAllOnDone=null;
var RecordsAllmaxID='';
var RecordsAllQuery='';
//var RecordsAllProgTexts="Starting...#Stop#Stopping...#Current Progress: #Complete!#Close#Are you sure you want to fetch all the rows#Fetch All Rows (title)";

function openAllRecords(RecordsAllProgTexts,runFunctionOnIdsRecordsAll,runFunctionOnIdsMaxRowsAll,isSelectedRowsMode,maxID,RecordsAllQuery1,runFunctionRecordsAllOnDone1){
	RecordsAllQuery=RecordsAllQuery1;
	runFunctionRecordsAllOnDone=runFunctionRecordsAllOnDone1;
	totalCountAjxRecordsAll=totalCountAjx;
	if(isSelectedRowsMode==null){
		isSelectedRowsMode=false;
	} 
	isSelectedRowsModesRecordsAll1=(isSelectedRowsMode==true);
	//alert("isSelectedRowsModesRecordsAll1: "+isSelectedRowsModesRecordsAll1);
	if(isSelectedRowsModesRecordsAll1){
		totalCountAjxRecordsAll=$(".lcbX input:checked").length;
	}
	RecordsAllmaxID=(maxID!=null && maxID!=""?maxID:RecordsAllmaxID);
	
	runFunctionOnIdsRecordsAll1=runFunctionOnIdsRecordsAll;
	if(runFunctionOnIdsMaxRowsAll==null){
		runFunctionOnIdsMaxRowsAll1=massActionsDefBatchSize;
	} else{
		runFunctionOnIdsMaxRowsAll1=runFunctionOnIdsMaxRowsAll;
	}
	RecordsAllProgTextsArr=RecordsAllProgTexts.split("#");
	if(!isSelectedRowsModesRecordsAll1 && !confirm(RecordsAllProgTextsArr[6].replace("{0}",totalCountAjxRecordsAll))){//
		return false;
	}
	progressbarRecordsAll=null;
	progressLabelRecordsAll=null;
	openAllRecordsAllLastID='';
	lastBtachSizeDoneRecordsAll=0;
	stopRecordsAll=false;
	stopRecordsAllError=false;
	msgRecordsAllAllRows="";
	messageCellRecordsAll="";
	lastBtachSizeDoneRecordsAll=0;
	
	$("#RecordsAllAllDialog").remove();											//Starting  Update...
	$("body").append("<div id='RecordsAllAllDialog'><div class='progresslabelMactALL'>"+RecordsAllProgTextsArr[0]+"</div><div id='progressbarRecordsAll' style='margin-top:15px;'></div></div>");
	progressLabelRecordsAll = $( ".progresslabelMactALL" );
	progressbarRecordsAll = $( "#progressbarRecordsAll" );
	var RecordsAllAllDialog=$("#RecordsAllAllDialog").dialog({
            resizable: true,
            //height:500,
            width:(isSF1()?($(self).width()-20):500),
            modal: openDialogAsMod(),
            title: RecordsAllProgTextsArr[7],//title
            buttons: [{
            text:RecordsAllProgTextsArr[1], //stop
            click: function() {
               stopRecordsAll=true;
                RecordsAllAllDialog.dialog( {"buttons":[{
			          text: RecordsAllProgTextsArr[2], //Stopping...#
			          click: function(){
			          //$( this ).dialog( "close" );
			          }
			        }]});
            }}]
            ,
            open: function() {
         		 //progressTimer = setTimeout( progress, 2000 );
         		 progressbarRecordsAll.progressbar({
			      value: false,
			      max:totalCountAjxRecordsAll,
			      change: function() {
			      	var val1=progressbarRecordsAll.progressbar( "value" );
			      	if(val1==null){val1=0;}
			      						//"Current Progress: " 
			        progressLabelRecordsAll.html( RecordsAllProgTextsArr[3] + Math.round((val1/totalCountAjxRecordsAll)*100.0) + "% ("+val1+" / "+totalCountAjxRecordsAll+")" );
			      },
			      complete: function() {
			        progressLabelRecordsAll.text( RecordsAllProgTextsArr[4] );//"Complete!"
			        stopRecordsAll=true;
			        changeRecordsAllBtns();
			        //$(".ui-dialog button:visible").last().focus();
			        
                     searchChanged(1);
			      }
			    });
 				if(!stopRecordsAll)doAllRecordsAll();
       		},
             close: function( event, ui ) {
             	$( this ).dialog( "close" );
             }
            });
            
}
function changeRecordsAllBtns(){
	fixOnload();
	$("#RecordsAllAllDialog").dialog( {"buttons":[{
			          text: RecordsAllProgTextsArr[5], //"Close"
			          click: function(){
			          fixOnload();
			          $( this ).dialog( "close" );
			          } 
			        }]});
}
var msgRecordsAllAllRows="";
var messageCellRecordsAll="";
var lastBtachSizeDoneRecordsAll=0;
var RecordsAllSortField="id";
function doAllRecordsAll(done){

	//msgRecordsAllAllRows=$.trim($(".msgRecordsAllAllRowsID").html());
	//alert($(".messageCellRecordsAll").length + " "+done);
	//messageCellRecordsAll=($(".messageCellRecordsAll").length>0?$.trim($(".messageCellRecordsAll").text()):"");
	if(done!=null){
		if((msgRecordsAllAllRows!=null && msgRecordsAllAllRows!="") || (messageCellRecordsAll!=null && messageCellRecordsAll!="")){
			//alert(messageCellRecordsAll);
			if(messageCellRecordsAll!=null ){
				alert(messageCellRecordsAll);
				//$("#RecordsAllAllDialog").remove(); 
				//fixOnload();
				changeRecordsAllBtns();
				stopRecordsAllError=true;
				
			}else{
				//fixMultiDependancefield();
				alert(msgRecordsAllAllRows);
			}
			
		}else{
		
			//stopRecordsAll=true;
			var val = progressbarRecordsAll.progressbar( "value" );
			if(val==null || val==false){
				val=0;
			}
			//alert(val+" "+lastBtachSizeDoneRecordsAll+" "+totalCountAjxRecordsAll);
 			progressbarRecordsAll.progressbar( "value", (val + lastBtachSizeDoneRecordsAll) );
 			if((val + lastBtachSizeDoneRecordsAll) >= totalCountAjxRecordsAll){
 				stopRecordsAll=true;
 				//alert(1);
 			}
 			
 		}
	}
	if(stopRecordsAllError){
		$("body").trigger("stopRecordsAllNOTOK");
		return;
	}
	if(stopRecordsAll){
		changeRecordsAllBtns();
		//RecordsAllAllDialog.dialog("close");
		runFunctionRecordsAllOnDone(); 
		 searchChanged(1);
		 $("body").trigger("stopRecordsAllOK");
		return;
	}
	lastBtachSizeDoneRecordsAll=0;
	//alert("openAllRecordsAllLastID: "+openAllRecordsAllLastID);
	var DBsubQeryToUse=RecordsAllQuery;

	if(isSelectedRowsModesRecordsAll1){
		var arrIDs=new Array();
		$(".lcbX input:checked").each(function(){
			arrIDs.push($.trim($(this).parents(".lcbX:first").attr("rid")));
		});
		DBsubQeryToUse=DBsubQeryToUse+(DBsubQeryToUse.indexOf('where')>-1?" and ":" where ")+" id in ('"+(arrIDs.join("','"))+"')";
	}
	if(RecordsAllmaxID!=null && RecordsAllmaxID!=""){
		DBsubQeryToUse=DBsubQeryToUse+(DBsubQeryToUse.indexOf('where')>-1?" and ":" where ")+" id <= '"+RecordsAllmaxID+"'";
	}
	if(openAllRecordsAllLastID!=null && openAllRecordsAllLastID!=""){
		DBsubQeryToUse=DBsubQeryToUse+(DBsubQeryToUse.indexOf('where')>-1?" and ":" where ")+" id > '"+openAllRecordsAllLastID+"'";
	}
	DBsubQeryToUse=DBsubQeryToUse+" ORDER BY "+RecordsAllSortField+" asc limit "+runFunctionOnIdsMaxRowsAll1+" "+DB_END_ALLROWS_Qery;
	
	//alert("DBsubQeryToUse: " +DBsubQeryToUse);
	$('.message.errorM3').remove();currePlacex1RedErrors="";
	Visualforce.remoting.Manager.invokeAction(
                remoteQueryAjax2,
                DBsubQeryToUse,
                function(result, event){
                	//alert(event.type+"\n "+event.status +" \n"+result+"\n"+result.length+"\n"+result[0]+"\n");
                    if (event.status && result!=null) {
    					if(result!=null && result.length>0 && !stopRecordsAll ){
                        	openAllRecordsAllLastID=result[result.length-1].id;
                        	//var toUpdate=result.join(";");
                        	//alert(result+' ' +openAllRecordsAllLastID);
                        	//var CurNum = Number(progressbarRecordsAll.progressbar( "value" ));
                        	lastBtachSizeDoneRecordsAll=result.length;
                        	
 							runFunctionOnIdsRecordsAll1(result);//doAllRecordsAll('1');//,(CurNum+lastBtachSizeDoneRecordsAll==totalCountAjxRecordsAll) 
 						}else if(result!=null && result.length==0 && !stopRecordsAll){//no result then products where changed during the proccess > done
                        	var CurNum = Number(progressbarRecordsAll.progressbar( "value" ));
                        	lastBtachSizeDoneRecordsAll=totalCountAjxRecordsAll-CurNum;
                        	stopRecordsAll=true;
                        	doAllRecordsAll('1'); 
                        }else{
                        	//lastBtachSizeDoneRecordsAll=0;
                        	//openAllRecordsAllLastID='';
                        	//doAllRecordsAll('1');
                        	if(stopRecordsAll){
                        		changeRecordsAllBtns();
                        	}
                        }
                    
                     } else if (event.type === 'exception') {
                        if(event.message!=null && ((event.message+"").indexOf("Logged in")>-1 || (event.message+"").indexOf("Refresh page")>-1)){
                            self.location=self.location;
                        }else if(event.message!=null && (event.message+"").indexOf("Unable to connect")==-1){
                            if($("body:visible").length>0)alert("An error has occurred: "+event.message);
                        }
                    } else {
                        //self.location=self.location;
                        // $("#"+filterIdSpan+" .availVals").html("");
                        	//searchChanged(1);
                    }
                }, 
                {escape: true,buffer:true,timeout: 90000}
            );
            
}

function addRemoveMPVal(fildAPINAme,isRemove){
	if(isEditMode1){
	var checkCBs=$(".dataRow input.lcbXRow:checked");
	if(checkCBs.size()==0){
		alert("Please select the rows that you want update!");
	}else{
	var isAdd=isRemove==null;
	var titX=isAdd?"Available":"Chosen";
	var titX2=isAdd?"Add":"Remove";
	//var fildAPINAme=prompt("Please enter the multi-picklist field api name in lowercase", "field_api_name");
	var valSTR=prompt("Please enter the multi-picklist value to "+(isAdd?"Add":"Remove")+" to the other", "Value to "+(isAdd?"Add":"Remove")+"");
	if(fildAPINAme!=null && valSTR!=null && fildAPINAme!="" && valSTR!=""){
	
	var rows=$(".dataRow ."+fildAPINAme+" .multiSelectPicklistRow select[title*='"+titX+"'] option:contains('"+valSTR+"')");
	rows.each(function(){
	 var rowCB=$(this).parents("tr.dataRow:first").find("input.lcbXRow");
	 if(rowCB.is(":checked")){
		var ValueToAdd=$(this).val();
		if(ValueToAdd!=null && ValueToAdd!=""){
			$(this).parents("select:first").val(ValueToAdd);
			$(this).parents("tr.multiSelectPicklistRow:first").find("td.multiSelectPicklistCell a[href][title='"+titX2+"'] img").click();
		}
	 }
	});
	}
	}
	}else{
		alert("Please switch to edit mode first (click the edit button)!");
	}

}
