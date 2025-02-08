({	
	init : function(component, event) {
		let action = component.get("c.getAddressFields");
		action.setParams({
            'leadId' : component.get("v.recordId")
        }); 
		action.setCallback(this, function(response) {
            let state = response.getState();
			let res = response.getReturnValue();
			let address = JSON.parse(res);
			component.set("v.fieldsMap", address); 
			component.set("v.fieldsMap.lead",component.get("v.recordId")); 
            let parentRecordType = address.parentRecordType;
			if(state=='SUCCESS' && address.addressToUpdate ){
				component.set("v.addressToUpdate", true);
			} else {
				console.log("Error: couldn't retrive Lead Address fieldset");	
				component.set("v.addressToUpdate", false);
			}

			$A.createComponent(
				"c:XC_LCP_Address",
				{
					"aura:id": "inpId",
					"address" : address,
					"source": "013",
					"addressToUpdate" : component.get("v.addressToUpdate"),
					"parentRecordType": parentRecordType,
					"recordId":component.get("v.recordId")
				},
				function(newInp, status, errorMessage){
					if (status === "SUCCESS") {
						component.set("v.body", newInp);
					}
					else if (status === "INCOMPLETE") {
						console.log("No response from server or client is offline.")
					}
						else if (status === "ERROR") {
							console.log("Error: " + errorMessage);
						}
				}
			);
        });
        
        $A.enqueueAction(action);
        }
})