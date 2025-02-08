({
	doInit : function(component, event, helper) {
		helper.init(component, event);
	},

	doSubmit : function(component, event, helper) {
		helper.submit(component, event);
	},

	doClose : function(component, event, helper) {
		helper.close(component, event);
	},

	doCheckValueNotEmpty : function(component, event, helper) {
		helper.checkValueNotEmpty(component, event);
	}
})