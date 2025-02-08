({
	init : function(component, event, helper) {
		helper.checkPromocodeApplication(component, event, helper);
	},

	closeModal: function(component, event, helper) {
		component.set("v.isPromocodeApplicationWarning", false);
		// Close the quick action
        var closeQuickAction = $A.get("e.force:closeQuickAction");
        closeQuickAction.fire();
	 },
	
	 okPromocode: function(component, event, helper) {
		component.set("v.isPromocodeApplicationWarning", false);
		helper.initNextStep(component, event, helper);
	 }
})