({
	doInit : function(component, event, helper) {
                var action = component.get("c.updateProdReference");
       action.setParams({ prID : component.get("v.recordId") });
        //Setting the Callback
        action.setCallback(this, function(response) {
            let state = response.getState();  
            let retValue = response.getReturnValue();
             //check if result is successfull 
            if (state==='SUCCESS' && retValue.success ) {
               component.set('v.defaultValue','Success'); 
               
               helper.showToast(component, event, helper, 'Success', 'success');
               
            } else {
                component.set('v.defaultValue',retValue.resultMessage);
                
                helper.showToast(component, event, helper, retValue.resultMessage, 'error') ;
            }
             component.set('v.showSpinner', false);
            $A.get('e.force:refreshView').fire();
             $A.get("e.force:closeQuickAction").fire();
        });
        
        //adds the server-side action to the queue
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