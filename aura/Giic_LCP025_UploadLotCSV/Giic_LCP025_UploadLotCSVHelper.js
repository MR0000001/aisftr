({
	
    

    cleanData : function(component, event, helper) {
        component.set("v.csvString", null);
        component.set("v.csvObject", null);
        var cmpEvent = $A.get("e.c:setBooleanParam_evt");
        cmpEvent.setParams({
            "booleano" : true
        }); 
        cmpEvent.fire();
        
    },
    
    
    createCSVObject : function(component,  event, helper) {
        var csv = component.get("v.csvString");
        if(csv != null) {
        var action = component.get('c.getCSVObject');
        action.setParams({
            csv_str : csv
        });
        action.setCallback(this, function(response) {
        var state = response.getState();
            
            if(state == "SUCCESS") {
                var lotMap = {};
                var listaLot = [];
                var res = response.getReturnValue();
                component.set("v.csvObject", res);
                for ( var i = 0; i < (res.lines).length; i++ ) {
                    if(res.lines[i][1]!=0){
                    	lotMap[res.lines[i][0]]  = res.lines[i][1] ;
                        listaLot.push(res.lines[i][0]);
                    }
                }
                console.log('map l-q = '+JSON.stringify(lotMap) );
                component.set("v.allSerials", listaLot);
                helper.shootRecords(component,event,helper,lotMap);
                component.set("v.showSpinner" , false);
            }
            
        });
        $A.enqueueAction(action);
            
        }
    },
    
    
    
    showToast : function(component, event, helper, message, type) {
        component.set("v.showSpinner", false);
        component.find('notifLib').showToast({
            "title": message,
            "message": '',
            "variant": type
        });
    },
    
    
     shootRecords : function(component,event,helper,lotMap){
        
        var purchaseOrderLineId = component.get("v.purchaseOrderLineId");
        var serialList = component.get("v.allSerials");
        console.log('leggo allSerial = '+ JSON.stringify(serialList));
        var map = new Map();
        map[purchaseOrderLineId] = serialList;
        //component.set("v.mapPolToSerialList", map);
        console.log('map to shoot = '+ JSON.stringify(map));
        //fire an event or chiama back-end
        var cmpEvent = $A.get("e.c:Giic_LCE018_ShootMapFromCsv");
        cmpEvent.setParams({
            "mapPolToSerialList" : JSON.stringify(map),
            "lotNumberToQuantityMap" : lotMap
        }); 
        cmpEvent.fire();
        
    }
    
    
})