({
	createSOGlovia : function(component,event, helper ) {
		component.set("v.spinner", true);
        console.log('@@@@ spinner:' + component.get("v.spinner"));
        var action = component.get("c.createMTR");
        var woliId =  component.get("v.recordId");
        
        action.setParams({
            'workOrderLineItemId' : woliId			
            
		});
 
        action.setCallback(this,function(response){
            var state = response.getState();
            let storeResponse = response.getReturnValue();
            console.log('@@@ createSOSOLIGlovia state:' + state);
            var resultsToast = $A.get("e.force:showToast");
            if (state === "SUCCESS") {
               if(storeResponse.success){
                   console.log('@@@@ response.getReturnValue():' + response.getReturnValue());
                   resultsToast.setParams({
                    	"title": "Success",
                    	"message": "Return material successfully executed",
                        "duration": "4000",
                        "type": "success",
                	});
                	// Update the UI: close panel, show toast, refresh account page
               }
               else{
                    console.log('@@@@ response.getReturnValue():' + response.getReturnValue());
                      resultsToast.setParams({
                        "title": "Error",
                        "message": storeResponse.resultMessage,
                        "duration": "4000",
                        "type": "error"
                    });
               }
            }else{
                	resultsToast.setParams({
                    	"title": 'Send order Material',
                    	"message": 'Order Material send failed!!',
                        "duration": "4000",
                        "type": 'Error',
                	});
            }
            resultsToast.fire();
            // Update the UI: close panel, show toast, refresh account page
            $A.get("e.force:closeQuickAction").fire();

            //$A.get("e.force:refreshView").fire();
        });
        var requestInitiatedTime = new Date().getTime();
        //component.set("v.spinner", false);
        $A.enqueueAction(action);
	}
    
   
})