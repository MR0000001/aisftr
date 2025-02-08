/**
 	* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date 18/03/2020
    * @description Helper for button to create Commercial Visit WO
 */

({
	doInit : function(component, event, helper) {
		console.log('@@@ In XC_LCP180_CreateCommercialVisit');
		component.set("v.spinnerControl", true);
        
        let action = component.get("c.manageCommercialVisit");
        action.setParams({ 
            "objectId": component.get("v.recordId") 
        });
        action.setCallback(this, function (a) {
            let state = a.getState();
            console.log('@@@ Result init -> ', state);
            let toastEvent = $A.get("e.force:showToast");
            if(state === "SUCCESS") {
                let result = a.getReturnValue();
                console.log('@@@ Output is -> ', result);
                if(result.success) {
                    toastEvent.setParams({
                        message: $A.get("$Label.c.XC_CL_OperationCompleted"),
                        key: 'info_alt',
                        type: 'success',
                        mode: 'dismissible'
                    });
                } else {
                    toastEvent.setParams({
                        title: $A.get("$Label.c.XC_CL_SerResMangement_Error"),
                        message: result.resultMessage,
                        key: 'info_alt',
                        type: 'error',
                        mode: 'dismissible'
                    });
                }
            }
            else {
                toastEvent.setParams({
                    title: $A.get("$Label.c.XC_CL_SerResMangement_Error"),
                    message: $A.get("$Label.c.XC_CL_OperationNotAllowed"),
                    key: 'info_alt',
                    type: 'error',
                    mode: 'dismissible'
                });
            }

            component.set("v.spinnerControl", false);
            toastEvent.fire();
			$A.get('e.force:closeQuickAction').fire();  
			$A.get('e.force:refreshView').fire();
        });
        $A.enqueueAction(action);    
    }
})