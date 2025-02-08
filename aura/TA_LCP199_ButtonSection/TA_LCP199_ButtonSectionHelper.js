({
    initialize : function(component, event, helper) {
        console.log('TA_LCP199_ButtonSection >> Helper >> initialize >> Start');
        let action = component.get("c.setButton");
        action.setParam("workOrderId", component.get("v.recordId"));
        action.setParam("screenWidth", screen.width);
        action.setCallback(this, function(response) {
            console.log('TA_LCP199_ButtonSection >> Helper >> initializeCallback >> Start');
            if(response.getState() == "SUCCESS") {
                let infoBag = JSON.parse(response.getReturnValue());
                component.set("v.infoBag", infoBag);
                let listVisibleButton = [];
                let listHiddenButton = [];
                infoBag.listButton.forEach(function(buttonWrapper) {
                    if(buttonWrapper.index <= infoBag.numberOfButtonsPerPage) {
                        listVisibleButton.push(buttonWrapper);
                    } else {
                        listHiddenButton.push(buttonWrapper);
                    }
                });
                component.set("v.listVisibleButton", listVisibleButton);
                component.set("v.listHiddenButton", listHiddenButton);
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
            component.set("v.isSpinnerVisible", false);
            console.log('TA_LCP199_ButtonSection >> Helper >> initializeCallback >> End');
        });
        $A.enqueueAction(action);

        //JS GELOCALIZATION START
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition((currentPosition) =>{

                let currentLatitude = currentPosition.coords.latitude;
                let currentLongitude = currentPosition.coords.longitude;
                let currentAccuracy = currentPosition.coords.accuracy.toFixed(7);

                component.set('v.currentLatitude', currentLatitude);
                component.set('v.currentLongitude', currentLongitude);
                component.set('v.currentAccuracy', currentAccuracy);
               
            });
        }
        //JS GELOCALIZATION END

        console.log('TA_LCP199_ButtonSection >> Helper >> initialize >> End');
    },

    moreOptions : function(component, event, helper) {
        console.log('TA_LCP199_ButtonSection >> Helper >> moreOptions >> Start');
        if(component.get("v.showMoreOptions")) {
            component.set("v.showMoreOptions", false);
        } else {
            component.set("v.listMoreButton", component.get("v.listHiddenButton"));
            component.set("v.showMoreOptions", true);
            component.set("v.showDependencyButtons", false);
        }
        console.log('TA_LCP199_ButtonSection >> Helper >> moreOptions >> End');
    },

    actionButton : function(component, event, helper) {
        console.log('TA_LCP199_ButtonSection >> Helper >> actionButton >> Start');
        let buttonDeveloperName = event.currentTarget.id;
        let listTotalButton = component.get("v.listVisibleButton");
        if(component.get("v.showMoreOptions") || component.get("v.showDependencyButtons")) {
            listTotalButton.push.apply(listTotalButton, component.get("v.listMoreButton"));
        }
        let actionBtn = {};
        let nextPhase = "";
        let updateNextPhase = false;
        let updateFields = false;
        let validation = false;
        listTotalButton.forEach(function(button) {
            if(button.developerName == buttonDeveloperName) {
                actionBtn = button.action;
                nextPhase = button.nextPhase;
                updateNextPhase = button.updateNextPhase;
                updateFields = button.updateFields;
                validation = button.validation;
            }
        });

        actionBtn = JSON.parse(actionBtn);

        this.manageAction(component, event, helper, actionBtn, nextPhase, updateNextPhase, updateFields, validation);
        console.log('TA_LCP199_ButtonSection >> Helper >> actionButton >> End');
    },

    manageAction : function(component, event, helper, actionBtn, nextPhase, updateNextPhase, updateFields, validation) {
        console.log('TA_LCP199_ButtonSection >> Helper >> manageAction >> Start');

        if(validation && !helper.checkValidation(component, updateFields)) {
            component.set("v.showToastMessage", true);
            component.set("v.isError", true);
            let invalidFields = component.get("v.invalidFields");
            let toastMessage = '';
            invalidFields.forEach(function(invalidField) {
                if(toastMessage != '') {
                    toastMessage += '. ';
                }
                toastMessage += invalidField;
            });

            component.set("v.toastMessage", toastMessage);
            component.set("v.isSpinnerVisible", false);
            return;
        }

        if(helper.isEmpty(actionBtn)) {
            actionBtn = {"javascript" : [], "apex" : []};
        }

        let recordId = component.get("v.recordId");
        if(!helper.isEmpty(actionBtn) && actionBtn.javascript.length) {
            actionBtn.javascript.forEach(function(jsMethod) {
                helper[jsMethod.name](component, event, helper, jsMethod.parameters);
            });
        }

        if(updateFields && !helper.isEmpty(component.get('v.updateObject'))) {
            actionBtn.apex.push(component.get('v.updateObject'));
            console.log(JSON.stringify(component.get('v.updateObject')));
        }

        if(!helper.isEmpty(component.get('v.leadConversionParams'))) {
            actionBtn.apex.push(component.get('v.leadConversionParams'));
        }

        component.get('v.methodApexToRun').forEach(function(apexAction) {
            actionBtn.apex.push(apexAction);
        });
        component.set('v.methodApexToRun', []);

        if(component.get('v.gpsDisabled')) updateNextPhase = false; //FIX [20220317AL] - NR70

        if((!helper.isEmpty(actionBtn) && actionBtn.apex.length) || updateNextPhase) {
            let action = component.get("c.manageApexAction");
            action.setParam("workOrderId", recordId);
            if(actionBtn) {
                action.setParam("apexActionSerialized", JSON.stringify(actionBtn.apex));
            } else {
                action.setParam("apexActionSerialized", null);
            }
            action.setParam("nextPhase", nextPhase);
            action.setParam("updateNextPhase", updateNextPhase);
            action.setCallback(this, function (response) {
                console.log('TA_LCP199_ButtonSection >> Helper >> manageActionCallback >> Start');
                let returnValueList = response.getReturnValue();
                if(response.getState() == "SUCCESS") {
                    let hasError = false;

                    returnValueList.forEach(function(returnValue) {
                        if(!returnValue.error) {
                            if(returnValue.runCallBack) {
                                helper[returnValue.callBack](component, event, helper, returnValue.callBackParams);
                            }
                        } else {
                            hasError = true;
                            let invalidFields = [];
                            if(returnValue.error.includes('Inizio pianificato')) invalidFields.push('Inizio pianificato deve essere precedente a Fine pianificata.');
                            else invalidFields.push(returnValue.error);
                            component.set("v.invalidFields", invalidFields);
                        }
                    });

                    if(hasError) {
                        component.set("v.showToastMessage", true);
                        component.set("v.isError", true);
                        component.set("v.toastMessage", JSON.stringify(component.get("v.invalidFields")));
                    }
                    
                    if(updateNextPhase && !hasError && !component.get('v.runCallBack')) {
                        location.reload();
                    } else { //ENXCRM-57 benjamin.geronimo 03/05/2021
                        component.set("v.keepSpinnerVisible", false);
                        component.set("v.isSpinnerVisible", false); 
                    }
                }
                console.log('TA_LCP199_ButtonSection >> Helper >> manageActionCallback >> End');
            });
            $A.enqueueAction(action);
        } else if(component.get("v.keepSpinnerVisible")) {
            component.set("v.keepSpinnerVisible", false);
        } else {
            component.set("v.isSpinnerVisible", false);
        }
        console.log('TA_LCP199_ButtonSection >> Helper >> manageAction >> End');
    },

    eventLCP208Modal : function(component, event, helper) {
        console.log('TA_LCP199_ButtonSection >> Helper >> eventLCP208Modal >> Start');
        let eventParams = event.getParams();
        let actionBtn = eventParams.configs.methods;
        if(actionBtn) {
            actionBtn = JSON.parse(actionBtn);
        }
        let nextPhase = eventParams.configs.nextPhase;
        let updateNextPhase = eventParams.configs.updateNextPhase;
        helper.manageAction(component, event, helper, actionBtn, nextPhase, updateNextPhase, eventParams.configs.updateFields, eventParams.configs.validation);
        console.log('TA_LCP199_ButtonSection >> Helper >> eventLCP208Modal >> End');
    },

    showLCP208Modal : function(component, event, helper, parameters) {
        console.log('TA_LCP199_ButtonSection >> Helper >> showLCP208Modal >> Start');
        component.set("v.paramsLCP208Modal", parameters);
        component.set("v.isSpinnerVisible", false);
        component.set("v.showLCP208Modal", true);
        console.log('TA_LCP199_ButtonSection >> Helper >> showLCP208Modal >> End');
    },

    hideLCP208Modal : function(component, event, helper, parameters) {
        console.log('TA_LCP199_ButtonSection >> Helper >> hideLCP208Modal >> Start');
        component.set("v.showLCP208Modal", false);
        console.log('TA_LCP199_ButtonSection >> Helper >> hideLCP208Modal >> End');
    },

    //START [20220621AL] - NR2330
    showTechnicalAssetModal : function(component, event, helper, parameters) {
        console.log('TA_LCP199_ButtonSection >> Helper >> showTechnicalAssetModal >> Start');
        this.getTechnicalAssetDefaultValues(component, parameters);
        console.log('TA_LCP199_ButtonSection >> Helper >> showTechnicalAssetModal >> End');
    },

    getTechnicalAssetDefaultValues : function(component, parameters) {
        let action = component.get("c.getTechnicalAssetDefaultValues");
        action.setParam("workOrderId", component.get("v.recordId"));
        action.setCallback(this, function(response) {
            console.log('TA_LCP199_ButtonSection >> Helper >> getTechnicalAssetDefaultValues >> Start');
            if(response.getState() == "SUCCESS") {
                let returnValue = JSON.parse(response.getReturnValue());
                // FD 11/08/2022 - INC000091951624 - START
                // FD 19/08/2022 - FIX - START
                if(returnValue.city != null){
                    let cityStringFix = returnValue.city;
                    let result = cityStringFix.replace(/(['])/g, '\\\'');
                    returnValue.city = result;
                }
                // FD 19/08/2022 - FIX - END                
                // FD 11/08/2022 - INC000091951624 - END
                if(returnValue) component.set('v.technicalAssetWrapper', {
                    technicalAsset: returnValue.technicalAsset ? { value: returnValue.technicalAsset, identifier: returnValue.technicalAssetName } : null,
                    dateDeclared: returnValue.dateDeclared,
                    // FD 08/08/2022 - - START
                    condition: returnValue.city != null ? `Account.Name LIKE '%${returnValue.city}%' AND TAM_IsTechnical__c = true` : `TAM_IsTechnical__c = true `,
                    // FD 08/08/2022 - - END
                    //condition: returnValue.city != null ? `NE__City__c = '${returnValue.city}' AND AccountId = '${returnValue.accountId}'` : null,
                    type: parameters.type
                });

                console.log('@@@ technicalAssetWrapper', JSON.stringify(component.get('v.technicalAssetWrapper')));
                component.set("v.isSpinnerVisible", false);
                component.set("v.showTechnicalAssetModal", true);

            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
                component.set("v.isSpinnerVisible", false);
            }
            console.log('TA_LCP199_ButtonSection >> Helper >> getTechnicalAssetDefaultValues >> End');
        });

        component.set("v.isSpinnerVisible", true);
        $A.enqueueAction(action);
    },
    //END [20220621AL] - NR2330

    manageDependencyButtonsModal : function(component, event, helper, parameters) {
        console.log('TA_LCP199_ButtonSection >> Helper >> manageDependencyButtonsModal >> Start');
        if(component.get("v.showDependencyButtons")) {
            component.set("v.showDependencyButtons", false);
        } else {
            let infoBag = component.get("v.infoBag");
            let buttonDevName = event.currentTarget.name;
            infoBag.listButton.forEach(function(buttonWrapper) {
                if(buttonWrapper.developerName == buttonDevName) {
                    component.set("v.listMoreButton", buttonWrapper.dependencyButtons);
                }
            });
            component.set("v.showDependencyButtons", true);
            component.set("v.showMoreOptions", false);
        }
        console.log('TA_LCP199_ButtonSection >> Helper >> manageDependencyButtonsModal >> End');
    },

    redirectToFLSCallback : function(component, event, helper, parameters) {
        console.log('TA_LCP199_ButtonSection >> Helper >> redirectToFLSCallback >> Start');
        if(parameters) {
            document.location = parameters[0];
        }
        console.log('TA_LCP199_ButtonSection >> Helper >> redirectToFLSCallback >> End');
    },

    completeWorkOrderCallback : function(component, event, helper, parameters) {
        console.log('TA_LCP199_ButtonSection >> Helper >> completeWorkOrderCallback >> Start');
        component.set("v.runCallBack", true);
        let woParentId = component.get('v.generalInfoMap').WorkOrder.ParentWorkOrderID;
        if(woParentId){
            this.redirectToPage(component, 'workorder/'+woParentId, true);
        } else {
            this.redirectToPage(component, 'custom-calendar', true);
        }
        console.log('TA_LCP199_ButtonSection >> Helper >> completeWorkOrderCallback >> End');
    },

    // START | ENCXRM-151 HSEQ BGO
    redirectToHomepageCallback : function(component, event, helper, parameters) {
        console.log('TA_LCP199_ButtonSection >> Helper >> redirectToHomepageCallback >> Start');
        component.set("v.runCallBack", true);
        this.redirectToPage(component, '', true);
        console.log('TA_LCP199_ButtonSection >> Helper >> redirectToHomepageCallback >> End');
    },
    // END | ENCXRM-151 HSEQ BGO

    manageUpdateFieldsEvt : function(component, event, helper) {
        console.log('TA_LCP199_ButtonSection >> Helper >> manageUpdateFieldsEvt >> Start');

        let updateObject = component.get('v.updateObject');
        if(updateObject == null) {
            updateObject = {"name" : "updateFields",
                            "parameters" : [{"cmpName" : event.getParam("cmpName"),
                                             "objectName" : event.getParam("objectName"),
                                             "objectLookup" : event.getParam('objectLookup'), // [20220120AL]
                                             "whereCondition" : event.getParam("whereCondition"),
                                             "fields" : event.getParam("fields")}]};
        } else {
            let cmpNames = [];
            updateObject.parameters.forEach(function(param) {
                cmpNames.push(param.cmpName);
            })

            if(cmpNames.includes(event.getParam("cmpName"))) {
                updateObject.parameters.forEach(function(param) {
                    if(param.cmpName == event.getParam("cmpName")) {
                        param.fields = event.getParam("fields");
                        param.objectName = event.getParam("objectName"); //ENXCRM-33 benjamin.geronimo 04052021
                        param.objectLookup = event.getParam('objectLookup'); // [20220120AL]
                        param.whereCondition = event.getParam("whereCondition");
                    }
                });
            } else {
                updateObject.parameters.push({"cmpName" : event.getParam("cmpName"),
                                              "objectName" : event.getParam("objectName"),
                                              "whereCondition" : event.getParam("whereCondition"),
                                              "objectLookup" : event.getParam('objectLookup'), // [20220120AL]
                                              "fields" : event.getParam("fields")});
            }
        }

        component.set('v.updateObject', updateObject);

        //START FIX [20211213AL]
        updateObject.parameters.forEach(param => {
            if(param.cmpName == 'TA_LCP214_DynamicTableLayout' && param.objectName == 'ServiceAppointment') {
                param.fields.forEach(field => {
                    if(field.apiName == 'SchedStartTime' || field.apiName == 'SchedEndTime') component.set('v.schedTimesUpdated', true);
                });
            }
        });
        //END FIX [20211213AL]

        console.log('TA_LCP199_ButtonSection >> Helper >> manageUpdateFieldsEvt >> End');
    },

    updateFieldsCallback : function(component, event, helper, parameters) {
        console.log('TA_LCP199_ButtonSection >> Helper >> updateFieldsCallback >> Start');
        if(parameters && parameters[0]) {
            component.get('v.runCallBack', true);
            component.set('v.showInfoModal', true);
            component.set('v.modalInfo', { 'title' : $A.get("$Label.c.TA_ModalInfo_Alert"), 'description' : $A.get("$Label.c.TA_ModalInfo_SerialNumberNotFound")});
        } // else {
        //     location.reload();
        // }
        console.log('TA_LCP199_ButtonSection >> Helper >> updateFieldsCallback >> End');
    },

    checkRequiredFields : function(component, event, helper) {
        console.log('TA_LCP199_ButtonSection >> Helper >> checkRequiredFields >> Start');
        if(component.get('v.updateObject') != null) {
            let invalidFields = [];
            let parameters = component.get('v.updateObject').parameters;
            parameters.forEach(function(param) {
                param.fields.forEach(function(field) {
                    if(field.required && (field.value == null || field.value == '')) invalidFields.push(field);
                });
            });
            if(invalidFields.length > 0) {
                component.set('v.invalidFields', invalidFields);
                return true;
            }
        }
        console.log('TA_LCP199_ButtonSection >> Helper >> checkRequiredFields >> End');
    },

    checkValidation : function(component, event, helper, updateFields) {
        console.log('TA_LCP199_ButtonSection >> Helper >> checkValidation >> Start');
        let validations = component.get('v.validations');
        let invalidFields = [];
        let validate = true;

        validations.forEach(function(validation) {
            if(validation.errors.length > 0 && !validation.validate) {
                invalidFields.push.apply(invalidFields, validation.errors);
                validate = false;
            }
        });
        component.set('v.invalidFields', invalidFields);
        console.log('TA_LCP199_ButtonSection >> Helper >> checkValidation >> End');
        return validate;
    },

    validationEvt : function(component, event, helper) {
        console.log('TA_LCP199_ButtonSection >> Helper >> validationEvt >> Start');
        let validations = component.get('v.validations');
        let validationNotFound = true;

        validations.forEach(function(validation) {
            if(validation.cmpName == event.getParam("cmpName")) {
                validation.validate = event.getParam("validate");
                validation.errors = event.getParam("errors");
                validation.updateFields = event.getParam("updateFields");
                validationNotFound = false;
            }
        });

        if(validationNotFound) {
            validations.push({"cmpName" : event.getParam("cmpName"),
                             "validate" : event.getParam("validate"),
                             "errors" : event.getParam("errors"),
                             "updateFields" : event.getParam("updateFields")});
        }

        component.set('v.validations', validations);
        console.log('TA_LCP199_ButtonSection >> Helper >> validationEvt >> End');
    },
    
    receiveLeadConversionParams : function(component, event, helper) {
        console.log('TA_LCP199_ButtonSection >> Helper >> receiveLeadConversionParams >> Start');
        let leadConversionParams = event.getParam("paramsWrapper");
        let infoBag = leadConversionParams.infoBag;
        let infoBagWithDBValues = leadConversionParams.infoBagWithDBValues;
        let hasChanged = this.hasChanged(infoBag, infoBagWithDBValues);
        let serializedInfoBag = JSON.stringify(infoBag);
        let serializedAddress = JSON.stringify(leadConversionParams.address);

        let configurationObject = {"name" : "leadConversion",
                                   "parameters" : [{"serializedInfoBag" : serializedInfoBag,
                                                    "hasChanged" : hasChanged,
                                                    "serializedAddress" : serializedAddress}]
                                  };

        component.set("v.leadConversionParams", configurationObject);
        console.log('TA_LCP199_ButtonSection >> Helper >> receiveLeadConversionParams >> End');
    },

    hasChanged : function(infoBag, infoBagWithDBValues) {
        console.log('TA_LCP199_ButtonSection >> Helper >> hasChanged >> Start');
        let hasChanged = false;
        for(let i = 0; i < infoBagWithDBValues.fieldStructureList.length; i++) {
            if(infoBagWithDBValues.fieldStructureList[i].apiName == infoBag.fieldStructureList[i].apiName) {
                if(infoBagWithDBValues.fieldStructureList[i].value != infoBag.fieldStructureList[i].value) {
                    hasChanged = true;
                }
            }
        }
        console.log('TA_LCP199_ButtonSection >> Helper >> hasChanged >> End');
        return hasChanged;
    },

    answerToButton : function(component, event, helper) {
        console.log('TA_LCP199_ButtonSection >> Helper >> answerToButton >> Start');
        let listMethod = event.getParam('answerValue');
        listMethod.forEach(function(method) {
            helper[method.methodName](component, event, helper, method.parameters);
        });
        console.log('TA_LCP199_ButtonSection >> Helper >> answerToButton >> End');
    },

    enableDisableButton : function(component, event, helper, parameters) {
        console.log('TA_LCP199_ButtonSection >> Helper >> enableDisableButton >> Start');
        let buttonElem = document.getElementById(parameters.buttonName);
        let action = parameters.action;

        let checkClass = false;
        buttonElem.classList.forEach(function(className) {
            if(className == "ta-disable-button") {
                checkClass = true;
            }
        });

        if(checkClass && action == 'enable') {
            buttonElem.classList.remove("ta-disable-button");
        } else if(!checkClass && action == 'disable') {
            buttonElem.classList.add("ta-disable-button");
        }
        console.log('TA_LCP199_ButtonSection >> Helper >> enableDisableButton >> End');
    },

    showNoMatchAssetModal : function(component, event, helper, parameters) {
        console.log('TA_LCP199_ButtonSection >> Helper >> showNoMatchAssetModal >> Start');
        component.set('v.showNoMatchAssetModal', true);
        console.log('TA_LCP199_ButtonSection >> Helper >> showNoMatchAssetModal >> End');
    },

    updateNextPhaseButton : function(component, event, helper, parameters) {
        console.log('TA_LCP199_ButtonSection >> Helper >> updateNextPhaseButton >> Start');
        let infoBag = component.get('v.infoBag');

        infoBag.listButton.forEach(function(button) {
            if(button.developerName == parameters.buttonName) {
                button.nextPhase = parameters.phase;
            }
        });

        component.set('v.infoBag', infoBag);
        console.log('TA_LCP199_ButtonSection >> Helper >> updateNextPhaseButton >> End');
    },

    customerInteraction : function(component, event, helper, parameters) {
        console.log('TA_LCP199_ButtonSection >> Helper >> customerInteraction >> Start');
        let generalInfo = component.get('v.generalInfoMap');
        Object.keys(parameters.CustomerInteraction).forEach(function(ciInput) {
            if(!parameters.CustomerInteraction[ciInput]) {
                parameters.CustomerInteraction[ciInput] = generalInfo.WorkOrder[ciInput];
            }
        });

        let apexAction = {"name": "customerInteraction", "parameters": JSON.stringify(parameters)};
        let methodApexToRun = component.get('v.methodApexToRun');
        methodApexToRun.push(apexAction);
        component.set('v.methodApexToRun', methodApexToRun);
        component.set('v.showMoreOptions', false);
        console.log('TA_LCP199_ButtonSection >> Helper >> customerInteraction >> End');
    },

    generalInfo : function(component, event, helper) {
        console.log('TA_LCP199_ButtonSection >> Helper >> generalInfo >> Start');
        component.set('v.generalInfoMap', event.getParam('generalInfoMap'));
        console.log('TA_LCP199_ButtonSection >> Helper >> generalInfo >> End');
    },

    updateWorkOrder : function(component, event, helper, parameters) {
        console.log('TA_LCP199_ButtonSection >> Helper >> updateWorkOrder >> Start');
        parameters.WorkOrder = helper.createJSONRecursive(component, event, helper, 'WorkOrder', parameters['WorkOrder']);
        //Add coordinates to WorkOrder - jacopo.scaravaggi@webresults.it - 25/01/2022 - START
        /*if(parameters.Coordinates && navigator.geolocation){
            navigator.geolocation.getCurrentPosition((currentPosition) =>{

                //parameters.WorkOrder[parameters.Coordinates.Latitude] = currentPosition.coords.latitude;
                //parameters.WorkOrder[parameters.Coordinates.Longitude] = currentPosition.coords.longitude;
                //parameters.WorkOrder[parameters.Coordinates.Accuracy] = currentPosition.coords.accuracy.toFixed(7);

                parameters.Coordinates.Latitude.value = currentPosition.coords.latitude;
                parameters.Coordinates.Longitude.value = currentPosition.coords.longitude;
                parameters.Coordinates.Accuracy.value = currentPosition.coords.accuracy.toFixed(7);
                
                console.log('@@>> parameters with coordinates >>> ' + JSON.stringify(parameters));
                return parameters;

            }).then(parameters => {
                console.log('SONO QUI >>>>>>>>>>>>>>>>>>>>>>>>>>');
                let apexAction = {"name": "updateWorkOrder", "parameters": JSON.stringify(parameters)};
                let methodApexToRun = component.get('v.methodApexToRun');
                methodApexToRun.push(apexAction);
                component.set('v.methodApexToRun', methodApexToRun);
            });

        } else {
            console.log('qui ora non devo entrare >>>>>>>>>>>>>>>>>>>>>>>>>>');
            let apexAction = {"name": "updateWorkOrder", "parameters": JSON.stringify(parameters)};
            let methodApexToRun = component.get('v.methodApexToRun');
            methodApexToRun.push(apexAction);
            component.set('v.methodApexToRun', methodApexToRun);
        }*/

        /*if(parameters.Coordinates){
            parameters.Coordinates.Latitude.value = component.get('v.currentLatitude');
            parameters.Coordinates.Longitude.value = component.get('v.currentLongitude');
            parameters.Coordinates.Accuracy.value = component.get('v.currentAccuracy');
            console.log('@@>> parameters >>> ' + JSON.stringify(parameters));
        }*/
        //Add coordinates to WorkOrder - jacopo.scaravaggi@webresults.it - 25/01/2022 - END

        let apexAction = {"name": "updateWorkOrder", "parameters": JSON.stringify(parameters)};
        let methodApexToRun = component.get('v.methodApexToRun');
        methodApexToRun.push(apexAction);
        component.set('v.methodApexToRun', methodApexToRun);
        
        console.log('TA_LCP199_ButtonSection >> Helper >> updateWorkOrder >> End');
    },

    completeWorkOrderGPS : function(component, event, helper, parameters) {
        console.log('TA_LCP199_ButtonSection >> Helper >> completeWorkOrderGPS >> Start');
        parameters.WorkOrder = helper.createJSONRecursive(component, event, helper, 'WorkOrder', parameters['WorkOrder']);

        if(parameters.Coordinates){
            parameters.Coordinates.Latitude.value = component.get('v.currentLatitude');
            parameters.Coordinates.Longitude.value = component.get('v.currentLongitude');
            parameters.Coordinates.Accuracy.value = component.get('v.currentAccuracy');
            console.log('@@>> parameters >>> ' + JSON.stringify(parameters));
        }

        let apexAction = {"name": "completeWorkOrderGPS", "parameters": JSON.stringify(parameters)};
        let methodApexToRun = component.get('v.methodApexToRun');
        methodApexToRun.push(apexAction);
        component.set('v.methodApexToRun', methodApexToRun);
        
        console.log('TA_LCP199_ButtonSection >> Helper >> completeWorkOrderGPS >> End');
    },

    updateWorkOrder_GPS : function(component, event, helper, parameters) {
        console.log('TA_LCP199_ButtonSection >> Helper >> updateWorkOrder >> Start');
		
        // 16062022 FD - ENXCRM-213 - START
        if(parameters.Coordinates){            
           if(component.get('v.currentLatitude') && component.get('v.currentLongitude') && component.get('v.currentAccuracy')){            
                parameters.Coordinates.Latitude.value = component.get('v.currentLatitude');
                parameters.Coordinates.Longitude.value = component.get('v.currentLongitude');
                parameters.Coordinates.Accuracy.value = component.get('v.currentAccuracy');
            } else {
                parameters.Coordinates.Latitude.value = null;
                parameters.Coordinates.Longitude.value = null;
                parameters.Coordinates.Accuracy.value = null;
            }
        }      

        if(parameters.Coordinates && parameters.Coordinates.Mandatory == 'true'){

            if(parameters.Coordinates && parameters.Coordinates.Latitude.value && parameters.Coordinates.Longitude.value && parameters.Coordinates.Accuracy.value){
                parameters.WorkOrder = helper.createJSONRecursive(component, event, helper, 'WorkOrder', parameters['WorkOrder']);               
                let apexAction = {"name": "updateWorkOrder_GPS", "parameters": JSON.stringify(parameters)};
                let methodApexToRun = component.get('v.methodApexToRun');
                methodApexToRun.push(apexAction);
                component.set('v.methodApexToRun', methodApexToRun);
                component.set('v.gpsDisabled', false);
            } else {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", $A.get('$Label.c.TA_GeolocalizationError'));
                component.set('v.isSpinnerVisible', false);
                component.set('v.gpsDisabled', true);
            }

        } else {

            parameters.WorkOrder = helper.createJSONRecursive(component, event, helper, 'WorkOrder', parameters['WorkOrder']);            
            let apexAction = {"name": "updateWorkOrder", "parameters": JSON.stringify(parameters)};
            let methodApexToRun = component.get('v.methodApexToRun');
            methodApexToRun.push(apexAction);
            component.set('v.methodApexToRun', methodApexToRun);
        }
        console.log('TA_LCP199_ButtonSection >> Helper >> updateWorkOrder >> End');
        // 16062022 FD - ENXCRM-213 - END
    },

    createJSONRecursive : function(component, event, helper, jsonProperty, jsonObject) {
        console.log('TA_LCP199_ButtonSection >> Helper >> createJSONRecursive >> Start');
        let jsonPropertyMap = component.get('v.generalInfoMap')[jsonProperty];
        for(let prop in jsonObject) {
            if(typeof jsonObject[prop] == 'string' && !jsonObject[prop]) {
                jsonObject[prop] = jsonPropertyMap[prop];
            } else if(typeof jsonObject[prop] == 'object') {
                if(Array.isArray(jsonObject[prop]) && jsonObject[prop].length) {
                    jsonObject[prop][0] = helper.createJSONRecursive(component, event, helper, prop, jsonObject[prop][0]);
                } else if(prop.toString() === '[object Object]') {
                    jsonObject[prop] = helper.createJSONRecursive(component, event, helper, prop, jsonObject[prop]);
                }
            }
        }
        console.log('TA_LCP199_ButtonSection >> Helper >> createJSONRecursive >> End');
        return jsonObject;
    },

    openModalCloseService : function(component, event, helper, parameters) {
        console.log('TA_LCP199_ButtonSection >> Helper >> openModalCloseService >> Start');
        component.set('v.closeServiceModalTitle', $A.getReference("$Label.c." + parameters.title));
        
        /*component.set('v.listCloseServiceReason', parameters.picklistOption);
        if(parameters.picklistOption.length) {
            component.set('v.selectedValueCloseService', parameters.picklistOption[0].label);
        }*/

        if(component.get('v.infoBag.closeReasons').length) {
            component.set('v.selectedValueCloseService', component.get('v.infoBag.closeReasons')[0].value);
        }

        component.set("v.showModalCloseService", true);
        console.log('TA_LCP199_ButtonSection >> Helper >> openModalCloseService >> End');
    },

    closeModalCloseService : function(component, event, helper) {
        console.log('TA_LCP199_ButtonSection >> Helper >> closeModalCloseService >> Start');
        component.set('v.showModalCloseService', false);
        console.log('TA_LCP199_ButtonSection >> Helper >> closeModalCloseService >> End');
    },

    updateCloseServiceReason : function(component, event, helper) {
        console.log('TA_LCP199_ButtonSection >> Helper >> updateCloseServiceReason >> Start');
        
        let selectedValueCloseService = component.get('v.selectedValueCloseService');
        let updateReasonCannotComplete = component.get('c.updateReasonCannotComplete');
        let _helper = this;
        
        updateReasonCannotComplete.setParams({'workOrderId' : component.get("v.recordId"), 'rccValue' : selectedValueCloseService});
        updateReasonCannotComplete.setCallback(this, function (response) {
            console.log('TA_LCP199_ButtonSection >> Helper >> updateReasonCannotComplete >> Start');
            if(response.getState() == "SUCCESS") {
                if(response.getReturnValue() == 'complete') {
                    _helper.redirectToPage(component, 'custom-calendar', true);
                } else {
                    component.set("v.showToastMessage", true);
                    component.set("v.isError", true);
                    component.set("v.toastMessage", response.getReturnValue());
                    component.set('v.isSpinnerVisible', false);
                }      
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
                component.set('v.isSpinnerVisible', false);
            }
            console.log('TA_LCP199_ButtonSection >> Helper >> updateReasonCannotComplete >> End');
        });

        component.set('v.isSpinnerVisible', true);
        $A.enqueueAction(updateReasonCannotComplete);

        /*let listCloseServiceReason = component.get('v.listCloseServiceReason');

        listCloseServiceReason.forEach(function(closeServiceReason) {
            if(closeServiceReason.label == selectedValueCloseService) {
                let selectedValueCloseServiceValue = closeServiceReason.value;
                helper[selectedValueCloseServiceValue.name](component, event, helper, selectedValueCloseServiceValue.parameters);
            }
        });

        helper.manageAction(component, event, helper, {}, null, false, false, false);*/
        console.log('TA_LCP199_ButtonSection >> Helper >> updateCloseServiceReason >> End');
    },

    rescheduleVisit : function(component, event, helper, parameters) {
        console.log('TA_LCP199_ButtonSection >> Helper >> rescheduleVisit >> Start');

        // START FIX [20211214AL]
        if(component.get('v.schedTimesUpdated')) {
            component.set('v.keepSpinnerVisible', true);
            let updateObject = component.get('v.updateObject');
            let woInUpdate = false;

            updateObject.parameters.forEach(param => {
                if(param.cmpName == 'TA_LCP214_DynamicTableLayout' && param.objectName == 'ServiceAppointment') {
                    param.fields.push({
                        value: 'Assigned to the technician',
                        apiName : 'XC_StatusReason__c'
                    });
                }

                if(param.objectName == 'WorkOrder') {
                    woInUpdate = true;
                    param.fields.push({
                        value: 'Assigned to the technician',
                        apiName : 'XC_StatusReason__c'
                    });
                }
            });

            if(!woInUpdate) {
                updateObject.parameters.push({
                    cmpName : 'TA_LCP214_DynamicTableLayout',
                    objectName : 'WorkOrder',
                    fields : [ { value: 'Assigned to the technician', apiName : 'XC_StatusReason__c' } ]
                })
            }
            helper.manageAction(component, event, helper, null, 'PreService', true, true, true);
            
        } else {
        // END FIX [20211214AL]
            component.set('v.showDependencyButtons', false);
            component.set('v.showLCP224BookAppointmentModal', true);
            component.set('v.showCalendarModal', true);
        }
        console.log('TA_LCP199_ButtonSection >> Helper >> rescheduleVisit >> End');
    },

    manageProvisioning : function(component, event, helper, parameters) {
        console.log('TA_LCP199_ButtonSection >> Helper >> manageProvisioning >> Start');
        parameters.id = component.get("v.recordId"); 
        let apexAction = {"name": "manageProvisioning", "parameters": parameters};
        let methodApexToRun = component.get('v.methodApexToRun');
        methodApexToRun.push(apexAction);
        component.set('v.methodApexToRun', methodApexToRun);
        console.log('TA_LCP199_ButtonSection >> Helper >> manageProvisioning >> End');
    },

    updateWorkOrderHasParentNoParent : function(component, event, helper, parameters) {
        console.log('TA_LCP199_ButtonSection >> Helper >> updateWorkOrderHasParentNoParent >> Start');
        let params = {}
        if(component.get('v.generalInfoMap').WorkOrder.ParentWorkOrderID) {
            params = parameters.woHasParent;
        } else {
            params = parameters.woHasNoParent;
        }
        helper.updateWorkOrder(component, event, helper, params);
        console.log('TA_LCP199_ButtonSection >> Helper >> updateWorkOrderHasParentNoParent >> End');
    },

    completeWorkOrderHasParentNoParent : function(component, event, helper, parameters) {
        console.log('TA_LCP199_ButtonSection >> Helper >> completeWorkOrderHasParentNoParent >> Start');
        let params = {}
        if(component.get('v.generalInfoMap').WorkOrder.ParentWorkOrderID) {
            params = parameters.woHasParent;
        } else {
            params = parameters.woHasNoParent;
        }
        helper.completeWorkOrder(component, event, helper, params);
        console.log('TA_LCP199_ButtonSection >> Helper >> completeWorkOrderHasParentNoParent >> End');
    },

    closeServiceApppointment : function(component) {
        console.log('TA_LCP199_ButtonSection >> Helper >> closeServiceApppointment >> Start');
        let _helper = this;
        let action = component.get("c.closeServiceAppointment");
        action.setParam("workOrderId", component.get("v.recordId"));
        action.setCallback(this, function(response) {
            console.log('TA_LCP199_ButtonSection >> Helper >> closeServiceApppointmentCallback >> Start');
            if(response.getState() == "SUCCESS") {
                if(response.getReturnValue() == true) _helper.redirectToPage(component, 'custom-calendar', true);
                component.set("v.isSpinnerVisible", false);
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
                component.set("v.isSpinnerVisible", false);
            }
            console.log('TA_LCP199_ButtonSection >> Helper >> closeServiceApppointmentCallback >> End');
        });

        component.set("v.isSpinnerVisible", true);
        $A.enqueueAction(action);
        console.log('TA_LCP199_ButtonSection >> Helper >> closeServiceApppointment >> End');
    },

    showNoMatchAssetModal : function(component) {
        console.log('TA_LCP199_ButtonSection >> Helper >> showNoMatchAssetModal >> Start');
        let action = component.get("c.loadAssets");
        action.setParam("workOrderId", component.get("v.recordId"));
        action.setCallback(this, function(response) {
            console.log('TA_LCP199_ButtonSection >> Helper >> showNoMatchAssetModalCallback >> Start');
            if(response.getState() == "SUCCESS") {
                component.set('v.assets', response.getReturnValue());
                component.set('v.showManageAssetModal', true);
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
            component.set("v.isSpinnerVisible", false);
            console.log('TA_LCP199_ButtonSection >> Helper >> showNoMatchAssetModalCallback >> End');
        });

        component.set("v.isSpinnerVisible", true);
        $A.enqueueAction(action);
        console.log('TA_LCP199_ButtonSection >> Helper >> showNoMatchAssetModal >> End');
    },

    prepareNextCartStep : function(component, event, helper) {
        console.log('TA_LCP199_ButtonSection >> Helper >> prepareNextCartStep >> Start');
        let params = event.getParams();
        if(params.showButton) {
            let infoBag = component.get('v.infoBag');
            infoBag.listButton.forEach(function(button) {
                if(button.developerName == 'Continue') {
                    button.action = JSON.stringify({
                                        "javascript": [{
                                            "name": "goToNextCartStep",
                                            "parameters": params
                                        }],
                                        "apex": []
                                    });
                }
            });
            component.set('v.infoBag', infoBag);
            let parametersDisableButton = {
                'buttonName' : 'Continue',
                'action' : 'enable'
            };
            helper.enableDisableButton(component, event, helper, parametersDisableButton);
        } else {
            let parametersDisableButton = {
                'buttonName' : 'Continue',
                'action' : 'disable'
            };
            helper.enableDisableButton(component, event, helper, parametersDisableButton);
        }
        console.log('TA_LCP199_ButtonSection >> Helper >> prepareNextCartStep >> End');
    },

    goToNextCartStep : function(component, event, helper, parameters) {
        console.log('TA_LCP199_ButtonSection >> Helper >> goToNextStep >> Start');
        let fireGoToNextStep = $A.get("e.c:TA_LCE226_CartStep");
        fireGoToNextStep.setParams({
            'handlerCmpName' : 'TA_LCP226_CartContainer',
            'actionName': parameters.actionName,
            'actionParams': parameters.actionParams
        });
        fireGoToNextStep.fire();
        console.log('TA_LCP199_ButtonSection >> Helper >> goToNextStep >> End');
    },

    addJSActionToButton : function(component, event, helper, parameters) {
        console.log('TA_LCP199_ButtonSection >> Helper >> addJSActionToButton >> Start');
        let jsAction = {"name": parameters.action, "parameters": JSON.stringify(parameters.params)};
        let infoBag = component.get('v.infoBag');
        infoBag.listButton.forEach(function(button) {
            if(button.developerName == parameters.buttonName && !helper.isEmpty(button.action)) {
                button.action.javascript.push(jsAction);
            }
        });
        component.set('v.infoBag', infoBag);
        console.log('TA_LCP199_ButtonSection >> Helper >> addJSActionToButton >> End');
    },

    manageQuoteEvent : function(component, event, helper, parameters) {
        console.log('TA_LCP199_ButtonSection >> Helper >> manageQuoteEvent >> Start');
        helper.keepSpinnerVisible(component, event, helper);
        let manageQuoteEvt = $A.get("e.c:TA_LCE233_QuoteSummary");
        manageQuoteEvt.setParams({
            'handlerCmpName' : 'TA_LCP233_QuoteSummary',
            'action' : 'manageQuote',
            'params' : parameters
        });
        manageQuoteEvt.fire();
        console.log('TA_LCP199_ButtonSection >> Helper >> manageQuoteEvent >> End');
    },

    completeWorkOrder : function(component, event, helper, parameters) {
        console.log('TA_LCP199_ButtonSection >> Helper >> completeWorkOrder >> Start');
        parameters.WorkOrder = helper.createJSONRecursive(component, event, helper, 'WorkOrder', parameters['WorkOrder']);
        let apexAction = {"name": "completeWorkOrder", "parameters": JSON.stringify(parameters)};
        let methodApexToRun = component.get('v.methodApexToRun');
        methodApexToRun.push(apexAction);
        component.set('v.methodApexToRun', methodApexToRun);
        console.log('TA_LCP199_ButtonSection >> Helper >> completeWorkOrder >> End');
    },

    //START - [20220627AL] - NR2330
    technicalAssetContinue : function(component, event, helper) {
        console.log('TA_LCP199_ButtonSection >> Controller >> technicalAssetContinue >> Start');
        let buttonAction = '';
        let nextPhase = '';

        if(component.get('v.technicalAssetWrapper').type == 'suspend') {
            nextPhase = 'Action_Suspend';
            buttonAction = JSON.stringify({
                'javascript': [{
                    'name': 'updateWorkOrder',
                    'parameters': {
                        'WorkOrder': { 
                            'WorkOrderID': '', 
                            'Status': 'On Hold',
                            'ServiceAppointment': [{
                                'ServiceAppointmentID': '',
                                'Status': 'On Hold',
                                'ActualEnd': ''
                            }]
                        }
                    }
                }],
                'apex': []
            });
        } else if(component.get('v.technicalAssetWrapper').type == 'complete') {
            nextPhase = 'Action_Complete';
            buttonAction = JSON.stringify({
                'javascript': [{
                    'name': 'completeWorkOrder',
                    'parameters': {
                        'WorkOrder': { 
                            'WorkOrderID': '', 
                            'ServiceAppointment': [{
                                'ServiceAppointmentID': '',
                                'Status': 'Completed',
                                'ActualEnd': ''
                            }]
                        }
                    }
                }],
                'apex': []
            });
        }
        component.set("v.isSpinnerVisible", true);
        this.manageAction(component, event, this, JSON.parse(buttonAction), nextPhase, true, true, true);
        console.log('TA_LCP199_ButtonSection >> Controller >> technicalAssetContinue >> End');
    },
    //END - [20220627AL] - NR2330

    goToQuoteSummary : function(component, event, helper) {
        console.log('TA_LCP199_ButtonSection >> Helper >> goToQuoteSummary >> Start');
        let params = event.getParams();
        let infoBag = component.get('v.infoBag');
        infoBag.listButton.forEach(function(button) {
            if(button.developerName == 'Continue') {
                button.action = JSON.stringify({
                                    "javascript": [],
                                    "apex": [{
                                        "name":"updateWorkOrderTAParameters",
                                        "parameters" : params.actionParams
                                    }]
                                });
                button.updateNextPhase = true;

                component.set('v.infoBag', infoBag);
                helper.manageAction(component, event, helper, JSON.parse(button.action), button.nextPhase, button.updateNextPhase, button.updateFields, button.validation);
                console.log('TA_LCP199_ButtonSection >> Helper >> goToQuoteSummary >> End');
                return;
            }
        });
        console.log('TA_LCP199_ButtonSection >> Helper >> goToQuoteSummary >> End');
    },

    manageUpdateQuote : function(component, event, helper, parameters) {
        console.log('TA_LCP199_ButtonSection >> Helper >> manageUpdateQuote >> Start');
        let infoBag = component.get('v.infoBag');
        infoBag.listButton.forEach(function(button) {
            if(button.developerName == parameters.buttonName) {
                let actionBtn = JSON.parse(button.action);
                if(helper.isEmpty(actionBtn)) {
                    actionBtn = {"javascript" : [], "apex" : []};
                }

                actionBtn.javascript.push({
                    "name": "manageQuoteEvent",
                    "parameters": parameters
                });

                button.action = JSON.stringify(actionBtn);
            }
        });
        component.set('v.infoBag', infoBag);
        console.log('TA_LCP199_ButtonSection >> Helper >> manageUpdateQuote >> End');
    },

    manageUpdateOrderItemBillingProfile : function(component, event, helper, parameters) {
        console.log('TA_LCP199_ButtonSection >> Helper >> manageUpdateOrderItemBillingProfile >> Start');
        let manageOrderItemEvt = $A.get("e.c:TA_LCE233_QuoteSummary");
        manageOrderItemEvt.setParams({
            'handlerCmpName' : 'TA_LCP234_PaymentMethod',
            'action' : 'handleUpdateOrderItemBillingProfile',
            'params' : parameters
        });
        manageOrderItemEvt.fire();
        console.log('TA_LCP199_ButtonSection >> Helper >> manageUpdateOrderItemBillingProfile >> End');
    },

    goToNextPhase : function(component, event, helper, parameters) {
        console.log('TA_LCP199_ButtonSection >> Helper >> goToNextPhase >> Start');
        let infoBag = component.get('v.infoBag');
        infoBag.listButton.forEach(function(button) {
            if(button.developerName == parameters.buttonName) {
                button.action = JSON.stringify({
                                    "javascript": [],
                                    "apex": []
                                });
                button.updateNextPhase = parameters.updateNextPhase;

                component.set('v.infoBag', infoBag);
                helper.manageAction(component, event, helper, JSON.parse(button.action), button.nextPhase, button.updateNextPhase, button.updateFields, button.validation);
                console.log('TA_LCP199_ButtonSection >> Helper >> goToNextPhaseCallback >> End');
                return;
            }
        });
        console.log('TA_LCP199_ButtonSection >> Helper >> goToNextPhase >> End');
    },

    keepSpinnerVisible : function(component, event, helper) {
        console.log('TA_LCP199_ButtonSection >> Helper >> keepSpinnerVisible >> Start');
        component.set('v.keepSpinnerVisible', true);
        console.log('TA_LCP199_ButtonSection >> Helper >> keepSpinnerVisible >> End');
    },

    completeQuoteCallback : function(component, event, helper, parameters) {
        console.log('TA_LCP199_ButtonSection >> Helper >> completeQuoteCallback >> Start');
        helper.completeWorkOrder(component, event, helper, parameters);
        component.set('v.keepSpinnerVisible', true);
        helper.manageAction(component, event, helper, {}, null, false, true, true);
        console.log('TA_LCP199_ButtonSection >> Helper >> completeQuoteCallback >> End');
    },

    createNewOppty : function(component, event, helper, parameters) {
        console.log('TA_LCP199_ButtonSection >> Helper >> createNewOppty >> Start');
        parameters.Opportunity = helper.createJSONRecursive(component, event, helper, 'Opportunity', parameters['Opportunity']);
        let apexAction = {
                            "name": "createNewOppty",
                            "parameters": {
                                "opptyWrapper" : JSON.stringify(parameters),
                                "taParameters" : {
                                    "newOppty" : ""
                                }
                            }
                        };
        let methodApexToRun = component.get('v.methodApexToRun');
        methodApexToRun.push(apexAction);
        component.set('v.methodApexToRun', methodApexToRun);
        console.log('TA_LCP199_ButtonSection >> Helper >> createNewOppty >> End');
    },

    createNewOpptyCallback : function(component, event, helper, parameters) {
        console.log('TA_LCP199_ButtonSection >> Helper >> createNewOpptyCallback >> Start');
        location.reload();
        console.log('TA_LCP199_ButtonSection >> Helper >> createNewOpptyCallback >> End');
    },

    showSuspendVisitModal : function(component, event, helper, parameters) {
        console.log('TA_LCP199_ButtonSection >> Helper >> showSuspendVisitModal >> Start');
        component.set("v.suspendVisitParams", parameters);
        component.set("v.showSuspendVisitModal", true);
        console.log('TA_LCP199_ButtonSection >> Helper >> showSuspendVisitModal >> End');
    },
    
    suspendVisit : function(component, event, helper) {
        console.log('TA_LCP199_ButtonSection >> Helper >> suspendVisit >> Start');
        let parameters = component.get("v.suspendVisitParams");
        component.set("v.isSpinnerVisible", true);      
        helper.completeWorkOrder(component, event, helper, parameters);
        helper.actionButton(component, event, helper);
        console.log('TA_LCP199_ButtonSection >> Helper >> suspendVisit >> End');
    },

    manageSuspendVisitModal : function(component, event, helper) {
        console.log('TA_LCP199_ButtonSection >> Helper >> manageSuspendVisitModal >> Start');
        let showSuspendVisitModal = component.get("v.showSuspendVisitModal");
        component.set("v.showSuspendVisitModal", !showSuspendVisitModal);
        console.log('TA_LCP199_ButtonSection >> Helper >> manageSuspendVisitModal >> End');
    },

    changeSelectedQuoteOppty : function(component, event, helper, opptyId) {
        console.log('TA_LCP199_ButtonSection >> Helper >> changeSelectedQuoteOppty >> Start');
        let infoBag = component.get('v.infoBag');
        infoBag.listButton.forEach(function(button) {
            let action = JSON.parse(button.action);
            if(button.developerName == 'EmailQuote' && action && action.javascript) {
                action.javascript.forEach(function(jsMethod) {
                    if(jsMethod.name == 'customerInteraction' && jsMethod.parameters && jsMethod.parameters.CustomerInteraction) {
                        if(opptyId) {
                            jsMethod.parameters.CustomerInteraction.OpportunityId = opptyId;
                        } else {
                            jsMethod.parameters.CustomerInteraction.OpportunityId = '';
                        }
                    }
                });
            }
        });
        component.set('v.infoBag', infoBag);
        console.log('TA_LCP199_ButtonSection >> Helper >> changeSelectedQuoteOppty >> End');
    }
})