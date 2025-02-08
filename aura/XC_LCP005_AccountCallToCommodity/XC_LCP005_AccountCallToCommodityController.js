({
	init : function(component, event, helper) { 
		helper.doInit(component, event, helper);
	},

	handleSaveSectionEvent : function(component, event, helper) {
		//helper.saveSectionEvent(component, event, helper);
	},
	
    handlePress: function (component, event, helper) {
       helper.handlePress (component, event, helper); 
	},
	saveNameAndSurname: function(component, event, helper){
		let action = component.get("c.saveNameSurname");
		let resultList = JSON.stringify( component.get("v.resultList"));
		let recordId = component.get("v.recordId");
		action.setParams({'resultListString' : resultList, 'recordId' : recordId });
		action.setCallback(this, function (response) {
			let state = response.getState();
			let responseResult = response.getReturnValue();
			console.log('@@@@ response andrea ' + JSON.stringify(response) );
            if (component.isValid() && state === "SUCCESS") {
                
                if (responseResult.success) {
                    helper.showToast(component, responseResult.resultMessage, 'success');
                } else {
                    helper.showToast(component, responseResult.resultMessage, 'error');
                }
            } else {
                helper.showToast(component, $A.get("$Label.c.XC_CL_ErrorsOccurred"), 'error');
            }
            component.set('v.spinnerControl', false);
        });
		$A.enqueueAction(action);
    },
	savePrimaryPhoneHandler: function(component, event, helper){
		let action = component.get("c.savePrimaryPhone");
		let resultList = JSON.stringify( component.get("v.resultList"));
		let recordId = component.get("v.recordId");
		action.setParams({'resultListString' : resultList, 'recordId' : recordId });
		action.setCallback(this, function (response) {
			let state = response.getState();
			let responseResult = response.getReturnValue();
			console.log('@@@@ response andrea ' + JSON.stringify(response) );
            if (component.isValid() && state === "SUCCESS") {
                
                if (responseResult.success) {
                    helper.showToast(component, responseResult.resultMessage, 'success');
                } else {
                    helper.showToast(component, responseResult.resultMessage, 'error');
                }
            } else {
                helper.showToast(component, $A.get("$Label.c.XC_CL_ErrorsOccurred"), 'error');
            }
            component.set('v.spinnerControl', false);
        });
		$A.enqueueAction(action);
    },
	saveSecondaryPhoneHandler: function(component, event, helper){
		let action = component.get("c.saveSecondaryPhone");
		let resultList = JSON.stringify( component.get("v.resultList"));
		let recordId = component.get("v.recordId");
        action.setParams({'resultListString' : resultList, 'recordId' : recordId });
		action.setCallback(this, function (response) {
			let state = response.getState();
			let responseResult = response.getReturnValue();
            if (component.isValid() && state === "SUCCESS") {
                
                if (responseResult.success) {
                    helper.showToast(component, responseResult.resultMessage, 'success');
                } else {
                    helper.showToast(component, responseResult.resultMessage, 'error');
                }
            } else {
                helper.showToast(component, $A.get("$Label.c.XC_CL_ErrorsOccurred"), 'error');
            }
            component.set('v.spinnerControl', false);
        });
		$A.enqueueAction(action);
    },
	saveEmailHandler: function(component, event, helper){
		let action = component.get("c.saveEmail");
		let email = event.getSource().get("v.value");
		let recordId = component.get("v.recordId");
		action.setParams({'email' : email, 'recordId' : recordId });
		action.setCallback(this, function (response) {
			let state = response.getState();
			let responseResult = response.getReturnValue();
			console.log('@@@@ response andrea ' + JSON.stringify(response) );
            if (component.isValid() && state === "SUCCESS") {
                
                if (responseResult.success) {
                    helper.showToast(component, responseResult.resultMessage, 'success');
                } else {
                    helper.showToast(component, responseResult.resultMessage, 'error');
                }
            } else {
                helper.showToast(component, $A.get("$Label.c.XC_CL_ErrorsOccurred"), 'error');
            }
            component.set('v.spinnerControl', false);
        });
		$A.enqueueAction(action);
    },
})