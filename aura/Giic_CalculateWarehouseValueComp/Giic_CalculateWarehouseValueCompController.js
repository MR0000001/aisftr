({
	doInit : function(component, event, helper) {
        var action = component.get("c.calculateValueForWHPage");
       action.setParams({ whId : component.get("v.recordId") });
        //Setting the Callback
        action.setCallback(this, function(a) {
            
            var state = a.getState();
             //check if result is successfull 
            if (state == "SUCCESS") {
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
                component.set('v.showSpinner',false);
            } else if (state == "ERROR") {
                component.set('v.defaultValue','Error while calculating');
                component.set('v.showSpinner',false);
                //alert("Error in calling server side action");
            }
        });
        
        //adds the server-side action to the queue
        $A.enqueueAction(action);
	}
})