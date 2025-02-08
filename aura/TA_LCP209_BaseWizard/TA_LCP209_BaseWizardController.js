({
    handleInitialize: function (component, event, helper) {
        console.log('TA_LCP209_BaseWizard >> Controller >> handleInitialize >> Start');
        helper.initialize(component);
        console.log('TA_LCP209_BaseWizard >> Controller >> handleInitialize >> End');
    },

    handleRedirectToPage: function (component, event, helper, redirectParam) {
        console.log('TA_LCP209_BaseWizard >> Controller >> handleRedirectToPage >> Start');
        helper.redirectToPage(component, redirectParam);
        console.log('TA_LCP209_BaseWizard >> Controller >> handleRedirectToPage >> End');
    },

    handleCatchAppointmentPreviewEvt : function(component, event, helper){
        console.log('TA_LCP209_BaseWizard >> Controller >> handleCatchAppointmentPreviewEvt >> Start');
        helper.catchAppointmentPreviewEvt(component, event);
        console.log('TA_LCP209_BaseWizard >> Controller >> handleCatchAppointmentPreviewEvt >> End');
    },

    handleCatchToggleSpinnerEvt : function(component, event, helper){
        console.log('TA_LCP209_BaseWizard >> Controller >> handleCatchToggleSpinnerEvt >> Start');
        helper.catchToggleSpinnerEvt(component, event);
        console.log('TA_LCP209_BaseWizard >> Controller >> handleCatchToggleSpinnerEvt >> End');
    }
})