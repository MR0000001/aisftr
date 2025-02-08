({
    init: function (component, event, helper) {
        let action = component.get("c.retrievePickListValue");
        component.set("v.spinnerControl", true);
        action.setCallback(this, function (a) {

            let result = a.getReturnValue();
            let state = a.getState();
            console.log("@@@ Result is: ", result);

            if (state === "SUCCESS") {
                // popolamento picklist brand
                var opts = [];
                result.forEach(function (entry) {
                    opts.push({
                        value: entry,
                        label: entry
                    });
                })
                component.set("v.spinnerControl", false);
                component.set('v.pickListValue', opts);
            } else {
                console.log("NOT SUCCESS");


                let errors = response.getError();
                let message = 'Unknown error'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                // Display the message
                console.log("Error: " + message);
                let toastEventWarn = $A.get("e.force:showToast");
                toastEventWarn.setParams({
                    title: $A.get("$Label.XC_CL_Warning"),
                    mode: 'dismissible',
                    mode: 'pester',
                    key: 'info_alt',
                    type: 'error',
                    message: message
                });
                component.set("v.spinnerControl", false);
                toastEventWarn.fire();

                $A.get('e.force:closeQuickAction').fire();
            }
        });
        $A.enqueueAction(action);
    },

    save: function (component, event, helper) {
        let action = component.get("c.assignBrand");
        component.set("v.spinnerControl", true);
        action.setParams({
            "recordId": component.get("v.recordId"),
            "typeSelected": component.get("v.brandString")
        });
        action.setCallback(this, function (a) {

            let result = a.getReturnValue();
            let state = a.getState();
            console.log("@@@ Result is: ", result);

            if (state === "SUCCESS") {
                if (result.success) {
                    let toastEventWarn = $A.get("e.force:showToast");
                    toastEventWarn.setParams({
                        title: $A.get("$Label.XC_CL_Warning"),
                        mode: 'dismissible',
                        mode: 'pester',
                        key: 'info_alt',
                        type: 'success',
                        message: result.message
                    });
                    component.set("v.spinnerControl", false);
                    toastEventWarn.fire();

                    $A.get('e.force:closeQuickAction').fire();
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
            }
        });
        $A.enqueueAction(action);
    }

})