({
	
	init: function (component, event, helper) {
		let recordId = component.get("v.recordId");
		if(recordId.startsWith('0WO')){
			component.set("v.isFromWorkOrder", true);
		}
		console.log("recordId " + recordId);
		let action = component.get('c.createCase');
		action.setParams({
			recordId: recordId
		});
		action.setCallback(this, function (response) {
			let state = response.getState();
			if (state = "SUCCESS") {
				let result = response.getReturnValue();
				if(result.success){
					let caseNumber = result.objectInfo;

					component.set("v.caseNumber", caseNumber);
					console.log('@@ CaseNumber=' + component.get("v.caseNumber")); 
					component.set("v.isOpen", true);
					component.set("v.spinnerControl", false);
					if(component.get("v.isFromWorkOrder")){
						setTimeout(function(){
						$A.get('e.force:refreshView').fire();
						}, 2500);
					}else{
						$A.get('e.force:refreshView').fire();
					}
				}else{
                    helper.showToast(component, result.resultMessage , "error"); 
					component.set("v.isOpen", false);
					component.set("v.errorMessage", result.resultMessage);
					component.set("v.spinnerControl", false);
				}
            }else{
                helper.showToast(component, $A.get("$Label.c.XC_CL_CreateCaseMessageError"), "error"); 
				component.set("v.isOpen", true);
				component.set("v.spinnerControl", false);
            }
		});

		$A.enqueueAction(action);
	},
    
    close :  function(component, event, helper) {
        console.log("IN close");
        $A.get("e.force:closeQuickAction").fire();
    },

    showToast : function(component, message, type) {
        component.find('notifLib').showToast({
            "title": message,
            "message": '',
            "variant": type
        });
        $A.get("e.force:closeQuickAction").fire();
    }
})