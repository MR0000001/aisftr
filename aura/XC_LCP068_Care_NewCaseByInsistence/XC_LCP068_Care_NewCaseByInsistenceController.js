({
	doInit: function (cmp, event, helper) {
		helper.doInit(cmp, event, helper);
	},
	newRequest: function (cmp, event, helper) {
		helper.newRequest(cmp, event, helper);
		console.log("newRequest");
	},
	validateWorkOrder: function (cmp, event, helper) {
		helper.validateWorkOrder(cmp);
		console.log("validateWorkOrder");

	}, 
	openModel: function (cmp, event, helper) {
		helper.openModel(cmp);
		console.log("openModel");
	},
	closeModel: function (cmp, event, helper) {
		helper.closeModel(cmp);
		console.log("closeModel");
	},
	refreshModel: function (cmp, event, helper) {
		helper.refreshModel(cmp);
		console.log("refreshModel");
	}
})