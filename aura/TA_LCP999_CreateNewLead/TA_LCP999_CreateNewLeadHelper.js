({
    initialize : function(component, event, helper) {
        console.log('TA_LCP999_CreateNewLead >> Helper >> initialize >> Start');
        let action = component.get("c.initialize");
        
        action.setCallback(this, function(response) {
            console.log('TA_LCP999_CreateNewLead >> Helper >> initializeCallback >> Start');
            if(response.getState() == "SUCCESS") {
                component.set("v.leadRecordTypeId", response.getReturnValue());
                component.set("v.initialized", true);
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
            console.log('TA_LCP999_CreateNewLead >> Helper >> initializeCallback >> Finish');
        });

        $A.enqueueAction(action);
        console.log('TA_LCP999_CreateNewLead >> Helper >> initialize >> Finish');
    }
})