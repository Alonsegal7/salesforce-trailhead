var stageDependantXXX=false;
var stageDependant=new Array();
var fullStageDP="";//for Mass updates
initDepPullDown();
$(document).ready(function(){
initDepPullDown();
   $(".muf1.stagename .iTb").change(depandentByStage2);
   $(".muf1.forecastcategoryname .iTb").change(depandentByForecastcategoryname2);
$("body").bind("OnRenderDone",function(){

//set depenadant fields
if(isEditMode1){
    $(".inpSt_stagename").change(depandentByStage1);
	$(".inpSt_forecastcategoryname").change(depandentByForecastcategoryname1);
}

   $(".muf1.stagename .iTb").change(depandentByStage2);
   $(".muf1.forecastcategoryname .iTb").change(depandentByForecastcategoryname2);
	if(fullStageDP!="" && $(".muf1.stagename").attr("rp")==null){
		$(".muf1.stagename .iTb").html(fullStageDP);
		$(".muf1.stagename").attr("rp","1");
	}
});
});
function initDepPullDown(){
	try{
	var query1="SELECT MasterLabel,ApiName,ForecastCategoryName,DefaultProbability,Id FROM OpportunityStage where isactive=true order by SortOrder asc";
if( stageDependant.length==0){
stageDependantXXX=true;
 Visualforce.remoting.Manager.invokeAction(
                remoteQueryAjax2,
                query1, 
                function(result, event){
                    if (event.status && result!=null) {
    
//                        createGarphsDataFilter(field1,filterIdSpan,fieldCalss1,filterObjShowType,amountFleild,amountFName,colName,filterCount1,hasGeo,result,"1",autoPIn);
                       // var result = sforce.connection.query("Select MasterLabel,ForecastCategoryName,DefaultProbability,Id from OpportunityStage order by SortOrder asc");
					   
  var records = result;//.getArray("records");
 //alert(records.length);
 fullStageDP="<option value=''>--None--</option>";
  for (var i=0; i< records.length; i++) {
    var record = records[i];
    fullStageDP+="<option value='"+record.ApiName+"'>"+record.MasterLabel+"</option>";
	if(stageDependant[record.MasterLabel]==null){
		stageDependant[record.MasterLabel]="";
	}
	if(stageDependant[record.ForecastCategoryName]==null){
		stageDependant[record.ForecastCategoryName]="";
	}
	stageDependant[record.MasterLabel]+="~"+record.ForecastCategoryName;
	stageDependant[record.ForecastCategoryName]+="~"+record.MasterLabel;
	
	stageDependant[record.ForecastCategoryName+"~"+record.MasterLabel]=record.DefaultProbability;
	stageDependant[" ~"+record.MasterLabel]=record.DefaultProbability;
  }
  
// $(".muf1.stagename .iTb").html(fullStageDP);
                      
                     } else if (event.type === 'exception') {
                        if(event.message!=null && ((event.message+"").indexOf("Logged in")>-1 || (event.message+"").indexOf("Refresh page")>-1)){
                            self.location=self.location;
                        }else if(event.message!=null && (event.message+"").indexOf("Unable to connect")==-1){
                           // if($("body:visible").size()>0)alert("An error has occurred: "+event.message);
                        }
                    } else {
                        //self.location=self.location;
                        // $("#"+filterIdSpan+" .availVals").html("");
                        //alert(1);
                    }
                }, 
                {escape: true,buffer:true}
            );
}
}catch(e){
//alert(e);
}
}
function depandentByStage1(){
	return depandentByStage(this,"tr:first",".inpSt_forecastcategoryname",".inpSt_probability");
}
function depandentByForecastcategoryname1(){
	return depandentByForecastcategoryname(this,"tr:first",".inpSt_stagename",".inpSt_probability");
}
function depandentByStage2(){
	return depandentByStage(this,"table:first",".muf1.forecastcategoryname .iTb",".muf1.probability .iTb");
}
function depandentByForecastcategoryname2(){
	return depandentByForecastcategoryname(this,"table:first",".muf1.stagename .iTb",".muf1.probability .iTb");
}
function depandentByStage(origin,contParentSel,secondFieldSel,probabilitySel){
	var inpSt_stagename=$(origin);
	var inpSt_forecastcategoryname=$($(origin).parents(contParentSel).find(secondFieldSel));//.inpSt_forecastcategoryname
	//alert(stageDependant[inpSt_stagename.val()]+ " "+inpSt_forecastcategoryname.val());
	var inpSt_stagename_val=inpSt_stagename.val();
	if(inpSt_stagename_val==null || inpSt_stagename_val==""){
		inpSt_stagename_val=" ";
	}
	var stageDependant_vals1=stageDependant[inpSt_stagename_val];
	var inpSt_forecastcategoryname_val=inpSt_forecastcategoryname.val();
	if(inpSt_forecastcategoryname_val==null || inpSt_forecastcategoryname_val==""){
		inpSt_forecastcategoryname_val=" ";
	}
	if(stageDependant_vals1!=null && stageDependant_vals1.indexOf(inpSt_forecastcategoryname_val)==-1){
		inpSt_forecastcategoryname.val(stageDependant_vals1.split("~")[1]);
	}
		inpSt_forecastcategoryname.find("option").each(function(){
			if(stageDependant_vals1!=null && stageDependant_vals1.indexOf($(this).text())==-1){
				$(this).attr("disabled","disabled");
			}else{
				$(this).removeAttr("disabled");
			}
			
		});
	
	setProbabilityX(origin,inpSt_stagename_val,inpSt_forecastcategoryname_val,probabilitySel,contParentSel);
}
function depandentByForecastcategoryname(origin,contParentSel,secondFieldSel,probabilitySel){
	var inpSt_forecastcategoryname=$(origin);
	var inpSt_stagename=$($(origin).parents(contParentSel).find(secondFieldSel));//.inpSt_stagename
	var inpSt_stagename_val=inpSt_stagename.val();
	if(inpSt_stagename_val==null || inpSt_stagename_val==""){
		inpSt_stagename_val=" ";
	}
	var inpSt_forecastcategoryname_val=inpSt_forecastcategoryname.val();
	if(inpSt_forecastcategoryname_val==null || inpSt_forecastcategoryname_val==""){
		inpSt_forecastcategoryname_val=" ";
	}
	var stageDependant_vals1=stageDependant[inpSt_stagename_val];
	inpSt_forecastcategoryname.find("option").each(function(){
			if(stageDependant_vals1!=null && stageDependant_vals1.indexOf($(this).text())==-1){
				$(this).attr("disabled","disabled");
			}else{
				$(this).removeAttr("disabled");
			}
			
		});
	if(stageDependant[inpSt_forecastcategoryname_val]!=null && stageDependant[inpSt_forecastcategoryname_val].indexOf(inpSt_stagename_val)==-1){
		inpSt_stagename.val(stageDependant[inpSt_forecastcategoryname_val].split("~")[1]);
	}
	setProbabilityX(origin,inpSt_stagename_val,inpSt_forecastcategoryname_val,probabilitySel,contParentSel);
}
function setProbabilityX(origin,inpSt_stagename_val,inpSt_forecastcategoryname_val,probabilitySel,contParentSel){
	var inpSt_probability=$($(origin).parents(contParentSel).find(probabilitySel));
	var inpSt_probability_stageDependant_val= stageDependant[inpSt_forecastcategoryname_val+"~"+inpSt_stagename_val];
	if(inpSt_probability_stageDependant_val!=null && inpSt_probability_stageDependant_val!=""){
		inpSt_probability.val(stageDependant[inpSt_forecastcategoryname_val+"~"+inpSt_stagename_val]);
	}
}