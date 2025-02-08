({
    createReturnMaterialWoli : function(component,event, helper) {
        component.set("v.spinner", true);
        component.set("v.disableButton", true);
        var woliId =  component.get("v.recordId");
        console.log(woliId);
        
        //set action to call
        var action = component.get("c.createReturnMaterial");

        //set parameters to send
        action.setParams({
            'recordId' : woliId			
		});

        //set callback logic after the action is completed
        //return success status or error
        action.setCallback(this,function(response){
            component.set("v.spinner", false);
            var state = response.getState();
            let storeResponse = response.getReturnValue();
            var resultsToast = $A.get("e.force:showToast");
            if (state === "SUCCESS") {
               if(storeResponse.success){
                   console.log('@@@@ response.getReturnValue():' + response.getReturnValue());
                   resultsToast.setParams({
                    	"title": "Success",
                    	"message": "Return Material woli created successfully",
                        "duration": "4000",
                        "type": "success",
                	});

                	resultsToast.fire();
                    // redirect to the new woli
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                    //recordId is the id of the new woli
                    "recordId": storeResponse.recordId,
                    "slideDevName": "Detail"
                    });
                    navEvt.fire();
               }
               else{
                console.log('@@@@ response.getReturnValue():' + response.getReturnValue());
                  resultsToast.setParams({
                    "title": "Error",
                    "message": storeResponse.resultMessage,
                    "duration": "4000",
                    "type": "error"
                });

                resultsToast.fire();

                $A.get("e.force:closeQuickAction").fire();
           }
            }else{
                	resultsToast.setParams({
                    	"title": 'Send order Material',
                    	"message": storeResponse.resultMessage,
                        "duration": "4000",
                        "type": 'Error',
                	});

                    resultsToast.fire();

                    $A.get("e.force:closeQuickAction").fire();
            }
        });

        $A.enqueueAction(action);
    }
})