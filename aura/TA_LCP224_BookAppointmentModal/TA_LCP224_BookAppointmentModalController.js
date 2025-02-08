({
    handleGetAvailableAppointments : function(component, event, helper) {
        console.log('TA_LCP213_BookAppointment >> Controller >> handleGetAvailableAppointments >> Start');
        if(component.get('v.bookNow') && component.get('v.leadId') != null) {
            helper.confirm(component, null);
        } else {
            helper.getAppointments(component);
        }
        console.log('TA_LCP213_BookAppointment >> Controller >> handleGetAvailableAppointments >> End');
    },

    handleChangeShowCalendarModal : function(component, event, helper) {
        console.log('TA_LCP213_BookAppointment >> Controller >> handleChangeShowCalendarModal >> Start');
        if(component.get('v.showCalendarModal')) {
            if(!component.get('v.bookNow')) {
                helper.getAppointments(component);
            } else {
                helper.confirm(component, null);
            }
        }
        console.log('TA_LCP213_BookAppointment >> Controller >> handleChangeShowCalendarModal >> End');
    },

    handleCloseModal : function(component, event, helper) {
        console.log('TA_LCP213_BookAppointment >> Controller >> handleCloseModal >> Start');
        component.set('v.showCalendarModal', false);
        component.set('v.showSlotSelectionModal', false);
        component.set('v.showConfirmModal', false);
        helper.closeModalEvt();
        console.log('TA_LCP213_BookAppointment >> Controller >> handleCloseModal >> End');
    },

    handleTimeSlotSelected : function(component, event, helper) {
        console.log('TA_LCP213_BookAppointment >> Controller >> handleTimeSlotSelected >> Start');
        helper.timeSlotSelected(component, event);
        console.log('TA_LCP213_BookAppointment >> Controller >> handleTimeSlotSelected >> End');
    },

    handleRedirectToCalendar : function(component, event, helper) {
        console.log('TA_LCP213_BookAppointment >> Controller >> handleRedirectToCalendar >> Start');
        helper.redirectToPage(component, 'custom-calendar', true);
        console.log('TA_LCP213_BookAppointment >> Controller >> handleRedirectToCalendar >> End');
    },

    handleManageEdit : function(component, event, helper) {
        console.log('TA_LCP213_BookAppointment >> Controller >> handleManageEdit >> Start');
        let buttonName = event.currentTarget.id;
        if(buttonName == 'edit-date') {
            helper.editDateSelected(component);
        } else if(buttonName == 'edit-time-slot') {
            component.set('v.isTimeSlotConfirmed', false);
        } else if(buttonName == 'edit-duration-time') {
            component.set('v.isTimeSlotConfirmed', true);
            component.set('v.isTimeDurationSelection', true);
        }
        console.log('TA_LCP213_BookAppointment >> Controller >> handleManageEdit >> End');
    }, 

    handleConfirm : function(component, event, helper) {
        console.log('TA_LCP213_BookAppointment >> Controller >> handleConfirm >> Start');
        let buttonName = event.getSource().get("v.name");
        if(buttonName == "request-availability") {
            component.set('v.isTimeSlotConfirmed', true);
            component.set('v.isTimeDurationSelection', true);
        } else if(buttonName == 'confirm') {
            component.set('v.isSpinnerVisible', true);
            helper.saveDurationTime(component, event, helper);
        } else if(buttonName == 'saveDurationTime') {
            component.set("v.isTimeDurationSelection", false);
        }
        console.log('TA_LCP213_BookAppointment >> Controller >> handleConfirm >> End');
    },

    handleBackModal : function(component, event, helper) {
        console.log('TA_LCP213_BookAppointment >> Controller >> handleBackModal >> Start');

        if(event.currentTarget.name == 'lead') {
            component.set('v.showCalendarModal', false);
            let closeModalEvt = $A.get("e.c:TA_LCE216_ModalManagement");
            closeModalEvt.setParam("type", 'back');
            closeModalEvt.fire();
            
        } else if(event.currentTarget.name == 'calendar') {
            component.set('v.showSlotSelectionModal', false);
            component.set('v.showCalendarModal', true);
        }

        console.log('TA_LCP213_BookAppointment >> Controller >> handleBackModal >> End');
    },

    handleManageTime : function(component, event, helper) {
        console.log('TA_LCP224_BookAppointmentModal >> Controller >> handleManageTime >> Start');
        helper.manageTime(component, event, helper);
        console.log('TA_LCP224_BookAppointmentModal >> Controller >> handleManageTime >> End');
    }
})