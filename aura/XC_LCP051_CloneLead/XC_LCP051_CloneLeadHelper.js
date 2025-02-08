({
    
    doInit : function(component, event) {   
        
        var action = component.get("c.isSystemAdmin");
        action.setCallback(this, function(response) {
             var state = response.getState();
             var retValue = response.getReturnValue();
            if (state === "SUCCESS" && retValue)  {
                component.set("v.isSystemAdmin",true);
                component.set("v.disableCheckBox",false);
                //component.set("v.executeAssignment",false);
            }
          }); 
          $A.enqueueAction(action);
    },
    
	/*assignLeadCheckedHelper : function(component, event) {
        
        var controlCheck = component.get('v.executeAssignment');
        if(controlCheck) {
            component.set('v.executeAssignment', false);
        }
        else{
            component.set('v.executeAssignment', true);
        }
    },*/
    
    cancel :  function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    
    createClone :  function(component, event, helper) {
        component.set("v.spinnerControl",true);
        var action = component.get("c.cloneNewLead");
        action.setParams({
            'recordId' : component.get("v.recordId"),
            'productCategoryOfInterest' : component.get("v.productCategoryOfInterest"),
            'executeAssignment' : component.get("v.executeAssignment")
            });
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS"){
                var result = a.getReturnValue();
                if(result.success){
                    console.log('idClone= '+result.recordId);
                    helper.showToast(component, event, helper, $A.get("$Label.c.XC_CL_LeadCorrectlyCloned") , "success");
                   
                    /*var navigateEvent = $A.get("e.force:navigateToSObject");
        			navigateEvent.setParams({ "recordId": result.recordId, "slideDevName": "detail", "isredirect":true });            
                    navigateEvent.fire();*/
                    helper.navigateToLeadClone(component, event, helper, result.recordId);
                   }
                else{
                   helper.showToast(component, event, helper, result.resultMessage, "error");
                }
            }
        });
        $A.enqueueAction(action);
        
    },

    navigateToLeadClone : function(component, event, helper, newRecordId) {
        var targetPageReference = {
            type: 'standard__recordPage',
            attributes: {
                "recordId": newRecordId,
                "actionName": "view"
            },
            state: {
                "c__recordId": newRecordId,
                "c__closeSource" : false
            }
        };
        component.set("v.targetPageReference", targetPageReference);
        helper.executeAptNavigation(component, event, helper);
    },
    
    showToast : function(component, event, helper, message, type) {
        component.set("v.spinnerControl",false);
        component.find('notifLib').showToast({
            "title": message,
            "message": '',
            "variant": type
        });
         $A.get("e.force:closeQuickAction").fire();
    }
    
    
})