({
    
    init : function(component, event, helper) {
   	 	helper.waitAndCloseModel(component, event);
    },
    
	closeModel : function(component, event, helper) {
   	 	helper.closeModel(component, event);
    }
})