/** 
  * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 15/06/2021
  * @description Helper class for Component XC_LCP254_SelectInvoiceDeliveryPreference
*/

({
    doInit : function(component, helper, event) { 
        console.log('@@@ In XC_LCP254_SelectInvoiceDeliveryPreference');
        component.set("v.spinnerControl", true);
        
        let action = component.get("c.loadPreferences");
        action.setParams({ 
            "orderId": component.get("v.recordId") 
        });
        action.setCallback(this, function (a) {
            let state = a.getState();
            let toastEvent = $A.get("e.force:showToast");
            if (state === "SUCCESS") {
                let result = a.getReturnValue();
                if(!result.success) {
                    toastEvent.setParams({
                        title: $A.get("$Label.c.XC_CL_WorkOrder_Error"),
                        message: result.message,
                        key: 'info_alt',
                        type: 'error',
                        mode: 'dismissible'
                    });
                    component.set("v.spinnerControl", false);
                    toastEvent.fire();
                    $A.get('e.force:closeQuickAction').fire(); 
                    return;
                }
                component.set('v.listOptionsPreference', result.listPreferences);
                component.set('v.preferenceSelected', result.listPreferences[0]);
            }
            else {
                toastEvent.setParams({
                    title: $A.get("$Label.c.XC_CL_WorkOrder_Error"),
                    message: JSON.parse(JSON.stringify(a.getError())),
                    key: 'info_alt',
                    type: 'error',
                    mode: 'dismissible'
                });
                $A.get('e.force:closeQuickAction').fire();  
            }

            component.set("v.spinnerControl", false);
            toastEvent.fire();
        });
        $A.enqueueAction(action);    
    },

    changePreference : function(component, helper, event) { 
        console.log('@@@ In XC_LCP254_SelectInvoiceDeliveryPreference');
        component.set("v.spinnerControl", true);
        
        let action = component.get("c.savePreference");
        action.setParams({ 
            "orderId": component.get("v.recordId"),
            "preferenceSelected": component.get('v.preferenceSelected') 
        });
        action.setCallback(this, function (a) {
            let state = a.getState();
            let toastEvent = $A.get("e.force:showToast");
            if(state === "SUCCESS") {
                let result = a.getReturnValue();
                if(result.success) {
                    toastEvent.setParams({
                        title: $A.get("$Label.c.XC_CL_Success"),
                        message: result.message,
                        key: 'info_alt',
                        type: 'success',
                        mode: 'dismissible'
                    });
                } else {
                    toastEvent.setParams({
                        title: $A.get("$Label.c.XC_CL_WorkOrder_Error"),
                        message: result.message,
                        key: 'info_alt',
                        type: 'error',
                        mode: 'dismissible'
                    });
                }
            }
            else {
                toastEvent.setParams({
                    title: $A.get("$Label.c.XC_CL_WorkOrder_Error"),
                    message: JSON.parse(JSON.stringify(a.getError())),
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