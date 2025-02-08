({
    handleSelectHelper : function (component, event) {
        var stepName = event.getParam("detail").value;
        var toastEvent = $A.get("e.force:showToast");
        var WorkingBooked = $A.get("$Label.c.XC_CL_Account_WorkingBooked");
        var ClosedConverted = $A.get("$Label.c.XC_CL_Account_ClosedConverted");
        var WorkingContacted = $A.get("$Label.c.XC_CL_Account_WorkingContacted");
        var WarningMessage = $A.get("$Label.c.XC_CL_Account_TransitionErrorMessage");
        
        toastEvent.setParams({
            "title": $A.get("$Label.c.XC_CL_Warning"),
            "message": WarningMessage 
        });
        //toastEvent.fire();
        if(stepName == WorkingBooked || stepName == ClosedConverted || stepName == WorkingContacted){
            component.set('v.hideUpdateButton', true);
            toastEvent.fire();
        }
        else {
            component.set('v.hideUpdateButton', false);
        }
    }
})