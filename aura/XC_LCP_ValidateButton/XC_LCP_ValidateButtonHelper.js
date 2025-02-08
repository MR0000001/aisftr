({
	validate : function(component, event, helper) {
		let action = component.get("c.validate");

		action.setParams({
			'recId' : component.get("v.recordId")
		});

		action.setCallback(this, function (response) {
            let state = response.getState();
            console.log("@@@ State Result : " + state + " And record is: " + component.get("v.recordId") + " Result Value " + response.getReturnValue());
            component.set("v.showSpinner", false);
            if (state === "SUCCESS") {
                let result = response.getReturnValue();
                console.log("@@@ result.errorResult : " + result.errorResult);
                console.log("@@@ result.errorMessage : " + result.errorMessage);
                if(!result.errorResult) { 
                    console.log("@@@ nessun errore");
                    this.showToast(component, result.errorMessage, 'success', true);
                } else {
                    console.log("@@@ sono in errore");
                    this.showToast(component, result.errorMessage, 'error', true);
                    console.log("@@@ dopo show toast");
                }
            } else {
                //helper.showToast(component, response.getError(), 'error', true);
                this.showToastLonger(result.errorMessage,  true, 10000);
            }
        });
        $A.enqueueAction(action);
	},
    
    showToast : function(component, message, type, closeComponent) {
		console.log('@#@#@#@#@#@ showToast message: '+ message);
		component.find('notifLib').showToast({
            "title": message,
            "message": '',
            "variant": type
        });

		if(closeComponent){
	        $A.get("e.force:closeQuickAction").fire();
	        $A.get('e.force:refreshView').fire();
		}
	},
    
    showToastLonger : function(message, closeComponent, duration) {
		console.log('@#@#@#@#@#@ showToastLonger message: '+message);
		var toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
			title : $A.get("$Label.XC_CL_Warning"),
			mode: 'sticky',
			type:'error',
			mode: 'dismissible',
			mode: 'pester',
			duration : duration,
			message: message
		});
		toastEvent.fire();

		if(closeComponent){
	        $A.get("e.force:closeQuickAction").fire();
	        $A.get('e.force:refreshView').fire();
		}
    }
})