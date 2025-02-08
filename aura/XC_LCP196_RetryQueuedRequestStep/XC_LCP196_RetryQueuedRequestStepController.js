({
    doInit: function (component, event, helper) {

        let action = component.get("c.retryCurrentQRS");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            if(response.getState()=="SUCCESS"){
                let result = response.getReturnValue();
                if(result.success){
                    component.find('notifLib').showToast({
                        "title": "Success",
                        "message": 'Request Step Re-Submitted!',
                        "mode": "pester",
                        "variant": "success"
                    });
                }else{
                    component.find('notifLib').showToast({
                        "title": "Error",
                        "message": result.errorMsg,
                        "mode": "pester",
                        "variant": "success"
                    });
                }
                $A.get('e.force:refreshView').fire();
                $A.get("e.force:closeQuickAction").fire();
            }else{
                component.find('notifLib').showToast({
                    "title": "Error",
                    "message": response.getError()[0].message,
                    "mode": "pester",
                    "variant": "success"
                });
                $A.get('e.force:refreshView').fire();
                $A.get("e.force:closeQuickAction").fire();
            }
        });

        $A.enqueueAction(action);
    }
})