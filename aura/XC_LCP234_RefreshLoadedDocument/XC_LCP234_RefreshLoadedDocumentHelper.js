({
	doInit : function(component, event, helper) {
		component.set("v.spinnerControl", true);
		let action = component.get("c.callDoxee");
        action.setParams({ 
            "objectId": component.get("v.recordId") 
        });
        action.setCallback(this, function (a) {
            let state = a.getState();
            let toastEvent = $A.get("e.force:showToast");
            if(state === "SUCCESS") {

				toastEvent.setParams({
					title: $A.get("$Label.c.XC_CL_Success"),
					message: $A.get("$Label.c.XC_CL_OperationCompleted"),
					key: 'info_alt',
					type: 'success',
					mode: 'dismissible'
				});

            }
            else {
                toastEvent.setParams({
                    title: $A.get("$Label.c.XC_CL_Error"),
                    message: a.getError(),
                    key: 'info_alt',
                    type: 'error',
                    mode: 'dismissible'
                });
            }

            component.set("v.spinnerControl", false);
			toastEvent.fire();
            if(!component.get('v.notCloseAction')) {
                $A.get('e.force:closeQuickAction').fire();  
            }
        });
        $A.enqueueAction(action);    
	}

})