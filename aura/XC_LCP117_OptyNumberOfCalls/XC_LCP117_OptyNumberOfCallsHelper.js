({
    doInit : function(component, event) {

        var action = component.get("c.updateNumberOfCalls");
        action.setParams({
            "opportunityId" : component.get("v.recordId")
        });

        action.setCallback(this, function(ret){
            var state = ret.getState();
            if (state === "SUCCESS"){
                var resultJSON = ret.getReturnValue();
                var result = JSON.parse(resultJSON);

                component.set("v.spinnerControl", false);

                if(result.success) {
                    this.showToast(component, $A.get("$Label.c.XC_CL_Opportunity_NumberCallsUpdated"), "Success");
                    if(result.isValid) {
                        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                          "recordId": component.get("v.recordId"),
                          "slideDevName": "related"
                        });
                        navEvt.fire();    
                    }
                } else {
                    this.showToast(component, result.resultMessage, "Error");
                }
            } else {
                this.showToast(component, "Error", "Error");
            }
            $A.get("e.force:closeQuickAction").fire();
            return;
        });
        $A.enqueueAction(action);

    },
    
	showToast : function(component, message, type) {
		var msg = message.charAt(0).toUpperCase() + message.slice(1);
        component.find('notifLib').showToast({
            "title": msg,
            "message": '',
            "variant": type
		});
	}
        
})