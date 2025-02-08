({
	init : function(component, event, helper) {
		helper.doInit(component,event,helper);
	},

	contactSelected : function(component,event,helper){
		helper.onContactSelected(component,event,helper)
	},

	leadSelected : function(component,event,helper){
		helper.onLeadSelected(component,event,helper);
	},
	createLead : function(component,event,helper){
		//helper.createNewLead(component,event,helper);
	}
})