({
	manageData : function(component, event, helper) {
         
          helper.manageForm(component, event, helper);   
      
            
	},
        
    
    closeW : function(component, event, helper) {
    	component.set("v.isOpenWarehouse" , false);
    
	},
    
     closeB : function(component, event, helper) {
    	component.set("v.isOpenBudget" , false);
    
	},
    
    closeM : function(component, event, helper) {
    	component.set("v.isOpenMultiple" , false);
    
	},
    
    closeQ : function(component, event, helper) {
    	component.set("v.isOpenWrongQuantity" , false);
    
	}
})