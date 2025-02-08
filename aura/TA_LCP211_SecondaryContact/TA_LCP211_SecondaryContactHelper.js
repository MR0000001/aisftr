({
    initialize : function(component, event, helper) {
        console.log('TA_LCP211_SecondaryContact >> Helper >> initialize >> Start');
        component.set("v.selectedContact", component.get("v.contactId"));
        component.set('v.general', JSON.parse(component.get('v.fieldSet')).general);
        component.set('v.custom', JSON.parse(component.get('v.fieldSet')).custom);
        component.set('v.title', $A.getReference("$Label.c." + component.get('v.general').defaultTitle));
        component.set('v.description', $A.getReference("$Label.c." + component.get('v.general').description));
        component.set('v.customerCardBg', $A.get('$Resource.TA_Images') + '/imgs/' + component.get('v.general.bgImage'));

        let action = component.get("c.initialize");
        action.setParam("inputParameter", JSON.stringify(component.get('v.custom')));
        action.setParam("workOrderId", component.get("v.workOrder").Id);

        action.setCallback(this, function(response) {
            console.log('TA_LCP211_SecondaryContact >> Helper >> initializeCallback >> Start');
            if(response.getState() == "SUCCESS") {
                component.set("v.infoBag", JSON.parse(response.getReturnValue()));
                if(!component.get("v.infoBag").error) {
                    let newContact = {
                        "Account": {
                            "AccountID": component.get("v.accountId")
                        },
                        "Contact": [
                            {
                                "LastName": "",
                                "FirstName": "",
                                "Email": "",
                                "IdentityType": "",
                                "IdentityNumber": "",
                                "GDPR": {
                                    "GiveDataToThirdParties": "N",
                                    "LegalEntity": [
                                        {
                                            "LegalEntity": "",
                                            "GiveDataToLegalEntity": "N",
                                            "GiveDataForMarketing": "N",
                                            "GiveDataForProfiling": "N"
                                        }
                                    ]
                                }
                            }
                        ]
                    };
                    component.set('v.newContact', newContact);
                    this.fireSendInitStateEvt(component, true);
                } else {
                    component.set("v.showToastMessage", true);
                    component.set("v.isError", true);
                    component.set("v.toastMessage", component.get("v.infoBag").error);
                }
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
            console.log('TA_LCP211_SecondaryContact >> Helper >> initializeCallback >> End');
        });

        $A.enqueueAction(action);
        console.log('TA_LCP211_SecondaryContact >> Helper >> initialize >> End');
    },

    closeModal : function(component, event, helper) {
        console.log('TA_LCP211_SecondaryContact >> Helper >> closeModal >> Start');
        component.set("v.showModal", false);
        component.set("v.showNewContactForm", false);
        helper.clearSection(component, event, helper);
        console.log('TA_LCP211_SecondaryContact >> Helper >> closeModal >> End');
    },

    manageModal : function(component, event, helper) {
        console.log('TA_LCP211_SecondaryContact >> Helper >> manageModal >> Start');
        helper.clearSection(component, event, helper);
        component.set("v.showNewContactForm", !component.get("v.showNewContactForm"));
        console.log('TA_LCP211_SecondaryContact >> Helper >> manageModal >> End');
    },
 
    loadContact : function(component, event, helper) {
        console.log('TA_LCP211_SecondaryContact >> Helper >> loadContact >> Start');
        let action = component.get("c.loadContact");
        action.setParam("infoBagSerialized", JSON.stringify(component.get("v.infoBag")));
        action.setParam("accountId", component.get("v.accountId"));
        action.setParam("contactId", component.get("v.selectedContact") != null ? component.get("v.selectedContact") : component.get("v.contactId"));

        action.setCallback(this, function(response) {
            console.log('TA_LCP211_SecondaryContact >> Helper >> loadContactCallback >> Start');
            if(response.getState() == "SUCCESS") {
                component.set("v.infoBag", JSON.parse(response.getReturnValue()));
                if(component.get("v.infoBag").error) {
                    component.set("v.showToastMessage", true);
                    component.set("v.isError", true);
                    component.set("v.toastMessage", component.get("v.infoBag").error);
                }
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
            console.log('TA_LCP211_SecondaryContact >> Helper >> loadContactCallback >> End');
        });

        $A.enqueueAction(action);
        console.log('TA_LCP211_SecondaryContact >> Helper >> loadContact >> End');
    },

    selectContact : function(component, event, helper) {
        console.log('TA_LCP211_SecondaryContact >> Helper >> selectContact >> Start');
        let newContactId = event.currentTarget.id;
        let infoBag = component.get("v.infoBag");
        infoBag.contactWrapperList.forEach(function(contactWrapper) {
            if(contactWrapper.id == newContactId) {
                contactWrapper.selected = true;
            } else if(contactWrapper.id == component.get("v.selectedContact")) {
                contactWrapper.selected = false;
            }
        });
        component.set("v.selectedContact", newContactId);
        component.set("v.infoBag", infoBag);
        console.log('TA_LCP211_SecondaryContact >> Helper >> selectContact >> End');
    },

    updateContact : function(component, event, helper) {
        console.log('TA_LCP211_SecondaryContact >> Helper >> updateContact >> Start');
        let action = component.get("c.updateContact");
        action.setParam("infoBagSerialized", JSON.stringify(component.get("v.infoBag")));
        action.setParam("workOrderId", component.get("v.workOrder").Id);
        action.setParam("newContactId", component.get("v.selectedContact"));

        action.setCallback(this, function(response) {
            console.log('TA_LCP211_SecondaryContact >> Helper >> updateContactCallback >> Start');
            if(response.getState() == "SUCCESS") {
                helper.closeModal(component, event, helper);
                helper.fireRefreshEvt(component);
                helper.fireToggleSpinnerEvent(component, false);
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
            console.log('TA_LCP211_SecondaryContact >> Helper >> updateContactCallback >> End');
        });

        $A.enqueueAction(action);
        helper.fireToggleSpinnerEvent(component, true);
        console.log('TA_LCP211_SecondaryContact >> Helper >> updateContact >> End');
    },

    saveNewContact : function(component, event, helper) {
        console.log('TA_LCP211_SecondaryContact >> Helper >> saveNewContact >> Start');
        let infoBag = component.get("v.infoBag");
        infoBag.error = '';
        let checkField = true;

        let fiscalCodePattern = /^[a-zA-Z]{6}[0-9]{2}[a-zA-Z][0-9]{2}[a-zA-Z][0-9]{3}[a-zA-Z]$/;
        let documentType;
        let documentNumber;

        component.set("v.showToastMessage", false);

        infoBag.fieldStructureList.forEach(function(fieldStructure) {
            if(fieldStructure.required && fieldStructure.value == "") {
                fieldStructure.error = "Complete this field.";
                checkField = false;
            }

            if(fieldStructure.apiName == 'XC_ContactDocumentType__c'){
                documentType = fieldStructure.value;
            } else if (fieldStructure.apiName == 'XC_ContactDocumentNumber__c'){
                documentNumber = fieldStructure.value;
            }
        });

        if(documentType == 'CF' && documentNumber.search(fiscalCodePattern) == -1){     
            component.set("v.showToastMessage", true);
            component.set("v.isError", true);
            component.set("v.toastMessage", 'Il Codice Fiscale inserito è errato.');
            return;
        }

        if(checkField) {
            let action = component.get("c.saveNewContact");
            action.setParam("infoBagSerialized", JSON.stringify(infoBag));
            action.setParam("newContact", JSON.stringify(component.get("v.newContact")));

            action.setCallback(this, function(response) {
                console.log('TA_LCP211_SecondaryContact >> Helper >> saveNewContactCallback >> Start');
                if(response.getState() == "SUCCESS") {
                    let infoBag = JSON.parse(response.getReturnValue());
                    if(!infoBag.error) {
                        component.set("v.infoBag", infoBag);
                        let contacts = component.get('v.infoBag.contactWrapperList');
                        contacts.forEach(function(contact) {
                            if(contact.selected) component.set('v.selectedContact', contact.id);
                        });
                        helper.manageModal(component, event, helper);
                        helper.clearSection(component, event, helper);
                    } else {
                        component.set("v.showToastMessage", true);
                        component.set("v.isError", true);
                        component.set("v.toastMessage", infoBag.error);
                    }

                    helper.fireToggleSpinnerEvent(component, false);
                } else if(response.getState() == "ERROR") {
                    component.set("v.showToastMessage", true);
                    component.set("v.isError", true);
                    component.set("v.toastMessage", JSON.stringify(response.getError()));
                }
                console.log('TA_LCP211_SecondaryContact >> Helper >> saveNewContactCallback >> End');
            });
            $A.enqueueAction(action);
            helper.fireToggleSpinnerEvent(component, true);
        } else {
            component.set("v.infoBag", infoBag);
        }
        console.log('TA_LCP211_SecondaryContact >> Helper >> saveNewContact >> End');
    },

    fireToggleSpinnerEvent : function(component, toggleSpinner) {
        console.log('TA_LCP211_SecondaryContact >> Helper >> fireToggleSpinnerEvent >> Start');
        let toggleSpinnerEvent = component.getEvent("toggleSpinnerEvent");
        toggleSpinnerEvent.setParams({
            "sourceComponent" : "TA_LCP211_SecondaryContact",
            "toggleSpinner" : toggleSpinner
        });
        toggleSpinnerEvent.fire();
        console.log('TA_LCP211_SecondaryContact >> Helper >> fireToggleSpinnerEvent >> End');
    },

    inputChange : function(component, fieldInput, helper) {
        console.log('TA_LCP211_SecondaryContact >> Helper >> inputChange >> Start');
        let infoBag = component.get("v.infoBag");
        let isButtonDisabled = false;

        infoBag.fieldStructureList.forEach(function(fieldStructure) {
            if(!fieldStructure.value && fieldStructure.required) {
                isButtonDisabled = true;
            }
        });

        component.set("v.isButtonDisabled", isButtonDisabled);

        let newContact = component.get('v.newContact');
        let fieldValue = "";

        infoBag.fieldStructureList.forEach(function(fieldStructure) {
            if(fieldStructure.apiName == fieldInput) {
                fieldValue = fieldStructure.value;
            }
        });

        if(fieldValue == "") {
            infoBag.gdprStructureList.forEach(function(gdprStructure) {
                if(gdprStructure.apiName == fieldInput) {
                    if(gdprStructure.value) {
                        fieldValue = "Y";
                    } else {
                        fieldValue = "N";
                    }
                }
            });
        }

        if(fieldValue != "") {
            if(fieldInput == 'FirstName') {
                newContact.Contact[0].FirstName = fieldValue;
            } else if(fieldInput == 'LastName') {
                newContact.Contact[0].LastName = fieldValue;
            } else if(fieldInput == 'Email') {
                newContact.Contact[0].Email = fieldValue;
            } else if(fieldInput == 'XC_ContactDocumentCountry__c') {
                helper.reloadDocumentTypePicklist(component, helper, 'XC_ContactDocumentCountry__c', 'XC_ContactDocumentType__c', fieldValue);
            } else if(fieldInput == 'XC_ContactDocumentType__c') {
                newContact.Contact[0].IdentityType = fieldValue;
            } else if(fieldInput == 'XC_ContactDocumentNumber__c') {
                newContact.Contact[0].IdentityNumber = fieldValue;
            } else if(fieldInput == 'giveDataToLE') {
                newContact.Contact[0].GDPR.LegalEntity[0].GiveDataToLegalEntity = fieldValue;
            } else if(fieldInput == 'thirdParties') {
                newContact.Contact[0].GDPR.GiveDataToThirdParties = fieldValue;
            } else if(fieldInput == 'marketing') {
                newContact.Contact[0].GDPR.LegalEntity[0].GiveDataForMarketing = fieldValue;
            } else if(fieldInput == 'profiling') {
                newContact.Contact[0].GDPR.LegalEntity[0].GiveDataForProfiling = fieldValue;
            }
        }

        component.set('v.newContact', newContact);
        console.log('TA_LCP211_SecondaryContact >> Helper >> inputChange >> End');
    },

    fireSendInitStateEvt : function(component, isInitialized) {
        console.log('TA_LCP211_SecondaryContact >> Helper >> fireSendInitStateEvt >> Start');
        let sendInitStateEvt = component.getEvent("sendInitStateEvt");
        sendInitStateEvt.setParams({
            "componentName" : "TA_LCP211_SecondaryContact",
            "initState" : isInitialized
        });
        sendInitStateEvt.fire();
        console.log('TA_LCP211_SecondaryContact >> Helper >> fireSendInitStateEvt >> End');
    },

    fireRefreshEvt : function(component) {
        console.log('TA_LCP211_SecondaryContact >> Helper >> fireRefreshEvt >> Start');
        let fireRefreshEvt = $A.get("e.c:TA_LCE224_Refresh");
        fireRefreshEvt.setParam('action','dynamic-layout-initialize');
        fireRefreshEvt.fire();
        console.log('TA_LCP211_SecondaryContact >> Helper >> fireRefreshEvt >> End');
    },

    reloadDocumentTypePicklist : function(component, helper, masterPicklistApiName, dependantPicklistApiName, documentCountryValue) {
        console.log('TA_LCP211_SecondaryContact >> Helper >> reloadDocumentTypePicklist >> Start');
        let action = component.get("c.reloadDocumentTypePicklist");
        action.setParam("masterPicklistApiName", masterPicklistApiName);
        action.setParam("dependantPicklistApiName", dependantPicklistApiName);

        action.setCallback(this, function(response) {
            console.log('TA_LCP211_SecondaryContact >> Helper >> reloadDocumentTypePicklistCallback >> Start');
            if(response.getState() == "SUCCESS") {
                let fields = component.get("v.infoBag.fieldStructureList");
                let newAvailableValues = [{"label":"None","value":""}];
                let documentTypeValues = JSON.parse(response.getReturnValue());
                let availableValues = documentTypeValues[documentCountryValue];

                for(let i = 0; i < fields.length; i++) {
                    if(fields[i].apiName == dependantPicklistApiName) {
                        if(availableValues.length > 0) {
                            for(let j = 0; j < availableValues.length; j++) {
                                let newAvailableValue = {};
                                newAvailableValue.label = availableValues[j];
                                newAvailableValue.value = availableValues[j];
                                newAvailableValues.push(newAvailableValue);
                            }

                        } else {
                            let newAvailableValue = {};
                            newAvailableValue.label = 'No document type available';
                            newAvailableValue.value = '';
                            newAvailableValues.push(newAvailableValue);
                        }

                        fields[i].availableValues = newAvailableValues;
                    }
                }

                component.set("v.infoBag.fieldStructureList", fields);
                helper.fireToggleSpinnerEvent(component, false);
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
            console.log('TA_LCP211_SecondaryContact >> Helper >> reloadDocumentTypePicklistCallback >> End');
        });
        $A.enqueueAction(action);
        helper.fireToggleSpinnerEvent(component, true);
        console.log('TA_LCP211_SecondaryContact >> Helper >> reloadDocumentTypePicklist >> End');
    },

    clearSection : function(component, event, helper) {
        console.log('TA_LCP211_SecondaryContact >> Helper >> clearSection >> Start');
        let fields = component.get("v.infoBag.fieldStructureList");
        for(let i = 0; i < fields.length; i++) {
            fields[i].value = '';
        }
        component.set("v.infoBag.fieldStructureList", fields);
        console.log('TA_LCP211_SecondaryContact >> Helper >> clearSection >> End');
    }
})