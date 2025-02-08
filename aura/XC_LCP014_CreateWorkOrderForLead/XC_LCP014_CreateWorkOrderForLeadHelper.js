({
    doInit: function (component, event) {
        component.set("v.spinnerControl", true);
        this.checkProdCategory(component, event);
	},
    
    checkProdCategory: function (component, event) {
        console.log('ID' + component.get("v.recordId"));
        let recordId = component.get("v.recordId");
        let action = component.get("c.hasCommercialVisitForLead");
        action.setParams({ "recordId": recordId });
        action.setCallback(this, function (response) {
            let res = response.getReturnValue();
            console.log('hasCommercialVisitResponse' + res);
            if(!res.check) {
                this.closeQuickAndErrorMessage(component, event, res.resultMessage);
            } else {
				if(!res.resultWrapper.success) {
					this.closeQuickAndErrorMessage(component, event, res.resultWrapper.resultMessage);
				}
				else {
					console.log('recordId -> ' + res.resultWrapper.recordId);
                    component.set('v.workorderId -> ', res.resultWrapper.recordId);
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: $A.get('$Label.c.XC_CL_Success'),
                        message: $A.get('$Label.c.XC_CL_WorkOrder_WoCreated'),
                        key: 'info_alt',
                        type: 'success',
                        mode: 'dismissible'
                    });
               
                    toastEvent.fire();
                    
                    let navService = component.find("navService");
        			let pageReference = {
                		"type": "standard__recordPage",
						"attributes": {
							"recordId": res.resultWrapper.recordId,
							"actionName": "view"
						}
					};
					navService.navigate(pageReference);

					component.set('v.spinnerControl2', false);
					component.set('v.spinnerControl', false);
					$A.get("e.force:closeQuickAction").fire();
				}
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
            mode: 'dismissible',
            mode: 'pester'
        });
        toastEvent.fire();
    }
})