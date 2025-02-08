({
	initialize : function(component, event, helper) {
        console.log('TA_LCP259_QualityCheckCreateRecord >> Helper >> initialize >> Start');
        
        component.set('v.general', JSON.parse(component.get('v.fieldSet')).general);
        component.set('v.custom', JSON.parse(component.get('v.fieldSet')).custom);     
        component.set('v.title', $A.getReference("$Label.c." + component.get('v.general').defaultTitle));
        component.set('v.customerCardBg', $A.get('$Resource.TA_Images') + '/imgs/' + component.get('v.general.bgImage'));

		this.loadRecordTypes(component);
        console.log('TA_LCP259_QualityCheckCreateRecord >> Helper >> initialize >> End');
    },

	loadRecordTypes : function(component) {
		console.log('TA_LCP259_QualityCheckCreateRecord >> Helper >> loadRecordTypes >> Start');
		let _helper = this;
		_helper.callToServer(
			component,
			"c.findRecordTypes",
			function(response) {
                //alert(JSON.parse(response));
                var jsonObject=JSON.parse(response);
                component.set('v.recordTypeList',jsonObject);  
                component.set('v.formRecordTypeId',jsonObject[0].recordTypeId);
                _helper.getPredefinedValues(component);
            }, 
            {objName: component.get('v.objType')}
        ); 
		console.log('TA_LCP259_QualityCheckCreateRecord >> Helper >> loadRecordTypes >> End');
	},

    getCurrentRecords : function(component) {
        console.log('TA_LCP259_QualityCheckCreateRecord >> Helper >> getCurrentRecords >> Start');
        let _helper = this;
		_helper.callToServer(
			component,
			"c.getCurrentRecords",
			function(response) {
                if(response) {
                    component.set('v.records', response);
                } 
                //_helper.fireToggleSpinnerEvent(component, false);
                _helper.fireSendInitStateEvt(component, true);
            }, 
            {workOrderId: component.get('v.workOrderId')}
        ); 
        console.log('TA_LCP259_QualityCheckCreateRecord >> Helper >> getCurrentRecords >> End');
    },

    getPredefinedValues : function(component) {
        console.log('TA_LCP259_QualityCheckCreateRecord >> Helper >> getPredefinedValues >> Start');


        let _helper = this;
		_helper.callToServer(
			component,
			"c.getPredefinedValues",
			function(response) {
                if(response) {
                    component.set('v.isInitialized',true);
                    component.set('v.predefinedValues', response);
                    _helper.getCurrentRecords(component);
                } 
            }, 
            {
                workOrderId: component.get('v.workOrderId'),
                serializedPredefinedValuesToQuery : JSON.stringify(component.get('v.custom').predefinedValues)
            }
        ); 

        console.log('TA_LCP242_DynamicCreateRecord >> Helper >> getPredefinedValues >> End');
    },

	fireToggleSpinnerEvent : function(component, toggleSpinner) {
        console.log('TA_LCP259_QualityCheckCreateRecord >> Helper >> fireToggleSpinnerEvent >> Start');
        let toggleSpinnerEvent = component.getEvent("toggleSpinnerEvent");
        toggleSpinnerEvent.setParams({
            "sourceComponent" : "TA_LCP259_QualityCheckCreateRecord",
            "toggleSpinner" : toggleSpinner
        });
        toggleSpinnerEvent.fire();
        console.log('TA_LCP259_QualityCheckCreateRecord >> Helper >> fireToggleSpinnerEvent >> End');
    },

    deleteRecord : function(component, recordId) {
        console.log('TA_LCP259_QualityCheckCreateRecord >> Helper >> deleteRecord >> Start');

        let _helper = this;
        _helper.callToServer(
			component,
			"c.deleteRecord",
			function(response) {
                if (response) {
                    console.log("Record deleted successfully");
                    let records = component.get("v.records").filter(function(item){
                        return item.id != recordId;
                    });
                    component.set("v.records", records);
                }
            }, 
            {
                objectName: component.get('v.objType'),
                recordId: recordId,
            }
        ); 

        console.log('TA_LCP259_QualityCheckCreateRecord >> Helper >> getRecordTypesByObjectName >> End');
    },

    openModalQualityCheckValidation : function(component, parameters, recordId) {
        console.log('TA_LCP259_QualityCheckCreateRecord >> Helper >> openModalQualityCheckValidation >> Start');
        component.set('v.hseqModalTitle', $A.getReference("$Label.c." + parameters.title));

        component.set("v.showQualityCheckValidationModal", true);
        let _helper = this;
        _helper.startFlow(component, recordId, parameters.flowName);
        
        console.log('TA_LCP259_QualityCheckCreateRecord >> Helper >> openModalQualityCheckValidation >> End');
    },

    startFlow : function(component,recordId,flowName){
        console.log('TA_LCP259_QualityCheckCreateRecord >> Helper >> startFlow >> Start');
        let recordSubmitId = recordId;
        console.log('recordSubmitId: '+recordSubmitId);
        var flow = component.find("flowData");
        // In that component, start your flow. Reference the flow's API Name.
        var inputVariables = [{ name : "recordId", type : "String", value: recordSubmitId}];
        flow.startFlow(flowName,inputVariables);
        console.log('TA_LCP259_QualityCheckCreateRecord >> Helper >> startFlow >> End');
    },

    closeModalQualityCheckValidation : function(component, event, helper) {
        console.log('TA_LCP259_QualityCheckCreateRecord >> Helper >> closeModalQualityCheckValidation >> Start');
        component.set('v.showQualityCheckValidationModal', false);
        console.log('TA_LCP259_QualityCheckCreateRecord >> Helper >> closeModalQualityCheckValidation >> End');
    },

    responseLayout : function(component, event) {
        console.log('TA_LCP259_QualityCheckCreateRecord >> Helper >> responseLayout >> Start');
        let objData = event.getParam('objData');
        let sections = [];

        objData.layout.sections.forEach(function(section) {
            let sectionTmp = {'heading' : section.heading, 'fields' : []};
            section.layoutRows.forEach(function(layoutRow) {
                layoutRow.layoutItems.forEach(function(layoutItem) {
                    sectionTmp.fields.push({'required' : layoutItem.required, 
                                     'label' : layoutItem.label, 
                                     'apiName' : layoutItem.layoutComponents[0].apiName,
                                     'readonly' : layoutItem.editableForNew.set,
                                     'relatedValue' : null,
                                     'isQuestion' : false
                                    });
                });
            });
            sections.push(sectionTmp);
        });

        let predefinedValues = component.get('v.predefinedValues');
        let readonlyFields = component.get('v.custom').readonlyFields;
        let hideFields = component.get('v.custom').hideFields;
        let requiredFields = component.get('v.custom').requiredFields;

        let fieldsToCheck = component.get("v.recordSubmit.fieldsToCheck");
        let readOnly = component.get("v.recordSubmit.readOnly");

        //if(predefinedValues.length > 0) {
        sections.forEach(function(section) {
            section.fields.forEach(function(field) {
                try {
                    
                    if(predefinedValues != null) {
                        predefinedValues.forEach(function(predValue) {
                            if(field.apiName == predValue.apiName) field.value = predValue.value;
                            if(field.apiName == predValue.dependentField) field.relatedValue = predValue.value;
                        });
                    }

                    if (readOnly) field.readonly = true;

                    if(readonlyFields != null) {
                        readonlyFields.forEach(function(readonlyField) {
                            if(field.apiName == readonlyField) field.readonly = true;
                        });
                    }

                    if(hideFields != null) {
                        hideFields.forEach(function(hideField) {
                            if(field.apiName == hideField) field.hide = true;
                        });
                        if(field.apiName && field.apiName.includes("Gravity__c")) field.hide = true;
                    }
                    
                    if(requiredFields != null) {
                        requiredFields.forEach(function(reqField) {
                            if(field.apiName == reqField) field.required = true;
                        })
                    }

                    if(fieldsToCheck && fieldsToCheck[field.apiName]) field.value = fieldsToCheck[field.apiName];

                    if(field.apiName && field.apiName.includes("Question")) field.isQuestion = true;
                } catch (error) {
                    console.log(error.getParams());
                }

            });
        });
        //}
        component.set('v.sections', sections);
        console.log('TA_LCP259_QualityCheckCreateRecord >> Helper >> responseLayout >> End');
    },

    submitForm : function(component, event) {
        console.log('TA_LCP259_QualityCheckCreateRecord >> Helper >> submitForm >> Start');

        event.preventDefault();       // stop the form from submitting
        console.log('>_> Quality check : ' + JSON.stringify(event.getParams()));
        let fields = event.getParams().fields;
        let predefinedValues = component.get('v.predefinedValues');

        fields.RecordTypeId = component.get('v.formRecordTypeId');  
        if(predefinedValues.length > 0) {
            predefinedValues.forEach(function(predValue) {
                fields[predValue.apiName] = predValue.value;
            });
        }

        component.find('recordForm').submit(fields); 
        console.log('TA_LCP259_QualityCheckCreateRecord >> Helper >> submitForm >> End');
    },  

	callToServer : function(component, method, callback, params) {
        //alert('Calling helper callToServer function');
		var action = component.get(method);
        if(params){
            action.setParams(params);
        }
        //alert(JSON.stringify(params));
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //alert('Processed successfully at server');
                callback.call(this,response.getReturnValue());
            }else if(state === "ERROR"){
				component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
                _helper.fireToggleSpinnerEvent(component, false);
            }
        });
		$A.enqueueAction(action);
    },
    
    fireSendInitStateEvt : function(component, isInitialized) {
        console.log('TA_LCP259_QualityCheckCreateRecord >> Helper >> fireSendInitStateEvt >> Start');
        
        let sendInitStateEvt = component.getEvent("sendInitStateEvt");
        sendInitStateEvt.setParams({
            "componentName" :  "TA_LCP259_QualityCheckCreateRecord",
            "initState"   :  isInitialized
        });

        sendInitStateEvt.fire();
        console.log('TA_LCP259_QualityCheckCreateRecord >> Helper >> fireSendInitStateEvt >> End');
    }
})