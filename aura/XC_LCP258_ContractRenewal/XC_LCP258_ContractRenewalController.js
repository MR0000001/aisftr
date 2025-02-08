({
    init : function(component, event, helper) {
		helper.init(component, event, helper);
	},

	handleMandatoryInput : function(component, event, helper) {
		//START-CR772-elisa.caldini@accenture.com-01.06.2022											  
		if($A.util.isEmpty(component.get("v.endDate")) || $A.util.isEmpty(component.get("v.contractZone")) || $A.util.isEmpty(component.get("v.endDateMin"))) { //DeAv CR772 added check on endDateMin
			component.set("v.disableSearch", true);
		}else {//END-CR772-elisa.caldini@accenture.com-01.06.2022
			component.set("v.disableSearch", false);
		}//START-CR772-elisa.caldini@accenture.com-28.04.2022
		if( component.get("v.endDate") < component.get("v.endDateMin")) {
			var messageError='The Contract End Date Min must be minor of Contract End Date Max.';
			helper.showToast(component,messageError , 'error');
		}if( component.get("v.endDateMin") < component.get("v.startDate") ) {
			var messageError='The Contract Start Date  must be minor of Contract End Date Min.';
			helper.showToast(component,messageError , 'error');
		}//END-CR772-elisa.caldini@accenture.com-28.04.2022
	},

	handleSearch : function(component, event, helper) {
		component.set("v.showSpinner", true);
		component.set("v.searchPressed", true);
		helper.handleSearch(component, event, helper);
	},

	handleAdjust : function(component, event, helper) {
		component.set("v.showSpinner", true);
		helper.handleAdjust(component, event, helper);
	},

	handleSelect : function(component, event, helper) {
		helper.handleSelect(component, event, helper);
	},

	handleEditCell : function(component, event, helper) {
		helper.handleEditCell(component, event, helper);
	}
})