/** 
  * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
  * @date Creation 15/10/2020
  * @description Helper for Component XC_LCP213_CreateServiceReport
*/

({
    doInit : function(component, helper, event) { 
        component.set("v.spinnerControl", true);
        let action = component.get("c.createServiceReport");
        action.setParams({ 
            "workOrderId": component.get("v.recordId") 
        });
        action.setCallback(this, function (a) {
            let state = a.getState();
            let toastEvent = $A.get("e.force:showToast");
            if(state === "SUCCESS") {
                let result = a.getReturnValue();
                if(result.success) {
                    toastEvent.setParams({
                        title: $A.get("$Label.c.XC_CL_CPAB_Success"),
                        message: $A.get("$Label.c.XC_CL_RequestServiceReport"),
                        key: 'info_alt',
                        type: 'success',
                        mode: 'dismissible'
                    });
                } else {
                    toastEvent.setParams({
                        title: $A.get("$Label.c.XC_CL_SerResMangement_Error"),
                        message: result.message,
                        key: 'info_alt',
                        type: 'error',
                        mode: 'dismissible'
                    });
                }
            }
            else {
                toastEvent.setParams({
                    title: $A.get("$Label.c.XC_CL_SerResMangement_Error"),
                    message: a.getError(),
                    key: 'info_alt',
                    type: 'error',
                    mode: 'dismissible'
                });
            }

            component.set("v.spinnerControl", false);
            toastEvent.fire();
            $A.get('e.force:closeQuickAction').fire();  
        });
        $A.enqueueAction(action);    
    }

})