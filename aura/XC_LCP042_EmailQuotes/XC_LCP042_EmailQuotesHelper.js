({
	init : function(component, event, helper) {
        component.set("v.spinnerControl",true);
        var recordId = component.get("v.recordId"); 
        var action = component.get("c.getConfigurationNotificationResult");
        
        action.setParams({
            "recordId": recordId
        });
        action.setCallback(this, function(resp) {
            var result = resp.getReturnValue();
            console.log("@@@ esito EmailQuotes call:  " + resp.getState());
            console.log("@@@ result: " + result);
            if(resp.getState() && result.success) {
                helper.showToast(component, result.result, 'success');
            } else {
                console.log('EmailQuotes error');
                helper.showToast(component, result.result, 'error');
            }      
        });
        $A.enqueueAction(action);
    },

	showToast : function(component, message, type) {
        component.set("v.spinnerControl",true);
        console.log('@#@#@#@#@#@ EmailQuotes message: '+message+' - type: '+type);
        component.find('notifLib').showToast({
            "title": message,
            "message": '',
            "variant": type
        });
        $A.get('e.force:closeQuickAction').fire();
    }
})