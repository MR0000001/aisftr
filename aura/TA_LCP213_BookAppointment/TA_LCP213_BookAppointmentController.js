({
    handleInitialize : function(component, event, helper) {
        console.log('TA_LCP213_BookAppointment >> Controller >> handleInitialize >> Start');
        helper.initialize(component);
        console.log('TA_LCP213_BookAppointment >> Controller >> handleInitialize >> End');
    },

    handleScheduleOtherDay : function(component, event, helper) {
        console.log('TA_LCP213_BookAppointment >> Controller >> handleScheduleOtherDay >> Start');
        component.set('v.bookNow', false);
        component.set('v.showCalendarModal', true);
        component.set('v.showBookAppointmentModal', false);
        component.set('v.showBookAppointmentModal', true);
        console.log('TA_LCP213_BookAppointment >> Controller >> handleScheduleOtherDay >> End');
    },

    handleScheduleToday : function(component, event, helper) {
        console.log('TA_LCP213_BookAppointment >> Controller >> handleScheduleToday >> Start');
        component.set('v.bookNow', true);
        component.set('v.showCalendarModal', true);
        component.set('v.showBookAppointmentModal', false);
        component.set('v.showBookAppointmentModal', true);
        console.log('TA_LCP213_BookAppointment >> Controller >> handleScheduleToday >> End');
    },

    handleShowChoiceModal : function(component, event, helper) {
        console.log('TA_LCP213_BookAppointment >> Controller >> handleShowChoiceModal >> Start');
        component.set('v.showChoiceModal', true);
        console.log('TA_LCP213_BookAppointment >> Controller >> handleShowChoiceModal >> End');
    },

    handleModalManagement : function(component, event, helper) {
        console.log('TA_LCP213_BookAppointment >> Controller >> handleModalManagement >> Start');
        if(event.getParam('type') == 'close') {
            component.set('v.showBookAppointmentModal', event.getParam('show'));
            component.set('v.showChoiceModal', false);
        }
        console.log('TA_LCP213_BookAppointment >> Controller >> handleModalManagement >> End');
    },

    handleCloseModal : function(component, event, helper) {
        console.log('TA_LCP213_BookAppointment >> Controller >> handleCloseModal >> Start');
        component.set('v.showChoiceModal', false);
        console.log('TA_LCP213_BookAppointment >> Controller >> handleCloseModal >> End');
    }
})