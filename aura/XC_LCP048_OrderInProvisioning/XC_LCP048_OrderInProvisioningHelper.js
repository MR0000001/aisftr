({
    checkCompliance1Status : function(component,event,helper){      // NM LR - 11/01/2019 - ESCEP-802
        var action = component.get("c.checkCompliance1Status");
        action.setParams({
            'recordId' : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var result = response.getReturnValue();
                if(result) {
                    this.changeStatus(component,event,helper);
                } else {
                    helper.showToast(component, event, helper, $A.get('{!$Label.c.XC_CL_CompleteComplianceVerification}'), 'error');
                    $A.get("e.force:closeQuickAction").fire();
                }
            }
        });
        $A.enqueueAction(action);
    },


	changeStatus : function(component,event,helper){
        var firstAction = component.get("c.insertProvisioningSteps");
        firstAction.setParams({
            'recordId' : component.get("v.recordId")
        });
        firstAction.setCallback(this, function(a) {
            var action = component.get("c.updateOrderStatus");
            action.setParams({
                'recordId' : component.get("v.recordId")
            });
            action.setCallback(this, function(a) {
                var state = a.getState();
                if (state === "SUCCESS"){
                    var result = a.getReturnValue();
                    console.log('result='+result.success);
                    if(result.success){
                        var spinner = component.find("mySpinner");
                        
                        $A.util.toggleClass(spinner, "slds-hide");
                        $A.get("e.force:closeQuickAction").fire();
                        helper.showToast(component, event, helper, result.resultMessage, 'success');
                        
                    
                        setTimeout(
                            function(){
                                $A.get('e.force:refreshView').fire();
                            }, 
                        400); 
                    } else {
                        console.log('result error='+result.resultMessage);
                        helper.showToast(component, event, helper, result.resultMessage, 'error');
                        $A.get("e.force:closeQuickAction").fire();
                    }
                }
            });            
            $A.enqueueAction(action);
        });
        $A.enqueueAction(firstAction); 
    },
    
    showToast : function(component, event, helper, message, type) {
        component.find('notifLib').showToast({
            "title": message,
            "message": '',
            "variant": type
        });
        
      
    },
	
})