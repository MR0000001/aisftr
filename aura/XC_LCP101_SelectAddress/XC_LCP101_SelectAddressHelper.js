({
    doInit: function (component, event) {
        console.log('inDoInit');
        //component.set("v.spinnerControl", true);
        component.set("v.spinnerControl", false);
		this.getTableData(component, event);
		
	},
	
	getTableData : function (component, event) {
		this.getColumn(component, event);
        this.getListAddress(component, event);
        
	},
    
    
    getListAddress: function (component, event) {
        let accountId = component.get("v.accountId");
        let applyIstallCondition = component.get("v.isAssetCreation");
        let action = component.get("c.getListAddress");
        action.setParams({ "recordId": accountId, "applyIstallCondition": applyIstallCondition });
        action.setCallback(this, function (response) {
            
            let res = response.getReturnValue();
            console.log('getListAddress res='+res);
            if (res === null || res[0] === null) {
                let message = (component.get('v.isAssetCreation')) ? $A.get("$Label.c.XC_CL_Asset_NoIstallAddressForThisAccount")
                                                                   : $A.get("$Label.c.XC_CL_WorkOrder_NoAddressForThisAccount");
                this.closeQuickAndErrorMessage(component, event, message);
            }
            else{
            	component.set("v.data", res.addressList);
                component.set("v.addressReady", true);
            }
        });
        
        $A.enqueueAction(action);
    },
    
    getColumn: function (component, event) {
        let column = [{ label: $A.get('$Label.c.XC_CL_Address'), fieldName: 'Name', type: 'text' },
                      { label: $A.get('$Label.c.XC_CL_Municipality'), fieldName: 'XC_Municipality__c', type: 'type' }];
        
        component.set("v.columns", column);
    },

    createObject: function (component, event, helper) {
        if(component.get('v.isAssetCreation')){
            helper.createAsset(component, event, helper);
        }else if(component.get('v.billingProfLineItem')!=''){
            helper.callZuoraForUpdateAddress(component, event, helper);
        }else{
            helper.createWoHelper(component, event, helper);
        }
    },
    
    
    callZuoraForUpdateAddress : function (component, event, helper) {
        component.set('v.spinnerControl2', true);
        let selectedRow = component.get("v.SelectedRow")[0];
        let action = component.get("c.callZuoraForUpdate");
        action.setParams({ "addressId": selectedRow.Id,
                           "lineItemId": component.get("v.billingProfLineItem") 
                         });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS"){
            let res = response.getReturnValue();
            
            	if (res != null && res.success) {
              		helper.showMessage(component, event, helper, 'Customer Account correctly updated', 'success');
            	}
            else{
                var errorMessage = JSON.parse(res.resultMessage)[0];
            	helper.showMessage(component, event, helper, errorMessage.message, 'error');
            }
            }else{
                helper.showMessage(component, event, helper, 'Generic error', 'error');
            }
             component.set('v.spinnerControl2', false);
        });
         $A.enqueueAction(action);
    },

    createAsset: function (component, event, helper) {
        let recordType = component.get("v.recordTypeId");
        let selectedRow = component.get("v.SelectedRow")[0];
        $A.createComponent(
            "c:XC_LCP054_RedirectAsset",
            {
                    "recordTypeId" : recordType,
                    "fromContact" : true,
                    "contactId" : component.get("v.contactId"),
                    "accountId" : component.get("v.accountId"),
                    "catalogCategory" : component.get("v.catalogCategory"),
                    "catalog" : component.get("v.catalog"),
                    "podId" : selectedRow.Id,
                    "description" : component.get("v.description"),
                    "modelValue" : component.get("v.modelValue")
            },
            function(newButton, status, errorMessage){
                if(status === 'SUCCESS'){
                    $A.get("e.force:closeQuickAction").fire();
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                    
                }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            }
        );
        component.set("v.spinner", false);
    },
    
    createWoHelper: function (component, event, helper) {
        component.set('v.spinnerControl2', true);
        let workOrdCr = component.get("v.workOrderCreated");	
        
        if (workOrdCr==false) {
            component.set('v.workOrderCreated',true);
            
            let recordId = component.get("v.recordId");
            let selectedRow = JSON.stringify(component.get("v.SelectedRow")[0]);
            let action = component.get("c.createWorkOrder");
            
            action.setParams({
                "recordId": recordId,
                "selectedRow": selectedRow
            });
           
            action.setCallback(this, function (response) {
                
                let result = response.getReturnValue();
                
                if (result && result.success) {
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
                            "actionName": "view"
                        },
                        state: {
                            "c__recordId": result.recordId,
                            "c__closeSource" : false
                        }
                    };
                    component.set("v.targetPageReference", targetPageReference);
                    component.set('v.spinnerControl2', false);
                    helper.executeAptNavigation(component, event, helper);
                   
                } else {
                    if (!result.success && result.resultMessage) {
                        let errorMessage = result.resultMessage;
                        let toastEventWarn = $A.get("e.force:showToast");
                        toastEventWarn.setParams({
                            title: $A.get("$Label.c.XC_CL_Warning"),
                            message: errorMessage,
                            key: 'info_alt',
                            type: 'error',
                            mode: 'dismissible'
                        });
                        $A.get("e.force:closeQuickAction").fire();
                        toastEventWarn.fire();
                        component.set('v.spinnerControl2', false);
                    }
                }
            });
            
            $A.enqueueAction(action);
            
        }
        
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
    },
    
    
     showMessage : function(component, event, helper, message, type) {
        component.set("v.showSpinner",false);
        component.find('notifLib').showToast({
            "title": message,
            "message": '',
            "variant": type
        });
		setTimeout(function(){ 
            $A.get("e.force:closeQuickAction").fire();
        }, 1000);
    }
})