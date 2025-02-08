({
    init : function(component, event,helper) {
        
        component.set("v.spinnerControl",true);
        
        let recordId = component.get("v.recordId"); 
        
        let action = component.get("c.callExternalSystem");
        
        action.setParams({
            "recordId": recordId
        });
        
        action.setCallback(this, function(a) {
            
            let result = a.getReturnValue();
            console.log("@@@ " + a.getState);
            console.log(result);
            
            if(result.success) {
                component.set("v.spinnerControl", false);
                helper.showToast(component, event, helper, result.resultMessage, 'success');
                
                $A.get('e.force:closeQuickAction').fire();
                $A.get('e.force:refreshView').fire();
                
                
            } else {
                
                
                //component.set("v.spinnerControl", false);
                console.log('errror');
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : $A.get("$Label.XC_CL_Warning"),
                    mode: 'sticky',
                    type:'error',
                    mode: 'dismissible',
                    mode: 'pester',
                    duration : 20,
                    message: result.resultMessage
                });
                toastEvent.fire();
                $A.get('e.force:closeQuickAction').fire();

              
            }
            
            
        });
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