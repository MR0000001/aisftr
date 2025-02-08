({
	generateRecord : function(component,event,helper) {
        helper.initCustomerInteractionMap(component,event,helper);
       
        var action = component.get("c.newEmailForCustomer");
        var customerInteraction = component.get("v.customerInteraction");
         action.setParams({
                'interactionValues' : JSON.stringify(customerInteraction)
            });
            action.setCallback(this, function(a) {
                var state = a.getState();
                  if (state === "SUCCESS"){
                    var result = a.getReturnValue();
                      if(result.success){
                           helper.showToast(component, event, helper, result.resultMessage, "success");
                      }else{
                           helper.showToast(component, event, helper, result.resultMessage, "error");
                      }
         
        
        
         			var spinner = component.find("mySpinner");
                           var delay=1000; //4 seconds
                    setTimeout(function() {
                    $A.util.toggleClass(spinner, "slds-hide");
                    $A.get("e.force:closeQuickAction").fire();
                    //$A.get('e.force:refreshView').fire();
                    })
                  }
                    
                      });
            $A.enqueueAction(action); 
		
	},
    
    initCustomerInteractionMap : function(component,event,helper){
     var recordId = component.get("v.recordId");
     component.set("v.customerInteraction", {    		
                                              customerType : 'Opportunity_SetCommercialVisit_Email',
         									  opportunityId : recordId,
         									  skipComunication : false,
         									  isAccountRequired : true                                                       
                                              } )
    
	},
    
    
    showToast : function(component, event, helper, message, type) {
        component.find('notifLib').showToast({
            "title": message,
            "message": '',
            "variant": type
        });
    }
    
    
})