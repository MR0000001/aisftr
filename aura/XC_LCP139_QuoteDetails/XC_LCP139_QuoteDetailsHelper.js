({
    doInit: function (component, event, helper) {
        let action = component.get("c.retrieveQuoteId");
        action.setParams({
            'caseId': component.get("v.recordId")
        })
        action.setCallback(this, function (response) {
            let state = response.getState();
            let retValue = response.getReturnValue();
            if (state === "SUCCESS" && retValue) {
                console.log('@@@ Result value: ', retValue);
                if (retValue.success) {
                    component.set("v.quoteFound", true);
                    let values = JSON.parse(retValue.objectInfo);
                    helper.setQuoteParams(component, event, helper, values);
                }
            }
        });
        $A.enqueueAction(action);
    },

    setQuoteParams: function (component, event, helper, values) {
        component.find("oneTime").set("v.value", values.priceTotal);
        component.find("recurringFrequency").set("v.value", values.recurringFrequencyTotal);
        /*component.find("quoteNumber").set("v.value" , values.quoteNumber);
        component.find("opportunityName").set("v.value" , values.opportunityName);
        component.find("recordType").set("v.value" , values.recordType);
        component.find("recurringCharge").set("v.value" , values.recurringCharge);
        component.find("status").set("v.value" , values.status);*/
    },

    showToast: function (component, event, helper, message, type) {
        component.find('notifLib').showToast({
            "title": message,
            "message": '',
            "variant": type
        });
    }

})