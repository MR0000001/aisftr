({
    init : function(component, event, helper){        
        helper.initEnvironment(component,event,helper);        
    },
    
    createPhoneOnAccount  : function(component, event, helper){
        	helper.createPhoneOnAccount(component, event, helper);
    },
    
    closePhoneSection  : function(component, event, helper){
           component.set("v.showInsertPhone", false); 
           $A.get("e.force:closeQuickAction").fire();
    },

    closeChildComponent : function(component,event,helper){
        $A.get("e.force:closeQuickAction").fire();
    }
})