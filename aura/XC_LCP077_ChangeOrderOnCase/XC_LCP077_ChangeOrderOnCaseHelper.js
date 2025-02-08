({
    prepopulateSubtype: function (component, event, helper) {
        component.set("v.secondSpinner", true);
        let myPageRef = component.get("v.pageReference");
        if (myPageRef) {
            component.set("v.recordId", myPageRef.state.c__recordId);
            component.set("v.oldTab", myPageRef.state.c__oldTab);
        }

        let workspaceAPI = component.find("workspace");
        workspaceAPI.focusTab().then(function (response) {

            workspaceAPI.setTabLabel({
                tabId: response.tabId,
                label:  $A.get('{!$Label.c.XC_CL_ChangeOrderTabTitle}')
            }); //' Change Order'
            workspaceAPI.setTabIcon({
                tabId: response.tabId,
                icon: 'utility:case'
            });
        });

        let action = component.get("c.populateSubtype");
        action.setParams({
            'recordId': component.get("v.recordId"),
            'operationType': 'ChangeOrder'
        });
        action.setCallback(this, function (a) {
            let state = a.getState();
            if (state === "SUCCESS") {
                let result = a.getReturnValue();
                console.log('result=' + result.success);
                let objInfo = [];
                if (result.success) {
                    console.log('result populateSubtype FROM metad = ' + result.resultMessage);
                    console.log('init disconnect > result objectInfo ='+result.objectInfo);
                    component.set("v.subtype", result.resultMessage);
                    if(result.objectInfo){
                        objInfo = JSON.parse(result.objectInfo);
                        component.set("v.purchOptionValue", objInfo['purchOptionValue']);
                        component.set("v.isOptionvalid", objInfo['isOptionvalid']);
                        component.set("v.skipOrderCreation", objInfo['skipOrderCreation']);
                        component.set("v.contractNumber", objInfo['contractNumber']);
                        component.set("v.contrStartD", objInfo['contrStartD']);
                        component.set("v.contrEndD", objInfo['contrEndD']);
                        component.set("v.legalText", objInfo['legalText']);
                        component.set("v.showLegalText", objInfo['showLegalText']);
                        component.set("v.assetId", objInfo['assetId']);
                    }
                    if (result.resultMessage === $A.get('{!$Label.c.XC_CL_ChangeOfOwnership}')) {
                        component.set("v.isReadOnly", true);
                        component.set("v.disabledSubmit", false);
                    } else {
                        component.set("v.isReadOnly", false);
                        component.set("v.disabledSubmit", false);
                    }

                    component.set("v.disegnPick", true);
                    if (component.find("XC_Subtype__c")) {
                        component.find("XC_Subtype__c").set("v.value", result.resultMessage);
                    }
                    let message = '';
                    if (result.resultMessage === undefined || result.resultMessage === null || result.resultMessage === '') {
                        message = $A.get('{!$Label.c.XC_CL_NoPerformChangeOrMess}');
                    }
                    if (message !== '') {
                        helper.showToast(component, message, 'error');
                        helper.closeDisconnectTab(component);
                    }
                } else {
                    helper.showToast(component, result.resultMessage, 'error');
                    helper.closeDisconnectTab(component);
                }
            }
            component.set("v.secondSpinner", false);
        });
        $A.enqueueAction(action);

    },

    closeDisconnectTab: function (component) {
        let workspaceAPI = component.find("workspace");
        let navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId"),
            "slideDevName": "detail"
        });
        navEvt.fire();
        workspaceAPI.getFocusedTabInfo().then(function (response) {
            let focusedTabId = response.tabId;
            workspaceAPI.closeTab({
                tabId: focusedTabId
            });
        })
    },

    disconnect: function (component, event, helper) {


        console.log('recordId passato = ' + component.get("v.recordId"));
        let subtype = component.find("subtype").get("v.value");
        console.log('-------->' + subtype);
        let action = component.get("c.changeOrderAssetFromCase");
        let workspaceAPI = component.find("workspace");
        let skipOrderCreation = component.get("v.skipOrderCreation");

        action.setParams({
            'recordId': component.get("v.recordId"),
            'subtype': subtype,
            'skipOrderCreation': skipOrderCreation
        });
        action.setCallback(this, function (a) {
            let state = a.getState();
            if (state === "SUCCESS") {
                let result = a.getReturnValue();
                console.log('result=' + result.success);
                if (result.success) {
                    if(skipOrderCreation){
                        helper.showToast(component, result.resultMessage, 'success');
                        setTimeout(function () {
                            workspaceAPI.closeTab({
                                tabId: component.get("v.oldTab")
                            });
                        }, 500);
                    } else {
                        let spinner = component.find("mySpinner");
                        $A.util.toggleClass(spinner, "slds-hide");

                        let navService = component.find("navService");
                        let pageReference2 = {
                            "type": "standard__recordPage",
                            "attributes": {
                                "recordId": result.recordId,
                                "objectApiName": "NE__Order__c",
                                "actionName": "view"
                            }
                        };

                        setTimeout(function () {
                            workspaceAPI.getFocusedTabInfo().then(function (response) {

                                // 03/12/2021 - Avoid double tab to handle Bit2Win order item duplication problem
                                /* workspaceAPI.openTab({
                                    pageReference: pageReference2,
                                    focus: true
                                }).then(function (response) { */
                                    workspaceAPI.closeTab({
                                        tabId: component.get("v.oldTab")
                                    });

                                // });
                            });
                        }, 1100);

                        navService.navigate(pageReference2);
                    }
                } else {
                    console.log('result error=' + result.resultMessage);
                    helper.showToast(component, result.resultMessage, 'error');

                    let navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": component.get("v.recordId"),
                        "slideDevName": "detail"
                    });
                    navEvt.fire();
                    workspaceAPI.getFocusedTabInfo().then(function (response) {
                        let focusedTabId = response.tabId;
                        workspaceAPI.closeTab({
                            tabId: focusedTabId
                        });
                    })
                }
            }
            component.set("v.secondSpinner", false);
        });
        $A.enqueueAction(action);
    },

    showToast: function (component, message, type) {
        component.find('notifLib').showToast({
            "title": message,
            "message": '',
            "variant": type
        });
    },

    callLegalText: function(component, event, helper){
        let caseId = component.get("v.recordId"); //{!Case.Id}
        let assetId = component.get("v.assetId"); //{!Case.AssetId}
        let url = '/apex/APXTConga4__Conga_Composer?serverUrl={!API.Partner_Server_URL_370}'+
        '&id='+caseId+
        '&QueryID='+$A.get('{!$Label.c.XC_CL_QuerySSIILegalText}')+'?pv0='+assetId+','+$A.get('{!$Label.c.XC_CL_QueryOKLegalText}')+
        '?pv0='+assetId+
        '&TemplateID='+$A.get('{!$Label.c.XC_CL_LegalTextTemplate}')+
        '&DS7=3'+
        '&FP0=1'+
        '&AC2=1'+
        '&LG1=Legal+Text'+
        '&AC0=1';

        let navService = component.find("navService");
        let pageReference =
        {
            "type": "standard__webPage",
            "attributes": {
                "url": url
            }
        }
        navService.navigate(pageReference);
    }

})