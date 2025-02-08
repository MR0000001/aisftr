({
    init : function(component, event, helper) {
		helper.init(component, event, helper);
	},

	handleMandatoryInput : function(component, event, helper) {
		if($A.util.isEmpty(component.get("v.contractNumber")) || $A.util.isEmpty(component.get("v.percentage")) || $A.util.isEmpty(component.get("v.symbol"))) {
			component.set("v.disableSearch", true);
		} else {
			component.set("v.disableSearch", false);
		}
	},

	handleSearch : function(component, event, helper) {
		component.set("v.showSpinner", true);
		component.set("v.searchPressed", true);
		helper.handleSearch(component, event, helper);
	},

	handleAdjust: function(component, event, helper) {
		component.set("v.showSpinner", true);
		helper.handleAdjust(component, event, helper);
	}
})