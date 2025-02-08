({
    doInit : function(component, event) {
        component.set("v.spinnerControl",true);
        
        var recordId = component.get("v.recordId"); 
        var action = component.get("c.checkBillingProfile");
        
        action.setParams({
            "recordId": recordId
        });
     
        action.setCallback(this, function(a) {
            
            var result = a.getReturnValue();
            console.log("@@@ Result is: " + result.success + " And record is: " + recordId);
            
            if(result.success) {
                component.set("v.spinnerControl", false);
                $A.get('e.force:closeQuickAction').fire();
                $A.get('e.force:refreshView').fire();
                                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : $A.get("$Label.XC_CL_Warning"),
                    mode: 'sticky',
                    type:'success',
                    mode: 'dismissible',
                    mode: 'pester',
                    duration : 20,
                    message: result.message
                });
                toastEvent.fire();       
            } else {
                            
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : $A.get("$Label.XC_CL_Warning"),
                    mode: 'sticky',
                    type:'error',
                    mode: 'dismissible',
                    mode: 'pester',
                    duration : 20,
                    message: result.message
                });
                                
                toastEvent.fire();
                component.set("v.spinnerControl", false);
                $A.get('e.force:closeQuickAction').fire();
            }
                       
        });
        $A.enqueueAction(action);
    }
})