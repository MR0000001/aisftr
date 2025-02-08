({
	doInit: function (component, event, helper) {
		helper.init(component, event, helper);
	},

	saveSelectValue: function (component, event, helper) {
		var selectedOptionValue = event.getParam("value");
		component.set("v.selectedValue", selectedOptionValue);
		console.log("--->select : " + selectedOptionValue);
	},

	assign: function (component, event, helper) {
		helper.assignToNationalPartner(component, event, helper);
	}
})