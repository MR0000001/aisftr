({
	init : function(component, event, helper) {
        
        let action = component.get("c.retrieveInformation");
        action.setParams({
            'caseId' : component.get("v.recordId")
        });
        action.setCallback(this, function(a) {
            let state = a.getState();
            if (state === "SUCCESS"){
                let result = a.getReturnValue();

                component.set("v.partner", result.PartnersName);
                component.set("v.pec", result.PEC);
                component.set("v.sap", result.SAPContract);
                component.set("v.workorder", result.WorkOrder);
                component.set("v.customer", result.Customer);
                component.set("v.inspectionDate", result.InspectionDate);
                component.set("v.inspectionLocation", result.InspectionLocation);
                component.set("v.summary", result.Summary);

                component.set("v.legalEntity", result.LegalEntity);

                component.set("v.nocheck", result.ChecklistError); //err           
                
                component.set("v.canSend", result.CanSendPec); //err     
            }
            component.set('v.showSpinner', false)
        });            
        $A.enqueueAction(action);
		
	}, 

    send : function(component, event, helper) {
        
        if(!component.find("pec").checkValidity()){
            component.find("pec").reportValidity();
            return;
        }

        let action = component.get("c.sendPec");

        let req = {
            PartnersName : component.get("v.partner"), 
            PEC : component.get("v.pec"), 
            SAPContract : component.get("v.sap"), 
            WorkOrder : component.get("v.workorder"),
            Customer : component.get("v.customer"), 
            InspectionDate : component.get("v.inspectionDate"), 
            InspectionLocation : component.get("v.inspectionLocation"),
            Summary: component.get("v.summary"),
            CaseId : component.get("v.recordId"),
            LegalEntity : component.get("v.legalEntity")
        };

        action.setParams({
            'req' : JSON.stringify(req)
        });
        action.setCallback(this, function(a) {
            let state = a.getState();
            if (state === "SUCCESS"){
                let result = JSON.parse(a.getReturnValue());

                if(!result.Result || result.Result.error_code != '0'){
                    helper.showMessage(component, "error", $A.get('$Label.c.XC_CL_Warning'), $A.get('$Label.c.XC_CL_NotificationError'));
                } else {
                    helper.showMessage(component, "info", $A.get('$Label.c.XC_CL_Success'), $A.get('$Label.c.XC_CL_NotificationInProgress'));
                }
                component.set('v.showSpinner', false)

            } else {
                helper.showMessage(component, "error", $A.get('$Label.c.XC_CL_Warning'), $A.get('$Label.c.XC_CL_NotificationError'));
                component.set('v.showSpinner', false)
            }
            
        });            
        $A.enqueueAction(action);
        component.set('v.showSpinner', true)

        
    },

    showMessage: function (component, event, helper, message, type) {
        component.set("v.showSpinner", false);
        if (type === 'info') {
            type = 'success';
        }

        let toastEvent = $A.get("e.force:showToast");

        toastEvent.setParams({
            message: message,
            type: type,
            mode: "pester"
        });
        toastEvent.fire();
    
    }

})