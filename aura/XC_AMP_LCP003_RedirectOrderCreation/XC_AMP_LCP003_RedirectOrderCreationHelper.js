({
	doInit: function (component, event, helper) {
		let action = component.get("c.retrieveRecordTypeId");
		action.setParams({
			'nameRTs': 'XC_GLO_Account_Residential;XC_GLO_Account_Soho' /*XC_GLO_Account_Residential;XC_GLO_Account_Soho*/
		});
		action.setCallback(this, function (resp) {
			let state = resp.getState();
			if (component.isValid() && state === "SUCCESS") {
				let rtList = resp.getReturnValue();
				component.set("v.listRT", rtList);
				if (rtList.length === 1) {
					component.set("v.selectedAccountRT", rtList[0].value);
					helper.initializeView(component, event, helper);
				} else {
					//OPEN MODAL
					component.set("v.showModalSelection", true);
					let modaltargetext = component.find('ExtModal');
					let backdroptargetext = component.find('Modalbackdrop');
					$A.util.addClass(modaltargetext, 'slds-fade-in-open');
					$A.util.addClass(backdroptargetext, 'slds-backdrop--open');
				}
			} else {
				console.log('ERROR IN INIT REDIRECT ORDER ' + JSON.stringify(response.getError()[0]));
			}
			component.set("v.spinnerControl", false);
		});
		$A.enqueueAction(action);
	},

	initializeView: function (component, event, helper) {
		$A.createComponent(
			"c:XC_AMP_LCP002_OrderMainViewBuilder", {
				"accountRecordTypeId": component.get("v.selectedAccountRT")
			},
			function (newcomponent, status, errorMessage) {
				if (status === "SUCCESS") {
					let body = component.get("v.body");
					body.push(newcomponent);
					component.set("v.body", body);
				} else if (status === "INCOMPLETE") {
					console.log("No response from server or client is offline.")
				} else if (status === "ERROR") {
					console.log("Error: " + errorMessage);
				}
			});
	}

})