({
    handleSelectHelper : function (component, event) {
        let stepName = event.getParam("detail").value;
        let toastEvent = $A.get("e.force:showToast");
        
        let WarningMessage = $A.get("$Label.c.XC_CL_Account_TransitionErrorMessage");
        let takeChargeMess = $A.get("$Label.c.XC_CL_PressTakeCharge");
        let convertedMess = $A.get("$Label.c.XC_CL_PressConvert");
        
        let viewedMessage = WarningMessage;
        if(stepName === 'Take Charge'){
            viewedMessage = takeChargeMess;
        }
        if(stepName === 'converted'){
            viewedMessage = convertedMess;
        }

        toastEvent.setParams({
            "title": $A.get("$Label.c.XC_CL_Warning"),
            "message": viewedMessage 
        });
        console.log('STEP NAME ' + stepName); 
        console.log('STEP NAME DETAIL' + JSON.stringify(event.getParam("detail") )); 
        
        if(stepName == 'Appointment Scheduled' || stepName == 'converted' || stepName == 'Take Charge'){
            component.set('v.hideUpdateButton', true);
            toastEvent.fire();
        }
        else {
            if(stepName == 'Assigned'){
                component.set('v.hideUpdateButton', true);
            }else{
                component.set('v.hideUpdateButton', false);
            }
        }
        //$A.get('e.force:refreshView').fire();
    }
})