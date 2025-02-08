({
    initialize : function(component) {
        console.log('TA_LCP202_DynamicLayout >> Helper >> initialize >> Start');
        component.set('v.general', JSON.parse(component.get('v.fieldSet')).general);
        component.set('v.custom', JSON.parse(component.get('v.fieldSet')).custom);
        let _helper = this;

        let getObjWrapper = component.get('c.getObjWrapper');
        getObjWrapper.setParams({
            'workOrderId' : component.get('v.workOrderId'),
            'customFieldSet' : JSON.stringify(component.get('v.custom'))
        });
        
		
        getObjWrapper.setCallback(this, function(response) {
            console.log('TA_LCP202_DynamicLayout >> Helper >> initializeCallback >> Start');
            if(response.getState() == "SUCCESS") {
                component.set('v.objWrapper', response.getReturnValue());

                if(component.get('v.objWrapper').whereCondition) {
                    component.set('v.whereCondition', component.get('v.objWrapper').whereCondition);
                }
				
                let allFieldsBlank = true;
                component.get('v.objWrapper').fields.forEach(function(field) {
                    if(field.type == 'BOOLEAN') field.value = field.value == 'true' ? true : field.value == 'false' ? false : field.value;  
                    if(field.addLogic) _helper.addLogicForSingleField(component, field);        
                    if((field.value != null && field.value != '') || component.get('v.objWrapper').isModeEdit) {
                        allFieldsBlank = false;                        
                        return;
                    }
                });

                if(allFieldsBlank || component.get('v.objWrapper').isVisible == false) {
                    component.set('v.isInitialized', false);
                    component.set('v.title', $A.getReference("$Label.c." + component.get('v.general').defaultTitle));
                    _helper.fireSendInitStateEvt(component, true);
                    return;
                }

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
                    if(field.mode == 'edit' && field.required == true && (field.value == '' || field.value == null)) errors.push(errorMessage);
                });
                if(errors.length > 0) _helper.fireEvts(component, [], errors);
				
                component.set('v.isInitialized', true);
                _helper.fireSendInitStateEvt(component, true);

            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
            console.log('TA_LCP202_DynamicLayout >> Helper >> initializeCallback >> End');
        });

        $A.enqueueAction(getObjWrapper);
        console.log('TA_LCP202_DynamicLayout >> Helper >> initialize >> End');
    },

    manageCheckbox : function(component, event) {
        console.log('TA_LCP202_DynamicLayout >> Helper >> manageCheckbox >> Start');
        let fieldApiName = event.currentTarget.id;
        let fields = component.get('v.objWrapper.fields');
        let updatedFields = [];

        fields.forEach(function(field) {
            if(field.apiName == fieldApiName) {
                field.value = field.value == true ? false : true;
                field.edited = true;
            }
            if(field.edited) updatedFields.push(field);
        });

        component.set('v.objWrapper.fields', fields);
        this.fireEvts(component, updatedFields, []);
        console.log('TA_LCP202_DynamicLayout >> Helper >> manageCheckbox >> End');
    },

    manageButtons : function(component, event) {
        console.log('TA_LCP202_DynamicLayout >> Helper >> manageButtons >> Start');
        let buttonName = event.currentTarget.name;
        if(buttonName == 'save') {
            let fields = component.get('v.objWrapper.fields');
            fields.forEach(function(field) {
                field.editEnabled = false;
            });
            component.set('v.objWrapper.fields', fields);
            this.fireEvts(component, component.get('v.massUpdateFields'), component.get('v.errors'));
        } else if(buttonName == 'single-edit') {
            let fields = component.get('v.objWrapper.fields');
            fields.forEach(function(field) {
                if(field.apiName == event.currentTarget.id) {
                    field.editEnabled = true;
                }
            });
            component.set('v.objWrapper.fields', fields);
        } else {
            let fields = component.get('v.objWrapper.fields');
            fields.forEach(function(field) {
                field.editEnabled = buttonName == 'edit' && field.mode == 'edit' ? true : false;
            });
            component.set('v.objWrapper.fields', fields);
        }

        component.set('v.isEditEnabled', !component.get('v.isEditEnabled'));
        console.log('TA_LCP202_DynamicLayout >> Helper >> manageButtons >> End');
    },

    manageField : function(component, fieldApiName, fieldValue) {
        console.log('TA_LCP202_DynamicLayout >> Helper >> manageField >> Start');
        let fields = component.get('v.objWrapper.fields');
        let _helper = this;
        
        if(component.get('v.objWrapper.massEdit')) {
            let massUpdateFields = [];
            let errors = [];

            fields.forEach(function(field) {
                if(field.apiName == fieldApiName) {
                    field.edited = true;
                }
                if(field.edited) massUpdateFields.push(field);
                let errorMessage = $A.get("$Label.c.TA_Field") + ' ' + field.label + ' ' + $A.get("$Label.c.TA_IsMandatory");
                if(field.required == true && (field.value == '' || field.value == null)) errors.push(errorMessage);
            });
            component.set('v.massUpdateFields', massUpdateFields);
            component.set('v.errors', errors);
        } else {
            let updateFields = [];
            let errors = [];

            fields.forEach(function(field) {
                if(field.apiName == fieldApiName) {
                    field.editEnabled = !field.defaultEditEnabled ? false : true;
                    field.edited = true;
                }
                if(field.edited) updateFields.push(field);
                let errorMessage = $A.get("$Label.c.TA_Field") + ' ' + field.label + ' ' + $A.get("$Label.c.TA_IsMandatory");
                if(field.required == true && (field.value == '' || field.value == null)) errors.push(errorMessage);
                
                if(field.addLogic) _helper.addLogicForSingleField(component,field);
                
            });
            this.fireEvts(component, updateFields, errors);
        }
        component.set('v.objWrapper.fields', fields);
        console.log('TA_LCP202_DynamicLayout >> Helper >> manageField >> End');
    },

    redirectToObject : function(component, event) {
        console.log('TA_LCP202_DynamicLayout >> Helper >> redirectToObject >> Start');
        let recordId = event.currentTarget.id;
        let urlPath = event.currentTarget.name;
        let redirectUrl = window.location.protocol + '//' + window.location.hostname + urlPath;
        window.location.href = redirectUrl;
        console.log('TA_LCP202_DynamicLayout >> Helper >> redirectToObject >> End');
    },

    fireEvts : function(component, fields, errors) {
        console.log('TA_LCP202_DynamicLayout >> Helper >> fireEvts >> Start');

        if(fields != []) {
            let updateFieldsEvt = $A.get("e.c:TA_LCE214_UpdateFields");
            updateFieldsEvt.setParams({
                "cmpName" : component.get('v.cmpName') + '-' + component.getGlobalId(),
                "objectName" : component.get('v.objWrapper.objectName'),
                "objectLookup" : component.get('v.objWrapper.objectLookup'), // [20220120AL]
                "fields" : fields
            });
            updateFieldsEvt.fire();
        }

        let validationEvt = $A.get("e.c:TA_LCE199_Validation");
        validationEvt.setParams({
            "cmpName" : component.get('v.cmpName') + '-' + component.getGlobalId(),
            "errors" : errors,
            "validate" : errors.length > 0 ? false : true,
            "updateFields" : true
        }); 
        validationEvt.fire(); 

        console.log('TA_LCP202_DynamicLayout >> Helper >> fireEvts >> End');
    },

    fireSendInitStateEvt : function(component, isInitialized) {
        console.log('TA_LCP202_DynamicLayout >> Helper >> fireSendInitStateEvt >> Start');
        let sendInitStateEvt = component.getEvent("sendInitStateEvt");
        sendInitStateEvt.setParams({
            "componentName" : "TA_LCP202_DynamicLayout",
            "initState" : isInitialized
        });
        sendInitStateEvt.fire();        
        console.log('TA_LCP202_DynamicLayout >> Helper >> fireSendInitStateEvt >> End');
    },

    addLogicForSingleField : function(component, field) {
        console.log('TA_LCP202_DynamicLayout >> Helper >> addLogicForSingleField >> Start');
        let apiName = field.apiName;
        let fieldValue = field.value;
        let fields = component.get('v.objWrapper.fields');

        switch(apiName) {
            //START [20220517AL] - NR2551
            case 'XC_PermittingForm__c': 
                let permittingFormAddLogic = $A.get("e.c:TA_LCE248_GenericEvent");               
                if(field.value == 'Needed') {                    
                    permittingFormAddLogic.setParams({
                        "action" : "show",
                        "params" : {'field' : 'XC_PermittingForm__c'}
                    });                   
                    permittingFormAddLogic.fire();              
                }
                else {                    
                    permittingFormAddLogic.setParams({
                        "action" : "hide",
                        "params" : {'field' : 'XC_PermittingForm__c'}
                    });               
                    permittingFormAddLogic.fire();
                }
                break;
            //END [20220517AL] - NR2551
            case 'XC_ExtraCost__c': 
                let addLogicEvent = $A.get("e.c:TA_LCE248_GenericEvent");               
                if(field.value){                    
                    addLogicEvent.setParams({
                        "action" : "show",
                        "params" : {}
                    });                    
                    addLogicEvent.fire();              
                }
                else {                    
                    addLogicEvent.setParams({
                        "action" : "hide",
                        "params" : {}
                    });                    
                    addLogicEvent.fire();
                }
                break;    
            case 'XC_ExtraKm__c':
                fields.forEach(field => {
                    if(field.apiName == 'XC_ExtraKmRefund__c') {
                        if(fieldValue) {
                            field.mode = 'edit';
                            field.editEnabled = false;
                        } else {
                            field.mode = 'none';
                            field.value = '';
                        }
                    }
                });
                component.set('v.objWrapper.fields', fields);
                break;
            case 'XC_ExtraWork__c':
                fields.forEach(field => {
                    if(field.apiName == 'XC_ExtraWorkRefund__c') {
                        if(fieldValue) {
                            field.mode = 'edit';
                            field.editEnabled = false;
                        } else {
                            field.mode = 'none';
                            field.value = '';
                        }
                    }
                });
                component.set('v.objWrapper.fields', fields);
                break;
            //START - [20220428AL] - NR2331 (Req. D)
            case 'XC_FaultType__c':
                if(fieldValue) component.set('v.faultType', fieldValue);
            //END - [20220428AL] - NR2331 (Req. D)
        }        
        console.log('TA_LCP202_DynamicLayout >> Helper >> addLogicForSingleField >> End');
    }
})