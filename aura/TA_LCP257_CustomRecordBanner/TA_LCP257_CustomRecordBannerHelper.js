({
    initialize : function (component, event, helper) {
        console.log('TA_LCP257_CustomRecordBanner >> Helper >> initialize >> Start');
        let action = component.get("c.initialize");
        action.setParam("recordId", component.get("v.recordId"));
        action.setCallback(this, function (response) {
            console.log('TA_LCP257_CustomRecordBanner >> Helper >> initializeCallback >> Start');
            if(response.getState() == "SUCCESS") {
                let infoBag = JSON.parse(response.getReturnValue());
                component.set("v.workOrder", infoBag.workOrder);
                component.set("v.general", JSON.parse(infoBag.general));
                component.set("v.custom", JSON.parse(infoBag.custom));

                infoBag.title = infoBag.title.length >= 33 ? infoBag.description.substr(0, 30) + '...' : infoBag.title;
                infoBag.description = infoBag.description.length >= 73 ? infoBag.description.substr(0, 70) + '...' : infoBag.description;
                component.set("v.title", infoBag.title);
                component.set("v.description", infoBag.description);
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
            console.log('TA_LCP257_CustomRecordBanner >> Helper >> initializeCallback >> End');
        });

        $A.enqueueAction(action);
        console.log('TA_LCP257_CustomRecordBanner >> Helper >> initialize >> End');
    }
})