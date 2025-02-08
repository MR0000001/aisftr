({
	
    handleInitialize: function (component, event, helper) {
        console.log('TA_LCP262_Geolocalization >> Controller >> handleInitialize >> Start');
        helper.initialize(component);
        console.log('TA_LCP262_Geolocalization >> Controller >> handleInitialize >> End');
    },

    handleGetCurrentCoordinates: function (component, event, helper) {
        console.log('TA_LCP262_Geolocalization >> Controller >> handleGetCurrentCoordinates >> Start');
        helper.getCurrentCoordinates(component);
        console.log('TA_LCP262_Geolocalization >> Controller >> handleGetCurrentCoordinates >> End');
    },

    handleManageAccordion : function(component, event, helper) {
        console.log('TA_LCP262_Geolocalization >> Controller >> handleManageAccordion >> Start');
        component.set('v.general.show', !component.get('v.general.show'));
        console.log('TA_LCP262_Geolocalization >> Controller >> handleManageAccordion >> End');
    },
})