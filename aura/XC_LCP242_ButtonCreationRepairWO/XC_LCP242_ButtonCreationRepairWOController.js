({
    doInit: function (component, event, helper) {
        helper.doInit(component, event, helper);
    },

    handleSubtypeChange : function(component, event, helper) {
		helper.handleSubtypeChange(component, event, helper);
	},

    handleSubmit : function(component, event, helper) {
        let button = component.find('createButtonId');
        button.set('v.disabled',true);
        component.set("v.showSpinner", true);
        helper.handleSubmit(component, event, helper);
	},

    handleCancel: function(component, event, helper) {
        helper.redirectToCase(component);
	}
  
})