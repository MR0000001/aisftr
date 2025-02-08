({  
    doInit: function (component, event, helper) {
        
        console.log('@@@ Component initialization');
        var recordId = component.get("v.recordId");
        console.log("recordId " + recordId);
        var action = component.get("c.initializeComponent");
        action.setParams({
            "orderId": recordId
        });
        action.setCallback(this, function (a) {
            var state = a.getState();
            var result = a.getReturnValue();
            console.log("@@@ State Result : " + state + " And record is: " + recordId);
            component.set("v.showSpinner", false);
            if (state === 'SUCCESS') {
                if(result) {
                    var object = JSON.parse(result.objectInfo);
                    var secondaryContactValues = [];
                    var count= Object.keys(object.secondaryContacts).length;

                    component.set("v.personalDocumentFieldSet", object['personalDocumentFieldSet']);
                    component.set("v.personalPrimaryDocumentFieldSet", object['personalPrimaryDocumentFieldSet']);
                    component.set("v.accountId", object['accountId']);
                    component.set("v.contactFromOpportunity", object['contactFromOpportunity']);

                    var contactRelationshipMap = new Map();
                    if (object.secondaryContacts) {
                        if(count == 1){
                            contactRelationshipMap[object.secondaryContacts[0].key] = object.secondaryContacts[0].relationshipType;
                            secondaryContactValues.push({
                                value: object.secondaryContacts[0].key,
                                label: object.secondaryContacts[0].value,
                            });
                        } else {
                            (object.secondaryContacts).forEach(function (entry) {
                                secondaryContactValues.push({
                                    value: entry['key'],
                                    label: entry['value'],
                                });
                                contactRelationshipMap[entry['key']] = entry['relationshipType'];
                            })
                        }
                        component.set("v.secondaryContactValues", secondaryContactValues);
                        component.set("v.contactRelationshipMap", contactRelationshipMap);

                    }
                    
                    var primaryContactDocumentValues = [];
                    var count= Object.keys(object.primaryContactsDocument).length;

                    if (object.primaryContactsDocument) {
                        if(count == 0) {

                            component.set("v.existingPrimaryContactDocument", false);

                            let inputCmps = component.find('field2');
                            
                            inputCmps.forEach(element => {
                                if(element.get("v.fieldName") == "XC_Account__c"){
                                    element.set("v.value", object['accountId']);
                                    $A.util.toggleClass(inputCmps, 'slds-hide');
                                }
                                if(element.get("v.fieldName") == "XC_Contact__c"){
                                     element.set("v.value", component.get("v.contactFromOpportunity"));
                                     $A.util.toggleClass(inputCmps, 'slds-hide');
                                }
                                if(element.get("v.fieldName") == "XC_Country__c"){
                                    element.set("v.value", 'Italy');
                                    element.set("v.disabled", "true");
                               }
                               if(element.get("v.fieldName") == "XC_DocumentType__c"){
                                element.set("v.value", 'CI');
                                element.set("v.disabled", "true");
                                }
                            })
                        }else if(count == 1){
                            component.set("v.existingPrimaryContactDocument", true);
                            primaryContactDocumentValues.push({
                                value: object.primaryContactsDocument[0].key,
                                label: object.primaryContactsDocument[0].value
                            });
                        } else {
                            component.set("v.existingPrimaryContactDocument", true);
                            (object.primaryContactsDocument).forEach(function (entry) {
                                primaryContactDocumentValues.push({
                                    value: entry['key'],
                                    label: entry['value']
                                });
                            })
                        }
                        component.set("v.primaryContactDocumentValues", primaryContactDocumentValues);
                    }
                    
                                    
                } else {
                    helper.showToast(component, result.resultMessage, 'error', true);
                }
            } else {
                helper.showToast(component, a.getError(), 'error', true);
            }
            
        });
        $A.enqueueAction(action);
    },

    handleSecondaryContactChange: function(component, event, helper) {
        component.set("v.showSpinner", true);
        var selectedSecondaryContact = component.get("v.secondaryContactValue");
        var relationship = component.get("v.contactRelationshipMap")[selectedSecondaryContact]; 
        component.set("v.contactRelationshipType", relationship);
        console.log("selected Secondary Contact " + selectedSecondaryContact + " relationshipType " + relationship);
        var action = component.get("c.getSecondaryContactDocument");
        action.setParams({
            "secondaryContactId": selectedSecondaryContact
        });
        action.setCallback(this, function (a) {
            var state = a.getState();
            var result = a.getReturnValue();
            console.log("@@@ State Result : " + state);
            component.set("v.showSpinner", false);
            if (state === 'SUCCESS') {
                if(result) {
                    var object = JSON.parse(result.objectInfo);
                    var secondaryContactDocumentValues = [];
                    var count= Object.keys(object.secondaryContactDocuments).length;
                    console.log(count);

                    if (object.secondaryContactDocuments) {
                        if(count == 0) {
                            component.set("v.existingSecondaryContactDocument", false);

                            let inputCmps = component.find('field1');
                            
                            inputCmps.forEach(element => {
                                if(element.get("v.fieldName") == "XC_Account__c"){
                                    element.set("v.value", component.get("v.accountId"));
                                    element.set("v.hidden", "true");
                                }
                                if(element.get("v.fieldName") == "XC_Contact__c"){
                                    element.set("v.value", selectedSecondaryContact);
                                    element.set("v.hidden", "true");
                                }
                                if(element.get("v.fieldName") == "XC_Country__c"){
                                    element.set("v.value", 'Italy');
                                    element.set("v.disabled", "true");
                               }
                               if(element.get("v.fieldName") == "XC_DocumentType__c"){
                                element.set("v.value", 'CI');
                                element.set("v.disabled", "true");
                                }
                            })
                            
                        }else if(count == 1){
                            component.set("v.existingSecondaryContactDocument", true);
                            secondaryContactDocumentValues.push({
                                value: object.secondaryContactDocuments[0].key,
                                label: object.secondaryContactDocuments[0].value
                            });
                        } else {
                            component.set("v.existingSecondaryContactDocument", true);
                            (object.secondaryContactDocuments).forEach(function (entry) {
                                secondaryContactDocumentValues.push({
                                    value: entry['key'],
                                    label: entry['value']
                                });
                            })
                        }
                        component.set("v.secondaryContactDocumentValues", secondaryContactDocumentValues);
                    }               
                } else {
                    helper.showToast(component, result.resultMessage, 'error', true);
                }
            } else {
                helper.showToast(component, a.getError(), 'error', true);
            }
            
        });
        $A.enqueueAction(action);
    },

    showToast : function(component, message, type, closeQuickAction) {
        component.set("v.showSpinner", false);
        component.find('notifLib').showToast({
            "title": message,
            "message": '',
            "variant": type
        });
        if (closeQuickAction == true) {
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
        }
    },

    handleCancel : function(component) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },

    checkFields: function(component, event, helper) {
        component.set("v.showSpinner", true);
        var isComponentValid = true;

        if($A.util.isEmpty(component.get("v.secondaryContactValue"))){
            isComponentValid = false;
        }
    
        var secondaryDocValid = false;
        var primaryDocValid = false;

        if(component.get("v.existingSecondaryContactDocument") == false) {
            let inputCmps = component.find('field1');
            secondaryDocValid = this.checkInputFields(inputCmps); 
        }

        if(secondaryDocValid == false && $A.util.isEmpty(component.get("v.secondaryContactDocumentValue"))) {
            isComponentValid = false;
        }

        if(component.get("v.existingPrimaryContactDocument") == false) {
            let inputCmps2 = component.find('field2');
            primaryDocValid = this.checkInputFields(inputCmps2);
            
        }

        if(primaryDocValid == false && $A.util.isEmpty(component.get("v.primaryContactDocumentValue"))) {
            isComponentValid = false;
        }

        if (isComponentValid === true) {
            let button = component.find('saveButtonId');
            button.set('v.disabled',false);
        }
        component.set("v.showSpinner", false);
        return isComponentValid;
    },

    handleSave : function(component, event, helper) {
        
        //if(isComponentValid === true) {
        if(component.get("v.existingPrimaryContactDocument") == false) {
            component.find("primaryContactDocumentForm").submit();
        }
        if(component.get("v.existingSecondaryContactDocument") == false) {
            component.find("secondaryContactDocumentForm").submit();
        } 

        if(component.get("v.existingSecondaryContactDocument") && component.get("v.existingPrimaryContactDocument")) {
            this.updateOrder(component, event, helper);
        }else {
			let button = component.find('saveButtonId');
            button.set('v.disabled',false);
            component.set("v.showSpinner", false);
        }
        /*} else {
            console.log('is not valid');
            helper.showToast(component, $A.get("$Label.c.XC_CL_RequiredFields"), 'error', false);
            let button = component.find('saveButtonId');
            button.set('v.disabled',false);
            component.set("v.showSpinner", false);
        }
        */
        
    },

    checkInputFields : function (inputCmps) { 
        //check if all fields are valid
        let isAllValid = inputCmps.reduce(function(validSoFar,currentInput){
            let validField = true;
            if(currentInput.get("v.required") && $A.util.isEmpty(currentInput.get("v.value"))){
                console.log(currentInput.get("v.fieldName"));
                validField = false;
            }
            return validSoFar && validField;
        },true);

        console.log('is valid or not' + isAllValid);
        return isAllValid;
    },

    handleSuccessPrimary : function(component, event, helper) {
        var payload = event.getParams().response;
        component.set("v.primaryContactDocumentValue", payload.id);
        if(! $A.util.isEmpty(component.get("v.secondaryContactDocumentValue"))) {
            this.updateOrder(component, event, helper);
        }
    },
    
    handleSuccessSecondary : function(component, event, helper) {
        var payload = event.getParams().response;
        component.set("v.secondaryContactDocumentValue", payload.id);
        if(! $A.util.isEmpty(component.get("v.primaryContactDocumentValue"))) {
            this.updateOrder(component, event, helper);
        }
    },
    
    updateOrder : function (component, event, helper) {
        var map = new Object();
        map["recordId"] = component.get("v.recordId");
        map["secondaryContact"] = component.get("v.secondaryContactValue");
        map["relationshipType"] = component.get("v.contactRelationshipType");
        map["primaryContactDocumentId"] = component.get("v.primaryContactDocumentValue");
        map["secondaryContactDocumentId"] = component.get("v.secondaryContactDocumentValue");

        var action = component.get("c.updateOrder");
        action.setParams({
            "paramsMap": map
        });
        action.setCallback(this, function (a) {
            var state = a.getState();
            console.log("@@@ State Result : " + state);
            component.set("v.showSpinner", false);
            if (state === 'SUCCESS') {
                var result = a.getReturnValue();
                if(result.success) { 
                    helper.showToast(component, $A.get("$Label.c.XC_CL_OrderUpdated"), 'success', true);
                } else {
                    helper.showToast(component, result.resultMessage, 'error', false);
                }
            } else {
                helper.showToast(component, a.getError(), 'error', false);
            }
        });
        $A.enqueueAction(action);
    }
})