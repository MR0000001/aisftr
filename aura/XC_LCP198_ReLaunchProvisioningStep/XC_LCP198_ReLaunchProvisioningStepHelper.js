({
    doInit : function(component, event) {
        component.set("v.spinnerControl",true);
        
		var recordId = component.get("v.recordId"); 
        var action = component.get("c.relaunchProvisioningStep");
        
        action.setParams({
			"recordId" : recordId
        });
     
        action.setCallback(this, function(a) {
            
            var result = a.getReturnValue();
            console.log("@@@ Result is: " + result.success + " And record is: " + recordId);
            
            if(result.success) {

                                
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
                component.set("v.spinnerControl", false);
                $A.get('e.force:closeQuickAction').fire();
                $A.get('e.force:refreshView').fire();
				/*setTimeout(function () {
					$A.get('e.force:refreshView').fire();
				}, 4000);*/
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