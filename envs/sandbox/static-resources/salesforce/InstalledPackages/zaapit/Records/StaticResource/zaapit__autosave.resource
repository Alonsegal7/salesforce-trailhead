var autoSaveAfterX=false;
var autoWarningOnEdit=false;
var numberOfMinsAutoSave=3;
var saveTimeInXAutoSave=(numberOfMinsAutoSave)*60*1000;

function fixInputs(){

	var url1AutoSave=self.location+"";
	if($qnb("#editPage").size()==1 && (url1AutoSave.indexOf("/e?")>-1 || (url1AutoSave.indexOf("/e")>url1AutoSave.length -3))){
		$qnb("#editPage .bEditBlock .pbBody h3").each(function(){
			var t1=$qnb(this).text();
			if(t1.indexOf("Edit Mode")>-1){
				autoWarningOnEdit=t1.indexOf("AutoWarn")>-1;
				autoSaveAfterX=t1.indexOf("AutoSave")>-1;
				var HideHeader=t1.indexOf("Hide")>-1;
				if(HideHeader){
					$qnb(this).parents(".pbSubheader:first").hide(); 
				}
				if(t1.indexOf("-")>-1){
					try{
					//alert(t1.split("-")[1].split(":")[0]);
					numberOfMinsAutoSave=new Number($qnb.trim(t1.split("-")[1].split(":")[0]));
					if(saveTimeInXAutoSave>0){
						saveTimeInXAutoSave=(numberOfMinsAutoSave)*60*1000;	
					}
					}catch(e){}
				}
			}
		});
	   
	}

    if(autoSaveAfterX){
        $qnb("#editPage input,#editPage textarea,#editPage select").click(resetCounter).keyup(resetCounter);
        $qnb("body").mousemove(bodyResetAutoSave);
    }
    if(autoWarningOnEdit){
		$qnb("#editPage input[type='button'],#editPage input[type='submit'],#editPage button").click(function(){
			wasChnagedAutoSave=false;
		});
        window.onbeforeunload = function(e){
            if(wasChnagedAutoSave){
                var msg = "\n\nYou haven't saved your work!\nDo you want to leave this page anyway?\n\n";
                e = e || window.event;
        
                if(e)
                    e.returnValue = msg;
                return msg;
            }
        }
    }
}
function bodyResetAutoSave(){
    if(wasChnagedAutoSave){
        resetCounter();
    }
}
var saveThreadAutoSave=null;
var wasChnagedAutoSave=false;
var StartTimeAutoSave=null;
var DueTimeAutoSave=null;
function resetCounter(){
    wasChnagedAutoSave=true;
    if(saveThreadAutoSave!=null){
        window.clearTimeout(saveThreadAutoSave);
    }
    StartTimeAutoSave=new Date().getTime();
    DueTimeAutoSave=StartTimeAutoSave+saveTimeInXAutoSave;
    saveThreadAutoSave=window.setTimeout(resetCounterXT1,1000);
}
function resetCounterXT1(){
    StartTimeAutoSave=new Date().getTime();
    var savingin=DueTimeAutoSave-StartTimeAutoSave;
    if(savingin>0){
		
        $qnb("#autoSaveTopX1").show();
        var seconds=Math.round((savingin/1000)%60 -0.5);
        if(seconds<10){
            seconds="0"+seconds;
        }
        $qnb("#autoSaveTimeX1").html(Math.round(savingin/60000-0.5)+":"+seconds);
        saveThreadAutoSave=window.setTimeout(resetCounterXT1,1000);
    }else{
        $qnb("#editPage input[name='save']:first").click();
    }
}
