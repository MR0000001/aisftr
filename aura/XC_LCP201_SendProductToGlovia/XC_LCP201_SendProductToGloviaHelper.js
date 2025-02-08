({
	createSOGlovia : function(component,event, helper ) {
		component.set("v.spinner", true);
        console.log('@@@@ spinner:' + component.get("v.spinner"));
        var action = component.get("c.getAllProductRequired");
        var woliId =  component.get("v.recordId");
        
        action.setParams({
            'workOrderLineItemId' : woliId			
            
		});
        
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log('@@@ createSOSOLIGlovia state:' + state);
            var resultsToast = $A.get("e.force:showToast");
            if (state === "SUCCESS" && response.getReturnValue().success) {
                  /* console.log('@@@@ response.getReturnValue():' + response.getReturnValue());
                   resultsToast.setParams({
                    	"title": response.getReturnValue().titleMessage,
                    	"message": response.getReturnValue().message,
                        "duration": "4000",
                        "type": response.getReturnValue().typeMessage,
                	});*/
                	helper.showToast(component, event, helper, response.getReturnValue().resultMessage, response.getReturnValue().typeMessage) ;
                	// Update the UI: close panel, show toast, refresh account page
            }else{
                helper.showToast(component, event, helper, response.getReturnValue().resultMessage, 'error') ;
            }    
            // Update the UI: close panel, show toast, refresh account page
            //resultsToast.fire();
            $A.get("e.force:closeQuickAction").fire();

            //$A.get("e.force:refreshView").fire();
        });
        var requestInitiatedTime = new Date().getTime();
        //component.set("v.spinner", false);
        $A.enqueueAction(action);
	},
    
    getCommercialItem : function(component,event, helper ) {
		
        console.log('@@@@ getCommercialItem:');
        var action = component.get("c.getCommercialItemList");
        var woliId =  component.get("v.recordId");
        
        action.setParams({
            'woliId' : woliId			
            
		});
        
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log('@@@ product2 state:' + state);
            if (state === "SUCCESS") {
                console.log('@@@@ response.getReturnValue():' + response.getReturnValue());
                if(response.getReturnValue()!=''){
                   component.set("v.commercialCI", response.getReturnValue());
                   component.set("v.isOpen", true);             	
                }
                

            }
        });
        var requestInitiatedTime = new Date().getTime();
        //component.set("v.spinner", false);
        $A.enqueueAction(action);
	},
	showToast : function(component, event, helper, message, type) {
            component.find('notifLib').showToast({
                "title": message,
                "message": '',
                "variant": type
            });
        }
    
})