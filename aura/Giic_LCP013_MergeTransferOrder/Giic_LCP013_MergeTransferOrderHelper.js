({  
	doInit : function(component, event, helper) {
           component.set('v.showSpinner',true);
        var action = component.get("c.processMergeForTOfromComponent");
        //Setting the Callback
        action.setCallback(this, function(response) {
            let state = response.getState();  
            let retValue = response.getReturnValue();
             //check if result is successfull 
            if (state==='SUCCESS' && retValue.success ) {
             
               component.set('v.showSpinner',false);
               helper.showToast(component, event, helper, 'Success', 'success');
               
            } else {
                
                component.set('v.showSpinner',false); 
                helper.showToast(component, event, helper, retValue.resultMessage, 'error') ;
            }
            
             $A.get("e.force:closeQuickAction").fire();
        });
        
        //adds the server-side action to the queue
        $A.enqueueAction(action);
	},
     
     showToast : function(component, event, helper, message, type) {
         component.set('v.showSpinner', false);
         var navService = component.find("navService");
         var pageReference = {
            "type" : 'standard__objectPage',
            "attributes": {
                "objectApiName": 'gii__TransferOrder__c',
                "actionName": "list"
            },
                "state": {
        			"filterName": "All_1"
  			}
		
        };
        component.find('notifLib').showToast({
            "title": message,
            "message": '',
            "variant": type
        });
        navService.navigate(pageReference);
        
    }
})