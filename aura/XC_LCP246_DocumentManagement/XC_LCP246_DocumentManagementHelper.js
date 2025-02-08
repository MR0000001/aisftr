/**
  * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
  * @date 24/03/2021
  * @description XC_LCP246_DocumentManagementHelper - Javascript Helper for LCP246
*/

({

    doInit : function(component, event, helper, recallEvent) {
        component.set('v.spinnerControl', true);
        let oppId = component.get('v.recordId');
        if(oppId == null || oppId == undefined || oppId == "") {
            component.set('v.message', $A.get("$Label.c.XC_CL_NoOrderFound"));
            component.set('v.showMessage', true);
        } 

        component.set('v.message', $A.get("$Label.c.XC_CL_Loading"));
        component.set('v.showMessage', true);
        let action = component.get("c.getDocuments");
        action.setParams({
            'oppId': oppId
        });
        action.setCallback(this, function (a) {
            let state = a.getState();
            if(state === "SUCCESS") {
                let result = a.getReturnValue();
                if(!result.success || (result.success && !result.documentsExist)) {
                    component.set('v.messageTable', result.message);
                    component.set('v.showTable', false);
                    component.set('v.documentsOK', true);
                    helper.createEventDocumentOk(component, event, helper);
                } else {
                    let legalEntity = result.legalEntity;
                    if(legalEntity == $A.get("$Label.c.XC_CL_EndesaX")) {
                        component.set('v.showVocalSigned', true);
                    }
                    component.set('v.mapNameCategoryDocument', result.mapDocumentCategoryName);
                    component.set('v.orderId', result.orderId);
                    component.set('v.showMessage', false);
                    component.set('v.columnsTable', [
                        {label: $A.get("$Label.c.XC_CL_SerResMangement_Document"), fieldName: 'documentName', type: 'text'},
                        {label: $A.get("$Label.c.XC_CL_Status"), cellAttributes: { iconName: { fieldName: 'iconStatus' }, iconLabel: { fieldName: 'iconLabel'} }}
                    ]);
                    component.set('v.listExistingDocument', result.listExistingDocuments);
                    component.set('v.listDocumentRequired', result.listDocumentsRequired);
                    helper.calculateExistingDocuments(component, event, helper, result.listDocumentsRequired, result.listExistingDocuments);                    
                    component.set('v.sessionId', result.sessionId);
                    component.set('v.showTable', true);
                    if(!component.get('v.documentsOK') && recallEvent) {
                        $A.createComponent("c:XC_LCP246_DocumentManagementEvent", {
                            "sessionId": component.get('v.sessionId'),
                            "orderId": component.get('v.orderId')
                        }, function(contentComponent, status, error) {
                            if(status === "SUCCESS") {
                                component.set('v.body', contentComponent);
                            } else {
                                throw new Error(error);
                            }
                        });
                    }
                }
            }
            else {
                component.set('v.messageTable', a.getError());
                component.set('v.showTable', false);
            }
            component.set('v.spinnerControl', false);
        });
        $A.enqueueAction(action);
    },

    refreshTable : function(component, event, helper) {
        component.set('v.spinnerControl', true);
        component.set('v.showMessage', true);
        component.set('v.showMessage', false);
        helper.doInit(component, event, helper, false);
        $A.createComponent("c:XC_LCP234_RefreshLoadedDocument", {
            "recordId": component.get('v.orderId'),
            "notCloseAction": true
        }, function(contentComponent, status, error) {
            if(status === "SUCCESS") {
                component.set('v.body', contentComponent);
            } else {
                throw new Error(error);
            }
        });
        component.set('v.spinnerControl', false);
    },

    documentFiltered : function(component, event, helper) {
        component.set('v.spinnerControl', true);
        let data = component.get("v.dataTableOriginal"),
            term = component.get("v.filterDocument"),
            results = data, regex;
        try {
            regex = new RegExp(term, "i");
            results = data.filter(row=>regex.test(row.documentName));
        } catch(e) {
            console.log('@@@ Error: ' + e);
        }
        component.set("v.dataTable", results);
        component.set('v.spinnerControl', false);
    },

    createEventDocumentOk : function(component, event, helper) {
        component.set('v.spinnerControl', true);
        let documentsOK = component.get('v.documentsOK');
        let obj = {
            'section' : 'documents',
            'validate' : documentsOK
        };
        let ev = component.getEvent("XC_AMP_LCE001_AMPCommunicationEvent");
        ev.setParam("data", obj);
        ev.fire();
        component.set('v.spinnerControl', false);
    },

    sendDocument : function(component, event, helper) {
        component.set('v.spinnerControl', true);
        /*let newDocument = event.getParam('documentInserted');
        let listDocumentRequired = component.get('v.listDocumentRequired');
        let listExistingDocument = component.get('v.listExistingDocument');
        listExistingDocument.push(newDocument);
        component.set('v.listExistingDocument', listExistingDocument);
        helper.calculateExistingDocuments(component, event, helper, listDocumentRequired, listExistingDocument);*/
        helper.doInit(component, event, helper, false);
        component.set('v.spinnerControl', false);
    },

    calculateExistingDocuments : function(component, event, helper, listDocumentRequired, listExistingDocument) {
        let listForTable = [];
        let allDocumentOk = true;
        let mapCategoryNameDocument = component.get('v.mapNameCategoryDocument');
        listDocumentRequired.forEach(requiredDocument => {
            let nameDocument = mapCategoryNameDocument.hasOwnProperty(requiredDocument) ? mapCategoryNameDocument[requiredDocument] : requiredDocument;
            let singleEntry = {"documentName" : nameDocument};
            if(listExistingDocument.includes(requiredDocument)) {
                singleEntry["iconStatus"] = "action:approval";
                singleEntry["iconLabel"] = ' ' + $A.get("$Label.c.XC_CL_DocumentFound");
            } else {
                allDocumentOk = false;
                singleEntry["iconStatus"] = "action:close";
                singleEntry["iconLabel"] = ' ' + $A.get("$Label.c.XC_CL_MissingDocument");
            }
            listForTable.push(singleEntry);
        });
        component.set('v.dataTable', listForTable);
        component.set('v.dataTableOriginal', listForTable);
        component.set('v.documentsOK', allDocumentOk);
    },

    digitalSignature : function(component, event, helper) {
        component.set('v.spinnerControl', true);
        $A.createComponent("c:XC_LCP191_ExternalOTPSignature", {
            "recordId" : component.get('v.orderId'),
            "notCloseModal" : true
        }, 
        function(contentComponent, status, error) {
            if(status === "SUCCESS") {
                // TODO
            } else {
                throw console.log('Error: ', JSON.parse(JSON.stringify(error)));
            }
            component.set('v.spinnerControl', false);
        }); 
    },

    vocalOrderSign : function(component, event, helper) {
        component.set('v.spinnerControl', true);
        $A.createComponent("c:XC_LCP175_VocalOrderAcceptance", {
            "recordId" : component.get('v.orderId'),
            "notCloseModal" : true
        }, 
        function(contentComponent, status, error) {
            if(status === "SUCCESS") {
                // TODO
            } else {
                throw console.log('Error: ', JSON.parse(JSON.stringify(error)));
            }
            component.set('v.spinnerControl', false);
        }); 
    },

    onVocalScript : function(component, event, helper) {
        component.set('v.spinnerControl', true);
        $A.createComponent("c:XC_LCP173_CTIShowAgentScriptContainer", {
            "recordId" : component.get('v.orderId'),
            "fromAnotherComponent" : true
        }, 
        function(contentComponent, status, error) {
            if(status === "SUCCESS") {
                let modalBody = contentComponent;
                component.find('overlayLib').showCustomModal({
                    header: $A.get("$Label.c.XC_CL_LCP173_ShowScriptCardHeader"),
                    body: modalBody, 
                    showCloseButton: true,
                    cssClass: "mymodal",
                });
            } else {
                throw console.log('Error: ', JSON.parse(JSON.stringify(error)));
            }
            component.set('v.spinnerControl', false);
        }); 
    },

    onSaveURL : function(component, event, helper) {
        component.set('v.spinnerControl', true);
        let valueURL = component.get('v.valueURL');
        if(valueURL == null || valueURL == undefined || valueURL == "") {
            let toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: $A.get("$Label.c.XC_CL_ErrorsOccurred"),
                message: $A.get("$Label.c.XC_CL_ErrorURL"),
                key: 'info_alt',
                type: 'error',
                mode: 'dismissible'
            });
            toastEvent.fire();
            component.set('v.spinnerControl', false);
            return;
        } 

        let action = component.get("c.updateOrder");
        action.setParams({
            'orderId': component.get('v.orderId'),
            'valueField': valueURL
        });
        action.setCallback(this, function (a) {
            let state = a.getState();
            let toastEvent = $A.get("e.force:showToast");
            if(state === "SUCCESS") {
                let result = a.getReturnValue();
                if(!result.success) {
                    toastEvent.setParams({
                        title: $A.get("$Label.c.XC_CL_ErrorsOccurred"),
                        message: result.message,
                        key: 'info_alt',
                        type: 'error',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                } else {
                    toastEvent.setParams({
                        title: $A.get("$Label.c.XC_CL_Success"),
                        message: result.message,
                        key: 'info_alt',
                        type: 'success',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                    component.set('v.showSetURL', false);
                }
            }
            else {
                toastEvent.setParams({
                    title: $A.get("$Label.c.XC_CL_ErrorsOccurred"),
                    message: a.getError(),
                    key: 'info_alt',
                    type: 'error',
                    mode: 'dismissible'
                });
                toastEvent.fire();
            }
            component.set('v.spinnerControl', false);
        });
        $A.enqueueAction(action);
    },

})