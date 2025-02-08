({
	handleInitialize : function(component, event, helper) {
        console.log('TA_LCP199_ButtonSection >> Controller >> handleInitialize >> Start');
        helper.initialize(component, event, helper);
        console.log('TA_LCP199_ButtonSection >> Controller >> handleInitialize >> End');
    },

    handleMoreOptions : function(component, event, helper) {
        console.log('TA_LCP199_ButtonSection >> Controller >> handleMoreOptions >> Start');
        component.set("v.isSpinnerVisible", true);
        helper.moreOptions(component, event, helper);
        component.set("v.isSpinnerVisible", false);
        console.log('TA_LCP199_ButtonSection >> Controller >> handleMoreOptions >> End');
    },

    handleActionButton : function(component, event, helper) {
        console.log('TA_LCP199_ButtonSection >> Controller >> handleActionButton >> Start');
        component.set("v.isSpinnerVisible", true);
        helper.actionButton(component, event, helper);
        console.log('TA_LCP199_ButtonSection >> Controller >> handleActionButton >> End');
    },

    handleEvents : function(component, event, helper) {
        console.log('TA_LCP199_ButtonSection >> Controller >> handleEvents >> Start');
        let eventName = event.getSource().getName();
        switch(eventName) {
            case 'cTA_LCP208_Modal':
                helper.eventLCP208Modal(component, event, helper);
                break;
            case 'cTA_LCP202_DynamicLayout':
                helper.manageUpdateFieldsEvt(component, event, helper);
                break;
            case 'cTA_LCP199_ButtonSection':
                helper.manageUpdateFieldsEvt(component, event, helper);
                break;
            case 'cTA_LCP214_DynamicTableLayout':
                helper.manageUpdateFieldsEvt(component, event, helper);
                break;
            case 'cTA_LCP215_DynamicMultyQueryLayout':
                helper.manageUpdateFieldsEvt(component, event, helper);
                break;
        }
        console.log('TA_LCP199_ButtonSection >> Controller >> handleEvents >> End');
    },

    handleCloseToast : function(component, event, helper) {
        console.log('TA_LCP199_ButtonSection >> Controller >> handleCloseToast >> Start');
        component.set('v.showErrorToast', false);
        console.log('TA_LCP199_ButtonSection >> Controller >> handleCloseToast >> End');
    },

    handleValidationEvt : function(component, event, helper) {
        console.log('TA_LCP199_ButtonSection >> Controller >> handleValidationEvt >> Start');
        helper.validationEvt(component, event, helper);
        console.log('TA_LCP199_ButtonSection >> Controller >> handleValidationEvt >> End');
    },

    handleReceiveLeadConversionParams : function(component, event, helper) {
        console.log('TA_LCP199_ButtonSection >> Controller >> handleReceiveLeadConversionParams >> Start');
        helper.receiveLeadConversionParams(component, event, helper);
        console.log('TA_LCP199_ButtonSection >> Controller >> handleReceiveLeadConversionParams >> End');
    },

    handleAnswerToButton : function(component, event, helper) {
        console.log('TA_LCP199_ButtonSection >> Controller >> handleAnswerToButton >> Start');
        helper.answerToButton(component, event, helper);
        console.log('TA_LCP199_ButtonSection >> Controller >> handleAnswerToButton >> End');
    },

    handleGeneralInfo : function(component, event, helper) {
        console.log('TA_LCP199_ButtonSection >> Controller >> handleGeneralInfo >> Start');
        helper.generalInfo(component, event, helper);
        console.log('TA_LCP199_ButtonSection >> Controller >> handleGeneralInfo >> End');
    },

    handleCloseModalCloseService : function(component, event, helper) {
        console.log('TA_LCP199_ButtonSection >> Controller >> handleCloseModalCloseService >> Start');
        helper.closeModalCloseService(component, event, helper);
        console.log('TA_LCP199_ButtonSection >> Controller >> handleCloseModalCloseService >> End');
    },

    handleUpdateCloseServiceReason : function(component, event, helper) {
        console.log('TA_LCP199_ButtonSection >> Controller >> handleUpdateCloseServiceReason >> Start');
        component.set("v.isSpinnerVisible", true);
        helper.updateCloseServiceReason(component, event, helper);
        console.log('TA_LCP199_ButtonSection >> Controller >> handleUpdateCloseServiceReason >> End');
    },

    handleModalManagement : function(component, event, helper) {
        console.log('TA_LCP199_ButtonSection >> Controller >> handleModalManagement >> Start');
        if(event.getParam('type') == 'close') component.set('v.showLCP224BookAppointmentModal', event.getParam('show'));
        console.log('TA_LCP199_ButtonSection >> Controller >> handleModalManagement >> End');
    },

    handleManageInfoModalClose : function(component, event, helper) {
        console.log('TA_LCP199_ButtonSection >> Controller >> handleManageInfoModalClose >> Start');
        location.reload();
        console.log('TA_LCP199_ButtonSection >> Controller >> handleManageInfoModalClose >> End');
    },

    handleManageNoMatchAssetModal : function(component, event, helper) {
        console.log('TA_LCP199_ButtonSection >> Controller >> handleManageNoMatchAssetModal >> Start');
        let buttonName = event.getSource().get('v.name');
        if(buttonName == 'button-yes') {
            helper.showNoMatchAssetModal(component);
        } else if(buttonName == 'button-no') {
            helper.closeServiceAppointment(component);
        }
        console.log('TA_LCP199_ButtonSection >> Controller >> handleManageNoMatchAssetModal >> End');
    },

    handleManageCloseModal : function(component, event, helper) {
        console.log('TA_LCP199_ButtonSection >> Controller >> handleManageCloseModal >> Start');
        component.set('v.' + event.currentTarget.name, false);
        if(event.currentTarget.name == 'showNoMatchAssetModal') {
            let fireRefreshEvt = $A.get("e.c:TA_LCE224_Refresh");
            fireRefreshEvt.setParam('action', 'question-answer-blank')
            fireRefreshEvt.fire();
        }
        console.log('TA_LCP199_ButtonSection >> Controller >> handleManageCloseModal >> End');
    },

    handlePrepareNextCartStep : function(component, event, helper) {
        console.log('TA_LCP199_ButtonSection >> Controller >> handlePrepareNextCartStep >> Start');
        if(event.getParam('handlerCmpName') == 'TA_LCP199_ButtonSection') {
            if(event.getParam('actionName') == 'goToQuoteSummary') {
                helper.goToQuoteSummary(component, event, helper);
            } else {
                helper.prepareNextCartStep(component, event, helper);
            }
        }
        console.log('TA_LCP199_ButtonSection >> Controller >> handlePrepareNextCartStep >> End');
    },

    handleQuoteSummaryCallback : function(component, event, helper) {
        console.log('TA_LCP199_ButtonSection >> Controller >> handleQuoteSummaryCallback >> Start');
        if(event.getParam('handlerCmpName') == 'TA_LCP199_ButtonSection') {
            let evtParams = event.getParams();
            helper[evtParams.action](component, event, helper, evtParams.params);
        }
        console.log('TA_LCP199_ButtonSection >> Controller >> handleQuoteSummaryCallback >> End');
    },

    handleSuspendVisit : function(component, event, helper) {
        console.log('TA_LCP199_ButtonSection >> Controller >> handleSuspendVisit >> Start');
        helper.suspendVisit(component, event, helper);
        console.log('TA_LCP199_ButtonSection >> Controller >> handleSuspendVisit >> End');
    },

    handleManageCloseSuspendVisitModal : function(component, event, helper) {
        console.log('TA_LCP199_ButtonSection >> Controller >> handleManageCloseSuspendVisitModal >> Start');
        helper.manageSuspendVisitModal(component, event, helper);
        console.log('TA_LCP199_ButtonSection >> Controller >> handleManageCloseSuspendVisitModal >> End');
    },

    //START - [20220627AL] - NR2330
    handleHideTechnicalAssetModal : function(component, event, helper) {
        component.set('v.showTechnicalAssetModal', false);
    },

    handleTechnicalAssetSelected : function(component, event, helper) {
        let technicalAssetWrapper = component.get('v.technicalAssetWrapper');
        if(technicalAssetWrapper.technicalAsset != null) technicalAssetWrapper.technicalAsset.value = event.getParam('value');
        else technicalAssetWrapper.technicalAsset = { value: event.getParam('value') };
        component.set('v.technicalAssetWrapper', technicalAssetWrapper);
    },

    handleTechnicalAssetValueChanged : function(component, event, helper) {
        console.log('TA_LCP199_ButtonSection >> Controller >> handleTechnicalAssetValueChanged >> Start');
        let apiName, objectLookup, objectName;
        if(event.getSource().get("v.name") == 'declared-date') {
            objectName = 'WorkOrder';
            objectLookup = 'Id';
            apiName = component.get('v.technicalAssetWrapper').type == 'suspend' ? 'XC_SuspensionDateTimeDeclared__c' : 'XC_ClosedDateDeclared__c';
        } else {
            objectName = 'Case';
            objectLookup = 'CaseId';
            apiName = 'XC_TechnicalAsset__c';
        }

        let updateFieldsEvt = $A.get("e.c:TA_LCE214_UpdateFields");
        updateFieldsEvt.setParams({
            "cmpName" : 'TA_LCP199_ButtonSection' + '-' + component.getGlobalId(),
            "objectName" : objectName,
            "objectLookup" : objectLookup,
            "fields" : [{
                'apiName': apiName,
                'value': event.getParam('value'),
                'type': 'DATETIME'
            }]
        });
        updateFieldsEvt.fire();
        console.log('TA_LCP199_ButtonSection >> Controller >> handleTechnicalAssetValueChanged >> End');
    },

    handleTechnicalAssetContinue : function(component, event, helper) {
        console.log('TA_LCP199_ButtonSection >> Controller >> handleTechnicalAssetContinue >> Start');

        if(component.get('v.technicalAssetWrapper').type == 'suspend') {
            let updateFieldsEvtWorkOrder = $A.get("e.c:TA_LCE214_UpdateFields");
            updateFieldsEvtWorkOrder.setParams({
                "cmpName" : 'TA_LCP199_ButtonSection-WorkOrder',
                "objectName" : 'WorkOrder',
                "objectLookup" : 'Id',
                "fields" : [{
                    'apiName': 'AssetId',
                    'value': component.get('v.technicalAssetWrapper').technicalAsset.value,
                    'type': 'STRING'
                }
            ]
            });
            updateFieldsEvtWorkOrder.fire();
    
            let updateFieldsEvtCase = $A.get("e.c:TA_LCE214_UpdateFields");
            updateFieldsEvtCase.setParams({
                "cmpName" : 'TA_LCP199_ButtonSection-Case',
                "objectName" : 'Case',
                "objectLookup" : 'CaseId',
                "fields" : [{
                    'apiName': 'XC_DateCaseSuspended__c',
                    'value': component.get('v.technicalAssetWrapper').dateDeclared,
                    'type': 'DATETIME'
                }
            ]
            });
            updateFieldsEvtCase.fire();
        } else {
            let updateFieldsEvt = $A.get("e.c:TA_LCE214_UpdateFields");
            updateFieldsEvt.setParams({
                "cmpName" : 'TA_LCP199_ButtonSection' + '-' + component.getGlobalId(),
                "objectName" : 'WorkOrder',
                "objectLookup" : 'Id',
                "fields" : [{
                    'apiName': 'XC_ClosedDateDeclared__c',
                    'value': component.get('v.technicalAssetWrapper').dateDeclared,
                    'type': 'DATETIME'
                },
                {
                    'apiName': 'AssetId',
                    'value': component.get('v.technicalAssetWrapper').technicalAsset.value,
                    'type': 'STRING'
                }
            ]
            });
            updateFieldsEvt.fire();
        }

        helper.technicalAssetContinue(component);
        console.log('TA_LCP199_ButtonSection >> Controller >> handleTechnicalAssetContinue >> End');
    }
    //END - [20220627AL] - NR2330
})