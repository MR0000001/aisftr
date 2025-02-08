({
    init : function(component, event) {      
        component.set("v.spinnerControl",true);      
        let recordId = component.get("v.recordId"); 
        let action = component.get("c.assignToPartner"); 
        
        action.setParams({
            "recordId": recordId
        });
        action.setCallback(this, function(a) {         
            let result = a.getReturnValue(); 
            console.log("@@@ Result is: ", result);
            let toastEvent = $A.get("e.force:showToast");
            if(result.success) {   
                toastEvent.setParams({
                    title : $A.get("$Label.XC_CL_Success"),
                    message: result.result,
                    key: 'info_alt',
                    type: 'success',
                    mode: 'dismissible',
                    mode: 'pester'
                });
                $A.get('e.force:refreshView').fire();
            } else { 
                toastEvent.setParams({
                    title : $A.get("$Label.XC_CL_Warning"),
                    message: result.result,
                    key: 'info_alt',
                    type: 'error',
                    mode: 'dismissible',
                    mode: 'pester'
                });    
            }       
            $A.get('e.force:closeQuickAction').fire();   
            component.set("v.spinnerControl", false);  
            toastEvent.fire();       
        });
        $A.enqueueAction(action);    
    }

})