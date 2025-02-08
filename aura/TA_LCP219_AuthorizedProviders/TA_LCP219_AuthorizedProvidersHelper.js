({
    initialize : function(component, event) {
        console.log("TA_LCP219_AuthorizedProviders >> Helper >> initialize >> Start");
        component.set("v.general", JSON.parse(component.get("v.fieldSet")).general);
        if(component.get("v.general").defaultTitle) {
            component.set("v.title", $A.getReference("$Label.c." + component.get("v.general").defaultTitle));
        }
        if(component.get("v.general").description) {
            component.set("v.description", $A.getReference("$Label.c." + component.get("v.general").description));
        }
        component.set("v.customerCardBg", $A.get("$Resource.TA_Images") + "/imgs/" + component.get("v.general.bgImage"));

        let custom = JSON.parse(component.get("v.fieldSet")).custom;
        let workOrder = component.get("v.workOrder");
        console.log("workOrder >> " + JSON.stringify(workOrder));
        custom.field.forEach(function(field) {
            field.value = workOrder;
            field.apiName.split(".").forEach(function(el) {
                field.value = field.value[el];
                if(field.value.length > 48) field.value = field.value.substring(0, 47);
            });
        });
        component.set("v.custom", custom);
        this.fireSendInitStateEvt(component, true);
        console.log("TA_LCP219_AuthorizedProviders >> Helper >> initialize >> End");
    },

    fireSendInitStateEvt : function(component, isInitialized) {
        console.log("TA_LCP219_AuthorizedProviders >> Helper >> fireSendInitStateEvt >> Start");
        let sendInitStateEvt = component.getEvent("sendInitStateEvt");
        sendInitStateEvt.setParams({
            "componentName" : "TA_LCP219_AuthorizedProviders",
            "initState" : isInitialized
        });
        sendInitStateEvt.fire();
        console.log("TA_LCP219_AuthorizedProviders >> Helper >> fireSendInitStateEvt >> End");
    }
})