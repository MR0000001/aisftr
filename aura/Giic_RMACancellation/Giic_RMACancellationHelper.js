({
	doInitH : function(component, event, helper) {
        component.set('v.showSpinner', true);  
        	let action = component.get("c.cancellation_RMA_RTS");
        	var currentId = component.get("v.recordId");
        	action.setParams({
           		 'currentId':currentId
			});
        	 action.setCallback(this, function (response) {
            let state = response.getState();
            let retValue = response.getReturnValue(); 
            console.log('retValue' + retValue);
            if (state === "SUCCESS" && retValue.success) {
                component.set('v.showSpinner', false);
            }else{
                helper.showToast(component, event, helper, retValue.resultMessage , 'error');
                component.set("v.showSpinner" , false);
                $A.get("e.force:closeQuickAction").fire();
            }
            
        });       
        $A.enqueueAction(action);    
    },
      showToast : function(component, event, helper, message, type) { 
        component.find('notifLib').showToast({
            "title": message,
            "message": '',
            "variant": type
        });
    }
	
})