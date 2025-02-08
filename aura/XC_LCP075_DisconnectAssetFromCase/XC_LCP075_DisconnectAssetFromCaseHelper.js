({
    prepopulateSubtype: function (component, event, helper) {
        component.set("v.firstSpinner", true);
        let myPageRef = component.get("v.pageReference");
        if (myPageRef) {
            component.set("v.recordId", myPageRef.state.c__recordId);
            component.set("v.oldTab", myPageRef.state.c__oldTab);
            component.set("v.title", myPageRef.state.c__title);
        }
        let workspaceAPI = component.find("workspace2");
        workspaceAPI.focusTab().then(function (response) {

            workspaceAPI.setTabLabel({
                tabId: response.tabId,
                label: $A.get('{!$Label.c.XC_CL_DisconnectTabTitle}')
            }); //' Disconnect'
            workspaceAPI.setTabIcon({
                tabId: response.tabId,
                icon: 'utility:case'
            });
        });
        let complaintOptions = [ //{label: $A.get('{!$Label.c.XC_CL_ClaimNotApplicable}'), value: 'Claim not applicable'}, 
            {
                label: $A.get('{!$Label.c.XC_CL_ClaimApplicable}'),
                value: 'Claim applicable (service not used)'
            },
            {
                label: $A.get('{!$Label.c.XC_CL_ClaimApplicable2}'),
                value: 'Claim applicable (service used)'
            }
        ];
        component.set("v.complaintOptions", complaintOptions);

        let action = component.get("c.populateSubtype");
        action.setParams({
            'recordId': component.get("v.recordId"),
            'operationType': 'Disconnect'
        });
        action.setCallback(this, function (a) {
            let state = a.getState();
            if (state === "SUCCESS") {
                let result = a.getReturnValue();
                console.log('result=' + result.success);
                let objInfo = [];
                if (result.success) {
                    component.set("v.showScriptComponent", true);
                    console.log('init disconnect > result message=' + result.resultMessage);
                    console.log('init disconnect > result objectInfo =' + result.objectInfo);
                    objInfo = JSON.parse(result.objectInfo);
                    component.set("v.subtype", objInfo['orderSubtype']); //result.resultMessage
                    component.set("v.skipOrderCreation", objInfo['skipOrderCreation']);
                    component.set("v.penaltyValue", objInfo['penaltyValue']);
                    component.set("v.penaltyMessage", objInfo['penaltyMessage']);
                    component.set("v.refundValue", objInfo['refundValue']);
                    component.set("v.contractNumber", objInfo['contractNumber']);
                    component.set("v.contrStartD", objInfo['contrStartD']);
                    component.set("v.contrEndD", objInfo['contrEndD']);
                    component.set("v.legalText", objInfo['legalText']);
                    component.set("v.assetId", objInfo['assetId']);
                    component.set("v.showLegalText", objInfo['showLegalText']);
                    if (objInfo['complaintCalculatedData']) {
                        component.set("v.complaintCalculatedData", JSON.parse(objInfo['complaintCalculatedData']));
                    }
                    //if(result.objectInfo=='Complaint'){
                    if (objInfo['orderSubtype'] === 'Complaint') {
                        component.set("v.disabledSubmit", false);
                        component.set("v.disegnComplaintPick", true);
                        component.set("v.subtype", objInfo['complaintType']);
                        helper.selectComplaintDataByOption(component, event, helper);
                    } else {
                        component.set("v.disegnPick", true);
                        component.set("v.disabledSubmit", false);
                    }
                    if (component.find("XC_Subtype__c")) {
                        component.find("XC_Subtype__c").set("v.value", objInfo['orderSubtype']);
                    }

                    let message = '';
                    if (objInfo['penaltyErrorMessage'] !== undefined && objInfo['penaltyErrorMessage'] !== null && objInfo['penaltyErrorMessage'] !== '') {
                        message = objInfo['penaltyErrorMessage'];
                    } else if (objInfo['orderSubtype'] === undefined || objInfo['orderSubtype'] === null || objInfo['orderSubtype'] === '') {
                        message = $A.get('{!$Label.c.XC_CL_NoPerformDisconnMess}');
                    }
                    if (message !== '') {
                        helper.showToast(component, message, 'error');
                        helper.closeDisconnectTab(component);
                    }
                } else {
                    helper.showToast(component, result.resultMessage, 'error');
                    helper.closeDisconnectTab(component);
                    /*let navEvt = $A.get("e.force:navigateToSObject");
    		 			navEvt.setParams({
     		 			"recordId": component.get("v.recordId"),
      		 			"slideDevName": "detail"
              			});
              			navEvt.fire();
                        workspaceAPI.getFocusedTabInfo().then(function(response) {
						let focusedTabId = response.tabId;
						workspaceAPI.closeTab({tabId: focusedTabId});
						})*/
                }
            }
            component.set("v.firstSpinner", false);
        });
        $A.enqueueAction(action);
    },

    closeDisconnectTab: function (component) {
        let workspaceAPI = component.find("workspace2");
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
        component.set("v.firstSpinner", true);

        //check recording needed
        let action = component.get("c.checkCallRecordingNeeded");
        let caseRecId = component.get("v.recordId");
        action.setParams({caseId : caseRecId});
        action.setCallback(this, function (response) {

            if (response.getState() === "SUCCESS") {
                let result = response.getReturnValue();
                if (result.success) {
                    //let penaltyMess = component.get("v.penaltyMessage");
                    //console.log('disconnect > penaltyMess='+penaltyMess);
                    let penaltyValue = component.get("v.penaltyValue");
                    console.log('disconnect > penaltyValue=' + penaltyValue);
                    //if(penaltyMess !== undefined && penaltyMess !== ''){
                    if (penaltyValue === undefined || penaltyValue === '' || penaltyValue === '0' || penaltyValue === '0.0') {
                        console.log('non ci sono penali procedo con la disconnect');
                        helper.proceedDisconnection(component, event, helper);
                    } else {
                        /*let spinner = component.find("mySpinner");
                        $A.util.toggleClass(spinner, "slds-hide");*/
                        component.set("v.firstSpinner", false);
                        component.set("v.secondSpinner", false);
                        component.set("v.foundPenality", true);
                    }
                    /*let action = component.get("c.checkPenalityBeforeDisconnectCase");
                    action.setParams({
                        'recordId' : component.get("v.recordId")
                    });
                    action.setCallback(this, function(a) {
                        let state = a.getState();
                        if (state === "SUCCESS"){
                            let result = a.getReturnValue();
                            console.log('result='+result.success);
                            if(!result.success){
                                console.log('non ci sono penali procedo con la disconnect');
                                helper.proceedDisconnection(component, event, helper);
                            }else{
                                let spinner = component.find("mySpinner");
                                $A.util.toggleClass(spinner, "slds-hide");
                                component.set("v.penaltyMessage",result.resultMessage);
                                component.set("v.foundPenality",true);
                            }
                        }
                    });            
                    $A.enqueueAction(action);*/
                } else {
                    //phone recording needed
                    helper.showToast(component,result.resultMessage,'error');
                    component.set("v.firstSpinner", false);
                    component.set("v.secondSpinner", false);
                }
            } else {
                console.log('ERROR ON CHECK RECORDING ON DISCONNECT ' + response.getError()[0].message);
            }


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

    proceedDisconnection: function (component, event, helper) {
        let subtype = component.find("subtype").get("v.value");
        let workspaceAPI = component.find("workspace2");
        let skipOrderCreation = component.get("v.skipOrderCreation");
        let action = component.get("c.disconnectAssetFromCase");
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
                    if (skipOrderCreation) {
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

                        this.runSetTimeout(component, workspaceAPI, pageReference2, 1100);
                        navService.navigate(pageReference2);
                    }
                } else {
                    console.log('result error=' + result.resultMessage);
                    helper.showToast(component, result.resultMessage, 'error');
                    helper.navigateAndClose(component, event, helper);
                }
            }
        });
        $A.enqueueAction(action);

    },

    navigateAndClose: function (component, event, helper) {
        let workspaceAPI = component.find("workspace2");

        let pageReference2 = {
            "type": "standard__recordPage",
            "attributes": {
                "recordId": component.get("v.recordId"),
                "objectApiName": "Case",
                "actionName": "view"
            }
        };

        this.runSetTimeout(component, workspaceAPI, pageReference2, 0);
    },

    runSetTimeout: function (component, workspaceAPI, pageReference2, delay) {
        setTimeout(function () {
            workspaceAPI.getFocusedTabInfo().then(function (response) {

                workspaceAPI.openTab({
                    pageReference: pageReference2,
                    focus: true
                }).then(function (response) {
                    workspaceAPI.closeTab({
                        tabId: component.get("v.oldTab")
                    });

                });
            });
        }, delay);
    },

    checkNotBlank: function (component, event, helper) {
        let subtype = component.find("subtype").get("v.value");
        console.log('entro con ' + subtype);
        if (subtype === '' || subtype === undefined) {
            component.set("v.disabledSubmit", true);
        } else {
            component.set("v.disabledSubmit", false);
        }
    },

    selectComplaintDataByOption: function (component, event, helper) {
        let complaintCalculatedData = component.get("v.complaintCalculatedData");
        let subtype = component.find("subtype").get("v.value");
        if (subtype === 'Claim not applicable') {
            component.set("v.penaltyValue", complaintCalculatedData.Penalty);
            component.set("v.refundValue", '0');
        } else if (subtype === 'Claim applicable (service not used)') {
            component.set("v.penaltyValue", '0');
            component.set("v.refundValue", complaintCalculatedData.Refund);

        }
        /*else if(subtype === 'Claim applicable (service used)'){
                    component.set("v.penaltyValue", '0');
                    component.set("v.refundValue", '0');

                }*/
        else {
            component.set("v.penaltyValue", '0');
            component.set("v.refundValue", '0');
        }
    },

    callLegalText: function (component, event, helper) {
        let caseId = component.get("v.recordId"); //{!Case.Id}
        let assetId = component.get("v.assetId"); //{!Case.AssetId}

        let url = '/apex/APXTConga4__Conga_Composer?serverUrl={!API.Partner_Server_URL_370}' +
            '&id=' + caseId +
            '&QueryID=' + $A.get('{!$Label.c.XC_CL_QuerySSIILegalText}') + '?pv0=' + assetId + ',' + $A.get('{!$Label.c.XC_CL_QueryOKLegalText}') +
            '?pv0=' + assetId +
            '&TemplateID=' + $A.get('{!$Label.c.XC_CL_LegalTextTemplate}') +
            '&DS7=3' +
            '&FP0=1' +
            '&AC2=1' +
            '&LG1=Legal+Text' +
            '&AC0=1';

        //component.set("v.congaURL", url);
        //component.set("v.showCongaLegalText", true);

        let navService = component.find("navService");
        let pageReference = {
            "type": "standard__webPage",
            "attributes": {
                "url": url
            }
        }
        navService.navigate(pageReference);
    }
})