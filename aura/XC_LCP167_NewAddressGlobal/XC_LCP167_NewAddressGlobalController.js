({
	doInit : function(component, event, helper) {
		helper.init(component, event, helper);
	}, 

	saveAddress: function(component, event, helper) {
        if(helper.checkMandatory(component)){
            helper.handleSaveButtonClick(component, event, helper);
            
		} else {
			helper.showErrorOnField(component, event, helper);
			helper.showMessage(component, "error", "Warning", "Missing mandatory field");
		}
	}, 

    cancel : function(component, event, helper) {
        helper.cancel(component, event,helper);
    },

	setPickCountry  : function(component, event, helper) {
        let selectedOptionValue = event.getParam("value");
        helper.setPickCountry(component, selectedOptionValue);
	},
	
	sendAddressToMain : function(component, event, helper) {
		if(component.get("v.source") == "002" || component.get("v.source") == "003"){
			helper.setDeelay(component, helper);
		}
	},

    clearAddress : function(component, event, helper) {
        helper.clearAddress(component, event, helper);
	}, 

	onModify : function(component, event, helper){
		helper.onModify(component, event, helper);
    }

})