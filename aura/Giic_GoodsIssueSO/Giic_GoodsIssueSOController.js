({
    doInit : function(component, event, helper) {
       helper.init(component, event, helper);
    },
    
    validateOdrQty : function(component, event, helper){
        try{
            var val = event.getSource().get('v.value');
            if(val > 0){
                component.set('v.disableSave',false);
            }else{
                component.set('v.disableSave',true);
                component.find('notifLib').showToast({
                    "title": "Error!",
                    "message": "Order Qty should be greater than 0 !!",
                    "variant": "error"
                });
            }
            
        }catch(ex){
            console.log(ex);
        }   
    },
    
    cancel : function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire();
    },
    
    validatePS : function(component, event, helper){
        try{
            console.log('validatePS------');
            var index = event.getSource().get('v.name');
            var lstOrderLine = component.get("v.mainGIWrapper.salesOrderLineList");//.lstAssignedSerial
            var soLine = lstOrderLine[index];
            var qty = soLine.consumedQuantity;
            if(qty >= 0){
                component.set('v.disableSave',false);
                var soLineSerials = soLine.assignedSerials;
                if(soLine.isSerialControlled){
                    lstOrderLine[index].assignedSerials = [];
                    for(var i=0;i<qty;i++){
                        console.log(qty);
                        var object = {};
                        object.serialNumber = '';
                        lstOrderLine[index].assignedSerials.push(object);
                    }
                    component.set('v.mainGIWrapper.salesOrderLineList',lstOrderLine);
                }
                console.log(component.get("v.mainGIWrapper.salesOrderLineList")); 
            }
          /*  if(qty == 0){
                component.set('v.disableSave',true);
                component.find('notifLib').showToast({
                    "title": "Error!",
                    "message": "Consumed Qty should be greater than 0 !!",
                    "variant": "error"
                });
            }*/
        }catch(ex){
            console.log(ex);
        }
    },
    setLocValue : function(component, event, helper){
        try{
            console.log('setLocValue------');
            var index = event.getSource().get('v.name');
            var val = event.getSource().get('v.value');
            var lstOrderLine = component.get("v.mainGIWrapper.salesOrderLineList");//.lstAssignedSerial
            lstOrderLine[index].vanLocation = val;
            component.set('v.mainGIWrapper.salesOrderLineList',lstOrderLine);
            console.log(component.get("v.mainGIWrapper.salesOrderLineList")); 
        }catch(ex){
            console.log(ex);
        }
    },
    
    handleCancel : function(component, event, helper) {
        
        $A.get("e.force:closeQuickAction").fire();
    },
    
    
    handleSave : function(component, event, helper) {
        helper.saveToDB(component, event, helper);
    },
    
    
    openModal : function(component, event, helper) {
        var mainWrapper = component.get("v.mainGIWrapper");
        var pdtSelected =[];
        var pdtSerialToShow =[];
        mainWrapper.salesOrderLineList.forEach(function(element){
            if(element.isSerialControlled == true){
                element.assignedSerials.forEach(function(element1){
                    if(!$A.util.isUndefinedOrNull(element1.serialNumber) || element1.serialNumber !=''){
                        pdtSelected.push(element1.serialNumber);
                    }
                });
            }
        });
        console.log('Open Modal');
        var productName = event.currentTarget.dataset.id;
        console.log("productName::"+productName);
        var position = event.currentTarget.dataset.name;
        var action = event.currentTarget.dataset.action;
        component.set("v.action",action);  
        if(action=='Product Serial'){
            console.log(" Product Serial Position::"+position);
            component.set("v.psPosition",position);
            var mapPSData = component.get("v.mapPSData");
            var lstPS = mapPSData[productName];
            lstPS.forEach(function(element){
                if(!pdtSelected.includes(element.gii__ProductSerial__r.Name)){
                    pdtSerialToShow.push(element);
                }
            });
            component.set("v.listShowPS",pdtSerialToShow); 
        }
        
        component.set("v.isOpen", true);
    },
    
    
    
    openModalForLot : function(component, event, helper) {
        var mainWrapper = component.get("v.mainGIWrapper");
        var pdtSelected =[];
        var pdtSerialToShow =[];
        mainWrapper.salesOrderLineList.forEach(function(element){
            if(element.isLotControlled == true){
                element.assignedSerials.forEach(function(element1){
                    console.log('element1 = '+JSON.stringify(element1));
                    if(!$A.util.isUndefinedOrNull(element1.serialNumber) || element1.serialNumber !=''){
                        
                        console.log('element1.serialNumber = '+element1.serialNumber);
                        pdtSelected.push(element1.serialNumber);
                        
                    }
                });
            }
        });
        console.log('Open Modal');
        var productName = event.currentTarget.dataset.id;
        console.log("productName::"+productName);
        var position = event.currentTarget.dataset.name;
        var action = event.currentTarget.dataset.action;
        component.set("v.action",action);  
        if(action=='Product Lot'){
            console.log(" Product lot Position::"+position);
            component.set("v.psPosition", position);
            var mapPSData = component.get("v.mapPSData");
            var lstPS = mapPSData[productName];
            
            
            lstPS.forEach(function(element){
                if(!pdtSelected.includes(element.gii__ProductLot__r.Name)){
                    pdtSerialToShow.push(element);
                    
                }
            });
            component.set("v.listShowPS",pdtSerialToShow); 
        }
        
        component.set("v.isOpen", true);
    },
    
    
    setLotQuantityMap : function(component, event, helper) {
       
        var lotName = event.target.id;
        var selectedQuantity = event.target.value;
        var maxAvailableQuantity = event.target.name;
        var q = parseInt(selectedQuantity, 10);
        var m = parseInt(maxAvailableQuantity, 10);
        console.log('lotName = '+lotName);
        console.log('maxAvailableQuantity = '+maxAvailableQuantity);
        if( q > m ){
            helper.showWarningToast(component, event, helper, 'You can select only '+maxAvailableQuantity+' quantities for this lot!');
        }else{
            helper.lotSelected(component, event, helper, lotName, selectedQuantity) ;
        }
        
                
        
    },
    
    
    
    closeModel : function(component, event, helper) {
        component.set("v.isOpen", false);
    },

    psSelected : function(component, event, helper){
        try{
            var selectedPS = event.currentTarget.dataset.name;
            console.log('selectedPS:::'+selectedPS);
            console.log(component.get("v.psPosition"));
            var psPosition = component.get("v.psPosition");
            var positionPOline = psPosition.split('-')[0];
            var positionPS = psPosition.split('-')[1];
            console.log('positionPOline:::'+positionPOline);
            console.log('positionPS:::'+positionPS);
            var lstorderLine = component.get("v.mainGIWrapper.salesOrderLineList");
            lstorderLine[positionPOline].assignedSerials[positionPS].serialNumber = selectedPS;
            //lstorderLine[positionPOline].lstAssignedSerial[positionPS].productserialId = selectedPSid;
            component.set("v.mainGIWrapper.salesOrderLineList",lstorderLine);
            component.set("v.isOpen", false); 
            component.set("v.listShowPS",[]);   
        }catch(ex){
            console.log(ex);
        }
    },
    
    clearSelection : function(component, event, helper) {
        var position = event.currentTarget.dataset.name;
        var action = event.currentTarget.dataset.action;//component.get("v.action");  
        var lstorderLine = component.get("v.mainGIWrapper.salesOrderLineList");
        if(action=='Product Serial'){
            var positionPOline = position.split('-')[0];
            var positionPS = position.split('-')[1];
            console.log('positionPOline:::'+positionPOline);
            console.log('positionPS:::'+positionPS);
            lstorderLine[positionPOline].assignedSerials[positionPS].serialNumber = '';
            
        }else if(action=='Product Lot'){
            lstorderLine[position].assignedLot = '';
        }else if(action=='Location'){
            lstorderLine[position].locationName = '';
            lstorderLine[position].locationId = '';
            component.set("v.listShowLocation",[]); 
        }

        component.set("v.mainGIWrapper.salesOrderLineList",lstorderLine);
        
    }

})