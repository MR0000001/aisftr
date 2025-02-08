({
	doInit : function(component, event, helper) {    
		component.set("v.spinnerControl",true);      
		var recordId = component.get("v.recordId"); 
		var action = component.get("c.checkSplittingPossibility"); 		
		action.setParams({
			"recordId": recordId
		});
		action.setCallback(this, function(a) {         
			var result = a.getReturnValue(); 
			console.log("@@@ Result is: " + result.success + " And record is: " + recordId);
			if(result.success == false) {   
				helper.showToast(component, event, helper, result.resultMessage, "error");
				component.set("v.spinnerControl", false);
				$A.get('e.force:closeQuickAction').fire();
				
			} else { 
				this.checkHierAndSplit(component,event,helper);               
				
			}                   
		});
		$A.enqueueAction(action);    
	},

	checkHierAndSplit : function(component, event, helper){
		var recordId = component.get("v.recordId"); 
		var action = component.get("c.checkHierarchyLevelAndSplit"); 		
		action.setParams({
			"recordId": recordId
		});
		action.setCallback(this, function(a) {         
			var result = a.getReturnValue(); 
			console.log("@@@ Result is: " + result.success + " And record is: " + recordId);
			if(result.success == false){   
				helper.showToast(component, event, helper, result.resultMessage, "error");
				component.set("v.spinnerControl", false);
				$A.get('e.force:closeQuickAction').fire();
				
			} else { 
				helper.showToast(component, event, helper, $A.get("$Label.c.XC_CL_WorkOrderSplitted"), "success");
				component.set("v.spinnerControl", false);
				$A.get('e.force:closeQuickAction').fire(); 
			    var navigateEvent = $A.get("e.force:navigateToSObject");
				navigateEvent.setParams({ "recordId": result.recordId, "slideDevName": "detail", "isredirect":true });            
				navigateEvent.fire();
				var delay=700; 
                setTimeout(function(){
					$A.get('e.force:refreshView').fire();
				}, delay);
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