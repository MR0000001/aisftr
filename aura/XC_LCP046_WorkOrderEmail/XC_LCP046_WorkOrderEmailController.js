({
	init : function(component, event, helper) {
        component.set("v.customerInteraction.workorderId", component.get("v.recordId"));
        component.set("v.spinnerControl" , true);
        
        helper.checkPossibilityToCreate(component,event,helper);
    },
    
    cancel : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
    }
})