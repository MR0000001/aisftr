({
	initialize : function(component) {
		console.log('TA_LCP256_DynamicAppointmentPreview >> Helper >> handleInitialize >> Start');
		component.set('v.general', JSON.parse(component.get('v.fieldSet')).general);
        component.set('v.custom', JSON.parse(component.get('v.fieldSet')).custom);
        component.set('v.title', $A.getReference("$Label.c." + component.get('v.general').defaultTitle));
		setTimeout(function() {component.set('v.isSpinnerVisible', false); }, 2000);
		//_helper.getServiceAppointments(component);
        console.log('TA_LCP256_DynamicAppointmentPreview >> Helper >> handleInitialize >> End');
	},

	getServiceAppointments : function(component) {
        console.log('TA_LCP256_DynamicAppointmentPreview >> Helper >> getServiceAppointments >> Start');
        let _helper = this;
        let action = component.get("c.initialize");

        if(component.get('v.serviceAppointmentList').length == 0 && component.get('v.getInitInfoBag')) {
            action.setParam('rowLimit', component.get('v.custom').details.rowLimit);
            action.setCallback(this, function(response) {
                console.log('TA_LCP256_DynamicAppointmentPreview >> Helper >> initializeCallback >> Start');
                if(response.getState() == "SUCCESS") {
                    component.set("v.infoBag", JSON.parse(response.getReturnValue()));
                    _helper.manageServiceAppointments(component, JSON.parse(response.getReturnValue()).serviceAppointment);
                } else if(response.getState() == "ERROR") {
                    component.set("v.showToastMessage", true);
                    component.set("v.isError", true);
                    component.set("v.toastMessage", JSON.stringify(response.getError()));
                }
                console.log('TA_LCP256_DynamicAppointmentPreview >> Helper >> initializeCallback >> End');
            });

            $A.enqueueAction(action);
        }
        console.log('TA_LCP256_DynamicAppointmentPreview >> Helper >> getServiceAppointments >> End');
    }
})