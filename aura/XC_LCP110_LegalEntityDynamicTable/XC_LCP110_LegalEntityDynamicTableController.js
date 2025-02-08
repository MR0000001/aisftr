({
	init : function(component, event, helper) {
		helper.doInit(component, event, helper);
	},

	processOperationOnRow: function(component, event, helper) {
		let operation = event.getParam("operation");
		if(operation==='Add'){
			helper.addRow(component, event, helper);
		} else if(operation==='Delete'){
			helper.removeDeletedRow(component, event, helper);
		}
	},
	
	setLegalEntityConsents: function(component, event, helper) {
		helper.setLegalEntityConsents(component, event, helper);
	},
	
	setLegalEntityConsentsNEW: function(component, event, helper) {
		helper.setLegalEntityConsentsNEW(component, event, helper);
	}
})