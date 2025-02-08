/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 27/06/2019
* @description XC_LCP122_LeadConversion – Component for Lead conversion
*/

({
	doInit: function (component, event, helper) {
		component.set("v.spinnerControl", true);
		let leadId = component.get('v.recordId');
		console.log('@@@ Lead ---> ' + leadId);
		let action = component.get("c.retrieveLead");
		action.setParams({
			'leadId': leadId
		});

		action.setCallback(this, function (a) {
			let state = a.getState();
			let result = a.getReturnValue();
			console.log('@@@ State init ---> ' + state);
			component.set("v.spinnerControl", false);
			if (state === "ERROR" || result == null) {
				let toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
					title: $A.get("$Label.c.XC_CL_LeadConvert_Error"),
					message: $A.get("$Label.c.XC_CL_LeadConvert_Check_Data"),
					key: 'info_alt',
					type: 'error',
					mode: 'dismissible',
					mode: 'pester'
				});
				$A.get('e.force:closeQuickAction').fire();
				toastEvent.fire();
			}
			if (result.isErrorValidation) {
				let toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
					title: $A.get("$Label.c.XC_CL_LeadConvert_Error"),
					message: result.errorMessage,
					key: 'info_alt',
					type: 'error',
					mode: 'dismissible',
					mode: 'pester'
				});
				$A.get('e.force:closeQuickAction').fire();
				toastEvent.fire();
			}
			else {
				console.log('@@@ Result init ---> ', result);
				component.set('v.lead', result.lead);
				if(result.lead.XC_LeadRecordType__c.includes('SFM')){
					component.set('v.isSFMLead', true);
					console.log('@@@ is SFM Lead? ' + component.get('v.isSFMLead'));
				}
				//if (result.lead.XC_LeadRecordType__c == $A.get("$Label.c.XC_CL_Lead_Residential")) {
				component.set('v.emailContact', result.lead.XC_EmailCustom__c);
				//} else {
				//	component.set('v.emailContact', result.lead.XC_ContactEmail__c);
				//}
				component.set('v.wrapperResult', result);
				if (result.contactExists) {
					component.set('v.contactFound', true);
					component.set('v.contact', result.contact);
					component.set('v.contactExists', 'action:approval');
					component.set('v.contactExistsText', $A.get("$Label.c.XC_CL_LeadConv_MessContExists"));
				} else {
					component.set('v.contactExists', 'action:new');
					component.set('v.contactExistsText', $A.get("$Label.c.XC_CL_LeadConv_MessContNew"));
				}
				if (result.accountExists) {
					component.set('v.accountFound', true);
					component.set('v.account', result.account);
					component.set('v.accountExists', 'action:approval');
					component.set('v.accountExistsText', $A.get("$Label.c.XC_CL_LeadConv_MessAccExists"));
				} else {
					component.set('v.accountExists', 'action:new');
					component.set('v.accountExistsText', $A.get("$Label.c.XC_CL_LeadConv_MessAccNew"));
				}
				component.set('v.type', result.type);

				console.log('@@@ accountFound ---> ', component.get('v.accountFound'));
				console.log('@@@ contactFound ---> ', component.get('v.contactFound'));
				console.log('@@@ accountFoundVal ---> ', result.account);
				console.log('@@@ contactFoundVal ---> ', result.contact);
			}
		});
		$A.enqueueAction(action);
	},

	convert: function (component, event, helper) {
		console.log('@@@ Start converter');
		component.set("v.spinnerControl", true);
		var wrapper = component.get('v.wrapperResult');
		let createOpportunity = component.get('v.createOpportunity');
		console.log('@@@ For wrapper --->', wrapper);

		if (createOpportunity) {
			if (!wrapper.canCreateOpportunity) {
				if (wrapper.addressBlank) {
					let toastEvent = $A.get("e.force:showToast");
					toastEvent.setParams({
						title: $A.get("$Label.c.XC_CL_LeadConvert_Error"),
						message: $A.get("$Label.c.XC_CL_LeadConvert_Check_Lead_Address"),
						key: 'info_alt',
						type: 'error',
						mode: 'dismissible',
						mode: 'pester'
					});
					$A.get('e.force:closeQuickAction').fire();
					toastEvent.fire();
				}
				else {
					let toastEvent = $A.get("e.force:showToast");
					toastEvent.setParams({
						title: $A.get("$Label.c.XC_CL_LeadConvert_Error"),
						message: $A.get("$Label.c.XC_CL_LeadConvert_Check_Lead_ProdCategory"),
						key: 'info_alt',
						type: 'error',
						mode: 'dismissible',
						mode: 'pester'
					});
					$A.get('e.force:closeQuickAction').fire();
					toastEvent.fire();
				}
			}
		} else {
			if (wrapper.mustCreateOpportunity) {
				let toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
					title: $A.get("$Label.c.XC_CL_LeadConvert_Error"),
					message: $A.get("$Label.c.XC_CL_LeadConvert_Mandatory_Opp"),
					key: 'info_alt',
					type: 'error',
					mode: 'dismissible',
					mode: 'pester'
				});
				$A.get('e.force:closeQuickAction').fire();
				toastEvent.fire();
			}
		}

		wrapper.createOpportunity = createOpportunity;
		if(wrapper.account.Contacts && !wrapper.account.Contacts.hasOwnProperty('records')) {
			let tempArray = wrapper.account.Contacts;
			wrapper.account.Contacts = {
				totalSize: tempArray.length,
				done: true,
				records: tempArray
			}
		}
		let jsonString = JSON.stringify(wrapper);
		console.log('@@@ jsonString ---> ', jsonString);
        debugger;
		let action = component.get("c.conversionForRecordType");
		action.setParams({
			'wrapperString': jsonString
		});
		action.setCallback(this, function (a) {
			let state = a.getState();
			let result = a.getReturnValue();
            debugger;
			console.log('@@@ State convert ---> ' + state);
			console.log('@@@ result ---> ', result);
			component.set("v.spinnerControl", false);
			if (state == "ERROR" || result == null) {
				console.log('@@@ Error!');
				let toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
					title: $A.get("$Label.c.XC_CL_LeadConvert_Error"),
					message: $A.get("$Label.c.XC_CL_LeadConvert_Check_Data"),
					key: 'info_alt',
					type: 'error',
					mode: 'dismissible',
					mode: 'pester'
				});
				$A.get('e.force:closeQuickAction').fire();
				toastEvent.fire();
			}
			else if (!result.success) {
				console.log('@@@ Error ---> ' + result.errorMessage);
				let toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
					title: $A.get("$Label.c.XC_CL_LeadConvert_Error"),
					message: result.errorMessage,
					key: 'info_alt',
					type: 'error',
					mode: 'dismissible',
					mode: 'pester'
				});
				$A.get('e.force:closeQuickAction').fire();
				toastEvent.fire();
			}
			else {
				console.log('@@@ Lead converted');
				component.set('v.account', result.account);
				component.set('v.contact', result.contact);
				component.set('v.opportunity', result.opportunity);
				component.set('v.community', result.community);
				helper.handleClick(component, event, helper, result.warningMessage);
				console.log('@@@ End');
			}
		});
		$A.enqueueAction(action);
	},

	handleClick: function (component, event, helper, warningMessage) {
		console.log('@@@ In handleClick');

		let mapForLead = {
			'account': component.get('v.account'),
			'contact': component.get('v.contact'),
			'opportunity': component.get('v.opportunity'),
			'opportunityCreated': component.get('v.createOpportunity'),
			'community': component.get('v.community'),
			'type': component.get('v.type'),
			'productCategoryOfInterest': component.get('v.lead').MyCategoryOfInterest
		}
		console.log('@@@ mapForLead ---> ', mapForLead);
		let mapForLeadString = JSON.stringify(mapForLead);
		console.log('@@@ mapForLeadString ---> ', mapForLeadString);


		var modalBody;
		$A.createComponents([
			[
				"c:XC_LCP128_LeadConverted",
				{
					'mapForLeadString': mapForLeadString,
					'warningMessage': warningMessage
				}
			]
		],
			function (components, status, errorMessage) {
				if (status === "SUCCESS") {
					console.log('[CALL COMPONENT] ----> ', status);
					modalBody = components[0];
					component.find('overlayLib').showCustomModal({
						header: $A.get("$Label.c.XC_CL_LeadConvert_Lead_Converted"),
						body: modalBody,
						showCloseButton: false,
						closeCallback: function () {
							//document.location.reload(true);
							$A.get('e.force:closeQuickAction').fire();
						}
					})
				}
				else {
					console.log('[WARNING COMPONENT] ----> ', status);
					console.log('[ERROR MESSAGE] ----> ', errorMessage);
				}
				//$A.get('e.force:closeQuickAction').fire();
			}
		);
		
	}

})