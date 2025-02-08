({
	doInit : function(component, event, helper) {
        component.set("v.showSpinner" , true);
		helper.init(component, event, helper);
	}, 

	send : function(component, event, helper) {
		helper.send(component, event, helper);
	}

})