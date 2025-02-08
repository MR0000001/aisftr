({
    doInit  : function(component, event, helper) {
        helper.init(component, event, helper);		
    },
    
    closeModal : function(component, event, helper) {
      
            $A.get("e.force:closeQuickAction").fire();
    },
      saveCancellation : function (component, event, helper) {
        component.set("v.showSpinner" , true);
        helper.saveReason(component, event, helper) ;
        
    },
    onChangeReason: function (component, event, helper) {
        var val = event.getSource().get('v.value');
	    console.log('@@@@ reason:' + val);
		component.set("v.reason", val); 
    }
})