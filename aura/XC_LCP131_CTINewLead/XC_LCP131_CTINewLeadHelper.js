({
	createChooseRtNewLead: function (component, event, helper) {


		if(component.get('v.interactionRecord.XC_InteractionStatus__c')=='Close'){

            let msg = $A.get('$Label.c.XC_CL_CTINoLeadOnClosedInteraction');
            helper.showToast('Error',msg,'error');
            return;
        }


		component.set('v.sobjecttype', 'Lead');
		const action = component.get('c.getVisibleRecordType');
		action.setParams({
			'objectType': component.get("v.sobjecttype")
		});

		action.setCallback(this, function (resp) {

			let mapRt = [];
			let result = resp.getReturnValue();

			if (result.length >= 1) {

				for (let i = 0; i < result.length; i++) {
					mapRt.push({
						'label': result[i].Name,
						'value': result[i].Id
					});
				}

				component.set('v.rtOpts', mapRt);

				let cmpTarget = component.find('Modalbox');
				let cmpBack = component.find('Modalbackdrop');
				$A.util.addClass(cmpTarget, 'slds-fade-in-open');
				$A.util.addClass(cmpBack, 'slds-backdrop--open');


			} else {
				//to be managed
			}

		});


		$A.enqueueAction(action);

	},

	createChooseRtNewAccount: function (component, event, helper) {


		if(component.get('v.interactionRecord.XC_InteractionStatus__c')=='Close'){

            let msg = $A.get('$Label.c.XC_CL_CTINoAccountOnClosedInteraction');
            helper.showToast('Error',msg,'error');
            return;
        }

		component.set('v.sobjecttype', 'Account');
		const action = component.get('c.getVisibleRecordType');
		action.setParams({
			'objectType': component.get("v.sobjecttype")
		});

		action.setCallback(this, function (resp) {

			let mapRt = [];
			let result = resp.getReturnValue();

			if (result.length >= 1) {

				for (let i = 0; i < result.length; i++) {
					mapRt.push({
						'label': result[i].Name,
						'value': result[i].Id
					});
				}

				component.set('v.rtOpts', mapRt);

				let cmpTarget = component.find('Modalbox');
				let cmpBack = component.find('Modalbackdrop');
				$A.util.addClass(cmpTarget, 'slds-fade-in-open');
				$A.util.addClass(cmpBack, 'slds-backdrop--open');


			} else {
				//to be managed
			}

		});


		$A.enqueueAction(action);

	},

	openLeadAccountSubTab: function (component, event, helper, params) {

		let workspace = component.find('workspace');
		let parentId = params.parentTabId;
		let componentName = params.componentName;
		let tabLabel = params.tabLabel;
		let rtId = params.rtId;
		let phoneNumber = params.phone;
		let sobject = params.sobject;
        let phonePref = component.get("v.interactionPhonePrefix");
        if(phoneNumber.indexOf(phonePref)>-1){
            phoneNumber = phoneNumber.substring(phoneNumber.indexOf(phonePref)+phonePref.length, phoneNumber.length);
        }

		//TODO: add receiving channels to pre-default

		workspace.openSubtab({
			parentTabId: parentId,
			pageReference: {
				"type": "standard__component",
				"attributes": {
					"componentName": componentName
				},
				"state": {
					"c__qRecordType": rtId,
					"c__Phone": phoneNumber,
                    "c__PhonePrefix": phonePref
				}
			},
			focus: true
		}).then((response) => {

			console.log('OPENSUBTAB SUCCESS::' + JSON.stringify(response));

			workspace.setTabLabel({
				tabId: response,
				label: tabLabel
			});

			//OPEN POPUP FOR RECORDING ON LEAD (ITALY) F.I. 24/02/2020
			if(sobject=='Lead'){
				helper.showPopUpRecordingPane(component,event,helper);
			}

		}).catch((err) => {
			console.log(err);
		});

	},

	createLeadAccountModal: function (component, event, helper) {


		/*Redirect to new lead lightning component in a new tab inside console*/
		let workspace = component.find('workspace');
		let recordtypeId = component.get('v.rtvalueId');
		let sobject = component.get('v.sobjecttype');
		let phoneNumber = component.get('v.interactionRecord.XC_Phone__c');



		let componentName = sobject == "Lead" ? "c__XC_LCP002_NewLead" : "c__XC_LCP003_NewAccount";
		let label = sobject == "Lead" ? "New Lead" : "New Account";

		workspace.getEnclosingTabId().then((resp) => {

			const params = {
				parentTabId: resp,
				componentName: componentName,
				tabLabel: label,
				rtId: recordtypeId,
				phone: phoneNumber,
				sobject : sobject

			};

			helper.handleCancel(component, event, helper);

			console.log("PARAMS FOR OPEN TAB " + JSON.stringify(params));

			helper.openLeadAccountSubTab(component, event, helper, params);

		}).catch((err) => {
			console.log(err)
		});


	},

	handleCancel: function (component, event, helper) {
		let cmpTarget = component.find('Modalbox');
		let cmpBack = component.find('Modalbackdrop');
		$A.util.removeClass(cmpBack, 'slds-backdrop--open');
		$A.util.removeClass(cmpTarget, 'slds-fade-in-open');
	},

	handleCancelOpty: function (component, event, helper) {
		let cmpTarget = component.find('OptyModalBox');
		let cmpBack = component.find('Modalbackdrop');
		$A.util.removeClass(cmpBack, 'slds-backdrop--open');
		$A.util.removeClass(cmpTarget, 'slds-fade-in-open');
	},

	openOpportunitySubTab: function (component, event, helper) {


		if(component.get('v.interactionRecord.XC_InteractionStatus__c')=='Close'){

            let msg = $A.get('$Label.c.XC_CL_CTINoOptyOnClosedInteraction');
            helper.showToast('Error',msg,'error');
            return;
        }


		$A.createComponent('c:XC_LCP028_CreateOppFromContact',{
			"recordId" : component.get("v.interactionRecord.XC_ContactId__c")
		},function(newcomponent, status, errorMessage){
			if(status==="SUCCESS"){
				let body = newcomponent.get("v.body");
				body.push(newcomponent);
				component.set("v.body", body);
				
				let cmpTarget = component.find('OptyModalBox');
				let cmpBack = component.find('Modalbackdrop');
				$A.util.addClass(cmpTarget, 'slds-fade-in-open');
				$A.util.addClass(cmpBack, 'slds-backdrop--open');

			}
		});

	},

	showToast : function(title, message, type) {
        console.log('HELPER,SHOW TOAST');
        let toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            'title': title,
            'message': message,
            'type': type,
            'mode': 'dismissible',
            'duration' : 10000
        });
        toastEvent.fire();
	},

	showPopUpRecordingPane : function(component,event,helper){
		let connId = component.get('v.interactionRecord.XC_Connection_ID__c');
		let paramsMap = {
			"connectionId" : connId
		};
		let popAction = component.get('c.popUpCTIRecordingEvent');
		popAction.setParams({'params' : paramsMap});
		popAction.setCallback(this,function(response){
			if(response.getState()=="SUCCESS"){

				let result = response.getReturnValue();
				if(result){
					console.log('POP UP EVENT SENT');
				}else{
					console.log('ERROR ON SENDING POPUP EVENT ');
				}
			}else{
				let msg = response.getError()[0].message;
				console.log('ERROR ON SENDING POPUP EVENT ' + msg);
			}
		});

		$A.enqueueAction(popAction);

	}



})