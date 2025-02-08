({
    handleIsInitializedChange : function(component, event, helper) {
        console.log('TA_LCP251_SelectWarehouse >> Controller >> doInit >> Start');
        // if(component.get("v.isInitialized")) {
        //     helper.initialize(component, event, helper);
        // }
        console.log('TA_LCP251_SelectWarehouse >> Controller >> doInit >> End');
    },

    handleCloseModal : function(component, event, helper) {
        console.log('TA_LCP251_SelectWarehouse >> Controller >> handleCloseModal >> Start');
        helper.closeModal(component, event, helper);
        console.log('TA_LCP251_SelectWarehouse >> Controller >> handleCloseModal >> End');
    },

    handleSearch : function(component, event, helper) {
        console.log('TA_LCP251_SelectWarehouse >> Controller >> handleSearch >> Start');
        helper.fireToggleSpinnerEvent(component, true);
        helper.search(component, event, helper);
        console.log('TA_LCP251_SelectWarehouse >> Controller >> handleSearch >> End');
    },

    handleSelectWarehouse : function(component, event, helper) {
        console.log('TA_LCP251_SelectWarehouse >> Controller >> handleSelectWarehouse >> Start');
        helper.selectWarehouse(component, event, helper);
        console.log('TA_LCP251_SelectWarehouse >> Controller >> handleSelectWarehouse >> End');
    },

    handleBackToSearch : function(component, event, helper) {
        console.log('TA_LCP251_SelectWarehouse >> Controller >> handleBackToSearch >> Start');
        component.set("v.isSearchView", true);
        component.set("v.warehouseList", undefined);
        component.set("v.selectedWarehouse", undefined);
        console.log('TA_LCP251_SelectWarehouse >> Controller >> handleBackToSearch >> End');
    },

    handleSetWarehouse : function(component, event, helper) {
        console.log('TA_LCP251_SelectWarehouse >> Controller >> handleSetWarehouse >> Start');
        helper.fireToggleSpinnerEvent(component, true);
        helper.setWarehouse(component, event, helper);
        console.log('TA_LCP251_SelectWarehouse >> Controller >> handleSetWarehouse >> End');
    }
})