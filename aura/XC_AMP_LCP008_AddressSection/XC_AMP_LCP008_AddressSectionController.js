({
	init : function(component, event, helper) {
		helper.doInit(component, event, helper);
	},

	loadREForm : function(component,event,helper){
		component.set("v.spinnerControl", false);
    },
    
    handleAddressEvent : function(component,event,helper){
        helper.handleAddressEvent(component,event,helper);
    }
})