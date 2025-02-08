({
	init: function (component, event, helper) {
		component.set("v.spinnerControl", true);
		let action = component.get("c.getSupplier");
		action.setParams({
			'recordId': component.get("v.recordId")
		});
		action.setCallback(this, function (response) {
			let state = response.getState();
			if (state === "SUCCESS") {
				let result = response.getReturnValue();
				if (result.success == true) {
					component.set("v.supplierRepair", result.supplierRepair);
					component.set("v.supplierInsurance", result.supplierInsurance);
				} else {
					component.set("v.isError", true);
					component.set("v.errorMessage", 'Error!');
				}
			}
		});
		$A.enqueueAction(action);
	}
})