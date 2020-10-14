/**text export finds**/
var matchFindLastID="";
var findMatchDebug=false;
var textToExportX1="";
var textToExportX1WOMatches="";       
function handleFileSelectfindmatchs(evt){
	$(".fileX1EZImport").addClass("loadingx1");
	handleFileSelectEzImport(evt,addFindMatchsFieldsSelection);
	
}

var findmatchsSets=[];
var matchingX=null;
var actualCSVRows=null;
var matchingXCriteria=null;
var matchColsNum=3;
function addFindMatchsFieldsSelection(){


Visualforce.remoting.Manager.invokeAction(
                        remotequeryAjax2GetTbFields,
                        findmatchstableX1, 
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
                                var matchCols="";
                                var matchColsInp="";
                                
                                for(var i1=0;i1<matchColsNum;i1++){
                                	matchCols+="<th style='width: 335px;' class='MathCriteria'> <span class='helpQMSFDC' onmouseover='fixTitlex2(this,false,\"R\",1);' title='Use this column to detect existing records. \"And\" is used across multiple fields on each Matching-Criteria column. \"Or\" is used across Matching-Criteria columns'>Matching Criteria #"+(i1+1)+"</span></th>";
                                }
                                var tbCont1="<table cellpadding='4' width='100%' cellspacing='0' class='fieldSelectionInTB'><thead><tr><th>SF Fields</th><th>Expected Value</th><th>Select content Column</th><th>Selected Value</th>"+
                                matchCols+
                                "</tr></thead><tbody>";
                                
                                for(var i1=0;i1<matchColsNum;i1++){ 
                                	matchColsInp+="<td style='width:250px' class='criteria criteria"+i1+"'>"+
                                	" <select name='CharsWords"+i1+"{0}' onmousedown='return isSF1();' onclick=' return openSearchSel3(this,event,this.id);' onkeydown='return openSelXDP3(this,event,this.id);' class='CharsWords' style='width:120px;color:#aaaaaa;' onchange='setGraySel(this);'><option value=''>Please Select</option><option value='all'>Use all words</option><option value='word~1'>Use the First Word</option><option value='word~2'>Use the first two words</option><option value='word~3'>Use the first three words</option><option value='char~1'>Use the first char</option><option value='char~2'>Use the first 2 chars</option><option value='char~3'>Use the first 3 chars</option><option value='char~5'>Use the first 5 chars</option></select>"+
                                	"<select style='width:130px;color:#aaaaaa;' name='dupeAlg"+i1+"{0}' crt='"+i1+"' onmousedown='return isSF1();' onclick=' return openSearchSel3(this,event,this.id);' onkeydown='return openSelXDP3(this,event,this.id);' class='dupeAlg' onchange='setGraySel(this);'><option value=''>Please Select</option><option value='ExactMatch'>Exact Match</option><option value='CleanName'>Clean Name: Acronyms/ Synonyms/ Prefixes/ Suffixes/ Ignore Order</option><option value='CleanNameFuzzy'>Clean Name & Phonetic Match </option> </select>  "+

                                	"</td>";
          						}
          									
                                var tbCont1In="";
                                var funcsTorun=new Array();
                                for(var i=0;i<result.length;i++){
                                    //alert(result[i].label+" "+result[i].name+ " "+result[i].relationshipName);
                                    if(result[i].name!=null && result[i].childRel==0 ){
                                        var isChilds=false;
                                        
                                        if(result[i].type!='CHILDS'){ 
                                            //sel1+="<option cr=\""+result[i].childRel+"\" value=\""+result[i].name+"\" ref=\""+result[i].referenceTo+"\" rn=\""+result[i].relationshipName+"\" tp=\""+result[i].type+"\" isref=\"0\">"+result[i].label+"</option>";
                                            var tempN=cellMap[result[i].label.toLowerCase()];
                                            var def=findmatchsSets[result[i].name.toLowerCase()];
                                            var defV=findmatchsSets[result[i].name.toLowerCase()+"-val"];
                                            var defDupe=findmatchsSets[result[i].name.toLowerCase()+"-dupe"];
                                            var defchooseType=findmatchsSets[result[i].name.toLowerCase()+"-chooseType"];
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
                                            	typeChoose="<select style='max-width: 195px;' name='"+(result[i].name+"-"+result[i].type+"-"+result[i].Createable+"").toLowerCase()+"-chooseType' class='chooseType' title='Non existing values are treated as nulls' onmouseover='fixTitlex2(this,false,\"R\",1);'>"+typeChoose1+"</select>";
                                            	
                                            	if(defchooseType!=null && defchooseType!=""){
                                            		var x1=(result[i].name+"-"+result[i].type+"-"+result[i].Createable+"-chooseType").toLowerCase();
                                            		funcsTorun.push([x1,defchooseType,function(x1,defchooseType){
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
          									
                                           tbCont1In=(devVal=="" && tempN==null?tbCont1In:"")+"<tr class='imR "+(result[i].Createable=="true"?"":"ro1 ")+"' r='"+i+"' name='"+result[i].name+"'><td><span class='l'>"+result[i].label+"</span></td><td>"+(typeChoose)+"</td><td> <select class='fldM A-"+i+"' name='A-"+i+"-"+result[i].name+"' onchange='$(this).parents(\".imR:first\").find(\".fldInput\").val(($(this).val()==\"\"?\"\":\"Column:\"+$(this).val()))'>"+(tempN!=null?selectOpt.replace("'"+tempN+"'>","'"+tempN+"' selected>"):selectOpt)+"</select></td><td> <input type='text' name='"+(result[i].name+"-"+result[i].type+"-"+result[i].Createable).toLowerCase()+"' placeholder='Map / Actual Value' autocomplete='off' readonly class='fldInput fldInput"+result[i].name+" "+(result[i].type.toLowerCase().indexOf('date')>-1?"datePick":"")+"' value='"+(devVal!=""?devVal:(tempN!=null?"Column:"+tempN:""))+"' ></td>"+(matchColsInp.replace(/\{0\}/ig,result[i].name+""))+"</tr>"+(devVal!="" || tempN!=null?tbCont1In:"");  
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
                        {escape: true}
                    );
                    
		  	
}

function openfindmatchsJob(){
	var html1='<div style="font-weight:bold; margin: 10px 0px;width:98%;">Please select the main object for the matching job:</div>'+
				'<div id="mainObjPreDiv" style="margin-top: 14px;"><b>Loading...</b></div>';
				
				var button1={
				text: "Select Main Object", 
				click: function() { 
				openfindmatchs(null,$("#mainObjPre").val());
				jQuery( this ).dialog( "close" ); 
				}};
				//alert(html1);
				messagePopupAlert(html1,"Find matching and non-matching records",button1);
				
				
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

function OpenFilterWizardFindMatches(mainTb,jsObj){
	var conditionpoup='<div id="multiSelFldsWRp2" title="Choose a Field"></div> <div id="multiSelFldsWRp3" class="hd1" title="Add a Condition"> <div style="padding:5px;display:block;border:1px solid #eeeeee;margin-bottom:10px;"> 1) Select a Field: </div><div id="multiSelFldsWRp3in" /> <div style="padding:5px;display:block;border:1px solid #eeeeee;margin-bottom:10px;margin-top:10px;"> <span> 2) Add Condition: </span> <select name="RLRFAndOr1" id="RLRFAndOr1"> <option value=" ">-</option><option value="AND">AND</option><option value="OR">OR</option> </select><input tyle="text" value="Select a Field" id="RLRF" class="RLRF" style="" onclick="initFieldPicker(this);"/><select name="RLRFOp1" id="RLRFOp1" onchange="RLRFOp1Change();" style="width: 171px;"><optgroup label="Texts" typeValid="text"><option value="{0}=\'{1}\'">equals</option><option value="{0}!=\'{1}\'">not equal to</option><option value="{0} like \'{1}%\'">starts with</option><option value="{0} like \'%{1}%\'">contains</option><option value="(not {0} like \'%{1}%\')">does not contain</option><option value="{0} &lt; \'{1}\'">less than</option><option value="{0} &gt; \'{1}\'">greater than</option><option value="{0} &lt;= \'{1}\'">less or equal</option><option value="{0} &gt;= \'{1}\'">greater or equal</option><option value="{0} in (\'{1}\')">includes</option><option value="(not {0} in (\'{1}\'))">excludes</option></optgroup><optgroup label="Numbers" typeValid="number"><option value="{0}={1}">equals</option><option value="{0}!={1}">not equal to</option><option value="{0} &lt; {1}">less than</option><option value="{0} &gt; {1}">greater than</option><option value="{0} &lt;= {1}">less or equal</option><option value="{0} &gt;= {1}">greater or equal</option><option value="{0} in ({1})">includes</option><option value="(not {0} in ({1}))">excludes</option></optgroup><optgroup label="Dates" typeValid="date"><option value="{0}={1}">equals</option><option value="{0}!={1}">not equal to</option><option value="{0} &lt; {1}">less than</option><option value="{0} &gt; {1}">greater than</option><option value="{0} &lt;= {1}">less or equal</option><option value="{0} &gt;= {1}">greater or equal</option><option value="{0} = TODAY">equals today</option><option value="{0} = LAST_N_DAYS:{1}">equals last n days</option><option value="{0} = NEXT_N_DAYS:{1}">equals next n days</option><option value="{0} = LAST_N_QUARTERS:{1}">equals last n quarters</option><option value="{0} = NEXT_N_QUARTERS:{1}">equals next n quarters</option><option value="{0} = LAST_N_YEARS:{1}">equals last n years</option><option value="{0} = NEXT_N_YEARS:{1}">equals next n years</option></optgroup><optgroup label="Multi Picklists" typeValid="multiPL"><option value="{0} includes (\'{1}\')">includes</option><option value="{0} excludes (\'{1}\')">excludes</option><option value="{0}=\'{1}\'">equals</option><option value="{0}!=\'{1}\'">not equal to</option></optgroup><optgroup label="Check Boxes" typeValid="checkbox"><option value="{0}={1}">equals</option><option value="{0}!={1}">not equal to</option></optgroup></select><input type="text" name="condvalue" id="condvalue" value="" style="width:138px;" autocomplete="off"/><button id="mainPAdvanceFilter" disabled="disabled" onclick="appendToFieldVal(\'RLRF\',\'RLRF-TA\');" type="button" class="btnDisabled" style="font-size:13pt;line-height: 13px;vertical-align: -2px;">+</button></div><div style="padding:5px;display:block;border:1px solid #eeeeee;margin-bottom:10px;"> 3) Edit Condition: </div><textarea id="RLRF-TA" class="RLRF-TA"/> <div style="" id="ValidIssue"></div></div>';
	if($("#multiSelFldsWRp2").length==0){
		$("body").append(conditionpoup);
	}
	conditionPickX_tableName=mainTb;
	//conditionPickX($(jsObj)[0]);
		selectSoqlFieldCon($(jsObj)[0]);
	//conditionPickX.selectSoqlField();
}


var findmatchstableX1="";
  function openfindmatchs(findmatchsSetsT,tableX1temp){
  		if(findmatchsSetsT==null){
  			findmatchsSetsT=[];
  		}
  		if(tableX1temp!=null && tableX1temp!=''){
  			findmatchstableX1=tableX1temp;
  		}else{
  			findmatchstableX1=tableX1;
  		}
  		
  		findmatchsSets=findmatchsSetsT;
  		fileX1EZImport="";
		$('#dialog-easy-import').remove(); 
		
		$('body').append( 
		'<div id="dialog-easy-import" title="Find matching and non-matching records as CSV Files ">' + 
		'<form id="easyimportform">'+
		'<div style="margin:5px 0px 10px 0px;font-weight:bold;">1) Choose a CSV / Tab-delimited / Unicode text file or paste the file content directly from your spreadsheet:</div>'+
                   //'Choose File Encoding: <select id="encode1EZImport" onchange="$(\'#files\').val(\'\');$(\'#fileX1EZImport\').val(\'\');"><option value="UTF-8">UTF-8 File (default)</option><option value="ISO-8859-1">ISO-8859-1 File</option></select>' +
                   '<div style="margin:0px 0px 10px 0px;">Choose / Drag file: <input type="file" id="files" name="files[]" style="border:1px solid #d5d5d5;padding:5px;"/></div>'+
                    
		'<div style="margin:0px 0px 5px 0px">File Content / Preview <span style="float:right;margin-top:-5px;margin-right:0px;"><select id="fileTypeEZImport" onchange="if($(\'.fileX1EZImport\').val()!=\'\')addFindMatchsFieldsSelection();" style="color:#696969"><option value="TAB">Tab-delimited / Unicode / Copy-Paste</option><option value="CSV" >CSV</option></select></span>: </div>'+
		' <Textarea class="fileX1EZImport" id="fileX1EZImport" style="width:99.7%;height:69px;white-space:pre" onchange="$(\'.contFindMatchs\').hide();addFindMatchsFieldsSelection();" onclick="$(\'.contFindMatchs\').show();"/><div style="width:230px;padding:5px;" class="contFindMatchs ui-state-default ui-corner-all hd1" onclick="$(this).hide();" ><span class="ui-icon ui-icon-circle-triangle-s" style="display: inline-block;vertical-align: -3px;"></span> Recalculate Field Mappings</div>'+ 
		'<div class="fieldSelection hd1" style="margin-top:15px;"><b>2) Fields Mapping &amp; Matching Criteria:</b>'+
		
		'<div style="float:right;display:inline-block;margin-top: -10px;margin-right: 15px;">'+
		'<button class="btn" onclick="openSavedMapping();return false;" type="button" style="margin-left:5px;margin-right:5px;">Load / Save Field Mappings</button>'+
		'<button class="btn" onclick="openSynonymsPupup();return false;" type="button" style="margin-left:5px;margin-right:5px;">Acronyms/ Synonyms/ Prefixes/ Suffixes </button>'+
		//'<select style="height: 28px;" onmousedown="return isSF1();" onclick=" return openSearchSel3(this,event,this.id);" onkeydown="return openSelXDP3(this,event,this.id);" onselect="loadFindIDSettings();"><option value="">Saved Settings - Please Select</option><option value="SaveSettings">Save Settings</option></select>'+
		''+
		' </div>'+
		'<div class="fieldSelectionIn" style="margin-top: 5px;max-height:250px;width:100%;overflow:auto;padding:5px 0px;border:1px solid #aaaaaa;"> - Upload file first - </div>'+
		//'<div style="margin-top:5px;margin-bottom:0px;"><input type="checkbox" name="skipInvalidNums" class="skipInvalidNums" '+(findmatchsSets['skipInvalidNums']!=null?'checked':'')+'> <label for ="skipInvalidNums">Skip Invalid Numbers during matching (use null)</label></div>'+
		//'<div style="margin-top:5px;">Duplicates Strategy: <select name="detectDupes" class="detectDupes"><option value="update">Update Existing Rows (upsert)</option><option value="skip">Skip Duplicates</option><option value="create">Create Duplicates</option></select></div>'+
		'<div style="color:#696969;margin-top:5px;">RO: Read-only fields.</div>'+
		
		'<div style="margin-top:15px;width:100%;"><span style="display:block;width:100%;font-weight:bold;"> 3) Custom advanced / SOQL filter:</span> '+
		'<div style="width:100%;margin-top:3px;"><textarea id="FindMatchesAllSOQLFilter" name="FindMatchesAllSOQLFilter"  onchange="checkSyntaxX(\'#tot1\',\''+tableX1temp+'\',\'#FindMatchesAllSOQLFilter\',\'#CSMMALL\')" style="width:100%;height:85px;">'+(tableX1temp=='lead'?' isconverted=false ':'')+'</textarea>'+
		'</div>'+
		'<div style="margin-top:3px;"><button onclick="OpenFilterWizardFindMatches(\''+tableX1temp+'\',\'#FindMatchesAllSOQLFilter\');" type="button" class="btn" style=" background: #ffffe0 !important;" >SOQL Filter Wizard</button> <button onclick="checkSyntaxX(\'#tot1\',\''+tableX1temp+'\',\'#FindMatchesAllSOQLFilter\',\'#CSMMALL\')" class="btn" type="button" >Check Syntax & Recalculate totals</button> &nbsp;&nbsp;&nbsp;<span id="tot1"></span><span id="CSMMALL"></span></div>'+
		
		'</div> </div>'+
		
		
		'</form>'
		); 
   var buttons1=new Array();
			buttons1.push({ 
		text: "Find matching and non-matching records as CSV Files",
		click: function() { 
		 runfindmatchs(this);
		
		}
		});
		
		
		buttons1.push({
		text: "Close", 
		click: function() { 
		jQuery( this ).dialog( "close" ); 
		} 
		});
		
		$( "#dialog-easy-import" ).dialog({ 
		resizable: true, 
		width: (isSF1()?($(self).width()-10):($(self).width()-30)), 
		height:(isSFLight1XV?($(self).height()-30):$(self).height()-30), 
		//modal: true, 
		buttons: buttons1,
		open:function(){
		  	document.getElementById('files').addEventListener('change', handleFileSelectfindmatchs, false); 
				     fixIfmHegt();
           	}
		}); 

  
  }
  
  
  function runfindmatchs(obj){
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
	  			var imp1=findmatchsObj(fileX1EZImport);
	  		}
	  	}else{
			alert("Please select a file or paste its content to the file content textarea!");
		}
  }
  
  function findmatchsObj(fileX1EZImport){
  	  
	  $.expr[":"].containsUC = $.expr.createPseudo(function(arg) {
	    return function( elem ) {
	        return $(elem).text().toUpperCase().indexOf(arg.toUpperCase()) >= 0;
	    };
	});
	
	
function initProgress(totalCount){
		$("#findmatchsObjDialog").remove();
		$("body").append("<div id='findmatchsObjDialog'><div class='progress-label'>"+findmatchsObjProgTextsArr[0]+"</div><div id='findmatchsprogbar' style='margin-top:15px;'></div><div class='progress-label2'></div><div id='importErr' style='height:69px;overflow:auto;margin-top:5px;'></div></div>");
	findmatchsproLabel = $( ".progress-label" );
	findmatchsproLabel2 = $( ".progress-label2" );
	findmatchsprogbar = $( "#findmatchsprogbar" );
	
	var findmatchsObjDialog=$("#findmatchsObjDialog").dialog({
            resizable: true,
            height:300,
            width:(isSF1()?($(self).width()-20):500),
            modal: openDialogAsMod(),
            title: findmatchsObjProgTextsArr[7],
            buttons: [{
            text:findmatchsObjProgTextsArr[1], //stop
            click: function() {
               stopfindmatchsObj=true;
                findmatchsObjDialog.dialog( {"buttons":[{
			          text: findmatchsObjProgTextsArr[2], //Stopping...#
			          click: function(){
			          //$( this ).dialog( "close" );
			          }
			        }]});
            }}]
            ,
            open: function() {
         		 //progressTimer = setTimeout( progress, 2000 );
         		 findmatchsprogbar.progressbar({
			      value: false,
			      max:totalCount,
			      change: function() {
			      	var val1=findmatchsprogbar.progressbar( "value" );
			      	if(val1==null){val1=0;}
			      						//"Current Progress: " 
			        findmatchsproLabel.html( findmatchsObjProgTextsArr[3] + Math.round((val1/totalCount)*100.0) + "% ("+val1+" / "+totalCount+")" );
			      },
			      complete: function() {
			        findmatchsproLabel.text( findmatchsObjProgTextsArr[4] );//"Complete!"
			        stopfindmatchsObj=true;
			        changeImportBtns();
			        
                    // searchChanged(1);//
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
	$("#findmatchsObjDialog").dialog( {"buttons":[{
			          text: findmatchsObjProgTextsArr[5], //"Close"
			          click: function(){
			          $( this ).dialog( "close" );
			          } 
			        }]});
}

			var stopfindmatchsObj=false;
  			var findmatchsproLabel=null;
  			var findmatchsproLabel2=null;
  			var totalMatchingx=0;
  			
  			var findmatchsprogbar=null
	    	var Sep1=($("#fileTypeEZImport").val()=="TAB"?"\t":",");
	    	var sepText=(Sep1=="\t"?"\\t":"~~");//inside comma
		  	var tabDelFile= fileX1EZImport;
		  	var rows=getFileRows(tabDelFile,Sep1);//tabDelFile.split(/\n/ig);

		
		  	
		  	if(licenseStatus!='Active' && licenseStatus!='ActiveP' && (rows.length>50 || getStoredNumPPL("findmatchs")>7)){ 
					licenseReqMessage("During the free trial Find Matching report is limited to 50 rows per shot / 7 shots in total."); 
					//jQuery( this ).dialog( "close" ); 
					return; 
			}
			
			if( licenseStatus!='ActiveP' && rows.length>50){ 
					licenseReqMessage("The 'Find Matching Records' report is not included with your license, you can try it in your sandbox or with up to 50 rows. \nContact sales@zaapit.com for more details!"); 
					return; 
			}
		
		  	var headers=new Array();
		  	//var headersTPX=new Array();
		  	var actualRows=$(".dataRow[rowid='']");
		  	var cellReg=new RegExp(Sep1,"ig");
		  	var detectDupes=$(".detectDupes").val();
		  	var skipInvalidNums=$(".skipInvalidNums").is(":checked")+"";
		  	var useEmptyLookups=findmatchsSets['useEmptyLookups'];
		  	var skipRowsEmptyLookups=findmatchsSets['skipRowsEmptyLookups'];
		  	
		  
	  		
		  	var currRow=0;
		  	var currfindmatchsObj=this;

		  	findmatchsObjProgTextsArr="Analyzing File's Rows...#Stop#Stopping...#Current Progress: #Complete!#Close#Are you sure?\n\nThis is the second and last confirm for matching!#Matching Rows".split("#");
		  	initProgress(rows.length);
		  	
		  	matchingXCriteria=new Array();
		  	var flds="";
		  	fldHeadersExport=new Array();
		  	fldHeadersExportAPI=new Array();
		  	 //for(var i1=0;i1<matchColsNum;i1++){ 
				//$(".criteria"+i1+"").each(function(){
					var sets=matchingXCriteria;//new Array();

				  	$("select.dupeAlg[value!=''][crt!='']").each(function(){
						var dupeAlg=$(this).val()
						var crt=Number($(this).attr("crt"));
				  		var tr=$(this).parents("tr:first");
				  		var fldM=tr.find("select.fldM[value!='']");
				  		var fldInput=tr.find(".fldInput").val();
				  		var CharsWords=$(this).parents("td:first").find(".CharsWords").val();
						var fldAPI=$(this).parents("tr:first").attr("name");
						
				  		var flmV=fldAPI;//fldM.val();
				  		
				  		if(dupeAlg!=null && dupeAlg!="" && flmV!=null &&flmV!=""){
							var set1={};
							set1['fldInput']=fldInput;
							set1['dupeAlg']=dupeAlg;
							set1['CharsWords']=CharsWords;
							set1['fldAPI']=fldAPI;
							
					  		flds+=","+flmV;
					  		var chooseType=tr.find("select.chooseType");
					  		if(fldM.length>0 && chooseType.size()>0 && chooseType.val()!="ID"){
					  			var namexL=chooseType.val().split(">");
					  			var namex=(namexL.length>1?namexL[1]:"Name");
					  			var fld2=fldM.attr("name").split("-")[2];
					  			if(fld2.indexOf("__c")>-1){
					  				fld2=fld2.replace("__c","__r");
					  			}else if(fld2.indexOf("Id")==fld2.length-2){
					  				fld2=fld2.substring(0,fld2.length-2);
					  			}
					  			flds+=","+fld2+"."+namex;
					  			set1['fldAPI']=fld2+"."+namex;
					  			
					  			set1['namex']=namex;
					  			set1['namexL']=namexL;
					  			
					  			set1['fld']=fld2;		
					  			set1['fldm']=flmV;
					  			set1['chooseType']=chooseType;
					  						  			
					  		}else{
					  			set1['fld']=fld2;		
					  			set1['fldm']=flmV;
					  			//set1['chooseType']=chooseType;
					  		}
					  		fldHeadersExport.push(set1['fldAPI']);
					  		if(sets[crt]==null) sets[crt]=new Array();
					  		sets[crt].push(set1);	
					  			
				  		}
				  	});
				  	
				  	//matchingXCriteria.push(sets);
				  	
		//	  	});
		  //	}
		  
		  if(matchingXCriteria.length==0){
		  	alert("Please select at least one matching criteria!");
		  	$("#findmatchsObjDialog").remove();
		   	return;
		   }
		  
		     fldHeadersExportAPI=fldHeadersExport;
		  	var cellsHead=getRowCells(rows[0],Sep1,cellReg,sepText);
		  	
		  	
		  	textToExportX1="\"Salesforce Data:\","+"\""+(fldHeadersExportAPI.join("\",\"").replace(/[^\"\,]/ig," "))+"\",\"Search String\",\"File \""+
		  	"\n\"Id\",\""+(fldHeadersExportAPI.join("\",\""))+"\",\"Text\",\""+$.trim(cellsHead.join("\",\""))+"\"";
		  	textToExportX1WOMatches="\"Search String \",\""+(cellsHead.join("\",\""))+"\"";
		  	
	  		/*for(var i=0;i<cells.length;i++){
	  			var tempN=cells[i].replace(/["\,~]+/ig,'').toLowerCase();
	  			cellMap[tempN]=i;
	  			
	  		}
	  		*/
	  		//importRowsMatching
	  		var cellsHeadSize=cellsHead.length;
	  		//findmatchsprogbar.progressbar( "value", (i+1) );
	  		importRowsMatching=new Array();
	  		importRowsMatchingUsed=new Array();
	  		actualCSVRows=rows;
	  		for(var i=1;i<rows.length;i++){
	  			if(rows[i]=="") continue;
	  			var rowCells=getRowCells(rows[i],Sep1,cellReg,sepText);
	  			if(findMatchDebug) console.log(matchingXCriteria);
	  			if(rowCells.length!=cellsHeadSize) continue;
	  			for(var j=0;j<matchingXCriteria.length ;j++){
	  				var MatchSTR='';
	  				var sets=matchingXCriteria[j];
	  				if(sets==null) continue;
	  				if(findMatchDebug) console.log(sets);
	  				for(var j1=0;j1<sets.length;j1++){
	  					var set1=sets[j1];
	  					if(findMatchDebug) console.log(set1);
	  					if(set1['dupeAlg']==null || set1['CharsWords']==null) continue;
	  					var fldInput=set1['fldInput'];
	  					var fldVal='';
	  					if(fldInput!=null && fldInput.indexOf("Column:")>-1){
	  						var fldValX=fldInput.substring(7);
	  						if(!isNaN(fldValX)){
	  							fldVal=rowCells[Number(fldValX)];
	  						}
	  					}else{
	  						//fldVal=fldInput;//if entered fix valye
	  					}
	  					if(findMatchDebug) console.log("fldVal: "+fldVal+ ", fldInput: "+fldInput);
	  					
	  					var dupeAlg=set1['dupeAlg'];;
						var CharsWords=set1['CharsWords'];
						
						var CharsWordsX=CharsWords.split("~");
						var isword=CharsWordsX[0]=="word";
						var ischar=CharsWordsX[0]=="char";
						var fldValX=cutText(fldVal,(ischar?Number(CharsWordsX[1]):0),(isword?Number(CharsWordsX[1]):0),false);
						
						if(dupeAlg=="CleanName" ){
							fldValX=cleanTextSynonyms(fldValX);
						
						}else if(dupeAlg=="CleanNameFuzzy"){
							fldValX=cleanTextSynonyms(fldValX);
							fldValX=soundex(fldValX);
						
						}
						MatchSTR+="~"+$.trim(fldValX);
	  					//var fldMatchChar=importRowsMatching[i][Number(set1['fldm'])];
	  					//var ;=
	  					/*set1['namex']=namex;
					  			set1['fld']=fld2;		
					  			set1['fldm']=flmV;
					  			set1['namexL']=namexL;
					  			set1['chooseType']=chooseType;*/
	  					
	  				}
	  				if(findMatchDebug) console.log("MatchSTR:" +MatchSTR);
	  				if(MatchSTR!=""){
	  					MatchSTR=MatchSTR.substring(1);//remove ~
	  					if(importRowsMatching[MatchSTR] == null){
	  						importRowsMatching[MatchSTR]=new Array();
	  					}
	  					importRowsMatching[MatchSTR].push(rowCells);
	  				}
	  				
	  				var val = findmatchsprogbar.progressbar( "value" );
					if(val==null || val==false){
						val=0;
					}
		 			
	  			}
	  			if(i%100==0 ||i+1==rows.length) findmatchsprogbar.progressbar( "value", (i+1) );//val + 1
	  		}
	  		//if(findMatchDebug) console.log(importRowsMatching);
	  		
	  		
		  	var DBsubQeryToUse="SELECT Id"+flds+" FROM "+findmatchstableX1+" ";
		  	matchingX=new Array();
		  	//matchingXCriteria=new Array();
		  	
		  	
		  	
		  	startMatch(DBsubQeryToUse);
		  	
		  	 function start(){
		  		var listRow=[];
		  		var lastcurrRow=currRow;
		  		var fields="";
		  		var batchSizeAI=findmatchsSets['batchSize'];//batchSize in settings
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
			  			var json={"tableX1":findmatchstableX1,"listObj":listRow,"useEmptyLookups":useEmptyLookups,"skipRowsEmptyLookups":skipRowsEmptyLookups,"skipInvalidNums":skipInvalidNums,"detectDupes":detectDupes,"dupeFields":dupe,"fields":fields,"chooseType":chooseType};
			  			
			  			
			  			 Visualforce.remoting.Manager.invokeAction(
			                remoteCreateRow,
			                JSON.stringify(json), 
			                function(result, event){
			                    if (event.status && result!=null) {
			    					//alert(result+"\n\n"+result.replace(/\&quot\;/ig,"\"").replace(/\&\#39\;/ig,"'").replace(/\\/ig,""));
			    					result=jQuery.parseJSON(result.replace(/\&quot\;/ig,"\"").replace(/\&\#39\;/ig,"'").replace(/\\/ig,"").replace(/\n/ig,"<br/>"));
			    					//alert(result);
			                        //result
			                        
			                        	var val = findmatchsprogbar.progressbar( "value" );
										if(val==null || val==false){
											val=0;
										}
							 			findmatchsprogbar.progressbar( "value", (val + (currRow-lastcurrRow)) );
			                        if(result["status"]!=null && result["status"]=="OK"){

			                        }else{
			                        	//stopfindmatchsObj=true;
			                        	$("#importErr").append("Error matching rows ("+lastcurrRow+":"+(currRow-1)+"), "+result["message"]+"<br/>");
			                        }
			                        if(!stopfindmatchsObj && currRow<rows.length){
			                        	//currRow++;
			                        	start();
			                        }
			                        if(stopfindmatchsObj){
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
		  
		    function startMatch(DBsubQeryToUse){//cal total
		  		totalMatchingx=0;
		  		var FindMatchesAllSOQLFilter=$("#FindMatchesAllSOQLFilter").val();
		  		if(FindMatchesAllSOQLFilter!=""){
		  			FindMatchesAllSOQLFilter=" where "+FindMatchesAllSOQLFilter;
		  		}
					var DBsubQeryToUseX="SELECT count(id) count1 "+DBsubQeryToUse.substring(DBsubQeryToUse.indexOf("FROM"))+" "+FindMatchesAllSOQLFilter;
			  			Visualforce.remoting.Manager.invokeAction(
                remoteQueryAjax2,
                DBsubQeryToUseX, 
                function(result, event){
                //alert(event.status + " "+event.type +" "+ result.length);
                    if (event.status && result!=null ) {
                       if(result.length>0){
                       		
                       		matchFindLastID="";
                       		findmatchsObjProgTextsArr="Analyzing Your Data...#Stop#Stopping...#Loading DB rows: #Complete!#Close#Are you sure?\n\nThis is the second and last confirm for matching!#Analyzing Your Data".split("#");
                       		if(findMatchDebug) console.log(result);
		  					if(result[0].count1!=null){
			  					initProgress(result[0].count1);
			  					if(findMatchDebug) console.log(result[0].count1);
			  					
	                       		startMatchIn(DBsubQeryToUse);
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
                        //alert(1);
                    }
                }, 
                {escape: true,buffer:false,timeout: 90000}
            );
			  		
			  	
		  }
                       
                 
		  function startMatchIn(DBsubQeryToUse){
		  			var FindMatchesAllSOQLFilter=$("#FindMatchesAllSOQLFilter").val();
		  			
					var DBsubQeryToUseX=DBsubQeryToUse;

					if(matchFindLastID!=null && matchFindLastID!=""){
						if(FindMatchesAllSOQLFilter!="") FindMatchesAllSOQLFilter=" and ("+FindMatchesAllSOQLFilter+")"; 
						DBsubQeryToUseX+=(DBsubQeryToUseX.indexOf('where')>-1?" and ":" where ")+" id > '"+matchFindLastID+"' "+FindMatchesAllSOQLFilter+" order by id asc limit 500";
					}else{
						if(FindMatchesAllSOQLFilter!="") FindMatchesAllSOQLFilter=" where "+FindMatchesAllSOQLFilter;
						DBsubQeryToUseX+=FindMatchesAllSOQLFilter+" order by id asc limit 500";
					}			  			
			  			
			  			Visualforce.remoting.Manager.invokeAction(
                remoteQueryAjax2,
                DBsubQeryToUseX, 
                function(result, event){
                //alert(event.status + " "+event.type +" "+ result.length);
                    if (event.status && result!=null ) {
                   		 if(findMatchDebug) console.log(result);
                       if(result.length>0){
                       			if(findMatchDebug) console.log("matchFindLastID: "+matchFindLastID);
		                    	matchFindLastID=result[result.length-1]['Id'];
		                    	//if(findMatchDebug) console.log("matchFindLastID: "+matchFindLastID);
		    					for(var i=0;i<result.length;i++){
		    						//matchingX[]
		    						fldHeadersExport=new Array();
		    						fldHeadersExport2=new Array();
		    						for(var k=0; k<fldHeadersExportAPI.length;k++){
		    							var fldAPI=fldHeadersExportAPI[k];
					  					var fldVal='';
										var fldTemp=result[i];
					  					if(fldAPI!=null && fldAPI!=""){//get val
					  						if(fldTemp!=null) fldTemp=fldTemp[fldAPI]; 
					  						/*var fldAPIX=fldAPI.split(".");
					  						for(var k1=0;k1<fldAPIX.length;k1++){
					  							if(fldTemp!=null) fldTemp=fldTemp[fldAPIX[k1]]
					  						}*/
					  					}
					  					if(fldTemp!=null) fldVal=$.trim(fldTemp);
							  			fldHeadersExport.push(fldVal);
							  			fldHeadersExport2[fldAPI]=fldVal;
		    						}
		    						var foundMatching=false;
		    						
		    						for(var j=0;j<matchingXCriteria.length && rowCells.length==cellsHeadSize;j++){
							  				var MatchSTR='';
							  				var sets=matchingXCriteria[j];
							  				if(findMatchDebug) console.log(sets);
							  				for(var j1=0;j1<sets.length;j1++){
							  					var set1=sets[j1];
							  					if(findMatchDebug) console.log(set1);
							  					if(set1['dupeAlg']==null || set1['CharsWords']==null || set1['fldAPI']==null  || set1['fldAPI']=="" ) continue;
							  					var fldInput=set1['fldInput'];
							  					var fldAPI=set1['fldAPI'];
							  					var fldVal='';
							  					var fldTemp=result[i];
							  					//fldHeadersExport
							  					/*
							  					if(fldAPI!=null && fldAPI!=""){//get val 
							  						var fldAPIX=fldAPI.split(".");
							  						
							  						for(var k=0;k<fldAPIX.length;k++){
							  							if(fldTemp!=null) fldTemp=fldTemp[fldAPIX[k]]
							  						}
							  					}
							  					if(fldTemp!=null) fldVal=$.trim(fldTemp);
							  					*/
							  					fldTemp=fldHeadersExport2[fldAPI];
							  					if(fldTemp!=null) fldVal=$.trim(fldTemp);
							  					
							  					//fldHeadersExport.push(fldVal);
							  					
							  					if(findMatchDebug) console.log("fldVal: "+fldVal+ ", fldInput: "+fldInput);
							  					
							  					var dupeAlg=set1['dupeAlg'];;
												var CharsWords=set1['CharsWords'];
												
												var CharsWordsX=CharsWords.split("~");
												var isword=CharsWordsX[0]=="word";
												var ischar=CharsWordsX[0]=="char";
												var fldValX=cutText(fldVal,(ischar?Number(CharsWordsX[1]):0),(isword?Number(CharsWordsX[1]):0),false);
												
												
												if(dupeAlg=="CleanName" ){
													fldValX=cleanTextSynonyms(fldValX);
												
												}else if(dupeAlg=="CleanNameFuzzy"){
													fldValX=cleanTextSynonyms(fldValX);
													fldValX=soundex(fldValX);
												
												}
												MatchSTR+="~"+$.trim(fldValX);
							  					//var fldMatchChar=importRowsMatching[i][Number(set1['fldm'])];
							  					//var ;=
							  					/*set1['namex']=namex;
											  			set1['fld']=fld2;		
											  			set1['fldm']=flmV;
											  			set1['namexL']=namexL;
											  			set1['chooseType']=chooseType;*/
							  					
							  				}
							  				if(findMatchDebug) console.log("MatchSTR row:" +MatchSTR);
							  				if(MatchSTR!=""){
							  					MatchSTR=MatchSTR.substring(1);//remove ~
							  					var importRowsMatching_macth=importRowsMatching[MatchSTR];
							  					if(importRowsMatching_macth != null){//found?
							  						for(var k=0;k<importRowsMatching_macth.length;k++){
							  							//textToExportX1="\"Id\",\""+importRowsMatching_macth[k].join("\",\"")+"\""; 
							  							textToExportX1+="\n\""+result[i].Id+"\",\""+(fldHeadersExport.join("\",\""))+"\",\""+MatchSTR+"\",\""+$.trim(importRowsMatching_macth[k].join("\",\""))+"\"";
							  							totalMatchingx++;
							  						}
							  						importRowsMatchingUsed[MatchSTR]=true;
							  						
							  					}
							  					
							  				}
	  				
		    						}
		    						
		    					}
		    					
		    				var val = findmatchsprogbar.progressbar( "value" );
							if(val==null || val==false){
								val=0;
							}
				 			findmatchsprogbar.progressbar( "value", (val + result.length) );
				 			findmatchsproLabel2.html("Total matchings: "+totalMatchingx).css({"margin-top":"15px"});
				 			startMatchIn(DBsubQeryToUse);
		 				}else{//done
		 					if(findMatchDebug) console.log(importRowsMatching);
		 					
		 					saveTextAsCSV(textToExportX1,"match_report_");
		 					
		 					var totalMatchingxNM=0;
		 					for(MatchSTR in importRowsMatching){
		 						if(importRowsMatchingUsed[MatchSTR]==null){
		 							var importRowsMatching_macth=importRowsMatching[MatchSTR];
		 							if(importRowsMatching_macth != null){//found?
				  						for(var k=0;k<importRowsMatching_macth.length;k++){
				  							//textToExportX1="\"Id\",\""+importRowsMatching_macth[k].join("\",\"")+"\""; 
				  							textToExportX1WOMatches+="\n\""+MatchSTR+"\",\""+$.trim(importRowsMatching_macth[k].join("\",\""))+"\"";
				  							totalMatchingxNM++;
				  						}
				  					}
		 						}
		 					}
		 					
		 					findmatchsproLabel2.append("<div style='margin-top:7px'>Total rows without a matching: "+totalMatchingxNM+"</div>") ;
		 					if(actualCSVRows!=null && actualCSVRows.length>0) findmatchsproLabel2.append("<div style='margin-top:7px'>Total rows in input file: "+(actualCSVRows.length-1)+"</div>") ;
		 					
		 					if(totalMatchingxNM>0) saveTextAsCSV(textToExportX1WOMatches,"no_match_report_");
		 					changeImportBtns();
		 					//resultContent,fileNamePrefix
		 				
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
                }
                , 
                {escape: true,buffer:false,timeout: 90000}
            );
			  		
	  			
		}
  }
  
  var codes = {
             a: '', e: '', i: '', o: '', u: '',
             b: 1, f: 1, p: 1, v: 1,
             c: 2, g: 2, j: 2, k: 2, q: 2, s: 2, x: 2, z: 2,
             d: 3, t: 3,
             l: 4,
             m: 5, n: 5,
             r: 6
         };
  function soundex(s) {
     var a = s.toLowerCase().split(''),
         r = '';
  		var lastS="";
	   for(var i=0;i<a.length;i++){
	   		var s1=codes[a[i]];
	   		if(s1!="" && lastS==s1){//remove rep
	   			s1="";
	   		}else{
	   			lastS=s1;
	   		}
	   		r+=(s1==null?"":s1);
	   }
         
         return r;
         
};


function cutText(s,charCut,wordCut,ignoreWordOrder){
	var r=s;
	if(s!=null){
		r=r.toLowerCase();
		if(charCut!=null && charCut>0 && s.length>charCut){
			r=s.substring(0,charCut);
		}else if(wordCut!=null && wordCut>0 && s.length>wordCut){
			var arr=s.split(" ");
			if(arr.length>0){
				if(ignoreWordOrder) arr=arr.sort();
				r=arr[0];
				for(var i=1;i< arr.length && i<wordCut;i++){
					r+=" "+ arr[i];
				}
				//r=arr.join(" ");
			}
		}
		
		if(ignoreWordOrder && ( wordCut==null || wordCut==0) ) {
			var arr=s.split(" ");
			if(arr.length>0){
				arr=arr.sort();
				r=arr.join(" ");
			}
			
		}
	}
	return r;
}

var saveSynonymsXXXArrDR=null;
var acronymsX1=null;
function cleanTextSynonyms(s){
	var r=s;
	if(saveSynonymsXXXArrDR==null){
		saveSynonymsXXXArrDR=getsaveSynonymsXXX().split("###");
		for(var i=0;i<saveSynonymsXXXArrDR.length;i++){
			if(saveSynonymsXXXArrDR[i]!="") {
				saveSynonymsXXXArrDR[i]=saveSynonymsXXXArrDR[i].split(/\n/ig);
			}else{
				saveSynonymsXXXArrDR[i]=null;
			}
		}
		var acronyms=new Array();
		for(var j=0;j<saveSynonymsXXXArrDR.length;j++){
		
			for(var i=0;i<saveSynonymsXXXArrDR[j].length;i++){
				if(j==0){
					var a1=saveSynonymsXXXArrDR[j][i].split("~");
					if(a1.length==2){
						acronyms[a1[0]]=a1[1];//
					}
				}else{
					acronyms[saveSynonymsXXXArrDR[j][i]]="";
				}
			}
		}
		
		acronymsX1=acronyms;
	}
	if(acronymsX1!=null){
			var arr=$.trim(s.toLowerCase().replace(/[\.\,\"\'\$\^\&\*\(\)\!\~\#\%\\\/\+\-\;\:]+/g," ")).split(/[ ]+/);
			if(arr.length>0){
				var arr2=new Array();
				for(var i=0;i<arr.length;i++){
					var res=acronymsX1[arr[i]];
					if(res!=null){
						arr2.push(res);
					}else{
						arr2.push(arr[i]);
					}
				}
				arr2=arr2.sort();
				r=arr2.join(" ");
			}
	}
	
	
	return $.trim(r);

} 

function setGraySel(obj){
	if($(obj).val()!=""){
		$(obj).css({"color":"#000000;"});
	}else{
		$(obj).css({"color":"#aaaaaa;"});
	}
}
  
  function getsaveSynonymsXXX(){
  	var saveSynonymsXXX=getLS1("saveSynonymsXXX");
  	if(saveSynonymsXXX==null || saveSynonymsXXX=="X"){
  		saveSynonymsXXX="abigail~abig\nabraham~abr\nagnes~agn\nalexander~alex\nalfred~alf\nalphonse~alf\nambrose~amb\nandrew~and\nandy~and\nanna~an\nanne~anna\nanthony~ant\narthur~art\naugustus~aug\nbarb~bar\nbarbara~bar\nbartholomew~bart\nbeatrice~bett\nbenjamin~ben\nbenny~ben\nbetty~bett\nbridget~brid\ncatherine~cath\ncathy~cath\ncharles~chas\nchristian~chr\nchristian~xtian\nchristopher~xpr\nchristopher~xtopher\nclement~clem\nconstance~const\ncornelius~corn\ndaniel~danl\ndave~dav\ndavid~dav\ndeborah~deb\ndennis~den\ndorothy~dy\ndouglas~doug\nedmund~edm\nedward~edr\nedward~edw\neleanor~elnr\nelizabeth~eliz\nesther~esth\nezekiel~ezek\nfrancis~fs\nfranco~froo\nfrederick~fred\ngabriel~gab\ngeoffrey~geof\ngeorge~geo\ngodfrey~godf\ngregory~greg\nhannah~han\nhelen~hel\nhenry~hen\nhenry~hy\nherbert~herb\nhospital~hosp\nisaac~is\nisabel~isb\njames~jab \njac~jab\njas~jab\nJeffrey~jeff\njeremiah~jer\njohn~jno\nioh~jno\njonathan~jon\njoseph~jos\njoshua~josh\njosiah~josh\njudith~jud\nkatherine~kath\nkathy~kath\nlaurence~lau\nlawrence~lawr\nleonard~leon\nlydia~lyd\nmargaret~margt\nmary~my\nmatthew~matt\nmatthias~math\nmaurice~mau\nmedical center~mc\nmichael~mike\nmillicent~mill\nnathaniel~nath\nnicholas~nich\nnicholas~nics\nnorman~norm\noliver~ol\npamela~pam\npatricia~pat\npatrick~pat\npenelope~pen\npeter~pet\nphilip~phil\nphineas~phin\nphyllis~phyl\npriscilla~prisc\nprudence~pru\nrachel~rach\nraymond~ray\nrebecca~reb\nreginald~reg\nrichard~ric\nrichard~richd \nrobert~robt\nroger~rog\nsamuel~saml\nsamanta~sam\nsandra~sand\nsandy~sand\nsarah~sar\nsimon~sim\nsolomon~sol\nstephen~ste\nsusanna~sue\nsus~sue\nsusan~sue\nsusna~sue\nsylvester~silv\ntechnologies~tech\ntheodore~theo\nthomas~thos\nthomas~tom\ntimothy~tim\nunited states~usa\nuniversity~u\nursula~urs\nvalentine~val\nvincent~vinc\nwalter~walt\nwilliam~bill\nwilliam~gul\nwilliam~wm\nwinifred~win\nzachariah~zach###the\ndept\nle\nla\nministry\ndepartment\nof\nand\noffice\namp###co\ncompany\ninc\nincorporated\nltd\nlimited\nllc\ncorporation\ncorp\nplc\ngmbh\npartnership";
  	}
  	return saveSynonymsXXX;
  }
  function openSynonymsPupup(){

  	var saveSynonymsXXXArr=getsaveSynonymsXXX().split("###");
  var message='<div id="tabsSynonyms">'+
'  <ul>'+
'    <li><a href="#tabs-1">Acronyms / Synonyms</a></li>'+
'    <li><a href="#tabs-2">Prefixes</a></li>'+
'	<li><a href="#tabs-3">Suffixes</a></li>'+
'  </ul>'+
'  <div id="tabs-1">'+
//'  <p>Acronyms / Synonyms:</p>'+
'    <textarea id="Acronyms_Synonyms" name="Acronyms_Synonyms" style="width:100%;height:290px;overflow:auto;">'+saveSynonymsXXXArr[0]+'</textarea>'+
'	<p>Format: long text~short text NEW-LINE</p>'+
'  </div>'+
'  <div id="tabs-2">'+
//'  <p>Prefixes:</p>'+
'    <textarea id="Prefixes" name="Prefixes" style="width:100%;height:290px;overflow:auto;">'+saveSynonymsXXXArr[1]+'</textarea>'+
'	<p>Format: Prefix NEW-LINE</p>'+
'  </div>'+
'  <div id="tabs-3">'+
//'    <p>Suffixes:</p>'+
'	<textarea id="Suffixes" name="Suffixes" style="width:100%;height:290px;overflow:auto;">'+saveSynonymsXXXArr[2]+'</textarea>'+
'	<p>Format: Suffix NEW-LINE</p>'+
'  </div>'+
'</div>';
 	 messagePopupAlert(message,"Acronyms/ Synonyms/ Prefixes/ Suffixes",{
		text: "Save Settings", 
		click: function() { 
			saveSynonyms();
			
			jQuery( this ).dialog( "close" ); 
		} 
		},500,550);
 	 $("#tabsSynonyms").tabs();

  }
  function saveSynonyms(){
  	var saveSynonymsXXX=$("#Acronyms_Synonyms").val()+"###"+$("#Prefixes").val()+"###"+$("#Suffixes").val();
  	saveSynonymsXXX=saveSynonymsXXX.replace(/>/ig,"&gt;").replace(/</ig,"&lt;");
  	setLS1("saveSynonymsXXX",saveSynonymsXXX);
  }
  
  
  function getsaveMappingXXX(){
  	var saveMapping=getLS1("saveMapping~"+findmatchstableX1);
  	if(saveMapping==null || saveMapping=="X"){
  		saveMapping="";
  	}
  	return saveMapping;
  }
  
  function openSavedMapping(){
  
    	var saveMappingXXXArr=getsaveMappingXXX().split("###");
    	var mapstrX="";
    	for(var i=0;i<saveMappingXXXArr.length;i++){
    		var sel1=saveMappingXXXArr[i].split("~~~");
    		if(sel1.length==2){
    			mapstrX+='<option style="padding:6px;" value="'+sel1[1]+'">'+sel1[0]+'</option>';
    		}
    	}
  var message='<select id="selFielMappings" size="20" style="width: 100%;height: 95%;">'+
mapstrX+
'</select>';
 	 messagePopupAlert(message,"Load / Save Field Mappings",[{
		text: "Save New", 
		click: function() { 
			newMapping();
			
			//jQuery( this ).dialog( "close" ); 
		}},
		{
		text: "Load Selected", 
		click: function() { 
			loadMapping();
			
			jQuery( this ).dialog( "close" ); 
		}}
		,
		{
		text: "Delete Selected", 
		click: function() { 
			deleteMapping();
			
			//jQuery( this ).dialog( "close" ); 
		}}
		
		],500,550);
 	 $("#tabsSynonyms").tabs();
  }
  
  function newMapping(){
  	var newTemplateName=prompt("Please enter a mapping name / description", "My Mapping");
  	if(newTemplateName!=null){
	  	var json={};
	  	$(".fieldSelection input[type='text'][name],.fieldSelection select[name],.fieldSelection textarea[name]").each(function(){
	  		json[$(this).attr("name")]=$(this).val();
	  	});
	  	$("#selFielMappings").append('<option style="padding:6px;" value="'+escape(JSON.stringify(json))+'">'+newTemplateName+'</option>');
	  	saveMapping();
  	}
  }
  function loadMapping(){
  		var mappings=unescape($("#selFielMappings").val());
  		if(mappings!=null && mappings!="null"){
	  		var json=JSON.parse(mappings);
	  		for (var key in json) {
	  			$(".fieldSelection [name='"+key+"']").val(json[key]).change();
	  		}
	  		
  		}else{
  			alert("Please select a field-mapping");
  		}
  		
  }
  
  function saveMapping(){
  		var mappings="";
  		$("#selFielMappings option").each(function(){
  			mappings+=$(this).text()+"~~~"+($(this).attr("value"))+"###";
  		});
  		
  		setLS1("saveMapping~"+findmatchstableX1,mappings);
  }
  function deleteMapping(){
  		var selIndex=$("#selFielMappings")[0].selectedIndex;
  		if($("#selFielMappings")[0].selectedIndex>=0 ){
  			if(confirm("Are you sure you want to delete the selected row?")){
  				$($("#selFielMappings")[0][selIndex]).remove();
  				saveMapping();
  			}
  		}else{
  			alert("Please select a field-mapping");
  		}
  		
  }
  function loadFindIDSettings(){
  	
  }
  /* FindMatchs end*/
  
  
  
  function saveTextAsCSV(resultContent,fileNamePrefix){
  	 var text = resultContent;
				  var date1=new Date();
			  var filename = fileNamePrefix+"_"+date1.getDate()+"_"+(date1.getMonth()+1)+"_"+date1.getFullYear()+"_"+date1.getHours()+"_"+date1.getMinutes()+"_"+date1.getSeconds()+".csv";
			  var blob = new Blob([text], {type: "text/plain;charset=utf-8"});
			  saveAs(blob, filename+"");
  }
  
  /******saveas******/
  
  /*! @source http://purl.eligrey.com/github/FileSaver.js/blob/master/FileSaver.js */
var saveAs=saveAs||function(e){"use strict";if(typeof e==="undefined"||typeof navigator!=="undefined"&&/MSIE [1-9]\./.test(navigator.userAgent)){return}var t=e.document,n=function(){return e.URL||e.webkitURL||e},r=t.createElementNS("http://www.w3.org/1999/xhtml","a"),o="download"in r,a=function(e){var t=new MouseEvent("click");e.dispatchEvent(t)},i=/constructor/i.test(e.HTMLElement)||e.safari,f=/CriOS\/[\d]+/.test(navigator.userAgent),u=function(t){(e.setImmediate||e.setTimeout)(function(){throw t},0)},s="application/octet-stream",d=1e3*40,c=function(e){var t=function(){if(typeof e==="string"){n().revokeObjectURL(e)}else{e.remove()}};setTimeout(t,d)},l=function(e,t,n){t=[].concat(t);var r=t.length;while(r--){var o=e["on"+t[r]];if(typeof o==="function"){try{o.call(e,n||e)}catch(a){u(a)}}}},p=function(e){if(/^\s*(?:text\/\S*|application\/xml|\S*\/\S*\+xml)\s*;.*charset\s*=\s*utf-8/i.test(e.type)){return new Blob([String.fromCharCode(65279),e],{type:e.type})}return e},v=function(t,u,d){if(!d){t=p(t)}var v=this,w=t.type,m=w===s,y,h=function(){l(v,"writestart progress write writeend".split(" "))},S=function(){if((f||m&&i)&&e.FileReader){var r=new FileReader;r.onloadend=function(){var t=f?r.result:r.result.replace(/^data:[^;]*;/,"data:attachment/file;");var n=e.open(t,"_blank");if(!n)e.location.href=t;t=undefined;v.readyState=v.DONE;h()};r.readAsDataURL(t);v.readyState=v.INIT;return}if(!y){y=n().createObjectURL(t)}if(m){e.location.href=y}else{var o=e.open(y,"_blank");if(!o){e.location.href=y}}v.readyState=v.DONE;h();c(y)};v.readyState=v.INIT;if(o){y=n().createObjectURL(t);setTimeout(function(){r.href=y;r.download=u;a(r);h();c(y);v.readyState=v.DONE});return}S()},w=v.prototype,m=function(e,t,n){return new v(e,t||e.name||"download",n)};if(typeof navigator!=="undefined"&&navigator.msSaveOrOpenBlob){return function(e,t,n){t=t||e.name||"download";if(!n){e=p(e)}return navigator.msSaveOrOpenBlob(e,t)}}w.abort=function(){};w.readyState=w.INIT=0;w.WRITING=1;w.DONE=2;w.error=w.onwritestart=w.onprogress=w.onwrite=w.onabort=w.onerror=w.onwriteend=null;return m}(typeof self!=="undefined"&&self||typeof window!=="undefined"&&window||this.content);if(typeof module!=="undefined"&&module.exports){module.exports.saveAs=saveAs}else if(typeof define!=="undefined"&&define!==null&&define.amd!==null){define("FileSaver.js",function(){return saveAs})}




function checkSyntaxX(div1,table1,v2SOQL,checkSyntaxDiv){
	if($(div1).html().indexOf("Calculating")>-1){
		setTimeout(function(){
			if($(div1).html().indexOf("Calculating")>-1){
				$(div1).html("");
			}
		},45000);
		return;
	}

	$(div1).html("<span style='color:#999999;'>Calculating...</span>");
	
	var v2SOQLCOND=$(v2SOQL).val(); 
	
	var queryZZZ="SELECT count(id) countRowsx1 FROM "+table1+" "+(v2SOQLCOND!=""?" where "+v2SOQLCOND:"")+" "; 
		
	Visualforce.remoting.Manager.invokeAction( 
		remoteTotMethod,//remoteQueryAjax2SC, //countRowsx1==c2
		queryZZZ, 
		function(result, event){ 
		$(div1).html("");
		$(checkSyntaxDiv).html("");
		if (event.status && result!=null && result.countRowsx1!=null) { 
			var innerHtml = ''; 
			var records=result; 
			//alert(records)
			records.c2=records.countRowsx1;
			$(div1).html("<span id='totalDupes1'>Total Records: </span> <span id='totalDupes2'>" +records.c2+"</span>");
			$(checkSyntaxDiv).html('<span style="color:#00AA00;font-weight:bold;margin-left: 7px;display:inline-block;">Syntax OK!</span>');
		} else if (event.type === 'exception') { 
		if(event.message!=null && ((event.message+"").indexOf("Logged in")>-1 || (event.message+"").indexOf("Refresh page")>-1)){ 
		self.location=self.location; 
		}else if(event.message!=null && (event.message+"").indexOf("Unable to connect")==-1){
		 	$(checkSyntaxDiv).html('<div style="color:#AA0000;font-weight:bold;margin: 15px 5px;">Syntax Error: '+event.message+' </div>');
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


