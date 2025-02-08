({
    handleOrderFieldSave: function (component, event, helper) {

        //check changed fields
        let eventParams = event.getParams();
        let changedFields = eventParams.changedFields;

        console.log('CHANGED FIELDS ON ORDER ACCEPTANCE ' + JSON.stringify(changedFields));
        let currentValue = component.get('v.orderRecord.XC_SignedByExternal__c');
        console.log('CURRENT EXTERNAL ORDER ACCEPTANCE ' + currentValue);


        if (currentValue != 'VocalOrder') {
            //change the field value
            component.set("v.orderRecord.XC_SignedByExternal__c", 'VocalOrder');
            component.find('recordLoader').saveRecord($A.getCallback(function (result) {
                if (result.state === "SUCCESS") {

                    //close send toast and close quick action
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success",
                        "message": $A.get("$Label.c.XC_CL_VocalOrderAcceptedSuccess"),
                        "mode": "pester",
                        "type": "success"
                    });
                    toastEvent.fire();

                    if(!component.get('v.notCloseModal')) {
                        $A.get("e.force:closeQuickAction").fire();
                    }

                } else if (result.state === "ERROR") {

                    //send error and close quick action
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error",
                        "message": $A.get("$Label.c.XC_CL_VocalOrderAcceptedError") + JSON.stringify(result.error),
                        "mode": "pester",
                        "type": "error"
                    });
                    toastEvent.fire();

                    if(!component.get('v.notCloseModal')) {
                        $A.get("e.force:closeQuickAction").fire();
                    }
                }
            }));
        } else {
            //close send toast and close quick action no save on db
            let toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Start",
                "message": $A.get("$Label.c.XC_CL_VocalOrderAcceptedSuccess"),
                "mode": "pester",
                "type": "success"
            });
            toastEvent.fire();
            if(!component.get('v.notCloseModal')) {
                $A.get("e.force:closeQuickAction").fire();
            }
        }
    }
})