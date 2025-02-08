({
	init : function(component, event, helper) {
      	helper.doInit(component,event);
	},

	handler : function (component,event,helper) {
		helper.createObject(component, event, helper);
	}
})