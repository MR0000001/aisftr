({
	init : function(component, event, helper) {
		helper.doInit(component, event, helper);
	},

	

	handleSaveEdition : function(component, event, helper) {
		helper.updateRecord(component, event, helper);
	},

	showModal : function(component) { 
        console.log('showModal');
        component.set("v.showModal", true);
	},
	
	cancel : function(component, event, helper) {
        component.set("v.showModal", false);
        component.set("v.skillId", '');
        component.set("v.skillLevel", null);
        component.set("v.assignmentStartDate", null);
        component.set("v.assignmentEndDate", null);
    },
    
    confirm :  function(component, event, helper) {
        helper.onSave(component, event, helper);
    } 
})