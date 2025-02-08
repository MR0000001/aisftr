({
    init : function(component, event, helper) {
        helper.populatePickValues(component, event, helper); 
    },
    
    cancel : function(component, event, helper) {
        helper.goBack(component, event);
    },
    
    confirm :  function(component, event, helper) {
        helper.saveProductSkillAssociation(component, event, helper);
    }  
})