({
	init : function(component, event, helper) {
        
		helper.doInit(component, event, helper);
        
	},
    
    closeModal :  function(component, event, helper) {
         $A.get("e.force:closeQuickAction").fire();
    },
    
    reject :  function(component, event, helper) {
     helper.rejectQuote(component, event, helper);
    }
})