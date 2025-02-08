({
	doInit: function (component, event, helper) {
		helper.init(component, event, helper);
	},

	saveSelectValue: function (component, event, helper) {
		var selectedOptionValue = event.getParam("value");
		component.set("v.selectedValue", selectedOptionValue);
	},

	callConga: function (component, event, helper) {
		helper.callCongaHelper(component, event, helper);
	}
})