({
    handleIsOpen : function(component, event, helper) {
        console.log('TA_LCP263_GeolocalizationStandalone >> Controller >> handleInitialize >> Start');
        helper.fireToggleSpinnerEvent(component, true);
        if(component.get("v.isOpen")) {
            helper.initialize(component, event);
        } else {
            helper.fireToggleSpinnerEvent(component, false);
        }
        console.log('TA_LCP263_GeolocalizationStandalone >> Controller >> handleInitialize >> End');
    },

    handleCloseModal : function(component, event, helper) {
        console.log('TA_LCP263_GeolocalizationStandalone >> Controller >> handleCloseModal >> Start');
        helper.fireToggleSpinnerEvent(component, true);
        helper.closeModal(component, event);
        helper.fireToggleSpinnerEvent(component, false);
        console.log('TA_LCP263_GeolocalizationStandalone >> Controller >> handleCloseModal >> End');
    },

    handleSearchAsset : function(component, event, helper) {
        console.log('TA_LCP263_GeolocalizationStandalone >> Controller >> handleSearchAsset >> Start');
        helper.searchAsset(component);
        console.log('TA_LCP263_GeolocalizationStandalone >> Controller >> handleSearchAsset >> End');
    },

    handleCardClick : function(component, event, helper) {
        console.log('TA_LCP263_GeolocalizationStandalone >> Controller >> handleCardClick >> Start');
        helper.assetSelection(component, event);
        console.log('TA_LCP263_GeolocalizationStandalone >> Controller >> handleCardClick >> End');
    },

    handleBack : function(component) {
        console.log('TA_LCP263_GeolocalizationStandalone >> Controller >> handleCardClick >> Start');
        component.set('v.step', 'search');
        console.log('TA_LCP263_GeolocalizationStandalone >> Controller >> handleCardClick >> End');
    },

    handleGeolocalization : function(component, event, helper) {
        console.log('TA_LCP263_GeolocalizationStandalone >> Controller >> handleGeolocalization >> Start');
        helper.getCurrentCoordinates(component);
        console.log('TA_LCP263_GeolocalizationStandalone >> Controller >> handleGeolocalization >> End');
    },
})