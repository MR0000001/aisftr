({
	generateRecord : function(component,event,helper) {
        var delay;
        if(component.find("mydelay") && component.find("mydelay").get("v.value")!=undefined){
            delay = component.find('mydelay').get("v.value");
            component.set("v.customerInteraction.delay" , delay);
            console.log('customerInteraction info = '+JSON.stringify(component.get("v.customerInteraction")));
        }
        
        let action = component.get("c.updateServiceAndSend");
        let customerInteraction = component.get("v.customerInteraction");
         action.setParams({
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
         
        
                    }
                 component.set("v.spinnerControl" , false);
           
             
                    
            });
            $A.enqueueAction(action); 
            
		
	},
    
     
    
    
    showToast : function(component, event, helper, message, type) {
        component.find('notifLib').showToast({
            "title": message,
            "message": '',
            "variant": type
        });
        
        let spinner = component.find("mySpinner");
                    setTimeout(function() {
                    $A.util.toggleClass(spinner, "slds-hide");
                    $A.get("e.force:closeQuickAction").fire();
                    $A.get('e.force:refreshView').fire();
                    })
    },
    
    checkPossibilityToCreate  : function(component,event,helper) {
        let action = component.get("c.checkPossibilityToSend");
        action.setParams({
            'recordId' : component.get('v.recordId')
        });
        action.setCallback(this, function(a) {
            let state = a.getState();
                if (state === "SUCCESS"){
                let result = a.getReturnValue();
                console.log('can send='+result.success);
                if(result.success){
                    helper.generateRecord(component,event,helper);
                }else{
                    console.log('can send result message='+result.resultMessage);
                    component.set("v.spinnerControl" , false);
                    helper.showToast(component, event, helper, result.resultMessage, 'error');
                }
            }
        });
        $A.enqueueAction(action);
        
    }
    
    
})