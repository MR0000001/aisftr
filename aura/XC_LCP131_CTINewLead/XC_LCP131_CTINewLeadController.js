({
	createLead : function(component,event,helper){
		helper.createChooseRtNewLead(component,event,helper);
	},
	createAccount : function(component,event,helper){
		helper.createChooseRtNewAccount(component,event,helper);
	},
	createModalRecord : function(component,event,helper){
		helper.createLeadAccountModal(component,event,helper);
	},
	handleCancel : function(component,event,helper){
		helper.handleCancel(component,event,helper);
	},
	handleCancelOpty : function(component,event,helper){
		helper.handleCancelOpty(component,event,helper);
	},
	init : function(component,event,helper){
		let phoneKey = component.get("v.interactionRecord.XC_Phone__c");
		let contactId = component.get("v.interactionRecord.XC_ContactId__c");
        let phonePre = component.get("v.interactionRecord.XC_Customer_Phone_Prefix__c");

		if(contactId){
			component.set("v.hasContact",true);
		}else{
			component.set("v.hasContact",false);
		}

		console.log('PHONE KEY::: ' + phoneKey);
		component.set('v.interactionPhone',phoneKey);
        component.set('v.interactionPhonePrefix',phonePre);
	},
	showScriptModal : function(component,event,helper){
		component.set("v.showScriptModal",true);
	},
	createOpportunity : function(component,event,helper){
		helper.openOpportunitySubTab(component,event,helper);
	},
	closeChildComponent : function(component,event,helper){
		helper.handleCancelOpty(component,event,helper);
	}




})