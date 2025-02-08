({
    doInit: function (component, event, helper) {
        console.log('init');
        component.set("v.showSpinner", true);
        helper.doInit(component, event, helper);
    },

    handleSave : function(component, event, helper) {
        component.set("v.showSpinner", true);
        let button = component.find('saveButtonId');
        button.set('v.disabled',true);
        helper.handleSave(component, event, helper);
	},

    handleCancel: function(component, event, helper) {
        helper.handleCancel(component);
	},

    handleSecondaryContactChange: function(component, event, helper) {
        helper.handleSecondaryContactChange(component, event, helper);
        helper.checkFields(component, event, helper);
	},

    handleSuccessSecondary: function(component, event, helper) {
        helper.handleSuccessSecondary(component, event, helper);
	},

    handleSuccessPrimary: function(component, event, helper) {
        helper.handleSuccessPrimary(component, event, helper);
	},

    checkFields: function(component, event, helper) {
        helper.checkFields(component, event, helper);
	}
    
})