({
    init : function(component, event, helper) {   
        
        if(component.get("v.address.country")){
            helper.selectCountry(component, event, helper);
        } else {
            var action = component.get("c.getCountryByUser");
            action.setCallback(this, function(response) {
                var state = response.getState();
                var res = response.getReturnValue();
                if(state=='SUCCESS'){
                    component.set("v.address.country", res);
                    helper.selectCountry(component, event, helper);
                }
            });
            $A.enqueueAction(action);    
        }
    },
    
    handleComponent : function(component, event, helper) {
        var recId = component.get("v.recordId");
        var accId = component.get("v.accountId");
        var leadId = component.get("v.leadId");
        var source = component.get("v.source");
        
        if(source=='013'&&!leadId){
            leadId = recId;
            
        } else if(!accId){
            accId = recId;
        }
        
        component.set("v.address.isAccountPartner", component.get("v.isPartner"));
        component.set("v.address.account", accId);
        component.set("v.address.lead", leadId);
        component.set("v.address.validate", component.get("v.forceAllAddresses"));
        console.log('@@@@ ' + component.get("v.componentName"));
        $A.createComponent(
            "c:"+component.get("v.componentName"),
            {
                "aura:id": "inpId",
                "recordId": recId,
                "address" : component.get("v.address"),

                //"autocomplete" : component.get("v.autocomplete"),
                //"disabled" : component.get("v.disabled")
                
                "source": source,
                "addressToUpdate" : component.get("v.addressToUpdate")
            },
            function(newInp, status, errorMessage){
                if (status === "SUCCESS") {
                    //var body = component.get("v.body");
                    //body.push(newInp);
                    component.set("v.body", newInp);
                    component.set("v.loaded", true);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                }
                    else if (status === "ERROR") {
                        console.log("Error: " + errorMessage);
                    }
            }
        );
    },
    
    selectCountry : function(component, event, helper) {
    	var action = component.get("c.getComponentName");
        var countryVar = component.get("v.address.country");
        action.setParams({
            'country' : countryVar
        }); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            var res = response.getReturnValue();
            
            if(state=='SUCCESS'){
                var setup = JSON.parse(res);
                component.set("v.componentName", setup.componentName);
                component.set("v.autocomplete", setup.isAutocomplete);
                component.set("v.forceAllAddresses",setup.forceAllAddresses);
                helper.handleComponent(component, event, helper);
                
            } else {
                console.log("Error: couldn't retrive Address fieldset");	
            }
        });
        
        $A.enqueueAction(action);
    }
    
})