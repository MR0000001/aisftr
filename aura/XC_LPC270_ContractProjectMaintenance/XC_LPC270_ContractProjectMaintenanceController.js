({ 
    doInit : function(component, event, helper) {
        var action = component.get("c.createProjectTasks");
        component.set("v.loading",true);
        
        action.setParams({
            "contractId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var res = response.getReturnValue();    
            if (state === "SUCCESS") {
                component.set("v.loading",false);
                if (res != 'Project Tasks created'){
                    helper.toastError(component,res);
                    $A.get("e.force:closeQuickAction").fire();
                }
                else {
                    // Alert the user with the value returned 
                    // from the server
                helper.ToastSuccess(component,res);
                    $A.get("e.force:closeQuickAction").fire();
                    $A.get('e.force:refreshView').fire();
                }
            }
        })
        $A.enqueueAction(action);         
	}
})