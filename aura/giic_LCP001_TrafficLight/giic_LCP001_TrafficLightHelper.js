({
	init : function(component, event, helper) {
          console.log('in init ');
        let actionContactList = component.get("c.setTrafficLight");
        
        actionContactList.setParams({
            recordId : component.get("v.recordId"),
            objectName : component.get("v.sobjectType")
        });
        
        actionContactList.setCallback(this, function(response) {
            component.set("v.products", response.getReturnValue());
            var state = response.getState();
            var retValue = response.getReturnValue();
            if (state === "SUCCESS" && retValue.success) {
            
                component.set("v.lightValue", retValue.resultMessage);
                console.log('lightValue = '+component.get("v.lightValue"));
               
            }
            else{
         
            }
            

        });
        $A.enqueueAction(actionContactList);
		
	},
		
	
})