/** 
  * @author Salvatore Agrillo, Marco Rosa
  * @date Creation 30/10/2019
  * @description Helper class for Component XC_LCP168_CreateWorkOrderFromOrder
*/

({
    doInit : function(component, helper, event) { 
        console.log('@@@ In XC_LCP168_CreateWorkOrderFromOrder');
        component.set("v.spinnerControl", true);
        
        let action = component.get("c.createWorkOrder");
        action.setParams({ 
            "orderId": component.get("v.recordId") 
        });
        action.setCallback(this, function (a) {
            let state = a.getState();
            console.log('@@@ Result init -> ', state);
            let toastEvent = $A.get("e.force:showToast");
            if (state === "SUCCESS") {
                let result = a.getReturnValue();
                console.log('@@@ Output is -> ', result);
                if(result.success) {
                    toastEvent.setParams({
                        title: $A.get("$Label.c.XC_CL_CPAB_Success"),
                        message: $A.get("$Label.c.XC_CL_WorkOrderCreated"),
                        key: 'info_alt',
                        type: 'success',
                        mode: 'dismissible'
                    });
                } else {
                    toastEvent.setParams({
                        title: $A.get("$Label.c.XC_CL_SerResMangement_Error"),
                        message: result.errorMessage,
                        key: 'info_alt',
                        type: 'error',
                        mode: 'dismissible'
                    });
                }
            }
            else {
                toastEvent.setParams({
                    title: $A.get("$Label.c.XC_CL_SerResMangement_Error"),
                    message: $A.get("$Label.c.XC_CL_ErrorCreateWorkOrder"),
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
    },

    showToast : function(helper, title, message, type) { 
        
        
        
    }

})