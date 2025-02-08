({
    handleIsInitializedChange : function(component, event, helper) {
        console.log("TA_LCP246_AddNewProductRequired >> Controller >> handleIsInitializedChange >> Start");
        helper.fireToggleSpinnerEvent(component, true);
        if(component.get("v.isInitialized")) {
            helper.initialize(component, event, helper);
        } else {
            helper.fireToggleSpinnerEvent(component, false);
        }
        console.log("TA_LCP246_AddNewProductRequired >> Controller >> handleIsInitializedChange >> End");
    },

    cancelDialog : function(component, event, helper) {
        console.log("TA_LCP246_AddNewProductRequired >> Controller >> cancelDialog >> Start");
        component.set('v.isInitialized', false);
        helper.fireToggleSpinnerEvent(component, false);
        console.log("TA_LCP246_AddNewProductRequired >> Controller >> cancelDialog >> End");
    },

    onPicklistChange: function(component, event, helper) {
        console.log("TA_LCP246_AddNewProductRequired >> Controller >> onPicklistChange >> Start");
        helper.fireToggleSpinnerEvent(component, true);
        let idConfComm = event.getSource().get("v.value");
        component.set("v.idSelectConfComm", idConfComm);

        if(idConfComm != '--none--') {
            helper.getOtherParmCIC(component, event, helper);
        } else {
            helper.fireToggleSpinnerEvent(component, false);
        }
        console.log("TA_LCP246_AddNewProductRequired >> Controller >> onPicklistChange >> End");
    },

    callSaveComp : function(component, event, helper) {
        console.log("TA_LCP246_AddNewProductRequired >> Controller >> callSaveComp >> Start");
        helper.fireToggleSpinnerEvent(component, true);
        var pageRef = component.get("v.pageReference");
        var idCommItem = component.get("v.idSelectConfComm");

        if(idCommItem != '--none--') {
            var woliId = component.get("v.parentRecordId");
            var wbeElement = component.get("v.wbeElement");
            var costCenter = component.get("v.costCenter");
            if(pageRef != null && pageRef != undefined) {
                var evt = $A.get("e.force:navigateToComponent");
                evt.setParams({
                    componentDef : "c:XC_LCP195_AddTechnicalItems",
                    componentAttributes : {
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
        } else {
            component.set("v.showToastMessage", true);
            component.set("v.isError", true);
            component.set("v.toastMessage", "Add Order material: Choose related commercial item to add Material Order"); // TO DO CUSTOM LABEL
        }

        helper.fireToggleSpinnerEvent(component, false);
        console.log("TA_LCP246_AddNewProductRequired >> Controller >> callSaveComp >> End");
	}
})