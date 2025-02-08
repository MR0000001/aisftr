({
	updateWorkOrder : function (component, event) {

		var insertRefReason = component.get("v.componentRecord.XC_Refusing_Reason__c");
        var statusWorkOrder = component.get("v.componentRecord.Status");
        if(statusWorkOrder=== 'Assigned') {
            if(insertRefReason === null) {
                component.set("v.insertRefusingReason", true);
            } else {
                this.doChanges(component, event);
            }
        } else {
            this.noButton(component, event);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                'title': $A.get('{!$Label.c.XC_CL_Error}'),
                'type': 'error',
                'mode': 'dismissable',
                'message': $A.get('{!$Label.c.XC_CL_WorkOrder_ErrorStatus}')
            });
            toastEvent.fire();
        }
	},

	doChanges : function(component, event) {

		var workOrderId = component.get("v.recordId");
		var toastEvent = $A.get("e.force:showToast"); 
		var refReason =  component.get("v.newReason");
		var act = component.get("c.changesWorkOrder");
		act.setParams({
			"workOrderId" : workOrderId,
			"newRefusingReason" : refReason
		});
		act.setCallback(this, function(response) {
			var state = response.getState();
			if(state === 'SUCCESS') {
				var resultMap = response.getReturnValue();

				if(resultMap.status == 'success') {
					this.noButton(component, event);
					toastEvent.setParams({
						'title': $A.get('{!$Label.c.XC_CL_CPAB_Success}'),
						'type': 'success',
						'mode': 'dismissable',
						'message': resultMap.message
						});
					toastEvent.fire();            
					setTimeout(function(){ location.reload(); }, 3000);
				} else if (resultMap.status == 'error') {
					this.noButton(component, event);
					toastEvent.setParams({
						'title': $A.get('{!$Label.c.XC_CL_Error}'),
						'type': 'error',
						'mode': 'dismissable',
						'message': resultMap.message
					});
					toastEvent.fire();
				}
				
			} else {
				alert('ERROR');
			}
		});
		$A.enqueueAction(act);
	},

	noButton : function(component, event) {

        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    }, 
})