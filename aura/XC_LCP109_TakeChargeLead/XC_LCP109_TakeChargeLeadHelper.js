({
	initTakeCharge : function(component, event, helper) {
		var action = component.get("c.takeLeadChargeProcess");
        action.setParams({
            'leadId' : component.get("v.recordId")
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var result = response.getReturnValue();
                console.log('result='+result.success);
                console.log('resultMessage='+result.resultMessage);
                (result.success) ? helper.showToast(component, result.resultMessage, 'success')
                                 : helper.showToast(component, result.resultMessage, 'error');
            }
            else{
                console.debug('@@@@@ TakeChargeLead - Error on calling takeLeadChargeProcess...');
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);
	},

	showToast : function(component, message, type) {
		//var typeValue = type | 'warning';
		console.log('@#@#@#@#@#@ TakeChargeLead message: '+message);
		component.find('notifLib').showToast({
            "title": message,
            "message": '',
            "variant": type
        });

        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
    }
})