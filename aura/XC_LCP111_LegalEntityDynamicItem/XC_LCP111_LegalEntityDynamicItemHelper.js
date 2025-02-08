({
	/*doInit : function(component, event, helper) {
        let action = component.get("c.retrieveLegalEntities");
        action.setCallback(this, function(response) {
            let state = response.getState();
            if(state === "SUCCESS"){
                let options = response.getReturnValue();
				component.find("legalEntity").set("v.options", options);
                
            }else{
                console.debug('@@@@@ LegalEntityDynamicItem - Error on calling retrieveLegalEntities...');
            }
        });
        
        $A.enqueueAction(action);
    },*/
    
    onCountryChange : function(component, event, helper) {
        let action = component.get("c.getLegalEntitiesByCountry");
        action.setParams({
            'country' : component.get("v.ConsentsInstance.XC_LeCountry__c")
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if(state === "SUCCESS"){
                let options = response.getReturnValue();
				//component.find("legalEntity").set("v.options", options);
				component.set("v.ConsentsInstance.legalEntityConsents", options);
                
            }else{
                console.debug('@@@@@ LegalEntityDynamicItem - Error on calling getLegalEntitiesByCountry...');
            }
        });
        
        $A.enqueueAction(action);
    }
})