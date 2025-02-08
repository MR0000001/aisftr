({
	init: function (component, event, helper) {
		let recordId = component.get("v.recordId");
		let action = component.get("c.retrieveNationalPartner");
		action.setParams({
			'recordId': component.get("v.recordId")
		});
		action.setCallback(this, function (response) {
			component.set("v.spinnerControl", true);
			let state = response.getState();
			if (state === "SUCCESS") {
				let result = response.getReturnValue();
				if (result.length == 0) {
					component.set("v.showError", true);
					component.set("v.errorMessage", $A.get("$Label.c.XC_CL_AssignToNationalPartnerNoPartner"));
				} else {
					var options = [];
					result.forEach(function (element) {
						options.push({ value: element, label: element });
					});
					component.set("v.partnerList", options);
				}
			}
			component.set("v.spinnerControl", false);
		});
		$A.enqueueAction(action);

	},

	assignToNationalPartner: function (component, event, helper) {
		let action = component.get("c.assignToNationalPartner");
		component.set("v.spinnerControl", true);
		console.log("--->select Helper : " + component.get("v.selectedValue"));
		action.setParams({
			'accountName': component.get("v.selectedValue"),
			'recordId': component.get("v.recordId")

		});
		action.setCallback(this, function (response) {
			let state = response.getState();
			if (state === "SUCCESS") {
				let result = response.getReturnValue();
				if (result.success == true) {
					component.set("v.showSuccess", true);
					component.set("v.errorMessage", $A.get("$Label.c.XC_CL_AssignToNationalPartnerSuccess"));
					component.set("v.spinnerControl", false);
					setTimeout(function () {
						$A.get('e.force:refreshView').fire();
					}, 4000);

				} else {
					component.set("v.showError", true);
					component.set("v.errorMessage", result.message);
					component.set("v.spinnerControl", false);
				}
			}
		});

		$A.enqueueAction(action);
	}
})