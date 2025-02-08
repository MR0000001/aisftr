({
	doInit : function(component, event, helper) {
		helper.init(component, event, helper);
	},
    
    
     closeModal : function(component, event, helper) {
      
            $A.get("e.force:closeQuickAction").fire();
    },
    
    setCheckboxVal : function(component, event, helper) {                        
        
        var checkBox1 = document.getElementById("visual-picker-76");
        var checkBox2 = document.getElementById("visual-picker-77");
		
        if(checkBox1!=null && checkBox1.checked == true){
            component.set("v.clearSAPError", true);
        }else{
            component.set("v.clearSAPError", false);
        }
        if(checkBox2!=null && checkBox2.checked == true){
            component.set("v.clear3PLError", true);
        }else{
            component.set("v.clear3PLError", false);
        }
	},
    
      clearError : function (component, event, helper) {
        component.set("v.showSpinner" , true);
        helper.deleteErrorLog(component, event, helper) ;
        
    },
     
    
})