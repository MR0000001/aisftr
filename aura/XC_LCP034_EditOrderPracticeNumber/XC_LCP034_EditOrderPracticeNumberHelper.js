({
	init : function(component, event) {
		component.set("v.spinnerControl",true);
		var idToPass = component.get("v.IdFromMobile");
		if(component.get("v.recordId")==null){
			component.set("v.recordId", idToPass );
		}
		var action = component.get("c.checkFinancialApprovalValue");
		action.setParams({orderId: component.get("v.recordId")});
		action.setCallback(this, function(response) {
			var state = response.getState();
			var result = response.getReturnValue();
			if(state=='SUCCESS'){
				component.set("v.showModal", result.isValid);
				if(!result.isValid){
					component.find('notifLib').showToast({
						title: $A.get("$Label.XC_CL_Warning"),
						variant: 'info',
						mode: 'dismissible',
						duration : 20,
						message: result.resultMessage
					});
					var dismissActionPanel = $A.get("e.force:closeQuickAction");
					dismissActionPanel.fire();
					$A.get('e.force:closeQuickAction').fire();
				}  
				component.set("v.spinnerControl", false);
			} else {
				component.set("v.spinnerControl", false);
			}
		});

		$A.enqueueAction(action);
	},

	submit : function(component, event) {
		event.preventDefault();
		component.set("v.spinnerControl",true);
		var fields = event.getParam("fields");
		var practiceNumber = fields["XC_PracticeNumber__c"];
		var action = component.get("c.updateOrderPracticeNumber");
		action.setParams({orderId: component.get("v.recordId"), practiceNumber: practiceNumber});
		action.setCallback(this, function(response) {
			component.set("v.showModal", true);
			var state = response.getState();
			var result = response.getReturnValue();
			if(state=='SUCCESS'){
				var variant = 'success';
				if(!result.success){
					variant = 'error';
				}
				component.find('notifLib').showToast({
					title: $A.get("$Label.XC_CL_Warning"),
					variant: variant,
					mode: 'dismissible',
					duration : 20,
					message: result.resultMessage
				});
				component.set("v.spinnerControl", false);
				$A.get('e.force:closeQuickAction').fire();
				$A.get('e.force:refreshView').fire();   
			} else {
				component.set("v.spinnerControl", false);
			}
		});

		$A.enqueueAction(action);
	},

	checkValueNotEmpty : function(component, event){
		var partNumField = component.find("partNum");
		if(partNumField){
			var pratNumValue = partNumField.get("v.value");
			var disabledValue = pratNumValue=='';
			component.set("v.disabled",disabledValue);
		}
	},
	
	close : function(component, event) { 
		$A.get("e.force:closeQuickAction").fire();
	}
})