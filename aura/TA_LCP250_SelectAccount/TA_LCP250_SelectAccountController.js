({
    handleInitialize : function(component, event, helper) {
        console.log('TA_LCP250_SelectAccount >> Controller >> handleInitialize >> Start');
        helper.initialize(component, event, helper);
        console.log('TA_LCP250_SelectAccount >> Controller >> handleInitialize >> End');
    },

    handleSearchAccount : function(component, event, helper) {
        console.log('TA_LCP250_SelectAccount >> Controller >> handleSearchAccount >> Start');
        helper.searchAccount(component, event, helper);
        console.log('TA_LCP250_SelectAccount >> Controller >> handleSearchAccount >> End');
    },

    handleCheckSearchParam : function(component, event, helper) {
        console.log('TA_LCP250_SelectAccount >> Controller >> handleCheckSearchParam >> Start');
        helper.checkSearchParam(component, event, helper);
        console.log('TA_LCP250_SelectAccount >> Controller >> handleCheckSearchParam >> End');
    },

    handleSelectAccount : function(component, event, helper) {
        console.log('TA_LCP250_SelectAccount >> Controller >> handleSelectAccount >> Start');
        helper.selectAccount(component, event, helper);
        console.log('TA_LCP250_SelectAccount >> Controller >> handleSelectAccount >> End');
    },

    handleSelectAddress : function(component, event, helper) {
        console.log('TA_LCP250_SelectAccount >> Controller >> handleSelectAddress >> Start');
        helper.selectAddress(component, event, helper);
        console.log('TA_LCP250_SelectAccount >> Controller >> handleSelectAddress >> End');
    },

    handleConfirmAccount : function(component, event, helper) {
        console.log('TA_LCP250_SelectAccount >> Controller >> handleConfirmAccount >> Start');
        helper.confirmAccount(component, event, helper);
        console.log('TA_LCP250_SelectAccount >> Controller >> handleConfirmAccount >> End');
    },

    handleCloseModal : function(component, event, helper) {
        console.log('TA_LCP250_SelectAccount >> Controller >> handleConfirmAccount >> Start');
        helper.closeModal(component, event, helper);
        console.log('TA_LCP250_SelectAccount >> Controller >> handleConfirmAccount >> End');
    },

    handleAddressEvent : function(component, event, helper) {
        console.log('TA_LCP250_SelectAccount >> Controller >> handleAddressEvent >> Start');
        helper.addressEvent(component, event, helper);
        console.log('TA_LCP250_SelectAccount >> Controller >> handleAddressEvent >> End');
    },

    handleToggleAddressSection : function(component, event, helper) {
        console.log('TA_LCP250_SelectAccount >> Controller >> handleToggleAddressSection >> Start');
        helper.toggleAddressSection(component, event, helper);
        console.log('TA_LCP250_SelectAccount >> Controller >> handleToggleAddressSection >> End');
    },

    handleShowAddressModal : function(component, event, helper) {
        console.log('TA_LCP250_SelectAccount >> Controller >> handleShowAddressModal >> Start');
        component.set('v.showSelectAddressModal', true);
        component.set('v.showSelectAccountModal', false);
        console.log('TA_LCP250_SelectAccount >> Controller >> handleShowAddressModal >> End');
    },

    handleBackModal : function(component, event, helper) {
        console.log('TA_LCP250_SelectAccount >> Controller >> handleBackModal >> Start');
        component.set('v.showSelectAddressModal', false);
        component.set('v.showSelectAccountModal', true);
        console.log('TA_LCP250_SelectAccount >> Controller >> handleBackModal >> End');
    }
})