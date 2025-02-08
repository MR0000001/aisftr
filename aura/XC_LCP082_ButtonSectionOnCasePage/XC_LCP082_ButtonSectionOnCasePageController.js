({

    doInit: function (component, event, helper) {
        helper.doInit(component, event, helper);

    },
    newRequest: function (component, event, helper) {
        helper.checkPossibilityToChangeOrDisconnect(component, event, helper);
    },

    disconnect: function (component, event, helper) {
        helper.checkPossibilityToChangeOrDisconnect(component, event, helper);
    },

    newCompl: function (component, event, helper) {
        helper.newCompl(component, event, helper);

    },
    validateWorkOrder: function (component, event, helper) {
        helper.validateWorkOrder(component);
        console.log("validateWorkOrder");

    },
    openModel: function (component, event, helper) {
        helper.openModel(component);
        console.log("openModel");
    },
    closeModel: function (component, event, helper) {
        helper.closeModel(component);
        console.log("closeModel");
    },
    refreshModel: function (component, event, helper) {
        helper.refreshModel(component);
        console.log("refreshModel");
    },
    suspend: function (component, event, helper) {
        helper.suspend(component, event, helper);
    },


    handlePrimaryButtonClick: function (component, event, helper) {
        let count = component.get("v.count");
        count++;
        component.set("v.count", count);
        console.log("count = " + count);


        component.set("v.showTextArea", true);
        component.set("v.showFooter", false);



    },

    dis: function (component, event, helper) {
        helper.cancelCase(component, event, helper);

    },

    handleSecondaryButtonClick: function (component, event, helper) {
        helper.handleSecondaryButtonClick(component, event, helper);
    },

    handleModalClosedEvent: function (component, event, helper) {
        let modalName = event.getParam("modalName");
        if (modalName == $A.get("$Label.c.XC_CL_CreateOpportunityClosedEvent") ||
            modalName == $A.get("$Label.c.XC_CL_AssetsAttachClosedEvent") ||
            modalName == $A.get("$Label.c.XC_CL_UpCompliantCaseClosedEvent")) {
            helper.handleSecondaryButtonClick(component, event, helper);
        }
    },

    checkNotBlank: function (component, event, helper) {
        let resolution = component.get("v.cancelValuesMap.resolution");
        let result = component.get("v.cancelValuesMap.result");
        let caseRemarks = component.get("v.cancelValuesMap.caseRemarks");
        if (resolution == '' || resolution === undefined || result == '' || result === undefined || caseRemarks.trim() == '' || caseRemarks === undefined) {
            component.set("v.disabledSubmit", true);
        } else {
            component.set("v.disabledSubmit", false);
        }
    },

    handleClick: function (component, event, helper) {
        console.log("START handleclick");
        let selectedMenuItemValue = event.getParam("value");
        helper.doInitUpdate(component, event, helper, selectedMenuItemValue);

    },

    handleQualityClick: function (component, event, helper) {
        helper.handleQualityWOCreation(component, event, helper);
    },

    documentVerificationInvoke: function (component, event, helper) {
        helper.docVerification(component, event, helper);
    },

    backComplianceInvoke: function (component, event, helper) {
        helper.backCompliance(component, event, helper);
    },
    
    closeConfirmDisconnectModel: function(component, event, helper) {
    	component.set("v.confirmDisconnectModal", false);
    },
    
    continueConfirmDisconnectModel: function (component, event, helper) {
        component.set("v.confirmDisconnectModal", false);
    	helper.disconnect(component, event, helper);
    },
  
})