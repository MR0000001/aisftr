({
	resendSAP : function(component, event, helper) {
        let purchaseOrderId = component.get("v.recordId");
        let sapSelected = component.get("v.sapSelected");
        let logisticSelected = component.get("v.logisticSelected");
        console.log('sapSelected' +sapSelected);
        console.log('logisticSelected' +logisticSelected);
        console.log('purchaseOrderId' +purchaseOrderId);
        let action = component.get("c.resend");
        action.setParams({"recordId" : purchaseOrderId, 
                          "sapSelected" : sapSelected,
                          "logisticSelected" : logisticSelected});
        
        action.setCallback(this,function(response){
			  var state = response.getState();
              var returnValue = response.getReturnValue();
            if(state === "SUCCESS" && returnValue.success){
                var objectName = component.get('v.sobjecttype').substring(5);
                var objectNameF = objectName.slice(0, -3);
                helper.showToast(component, event, helper, objectNameF+" correctly resent", "success");
            }else{
                helper.showToast(component, event, helper, returnValue.resultMessage, "error");
            }
            $A.get("e.force:closeQuickAction").fire();
        
        });
        $A.enqueueAction(action);
		
	},
    
    showToast : function(component, event, helper, message, type) {
        component.find('notifLib').showToast({
        "title": message,
        "message": '',
        "variant": type
        });
    },
    
    
})