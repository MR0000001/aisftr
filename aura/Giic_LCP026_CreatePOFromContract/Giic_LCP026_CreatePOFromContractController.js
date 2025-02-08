({
	doInit : function(component, event, helper) {
        component.set("v.showSpinner" , true);
		helper.init(component, event, helper);
        
	},
    
       handleCancel : function(component, event, helper) {
        
        $A.get("e.force:closeQuickAction").fire();
    },
    
    
    handleSave :  function(component, event, helper) {
        component.set("v.showSpinner" , true);
        helper.validatePO(component, event, helper);
    },
    
    
    handleYes : function(component, event, helper) {
        component.set("v.showSpinner" , true);
        helper.createPO(component, event, helper);   
    },
    
     handleNo : function(component, event, helper) {
        
       component.set("v.isModalOpen", false);
    }
})