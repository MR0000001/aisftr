({
    doInit: function(component, event) {
        var recordId = component.get("v.recordId");
        
        component.set("v.isCase",String(recordId).startsWith("500"));
        component.set("v.showCaseDetails", false);
        component.set("v.showCaseBasicInformation", true);
        /*window.addEventListener("message", $A.getCallback(function(event) {
            var vfOrigin = component.get("v.vfOrigin");
            var message = event.data;
            console.log("vfOrigin "+vfOrigin);
            console.log("event.origin "+event.origin);
            if (event.origin !== vfOrigin) {
                // Not the expected origin: Reject the message!
                return;
            }
            
            if(message == undefined) {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title":  $A.get("$Label.c.caseDetails_Attention"),
                    "message":  $A.get("$Label.c.caseDetails_SelectPin"),
                    "type":"error"
                });
                toastEvent.fire();
            } else {
                console.log("message "+message);
                if(message != "goback"){
                    component.set("v.fullAddress",message.fullAddress);
                    component.set("v.address",message.streetAddress);
                    component.set("v.numberAddress",message.numberAddress);
                    component.set("v.letterAddress",message.letterAddress);
                    component.set("v.lat",message.lat);
                    component.set("v.lng",message.lng);
                }
                component.set("v.showCaseDetails", true);
                component.set("v.showCaseBasicInformation", false);
                component.set("v.callNic",(message != "goback"));
                console.log("@@@ callNic "+component.get("v.callNic"));
                component.set("v.showGeoCoding",false);
            }
          // Handle the message
      }), false);*/
   },
    
    handleFilterChange: function(component, event) {
        var action = event.getParam('action');
        console.log('handleFilterChange, action -> ', action);
        if ( action != 'noCloseTab' ) {
            var workspaceAPI = component.find("workspace");
            workspaceAPI.getFocusedTabInfo().then(function(response) {
                var focusedTabId = response.tabId;
                workspaceAPI.closeTab({tabId: focusedTabId});
            })
            .catch(function(error) {
                console.log(error);
            });
        } else {
            var navigate = component.get("v.navigateFlow");
            console.log('navigate -> ');
            if ( navigate != null && navigate != '') {
                navigate("FINISH");
            }
        }
    },
    
    handleCloseQuickAction: function(component, event) {
        console.log('handleCloseQuickAction');
        $A.get("e.force:closeQuickAction").fire();
    },

    handleBack: function(component, event) {
        console.group('handleConfirm');
        component.set("v.showGeoCoding", false);
        component.set("v.showCaseDetails", true);
        component.set("v.showCaseBasicInformation", false);
        console.log('event.getParams(): ', JSON.parse(JSON.stringify(event.getParams())));
        if(Object.keys(event.getParams()).length) {
            console.log('confirm address');
            component.set("v.lat", event.getParam('lat'));
            component.set("v.lng", event.getParam('lng'));
            component.set("v.municipality", event.getParam('municipality'));
            component.set("v.fullAddress", event.getParam('fullAddress'));
            component.set("v.address", event.getParam('address'));
            component.set("v.numberAddress", event.getParam('numberAddress'));
            component.set("v.letterAddress", event.getParam('letterAddress'));
            
            console.log('lat: ',component.get("v.lat"));
            console.log('lng: ',component.get("v.lng"));
            console.log('municipality: ',component.get("v.municipality"));
            console.log('fullAddress: ',component.get("v.fullAddress"));
            console.log('address: ',component.get("v.address"));
            console.log('numberAddress: ',component.get("v.numberAddress"));
            console.log('letterAddress: ',component.get("v.letterAddress"));
        }
        console.groupEnd('handleConfirm');
    },
    
    showGeoCoding: function(component, event) {
        var params = event.getParam('params');
        component.set("v.typologySelected",params.typologyselected);
        component.set("v.interactionSelected",params.interactionselected);
        component.set("v.selectedQueue",params.selectedqueue);
        component.set("v.selectedThemarea",params.selectedthemarea);
        component.set("v.selectedArgument",params.selectedargument);
        component.set("v.selectedSpecification",params.selectedspecification);
        component.set("v.selectedThemareaR",JSON.stringify(params.selectedthemarear));
        component.set("v.selectedArgumentR",JSON.stringify(params.selectedargumentr));
        component.set("v.selectedSpecificationR",JSON.stringify(params.selectedspecificationr));
        component.set("v.estimatedQueue",params.estimatedQueue);
        component.set("v.showGeoCoding",true);
        component.set("v.fullAddress",params.fullAddress);
        component.set("v.address",params.address);
        component.set("v.numberAddress",params.numberAddress);
        component.set("v.letterAddress",params.letterAddress);
        /*component.set("v.vfOrigin",params.vfOrigin);
        component.set("v.domain",params.domain);
        component.set("v.googleKey",params.googleKey);
        component.set("v.urlGoogleMaps",params.domain+'/apex/GoogleMaps');*/
        component.set("v.bottomUp",params.bottomUp);
        component.set("v.municipality",params.municipality);
        component.set("v.contactId",params.contactId);
        component.set("v.accountId",params.accountId);
        component.set("v.serviceRequestId",params.serviceRequestId);
        component.set("v.origin",params.origin);
        component.set("v.caseId",params.caseid);
        component.set("v.isonchangeselected", params.isonchangeselected);
        component.set("v.subject", params.subject);
        component.set("v.isCreation", params.iscreation);
        component.set("v.nameinteraction", params.nameinteraction);
        /*component.set("v.isNicError", params.isNicError);*/
        component.set("v.oldInteraction", params.oldInteraction);
        component.set("v.protocolNumber", params.protocolNumber);
        component.set("v.personaFisica", params.personaFisica);
        component.set("v.caseBusinessAccount", params.caseBusinessAccount);
        component.set("v.lat", params.lat);
        component.set("v.lng", params.lng);
    }
})