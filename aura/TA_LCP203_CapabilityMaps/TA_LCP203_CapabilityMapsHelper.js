({
    doInit : function(component, event, helper) {
        console.log('TA_LCP203_CapabilityMaps >> Helper >> doInit >> Start');
        let urlTot = 'https://www.google.com/maps/dir/?api=1&destination=' + component.get('v.Latitude') + ',' + component.get('v.Longitude');

        component.set("v.redirectUrl", urlTot);
        component.set("v.contactName", component.get('v.contactName'));
        component.set("v.street", component.get('v.Street'));
        component.set("v.totalAddress", component.get('v.Country') + ', ' + component.get('v.City') + ', ' + component.get('v.PostalCode'));

        component.set('v.mapMarkers', [
            {
                location: {
                    Latitude: component.get('v.Latitude'),
                    Longitude: component.get('v.Longitude')
                },
                title: component.get('v.City'),
                description: component.get('v.Street')
            }
        ]);

        component.set('v.zoomLevel', 16);
        this.fireSendInitStateEvt(component, true);
        console.log('TA_LCP203_CapabilityMaps >> Helper >> doInit >> End');
    },

    redirectToMaps : function(component, event, helper) {
        console.log('TA_LCP203_CapabilityMaps >> Helper >> redirectToMaps >> Start');
        var eUrl= $A.get("e.force:navigateToURL");
        eUrl.setParams({
            "url": component.get("v.redirectUrl")
        });
        eUrl.fire();
        console.log('TA_LCP203_CapabilityMaps >> Helper >> redirectToMaps >> End');
    },

    fireSendInitStateEvt : function(component, isInitialized) {
        console.log('TA_LCP203_CapabilityMaps >> Helper >> fireSendInitStateEvt >> Start');
        let sendInitStateEvt = component.getEvent("sendInitStateEvt");
        sendInitStateEvt.setParams({
            "componentName" : "TA_LCP203_CapabilityMaps",
            "initState" : isInitialized
        });
        sendInitStateEvt.fire();
        console.log('TA_LCP203_CapabilityMaps >> Helper >> fireSendInitStateEvt >> End');
    }
})