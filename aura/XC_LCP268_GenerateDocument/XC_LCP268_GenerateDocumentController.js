({
    init: function (component, event, helper) {

        component.set('v.spinnerControl', true);
        var recordId = component.get('v.recordId');
        console.log('recordId->' + recordId);
        var action = component.get("c.getContractRecordMethod");
        action.setParams({
            recordIdContract: recordId
        });
        action.setCallback(this, function (a) {
            let state = a.getState();
            console.log('****state****', state);
            if (component.isValid() && state === "SUCCESS") {
                let result = a.getReturnValue();
                console.log('****result11****', result);

                console.log('****result****' + result.Error + result.Message);
                if (result.Error == 200 || result.Error == 202) {
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Success',
                        message: 'Your request has been processed correctly',
                        duration: ' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    component.set('v.spinnerControl', false);
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();           
                } else if (result.Error >= 400 || result.Error >= 500) {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Error',
                        message: 'An error occurred while processing your request, please retry',
                        duration: ' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                } else {
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Success',
                        message: 'The contract document has been generated.',
                        duration: ' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                }
            }
        });
        $A.enqueueAction(action);
    }
})