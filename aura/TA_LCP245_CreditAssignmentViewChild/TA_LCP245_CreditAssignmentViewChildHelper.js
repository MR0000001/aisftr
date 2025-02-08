({
    fireToggleSpinnerEvent : function(component, toggleSpinner) {
        console.log('TA_LCP245_CreditAssignmentViewChild >> Helper >> fireToggleSpinnerEvent >> Start');
        let toggleSpinnerEvent = component.getEvent("toggleSpinnerEvent");
        toggleSpinnerEvent.setParams({
            "sourceComponent" : "TA_LCP245_CreditAssignmentViewChild",
            "toggleSpinner" : toggleSpinner
        });
        toggleSpinnerEvent.fire();
        console.log('TA_LCP245_CreditAssignmentViewChild >> Helper >> fireToggleSpinnerEvent >> End');
    },

    error : function(component, event) {
        this.fireToggleSpinnerEvent(component, false);
        component.set("v.showToastMessage", true);
        component.set("v.isError", true);

        let errorMessage = '';
        if(event.getParams().error.body.output.errors) {
            event.getParams().error.body.output.errors.forEach(function(errMsg) {
                errorMessage += errMsg.message + ' ';
            })
        } else errorMessage = JSON.stringify(event.getParams().error);
        component.set("v.toastMessage", errorMessage);
    },

})