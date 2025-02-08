({
    doInit: function (component, event) {

        let recordId = component.get("v.recordId");
        let action = component.get("c.documentVerification");

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
                    title: $A.get("$Label.XC_CL_Warning"),
                    mode: 'sticky',
                    type: 'success',
                    duration: 20,
                    message: result.message
                });
                toastEvent.fire();
            } else {

                let toastEventWarn = $A.get("e.force:showToast");
                toastEventWarn.setParams({
                    title: $A.get("$Label.XC_CL_Warning"),
                    mode: 'sticky',
                    type: 'error',
                    duration: 20,
                    message: result.message
                });

                toastEventWarn.fire();
                component.set("v.spinnerControl", false);
                $A.get('e.force:closeQuickAction').fire();
            }

        });
        $A.enqueueAction(action);

    }
})