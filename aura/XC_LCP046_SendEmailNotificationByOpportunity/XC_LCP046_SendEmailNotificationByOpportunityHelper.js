({
    generateRecord : function(component,event,helper) {
        helper.initCustomerInteractionMap(component,event,helper);
        
        let action = component.get("c.checkContactEmailAndNotification");
        let customerInteraction = component.get("v.customerInteraction"); 
        action.setParams({
            'opportunityId' : component.get("v.recordId"),
            'interactionValues' : JSON.stringify(customerInteraction)
            
        });
        action.setCallback(this, function(a) {
            let state = a.getState();
            if (state === "SUCCESS"){
                let result = a.getReturnValue();
                if(result.success){
                    helper.showToast(component, event, helper, result.resultMessage, "success");
                }else{
                    helper.showToast(component, event, helper, result.resultMessage, "error");
                }
                
                
                
                let spinner = component.find("mySpinner");
                
                setTimeout(function() {
                    $A.util.toggleClass(spinner, "slds-hide");
                    $A.get("e.force:closeQuickAction").fire();
                    
                })
            }
            
        });
        $A.enqueueAction(action); 
        
    },
    
    initCustomerInteractionMap : function(component,event,helper){
        let recordId = component.get("v.recordId");
        component.set("v.customerInteraction", {    		
            customerType : 'Opportunity_Product_Category_Email',
            skipComunication: false,
            opportunityId: recordId									                   
            
        })
        
    },
    
    
    showToast : function(component, event, helper, message, type) {
        component.find('notifLib').showToast({
            "title": message,
            "message": '',
            "variant": type
        });
    }
    
    
})