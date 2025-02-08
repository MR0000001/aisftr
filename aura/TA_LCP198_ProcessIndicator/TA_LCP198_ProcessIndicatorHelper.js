({
    initialize : function (component, event, helper) {
        console.log('TA_LCP198_ProcessIndicator >> Helper >> initialize >> Start');
        let action = component.get("c.setProcess");
        action.setParam("workOrderId", component.get("v.recordId"));
        action.setCallback(this, function (response) {
            console.log('TA_LCP198_ProcessIndicator >> Helper >> initializeCallback >> Start');
            if(response.getState() == "SUCCESS") {
                let infoBag = response.getReturnValue();
                component.set("v.infoBag", infoBag);
                let percentageProcess = 0;
                if(infoBag.listProcess.length == 1) {
                    percentageProcess = 100;
                } else if(infoBag.listProcess.length > 1) {
                    percentageProcess = ((infoBag.index - 1) * 100) / (infoBag.listProcess.length - 1);
                }
                component.set("v.percentageProcess", percentageProcess);
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
            console.log('TA_LCP198_ProcessIndicator >> Helper >> initializeCallback >> End');
        });
        $A.enqueueAction(action);
        console.log('TA_LCP198_ProcessIndicator >> Helper >> initialize >> End');
    }
})