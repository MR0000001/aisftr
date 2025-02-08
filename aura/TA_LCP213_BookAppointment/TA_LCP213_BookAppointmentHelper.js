({
    initialize : function(component, event, helper) {
        console.log('TA_LCP213_BookAppointment >> Helper >> initialize >> Start');
        component.set('v.general', JSON.parse(component.get('v.fieldSet')).general);
        component.set('v.custom', JSON.parse(component.get('v.fieldSet')).custom);

        if(component.get('v.general').titleType == 'default') {
            component.set('v.title', $A.getReference("$Label.c." + component.get('v.general').defaultTitle));
        } else {
            component.get('v.objWrapper').fields.forEach(function(field) {
                if(component.get('v.general').titleType == field.apiName) {
                    component.set('v.title', field.value);
                }
            });
        }
        component.set('v.description', $A.getReference("$Label.c." + component.get('v.general').description));
        component.set('v.customerCardBg', $A.get('$Resource.TA_Images') + '/imgs/' + component.get('v.general.bgImage'));
        component.set('v.isInitialized', true);

        this.fireSendInitStateEvt(component, true);
        console.log('TA_LCP213_BookAppointment >> Helper >> initialize >> End');
    },

    fireToggleSpinnerEvent : function(component, toggleSpinner) {
        console.log('TA_LCP213_BookAppointment >> Helper >> fireToggleSpinnerEvent >> Start');
        let toggleSpinnerEvent = component.getEvent("toggleSpinnerEvent");
        toggleSpinnerEvent.setParams({
            "sourceComponent" : "TA_LCP213_BookAppointment",
            "toggleSpinner" : toggleSpinner
        });
        toggleSpinnerEvent.fire();
        console.log('TA_LCP213_BookAppointment >> Helper >> fireToggleSpinnerEvent >> End');
    },

    fireSendInitStateEvt : function(component, isInitialized) {
        console.log('TA_LCP213_BookAppointment >> Helper >> fireSendInitStateEvt >> Start');
        let sendInitStateEvt = component.getEvent("sendInitStateEvt");
        sendInitStateEvt.setParams({
            "componentName" : "TA_LCP213_BookAppointment",
            "initState" : isInitialized
        });
        sendInitStateEvt.fire();
        console.log('TA_LCP213_BookAppointment >> Helper >> fireSendInitStateEvt >> End');
    }
})