/**
  @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
  @date 26/03/2021
  @description XC_AMP_LCP020_SimplifiedSalesHelper - Helper Javascript for AMP_LCP020
*/

({
    doInit : function(component, event, helper) {
        component.set('v.spinnerControl', true);
        let oppId = component.get('v.recordId');
        if(!oppId || oppId==null || oppId==='') {
            component.set('v.message', $A.get("$Label.c.XC_CL_NoOrderFound"));
            component.set('v.showMessage', true);
            component.set('v.spinnerControl', false);
            return;
        } 
        let action = component.get("c.getTemplate");
        action.setParams({
            'oppId': oppId
        });
        action.setCallback(this, function (a) {
            let state = a.getState();
            if(state === "SUCCESS") {
                let result = a.getReturnValue();
                if(!result.success) {
                    component.set('v.message', result.message);
                    component.set('v.showMessage', true);
                } else {
                    component.set('v.showMessage', false);
                    component.set('v.legalEntityUser', result.legalEntityUser);
                    component.set('v.segmentContact', result.segmentUser);
                    component.set('v.mapViewDefinition', result.mapViewDefinition);
                    component.set('v.mapComponentDefinition', result.mapComponentDefinition);
                    component.set('v.checkPointStep', result.checkPointStep);
                    component.set('v.order', result.order);
                    component.set('v.mapComponentDefinitionOtherInformation', result.mapOtherInfoForComponentDefinition);
                    let nameComponent = '';
                    if(result.checkPointStep != null && result.checkPointStep != undefined && result.checkPointStep != '' && result.checkPointStep != 'InitialStep') {
                        nameComponent = result.checkPointStep;
                    }
                    helper.showComponent(component, event, helper, nameComponent);
                }
            }
            else {
                component.set('v.message', JSON.parse(JSON.stringify(a.getError()))[0].message);
                component.set('v.showMessage', true);
            }
            component.set('v.spinnerControl', false);
        });
        $A.enqueueAction(action);
    },

    /*onBackButton : function(component, event, helper) {
        component.set('v.bigSpinnerControl', true);
        let currentStep = component.get('v.currentStep')-1;
        component.set('v.currentStep', currentStep);
        let listStep = component.get('v.listStep');
        if(currentStep != listStep.length-1) {
            component.set('v.labelNextButton', $A.get("$Label.c.XC_CL_NextMess"));
        }
        helper.showComponent(component, event, helper, listStep[currentStep]);
        component.set('v.bigSpinnerControl', false);
    },*/

    onNextButton : function(component, event, helper) {
        component.set('v.bigSpinnerControl', true);
        let validated = component.get('v.currentValidated');
        if(!validated) {
            $A.createComponent("ui:outputText", {
                "value" : $A.get("$Label.c.XC_CL_ErrorNextStep")
            }, 
            function(contentComponent, status, error) {
                if(status === "SUCCESS") {
                    let modalBody = contentComponent;
                    component.find('overlayLib').showCustomModal({
                        header: 'Warning',
                        body: modalBody, 
                        showCloseButton: true,
                        cssClass: "mymodal",
                    });
                } else {
                    throw console.log('Error: ', JSON.parse(JSON.stringify(error)));
                }
                component.set('v.spinnerControl', false);
            }); 
            component.set('v.bigSpinnerControl', false);
            return;
            
        }
        
        var step = component.get('v.step');
        if(step === 'BillingProfileManagement') {
            var actionBillingProfile = component.get("c.createOrSelectBillingProfile");
            var stepDataValues = JSON.parse(component.get("v.stepDataMap"));
            component.set("v.paymentMethodCategory", stepDataValues.paymentMethodCategory);
            actionBillingProfile.setParams({
                "accountId": component.get('v.accountId'),
                "mapValues": component.get('v.stepDataMap')
            });
            actionBillingProfile.setCallback(this, function (response) {
                var state = response.getState();
                var res = response.getReturnValue();
                if (state === "SUCCESS") {
                    if (res.success && res.objectInfo != null && res.objectInfo != '') {
                        var billingProfInfo = JSON.parse(res.objectInfo);
                        var paymentMethod = component.get("v.paymentMethod");
                        var valueMap = res.fieldName3;
                        component.set("v.billingProfileLineItemId", res.recordId);
                        if (paymentMethod === 'Credit Card' || paymentMethod === 'Direct Debt') {
                            helper.createSiaToken(component, event, helper, valueMap, '', res.fieldName2, paymentMethod, res.fieldName, res.recordId);
                        } else {
                            helper.createUnlinkedZuora(component, event, helper, valueMap, res.recordId);
                        }
                    } else if (res.success) {
                        var message = $A.get('{!$Label.c.XC_CL_BillingProfileAssociationOK}');
                        component.set('v.message', message);
                        component.set('v.showMessage', true);
                        component.set('v.bigSpinnerControl', false);
                        helper.updateCheckPoint(component,event,helper);
                    } else {
                        helper.onErrorNextStep(component, event, helper, res.resultMessage);
                        //component.set('v.message', res.resultMessage);
                        //component.set('v.showMessage', true);
                    }
                }
            });
            $A.enqueueAction(actionBillingProfile);
        } else {
            helper.updateCheckPoint(component,event,helper);
        }

        
    },

    createSiaToken: function (component, event, helper, valueMap, paymentMethodId, contactId, paymentMethod, billingProfileId, bpLineItemId) {
        var mapValues = JSON.parse(valueMap);
        var lang = mapValues.lang;
        var action = component.get("c.manageOperationBeforeCallSia");
        action.setParams({
            "contactId": contactId,
            "lang": lang,
            "paymentMethod": paymentMethod,
            "billingProfileId": billingProfileId
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            var res = response.getReturnValue();
            if (state === "SUCCESS") {
                console.log('SIA RESPONSE = ' + JSON.stringify(res));
                if (res.success) {
                    var siaResponse = JSON.parse(res.objectInfo);
                    console.log('SIA RESPONSE = ' + JSON.stringify(siaResponse));
                    var debtorCode = siaResponse.debtorCode;
                    var bpLineItemId = component.get("v.billingProfileLineItemId");
                    //error management
                    if(!debtorCode){
                        let errorMessage = siaResponse.details;
                        let errorCode = siaResponse.code;
                        component.set('v.message', errorMessage);
                        component.set('v.showMessage', true);
                        component.set('v.bigSpinnerControl', false);
                        return;
                    }
                    component.set("v.debtorCode", debtorCode);
                    if (paymentMethod !== 'Credit Card') {
                        helper.createUnlinkedZuora(component, event, helper, valueMap, bpLineItemId);
                    } else {
                        var oppId = component.get('v.recordId');
                        var accountId = component.get('v.accountId');
                        helper.associateBillingProfile(component, event, helper, accountId, bpLineItemId, oppId ,paymentMethod);
                    }
                } else {
                    var message = res.resultMessage;
                    component.set('v.message', message);
                    component.set('v.showMessage', true);
                    component.set('v.bigSpinnerControl', false);
                }
            } else {
                let msg = response.getError()[0].message;
                component.set('v.message', msg);
                component.set('v.showMessage', true);
                component.set('v.bigSpinnerControl', false);
            }
        });
        $A.enqueueAction(action);
        component.set('v.bigSpinnerControl', false);
    },

    createUnlinkedZuora: function (component, event, helper, valueMap, bpliId) {
        var mapValues = JSON.parse(valueMap);
        var billTo = JSON.stringify(mapValues.billTo);
        var soldTo = JSON.stringify(mapValues.soldTo);
        var account = JSON.stringify(mapValues.account);
        var action = component.get("c.prepareForCreateUnlinkedZuoraAccount");
        var billingProfileLineItemId = bpliId;
        action.setParams({
            "optionsMap": valueMap,
            "account": account,
            "billTo": billTo,
            "soldTo": soldTo,
            "billingProfileLineItemId" : bpliId
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            var res = JSON.parse(response.getReturnValue());
            if (state === "SUCCESS") {
                console.log("RESPOSNE createUnlinkedZuora" + JSON.stringify(res.integrationLog))
                let logs = [res.integrationLog];
                if (res.success == "true") {
                    var message = 'accountId: ' + res.accountId + '\n';
                    message += 'accountNumber: ' + res.accountNumber + '\n';
                    var paymentMethod = component.get("v.paymentMethod");                   
                    if (paymentMethod != 'Credit Card') {
                        var entityName = mapValues.entityName;
                        helper.createPaymentMethod(component, event, helper, valueMap, res.accountId, entityName, bpliId);
                    } else {
                        let oppId = component.get('v.recordId');
                        helper.associateBillingProfile(component, event, helper, res.accountId, bpliId, oppId ,paymentMethod);
                    }
                } else {
                    var message = $A.get('$Label.c.XC_CL_LCP116_Errors_Occured_P1') + '\n';
                    for (var i = 0; i < res.reasons.length; i++) {
                        message += res.reasons[i].message + '\n';
                    }
                    message += $A.get('$Label.c.XC_CL_LCP116_Errors_Occured_P2');
                    component.set('v.message', message);
                    component.set('v.showMessage', true);
                    component.set('v.bigSpinnerControl', false);
                }
                helper.saveIntegrationLog(component,event,helper,logs);
            }
        });
        $A.enqueueAction(action);
    },

    updateCheckPoint : function(component, event, helper) { 
        let numberStep = component.get('v.listStep').length;
        let currentStep = component.get('v.currentStep')+1;
        component.set('v.currentStep', currentStep);
        let listStep = component.get('v.listStep');
        if(currentStep == listStep.length-1) {
            component.set('v.labelNextButton', $A.get("$Label.c.XC_CL_StartProvisioning"));
        }

        let checkP;
        if(currentStep < listStep.length-1) {
            checkP = listStep[currentStep-1];
        } else {
            checkP = listStep[listStep.length-1];
        }
        let action = component.get("c.updateCheckPoint");
        action.setParams({
            'orderId': component.get('v.order').Id,
            'checkpoint': checkP
        });
        action.setCallback(this, function (a) {
            let state = a.getState();
            if(state === "SUCCESS") {
                let result = a.getReturnValue();
                if(!result.success) {
                    component.set('v.message', result.message);
                    component.set('v.showMessage', true);
                } else {
                    if(numberStep == currentStep) {
                        // Start Provisioning
                        component.set('v.message', $A.get("$Label.c.XC_CL_Loading"));
                        component.set('v.showMessage', true);
                        component.set('v.disabledNextButton', true);
                        //component.set('v.disabledBackButton', true);
                        helper.startProvisioningOrder(component, event, helper, 1);
                    }
                    else {
                        // Next Step            
                        helper.showComponent(component, event, helper, listStep[currentStep]);
                    }
                }
            }
            else {
                component.set('v.message', JSON.parse(JSON.stringify(a.getError()))[0].message);
                component.set('v.showMessage', true);
            }
            component.set('v.bigSpinnerControl', false);
        });
        $A.enqueueAction(action);
    },

    showComponent : function(component, event, helper, nameComponent) {
        component.set('v.spinnerControl', true);
        let mapComponentDefinitionOtherInformation = JSON.parse(JSON.stringify(component.get('v.mapComponentDefinitionOtherInformation')));
        let mapViewDefinition = JSON.parse(JSON.stringify(component.get('v.mapViewDefinition')));
        let mapComponentDefinition = JSON.parse(JSON.stringify(component.get('v.mapComponentDefinition')));
        let listSteps = mapViewDefinition['XC_AvailableNextSteps__c'].split(',');
        let order = component.get('v.order');
        component.set('v.listStep', listSteps);

        if(nameComponent == '' || nameComponent == null || nameComponent == undefined) {
            nameComponent = listSteps[0];
        } else if(listSteps[listSteps.length-1] == nameComponent) {
            component.set('v.labelNextButton', $A.get("$Label.c.XC_CL_StartProvisioning"));
        }
        component.set('v.message', $A.get("$Label.c.XC_CL_Loading"));
        component.set('v.showMessage', true);
        component.set("v.body", []);

        $A.createComponent(
            "c:"+mapComponentDefinition[nameComponent].XC_ComponentName__c, {
                "recordId" : order['NE__OptyId__c'] 
            },
            function (newInp, status, errorMessage) {
                if(status === "SUCCESS") {
                    let body = component.get("v.body");
                    body.push(newInp);
                    component.set("v.body", body);
                    component.set('v.showMessage', false);
                    component.set('v.currentValidated', false);
                    // Manage step:
                    component.set('v.currentStep', listSteps.indexOf(nameComponent));
                    let currentStep = component.get('v.currentStep');
                    if(currentStep == 0) {
                        component.set('v.disabledNextButton', false);
                        //component.set('v.disabledBackButton', true);
                    } else {
                        component.set('v.disabledNextButton', false);
                        //component.set('v.disabledBackButton', false);
                    }
                } else if(status === "INCOMPLETE") {
                    component.set('v.message', 'Error server/Client offline');
                    component.set('v.showMessage', true);
                    component.set('v.disabledNextButton', true);
                } else if(status === "ERROR") {
                    component.set('v.message', errorMessage);
                    component.set('v.showMessage', true);
                    component.set('v.disabledNextButton', true);
                }
            }
        );
        component.set('v.spinnerControl', false);
    },

    handleChildCommunicationEvent : function(component, event, helper){
        let receivedData = event.getParam('data');
        if(receivedData.hasOwnProperty('section') && receivedData['section'] == 'documents' && receivedData['validate'] == true) {
            component.set('v.currentValidated', true);
        } else {
            component.set('v.currentValidated', receivedData['validate']);
            component.set('v.step', receivedData['step']);
            component.set('v.stepDataMap', receivedData['stepDataMap']);
            component.set('v.accountId', receivedData['accountId']);
            component.set('v.paymentMethod', receivedData['paymentMethod']);
        }
    },

    startProvisioningOrder : function(component, event, helper, numberStep) {
        component.set('v.spinnerControl', true);

        let orderId = component.get('v.order').hasOwnProperty('Id') ? component.get('v.order')['Id'] : '';
        if(orderId==null || orderId==undefined || orderId=='') {
            component.set('v.message', $A.get("$Label.c.XC_CL_NoOrderFound"));
            component.set('v.showMessage', true);
            component.set('v.spinnerControl', false);
            return;
        } 
        let action = component.get("c.startProvisioning");
        action.setParams({
            'orderId': orderId,
            'numberStep': numberStep
        });
        action.setCallback(this, function (a) {
            let state = a.getState();
            if(state === "SUCCESS") {
                let result = a.getReturnValue();
                if(!result.success) {
                    component.set('v.message', result.message);
                    component.set('v.showMessage', true);
                } else {
                    if(numberStep == 3) {
                        let toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: "Success",
                            message: $A.get("$Label.c.XC_CL_Provisioning_Started"),
                            key: 'info_alt',
                            type: 'success',
                            mode: 'dismissible',
                            mode: 'pester'
                        });
                        toastEvent.fire();
                    } else {
                        helper.startProvisioningOrder(component, event, helper, numberStep+1);
                    }
                }
            }
            else {
                component.set('v.message', JSON.parse(JSON.stringify(a.getError()))[0].message);
                component.set('v.showMessage', true);
            }
            component.set('v.spinnerControl', false);
        });
        $A.enqueueAction(action);
    },

    saveIntegrationLog : function(component,event,helper,logs){

        return new Promise((resolve,reject)=>{
            let saveLogAction = component.get("c.saveIntegrationLog");
            saveLogAction.setParams({integrationLogList : JSON.stringify(logs)});
            saveLogAction.setCallback(this,function(response){
                if(response.getState()==="SUCCESS"){
                    let result = response.getReturnValue();
                    if(result){
                        resolve(result);
                        console.log('INTEGRATION LOGS SAVED');
                    }else{
                        reject(result);
                        console.log('CANNOT SAVE INTEGRATION LOGS');
                    }
                }else{
                    reject(response.getError()[0]);
                    console.log('CANNOT SAVE LOGS ' + JSON.stringify(response.getError()[0]));
                }
            });
            $A.enqueueAction(saveLogAction);

        });

    },

    createPaymentMethod: function (component, event, helper, valueMap, zuoraAccountId, entityName, bpliId) {
        var mapValues = JSON.parse(valueMap);
        var paymentMethodType = component.get("v.paymentMethod");
        let paymentMethodCategory = component.get("v.paymentMethodCategory");

        console.log('ENTRATO IN CREATePAYMENtMethod con ' + paymentMethodType + "CATEGORY OF MOP::: " + paymentMethodCategory);
        var action;
        //Se si tratta di un pagamento di tipo esterno
        if (paymentMethodCategory === "External") {
            action = component.get("c.linkAccountToExternalPaymentMethod");
            action.setParams({
                "accountId": zuoraAccountId,
                "externalPaymentMethodType": paymentMethodType,
                "entityName": entityName
            });
        } else {
            var paymentMethod = {};
            if (paymentMethodType === 'Direct Debt') {
                paymentMethod = {
                    "AccountId": zuoraAccountId,
                    "Type": "BankTransfer",
                    "BankTransferType": "SEPA",
                    "BankTransferAccountNumber": component.get("v.debtorCode"),
                    "TokenId": component.get("v.debtorCode"),
                    "MandateID": mapValues.sepaMandate,
                    "MandateCreationDate": mapValues.sepaMandateDate, 
                    "IBAN": mapValues.accountNumber,
                    "paymentGateway": "SIA PH SDD"

                }

            }
            var paymentMethodBody = JSON.stringify(paymentMethod);
            action = component.get("c.createPaymentMethod");
            action.setParams({
                "paymentMethod": paymentMethodBody,
                "entityName": entityName,
                "billingProfLineItemId": bpliId
            });
        }

        action.setCallback(this, function (response) {
            var state = response.getState();
            var res = typeof(response.getReturnValue()) === 'object' ? response.getReturnValue() : JSON.parse(response.getReturnValue());
            if (state === "SUCCESS") {
                let logs = [];
                if (paymentMethodCategory === "External") {
                    res.integrationLog['XC_BillingProfileLineItem__c'] = component.get("v.createdBPLIId");
                    logs.push(res.integrationLog);
                    var accountId = component.get('v.accountId');
                    var bpLineItemId = component.get("v.billingProfileLineItemId");
                    let oppId = component.get('v.recordId');
                    helper.associateBillingProfile(component, event, helper, accountId, bpLineItemId, oppId ,paymentMethod);
                } else if (res.Success === "true") {
                    var paymentMethodId = res.Id;
                    console.log('USCITO DA CREATePAYMENtMethod CON PaymentId = ' + res.Id);
                    res.integrationLog['XC_BillingProfileLineItem__c'] = component.get("v.createdBPLIId");
                    logs.push(res.integrationLog);
                    helper.linkPaymentMethodToAccount(component, event, helper, zuoraAccountId, paymentMethodId, entityName);
                } else {
                    var message = $A.get('$Label.c.XC_CL_LCP116_Errors_Occured_P1') + '\n';
                    for (var i = 0; i < res.Errors.length; i++) {
                        message += res.Errors[i].Message + '\n';
                    }
                    res.integrationLog['XC_BillingProfileLineItem__c'] = component.get("v.createdBPLIId");
                    logs.push(res.integrationLog);

                    message += $A.get('$Label.c.XC_CL_LCP116_Errors_Occured_P2');
                    component.set('v.message', message);
                    component.set('v.showMessage', true);
                    component.set('v.bigSpinnerControl', false);

                }
                if(logs.length>0){
                    helper.saveIntegrationLog(component,event,helper,logs);
                }
            }
        });
        $A.enqueueAction(action);
    },

    linkPaymentMethodToAccount: function (component, event, helper, zuoraAccountId, paymentMethodId, entityName) {
        console.log('ENTRATO IN linkPaymentMethodToAccount');
        var action = component.get("c.linkPaymentMethodToAccount");
        action.setParams({
            "zuoraAccountId": zuoraAccountId,
            "paymentMethodId": paymentMethodId,
            "entityName": entityName
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            var res = JSON.parse(response.getReturnValue()); 
            if (state === "SUCCESS") {
                if (res.Success === "true") {
                    message += 'paymentMethodId: ' + paymentMethodId + '\n';
                    var accountId = component.get('v.accountId');
                    var bpLineItemId = component.get("v.billingProfileLineItemId");
                    let oppId = component.get('v.recordId');
                    var paymentMethod = component.get("v.paymentMethod");
                    helper.associateBillingProfile(component, event, helper, accountId, bpLineItemId, oppId ,paymentMethod);
                    console.log('ESCO DA linkPaymentMethodToAccount CON SUCCESS = ' + res.Success);
                } else {
                    var message = $A.get('$Label.c.XC_CL_LCP116_Errors_Occured_P1') + '\n';
                    for (var i = 0; i < res.Errors.length; i++) {
                        message += res.Errors[i].Message + '\n';
                    }
                    message += $A.get('$Label.c.XC_CL_LCP116_Errors_Occured_P2');
                    component.set('v.message', message);
                    component.set('v.showMessage', true);
                    component.set('v.bigSpinnerControl', false);
                }
            }
        });
        $A.enqueueAction(action);
    },

    associateBillingProfile : function(component, event, helper, accountId, billingProfileLineItemId, opportunityId, paymentMethod) {
        console.log('Associate billing profile line item with order');
        var action = component.get("c.associateBillingProfile");
        action.setParams({
            "accountId": accountId,
            "billingProfileLineItemId": billingProfileLineItemId,
            "opportunityId": opportunityId,
            "paymentMethod" : paymentMethod
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            var res = response.getReturnValue();
            if (state === "SUCCESS") {
                if (res.success) {
                    var message = $A.get('{!$Label.c.XC_CL_BillingProfileAssociationOK}');
                    component.set('v.message', message);
                    component.set('v.showMessage', true);
                    helper.updateCheckPoint(component,event,helper);
                } else {
                    helper.onErrorNextStep(component, event, helper, res.resultMessage);
                    //component.set('v.message', res.resultMessage);
                    //component.set('v.showMessage', true);
                }
            }
        });
        $A.enqueueAction(action);
        
        component.set('v.bigSpinnerControl', false);
    },

    onErrorNextStep : function(component, event, helper, value) {
        $A.createComponent("ui:outputText", {
            "value" : value
        }, 
        function(contentComponent, status, error) {
            if(status === "SUCCESS") {
                let modalBody = contentComponent;
                component.find('overlayLib').showCustomModal({
                    header: 'Warning',
                    body: modalBody, 
                    showCloseButton: true,
                    cssClass: "mymodal",
                });
            } else {
                throw console.log('Error: ', JSON.parse(JSON.stringify(error)));
            }
            component.set('v.spinnerControl', false);
        }); 
        component.set('v.bigSpinnerControl', false);
        return;
    }

})