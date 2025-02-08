({
	cancelProductReservation : function(component,event, helper ) {
		component.set("v.spinner", true);
        console.log('@@@@ spinner:' + component.get("v.spinner"));
        var action = component.get("c.cancelProducReservationStep1");
        var woliId =  component.get("v.recordId");
        var action2 = component.get("c.cancelProducReservationStep2");
        
        action2.setParams({
            'workOrderLineItemId' : woliId  
        });
        
        action2.setCallback(this,function(response){
            var state = response.getState();
            let storeResponse = response.getReturnValue();
            console.log("status step2: " + state);
            var resultsToast = $A.get("e.force:showToast");
            if (state === "SUCCESS") {
                if(storeResponse.success){
                    resultsToast.setParams({
                        "title": "Success",
                        "message": "Cancel Product Reservation correctly executed",
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
                    "title": 'Error',
                    "message": 'Cancel Product Reservation failed',
                    "duration": "4000",
                    "type": 'error',
                });
            }
            resultsToast.fire();
            // Update the UI: close panel, show toast, refresh account page
            $A.get("e.force:closeQuickAction").fire();
            
            //$A.get("e.force:refreshView").fire();
        });
        
        action.setParams({
            'workOrderLineItemId' : woliId  
		});
        
        action.setCallback(this,function(response){
            var state = response.getState();
            let storeResponse = response.getReturnValue();
            console.log('@@@ status step1 @@@ ' + state);
            var resultsToast = $A.get("e.force:showToast");
            if (state === "SUCCESS") {
                console.log('@@@ storeResponse.success @@@ ' + storeResponse.success);
               if(storeResponse.success){
                    $A.enqueueAction(action2);
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
                    	"title": 'Error',
                    	"message": 'Cancel Product Reservation failed',
                        "duration": "4000",
                        "type": 'error',
                	});
            }
            resultsToast.fire();
            // Update the UI: close panel, show toast, refresh account page
            $A.get("e.force:closeQuickAction").fire();

            //$A.get("e.force:refreshView").fire();
        });

        var requestInitiatedTime = new Date().getTime();
        //component.set("v.spinner", false);
        console.log('@@@ calling step1 @@@');
        $A.enqueueAction(action);
	}
})