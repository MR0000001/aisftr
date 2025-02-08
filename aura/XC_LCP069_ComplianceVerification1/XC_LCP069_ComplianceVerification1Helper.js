({
	complianceVerification1 : function(component, event, helper) {
        let firstAction = component.get("c.checkCompliance1Needed");
        firstAction.setParams({
            'configurationId' : component.get("v.recordId")
        });
        firstAction.setCallback(this, function(response) {
            let state = response.getState();
            if(state === "SUCCESS"){
                let result = response.getReturnValue();
                console.log('@@@ result checkCompliance1Needed ---> ', result);
                if(result) {
                    let action = component.get("c.checkDocumentsComplianceVerification1");
                    action.setParams({
                        'configurationId' : component.get("v.recordId")
                    });
                    action.setCallback(this, function(responseCompliance) {
                        let state = responseCompliance.getState();
                        if (state === "SUCCESS"){
                            let resultComplianceNeeded = responseCompliance.getReturnValue();
                            console.log('@@@ result checkDocumentsComplianceVerification1 ---> ', resultComplianceNeeded);
                            if(resultComplianceNeeded.success) {
                                helper.showToast(component, event, helper,resultComplianceNeeded.resultMessage,'warning');
                                $A.get("e.force:closeQuickAction").fire();
                            } else { 
                                helper.showToast(component, event, helper, resultComplianceNeeded.resultMessage, 'success');
                                $A.get("e.force:closeQuickAction").fire();
                            } 
                        }
                    });
                    $A.enqueueAction(action);
                }
                else{
                    helper.showToast(component, event, helper, $A.get('{!$Label.c.XC_CL_Compliance1Done}'), 'warning');
                    $A.get("e.force:closeQuickAction").fire();
                }
            }
        });
        $A.enqueueAction(firstAction); 
	},

	showToast : function(component, event, helper, message, type) {
        component.find('notifLib').showToast({
            "title": message,
            "message": '',
            "variant": type
        }); 
      
    },
})