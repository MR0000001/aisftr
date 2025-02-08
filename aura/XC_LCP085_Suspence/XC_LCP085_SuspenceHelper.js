({
    myfunction : function(component, event, helper){
        var workspaceAPI = component.find("workspace");
        var action = component.get("c.getSwitchUtil");
        action.setParams({
            'recordId' : component.get("v.recordId")
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS"){
                var result = a.getReturnValue();
                console.log('result='+result.success);
                var spinner = component.find("mySpinner");
                $A.util.toggleClass(spinner, "slds-hide");
                if(result.success){
                    helper.showToast(component, event, helper, result.resultMessage, 'success'); 
                } else {
                    console.log('result error='+result.resultMessage);
                    helper.showToast(component, event, helper, result.resultMessage, 'error');
                } 
                $A.get("e.force:closeQuickAction").fire();
                $A.get("e.force:refreshView").fire();
            }
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