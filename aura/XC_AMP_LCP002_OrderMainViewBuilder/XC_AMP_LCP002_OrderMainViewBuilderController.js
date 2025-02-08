({
	init : function(component, event, helper) {
		helper.doInit(component, event, helper);
	},
	
	handleAMPCommunicationEvent : function(component, event, helper) {
		helper.handleChildCommunicationEvent(component,event,helper);
	},

	submitSections : function(component,event,helper){
		helper.submitSections(component,event,helper);
	},

	handleAMPSimpleFlowNextStep : function(component, event, helper) {
		component.set("v.showOrderSection",false);
		component.set("v.showSubmit",false);
		let nextStep = event.getParam('nextStep');
		if(nextStep === 'InitSimpleSales'){
			$A.createComponent(
				"c:XC_AMP_LCP020_SimplifiedSales", {
				"aura:id": 'SimplifiedSalesComp',
				"recordId": component.get("v.parentOpportunityId")
			},
				function (newInp, status, errorMessage) {
					if (status === "SUCCESS") {
						var body = []; // component.get("v.body");
						body.push(newInp);
						component.set("v.body", body);
					} else if (status === "INCOMPLETE") {
						console.log("No response from server or client is offline.")
					} else if (status === "ERROR") {
						console.log("Error: " + errorMessage);
					}
				}
			);
		}
	},
	
	cancel : function(component, event, helper) {
		let currentURL = window.location.href;
		let baseURL = currentURL.substring(0, currentURL.indexOf("/s"));
		window.location.replace(baseURL+"/s");  
    }
})