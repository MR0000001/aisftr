({
	doInit: function (cmp, event, helper) {
		var recordId = cmp.get("v.recordId");
		console.log("recordId " + recordId); 
		var number = "";
		cmp.set("v.caseNumber", "1");
		console.log("cmp.get(v.caseNumber) " + cmp.get("v.caseNumber")); 
		/*Informacion logica POP UPS*/
		/*var action = cmp.get('c.isClosedWorkOrderMethod');
		action.setParams({
			recordId: recordId
		});
		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				cmp.set("v.isClosedWorkOrder", response.getReturnValue());
				console.log('isClosedWorkOrder callback' + response.getReturnValue());
			} else console.log('isClosedWorkOrder.setCallback fail');
		});
		$A.enqueueAction(action);*/
	},

	newRequest: function (cmp, event, helper) {
		var caseNumber;
		var actionAsset = cmp.get('c.createCase');
		var recordId = cmp.get("v.recordId");
		console.log("recordId " + recordId);
		actionAsset.setParams({
			recordId: recordId
		});
		actionAsset.setCallback(this, function (response) {
			var state = response.getState();
			if (state = "SUCCESS") {
                var result = response.getReturnValue();
                if(result.success){
				caseNumber = result.objectInfo;
				
				console.log('asset callback' + response.getReturnValue());
				cmp.set("v.caseNumber", caseNumber);
				console.log("cmp.get(v.caseNumber) " + cmp.get("v.caseNumber")); 
				var a = cmp.get('c.openModel');
				$A.enqueueAction(a);
				
                }
                	else{
                        helper.showToast(cmp, result.resultMessage, "error");
                	}
            }else{
                helper.showToast(cmp, $A.get("$Label.c.XC_CL_CreateCaseMessageError"), "error");
			}
		});

		$A.enqueueAction(actionAsset);
	},

	openModel: function (cmp) {
		// for Display Model,set the "isOpen" attribute to "true"
		cmp.set("v.isOpen", true);
	},
	closeModel: function (cmp) {
		// for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
		cmp.set("v.isOpen", false);
	},
	refreshModel: function (cmp) {
		// for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
		cmp.set("v.isOpen", false);

		$A.get('e.force:refreshView').fire();
	}, 

    showToast : function(component, message, type) {
        component.find('notifLib').showToast({
            "title": message,
            "message": '',
            "variant": type
        });
    }
})