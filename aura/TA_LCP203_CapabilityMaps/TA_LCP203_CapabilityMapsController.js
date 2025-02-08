({
    handleDoInit : function(component, event, helper) {
        console.log('TA_LCP203_CapabilityMaps >> Controller >> handleDoInit >> Start');
        helper.doInit(component, event, helper);
        console.log('TA_LCP203_CapabilityMaps >> Controller >> handleDoInit >> End');
    },

    handleRedirectToMaps : function(component, event, helper) {
        console.log('TA_LCP203_CapabilityMaps >> Controller >> handleRedirectToMaps >> Start');
        helper.redirectToMaps(component, event, helper);
        console.log('TA_LCP203_CapabilityMaps >> Controller >> handleRedirectToMaps >> End');
    }
})