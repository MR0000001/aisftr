({
	navigate : function(component, contractId) {
		var navService = component.find("navService");        
        var pageReference = {
            "type": 'standard__recordPage',         
            "attributes": {              
                "recordId": contractId,
                "actionName": "view",               
                "objectApiName":"Contract"              
            }        
        };
                
        component.set("v.pageReference", pageReference);
            
        var pageReference = component.get("v.pageReference");
        navService.navigate(pageReference); 
	}
})