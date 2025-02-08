({
    doInit: function (component, event) {
        console.log('inDoInit');
        component.set("v.spinnerControl", true);
        
        
        this.checkProdCategory(component, event);
        
    },
    
    
    
    
    
    
   
    
    
    createWoHelper: function (component, event, helper) {
        component.set('v.spinnerControl2', true);
        
         let navService = component.find("navService");
         
        let recordId = component.get("v.recordId");
        
        let action = component.get("c.createWorkOrder");
        
        action.setParams({
            "recordId": recordId
            
        });
        
        action.setCallback(this, function (response) {
            
            let result = response.getReturnValue();
            
            if (result && result.success) {
                  component.set("v.spinnerControl", false);
                console.log('recordId->' + result.recordId);
                component.set('v.workorderId', result.recordId);
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: result.errorMessage,
                    message: $A.get('$Label.c.XC_CL_WorkOrder_WoCreated'),
                    key: 'info_alt',
                    type: 'success',
                    mode: 'dismissible'
                });
                
                toastEvent.fire();
                let targetPageReference = {
                    type: 'standard__recordPage',
                    attributes: {
                        "recordId": result.recordId,
                        "objectApiName": "WorkOrder",
                        "actionName": "view"
                    }};
                   navService.navigate(targetPageReference);
                
                component.set("v.targetPageReference", targetPageReference);
                component.set('v.spinnerControl2', false);
                
                $A.get("e.force:closeQuickAction").fire();
            } else {
                if (!result.success && result.resultMessage) {
                    let errorMessage = result.resultMessage;
                    let toastEventError = $A.get("e.force:showToast");
                    toastEventError.setParams({
                        title: $A.get("$Label.c.XC_CL_Warning"),
                        message: errorMessage,
                        key: 'info_alt',
                        type: 'error',
                        mode: 'dismissible'
                    });
                    $A.get("e.force:closeQuickAction").fire();
                    toastEventError.fire();
                    component.set('v.spinnerControl2', false);
                }
            }
        });
        
        $A.enqueueAction(action);
        
        
        
    },
    
    checkProdCategory: function (component, event, helper) {
        console.log('ID' + component.get("v.recordId"));
        let recordId = component.get("v.recordId");
        let action = component.get("c.hasCommercialVisitForOpportunity");
        action.setParams({ "recordId": recordId });
        action.setCallback(this, function (response) {
            
            let res = response.getReturnValue();
            console.log('hasCommercialVisitResponse' + res);
            if(!res) {
                this.closeQuickAndErrorMessage(component, event, $A.get("$Label.c.XC_CL_WorkOrder_NoWoWithThisCategory"));
            } else {
                this.createWoHelper(component, event, helper);
            }
        });
        
        $A.enqueueAction(action);
    },
    
    openTab: function (component, event, helper) {
        let isMobile = component.get("v.isMobile");
        let targetPageReference = {
            type: 'standard__recordPage',
            attributes: {
                recordId: component.get('v.workorderId'),
                objectApiName: 'WorkOrder',
                actionName: 'view'
            }
        };
        component.set("v.targetPageReference", targetPageReference);
        
        (isMobile) ? helper.navigateTo(component, event)
        : helper.openTabNavigation(component, event);
    },
    
    closeQuickAndErrorMessage: function (component, event, message) {
        $A.get("e.force:closeQuickAction").fire();
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: $A.get("$Label.c.XC_CL_Warning"),
            message: message,
            key: 'info_alt',
            type: 'error',
            mode: 'dismissible'
        });
        toastEvent.fire();
    }
})