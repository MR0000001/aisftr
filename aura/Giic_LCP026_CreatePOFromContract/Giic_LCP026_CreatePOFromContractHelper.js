({
	init : function(component, event, helper) {
        let recordId = component.get("v.recordId");
        console.log('recordId = '+recordId);
        let action = component.get("c.retrieveInitialInfo");
        action.setParams({ "contractId" : recordId });
        action.setCallback(this, function (response) {
            let state = response.getState();
            let retValue = response.getReturnValue();
          
            if (state === "SUCCESS" && retValue.success) {
        	    component.set("v.legalEntity" , retValue.legalEntity);
                console.log('LegalEntity = '+retValue.legalEntity)
                component.set("v.contractNumber", retValue.fieldName);
                component.set("v.contractObject", retValue.objectInfo);
                component.set("v.priceBookId", retValue.fieldName2);
                
                component.set("v.filter1", "giic_LegalEntity__c = '"+retValue.legalEntity+"'");
                component.set("v.showSpinner" , false);
                component.set("v.showLookup" , true);
                console.log('ok');
                
            }else{
                  component.set("v.showSpinner" , false);
                  helper.showToast(component, event, helper, retValue.resultMessage , 'error');
                  component.set("v.showSpinner" , false);
                  $A.get("e.force:closeQuickAction").fire();
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
    
    validatePO : function(component, event, helper) {
        let contractObject = component.get("v.contractObject");
        
        let action = component.get("c.validatePurchaseOrder");
        action.setParams({ "contractObject" : contractObject,
                           "warehouseId" :    component.get("v.warehouseId"),
                           "priceBookId" :    component.get("v.priceBookId") });
        action.setCallback(this, function (response) {
            let state = response.getState();
            let retValue = response.getReturnValue();
          
            if (state === "SUCCESS" && retValue.success) {
                 component.set("v.showSpinner" , false);
                 component.set("v.numberOfProduct" , JSON.parse(retValue.fieldName5));
                 component.set("v.isModalOpen", true);
        	     
            }else{
                  component.set("v.showSpinner" , false);
                  helper.showToast(component, event, helper, retValue.resultMessage , 'error');
                  component.set("v.showSpinner" , false);
                  $A.get("e.force:closeQuickAction").fire();
            }
            
        });       
        $A.enqueueAction(action); 
    
    
    },
    
    
    createPO : function(component, event, helper) {
        let contractObject = component.get("v.contractObject");
        let action = component.get("c.createPurchaseOrder");
        action.setParams({ "contractObject" : contractObject,
                           "warehouseId" :    component.get("v.warehouseId"),
                           "priceBookId" :    component.get("v.priceBookId") });
        action.setCallback(this, function (response) {
            let state = response.getState();
            let retValue = response.getReturnValue();
          
            if (state === "SUCCESS" && retValue.success) {
                 component.set("v.showSpinner" , false);
        	     helper.showToast(component, event, helper, retValue.resultMessage , 'success');
				 helper.navigateTo(component, event, helper, retValue.recordId);       
            }else{
                  component.set("v.showSpinner" , false);
                  helper.showToast(component, event, helper, retValue.resultMessage , 'error');
                  component.set("v.showSpinner" , false);
                  $A.get("e.force:closeQuickAction").fire();
            }
            
        });       
        $A.enqueueAction(action); 
    
    
    },
    
    
    navigateTo: function(component, event, helper, newId) {
        var navService = component.find("navService");
        
        var pageReference = {
                "type": "standard__recordPage",
				"attributes": {
				"recordId": newId,
				"objectApiName": "gii__PurchaseOrder__c",
				"actionName": "view"
		}};
        event.preventDefault();
        navService.navigate(pageReference);
    }
    
})