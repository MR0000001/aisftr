({
    initialize : function(component, event) {
        console.log('TA_LCP266_TechnicalAssetSearching >> Helper >> initialize >> Start');
        this.fireToggleSpinnerEvent(component, false);
        console.log('TA_LCP252_AppointmentToBeConfirmed >> Helper >> initialize >> End');
    },

    closeModal : function(component, event) {
        console.log('TA_LCP266_TechnicalAssetSearching >> Helper >> closeModal >> Start');
        if(component.get('v.step') == 'details') component.set('v.step', 'search')
        else component.set("v.isOpen", false);
        console.log('TA_LCP266_TechnicalAssetSearching >> Helper >> closeModal >> End');
    },

    searchAsset : function(component) {
        console.log('TA_LCP266_TechnicalAssetSearching >> Helper >> searchAsset >> Start');
        
        if(!component.get('v.assetNameLike') || component.get('v.assetNameLike').length < 6) {
            component.set("v.showToastMessage", true);
            component.set("v.isError", true);
            component.set("v.toastMessage", $A.get('$Label.c.TA_Min6Digits'));
            return;
        }

        if(!component.get('v.city')) {
            component.set("v.showToastMessage", true);
            component.set("v.isError", true);
            component.set("v.toastMessage", $A.get('$Label.c.TA_CityRequired'));
            return;
        }

        let searchAsset = component.get('c.searchAsset');
        searchAsset.setParams({
            'city' : component.get('v.city'),
            'assetNameLike' : component.get('v.assetNameLike'),
        });

        searchAsset.setCallback(this, function(response) {
            console.log('TA_LCP266_TechnicalAssetSearching >> Helper >> searchAssetCallback >> Start');
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
            console.log('TA_LCP266_TechnicalAssetSearching >> Helper >> searchAssetCallback >> End');
        });

        this.fireToggleSpinnerEvent(component, true);
        $A.enqueueAction(searchAsset);

        console.log('TA_LCP266_TechnicalAssetSearching >> Helper >> searchAsset >> End');
    },

    fireToggleSpinnerEvent : function(component, toggleSpinner) {
        console.log('TA_LCP266_TechnicalAssetSearching >> Helper >> fireToggleSpinnerEvent >> Start');
        let toggleSpinnerEvent = component.getEvent("toggleSpinnerEvent");
        toggleSpinnerEvent.setParams({
            "sourceComponent" : "TA_LCP266_TechnicalAssetSearching",
            "toggleSpinner" : toggleSpinner
        });
        toggleSpinnerEvent.fire();
        console.log('TA_LCP266_TechnicalAssetSearching >> Helper >> fireToggleSpinnerEvent >> End');
    },

    assetSelection : function(component, event) {
        console.log('TA_LCP266_TechnicalAssetSearching >> Helper >> assetSelection >> Start');
        let assetId = event.currentTarget.id;
        component.get('v.assets').forEach((asset) => {
            if(asset.id == assetId) {
                component.set('v.selectedAsset', asset);
                component.set('v.step', 'details');
                if(asset.longitude && asset.latitude) component.set('v.mapMarkers', [{ location: { Latitude: asset.latitude, Longitude: asset.longitude }}]);
                else component.set('v.mapMarkers', []);
            }
        });
        console.log('TA_LCP266_TechnicalAssetSearching >> Helper >> assetSelection >> End');
    },

    showToast: function(component, isError, toastMessage) {
        component.set("v.showToastMessage", true);
        component.set("v.isError", isError);
        component.set("v.toastMessage", toastMessage);
    },
})