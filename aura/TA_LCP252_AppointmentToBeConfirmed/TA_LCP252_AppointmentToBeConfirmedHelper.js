({
    initialize : function(component, event, helper) {
        console.log('TA_LCP252_AppointmentToBeConfirmed >> Helper >> initialize >> Start');
        let action = component.get("c.initialize");

        action.setCallback(this, function(response) {
            console.log('TA_LCP252_AppointmentToBeConfirmed >> Helper >> initializeCallback >> Start');
            if(response.getState() == "SUCCESS") {
                component.set('v.infoBag', JSON.parse(response.getReturnValue()));
                helper.manageServiceAppointments(component, component.get('v.infoBag').serviceAppointment);
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }

            helper.fireToggleSpinnerEvent(component, false);
            console.log('TA_LCP252_AppointmentToBeConfirmed >> Helper >> initializeCallback >> End');
        });

        $A.enqueueAction(action);
        console.log('TA_LCP252_AppointmentToBeConfirmed >> Helper >> initialize >> End');
    },

    closeModal : function(component, event, helper) {
        console.log('TA_LCP252_AppointmentToBeConfirmed >> Helper >> closeModal >> Start');
        component.set("v.isOpen", false);
        console.log('TA_LCP252_AppointmentToBeConfirmed >> Helper >> closeModal >> End');
    },

    fireToggleSpinnerEvent : function(component, toggleSpinner) {
        console.log('TA_LCP252_AppointmentToBeConfirmed >> Helper >> fireToggleSpinnerEvent >> Start');
        let toggleSpinnerEvent = component.getEvent("toggleSpinnerEvent");
        toggleSpinnerEvent.setParams({
            "sourceComponent" : "TA_LCP252_AppointmentToBeConfirmed",
            "toggleSpinner" : toggleSpinner
        });
        toggleSpinnerEvent.fire();
        console.log('TA_LCP252_AppointmentToBeConfirmed >> Helper >> fireToggleSpinnerEvent >> End');
    },

    cardClick : function(component, event, helper) {
        console.log('TA_LCP252_AppointmentToBeConfirmed >> Helper >> cardClick >> Start');
        this.fireAppointmentPreviewEvent(component, event.currentTarget.id);
        console.log('TA_LCP252_AppointmentToBeConfirmed >> Helper >> cardClick >> End');
    },

    fireAppointmentPreviewEvent : function(component, urlToRedirect) {
        console.log('TA_LCP252_AppointmentToBeConfirmed >> Helper >> fireAppointmentPreviewEvent >> Start');
        var myEvent = component.getEvent("appointmentPreviewEvent");
        myEvent.setParams({
            "urlToRedirect" : urlToRedirect
        });
        myEvent.fire();
        console.log('TA_LCP252_AppointmentToBeConfirmed >> Helper >> fireAppointmentPreviewEvent >> End');
    },

    manageServiceAppointments : function(component, serviceAppointments) {
        console.log('TA_LCP252_AppointmentToBeConfirmed >> Helper >> manageServiceAppointments >> Start');
        
        if(serviceAppointments && serviceAppointments.length > 0) {
            var workTypeCategory = []; //ENXCRM-176 BGO
            workTypeCategory.push($A.get("$Label.c.TA_ViewAll"));
            serviceAppointments.sort((firstElementToSort, secondElementToSort) => (firstElementToSort.createdDate > secondElementToSort.createdDate) ? 1 : -1);
            serviceAppointments.forEach(function(sa) {
                if(sa.customerName) {
                    if(sa.customerName.length > 30) sa.customerName = sa.customerName.substr(0, 28) + '..';
                }
                if(sa.toLabelWorkTypeLabel) {
                    if(sa.toLabelWorkTypeLabel.length > 25) sa.toLabelWorkTypeLabel = sa.toLabelWorkTypeLabel.substr(0, 23) + '..';
                }
                if(sa.address) {
                    if(sa.address.length > 30) sa.address = sa.address.substr(0, 28) + '..';
                }
                if(sa.street) {
                    if(sa.street.length > 30) sa.street = sa.street.substr(0, 28) + '..';
                }
                if(sa.city) {
                    if(sa.city.length > 30) sa.city = sa.city.substr(0, 28) + '..';
                }
                //START | ENXCRM-176 BGO
                if(sa.toLabelWorkTypeCategory && !workTypeCategory.includes(sa.toLabelWorkTypeCategory)) {
                    workTypeCategory.push(sa.toLabelWorkTypeCategory);
                }
                //END | ENXCRM-176 BGO
            });
            component.set('v.serviceAppointmentList', serviceAppointments);
            component.set('v.serviceAppointmentsAll', serviceAppointments);
            component.set('v.workTypeCategory', workTypeCategory); //ENXCRM-176 BGO
        }
        console.log('TA_LCP252_AppointmentToBeConfirmed >> Helper >> manageServiceAppointments >> End');
    },

    changeCategoryFilter : function(component, workTypeCategory) {
        console.log('TA_LCP252_AppointmentToBeConfirmed >> Helper >> changeCategoryFilter >> Start');

        var serviceAppointments;

        if(workTypeCategory == $A.get("$Label.c.TA_ViewAll")){
            serviceAppointments = component.get('v.serviceAppointmentsAll');
        } else {
            serviceAppointments = component.get('v.serviceAppointmentsAll').filter(function(sa){
                return sa.toLabelWorkTypeCategory == workTypeCategory;
            });
        }    
        component.set('v.serviceAppointmentList', serviceAppointments);
        
        console.log('TA_LCP252_AppointmentToBeConfirmed >> Helper >> changeCategoryFilter >> End');
    }
})