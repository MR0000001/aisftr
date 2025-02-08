({
    initialize : function(component, event, helper) {
        console.log('TA_LCP243_CreateRecordModal >> Helper >> initialize >> Start'); 
        let _helper = this;                               
        _helper.fireToggleSpinnerEvent(component, true);
        _helper.getPredefinedValues(component);
        console.log('TA_LCP243_CreateRecordModal >> Helper >> initialize >> End');
    },

    getPredefinedValues : function(component) {
        console.log('TA_LCP243_CreateRecordModal >> Helper >> getRecordTypesByObjectName >> Start');

        let _helper = this;
        
        let getPredefinedValues = component.get("c.getPredefinedValues");
        let predefinedValues = component.get('v.custom')[component.get("v.objectName")] ? component.get('v.custom')[component.get("v.objectName")].predefinedValues : null;
        let parentObjectName =  component.get('v.custom')[component.get("v.objectName")] ?  component.get('v.custom')[component.get("v.objectName")].parentObjectApiName : null;
        console.log("predefinedValues",JSON.stringify(predefinedValues));

        getPredefinedValues.setParam("parentId", component.get('v.parentId'));
        getPredefinedValues.setParam("serializedPredefinedValuesToQuery", JSON.stringify(predefinedValues));
        getPredefinedValues.setParam("parentObjectName", parentObjectName);

        getPredefinedValues.setCallback(this, function(response) {
            console.log('TA_LCP243_CreateRecordModal >> Helper >> getPredefinedValuesCallback >> Start');
            if(response.getState() == "SUCCESS") {
                component.set('v.predefinedValues', response.getReturnValue());
                _helper.getRecordTypesByObjectName(component);

            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
            console.log('TA_LCP243_CreateRecordModal >> Helper >> getPredefinedValuesCallback >> End');
        });
        $A.enqueueAction(getPredefinedValues);

        console.log('TA_LCP243_CreateRecordModal >> Helper >> getRecordTypesByObjectName >> End');
    },

    getRecordTypesByObjectName : function(component) {
        console.log('TA_LCP243_CreateRecordModal >> Helper >> getRecordTypesByObjectName >> Start');

        let _helper = this;
        let getRecordTypesByObjectName = component.get("c.getRecordTypesByObjectName");
        //let checkLegalEntity = component.get('v.custom')[component.get("v.objectName")] && component.get('v.custom')[component.get("v.objectName")].checkLegalEntityRT!=null ? component.get('v.custom')[component.get("v.objectName")].checkLegalEntityRT : null;

        getRecordTypesByObjectName.setParam("objectName", component.get('v.objectName'));
        getRecordTypesByObjectName.setParam("workOrderId", component.get('v.parentId'));
        getRecordTypesByObjectName.setParam("checkLegalEntityRT", component.get("v.checkLegalEntityRT"));

        getRecordTypesByObjectName.setCallback(this, function(response) {
            console.log('TA_LCP243_CreateRecordModal >> Helper >> getRecordTypesByObjectNameCallback >> Start');
            if(response.getState() == "SUCCESS") {
                component.set('v.recordTypes', JSON.parse(response.getReturnValue()));
                console.log('getReturnValue: ' + response.getReturnValue());

                if(!component.get('v.recordTypes').length > 0){
                    _helper.manageShowFormModal(component,event,_helper);
                }
                if(component.get("v.recordId")==null || component.get("v.recordId")==''){
                    component.set("v.formRecordTypeId",component.get('v.recordTypes')[0].recordTypeId);
                }
                console.log('formRecordTypeId: ' + component.get('v.formRecordTypeId'));
                console.log('init recordSubmit: ' + component.get("v.recordId"));
                component.set('v.isInitialized', true);

            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
            
            _helper.fireSendInitStateEvt(component, true);            
            console.log('TA_LCP243_CreateRecordModal >> Helper >> getRecordTypesByObjectNameCallback >> End');
        });
        $A.enqueueAction(getRecordTypesByObjectName);

        console.log('TA_LCP243_CreateRecordModal >> Helper >> getRecordTypesByObjectName >> End');
    },

    changeRecordTypeId : function(component) {
        console.log('TA_LCP243_CreateRecordModal >> Helper >> changeRecordTypeId >> Start');

        let recordTypes = component.get('v.recordTypes');
        let recordTypeId = component.get('v.formRecordTypeId');

        for(let i = 0; i < recordTypes.length; i++) {
            if(recordTypes[i].recordTypeId == recordTypeId) {
                component.set('v.rtNameSelected', recordTypes[i].name);
                break;
            }
        }
        console.log('rtNameSelected: ' + component.get('v.rtNameSelected'));
        console.log('formRecordTypeId: ' + component.get('v.formRecordTypeId'));

        console.log('TA_LCP243_CreateRecordModal >> Helper >> changeRecordTypeId >> End');
    },

    responseLayout : function(component, event) {
        console.log('TA_LCP243_CreateRecordModal >> Helper >> responseLayout >> Start');
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
        console.log('predefinedValues '+ JSON.stringify(predefinedValues));
        let readonlyFields = component.get('v.custom')[component.get("v.objectName")] ? component.get('v.custom')[component.get("v.objectName")].readonlyFields : null;
        let hideFields = component.get('v.custom')[component.get("v.objectName")] ? component.get('v.custom')[component.get("v.objectName")].hideFields : null;
        let mainFields = component.get('v.custom')[component.get("v.objectName")] ? component.get('v.custom')[component.get("v.objectName")].mainFields : null;
        let requiredFields = component.get('v.custom').requiredFields;
        
        sections.forEach(function(section) {
            section.fields.forEach(function(field) {
                if(predefinedValues != null) {
                    predefinedValues.forEach(function(predValue) {
                        // START FIX [ADC08/07/2021] ENXCRM-172 fix campo lookup woli su edit product consumed
                        //if(field.apiName == predValue.apiName) field.value = predValue.value;
                        if(field.apiName == predValue.apiName && !component.get("v.recordId")) field.value = predValue.value;
                        // END FIX [ADC08/07/2021] ENXCRM-172 fix campo lookup woli su edit product consumed
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

        if(mainFields && mainFields.length > 0) {
            let mainInfoSection = {'heading' : $A.get("$Label.c.TA_MainInformation"), 'fields' : []};
            let removeFieldsApiName = [];
            for(let i = 0; i < sections.length; i++) {

                let sectionFields = sections[i].fields;
                sectionFields.forEach(function(field) {
                    if(mainFields.includes(field.apiName)) {
                        mainInfoSection.fields.push(field);
                        removeFieldsApiName.push(field.apiName);
                    }
                });
                if(sections[i].fields.length == 0) sections.splice(i, 1);
            }

            if(removeFieldsApiName.length > 0) {
                sections.forEach(function(section) {
                    let tmpSectionFields = [];
                    section.fields.forEach(function(field) {
                        if(!removeFieldsApiName.includes(field.apiName)) tmpSectionFields.push(field);
                    });
                    section.fields = tmpSectionFields;
                });
            }
            sections.unshift(mainInfoSection);
        }

        component.set('v.sections', sections);
        this.fireToggleSpinnerEvent(component, false);
        console.log('sections: ' + JSON.stringify(component.get('v.sections')));
        console.log('recordSubmit: ' + component.get("v.recordId"));
        console.log('TA_LCP243_CreateRecordModal >> Helper >> responseLayout >> End');
    },  

    success : function(component, event) {
        console.log('TA_LCP243_CreateRecordModal >> Helper >> success >> Start');
        console.log(component.get('v.rtNameSelected'));
        console.log(component.get('v.recordTypes'));
        let isInsert = component.get('v.recordId') == null? true : false;
        console.log('isInsert: ' + isInsert);
        component.set('v.recordId', event.getParams().response.id);
        console.log('recordSubmit on success: ' + component.get('v.recordId'));
        component.set('v.showFormModal', false);
        component.set('v.showComponent', false);
        this.fireRefreshEvt(component,isInsert);
        //this.fireToggleSpinnerEvent(component, false);
        // lo spinner viene stoppato nell'init dal componente intervention quando cattura l'evento        
        console.log('TA_LCP243_CreateRecordModal >> Helper >> success >> End');
    },

    submitForm : function(component, event) {
        try{
            console.log('TA_LCP243_CreateRecordModal >> Helper >> submitForm >> Start');
            event.preventDefault();
            console.log('event.getParams --- ' + JSON.stringify(event.getParams()));
            let fields = event.getParams().fields;
            let predefinedValues = component.get('v.predefinedValues');

            fields.RecordTypeId = component.get('v.formRecordTypeId');
            if(predefinedValues && predefinedValues.length > 0) {
                predefinedValues.forEach(function(predValue) {
                    fields[predValue.apiName] = predValue.value;
                });
            }

            component.find('recordForm').submit(fields);
        }
        catch(e){
            console.log('ERROR: ',e);

        }
        console.log('TA_LCP243_CreateRecordModal >> Helper >> submitForm >> End');
    },

    fireToggleSpinnerEvent : function(component, toggleSpinner) {
        console.log('TA_LCP243_CreateRecordModal >> Helper >> fireToggleSpinnerEvent >> Start');
        let toggleSpinnerEvent = component.getEvent("toggleSpinnerEvent");
        toggleSpinnerEvent.setParams({
            "sourceComponent" : "TA_LCP243_CreateRecordModal",
            "toggleSpinner" : toggleSpinner
        });
        toggleSpinnerEvent.fire();
        console.log('TA_LCP243_CreateRecordModal >> Helper >> fireToggleSpinnerEvent >> End');
    },

    fireRefreshEvt : function(component, isInsert) {
        console.log('TA_LCP243_CreateRecordModal >> Helper >> fireRefreshEvt >> Start');
        let fireRefreshEvt = $A.get("e.c:TA_LCE224_Refresh");
        fireRefreshEvt.setParam('action','refresh intervention');
        let params={};
        params.isInsert = isInsert;  
        params.showComponentLabel = false;    
        fireRefreshEvt.setParam('params',params);
        fireRefreshEvt.fire();
        console.log('TA_LCP243_CreateRecordModal >> Helper >> fireRefreshEvt >> End');
    },
    manageShowFormModal : function(component, event, helper) {
        console.log('TA_LCP243_CreateRecordModal >> Helper >> manageShowFormModal >> Start');
        component.set('v.showFormModal', !component.get('v.showFormModal'));
        if(component.get('v.showFormModal')) document.getElementById('div-scroll').scrollIntoView();
        else if(!component.get('v.showFormModal') && component.get('v.buttonType') == 'edit') component.set('v.showComponent', !component.get('v.showComponent'));
        console.log('TA_LCP243_CreateRecordModal >> Helper >> manageShowFormModal >> End');
    }

})