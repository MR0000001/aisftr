({
	updateServiceAppointment : function(component, event, helper) {
		helper.updateServiceAppointment(component, event);
	},

	doChanges : function(component, event, helper) {
		helper.doChanges(component, event);
	},

	noButton : function(component, event, helper) {
		helper.noButton(component, event);
	},
    sblock :  function(component, event, helper) {
    var selectedOptionValue = event.getParam("value");
        if(selectedOptionValue!=""){
    		component.set("v.pickOk",false);
        }else{
            component.set("v.pickOk",true);
        }
	}
    
})