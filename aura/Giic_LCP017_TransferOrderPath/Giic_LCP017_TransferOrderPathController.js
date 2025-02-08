({
	handleSelect : function (component, event, helper) {
        
     var stepName = event.getParam("detail").value;
     if(stepName == 'Open' || stepName == 'Cancelled'){
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
                helper.showToast(component, event, helper, stepName+"!", 'success' );
                $A.get('e.force:refreshView').fire();
            }else{
                helper.showToast(component, event, helper, retValue.resultMessage, 'error' );
            }
            component.set('v.showSpinner', false);
        }); 
        $A.enqueueAction(action); 
         
        }
        
        
    }
})