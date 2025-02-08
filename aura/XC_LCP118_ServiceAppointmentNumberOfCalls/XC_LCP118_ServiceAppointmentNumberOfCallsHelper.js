({
	doInit : function(component, event, helper) {    
		component.set("v.spinnerControl",true);      
		var recordId = component.get("v.recordId"); 
		var action = component.get("c.increaseNumberOfCalls"); 		
		action.setParams({
			"recordId": recordId
		});
		action.setCallback(this, function(a) {         
			var result = a.getReturnValue(); 
			console.log("@@@ Result is: " + result.success + " And record is: " + recordId);
			
			if(result.success) {   
				helper.showToast(component, event, helper, $A.get("$Label.c.XC_CL_NumberOfCallsIncrese"), "success");
				component.set("v.spinnerControl", false);
				$A.get('e.force:closeQuickAction').fire();
				$A.get('e.force:refreshView').fire();
				
			} else {                
				helper.showToast(component, event, helper, result.resultMessage, "error");
				component.set("v.spinnerControl", false);
				$A.get('e.force:closeQuickAction').fire();
			}                   
		});
		$A.enqueueAction(action);    
	},

	showToast : function(component, event, helper, message, type) {
		component.set("v.spinnerControl",false);
		component.find('notifLib').showToast({
			"title": message,
			"message": '',
			"variant": type
		});
	}	
})