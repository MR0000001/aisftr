/*
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 02/05/2020
* @description XC_LCP185_PendingOrder – Helper Javascript for component to manage WO/SA to insert new technical products
*/

({
    doInit : function(component, event, helper) {
        console.log('@@@ In XC_LCP185_PendingOrder');
        component.set("v.spinner", true);
        let recordId = component.get("v.recordId");
        let action = component.get("c.managePendingOrder");
        action.setParams({
            'recordId': recordId,
        });
        action.setCallback(this, function (resp) {
            let state = resp.getState();
            if(state === "SUCCESS") {
                let result = resp.getReturnValue();
                if(result.success) {
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: $A.get("$Label.c.XC_CL_Success"),
                        message: $A.get("$Label.c.XC_CL_SuccessPendingOrder"),
                        key: 'info_alt',
                        type: 'success',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                } else {
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: $A.get("$Label.c.XC_CL_WorkOrder_Error"),
                        message: result.message,
                        key: 'info_alt',
                        type: 'error',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                }
            } else {
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: $A.get("$Label.c.XC_CL_WorkOrder_Error"),
                    message: resp.getError(),
                    key: 'info_alt',
                    type: 'error',
                    mode: 'dismissible'
                });
                toastEvent.fire();
            }
            component.set("v.spinner", false);
            $A.get('e.force:closeQuickAction').fire(); 
        });
        $A.enqueueAction(action);
    }
})