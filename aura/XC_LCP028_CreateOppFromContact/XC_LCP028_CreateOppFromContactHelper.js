({
    doInit: function (component, event, helper) {
        console.log("DOINIT CREATE OPTy");
        let action = component.get("c.getVisibleRecordType");
        action.setParams({
            'objectType': component.get("v.objectType"),
            'recordId': component.get('v.recordId')
        });
        action.setCallback(this, function (a) {

            let mapRT = [];
            if (a) {
                console.log("RESULT" + JSON.stringify(a.getReturnValue()));
                let result = a.getReturnValue();
                if (result.length > 1) {
                    for (let i = 0; i < result.length; i++) {

                        mapRT.push(
                            { 'label': result[i].Name, 'value': result[i].Id }
                        );
                    }
                    component.set("v.listRT", mapRT);
                    helper.checkIfPrimary(component, event, helper, false);
                    component.set("v.visibleTo", mapRT);
                    component.set("v.showComponent", true);
                } else if( result.length == 1) {
                    component.set("v.spinner", true);
                    component.set("v.selectedRT", result[0].Id);
                    if (component.get("v.objectType") == 'Opportunity') {
                        helper.checkIfPrimary(component, event, helper, true);
                    }
                    else if (component.get("v.objectType") == 'Lead') {
                        helper.createLead(component, event, helper);
                    }
                } else {
                    component.set("v.spinner", true);
                }
            }
        });
        $A.enqueueAction(action);
    },

    //[R1.1. 2022 - NR2559 - start]
    checkOptyCreation: function(component, event, helper){
        console.log("checkOptyCreation");
        let action = component.get("c.canCreateOpty");
        action.setParams({ 
            'recordId': component.get('v.recordId')
        });
        action.setCallback(this, function (a) {
            if(a){
                let result = a.getReturnValue();
                console.log(result);
                if(result){
                    helper.doInit(component, event, helper);
                } 
            	else{ 
                    let toastEvent = $A.get("e.force:showToast");
                                    toastEvent.setParams({
                                        title: "Error",
                                        message: "Non è possile creare opportunity con questo Account",
                                        key: 'info_alt',
                                        type: 'error',
                                        mode: 'dismissible'
                                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire();
                    component.set("v.showOpportunity", false);
                    component.destroy();
            	}
            }
        });
        $A.enqueueAction(action);
    },
    //[R1.1. 2022 - NR2559 - end]

    createOpp: function (component, event, helper) {
        component.set("v.spinner", true);
        console.log("CreateOPP Helper");
        console.log('serviceid' + component.get("v.serviceId"));//cr 763
        console.log('caseId'+component.get("v.caseId"));//cr 763
        console.log('workOrderId'+component.get("v.workOrderId"));//cr 763
        let recordId = component.get("v.recordId");
        let action = component.get("c.getContactId");
        action.setParams({
            'recordId': recordId,
        });
        action.setCallback(this, function (resp) {
            let state = resp.getState();
            if (state === "SUCCESS") {
                let result = resp.getReturnValue();
                if (result.success) {
                    let contactId = result.recordId;
                    let workOrderId = '';
                    let caseId = '';
                    //start 763
                   if(component.get("v.serviceId")!==''){
                     workOrderId=component.get("v.workOrderId");//cr 763
                     caseId=component.get("v.caseId");//cr 763
                     console.log('caseId'+caseId);//cr 763
                     console.log('workOrderId'+workOrderId);//cr 763
                    }
                // end 763
                    if (result.objectInfo === 'WorkOrder') {
                        workOrderId = recordId;
                    }
                    if (result.objectInfo === 'Case') {
                        caseId = recordId;
                    }
                    let action = component.get("c.getCurrentContactData");
                    action.setParams({
                        'recordId': contactId,
                    });
                    action.setCallback(this, function (a) {
                        let result = a.getReturnValue();
                        if (result) {
                            if(!result.success && result.resultMessage){
                                let toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    title: "Error",
                                    message: result.resultMessage,
                                    key: 'info_alt',
                                    type: 'error',
                                    mode: 'dismissible'
                                });
                                toastEvent.fire();
                                $A.get("e.force:closeQuickAction").fire();
                                component.set("v.showOpportunity", false);
                                component.destroy();
                            } else if (!result.documentExists && !result.isSFMContact) {
                                let toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    title: "Error",
                                    message: $A.get("$Label.c.XC_CL_NoDocForAccountMess"),
                                    key: 'info_alt',
                                    type: 'error',
                                    mode: 'dismissible'
                                });
                                toastEvent.fire();
                                $A.get("e.force:closeQuickAction").fire();
                                component.set("v.showOpportunity", false);
                                component.destroy();
                                //component.find("notifLib").notifyClose();
                            } else {
                                let recordTypeId = component.get("v.selectedRT");
                                console.log('recordTypeId= ' + recordTypeId);
                                let closeDate = result.d;
                                component.set("v.closeDate", closeDate);
                                let accountId;
                                if(result.objectType === 'Account'){
                                    accountId = component.get("v.recordId");
                                }
                                //start 763
                                if(component.get("v.serviceId")!==''){ 
                                    $A.createComponent(
    
                                        "c:XC_LCP052_SelectAvaibleAccountFromIndividual",
                                        {
                                            "forAsset": false,
                                            "forOpportunity": true,
                                            "recordTypeId": recordTypeId,
                                            "recordId": contactId, //component.get("v.recordId"),
                                            "stageName": "Draft",
                                            "closeDate": component.get("v.closeDate"),
                                            "title": $A.get("$Label.c.XC_CL_Contact_ChooseAnAccount"),
                                            "workOrderId": workOrderId,
                                            "caseId": caseId, 
                                            "isSFMObject": result.isSFMContact,
                                            "sourceObjType" : result.objectType,
                                            "accountid" : accountId,
                                            "serviceId" :component.get("v.serviceId") //cr 763
                                            
                                        },
                                        function (newcomponent, status, errorMessage) {
                                            if (status === "SUCCESS") {
    
                                                let body = newcomponent.get("v.body");
                                                body.push(newcomponent);
                                                component.set("v.body", body);
                                            }
                                            else if (status === "INCOMPLETE") {
                                                console.log("No response from server or client is offline.")
                                            }
                                            else if (status === "ERROR") {
                                                console.log("Error: " + errorMessage);
                                            }
                                        })}
                                    else{
                                        $A.createComponent(
    
                                            "c:XC_LCP052_SelectAvaibleAccountFromIndividual",
                                            {
                                                "forAsset": false,
                                                "forOpportunity": true,
                                                "recordTypeId": recordTypeId,
                                                "recordId": contactId, //component.get("v.recordId"),
                                                "stageName": "Draft",
                                                "closeDate": component.get("v.closeDate"),
                                                "title": $A.get("$Label.c.XC_CL_Contact_ChooseAnAccount"),
                                                "workOrderId": workOrderId,
                                                "caseId": caseId, 
                                                "isSFMObject": result.isSFMContact,
                                                "sourceObjType" : result.objectType,
                                                "accountid" : accountId
                                                
                                            },
                                            function (newcomponent, status, errorMessage) {
                                                if (status === "SUCCESS") {
        
                                                    let body = newcomponent.get("v.body");
                                                    body.push(newcomponent);
                                                    component.set("v.body", body);
                                                }
                                                else if (status === "INCOMPLETE") {
                                                    console.log("No response from server or client is offline.")
                                                }
                                                else if (status === "ERROR") {
                                                    console.log("Error: " + errorMessage);
                                                }
                                            })
    
                                    }   
                                    ;
                                    //end cr 763
                            }

                            component.set("v.spinner", false);
                        }
                    });
                    $A.enqueueAction(action);
                } else {
                    helper.closeFunctinality(component, event, helper, result.resultMessage, 'error');
                }
            } else {
                helper.closeFunctinality(component, event, helper, resp.getError(), 'error');
            }
        });
        $A.enqueueAction(action);
    },

    createLead: function (component, event, helper) {
        component.set("v.showComponent", false);
        let recordTypeId = component.get("v.selectedRT");
        let isCommunity = component.get("v.isCommunity");
        $A.createComponent(
            "c:XC_LCP002_NewLead",

            {
                "recordTypeToReturn": recordTypeId,
                "isCommunity": isCommunity
            },
            function (newcomponent, status, errorMessage) {
                if (status === "SUCCESS") {

                    let body = newcomponent.get("v.body");
                    body.push(newcomponent);
                    component.set("v.body", body);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            });
    },

    createAccount: function (component, event, helper) {
        component.set("v.showComponent", false);
        let recordTypeId = component.get("v.selectedRT");
        let isCommunity = component.get("v.isCommunity");
        $A.createComponent(
            "c:XC_LCP003_NewAccount",

            {
                "recordTypeToReturn": recordTypeId,
                "isCommunity": isCommunity
            },
            function (newcomponent, status, errorMessage) {
                if (status === "SUCCESS") {

                    let body = newcomponent.get("v.body");
                    body.push(newcomponent);
                    component.set("v.body", body);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            });
    },

    closeFunctinality: function (component, event, helper, message, typeMessage) {
        component.set("v.spinner", false);
        helper.showToast(component, message, typeMessage);
        $A.get("e.force:closeQuickAction").fire();

        //lancio evento per il close della finestra
        let ev = $A.get("e.c:XC_LCE015_ModalClosed");
        if (ev) {
            ev.setParams({ "modalName": $A.get("$Label.c.XC_CL_CreateOpportunityClosedEvent") });
            ev.fire();
        }
    },

    openAccountInCommunity: function (component, event, helper) {
        let recordTypeId = component.get("v.selectedRT");

        $A.createComponent(
            "c:XC_LCP052_SelectAvaibleAccountFromIndividual",
            {
                "forAsset": false,
                "recordTypeId": recordTypeId,
                "recordId": component.get("v.recordId"),
                "stageName": "Draft",
                "closeDate": component.get("v.closeDate"),
                "title": $A.get("$Label.c.XC_CL_Contact_ChooseAnAccount")
            },
            function (newcomponent, status, errorMessage) {
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    console.log('entrato in openAccountInCommunity');
                    let body = newcomponent.get("v.body");
                    body.push(newcomponent);
                    component.set("v.body", body);


                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.");
                    // Show offline error
                }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                    // Show error message
                }
            }
        );


    },

    openNewObjectPage: function (component, event, helper) {
        let navService = component.find("navService");
        let targetPageReference = component.get("v.targetPageReference");

        navService.navigate(targetPageReference);
    },


    setCurrentRT: function (component, event) {
        let selected = component.get("v.value");
        console.log('selected=' + selected);
        component.set("v.selectedRT", selected);
    },

    showToast: function (component, message, type) {
        component.find('notifLib').showToast({
            "title": message,
            "message": '',
            "variant": type
        });
    },

    checkIfPrimary: function (component, event, helper, createOpp) {
        let recordId = component.get("v.recordId");
        if(recordId == null || recordId == undefined) {
            return;
        }
        var action;
        if (recordId.substring(0, 3) === '001') {
            component.set("v.accountId", recordId);
            if(createOpp){
                helper.createOpp(component, event, helper);
            }else{
                component.set("v.visibleTo", component.get("v.listRT"));
            }
            return;

        }else if (recordId.substring(0, 3) === '500') {
            action = component.get("c.getCurrentContactDataForCase");
        } else {
            action = component.get("c.getCurrentContactData");
        }
        action.setParams({
            'recordId': recordId,
        });
        action.setCallback(this, function (resp) {
            let state = resp.getState();
            let result = resp.getReturnValue();
            if (state === 'SUCCESS') {
                let primary;

                if(result.contact){
                    primary = result.contact.XC_PrimaryContact__c;
                }

                if (primary) {
                    component.set("v.accountId", result.contact.AccountId);
                    if(!result.documentExists && !result.isSFMContact){
                        helper.showToast(component, $A.get('$Label.c.XC_CL_LCP028_Doc_Error'), 'Error');
                        helper.closeFunctinality(component, event, helper, resp.getError(), 'error');
                    }else{
                        if(createOpp){
                            helper.createOpp(component, event, helper);
                        }else{
                            component.set("v.visibleTo", component.get("v.listRT"));
                        }
                    }

                } else {
                        helper.showToast(component, $A.get('$Label.c.XC_CL_LCP028_contactError'), 'Error');
                        helper.closeFunctinality(component, event, helper, resp.getError(), 'error');
                }

            } else {
                helper.closeFunctinality(component, event, helper, resp.getError(), 'error');
            }
        });
        $A.enqueueAction(action);
    },

    goBack : function(component,event,helper){
        
        $A.get("e.force:closeQuickAction").fire();

        //lancio evento per il close della finestra
        let ev = component.getEvent("XC_LCE019_CloseChildComponent");
        if (ev) {
            ev.fire();
        }

    }

})