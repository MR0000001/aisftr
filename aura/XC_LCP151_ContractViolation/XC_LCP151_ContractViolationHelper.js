({
	init : function(component, helper, event) {
        component.set("v.spinnerControl", true);
		var action = component.get("c.updateFLS");
        action.setParams({
            workOrderId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            component.set("v.spinnerControl", false);
            let result = response.getReturnValue();
            let state = response.getState();
			let toastEvent = $A.get("e.force:showToast");
       		$A.get('e.force:refreshView').fire();
            if (result.success && state === "SUCCESS"){
            	toastEvent.setParams({
                title : $A.get("$Label.c.XC_CL_Success"),
                message: $A.get("$Label.c.XC_CL_WorkOrder_SuccessUpdateStatus"),
                key: 'info_alt',
                type: 'success'
            	});  
                toastEvent.fire();
                $A.get('e.force:closeQuickAction').fire();
            } 
            else{
                let toastEvent = $A.get("e.force:showToast");
            	toastEvent.setParams({  
                title :  $A.get("$Label.c.XC_CL_WorkOrder_Error"),
                message: result.resultMessage,
                key: 'info_alt',
                type: 'error'
                });
                toastEvent.fire();
                $A.get('e.force:closeQuickAction').fire();
            }
        });
        $A.enqueueAction(action);
	}
})