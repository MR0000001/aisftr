({
    handleInitialize : function(component, event, helper) {
        console.log('TA_LCP220_LeadConversion >> Controller >> handleInitialize >> Start');
        component.set('v.isSpinnerVisible', true);
        helper.initialize(component);
        console.log('TA_LCP220_LeadConversion >> Controller >> handleInitialize >> End');
    },

    handleCloseModal : function(component, event, helper) {
        console.log('TA_LCP220_LeadConversion >> Controller >> handleCloseModal >> Start');
        helper.closeModal(component);
        console.log('TA_LCP220_LeadConversion >> Controller >> handleCloseModal >> End');
    },

    handleManageButtons : function(component, event, helper) {
        console.log('TA_LCP202_DynamicLayout >> Controller >> handleManageButtons >> Start');
        helper.manageButtons(component, event);
        console.log('TA_LCP202_DynamicLayout >> Controller >> handleManageButtons >> End');
    },

    handleAddressValidationEvent : function(component, event, helper) {
        console.log('TA_LCP202_DynamicLayout >> Controller >> handleAddressValidationEvent >> Start');
        helper.setAddress(component, event);
        console.log('TA_LCP202_DynamicLayout >> Controller >> handleAddressValidationEvent >> End');
    }
})