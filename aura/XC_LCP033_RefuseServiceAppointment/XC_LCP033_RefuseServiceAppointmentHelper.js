({
	updateServiceAppointment : function(component, event) {
		var insertRefReason = component.get("v.componentRecord.XC_Refusing_Reason__c");
		var isRefutable = component.get("v.componentRecord.XC_IsRefutable__c");
		var statusSerApp = component.get("v.componentRecord.Status");

		if(!isRefutable) {
			if(!insertRefReason || insertRefReason == null) {
				component.set("v.insertRefusingReason", true);
			} else {
				this.doChanges(component, event);
			}
		} else {
			this.noButton(component, event);
			var toastEvent = $A.get("e.force:showToast");
			toastEvent.setParams({
				'title': $A.get('{!$Label.c.XC_CL_Error}'),
				'type': 'error',
				'mode': 'dismissable',
				'message': $A.get('{!$Label.c.XC_CL_ServiceAppointment_ErrorStatus}')
			});
			toastEvent.fire();
		}
	},

	doChanges : function(component, event) {
        component.set("v.spinnerControl",true);   
		var serAppId = component.get("v.recordId");
		var refReason = component.get("v.newReason");
		var toastEvent = $A.get("e.force:showToast"); 
		var act = component.get("c.changesSerAppointment");
		act.setParams({
			"serviceAppId" : serAppId,
			"newRefusingReason" : refReason,
		});
		act.setCallback(this, function(response) {
			var state = response.getState(); 
			if(state == 'SUCCESS') {
				var resultMap = response.getReturnValue();

				if(resultMap.success) {
					toastEvent.setParams({
						'title': $A.get('{!$Label.c.XC_CL_CPAB_Success}'),
						'type': 'success',
						'mode': 'dismissable',
						'message': resultMap.message
						});
					toastEvent.fire();            
					setTimeout(function(){ location.reload(); }, 3000);
					this.noButton(component, event);
				} else {
					toastEvent.setParams({
						'title': $A.get('{!$Label.c.XC_CL_Error}'),
						'type': 'error',
						'mode': 'dismissable',
						'message': resultMap.message
					});
					toastEvent.fire();
					this.noButton(component, event);
				} 				
			} else {
                this.noButton(component, event);
				console.log('ERROR');
			}
		});
		$A.enqueueAction(act);
	},

	noButton : function(component, event) {
        component.set("v.spinnerControl", false);
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    }, 
})