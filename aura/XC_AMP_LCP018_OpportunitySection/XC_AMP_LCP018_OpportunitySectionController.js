({
	init : function(component, event, helper) {
		helper.doInit(component, event, helper);
	},

	loadREForm : function(component,event,helper){
		helper.loadPredefaultValues(component,event,helper);
		component.set("v.spinnerControl", false);
    },
    
    validateData : function(component,event,helper) {
        helper.validateData(component,event,helper);
    }

})