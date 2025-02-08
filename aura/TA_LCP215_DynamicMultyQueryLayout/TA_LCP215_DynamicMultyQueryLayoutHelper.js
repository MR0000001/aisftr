({
    initialize : function(component) {
        console.log('TA_LCP215_DynamicMultyQueryLayout >> Helper >> initialize >> Start');
        component.set('v.general', JSON.parse(component.get('v.fieldSet')).general);
        component.set('v.custom', JSON.parse(component.get('v.fieldSet')).custom);
        let _helper = this;

        let getObjWrapper = component.get('c.getObjWrapper');
        getObjWrapper.setParams({
            'workOrderId' : component.get('v.workOrderId'),
            'customFieldSet' : JSON.stringify(component.get('v.custom')),
            'AssetId' : component.get('v.assetId')
        });

        getObjWrapper.setCallback(this, function(response) {
            console.log('TA_LCP215_DynamicMultyQueryLayout >> Helper >> initializeCallback >> Start');
            if(response.getState() == "SUCCESS") {
                let objWrapper = response.getReturnValue();
                if(objWrapper != null) {
                    component.set('v.objWrapper', objWrapper);

                    if(component.get('v.general').titleType == 'default') {
                        component.set('v.title', $A.getReference("$Label.c." + component.get('v.general').defaultTitle));
                    } else {
                        component.get('v.objWrapper').fields.forEach(function(field) {
                            if(component.get('v.general').titleType == field.apiName) {
                                component.set('v.title', field.value);
                            }
                        });
                    }
    
                    component.set('v.description', $A.getReference("$Label.c." + component.get('v.general').description));
                    component.set('v.customerCardBg', $A.get('$Resource.TA_Images') + '/imgs/' + component.get('v.general.bgImage'));
                    component.set('v.checkIcon', $A.get('$Resource.TA_Icons') +  '/xc-icons/check-white-bgp.svg');
    
                    let fields = component.get('v.objWrapper.fields');
                    let errors = [];
    
                    fields.forEach(function(field) {
                        let errorMessage = $A.get("$Label.c.TA_Field") + ' ' + field.label + ' ' + $A.get("$Label.c.TA_IsMandatory");
                        console.log('@@>> errorMessage >>> ' + errorMessage);
                        if(field.editableField == true && field.required == true && (field.value == '' || field.value == null)) errors.push(errorMessage);
                    });
    
                    if(errors.length > 0) _helper.fireEvts(component, [], errors);
                    component.set('v.isInitialized', true);
                } else {
                    if(component.get('v.general').hideIfDataNotAvailable == 'true') {
                        component.set('v.isInitialized', false);
                    } else {
                        component.set("v.showToastMessage", true);
                        component.set("v.isError", true);
                        component.set("v.toastMessage", 'TA_LCP215_DynamicMultyQueryLayout - Response return null: check the data related to object');
                        component.set('v.isInitialized', true);
                    }
                }

                this.fireSendInitStateEvt(component, true);
                
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
            console.log('TA_LCP215_DynamicMultyQueryLayout >> Helper >> initializeCallback >> End');
        });

        $A.enqueueAction(getObjWrapper);
        console.log('TA_LCP215_DynamicMultyQueryLayout >> Helper >> initialize >> End');
    },

    fireToggleSpinnerEvent : function(component, toggleSpinner) {
        console.log('TA_LCP215_DynamicMultyQueryLayout >> Helper >> fireToggleSpinnerEvent >> Start');
        let toggleSpinnerEvent = component.getEvent("toggleSpinnerEvent");
        toggleSpinnerEvent.setParams({
            "sourceComponent" : "TA_LCP215_DynamicMultyQueryLayout",
            "toggleSpinner" : toggleSpinner
        });
        toggleSpinnerEvent.fire();
        console.log('TA_LCP215_DynamicMultyQueryLayout >> Helper >> fireToggleSpinnerEvent >> End');
    },

    fireSendInitStateEvt : function(component, isInitialized) {
        console.log('TA_LCP215_DynamicMultyQueryLayout >> Helper >> fireSendInitStateEvt >> Start');
        let sendInitStateEvt = component.getEvent("sendInitStateEvt");
        sendInitStateEvt.setParams({
            "componentName" : "TA_LCP215_DynamicMultyQueryLayout",
            "initState" : isInitialized
        });
        sendInitStateEvt.fire();
        console.log('TA_LCP215_DynamicMultyQueryLayout >> Helper >> fireSendInitStateEvt >> End');
    },

    manageCheckbox : function(component, event) {
        console.log('TA_LCP215_DynamicMultyQueryLayout >> Helper >> manageCheckbox >> Start');
        let fieldApiName = event.currentTarget.id;
        let fields = component.get('v.objWrapper.fields');

        fields.forEach(function(field) {
            if(field.apiName == fieldApiName) {
                field.value = field.value == 'true' ? 'false' : 'true';
            }
        });

        component.set('v.objWrapper.fields', fields);
        console.log('TA_LCP215_DynamicMultyQueryLayout >> Helper >> manageCheckbox >> End');
    },
   
    manageEditing : function(component, event) {
        console.log('TA_LCP215_DynamicMultyQueryLayout >> Helper >> manageEditing >> Start' );
        if(event.currentTarget.name == 'save') {
            this.fireEvts(component, component.get('v.updatingFields'), component.get('v.errors'));
        }

        let changeEditingField = component.get('v.objWrapper.fields');
        for(let i = 0; changeEditingField.length > i; i++) {
            let changeEditingFieldIndex = changeEditingField[i];
            if(changeEditingFieldIndex.editableField == true) {
                if(event.currentTarget.name == 'edit') {
                    changeEditingFieldIndex.mode = 'edit';
                } else {
                    changeEditingFieldIndex.mode = 'view';
                }

                if(event.currentTarget.name == 'cancel') {
                    changeEditingFieldIndex.value = changeEditingFieldIndex.originalValue;
                }
            }
        }

        component.set('v.objWrapper.fields',changeEditingField);
        component.set('v.isEditEnabled', !component.get('v.isEditEnabled'));
        console.log('TA_LCP215_DynamicMultyQueryLayout >> Helper >> manageEditing >> End');
    },

    ManageEditingPencil : function(component, event) {
        console.log('TA_LCP215_DynamicMultyQueryLayout >> Helper >> ManageEditingPencil >> Start');
        let changeEditingField = component.get('v.objWrapper.fields');
        for(let i = 0; changeEditingField.length > i; i++) {
            let changeEditingFieldIndex = changeEditingField[i];
            if(changeEditingFieldIndex.editableField == true) {
                if(changeEditingFieldIndex.apiName == event.currentTarget.name) {
                    changeEditingFieldIndex.mode = 'edit';
                } 
            }
        }

        component.set('v.objWrapper.fields',changeEditingField);
        component.set('v.isEditEnabled', !component.get('v.isEditEnabled'));
        console.log('TA_LCP215_DynamicMultyQueryLayout >> Helper >> ManageEditingPencil >> End');
    },

    manageUpdate : function(component, currentApiName) {
        console.log('TA_LCP215_DynamicMultyQueryLayout >> Helper >> manageUpdate >> Start');
        let fields = component.get('v.objWrapper.fields');
        if(component.get('v.general.typeOfEditable') == 'SaveButton') {
            let massUpdateFields = [];
            let errors = [];

            fields.forEach(function(field) {
                if(field.apiName == currentApiName) massUpdateFields.push(field);
                if(field.edited) massUpdateFields.push(field);
                let errorMessage = $A.get("$Label.c.TA_Field") + ' ' + field.label + ' ' + $A.get("$Label.c.TA_IsMandatory");
                console.log('@@>> errorMessage >>> ' + errorMessage);
                if(field.required == true && (field.value == '' || field.value == null)) errors.push(errorMessage);
            });
            component.set('v.updatingFields', massUpdateFields);
            component.set('v.errors', errors);
        } else {
            let updateFields = [];
            let errors = [];
            fields.forEach(function(field) {
                if(field.apiName == currentApiName) {
                    component.set('v.isEditEnabled', !component.get('v.isEditEnabled'));
                    field.mode = 'view';
                    component.set('v.objectName', field.objectName);
                    updateFields.push(field);
                }

                if(field.edited) updateFields.push(field);
                let errorMessage = $A.get("$Label.c.TA_Field") + ' ' + field.label + ' ' + $A.get("$Label.c.TA_IsMandatory");
                console.log('@@>> errorMessage >>> ' + errorMessage);
                if(field.required == true && (field.value == '' || field.value == null)) errors.push(errorMessage);
            });
            this.fireEvts(component, updateFields, errors);
        }
        component.set('v.objWrapper.fields', fields);
        console.log('TA_LCP215_DynamicMultyQueryLayout >> Helper >> manageUpdate >> End' );
    },

    fireUpdateEvt : function(component, fields) {
        console.log('TA_LCP215_DynamicMultyQueryLayout >> Helper >> fireUpdateEvt >> Start');
        let updateFieldsEvent = $A.get("e.c:TA_LCE214_UpdateFields");
        updateFieldsEvent.setParams({
            "cmpName" : component.get('v.cmpName'),
            "objectName" : component.get('v.objectName'),
            "fields" : fields
        });
        updateFieldsEvent.fire();
        console.log('TA_LCP215_DynamicMultyQueryLayout >> Helper >> fireUpdateEvt >> End');
    },

    fireEvts : function(component, fields, errors) {
        console.log('TA_LCP215_DynamicMultyQueryLayout >> Helper >> fireEvts >> Start');
        if(fields != []) {
            let updateFieldsEvt = $A.get("e.c:TA_LCE214_UpdateFields");
            updateFieldsEvt.setParams({
                "cmpName" : component.get('v.cmpName'),
                "objectName" : component.get('v.objectName'),
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

        console.log('TA_LCP215_DynamicMultyQueryLayout >> Helper >> fireEvts >> End');
    }
})