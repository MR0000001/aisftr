({
    initialize : function(component, event, helper) {
        console.log("TA_LCP246_AddNewProductRequired >> Helper >> initialize >> Start");
        var pageRef = component.get("v.pageReference");
        if(pageRef != null && pageRef != undefined) {
            var state = pageRef.state; // state holds any query params
            var base64Context = state.inContextOfRef;
            if(base64Context.startsWith("1\.")) {
                base64Context = base64Context.substring(2);
            }
            var addressableContext = JSON.parse(window.atob(base64Context));
            component.set("v.parentRecordId", addressableContext.attributes.recordId);
        } else {
            component.set("v.parentRecordId", component.get("v.recordId"));
        }

        helper.getListConfCommercial(component, event, helper);
        console.log("TA_LCP246_AddNewProductRequired >> Helper >> initialize >> End");
    },

    getListConfCommercial : function (component, event, helper) {
        console.log('TA_LCP246_AddNewProductRequired >> Helper >> getListConfCommercial >> Start');
        var action = component.get("c.getCommercialItemList");
        var woliId = component.get("v.parentRecordId");
        action.setParams({
            'woliId' : woliId
        });

        action.setCallback(this, function(response) {
            console.log('TA_LCP246_AddNewProductRequired >> Helper >> getListConfCommercialCallback >> Start');
            if(response.getState() == "SUCCESS") {
                if(response.getReturnValue() != '' && response.getReturnValue() != null && response.getReturnValue().length > 0) {
                    component.set("v.selectConfComm", true);
                    component.set("v.confItemCommercial", response.getReturnValue());
                    helper.fireToggleSpinnerEvent(component, false);
                } else if(response.getReturnValue() != null && response.getReturnValue().length == 0) {
                    this.openLCP195(component, event, helper);
                } else {
                    component.set("v.showToastMessage", true);
                    component.set("v.isError", true);
                    component.set("v.toastMessage", $A.get('$Label.c.XC_CL_Error') + ": " + $A.get('$Label.c.XC_CL_NoAddProductForWOLI'));
                    $A.get("e.force:closeQuickAction").fire();
                    helper.fireToggleSpinnerEvent(component, false);
                }
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
                helper.fireToggleSpinnerEvent(component, false);
            }
            console.log('TA_LCP246_AddNewProductRequired >> Helper >> getListConfCommercialCallback >> End');
        });

        $A.enqueueAction(action);
        console.log('TA_LCP246_AddNewProductRequired >> Helper >> getListConfCommercial >> End');
    },

    getOtherParmCIC : function (component, event, helper) {
        console.log('TA_LCP246_AddNewProductRequired >> Helper >> getOtherParmCIC >> Start');
        var action = component.get("c.getParamToGlovia");
        var idConfComm = component.get("v.idSelectConfComm");
        action.setParams({
            'confItemComm' : idConfComm
        });

        action.setCallback(this, function(response) {
            console.log('TA_LCP246_AddNewProductRequired >> Helper >> getOtherParmCICCallback >> Start');
            if(response.getState() == "SUCCESS") {
                if(response.getReturnValue().result == true) {
                    component.set("v.selectConfComm", true);
                    component.set("v.wbeElement", response.getReturnValue().wbeElement);
                    component.set("v.costCenter", response.getReturnValue().costCenter);
                } else {
                    component.set("v.selectConfComm", false);
                    let message = response.getReturnValue().titleMessage + ': ' + response.getReturnValue().message
                    component.set("v.showToastMessage", true);
                    component.set("v.isError", true);
                    component.set("v.toastMessage", message);
                }
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
            helper.fireToggleSpinnerEvent(component, false);
            console.log('TA_LCP246_AddNewProductRequired >> Helper >> getOtherParmCICCallback >> End');
        });

        $A.enqueueAction(action);
        console.log('TA_LCP246_AddNewProductRequired >> Helper >> getOtherParmCIC >> End');
    },

    openLCP195 : function(component, event, helper) {
        console.log('TA_LCP246_AddNewProductRequired >> Helper >> openLCP195 >> Start');
        var pageRef = component.get("v.pageReference");
        var woliId = component.get("v.parentRecordId");
        var wbeElement = component.get("v.wbeElement");
        var costCenter = component.get("v.costCenter");
        if(pageRef != null && pageRef != undefined) {
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef  : "c:XC_LCP195_AddTechnicalItems" ,
                componentAttributes : {
                    showComponentAddPC : component.get("v.showComponentAddPC"),
                    woliRecordId : woliId,
                    wbeElement : wbeElement,
                    costCenter : costCenter,
                    contestStartCI : false,
                    recordId : component.get("v.idSelectConfComm")
                }
            });
            evt.fire();
        } else {
            component.set("v.showAddTechnicalItems", true);
            component.set('v.isInitialized', false);
        }

        helper.fireToggleSpinnerEvent(component, false);
        console.log('TA_LCP246_AddNewProductRequired >> Helper >> openLCP195 >> End');
    },

    fireToggleSpinnerEvent : function(component, toggleSpinner) {
        console.log('TA_LCP246_AddNewProductRequired >> Helper >> fireToggleSpinnerEvent >> Start');
        let toggleSpinnerEvent = component.getEvent("toggleSpinnerEvent");
        toggleSpinnerEvent.setParams({
            "sourceComponent" : "TA_LCP246_AddNewProductRequired",
            "toggleSpinner" : toggleSpinner
        });
        toggleSpinnerEvent.fire();
        console.log('TA_LCP246_AddNewProductRequired >> Helper >> fireToggleSpinnerEvent >> End');
    }
})