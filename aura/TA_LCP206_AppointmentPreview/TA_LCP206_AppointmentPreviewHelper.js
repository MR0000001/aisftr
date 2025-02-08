({
    initialize : function(component) {
        console.log('TA_LCP206_AppointmentPreview >> Helper >> initialize >> Start');
        let _helper = this;
        let action = component.get("c.initialize");

        if(component.get('v.serviceAppointmentList').length == 0 && component.get('v.getInitInfoBag')) {
            action.setParam('rowLimit', component.get('v.rowLimit'));
            action.setCallback(this, function(response) {
                console.log('TA_LCP206_AppointmentPreview >> Helper >> initializeCallback >> Start');
                if(response.getState() == "SUCCESS") {
                    component.set("v.infoBag", JSON.parse(response.getReturnValue()));
                    _helper.manageServiceAppointments(component, JSON.parse(response.getReturnValue()).serviceAppointment);
                } else if(response.getState() == "ERROR") {
                    component.set("v.showToastMessage", true);
                    component.set("v.isError", true);
                    component.set("v.toastMessage", JSON.stringify(response.getError()));
                }
                console.log('TA_LCP206_AppointmentPreview >> Helper >> initializeCallback >> End');
            });

            $A.enqueueAction(action);
        }
        console.log('TA_LCP206_AppointmentPreview >> Helper >> initialize >> End');
    },

    cardClick : function(component, event, helper) {
        console.log('TA_LCP206_AppointmentPreview >> Helper >> cardClick >> Start');
        this.fireAppointmentPreviewEvent(component, event.currentTarget.dataset.id);
        console.log('TA_LCP206_AppointmentPreview >> Helper >> cardClick >> End');
    },

    fireAppointmentPreviewEvent : function(component, urlToRedirect) {
        console.log('TA_LCP206_AppointmentPreview >> Helper >> fireAppointmentPreviewEvent >> Start');
        var myEvent = component.getEvent("appointmentPreviewEvent");
        myEvent.setParams({
            "urlToRedirect" : urlToRedirect
        });
        myEvent.fire();
        console.log('TA_LCP206_AppointmentPreview >> Helper >> fireAppointmentPreviewEvent >> End');
    },

    manageServiceAppointments : function(component, serviceAppointments) {
        console.log('TA_LCP206_AppointmentPreview >> Helper >> manageServiceAppointments >> Start');
        let _helper = this;

        if(serviceAppointments && serviceAppointments.length > 0) {
            serviceAppointments.sort((firstElementToSort, secondElementToSort) => (firstElementToSort.createdDate > secondElementToSort.createdDate) ? 1 : -1);
            serviceAppointments.forEach(function(sa) {
                if(sa.customerName) {
                    if(sa.customerName.length > 30) sa.customerName = sa.customerName.substr(0, 30) + '..';
                }
                if(sa.toLabelWorkTypeLabel) {
                    if(sa.toLabelWorkTypeLabel.length > 31) sa.toLabelWorkTypeLabel = sa.toLabelWorkTypeLabel.substr(0, 30) + '..';
                }
                if(sa.address) {
                    if(sa.address.length > 36) sa.address = sa.address.substr(0, 35) + '..';
                }
                if(sa.duration) {
                    if(sa.durationType == 'Hours') {
                        sa.duration = _helper.formatDuration(sa.duration);
                    } else if(sa.durationType == 'Minutes') {
                        sa.duration = sa.duration.substr(0,2);
                    }       
                }
            });

            component.set('v.serviceAppointmentList', serviceAppointments);
        }
        console.log('TA_LCP206_AppointmentPreview >> Helper >> manageServiceAppointments >> End');
    },

    formatDuration : function(decimalToFormat) {
        let decimalTime = parseFloat(decimalToFormat);
        decimalTime = decimalTime * 60 * 60;

        let hours = Math.floor((decimalTime / (60 * 60)));
        decimalTime = decimalTime - (hours * 60 * 60);

        let minutes = Math.floor((decimalTime / 60));
        decimalTime = decimalTime - (minutes * 60);

        if(minutes < 10) {
            minutes = "0" + minutes;
        }
        return "" + hours + ":" + minutes;
    }
})