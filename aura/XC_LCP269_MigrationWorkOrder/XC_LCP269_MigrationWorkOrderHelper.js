({
	handleInit: function(component, event, helper) {
        
        console.log('>>> HANDLE INIT - START');
        var action = component.get("c.createWOFromAsset");
        action.setParams({
            recordId: component.get("v.recordId"),
            assts: null
        });
        action.setCallback(this, function(res) {
            var value = res.getReturnValue();
            console.log('>>> HANDLE INIT - '+res.getState()+' - XC_SC065_MigrationWorkOrderBatch.createWOFromAsset');
            if(Object.keys(value).length !== 0){
                helper.showToastMethod(value[Object.keys(value)[0]], 'Error');
            } else {
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);
        
    },
    
    showToastMethod : function(message, typeMessage){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": typeMessage.charAt(0).toUpperCase() + typeMessage.slice(1) + "!",
            "message": message,
            "type": typeMessage
        });
        toastEvent.fire();
    }
})