({
	doInit : function(component, event, helper) {
        component.set("v.showSpinner",true);
		helper.init(component, event, helper);
	},
    
    openLines  : function(component, event, helper) {
        if(!component.set("v.showLineComponent005")){
    		component.set("v.showLineComponent005", true);
        }else{
            component.set("v.showLineComponent005", false);
        }
    },
    
    changeGroup  : function(component, event, helper) {
         var purchaseOrganizationToDefinition = component.get("v.purchaseGroupToDefinition");
         var selectedOptionValue = event.getParam("value");
         for(var key in purchaseOrganizationToDefinition){
            if(purchaseOrganizationToDefinition[key].key == selectedOptionValue){
                 var definition = purchaseOrganizationToDefinition[key].value;
         		 component.set("v.definitionOfPurchasesGroup", definition);
                 component.set("v.permitSave",false);
            }
         }
        
        helper.savePG(component, event, helper);
        if(component.get("v.purchasesGroup")!=undefined && component.get("v.purchasingOrganization")!=undefined && component.get("v.purchasingOrganization")!=''){
             component.set("v.organizationDataOK", false);
        }
        
    },
    
    changeOrganization : function(component, event, helper) {
         var purchaseOrgToOrgDefinition = component.get("v.purchaseOrgToOrgDefinition");
         var selectedOptionValue = event.getParam("value");
         for(var key in purchaseOrgToOrgDefinition){
            if(purchaseOrgToOrgDefinition[key].key == selectedOptionValue){
                 var definition = purchaseOrgToOrgDefinition[key].value;
         		 //component.set("v.definitionOfPurchasesGroup", definition);
                 component.set("v.permitSave",false);
            }
         }
        
        helper.savePurchaseOrG(component, event, helper);
        if(component.get("v.purchasesGroup")!=undefined && component.get("v.purchasingOrganization")!=undefined && component.get("v.purchasingOrganization")!=''){
             component.set("v.organizationDataOK", false);
        }
        
    },
    
    closeModal : function(component, event, helper) {
      
            $A.get("e.force:closeQuickAction").fire();
    },
    
    savePG :  function(component, event, helper) {
        helper.savePG(component, event, helper);
    }
    
})