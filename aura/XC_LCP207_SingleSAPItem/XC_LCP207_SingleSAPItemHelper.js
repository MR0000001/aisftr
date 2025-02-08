({
	saveLineValues : function(component, event, helper) {
        component.set('v.showSpinner',true);
        component.set("v.category","P");
		var options = {
            purchaseOrderId : component.get("v.purchaseOrderId"),
            polId : component.get("v.polId"),
            applicantUnit : component.get("v.applicantUnitDefault"),
            category : component.get("v.category"),
            division : component.get("v.division"),
            definitionOfDivision : component.get("v.definitionOfDivision"),
            purchaseOrganization : component.get("v.purchaseOrganization"),
            definitionOfPurchaseOrganization : component.get("v.definitionOfPurchaseOrganization")
        }
      
        var optionsJSON = JSON.stringify(options);
        var action = component.get("c.updatePOLine");
        action.setParams({"polData": optionsJSON});
        action.setCallback(this, function(response) {
            var state = response.getState();
            var res =   response.getReturnValue();
            if (state === "SUCCESS" && res.success) {
            	 helper.showToast(component, event, helper, 'Success', 'success');

            }else{
                 helper.showToast(component, event, helper, res.resultMessage, 'error');
            }
            
             component.set('v.showIcon', true);
             component.set('v.showSpinner',false);
        });    
        $A.enqueueAction(action);    
                
	},
    
    
    showToast : function(component, event, helper, message, type) {
        component.find('notifLib').showToast({
            "title": message,
            "message": '',
            "variant": type
        });
    }
    
    
})