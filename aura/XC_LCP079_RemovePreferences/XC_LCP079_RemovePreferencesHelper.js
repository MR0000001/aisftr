({
 init : function(component, event, helper) {    
        component.set("v.spinnerControl",true);
        var recordId = component.get("v.recordId");  
        var action = component.get("c.removePreferences");
        action.setParams({
            "recordId": recordId
        });
        action.setCallback(this, function(a) {            
            var result = a.getReturnValue();
            console.log("@@@ " + a.getState);
            console.log(result);            
            if(result.success) {
               component.set("v.spinnerControl", false);
               $A.get('e.force:closeQuickAction').fire();
               $A.get('e.force:refreshView').fire();
               console.log(result);
               helper.showToast(component, $A.get("$Label.c.XC_CL_Success"), 'success');
            } else {
                
                component.set("v.spinnerControl", false);
                $A.get('e.force:closeQuickAction').fire(); 
                helper.showToast(component, result.result, 'error');
            }                 
        });
        $A.enqueueAction(action);
    },
    
        showToast : function(component, message, type) {
        component.set("v.spinnerControl",false);
        component.find('notifLib').showToast({
            "title": message,
            "message": '',
            "variant": type
        });
         $A.get("e.force:closeQuickAction").fire();
    }
    
})