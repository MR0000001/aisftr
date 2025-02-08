({
    doInit: function (component, event, helper) {
        console.log('@@@ Component initialization');
        let recordId = component.get("v.recordId");
        console.log("recordId " + recordId);
        let action = component.get("c.checkAndPrepareRepairPreconditions");
        action.setParams({
            "caseId": recordId
        });
        action.setCallback(this, function (a) {
            var state = a.getState();
            var result = a.getReturnValue();
            console.log("@@@ State Result : " + state + " And record is: " + recordId);
            component.set("v.showSpinner", false);
            if (state === 'SUCCESS') {
                if(result.success) {
                    component.set("v.preconditionsOK", true);
                    let value = component.find("subtype").get("v.value");
                    if (!$A.util.isEmpty(value)) {
                        component.set("v.buttonDisabled", false);
                    }
                } else {
                    helper.showToast(component, result.resultMessage, 'error');
                }
            } else {
                helper.showToast(component, a.getError(), 'error');
            }
                
        });
        $A.enqueueAction(action);
    },

    handleSubtypeChange : function(component, event, helper) {
        let value = component.find("subtype").get("v.value");
        console.log(value);
        if (!$A.util.isEmpty(value)) {
            component.set("v.buttonDisabled", false);
        } else {
            component.set("v.buttonDisabled", true);
        }
    },

    handleSubmit : function(component, event, helper) {
        event.preventDefault(); // Prevent default submit
        let button = component.find('createButtonId');
        let recordId = component.get("v.recordId");
        console.log("recordId " + recordId);
        let inputSubtype = component.find("subtype").get("v.value");

        let map = new Object();
        map["recordId"] = recordId;
        map["subtype"] = inputSubtype;

        let action = component.get("c.workOrderCreation");
        action.setParams({
            "paramsMap": map
        });
        action.setCallback(this, function (a) {
            var state = a.getState();
            console.log("@@@ State Result : " + state + " And record is: " + recordId);
            component.set("v.showSpinner", false);
            if (state === 'SUCCESS') {
                var result = a.getReturnValue();
                if(result.success) { 
                    helper.showToast(component, $A.get("$Label.c.XC_CL_WorkOrder_WoCreated"), 'success');
                } else {
                    helper.showToast(component, result.resultMessage, 'error');
                }
            } else {
                helper.showToast(component, a.getError(), 'error');
            }
        });
        $A.enqueueAction(action);
    },

    showToast : function(component, message, type) {
        component.find('notifLib').showToast({
            "title": message,
            "message": '',
            "variant": type
        });
        window.setTimeout(
            $A.getCallback(function() {
                window.location.reload();
            }), 
            5000
        );
    },

    redirectToCase : function(component) {
        window.setTimeout(
            $A.getCallback(function() {
                window.location.reload();
            }), 
            1000
        );
    }
})