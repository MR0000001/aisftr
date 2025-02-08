({
	cancelContract : function(component, event, helper) {
		component.set("v.spinnerControl", true);
        let recordId = component.get("v.recordId");
        let action = component.get("c.cancelContract");
		console.log("FIELD"); 
        action.setParams({
            "recordId": recordId
        });
        action.setCallback(this, function (a) {

            let result = a.getReturnValue();
            console.log("@@@ Result is: " + result.success + " And record is: " + recordId);

            if (result.success) {
                component.set("v.spinnerControl", false);
                $A.get('e.force:closeQuickAction').fire();
                $A.get('e.force:refreshView').fire();

                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: $A.get("$Label.XC_CL_Success"),
                    mode: 'dismissible',
                    mode: 'pester',
                    key: 'info_alt',
                    type: 'success',
                    message: result.message 
                });
                component.set("v.spinnerControl", false);
                toastEvent.fire();

            } else {
                let toastEventWarn = $A.get("e.force:showToast");
                toastEventWarn.setParams({
                    title: $A.get("$Label.XC_CL_Warning"),
                    mode: 'dismissible',
                    mode: 'pester',
                    key: 'info_alt',
                    type: 'error',
                    message: result.message
                });
                component.set("v.spinnerControl", false);
                toastEventWarn.fire();

                $A.get('e.force:closeQuickAction').fire();
            }

        });
        $A.enqueueAction(action);
	}
})