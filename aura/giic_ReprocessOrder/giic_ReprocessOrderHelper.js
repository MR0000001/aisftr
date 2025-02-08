/*
  @author GLOVIA Team
  @date Mod 06/09/2021 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
  @description giic_ReprocessOrderHelper - Helper Javascript
*/

({
    reprocessSO : function(component, event, helper) {
        component.set("v.isLoading",true);
        let checkPermissionSet  = component.get("c.checkPermissionGlovia");
        checkPermissionSet.setCallback(this, function (responseCheck) {  
            let stateCheck = responseCheck.getState(); 
            if(stateCheck === "SUCCESS") {
                let resultCheck = responseCheck.getReturnValue();
                if(resultCheck) {
                    let reprocessAction  = component.get("c.reprocessOrder");
                    reprocessAction.setParams({
                        "salesOrderId" : component.get("v.recordId")
                    });
                    reprocessAction.setCallback(this, function (response) {    
                        let state = response.getState(); 
                        if(state === "SUCCESS") {
                            let responseReprocess = response.getReturnValue();
                            if(!$A.util.isUndefinedOrNull(responseReprocess.errorMessages)) {
                                let toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    title: 'Reprocess Failed',
                                    type: 'error',
                                    message: responseReprocess.errorMessages[0] 
                                }); 
                                toastEvent.fire();
                            }
                            else {
                                let toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    title: 'Reprocess Success',
                                    type: 'success',
                                    message: 'Sales Order reprocessed successfully'
                                });
                                toastEvent.fire();
                            }
                        }
                        else{
                            let toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title: 'Reprocess Failed',
                                type: 'error',
                                message: 'Some error occurred, Plesae contact to System Admin'
                            });
                            toastEvent.fire();
                        }
                    });
                    $A.enqueueAction(reprocessAction);  
                }
                else {
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Reprocess Failed',
                        type: 'error',
                        message: 'You cannot reprocess order'
                    });
                    toastEvent.fire();
                }
            }
            else{
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: 'Reprocess Failed',
                    type: 'error',
                    message: 'Some error occurred, Plesae contact to System Admin'
                });
                toastEvent.fire();
            }
            component.set("v.isLoading",false);
            $A.get("e.force:closeQuickAction").fire();
            $A.get('e.force:refreshView').fire();
        });
        $A.enqueueAction(checkPermissionSet);  
    }
})