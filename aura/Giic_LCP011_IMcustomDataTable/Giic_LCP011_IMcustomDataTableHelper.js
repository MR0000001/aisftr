({
	init : function(component, event, helper) {
		
		
	},
    
    
    showMessage : function(component, event, helper, message, type) {
        
        component.find('notifLib').showToast({
            "title": message,
            "message": '',
            "variant": type
        });
		
    },
    
    
    saveAllPiqd : function(component, event, helper) {
        
        var action = component.get("c.inventoryMovement");
        action.setParams({
                'productInventoryId' : component.get("v.productInventoryId"),
            	'locationTo' : component.get("v.locationToId"),
            	'mapIdToOnHand' : JSON.stringify(component.get("v.mapIdToOnHand")),
            	'mapIdPiqdToLocationFrom' : JSON.stringify(component.get("v.mapIdPiqdToLocationFrom"))
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            let result = response.getReturnValue();
            if(state === "SUCCESS" && result.success){
              	helper.showMessage(component, event, helper, result.resultMessage, 'success');
                $A.get("e.force:closeQuickAction").fire();
            }
            else {
                component.set("v.showSpinner" , false);
              	helper.showMessage(component, event, helper, result.resultMessage, 'error');
            }
            
             
        });
		
        $A.enqueueAction(action);    
        
        
    }
    
    
    
    
})