({
    
      init : function(component, event, helper) {
        component.set('v.showSpinner', true);        
        let action = component.get("c.getReasonOfCancellation");
        action.setParams({ "poID": component.get("v.recordId")
                         });
        action.setCallback(this, function (response) {
            let state = response.getState();
            let retValue = response.getReturnValue(); 
            console.log('retValue' + retValue);
            if (state === "SUCCESS" && retValue.success) { 
               component.set('v.reasonsList',  JSON.parse(retValue.fieldName));
               component.set('v.showSpinner', false);
            }else{
                helper.showToast(component, event, helper, 'Error in get information' , 'error');
                component.set("v.showSpinner" , false);
                $A.get("e.force:closeQuickAction").fire();
            }
            
        });       
        $A.enqueueAction(action);    
    },
    
    saveReason : function(component, event, helper) {
        if (component.get("v.reason") == "Other" && component.get("v.otherReason") == null ) {        
                component.set('v.defaultValue','Error while Updating');
                component.set('v.showSpinner',false);
                helper.showToast(component, event, helper, 'Warning: '+'Please enter a better explenation of Cancellation reason', 'error');
        }else{
            
        var action = component.get("c.changeStatustoCancelled");
        action.setParams({ poID : component.get("v.recordId"),
                          reason :	component.get("v.reason"),
                          otherReason : component.get("v.otherReason")});
        //Setting the Callback
        action.setCallback(this, function(a) {
            var state = a.getState();
            //check if result is successfull 
            if (state == "SUCCESS") {        
                component.set('v.showSpinner',false);
                helper.showToast(component, event, helper, 'Purchase Order is requested for Cancellation', 'success'); 
                $A.get("e.force:refreshView").fire();
            } else if (state == "ERROR") {
                  component.set('v.defaultValue','Error while Updating');
                  component.set('v.showSpinner',false);
                  var errors = a.getError();
                  console.log("error1s" + errors);
                  var fmsg = errors[0].message;
                  helper.showToast(component, event, helper, 'Warning: '+fmsg, 'error');
                    
            }
             $A.get("e.force:closeQuickAction").fire();
            
        });
        }
 
        $A.enqueueAction(action);
    },
    
    
     showToast : function(component, event, helper, message, type) {
        
        component.find('notifLib').showToast({
            "title": message,
            "message": '',
            "variant": type
        }); 
    } 
})