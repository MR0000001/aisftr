({
    doInit : function(component,event,helper) {

        let currentOrder = component.get("v.recordId");
        let action = component.get("c.manageExternalOTP");
        action.setParams({recordId : currentOrder});
        action.setCallback(this,function(response){
            if(response.getState()==="SUCCESS"){

                let result = response.getReturnValue();

                if(result.success){
                    component.find('notifLib').showToast({
                        "title": "Success",
                        "message": $A.get('$Label.c.XC_CL_LCP191_SuccessExtOTP'),
                        "mode": "pester",
                        "variant": "success"
                    });
                }else{
                    component.find('notifLib').showToast({
                        "title": "Error",
                        "message": result.errorMsg,
                        "mode": "pester",
                        "variant": "error"
                    });
                }
                if(!component.get('v.notCloseModal')) {
                    $A.get("e.force:closeQuickAction").fire();
                }
            }else{
                component.find('notifLib').showToast({
                    "title": "Error",
                    "message": response.getError()[0].message,
                    "mode": "pester",
                    "variant": "error"
                });
                if(!component.get('v.notCloseModal')) {
                    $A.get("e.force:closeQuickAction").fire();
                }
            }
        });
        $A.enqueueAction(action);
    }
})