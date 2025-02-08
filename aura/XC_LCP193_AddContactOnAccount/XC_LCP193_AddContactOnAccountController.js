({
	doInit : function(component, event, helper) {
        helper.doInit(component, event, helper);
	},

    closeModal : function(component, event, helper) {
        //component.destroy() ;
        $A.get("e.force:closeQuickAction").fire();

	},
	
	changeData : function(component, event, helper) {
        if(component.get("v.contactValue") === ''){
			component.set("v.disableConfirm", true);
		}
		else{
			component.set("v.disableConfirm", false);
		}
    },

    onConfirm : function(component, event, helper) {
        helper.handleSubmit(component, event, helper) ;
    }

})