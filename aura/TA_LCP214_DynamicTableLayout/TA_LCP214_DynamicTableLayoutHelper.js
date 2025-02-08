({
    init : function(component, callback) {
        console.log('TA_LCP214_DynamicTableLayout >> Helper >> initialize >> Start');
        if(component.get('v.accountId') == null) {
            this.fireSendInitStateEvt(component, true);
            return;
        }

        component.set('v.general', JSON.parse(component.get('v.fieldSet')).general);
        component.set('v.custom', JSON.parse(component.get('v.fieldSet')).custom);
        console.log("@@@custom",component.get("v.custom"));
        var getObjWrapper = component.get('c.getObjWrapper');
        getObjWrapper.setParams({
            'workOrderId' : component.get('v.workOrderId'),
            'customFieldSet' : JSON.stringify(component.get('v.custom')),
            'accountId' : component.get('v.accountId'),
            'NE_orderId': component.get('v.NE_orderId')
        });

        getObjWrapper.setCallback(this, function(response) {
            console.log('TA_LCP214_DynamicTableLayout >> Helper >> initializeCallback >> Start');
            if(response.getState() == "SUCCESS") {
                this.fireSendInitStateEvt(component, true);
                console.log(response.getReturnValue());
                console.log( JSON.stringify(component.get('v.general')));
                component.set('v.objWrapper', response.getReturnValue());

                if(component.get('v.general').titleType == 'default') {
                    component.set('v.title', $A.getReference("$Label.c." + component.get('v.general').defaultTitle));
                }

                if(component.get('v.objWrapper')[0].whereCondition) {
                    component.set('v.whereCondition', component.get('v.objWrapper')[0].whereCondition);
                }

                component.get('v.objWrapper').forEach(function(description) {
                    if(description.detailDescription != '' && component.get('v.detailDescription') == undefined ) {
                        component.set('v.detailDescription', $A.getReference("$Label.c." + description.detailDescription));
                    }
                    else if(description.detailDescription != '' && component.get('v.detailDescription') != undefined) {
                        component.set('v.detailDescription2', $A.getReference("$Label.c." + description.detailDescription));
                    }

                    if(description.totalCountLabel != '') {
                        component.set('v.footerLabel', $A.getReference("$Label.c." + description.totalCountLabel));
                    }
                });

                if(component.get('v.general').description != null && component.get('v.general').description != '') {
                    component.set('v.description', $A.getReference("$Label.c." + component.get('v.general').description));
                }

                component.set('v.customerCardBg', $A.get('$Resource.TA_Images') + '/imgs/' + component.get('v.general.bgImage'));
                component.set('v.checkIcon', $A.get('$Resource.TA_Icons') + '/xc-icons/check-white-bgp.svg');
                component.set('v.isInitialized', true);
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
            console.log('TA_LCP214_DynamicTableLayout >> Helper >> initializeCallback >> End');
        });

        $A.enqueueAction(getObjWrapper);
        console.log('TA_LCP214_DynamicTableLayout >> Helper >> initialize >> End');
    },

    fireSendInitStateEvt : function(component, isInitialized) {
        console.log('TA_LCP214_DynamicTableLayout >> Helper >> fireSendInitStateEvt >> Start');
        let sendInitStateEvt = component.getEvent("sendInitStateEvt");
        sendInitStateEvt.setParams({
            "componentName" : "TA_LCP214_DynamicTableLayout",
            "initState" : isInitialized
        });
        sendInitStateEvt.fire();
        console.log('TA_LCP214_DynamicTableLayout >> Helper >> fireSendInitStateEvt >> End');
    },

    manageButtons : function(component, event, helper) {
        console.log('TA_LCP214_DynamicTableLayout >> Helper >> manageButtons >> Start');
        let buttonName = event.currentTarget.name;
        let buttonType = buttonName.substring(0, buttonName.indexOf('|'));
        let objectName = buttonName.substring(buttonName.indexOf('|') + 1);
        if(buttonType == 'save') {
            let objWrapper = component.get('v.objWrapper');
            objWrapper.forEach(function(object) {
                if(object.objectName == objectName) {
                    let fields = object.fieldsAndSection[0].fields;
                    fields.forEach(function(field) {
                        field.editEnabled = false;
                    });
                }
            });
            component.set('v.objWrapper', objWrapper);
            helper.fireEvts(component, component.get('v.massUpdateFields'), component.get('v.errors'), objectName);
        } else if(buttonType == 'single-edit') {
            let objWrapper = component.get('v.objWrapper');
            objWrapper.forEach(function(object) {
                if(object.objectName == objectName) {
                    let fields = object.fieldsAndSection[0].fields;
                    fields.forEach(function(field) {
                        if(field.apiName == event.currentTarget.id) {
                            field.editEnabled = true;
                        }
                    });
                }
            });
            component.set('v.objWrapper', objWrapper);
        } else {
            let objWrapper = component.get('v.objWrapper');
            objWrapper.forEach(function(object) {
                if(object.objectName == objectName) {
                    let fields = object.fieldsAndSection[0].fields;
                    fields.forEach(function(field) {
                        field.editEnabled = buttonType == 'edit' && field.mode == 'edit' ? true : false;
                    });
                }
            });
            component.set('v.objWrapper', objWrapper);
        }

        component.set('v.isEditEnabled', !component.get('v.isEditEnabled'));
        console.log('TA_LCP214_DynamicTableLayout >> Helper >> manageButtons >> End');
    },

    redirectToObject : function(component, event) {
        console.log('TA_LCP214_DynamicTableLayout >> Helper >> redirectToObject >> Start');
        let recordId = event.currentTarget.id;
        let urlPath = event.currentTarget.name;
        let redirectUrl = window.location.protocol + '//' + window.location.hostname + urlPath + recordId;
        window.location.href = redirectUrl;
        console.log('TA_LCP214_DynamicTableLayout >> Helper >> redirectToObject >> End');
    },

    manageCheckbox : function(component, event, helper) {
        console.log('TA_LCP214_DynamicTableLayout >> Helper >> manageCheckbox >> Start');
        let objectName = event.currentTarget.name;
        let fieldApiName = event.currentTarget.id;

        let objWrapper = component.get('v.objWrapper');
        let updatedFields = [];

        objWrapper.forEach(function(object) {
            if(object.objectName == objectName) {
                let fields = object.fieldsAndSection[0].fields;
                fields.forEach(function(field) {
                    if(field.apiName == fieldApiName) {
                        field.value = field.value == 'true' ? 'false' : 'true';
                        field.edited = true;
                    }
                    if(field.edited) updatedFields.push(field);
                });
            }
        });

        component.set('v.objWrapper', objWrapper);
        helper.fireEvts(component, updatedFields, [], objectName);
        console.log('TA_LCP214_DynamicTableLayout >> Helper >> manageCheckbox >> End');
    },

    fireEvts : function(component, fields, errors, objectName) {
        console.log('TA_LCP214_DynamicTableLayout >> Helper >> fireEvts >> Start');
        let whereCondition = component.get('v.whereCondition');

        if(fields != []) {
            let updateFieldsEvt = $A.get("e.c:TA_LCE214_UpdateFields");
            updateFieldsEvt.setParams({
                "cmpName" : component.get('v.cmpName'),
                "objectName" : objectName,
                "whereCondition" : whereCondition,
                "fields" : fields
            });
            updateFieldsEvt.fire();
        }

        let validationEvt = $A.get("e.c:TA_LCE199_Validation");
        validationEvt.setParams({
            "cmpName" : component.get('v.cmpName'),
            "errors" : errors,
            "validate" : errors.length > 0 ? false : true,
            "updateFields" : true
        }); 
        validationEvt.fire();

        console.log('TA_LCP214_DynamicTableLayout >> Helper >> fireEvts >> End');
    },

    manageField : function(component, event, helper, fieldName) {
        console.log('TA_LCP214_DynamicTableLayout >> Helper >> manageField >> Start');
        let objectName = fieldName.substring(0, fieldName.indexOf('|'));
        let fieldApiName = fieldName.substring(fieldName.indexOf('|') + 1);
        let objWrapper = component.get('v.objWrapper');

        objWrapper.forEach(function(object) {
            if(object.objectName == objectName) {
                if(object.massEdit) {
                    let massUpdateFields = [];
                    let errors = [];
                    let fields = object.fieldsAndSection[0].fields;

                    fields.forEach(function(field) {
                        if(field.apiName == fieldApiName) {
                            field.edited = true;
                        }
                        if(field.edited) massUpdateFields.push(field);
                        if(field.required == true && (field.value == '' || field.value == null)) errors.push('Field ' + field.label + ' is mandatory');
                    });

                    component.set('v.massUpdateFields', massUpdateFields);
                    component.set('v.errors', errors);
                } else {
                    let updateFields = [];
                    let errors = [];
                    let fields = object.fieldsAndSection[0].fields;
        
                    fields.forEach(function(field) {
                        if(field.apiName == fieldApiName) {
                            field.editEnabled = !field.defaultEditEnabled ? false : true;
                            field.edited = true;
                        }
                        if(field.edited) updateFields.push(field);
                        if(field.required == true && (field.value == '' || field.value == null)) errors.push('Field ' + field.label + ' is mandatory');
                    });

                    helper.fireEvts(component, updateFields, errors, objectName);
                }
            }
        });

        component.set('v.objWrapper', objWrapper);
        console.log('TA_LCP214_DynamicTableLayout >> Helper >> manageField >> End');
    },
    redirectToObject : function(component, event) {
        console.log('TA_LCP214_DynamicTableLayout >> Helper >> redirectToObject >> Start');
        let recordId = event.currentTarget.id;
        let urlPath = event.currentTarget.name;
        let redirectUrl = window.location.protocol + '//' + window.location.hostname + urlPath;
        window.location.href = redirectUrl;
        console.log('TA_LCP214_DynamicTableLayout >> Helper >> redirectToObject >> End');
    },
})