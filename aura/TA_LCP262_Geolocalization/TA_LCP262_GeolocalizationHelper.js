({
	initialize : function(component) {
        console.log('TA_LCP262_Geolocalization >> Helper >> initialize >> Start');

        component.set('v.general', JSON.parse(component.get('v.fieldSet')).general);
        component.set('v.custom', JSON.parse(component.get('v.fieldSet')).custom);
        component.set('v.customerCardBg', $A.get('$Resource.TA_Images') + '/imgs/' + component.get('v.general.bgImage'));
        component.set('v.title', $A.getReference("$Label.c." + component.get('v.general').defaultTitle));
        component.set('v.description', $A.getReference("$Label.c." + component.get('v.general').description));

        let _helper = this;

        let getAssetCoordinates = component.get('c.getAssetCoordinates');
        getAssetCoordinates.setParam('workOrderId', component.get('v.workOrderId'));
        getAssetCoordinates.setCallback(this, function(response) {
            if(response.getState() == "SUCCESS") { 
                let returnValue = response.getReturnValue();
                
                if(!returnValue.errorMessage){
                    let errors = [];
                    
                    if(returnValue.longitude) component.set('v.currentLongitude', returnValue.longitude);
                    if(returnValue.latitude) component.set('v.currentLatitude', returnValue.latitude);  
                    if(returnValue.accuracy) component.set('v.currentAccuracy', returnValue.accuracy);   
                    
                    if((!returnValue.longitude || !returnValue.latitude) && component.get('v.custom').isRequired) {
                        errors.push($A.get("$Label.c.TA_GeolocalizationRequired"));
                    }  else component.set('v.mapMarkers', [{ location: { Latitude: returnValue.latitude, Longitude: returnValue.longitude }}]);

                    this.fireValidationEvt(component, errors);
                } else {
                    _helper.showToast(component, true, returnValue.errorMessage);
                } 

                this.fireSendInitStateEvt(component, true);
                component.set('v.isInitialized', true);

            } else if(response.getState() == "ERROR") {
                _helper.showToast(component, true, JSON.stringify(response.getError()));
            }
            _helper.fireToggleSpinnerEvent(component, false);   
        });

        $A.enqueueAction(getAssetCoordinates);
        _helper.fireToggleSpinnerEvent(component, true);

        console.log('TA_LCP262_Geolocalization >> Helper >> initialize >> End');
    },

    getCurrentCoordinates : function(component) {
        console.log('TA_LCP262_Geolocalization >> Helper >> getCurrentCoordinates >> Start');
        
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
        console.log('TA_LCP262_Geolocalization >> Helper >> getCurrentCoordinates >> End');
    },

    fireSendInitStateEvt : function(component, isInitialized) {
        console.log('TA_LCP262_Geolocalization >> Helper >> fireSendInitStateEvt >> Start');
        
        let sendInitStateEvt = component.getEvent("sendInitStateEvt");
        sendInitStateEvt.setParams({
            "componentName" : "TA_LCP262_Geolocalization",
            "initState" : isInitialized
        });
        sendInitStateEvt.fire();

        console.log('TA_LCP262_Geolocalization >> Helper >> fireSendInitStateEvt >> End');
    },

    fireValidationEvt : function(component, errors) {
        console.log('TA_LCP262_Geolocalization >> Helper >> fireValidationEvt >> Start');
        
        let validationEvt = $A.get("e.c:TA_LCE199_Validation");
        validationEvt.setParams({
            "cmpName" : component.get('v.cmpName') + '-' + component.getGlobalId(),
            "errors" : errors,
            "validate" : errors.length > 0 ? false : true
        }); 
        validationEvt.fire();
        console.log('TA_LCP262_Geolocalization >> Helper >> fireValidationEvt >> End');
    },

    updateCoordinates : function(component, currentLatitude, currentLongitude, currentAccuracy) {
        console.log('TA_LCP262_Geolocalization >> Helper >> updateCoordinates >> Start');
        
        let _helper = this;

        let action = component.get('c.updateCoordinates');
        
        console.log('@@>> workOrderId >>> ' + component.get('v.workOrderId'));
        console.log('@@>> currentLatitude >>> ' + currentLatitude);
        console.log('@@>> currentLongitude >>> ' + currentLongitude);
        console.log('@@>> currentAccuracy >>> ' + currentAccuracy);

        action.setParams({
            'recordId' : component.get('v.workOrderId'),
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

                    this.fireValidationEvt(component, []);
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

    fireToggleSpinnerEvent : function(component, toggleSpinner) {
        console.log('TA_LCP262_Geolocalization >> Helper >> fireToggleSpinnerEvent >> Start');
        
        let toggleSpinnerEvent = component.getEvent("toggleSpinnerEvent");
        toggleSpinnerEvent.setParams({
            "sourceComponent" : "TA_LCP262_Geolocalization",
            "toggleSpinner" : toggleSpinner
        });
        toggleSpinnerEvent.fire();

        console.log('TA_LCP262_Geolocalization >> Helper >> fireToggleSpinnerEvent >> End');
    },

    showToast: function(component, isError, toastMessage) {
        component.set("v.showToastMessage", true);
        component.set("v.isError", isError);
        component.set("v.toastMessage", toastMessage);
    },

})