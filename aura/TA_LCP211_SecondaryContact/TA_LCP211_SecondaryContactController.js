({
    handleInitialize : function(component, event, helper) {
        console.log('TA_LCP211_SecondaryContact >> Controller >> handleInitialize >> Start');
        helper.initialize(component, event, helper);
        console.log('TA_LCP211_SecondaryContact >> Controller >> handleInitialize >> End');
    },

    handleOpenModal : function(component, event, helper) {
        console.log('TA_LCP211_SecondaryContact >> Controller >> handleOpenModal >> Start');
        helper.loadContact(component, event, helper);
        component.set("v.showModal", true);
        console.log('TA_LCP211_SecondaryContact >> Controller >> handleOpenModal >> End');
    },
    
    handleCloseModal : function(component, event, helper) {
        console.log('TA_LCP211_SecondaryContact >> Controller >> handleCloseModal >> Start');
        helper.closeModal(component, event, helper);
        console.log('TA_LCP211_SecondaryContact >> Controller >> handleCloseModal >> End');
    },

    handleSelectContact : function(component, event, helper) {
        console.log('TA_LCP211_SecondaryContact >> Controller >> handleSelectContact >> Start');
        helper.selectContact(component, event, helper);
        console.log('TA_LCP211_SecondaryContact >> Controller >> handleSelectContact >> End');
    },

    handleManageModal : function(component, event, helper) {
        console.log('TA_LCP211_SecondaryContact >> Controller >> handleManageModal >> Start');
        helper.manageModal(component, event, helper);
        console.log('TA_LCP211_SecondaryContact >> Controller >> handleManageModal >> End');
    },

    handleUpdateContact : function(component, event, helper) {
        console.log('TA_LCP211_SecondaryContact >> Controller >> handleUpdateContact >> Start');
        helper.updateContact(component, event, helper);
        console.log('TA_LCP211_SecondaryContact >> Controller >> handleUpdateContact >> End');
    },

    handleSaveNewContact : function(component, event, helper) {
        console.log('TA_LCP211_SecondaryContact >> Controller >> handleSaveNewContact >> Start');
        helper.saveNewContact(component, event, helper);
        console.log('TA_LCP211_SecondaryContact >> Controller >> handleSaveNewContact >> End');
    },

    handleInputChange : function(component, event, helper) {
        console.log('TA_LCP211_SecondaryContact >> Controller >> handleInputChange >> Start');
        helper.inputChange(component, event.getSource().get("v.name"), helper);
        console.log('TA_LCP211_SecondaryContact >> Controller >> handleInputChange >> End');
    }
})