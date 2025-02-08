({
    onInit : function(component, event, helper) {
        helper.init(component, event, helper);
    },
    
    selectCountry : function(component, event, helper) {
        let selectedOptionValue = event.getParam("value");
        
        if(selectedOptionValue!=''){
            helper.selectCountry(component, event, helper);
        }
        
    }, 

    reload : function(component, event, helper) {
        component.set("v.loaded", false);
        component.set("v.address", {});
        component.set("v.address.country", event.getParam("country"));
        helper.init(component, event, helper);
    },

    send : function(component, event, helper) {
        let map = event.getParam("address");
        let withoutValidate = event.getParam("withoutValidate");
        let checkValue = event.getParam("checkValue");
        let cmpEvent = component.getEvent("forwardAddress");
        cmpEvent.setParams({
            "address" : map,
            "withoutValidate" : withoutValidate,
            "checkValue" : checkValue
        }); 
        cmpEvent.fire();
    },

    close : function(component, event, helper) {
        let cmpEvent = component.getEvent("forwardCloseEvent");
        cmpEvent.fire();
    }
    
})