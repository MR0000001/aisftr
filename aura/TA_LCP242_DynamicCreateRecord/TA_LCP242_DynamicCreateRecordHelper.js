({
    initialize : function(component, event, helper) {
        console.log('TA_LCP242_DynamicCreateRecord >> Helper >> initialize >> Start');

        component.set('v.general', JSON.parse(component.get('v.fieldSet')).general);
        component.set('v.custom', JSON.parse(component.get('v.fieldSet')).custom);
        component.set('v.isMultiRecords', component.get('v.custom').isMultiRecords);
        component.set('v.isRequired', component.get('v.custom').isRequired);    
        component.set('v.isRequiredErrorLabel', $A.getReference("$Label.c." +component.get('v.custom').isRequiredErrorLabel));       
        component.set('v.title', $A.getReference("$Label.c." + component.get('v.general').defaultTitle));
        component.set('v.customerCardBg', $A.get('$Resource.TA_Images') + '/imgs/' + component.get('v.general.bgImage'));

        this.isComponentVisible(component);
        console.log('TA_LCP242_DynamicCreateRecord >> Helper >> initialize >> End');
    },

    isComponentVisible : function(component) {
        console.log('TA_LCP242_DynamicCreateRecord >> Helper >> isComponentVisible >> Start');

        let _helper = this;
        let isComponentVisible = component.get("c.isComponentVisible");
        isComponentVisible.setParam("workOrderId", component.get('v.workOrderId'));
        isComponentVisible.setParam("objectName", component.get('v.custom.objectName'));

        isComponentVisible.setCallback(this, function(response) {
            console.log('TA_LCP242_DynamicCreateRecord >> Helper >> isComponentVisibleCallback >> Start');
            if(response.getState() == "SUCCESS") {
                component.set('v.isVisible', response.getReturnValue());

                if(component.get('v.isVisible')) {
                    _helper.getCurrentRecords(component);
                } else {
                    _helper.fireSendInitStateEvt(component, true);
                    component.set('v.isInitialized', true);
                }
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
            console.log('TA_LCP242_DynamicCreateRecord >> Helper >> isComponentVisibleCallback >> End');
        });
        $A.enqueueAction(isComponentVisible);

        console.log('TA_LCP242_DynamicCreateRecord >> Helper >> isComponentVisible >> End');
    },

    getPredefinedValues : function(component) {
        console.log('TA_LCP242_DynamicCreateRecord >> Helper >> getPredefinedValues >> Start');

        let _helper = this;
        let getPredefinedValues = component.get("c.getPredefinedValues");
        getPredefinedValues.setParam("workOrderId", component.get('v.workOrderId'));
        getPredefinedValues.setParam("serializedPredefinedValuesToQuery", JSON.stringify(component.get('v.custom').predefinedValues));

        getPredefinedValues.setCallback(this, function(response) {
            console.log('TA_LCP242_DynamicCreateRecord >> Helper >> getPredefinedValuesCallback >> Start');
            if(response.getState() == "SUCCESS") {
                component.set('v.predefinedValues', response.getReturnValue());
                _helper.getRecordTypesByObjectName(component);

            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
            console.log('TA_LCP242_DynamicCreateRecord >> Helper >> getPredefinedValuesCallback >> End');
        });
        $A.enqueueAction(getPredefinedValues);

        console.log('TA_LCP242_DynamicCreateRecord >> Helper >> getPredefinedValues >> End');
    },

    getRecordTypesByObjectName : function(component) {
        console.log('TA_LCP242_DynamicCreateRecord >> Helper >> getRecordTypesByObjectName >> Start');

        let _helper = this;
        let getRecordTypesByObjectName = component.get("c.getRecordTypesByObjectName");
        getRecordTypesByObjectName.setParam("objectName", component.get('v.custom').objectName);

        getRecordTypesByObjectName.setCallback(this, function(response) {
            console.log('TA_LCP242_DynamicCreateRecord >> Helper >> getRecordTypesByObjectNameCallback >> Start');
            if(response.getState() == "SUCCESS") {
                component.set('v.recordTypes', JSON.parse(response.getReturnValue()));
                if(component.get('v.recordTypes').length == 0) component.set('v.recordTypesEmpty', true);
                component.set('v.isInitialized', true);

            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
            _helper.fireSendInitStateEvt(component, true);
            console.log('TA_LCP242_DynamicCreateRecord >> Helper >> getRecordTypesByObjectNameCallback >> End');
        });
        $A.enqueueAction(getRecordTypesByObjectName);

        console.log('TA_LCP242_DynamicCreateRecord >> Helper >> getRecordTypesByObjectName >> End');
    },

    deleteRecord : function(component, recordId) {
        console.log('TA_LCP242_DynamicCreateRecord >> Helper >> deleteRecord >> Start');

        let _helper = this;
        let deleteRecord = component.get("c.deleteRecord");
        deleteRecord.setParam("objectName", component.get('v.custom').objectName);
        deleteRecord.setParam("recordId", recordId) ;

        deleteRecord.setCallback(this, function(response) {
            console.log('TA_LCP242_DynamicCreateRecord >> Helper >> deleteRecordCallback >> Start');
            if(response.getState() == "SUCCESS") {
                if(response.getReturnValue()) {
                    let records = component.get('v.records');
                    for(let i = 0; i < records.length; i++) {
                        if(records[i].id == recordId) records.splice(i, 1);
                    }
                    component.set('v.records', records);
                    if(!component.get('v.isMultiRecords')) component.set('v.recordSubmit', null);
                    _helper.handleValidationRules(component);
                } else {
                    component.set("v.showToastMessage", true);
                    component.set("v.isError", true);
                    component.set("v.toastMessage", 'Record not found');
                }
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
            _helper.fireToggleSpinnerEvent(component, false);
            console.log('TA_LCP242_DynamicCreateRecord >> Helper >> deleteRecord >> End');
        });
        _helper.fireToggleSpinnerEvent(component, true);
        $A.enqueueAction(deleteRecord);

        console.log('TA_LCP242_DynamicCreateRecord >> Helper >> getRecordTypesByObjectName >> End');
    },

    getCurrentRecords : function(component) {
        console.log('TA_LCP242_DynamicCreateRecord >> Helper >> getCurrentRecords >> Start');

        let _helper = this;
        let getCurrentRecords = component.get("c.getCurrentRecords");
        getCurrentRecords.setParam("workOrderId", component.get('v.workOrderId'));
        getCurrentRecords.setParam("objectName", component.get('v.custom.objectName'));
        getCurrentRecords.setParam("isMultiRecords", component.get('v.isMultiRecords'));
        getCurrentRecords.setParam("fieldToDisplay", component.get('v.custom').fieldToDisplay);
        getCurrentRecords.setParam("fieldsToCheck", component.get('v.custom').fieldsToCheck);

        getCurrentRecords.setCallback(this, function(response) {
            console.log('TA_LCP242_DynamicCreateRecord >> Helper >> getCurrentRecordsCallback >> Start');
            if(response.getState() == "SUCCESS") {
                component.set('v.records', response.getReturnValue());
                // START FIX [ADC23-06-2021] ENXCRM-159 
                if(component.get('v.isRequired')){                   
                    _helper.fireEvts(component, response.getReturnValue().length > 0 ? [] : [component.get('v.isRequiredErrorLabel')]);  
                }
                // END FIX [ADC23-06-2021] ENXCRM-159 
                if(!component.get('v.isMultiRecords') && response.getReturnValue().length > 0) component.set('v.recordSubmit', component.get('v.records')[0]);
                if(component.get('v.custom').predefinedValues != null) {
                    _helper.getPredefinedValues(component);
                } else _helper.getRecordTypesByObjectName(component);
                _helper.handleValidationRules(component);
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
            console.log('TA_LCP242_DynamicCreateRecord >> Helper >> getCurrentRecordsCallback >> End');
        });  
        $A.enqueueAction(getCurrentRecords);

        console.log('TA_LCP242_DynamicCreateRecord >> Helper >> getCurrentRecords >> End');
    },

    handleValidationRules : function(component) {
        console.log('TA_LCP242_DynamicCreateRecord >> Helper >> handleValidationRules >> Start');
        let _helper = this;
        var validationRules = component.get('v.custom').validationRules;
        if(component.get('v.isMultiRecords') && validationRules != null){
            for(let i in validationRules) {
                if(validationRules[i].isActive && validationRules[i].ruleName == "requiredDocuments"){
                    _helper.validationRequiredDocuments(component, validationRules[i]);
                }
            }            
        }
        console.log('TA_LCP242_DynamicCreateRecord >> Helper >> handleValidationRules >> End');
    },

    validationRequiredDocuments : function(component, validationRule) {
        console.log('TA_LCP242_DynamicCreateRecord >> Helper >> validationRequiredDocuments >> Start');
        //Numbers of documents should be at least 2, one must be a fiscal code. test
        const comparators = {
			'eq': function(a, b) { return a === b }
		};
        let _helper = this;
        var documents = component.get('v.records');
        var isCF = false;
        var isError = false;
        if (documents.length < 2){
            isError = true;
        } else {
            for(let i in documents) {
                if (comparators[validationRule.ruleCondition.compare]( documents[i].fieldsToCheck[validationRule.ruleCondition.field], validationRule.ruleCondition.target )){
                    isCF = true;
                    break;
                }
            } 
            if (!isCF) isError = true;
        }
        _helper.fireEvts(component, isError ? [$A.get("$Label.c.TA_PersonalDocument_RequiredError")] : []);
        console.log('TA_LCP242_DynamicCreateRecord >> Helper >> validationRequiredDocuments >> End');
    },

    fireSendInitStateEvt : function(component, isInitialized) {
        console.log('TA_LCP242_DynamicCreateRecord >> Helper >> fireSendInitStateEvt >> Start');
        let sendInitStateEvt = component.getEvent("sendInitStateEvt");
        sendInitStateEvt.setParams({
            "componentName" : "TA_LCP242_DynamicCreateRecord",
            "initState" : isInitialized
        });
        sendInitStateEvt.fire();
        console.log('TA_LCP242_DynamicCreateRecord >> Helper >> fireSendInitStateEvt >> End');
    },

    fireToggleSpinnerEvent : function(component, toggleSpinner) {
        console.log('TA_LCP242_DynamicCreateRecord >> Helper >> fireToggleSpinnerEvent >> Start');
        let toggleSpinnerEvent = component.getEvent("toggleSpinnerEvent");
        toggleSpinnerEvent.setParams({
            "sourceComponent" : "TA_LCP242_DynamicCreateRecord",
            "toggleSpinner" : toggleSpinner
        });
        toggleSpinnerEvent.fire();
        console.log('TA_LCP242_DynamicCreateRecord >> Helper >> fireToggleSpinnerEvent >> End');
    },

    submitForm : function(component, event) {
        console.log('TA_LCP242_DynamicCreateRecord >> Helper >> submitForm >> Start');
        event.preventDefault();
        console.log('event.getParams --- ' + JSON.stringify(event.getParams()));
        let fields = event.getParams().fields;
        let predefinedValues = component.get('v.predefinedValues');

        fields.RecordTypeId = component.get('v.formRecordTypeId');  
        if(predefinedValues.length > 0) {
            predefinedValues.forEach(function(predValue) {
                fields[predValue.apiName] = predValue.value;
            });
        }

        //START FIX [ADC] 14/05/2021
        //component.find('recordForm').submit(fields);        
        if(fields.XC_Issue_Province__c){            
            if(fields.XC_Issue_Province__c.length > 2){                
                component.find('recordForm').submit(fields);
            }
            else {
                this.fireToggleSpinnerEvent(component, false);
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", $A.get("$Label.c.TA_Issue_Province"));
            }
        }
        else component.find('recordForm').submit(fields); 
        //else console.log('il campo XC_Issue_Province__c non esiste');
        //END FIX [ADC] 14/05/2021

        //this.fireToggleSpinnerEvent(component, false);
        console.log('TA_LCP242_DynamicCreateRecord >> Helper >> submitForm >> End');
    },

    error : function(component, event) {
        this.fireToggleSpinnerEvent(component, false);
        component.set("v.showToastMessage", true);
        component.set("v.isError", true);

        let errorMessage = '';
        if(event.getParams().error.body.output.errors) {
            event.getParams().error.body.output.errors.forEach(function(errMsg) {
                errorMessage += errMsg.message + ' ';
            })
        } else errorMessage = JSON.stringify(event.getParams().error);
        component.set("v.toastMessage", errorMessage);
    },

    responseLayout : function(component, event) {
        console.log('TA_LCP242_DynamicCreateRecord >> Helper >> responseLayout >> Start');
        let objData = event.getParam('objData');
        let sections = [];

        objData.layout.sections.forEach(function(section) {
            let sectionTmp = {'heading' : section.heading, 'fields' : []};
            section.layoutRows.forEach(function(layoutRow) {
                layoutRow.layoutItems.forEach(function(layoutItem) {
                    sectionTmp.fields.push({'required' : layoutItem.required, 
                                     'label' : layoutItem.label, 
                                     'apiName' : layoutItem.layoutComponents[0].apiName,
                                     'readonly' : !layoutItem.editableForNew
                                    });
                });
            });
            sections.push(sectionTmp);
        });

        let predefinedValues = component.get('v.predefinedValues');
        let readonlyFields = component.get('v.custom').readonlyFields;
        let hideFields = component.get('v.custom').hideFields;
        let requiredFields = component.get('v.custom').requiredFields;

        //if(predefinedValues.length > 0) {
        sections.forEach(function(section) {
            section.fields.forEach(function(field) {
                if(predefinedValues != null) {
                    predefinedValues.forEach(function(predValue) {
                        if(field.apiName == predValue.apiName) field.value = predValue.value;
                    });
                }

                if(readonlyFields != null) {
                    readonlyFields.forEach(function(readonlyField) {
                        if(field.apiName == readonlyField) field.readonly = true;
                    });
                }

                if(hideFields != null) {
                    hideFields.forEach(function(hideField) {
                        if(field.apiName == hideField) field.hide = true;
                    });
                }
                
                if(requiredFields != null) {
                    requiredFields.forEach(function(reqField) {
                        if(field.apiName == reqField) field.required = true;
                    })
                }
            });
        });
        //}

        component.set('v.sections', sections);
        console.log('TA_LCP242_DynamicCreateRecord >> Helper >> responseLayout >> End');
    },

    success : function(component, event) {
        console.log('TA_LCP242_DynamicCreateRecord >> Helper >> success >> Start');
        component.set('v.isInitialized', false);
        component.set('v.showFormModal', false);
        this.isComponentVisible(component);
        /*let records = component.get('v.records');
        for(let i = 0; i < records.length; i++) {
            if(records[0].id == event.getParams().response.id) records.splice(i, 1);
        }
        records.push({'id' : event.getParams().response.id, 'recordTypeName' : event.getParams().response.recordTypeInfo.name, 'recordTypeId' : event.getParams().response.recordTypeInfo.recordTypeId});
        component.set('v.records', records);
        component.set('v.showFormModal', false);
        this.fireToggleSpinnerEvent(component, false);*/
        console.log('TA_LCP242_DynamicCreateRecord >> Helper >> success >> End');
    },

    fireEvts : function(component, errors) {
        console.log('TA_LCP242_DynamicCreateRecord >> Helper >> fireEvts >> Start');

        let validationEvt = $A.get("e.c:TA_LCE199_Validation");
        validationEvt.setParams({
            "cmpName" : 'TA_LCP242_DynamicCreateRecord',
            "errors" : errors,
            "validate" : errors.length > 0 ? false : true
        }); 
        validationEvt.fire(); 

        console.log('TA_LCP242_DynamicCreateRecord >> Helper >> fireEvts >> End');
    },

    changeRecordTypeId : function(component) {
        console.log('TA_LCP242_DynamicCreateRecord >> Helper >> changeRecordTypeId >> Start');

        let recordTypes = component.get('v.recordTypes');
        let recordTypeId = component.get('v.formRecordTypeId');

        for(let i = 0; i < recordTypes.length; i++) {
            if(recordTypes[i].Id == recordTypeId) {
                component.set('v.rtNameSelected', recordTypes[i].Name);
                break;
            }
        }

        console.log('TA_LCP242_DynamicCreateRecord >> Helper >> changeRecordTypeId >> End');
    },
})