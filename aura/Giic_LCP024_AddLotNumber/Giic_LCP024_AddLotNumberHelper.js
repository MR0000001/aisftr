({
	init : function(component, event, helper) {
        console.log('MAPPA = '+JSON.stringify(component.get("v.allData")));
        var puchaseOrderLineId = component.get("v.purchaseOrderLineId");
        var maps = {};
        var lotMap = {};
        maps = component.get("v.allData"); 
        lotMap = component.get("v.totalLotMap"); 
        console.log('IN init con lotNumber-quantity = '+JSON.stringify(lotMap));
        var custs = [];
        var prepopulate = false;
        
        for(var key in maps){
            if( key == component.get("v.purchaseOrderLineId")){
                prepopulate=true;
                var listaValori = maps[key];
                console.log('seriali gia messi = '+JSON.stringify(listaValori));
            }
        }
        
        if(prepopulate){
            for(var i = 0; i < listaValori.length; i++){
                    console.log('aaa = '+JSON.stringify(lotMap[puchaseOrderLineId][listaValori[i]]));
              		custs.push({value: listaValori[i], key: i, quantity: lotMap[puchaseOrderLineId][listaValori[i]]  }); 
            }
            var mancanti = component.get("v.numberOfSerialToShow") - listaValori.length ;
            for(var j = listaValori.length; j < listaValori.length+mancanti; j++){
              		custs.push({value: '', key: j, quantity: 0}); 
            }
            
        }else{
              	for(var i = 0; i < component.get("v.numberOfSerialToShow"); i++){
                    custs.push({value: '', key: i, quantity: 0}); 
              	}
        }
             
             
         
        
        component.set("v.serialNumberList",custs); 
        if(component.get("v.numberOfSerialToShow")==0){
            component.set("v.showError",true);
            component.set("v.errorMessage" , 'Open quantity is 0');
        }
        console.log('serialNumberList = '+component.get("v.serialNumberList"));
		
	},
    
     showToast : function(component, event, helper, message, type) {
        component.find('notifLib').showToast({
            "title": message,
            "message": '',
            "variant": type
        });
    }
    
})