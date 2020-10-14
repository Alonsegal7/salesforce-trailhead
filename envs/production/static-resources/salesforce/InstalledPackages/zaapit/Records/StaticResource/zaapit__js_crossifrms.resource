 function openIDs1Ifrms(openCOlumnId,iframeId,clicktabNun){
 var ids1="";
 $("."+openCOlumnId).each(function(){
	ids1="~"+$(this).attr("afld")+ids1;
 });
 if(ids1!=""){
	ids1=ids1.substring(1);
 }
 var src1=parent.$("#"+iframeId).attr("src1");
 var src2=parent.$("#"+iframeId).attr("src2");
 if(src2==null){
	parent.$("#"+iframeId).attr("src2", src1);
 }else{
	src1=src2;
 }
 src1=src1.replace("id=&","");
 src1=src1+"&id="+escape(ids1);
	parent.$("#"+iframeId).attr("src1", src1);
	parent.$("#"+iframeId).attr("src", src1);
	if(clicktabNun!=null){
		parent.tabs.tabs({active:(clicktabNun)});
	}
		parent.loadingSH();
 }
 /*
 $(document).ready(function(){
	var selfino=self;
	parent.$("#ui-id-3").click(function(){
		
		selfino.openIDs1Ifrms("oSt_lead-name",'zaapit_tb_GeneralWL11',null);
	});
	parent.$("#ui-id-2").click(function(){
		
		selfino.openIDs1Ifrms("oSt_lead-name",'zaapit_tb_GeneralWL12',null);
	});
 });
 */