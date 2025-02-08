({
	init: function (component, event, helper) {
		let recordId = component.get("v.recordId");
		let action = component.get("c.getPickListValues");
		action.setParams({
			'recordId': component.get("v.recordId")
		});
		action.setCallback(this, function (response) {
			let state = response.getState();
			if (state === "SUCCESS") {
				let result = response.getReturnValue();
				if (result.length == 0) {
					let toastEventWarn = $A.get("e.force:showToast");
					toastEventWarn.setParams({
						title: $A.get("$Label.XC_CL_Warning"),
						mode: 'dismissible',
						mode: 'pester',
						key: 'info_alt',
						type: 'error',
						message: $A.get("$Label.c.XC_CL_RecreateDocument_NoDoc")
					});
					//$A.get('e.force:closeQuickAction').fire();
					component.set("v.spinnerControl", false);
					toastEventWarn.fire();

					$A.get('e.force:closeQuickAction').fire();
				} else {
					var options = [];
					result.forEach(function (element) {
						options.push({ value: element, label: element });
					});
					component.set("v.documentList", options);
				}
			}
			component.set("v.showSpinner", false);
		});
		$A.enqueueAction(action);

	},

	callCongaHelper: function (component, event, helper) {
		let action = component.get("c.startCongaFromButton");
		action.setParams({
			'templateName': component.get("v.selectedValue"),
			'recordId': component.get("v.recordId")

		});
		action.setCallback(this, function (response) {
			let state = response.getState();
			if (state === "SUCCESS") {
				let result = response.getReturnValue();
				if (result.success == true) {
					let toastEventWarnSucc = $A.get("e.force:showToast");
					toastEventWarnSucc.setParams({
						title: $A.get("$Label.XC_CL_Warning"),
						mode: 'dismissible',
						mode: 'pester',
						key: 'info_alt',
						type: 'success',
						message: $A.get("$Label.c.XC_CL_ReCreateDocumentSuccessMessage")
					});
					//$A.get('e.force:closeQuickAction').fire();
					component.set("v.spinnerControl", false);
					toastEventWarnSucc.fire();

				} else {
					let toastEventWarn = $A.get("e.force:showToast");
					toastEventWarn.setParams({
						title: $A.get("$Label.XC_CL_Warning"),
						mode: 'dismissible',
						mode: 'pester',
						key: 'info_alt',
						type: 'error',
						message: result.errorMessage
					});
					//$A.get('e.force:closeQuickAction').fire();
					component.set("v.spinnerControl", false);
					toastEventWarn.fire();
				}
			}
			$A.get('e.force:closeQuickAction').fire();
		});
		$A.enqueueAction(action);
	}
})