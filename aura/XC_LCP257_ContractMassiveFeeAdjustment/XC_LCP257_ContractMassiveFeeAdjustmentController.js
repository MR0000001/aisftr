({
    init : function(component, event, helper) {
		helper.init(component, event, helper);
	},

	handleMandatoryInput : function(component, event, helper) {
		if($A.util.isEmpty(component.get("v.priceBand")) || $A.util.isEmpty(component.get("v.contractZone")) || 
				$A.util.isEmpty(component.get("v.symbol")) || $A.util.isEmpty(component.get("v.percentage"))) {
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

	handleSelect : function(component, event, helper) {
		helper.handleSelect(component, event, helper);
	},

	handleAdjust: function(component, event, helper) {
		component.set("v.showSpinner", true);
		helper.handleAdjust(component, event, helper);
	}
})