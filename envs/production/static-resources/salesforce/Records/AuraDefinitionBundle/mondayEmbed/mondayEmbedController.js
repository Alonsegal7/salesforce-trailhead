({
    onRender : function(component, event, helper){
       var frame = document.getElementById("monday-embed");
       if(frame){
           console.log("mondayEmbed - onRender", frame.src);     
       }
       console.log("mondayEmbed - setTimeout");  
       var fullURL='';
       var initialURL =component.get('v.iframeUrl');
       var dashId=component.get('v.dashboardId');
       var boardId=component.get('v.boardId');
       var viewId=component.get('v.viewId');
       var fieldAPI=component.get('v.itemIdFieldAPI');
       var itemId=component.get('v.itemId');
       var filterAPI=component.get('v.filterFieldAPI');
       var filterValue=component.get('v.filterValue');
       var itemView=component.get('v.itemView');
       
       fullURL=initialURL;
       //DASHBOARD
       if(dashId!=undefined && dashId!=''){
            fullURL+='/overviews/' + dashId;
        //BOARD
       }else if(boardId!=undefined && boardId!=''){
            fullURL+='/boards/' + boardId;
            if(viewId!=undefined && viewId!=''){
                    fullURL+='/views/' + viewId;
            }
            //ITEMS
            var item='';
            if(fieldAPI!=undefined && fieldAPI!=''){
                var key = 'v.simpleRecord.'+fieldAPI;
                var value = component.get(key);
                if(value!=undefined){
                    item=value;
                }  
            } else if (itemId!=undefined&&itemId!=''){
                item=itemId;
            }
            if(item!=''){
                console.log("mondayEmbed - onRender value of item id", item);
                if(itemView){
                    fullURL=initialURL+'/embedded_item_view/item_view/'+item;
                }else{
                    fullURL+='/pulses/'+item ;
                }
            }
            //FILTERS
            if(filterAPI!=undefined && filterAPI!=''){
                var key2 = 'v.simpleRecord.'+filterAPI;
                var value2 = component.get(key2);
                console.log("mondayEmbed - onRender value filter field", value2);
                if(value2!=undefined){
                    var encodedValue=encodeURIComponent(value2);
                    fullURL+='?term='+encodedValue;
                }
            }else if (filterValue!=undefined&&filterValue!=''){
                var encodedValue2=encodeURIComponent(filterValue);
                    fullURL+='?term='+encodedValue2;
            }
        }
        component.set('v.fullURL', fullURL); 
        console.log("mondayEmbed - Full URL", fullURL);  
        
       setTimeout(function(){
           var frame = document.getElementById("monday-embed");
           console.log("mondayEmbed - setTimeout");                    
           if(frame){
               if(frame.src == 'https://monday.monday.com/boards/'){
                   frame.src=frame.src;
                   console.log("monday embed - refresh iframe patch", frame.src);                    
                  }
           }
       }, 1400);
   }
})