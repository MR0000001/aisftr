({

    doInit: function (component, event, helper) {
        console.log('@@@ Start status bar');
        let recordId = component.get("v.recordId");
        console.log("recordId " + recordId);
        let number = "";
        component.set("v.caseNumber", "1");
        console.log("component.get(v.caseNumber) " + component.get("v.caseNumber"));
        let action = component.get("c.getCaseInformations");
        action.setParams({
            "recordId": recordId
        });
        action.setCallback(this, function (a) {
            var state = a.getState();
            var result = a.getReturnValue();
            console.log("@@@ State Result : " + state + " And record is: " + recordId);
            console.log("Result---> " + result.isCommunity)
            if (state === 'SUCCESS') {
                component.set("v.showCreateQualityWO", result.check);
                component.set("v.resolutionMap", result.resolutionPicklistMap);
                component.set("v.resultMap", result.resultPicklistMap);
                component.set("v.complaintRTCase", result.complaintRTCase);
                component.set("v.sameOwner", result.sameOwner);
                component.set("v.caseSubtype", result.caseSubtype);
                component.set("v.community", result.isCommunity);
                component.set("v.communitySpain", result.communitySpain);
                component.set("v.qualityCheckCase", result.qualityCheckCase);
                component.set("v.showCreateRepairWOButton", result.createRepairWO);
            }
        });
        $A.enqueueAction(action);
        //Identify if the case is used for Italy
        console.log('@@@CaseItalyCheck');
        let action2 = component.get("c.checkItaly");
        action2.setParams({
            "recordId": recordId
        });
        action2.setCallback(this, function (a) {
            var state = a.getState();
            var result = a.getReturnValue();
            console.log("@@@ Result : " + result + " And record is: " + recordId);
            if (state === 'SUCCESS') {
                component.set("v.isB2BGItaly", result);
            }
        });
        $A.enqueueAction(action2);
    },

    doInitUpdate: function (component, event, helper, eventhandle) {
        console.log('@@@ Start status bar');
        let recordId = component.get("v.recordId");
        console.log("recordId " + recordId);
        let number = "";
        component.set("v.caseNumber", "1");
        console.log("component.get(v.caseNumber) " + component.get("v.caseNumber"));
        let action = component.get("c.getCaseInformations");
        action.setParams({
            "recordId": recordId
        });
        action.setCallback(this, function (a) {
            var state = a.getState();
            var result = a.getReturnValue();
            console.log("@@@ State Result : " + state + " And record is: " + recordId);
            if (state === 'SUCCESS') {
                component.set("v.showCreateQualityWO", result.check);
                component.set("v.resolutionMap", result.resolutionPicklistMap);
                component.set("v.resultMap", result.resultPicklistMap);
                component.set("v.complaintRTCase", result.complaintRTCase);
                component.set("v.sameOwner", result.sameOwner);
                component.set("v.caseSubtype", result.caseSubtype);
                helper.mangehandler(component, eventhandle, helper);
                console.log("fatto doInit");
            }
        });
        $A.enqueueAction(action);
    },

    mangehandler: function (component, eventhandle, helper) {

        let selectedMenuItemValue = eventhandle;
        if (selectedMenuItemValue === 'suspend') {
            helper.suspend(component, event, helper);
        } else if (selectedMenuItemValue === 'showModal') {
            component.set("v.caseRemarks", '');
            component.set("v.showConfirm", true);
            component.set("v.showFooter", true);
        } else if (selectedMenuItemValue === 'showModalOpportunity') {
            component.set("v.showOpportunity", true);
        } else if (selectedMenuItemValue === 'showModalAttachAssets') {
            component.set("v.showAttachAssets", true);
        } else if (selectedMenuItemValue === 'createQualityWO') {
            component.set("v.showQualityWO", true);
        } else if (selectedMenuItemValue == 'showIndemnification') {
            if (component.get("v.sameOwner") && component.get("v.caseSubtype").length !== 0) {

                component.set("v.showIndemnification", true);
            } else {
                helper.errorIndemnification(component, event, helper);

            }
        } else if (selectedMenuItemValue == 'newCase') {
            helper.createNewCase(component, event, helper);
        } else if (selectedMenuItemValue == 'backCompliance') {
            helper.backCompliance(component, event, helper);
        } else if (selectedMenuItemValue == 'documentVerification') {
            helper.docVerification(component, event, helper);
            console.log("END docVerification");
        } else if (selectedMenuItemValue == 'recalculateUrgency') {
            helper.recUrgency(component, event, helper);
        } else if (selectedMenuItemValue == 'suspendAction') {
            helper.suspendAction(component, event, helper);
        } else if (selectedMenuItemValue == 'qualityCheck') {
            helper.qualityCheckMethod(component, event, helper);
        } else if (selectedMenuItemValue === 'createRepairWO') {
            component.set("v.showCreateRepairWOComp", true);
        }
    },

    createNewCase: function (component, event, helper) {
        component.set("v.showNewCase", true);
        setTimeout(function () {
            component.set("v.showNewCase", false);
        }, 20000);
        /*
            let navService = component.find("navService");
            let workspaceAPI = component.find("workspace");
            let oldTabId;
            workspaceAPI.getFocusedTabInfo().then(function (response) {
                oldTabId = response.tabId;
            });
            
            let pageReference =
            {
                "type": "standard__component",
                "attributes": {
                    "componentName": "c__XC_LCP120_NewCase"
                },
                "state": {
                    "c__contactId": component.get("v.recordId"),
                    "c__sobjectType": "Case"
                }
            }
    
            navService.navigate(pageReference);  */


    },

    newRequest: function (component, event, helper) {
        let navService = component.find("navService");
        let workspaceAPI = component.find("workspace");
        let oldTabId;
        workspaceAPI.getFocusedTabInfo().then(function (response) {
            oldTabId = response.tabId;
        });
        let pageReference =
        {
            "type": "standard__component",
            "attributes": {
                "componentName": "c__XC_LCP077_ChangeOrderOnCase"
            },
            "state": {
                "c__recordId": component.get("v.recordId"),
                "c__oldTab": oldTabId
            }
        }

        navService.navigate(pageReference);
    },
    checkPossibilityToChangeOrDisconnect: function (component, event, helper) {
        let buttonFrom = event.getSource().get("v.label");
        let recordId = component.get("v.recordId");
        let action = component.get("c.checkPrimaryContact");
        action.setParams({
            "caseId": recordId
        });
        action.setCallback(this, function (a) {
            var state = a.getState();
            var result = a.getReturnValue();
            if (state === 'SUCCESS' && result.success) {
                if (buttonFrom == $A.get("$Label.c.XC_CL_CaseChangeOrder")) {
                    //20211118_DD_ERR_02 - start
                    helper.checkSubscriptionAssetHelper(component, event, helper);
                    //helper.newRequest(component, event, helper);
                    //20211118_DD_ERR_02 - end
                } else if (buttonFrom == $A.get("$Label.c.XC_CL_CaseDisconnectAsset")) {
                    if(result.isValid){
                         component.set("v.confirmDisconnectModal", true);
                    }else{
                        helper.disconnect(component, event, helper);
                    }
                }
            } else {
                helper.showToast(component, result.resultMessage, 'error');
            }
        });
        $A.enqueueAction(action);

    },

    
    //20211118_DD_ERR_02 - start
    checkSubscriptionAssetHelper: function (component, event, helper) {
        let recordId = component.get("v.recordId");
        let action = component.get("c.checkSubscriptionAsset");
        action.setParams({
            "caseId": recordId
        });
        action.setCallback(this, function (a) {
            var state = a.getState();
            var result = a.getReturnValue();
            if (state === 'SUCCESS' && result.success) {
                helper.newRequest(component, event, helper);
            } else {
                helper.showToast(component, result.resultMessage, 'error');
            }
        });
        $A.enqueueAction(action);

    },
    //20211118_DD_ERR_02 - end
    

    disconnect: function (component, event, helper) {
        let navService = component.find("navService");
        let workspaceAPI = component.find("workspace");
        let oldTabId;
        workspaceAPI.getFocusedTabInfo().then(function (response) {
            oldTabId = response.tabId;
        });
        let pageReference =
        {
            "type": "standard__component",
            "attributes": {
                "componentName": "c__XC_LCP075_DisconnectAssetFromCase"
            },
            "state": {
                "c__recordId": component.get("v.recordId"),
                "c__oldTab": oldTabId,
                "c__title": "Disconnect"
            }
        }

        navService.navigate(pageReference);



    },

    newCompl: function (component, event, helper) {
        component.set("v.impFirst", true);
        let caseNumber;
        let actionAsset = component.get('c.createCase');
        let recordId = component.get("v.recordId");
        console.log("recordId " + recordId);
        actionAsset.setParams({
            recordId: recordId
        });
        actionAsset.setCallback(this, function (response) {
            let state = response.getState();
            if (state = "SUCCESS") {
                let result = response.getReturnValue();
                if (result.success) {
                    caseNumber = result.objectInfo;
                    //console.log('asset callback' + response.getReturnValue());
                    console.log('New Insistence Case Number=' + caseNumber);
                    component.set("v.caseNumber", caseNumber);
                    console.log("component.get(v.caseNumber) " + component.get("v.caseNumber"));
                    //let a = component.get('c.openModel');
                    //$A.enqueueAction(a);

                    let okMess = $A.get("$Label.c.XC_CL_CreateComplaintCase") + ' ' + caseNumber;
                    helper.showToast(component, okMess, "success");
                    $A.get('e.force:refreshView').fire();
                }
                else {
                    helper.showToast(component, result.resultMessage, "error");
                }

                component.set("v.impFirst", false);

            } else {
                helper.showToast(component, $A.get("$Label.c.XC_CL_CreateCaseMessageError"), "error");
            }
        });

        $A.enqueueAction(actionAsset);
    },

    openModel: function (component) {
        // for Display Model,set the "isOpen" attribute to "true"
        component.set("v.isOpen", true);
    },
    closeModel: function (component) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
        component.set("v.isOpen", false);
    },
    refreshModel: function (component) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
        component.set("v.isOpen", false);

        $A.get('e.force:refreshView').fire();
    },

    handleSecondaryButtonClick: function (component, event, helper) {
        component.set("v.showFooter", true);
        component.set("v.caseRemarks", '');
        component.set("v.showConfirm", false);
        component.set("v.showTextArea", false);
        component.set("v.showOpportunity", false);
        component.set("v.showAttachAssets", false);
        component.set("v.showIndemnification", false);
        $A.get('e.force:refreshView').fire();
    },

    showToast: function (component, message, type) {
        component.find('notifLib').showToast({
            "title": message,
            "message": '',
            "variant": type
        });
    },
    suspend: function (component, event, helper) {

        let action = component.get("c.getSwitchUtil");
        action.setParams({
            'recordId': component.get("v.recordId")
        });
        action.setCallback(this, function (a) {
            let state = a.getState();
            if (state === "SUCCESS") {
                let result = a.getReturnValue();
                console.log('result=' + result.success);
                let spinner = component.find("mySpinner");
                $A.util.toggleClass(spinner, "slds-hide");
                if (result.success) {
                    helper.showToast(component, result.resultMessage, 'success');
                } else {
                    console.log('result error=' + result.resultMessage);
                    helper.showToast(component, result.resultMessage, 'error');
                }
                $A.get("e.force:closeQuickAction").fire();
                $A.get("e.force:refreshView").fire();
            }
        });
        $A.enqueueAction(action);
    },

    cancelCase: function (component, event, helper) {
        component.set("v.impFirst2", true);
        let cancelValuesMap = component.get("v.cancelValuesMap");
        let action = component.get("c.setCaseStatusCancel");
        console.log("cancelValuesMap " + JSON.stringify(cancelValuesMap));
        action.setParams({
            'recordId': component.get("v.recordId"),
            'cancelValues': JSON.stringify(cancelValuesMap)
        });
        action.setCallback(this, function (a) {
            let state = a.getState();
            if (state === "SUCCESS") {
                let result = a.getReturnValue();

                if (result.success) {
                    helper.showToast(component, 'Case correctly cancelled', 'success');
                } else {

                    helper.showToast(component, 'error: ' + result.resultMessage, 'error');
                }

                $A.get("e.force:refreshView").fire();

                component.set("v.showTextArea", false);
                component.set("v.impFirst2", false);
                component.set("v.showConfirm", false);

            }
        });
        $A.enqueueAction(action);


    },
    docVerification: function (component, event, helper) {
        console.log("START docVerification");
        component.set("v.impFirst", true);
        console.log("START DOCUMENT VERIFICATION");
        let recordId = component.get("v.recordId");
        console.log("GET RECORD ID" + recordId);
        let action = component.get("c.documentVerification");
        console.log("CALLED APEX CLASS");
        action.setParams({
            "recordId": recordId
        });
        console.log("SET PARAMS");
        action.setCallback(this, function (a) {
            console.log("SETCALLBACK");
            let result = a.getReturnValue();
            console.log("@@@ Result is: " + result.success + " And record is: " + recordId);
            if (result.success) {
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: $A.get("$Label.XC_CL_Warning"),
                    mode: 'dismissible',
                    mode: 'pester',
                    key: 'info_alt',
                    type: 'success',
                    message: result.message
                });
                $A.get('e.force:refreshView').fire();
                component.set("v.impFirst", false);
                toastEvent.fire();
            } else {
                let toastEventWarn = $A.get("e.force:showToast");
                toastEventWarn.setParams({
                    title: $A.get("$Label.XC_CL_Warning"),
                    mode: 'dismissible',
                    mode: 'pester',
                    key: 'info_alt',
                    type: 'error',
                    message: result.message
                });
                //$A.get('e.force:closeQuickAction').fire();
                component.set("v.impFirst", false);
                toastEventWarn.fire();
            }
            console.log("END");
        });
        $A.enqueueAction(action);
        console.log("END docVerification");
    },

    recUrgency: function (component, event, helper) {
        component.set("v.impFirst", true);
        let action = component.get("c.createWorkOrder");
        action.setParams({
            "caseId": component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
        	let result = response.getReturnValue();
            let state = response.getState();
            if(result.success && state === "SUCCESS") {
                let actionUpdateWo = component.get("c.updateStatus");
                actionUpdateWo.setParams({
                    "recordId": result.woId
                });
                actionUpdateWo.setCallback(this, function (responseWo) {
                    component.set("v.spinnerControl", false);
                    let resultCreateWo = responseWo.getReturnValue();
                    let stateCreateWo = responseWo.getState();
                    let toastEvent = $A.get("e.force:showToast");
                    //$A.get('e.force:refreshView').fire();
                    if(resultCreateWo.success && stateCreateWo === "SUCCESS") {
                        toastEvent.setParams({
                            title: $A.get("$Label.c.XC_CL_Success"),
                            message: resultCreateWo.resultMessage,
                            key: 'info_alt',
                            type: 'success'
                        });
                        component.set("v.impFirst", false);
                        toastEvent.fire();
                    }
                    else {
                        toastEvent.setParams({
                            title: $A.get("$Label.c.XC_CL_WorkOrder_Error"),
                            message: resultCreateWo.resultMessage,
                            key: 'info_alt',
                            type: 'error'
                        });
                        component.set("v.impFirst", false);
                        toastEvent.fire();
                    }
                });
                $A.enqueueAction(actionUpdateWo);
            }
        	else {
                component.set("v.spinnerControl", false);
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: $A.get("$Label.c.XC_CL_WorkOrder_Error"),
                    message: result.resultMessage,
                    key: 'info_alt',
                    type: 'error'
                });
                component.set("v.impFirst", false);
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
        /*let action = component.get("c.updateStatus");
        action.setParams({
            "recordId": component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            let result = response.getReturnValue();
            let state = response.getState();
            if(result.success && state === "SUCCESS") {
                let actionCreateWo = component.get("c.createWorkOrder");
                actionCreateWo.setParams({
                    "cs": result.cs
                });
                actionCreateWo.setCallback(this, function (responseWo) {
                    component.set("v.spinnerControl", false);
                    let resultCreateWo = responseWo.getReturnValue();
                    let stateCreateWo = responseWo.getState();
                    let toastEvent = $A.get("e.force:showToast");
                    //$A.get('e.force:refreshView').fire();
                    if(resultCreateWo.success && stateCreateWo === "SUCCESS") {
                        toastEvent.setParams({
                            title: $A.get("$Label.c.XC_CL_Success"),
                            message: resultCreateWo.resultMessage,
                            key: 'info_alt',
                            type: 'success'
                        });
                        component.set("v.impFirst", false);
                        toastEvent.fire();
                    }
                    else {
                        toastEvent.setParams({
                            title: $A.get("$Label.c.XC_CL_WorkOrder_Error"),
                            message: resultCreateWo.resultMessage,
                            key: 'info_alt',
                            type: 'error'
                        });
                        component.set("v.impFirst", false);
                        toastEvent.fire();
                    }
                });
                $A.enqueueAction(actionCreateWo);
            }
            else {
                component.set("v.spinnerControl", false);
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: $A.get("$Label.c.XC_CL_WorkOrder_Error"),
                    message: result.resultMessage,
                    key: 'info_alt',
                    type: 'error'
                });
                component.set("v.impFirst", false);
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);*/
    },

    backCompliance: function (component, event, helper) {
        console.log("START backCompliance");
        component.set("v.impFirst", true);
        let recordId = component.get("v.recordId");
        let action = component.get("c.backCompliance");

        action.setParams({
            "recordId": recordId
        });

        action.setCallback(this, function (a) {

            let result = a.getReturnValue();
            console.log("@@@ Result is: " + result.success + " And record is: " + recordId);

            if (result.success) {
                component.set("v.spinnerControl", false);
                $A.get('e.force:closeQuickAction').fire();
                $A.get('e.force:refreshView').fire();

                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: $A.get("$Label.XC_CL_Warning"),
                    mode: 'dismissible',
                    mode: 'pester',
                    key: 'info_alt',
                    type: 'success',
                    message: result.message
                });
                component.set("v.impFirst", false);
                toastEvent.fire();
            } else {
                let toastEventWarn = $A.get("e.force:showToast");
                toastEventWarn.setParams({
                    title: $A.get("$Label.XC_CL_Warning"),
                    mode: 'dismissible',
                    mode: 'pester',
                    key: 'info_alt',
                    type: 'error',
                    message: result.message
                });
                component.set("v.impFirst", false);
                toastEventWarn.fire();

                $A.get('e.force:closeQuickAction').fire();
            }

        });
        $A.enqueueAction(action);
        console.log("END backCompliance");
    },

    suspendAction: function (component, event, helper) {
        component.set("v.impFirst", true);
        let recordId = component.get("v.recordId");
        var action = component.get("c.suspendActionAsset");
        action.setParams({
            "recordId": recordId
        });
        action.setCallback(this, function (response) {
            let result = response.getReturnValue();
            let state = response.getState();
            let toastEvent = $A.get("e.force:showToast");
            $A.get('e.force:refreshView').fire();
            if (result.success && state === "SUCCESS") {
                toastEvent.setParams({
                    title: $A.get("$Label.c.XC_CL_Success"),
                    message: $A.get("$Label.c.XC_CL_Success"),
                    key: 'info_alt',
                    type: 'success'
                });

            } else {
                toastEvent.setParams({
                    title: $A.get("$Label.c.XC_CL_WorkOrder_Error"),
                    message: result.resultMessage ? result.resultMessage : $A.get("$Label.c.XC_CL_WorkOrder_Error"),
                    key: 'info_alt',
                    type: 'error'
                });
            }
            component.set("v.impFirst", false);
            toastEvent.fire();
        });
        $A.enqueueAction(action);
    },

    errorIndemnification: function (component, event, helper) {
        let label;
        if (component.get("v.sameOwner") == false) {
            label = $A.get("$Label.c.XC_CL_IndemnificationNotPossible");
        } else {
            label = $A.get("$Label.c.XC_CL_IndemnificationNotPossibleSubtype");
        }
        helper.showToast(component, label, 'error');
    },

    qualityCheckMethod: function (component, event, helper) {
        component.set("v.impFirst", true);
        let recordId = component.get("v.recordId");
        var action = component.get("c.qualityCheckUpdate");
        action.setParams({
            "recordId": recordId
        });
        action.setCallback(this, function (response) {
            component.set("v.spinnerControl", false);
            let result = response.getReturnValue();
            let state = response.getState();
            let toastEvent = $A.get("e.force:showToast");
            $A.get('e.force:refreshView').fire();
            if (result.success && state === "SUCCESS") {
                toastEvent.setParams({
                    title: $A.get("$Label.c.XC_CL_Success"),
                    message: 'Success',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                component.set("v.impFirst", false);
                toastEvent.fire();
            }
            else {
                toastEvent.setParams({
                    title: $A.get("$Label.c.XC_CL_WorkOrder_Error"),
                    message: result.resultMessage,
                    key: 'info_alt',
                    type: 'error'
                });
                component.set("v.impFirst", false);
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }
})