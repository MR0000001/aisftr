({
	init : function(component, event, helper) { 
		helper.doInit(component, event);
	}, 
    
    cancel : function(component, event, helper) {
        helper.goBack(component, event);
    },
    
    confirm :  function(component, event, helper) {
        helper.checkSkillRequired(component, event, helper);
    } 
})