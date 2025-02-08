({
    initialize : function(component, event) {
        console.log('TA_LCP263_GeolocalizationStandalone >> Helper >> initialize >> Start');
        this.fireToggleSpinnerEvent(component, false);
        console.log('TA_LCP252_AppointmentToBeConfirmed >> Helper >> initialize >> End');
    },

    closeModal : function(component, event) {
        console.log('TA_LCP263_GeolocalizationStandalone >> Helper >> closeModal >> Start');
        component.set("v.isOpen", false);
        component.set('v.step', 'search');
        console.log('TA_LCP263_GeolocalizationStandalone >> Helper >> closeModal >> End');
    },

    searchAsset : function(component) {
        console.log('TA_LCP263_GeolocalizationStandalone >> Helper >> searchAsset >> Start');
        
        let searchAsset = component.get('c.searchAsset');
        searchAsset.setParams({
            'searchType' : component.get('v.searchType'),
            'searchValue' : component.get('v.searchValue'),
            'assetNameLike' : component.get('v.assetNameLike')
        });

        searchAsset.setCallback(this, function(response) {
            console.log('TA_LCP263_GeolocalizationStandalone >> Helper >> searchAssetCallback >> Start');
            if(response.getState() == "SUCCESS") {
                let res = JSON.parse(response.getReturnValue());
                if(res) {
                    res.forEach((asset) => {
                        if(asset.addressName && asset.addressName.length > 45) asset.addressName = asset.addressName.substring(0, 42) + '..';
                    });
                    component.set('v.assets', res);
                }

            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }

            this.fireToggleSpinnerEvent(component, false);
            console.log('TA_LCP263_GeolocalizationStandalone >> Helper >> searchAssetCallback >> End');
        });

        this.fireToggleSpinnerEvent(component, true);
        $A.enqueueAction(searchAsset);

        console.log('TA_LCP263_GeolocalizationStandalone >> Helper >> searchAsset >> End');
    },

    fireToggleSpinnerEvent : function(component, toggleSpinner) {
        console.log('TA_LCP263_GeolocalizationStandalone >> Helper >> fireToggleSpinnerEvent >> Start');
        let toggleSpinnerEvent = component.getEvent("toggleSpinnerEvent");
        toggleSpinnerEvent.setParams({
            "sourceComponent" : "TA_LCP263_GeolocalizationStandalone",
            "toggleSpinner" : toggleSpinner
        });
        toggleSpinnerEvent.fire();
        console.log('TA_LCP263_GeolocalizationStandalone >> Helper >> fireToggleSpinnerEvent >> End');
    },

    assetSelection : function(component, event) {
        console.log('TA_LCP263_GeolocalizationStandalone >> Helper >> assetSelection >> Start');
        let assetId = event.currentTarget.id;
        component.get('v.assets').forEach((asset) => {
            if(asset.id == assetId) {
                component.set('v.selectedAsset', asset);
                component.set('v.step', 'gps');
                component.set('v.currentLongitude', asset.longitude);
                component.set('v.currentLatitude', asset.latitude);
                component.set('v.currentAccuracy', asset.accuracy);
                if(asset.longitude && asset.latitude) component.set('v.mapMarkers', [{ location: { Latitude: asset.latitude, Longitude: asset.longitude }}]);
            }
        });
        console.log('TA_LCP263_GeolocalizationStandalone >> Helper >> assetSelection >> End');
    },

    getCurrentCoordinates : function(component) {
        console.log('TA_LCP263_GeolocalizationStandalone >> Helper >> getCurrentCoordinates >> Start');
        
        let _helper = this;

        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition((currentPosition) => {
                _helper.updateCoordinates(
                    component, 
                    currentPosition.coords.latitude, 
                    currentPosition.coords.longitude, 
                    currentPosition.coords.accuracy.toFixed(7));
            }, function error(err) {
                _helper.showToast(component, true, $A.get('$Label.c.TA_GeolocalizationError'));
            });
        } else { 
            _helper.showToast(component, true, $A.get('$Label.c.TA_GeolocalizationError'));
        }
        console.log('TA_LCP263_GeolocalizationStandalone >> Helper >> getCurrentCoordinates >> End');
    },

    updateCoordinates : function(component, currentLatitude, currentLongitude, currentAccuracy) {
        console.log('TA_LCP262_Geolocalization >> Helper >> updateCoordinates >> Start');
        
        let _helper = this;
        let action = component.get('c.updateCoordinates');
        
        console.log('@@>> assetId >>> ' + component.get('v.selectedAsset').id);
        console.log('@@>> currentLatitude >>> ' + currentLatitude);
        console.log('@@>> currentLongitude >>> ' + currentLongitude);
        console.log('@@>> currentAccuracy >>> ' + currentAccuracy);

        action.setParams({
            'recordId' : component.get('v.selectedAsset').id,
            'currentLatitude' : currentLatitude,
            'currentLongitude' : currentLongitude,
            'currentAccuracy' : currentAccuracy
        });

        action.setCallback(this, function(response) {
            if(response.getState() == "SUCCESS") {
                if(response.getReturnValue() == 'Completed'){
                    component.set('v.currentLatitude', currentLatitude);
                    component.set('v.currentLongitude', currentLongitude);
                    component.set('v.currentAccuracy', currentAccuracy);
                    component.set('v.mapMarkers', [{ location: { Latitude: currentLatitude, Longitude: currentLongitude }}]);

                    let assets = component.get('v.assets');
                    assets.forEach((asset) => {
                        if(asset.id == component.get('v.selectedAsset').id) {
                            asset.longitude = currentLongitude;
                            asset.latitude = currentLatitude;
                            asset.accuracy = currentAccuracy;
                        }
                    });
                    _helper.showToast(component, false, $A.get('$Label.c.TA_GeolocalizationSuccess'));
                } else {
                    _helper.showToast(component, true, response.getReturnValue());
                } 
            } else if(response.getState() == "ERROR") {
                _helper.showToast(component, true, JSON.stringify(response.getError()));
            }
            _helper.fireToggleSpinnerEvent(component, false);   
        });

        $A.enqueueAction(action);
        _helper.fireToggleSpinnerEvent(component, true);

        console.log('TA_LCP262_Geolocalization >> Helper >> updateCoordinates >> End');
    },

    showToast: function(component, isError, toastMessage) {
        component.set("v.showToastMessage", true);
        component.set("v.isError", isError);
        component.set("v.toastMessage", toastMessage);
    },
})