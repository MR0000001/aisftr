({
    init: function (component, event, helper) {
        
        console.log('@@@ Component initialization');
        var recordId = component.get("v.recordId");
        console.log("recordId " + recordId);
        var action = component.get("c.changeStatus");
        action.setParams({
            "recordId": recordId
        });
        action.setCallback(this, function (a) {
            var state = a.getState();
            var result = a.getReturnValue();
            console.log("@@@ State Result : " + state + " And record is: " + recordId);
            component.set("v.showSpinner", false);
            if (state === 'SUCCESS') {
                if(result) {
                    helper.showToast(component, $A.get("$Label.c.XC_CL_Record_Updated"), 'success');                
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
        component.set("v.showSpinner", false);
        component.find('notifLib').showToast({
            "title": message,
            "message": '',
            "variant": type
        });
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    }
})