({
	doInit : function(component, event, helper) {
        component.set("v.showSpinner" , true);
		helper.init(component, event, helper);
	},
    
    closeModal : function (component, event, helper){
		$A.get("e.force:closeQuickAction").fire();
	},
    
    changeOwnerOrder : function (component, event, helper){
        helper.changeOwner(component, event, helper);
    },
    
    sblok : function (component, event, helper){
    	component.set("v.disabledSubmit" , false);
    },
    getAccountRelatedContact: function (component, event, helper){
        helper.getAccountRelatedContact(component, event, helper);
    }
})