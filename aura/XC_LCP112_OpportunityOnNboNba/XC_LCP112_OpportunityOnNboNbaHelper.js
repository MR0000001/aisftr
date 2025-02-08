({
    createOpportunity : function(component, event, helper){
        var action = component.get("c.createOpportunity");
        action.setParams({
            'recordId' : component.get("v.recordId")
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS"){
                var result = a.getReturnValue();
                console.log('result='+result.success);              
                if(result.success){
                    helper.showToast(component, event, helper, result.resultMessage, 'success'); 
                } else {
                    console.log('result error='+result.resultMessage);
                    helper.showToast(component, event, helper, result.resultMessage, 'error');
                } 
                
            }
        });            
        $A.enqueueAction(action);
    },
    
    showToast : function(component, event, helper, message, type) {
        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
        component.find('notifLib').showToast({
            "title": message,
            "message": '',
            "variant": type
        });
        $A.get("e.force:refreshView").fire();
        $A.get("e.force:closeQuickAction").fire();
    },
})