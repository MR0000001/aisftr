({
    init : function(component, event, helper) {
        component.set('v.showSpinner', true);        
        let action = component.get("c.retrieveErrorLog");
        action.setParams({ "recordId": component.get("v.recordId")
                         });
        action.setCallback(this, function (response) {
            let state = response.getState();
            let retValue = response.getReturnValue(); 
            console.log('retValue' + retValue);
            if (state === "SUCCESS" && retValue.success) {
                console.log('retValue ' + retValue.objectInfo);
                
                if(retValue.fieldName != 'found3PL'){
                    component.set('v.show3PLError', false);
                    
                }
                if(retValue.fieldName2 != 'foundSAP'){
                    component.set('v.showSAPError', false);
                }
                if(retValue.fieldName2 != 'foundSAP' && retValue.fieldName != 'found3PL'){
                     helper.showToast(component, event, helper, $A.get("$Label.c.giic_ErrorClearErrorLogs")  , 'error');
                     $A.get("e.force:closeQuickAction").fire();
                }
                component.set('v.showSpinner', false);
            }else{
                helper.showToast(component, event, helper, retValue.resultMessage , 'error');
                component.set("v.showSpinner" , false);
                $A.get("e.force:closeQuickAction").fire();
            }
            
        });       
        $A.enqueueAction(action);    
    },
    
    
    
    deleteErrorLog : function (component, event, helper) { 
        console.log('selectedRows' + component.get("v.errorLogProcessName"));
        let clear3PLError = component.get("v.clear3PLError");
        let clearSAPError = component.get("v.clearSAPError");
        console.log('clear3PLError = '+clear3PLError);
        console.log('clearSAPError = '+clearSAPError);
        let action = component.get("c.deleteErrorLog");
        action.setParams({ "recordId"        : component.get("v.recordId"),
                           "clear3PLError"   : clear3PLError,
                           "clearSAPError"   : clearSAPError
                         });
        
        action.setCallback(this, function (response) {
            let state = response.getState();
            let retValue = response.getReturnValue(); 
            if (state === "SUCCESS" && retValue.success) {
                helper.showToast(component, event, helper, retValue.resultMessage, 'success');
                $A.get("e.force:closeQuickAction").fire(); 
            }
            else{
                if(retValue!=null){
                    helper.showToast(component, event, helper, retValue.resultMessage, 'error');
                    component.set("v.showSpinner" , false);
                }else{
                    helper.showToast(component, event, helper, $A.get("$Label.c.giic_GenericError") , 'error');
                    component.set("v.showSpinner" , false);
                }
            }
            $A.get('e.force:refreshView').fire();
        }); 
        
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