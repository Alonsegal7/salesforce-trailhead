 var overwriteObj3="01u";
var overwriteObjConf="pricebookentryMC";


function getParameterByNameLUOV( name ,url){
  name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
  var regexS = "[\\?&]"+name+"=([^&#]*)";
  var regex = new RegExp( regexS );
  var results = regex.exec( url );
  if( results == null )
    return "";
  else
    return decodeURIComponent(results[1].replace(/\+/g, " "));
}

var lookupPickOrig=null;

    if(lookupPickOrig==null){
        lookupPickOrig= openLookup;//save old function if needed
    }
    openLookup=function(a, b,c, d,e,f,g,l){//overwrite with your custom code
    //alert(a+"~"+b+"~"+c+"~"+d+"~"+e+"~"+f+"~"+g+"~"+l);
    var ax=a;
    if(ax.indexOf("lktp="+overwriteObj3)>-1){
        var lknm=getParameterByNameLUOV("lknm",ax);
        var lkfm=getParameterByNameLUOV("lkfm",ax);
        var lksrch=getParameterByNameLUOV("lksrch",ax);
        //alert(b+"~"+c+"~"+d+"~"+e+"~"+f+"~"+g+"~"+l);
        ax="/apex/GenericLookupControl?"+(ax.split("?")[1]+"&frm="+escape(lkfm)+"&txt="+escape(lknm)+d)+"&conf="+overwriteObjConf+"&hideNewObjTab=1";
//        lookupPickOrig(ax, b,c, d,e,f,g,l);
        window.open(ax,"_blank","width=690,height=690");
    }else{
        lookupPickOrig(ax, b,c, d,e,f,g,l);
    }
    //put your code here
    }
	
