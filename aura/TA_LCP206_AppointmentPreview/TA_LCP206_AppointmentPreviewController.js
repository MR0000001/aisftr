({
    handleInitialize : function(component, event, helper) {
        console.log('TA_LCP206_AppointmentPreview >> Controller >> handleInitialize >> Start');
        helper.initialize(component);
        console.log('TA_LCP206_AppointmentPreview >> Controller >> handleInitialize >> End');
    },

    handleCardClick : function (component, event, helper) {
        console.log('TA_LCP206_AppointmentPreview >> Controller >> handleCardClick >> Start');
        helper.cardClick(component, event, helper);
        console.log('TA_LCP206_AppointmentPreview >> Controller >> handleCardClick >> End');
    }
})