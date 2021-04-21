({
    onRender : function(component, event, helper){
        var frame = document.getElementById("monday-embed");
        if(frame){
           console.log("mondayEmbed - onRender", frame.src);     
        }
        var fullURL='';
        console.log("mondayEmbed - v.currentUser "+ component.get('v.currentUser'));  

       //var initialURL =component.get('v.iframeUrl');
       var slugName =component.get('v.accountSlugName');
       var slugNameAPI =component.get('v.accountSlugNameAPI');
       var dashId=component.get('v.dashboardId');
       var boardId=component.get('v.boardId');
       var boardIdAPI=component.get('v.boardIdFieldAPI');
       var viewId=component.get('v.viewId');
       var fieldAPI=component.get('v.itemIdFieldAPI');
       var itemId=component.get('v.itemId');
       var filterAPI=component.get('v.filterFieldAPI');
       var filterValue=component.get('v.filterValue');
       var itemView=component.get('v.itemView');
       var userFieldAPI=component.get('v.userFieldAPI');
       var userFilterAPI=component.get('v.userFilterAPI');
       
       
       //fullURL=initialURL;
       
       //MONDAY ACCOUNT
       if(slugNameAPI!=undefined && slugNameAPI!=''){
            var keySlug = 'v.simpleRecord.'+slugNameAPI;
            var valueSlug = component.get(keySlug);
            if(valueSlug!=undefined){
                fullURL='https://'+valueSlug+'.monday.com';
            }
        }else if(slugName!=undefined && slugName!=''){
                fullURL='https://'+slugName+'.monday.com';
       }else{
            fullURL="https://monday.monday.com";
       }
       console.log("mondayEmbed - userPersonalBoard: "+userPersonalBoard); 
       //DASHBOARD
       if(dashId!=undefined && dashId!=''){
            fullURL+='/overviews/' + dashId;
        //BOARD
       }else if(boardId!=undefined && boardId!=''||boardIdAPI!=undefined && boardIdAPI!=''||userFieldAPI!=undefined && userFieldAPI!=''){
            var dynamicBoard='';
            var userPersonalBoard='';  
            if(userFieldAPI!=undefined && userFieldAPI!=''){//PERSONAL BOARD FROM USER LEVEL
                var keyUser = 'v.currentUser.'+userFieldAPI;
                var valueUser = component.get(keyUser);
                if(valueUser!=undefined){
                    userPersonalBoard=valueUser;
                }
                fullURL+='/boards/' + userPersonalBoard;
            }else if(boardId!=undefined && boardId!=''){
                fullURL+='/boards/' + boardId;
            }else if(boardIdAPI!=undefined && boardIdAPI!=''){
                var key0 = 'v.simpleRecord.'+boardIdAPI;
                var value0 = component.get(key0);
                if(value0!=undefined){
                    dynamicBoard=value0;
                }
                fullURL+='/boards/' + dynamicBoard;
            }
            //VIEW
            if(viewId!=undefined && viewId!=''){
                    fullURL+='/views/' + viewId;
            }
            //ITEM
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
            //FILTER
            var userFilter='';  
            if(userFilterAPI!=undefined && userFilterAPI!=''){//PERSONAL BOARD FROM USER LEVEL
                var keyUserFilter = 'v.currentUser.'+userFilterAPI;
                var valueUserFilter = component.get(keyUserFilter);
                if(valueUserFilter!=undefined){
                    userFilter=valueUserFilter;
                }
                fullURL+='?term='+userFilter;
            }else if(filterAPI!=undefined && filterAPI!=''){
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