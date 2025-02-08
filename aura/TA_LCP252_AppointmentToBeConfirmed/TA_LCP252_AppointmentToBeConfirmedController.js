({
    handleIsOpen : function(component, event, helper) {
        console.log('TA_LCP252_AppointmentToBeConfirmed >> Controller >> handleInitialize >> Start');
        helper.fireToggleSpinnerEvent(component, true);
        if(component.get("v.isOpen")) {
            helper.initialize(component, event, helper);
        } else {
            helper.fireToggleSpinnerEvent(component, false);
        }
        console.log('TA_LCP252_AppointmentToBeConfirmed >> Controller >> handleInitialize >> End');
    },

    handleCloseModal : function(component, event, helper) {
        console.log('TA_LCP252_AppointmentToBeConfirmed >> Controller >> handleCloseModal >> Start');
        helper.fireToggleSpinnerEvent(component, true);
        helper.closeModal(component, event, helper);
        helper.fireToggleSpinnerEvent(component, false);
        console.log('TA_LCP252_AppointmentToBeConfirmed >> Controller >> handleCloseModal >> End');
    },

    handleCardClick : function(component, event, helper) {
        console.log('TA_LCP252_AppointmentToBeConfirmed >> Controller >> handleCardClick >> Start');
        helper.fireToggleSpinnerEvent(component, true);
        helper.cardClick(component, event, helper);
        console.log('TA_LCP252_AppointmentToBeConfirmed >> Controller >> handleCardClick >> End');
    },

    handleChangeCategory : function(component, event, helper) {
        console.log('TA_LCP252_AppointmentToBeConfirmed >> Controller >> handleChangeCategory >> Start');
        helper.changeCategoryFilter(component, component.find('workTypeCategory').get('v.value'));
        console.log('TA_LCP252_AppointmentToBeConfirmed >> Controller >> handleChangeCategory >> End');
    }
})