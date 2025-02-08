({
	checkStatusStateModel : function(component, event, helper) {
            var stepName = event.getParam("detail").value;
            
            component.set('v.showSpinner', true);
            var action = component.get("c.saveStatus");
        	action.setParams({
            'recordId': component.get("v.recordId"),
            'stepName' : stepName
        })
        action.setCallback(this, function(response) {
            var state = response.getState();
            var retValue = response.getReturnValue();
            if (state === "SUCCESS" && retValue.success) {
                console.log('Result = '+retValue.success)
                helper.showToast(component, event, helper, stepName+"!", 'success' );
                $A.get('e.force:refreshView').fire();
            }else{
                helper.showToast(component, event, helper, 'Warning: '+retValue.resultMessage, 'error' );
            }
            component.set('v.showSpinner', false);
        }); 
        $A.enqueueAction(action); 
         
        
        
        
    },
    
    
    showToast : function(component, event, helper, message, type) {
        component.set('v.showSpinner', false);
        component.find('notifLib').showToast({
            "title": message,
            "message": '',
            "variant": type
        });
         
    }
    
    
		
	
})