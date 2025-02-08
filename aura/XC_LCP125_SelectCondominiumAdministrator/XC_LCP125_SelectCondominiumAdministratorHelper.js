({
	savePrimary : function(component, event, helper) {
        
        let action = component.get("c.updateAdministrator");
        
        action.setParams({
            contactId : component.get("v.contactId"),
            accountId : component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var retValue = response.getReturnValue();
             
            if (state === "SUCCESS" && retValue.success) {
                 helper.showToast(component, event, helper, 'Administrator correctly changed', 'success') ;
            }else{
                 helper.showToast(component, event, helper, retValue.resultMessage, 'error') ;
            }
             $A.get('e.force:closeQuickAction').fire();

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