({
    initialize : function(component) {
        console.log('TA_LCP220_LeadConversion >> Helper >> initialize >> Start');
        component.set('v.general', JSON.parse(component.get('v.fieldSet')).general);
        component.set('v.custom', JSON.parse(component.get('v.fieldSet')).custom);
        component.set('v.title', $A.getReference("$Label.c." + component.get('v.general').defaultTitle));
        component.set('v.description', $A.getReference("$Label.c." + component.get('v.general').description));

        let action = component.get("c.initialize");
        action.setParams({'inputParameter' : JSON.stringify(component.get("v.custom")),
                          'objectId' : component.get('v.workOrderId')});

        action.setCallback(this, function(response) {
            console.log('TA_LCP220_LeadConversion >> Helper >> initializeCallback >> Start');
            if(response.getState() === "SUCCESS") {
                let returnValue = response.getReturnValue();
                let infoBag = JSON.parse(returnValue);
                component.set("v.infoBag", infoBag);
                component.set("v.infoBagWithDBValues", infoBag);

                if(infoBag.relatedAddress) {
                    let address = component.get("v.address");
                    address.country = infoBag.relatedAddress.XC_AddressCountry__c;
                    address.streetType = infoBag.relatedAddress.XC_StreetTypeText__c;
                    address.address = infoBag.relatedAddress.XC_Address__c;
                    address.streetNumber = infoBag.relatedAddress.XC_StreetNumber__c;
                    address.door = infoBag.relatedAddress.XC_Door__c;
                    address.postalCode = infoBag.relatedAddress.XC_PostalCode__c;
                    address.stair = infoBag.relatedAddress.XC_Stair__c;
                    address.floor = infoBag.relatedAddress.XC_Floor__c;
                    address.city = infoBag.relatedAddress.XC_City__c;
                    address.province = infoBag.relatedAddress.XC_AddressProvince__c;
                    address.category = infoBag.relatedAddress.XC_Category__c;
                    address.municipality = infoBag.relatedAddress.XC_Municipality__c;
                    address.streetTypeText = infoBag.relatedAddress.XC_StreetTypeText__c;
                    address.gas = infoBag.relatedAddress.XC_GasCUPS__c;
                    address.electric = infoBag.relatedAddress.XC_ElectricCUPS__c;
                    if(infoBag.lookupObjectName == 'Account') {
                        component.set("v.showModal", false);
                        address.account = infoBag.relatedAddress.XC_Account__c;
                    } else if(infoBag.lookupObjectName == 'Lead') {
                        address.lead = infoBag.relatedAddress.XC_Lead__c;
                    }
                    address.region = infoBag.relatedAddress.XC_Region__c;
                    address.clarifType = infoBag.relatedAddress.XC_ClarificatorType__c;
                    address.clarifValue = infoBag.relatedAddress.XC_ClarificatorValue__c;
                    address.note = infoBag.relatedAddress.XC_Note__c;

                    component.set("v.address", address);
                }

                component.set('v.customerCardBg', $A.get('$Resource.TA_Images') + '/imgs/' + component.get('v.general.bgImage'));
                this.fireSendInitStateEvt(component, true);
                this.fireSendParamsToButtonSectionEvt(component, JSON.parse(returnValue), JSON.parse(returnValue));
                component.set('v.isInitialized', true);
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
            console.log('TA_LCP220_LeadConversion >> Helper >> initializeCallback >> End');
        });

        $A.enqueueAction(action);
        console.log('TA_LCP220_LeadConversion >> Helper >> initialize >> End');
    },

    closeModal : function(component) {
        console.log('TA_LCP220_LeadConversion >> Helper >> closeModal >> Start');
        component.set("v.showModal", false);
        console.log('TA_LCP220_LeadConversion >> Helper >> closeModal >> End');
    },

    manageButtons : function(component, event) {
        console.log('TA_LCP220_LeadConversion >> Helper >> manageButtons >> Start');
        component.set("v.disableFields", !component.get("v.disableFields"));
        if(!component.get("v.disableFields")) {
            component.set("v.editOrSaveLabel", "Save");
        } else {
            component.set("v.editOrSaveLabel", "Edit");
            this.fireSendParamsToButtonSectionEvt(component, component.get("v.infoBag"), component.get("v.infoBagWithDBValues"));
        }
        console.log('TA_LCP220_LeadConversion >> Helper >> manageButtons >> End');
    },

    setAddress : function(component, event) {
        console.log('TA_LCP220_LeadConversion >> Helper >> setAddress >> Start');
        this.fireSendParamsToButtonSectionEvt(component, component.get("v.infoBag"), component.get("v.infoBagWithDBValues"));
        console.log('TA_LCP220_LeadConversion >> Helper >> setAddress >> End');
    },

    fireSendInitStateEvt : function(component, isInitialized) {
        console.log('TA_LCP220_LeadConversion >> Helper >> fireSendInitStateEvt >> Start');
        let sendInitStateEvt = component.getEvent("sendInitStateEvt");
        sendInitStateEvt.setParams({
            "componentName" : "TA_LCP220_LeadConversion",
            "initState" : isInitialized
        });
        sendInitStateEvt.fire();
        console.log('TA_LCP220_LeadConversion >> Helper >> fireSendInitStateEvt >> End');
    },

    fireSendParamsToButtonSectionEvt : function(component, infoBag, infoBagWithDBValues) {
        console.log('TA_LCP220_LeadConversion >> Helper >> fireSendParamsToButtonSectionEvt >> Start');
        let paramsWrapper = {};
        paramsWrapper.infoBag = infoBag;
        paramsWrapper.infoBagWithDBValues = infoBagWithDBValues;
        paramsWrapper.address = {};
        paramsWrapper.address = component.get("v.address");
        let sendLeadConversionEvt = $A.get("e.c:TA_LCE223_LeadConversion");
        sendLeadConversionEvt.setParams({
            "paramsWrapper" : paramsWrapper
        });
        sendLeadConversionEvt.fire();
        console.log('TA_LCP220_LeadConversion >> Helper >> fireSendParamsToButtonSectionEvt >> End');
    }
})