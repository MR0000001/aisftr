/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 22/05/2019
* @description XC_LCP114_MassiveAssignmentWorkTypeZipCode – Component for Massive WorkType/ZipCode Assignment
*/

({
	init : function(component, event, helper) { 
        helper.init(component, event, helper); 
	},

	enableButton : function(component, event, helper) { 
		helper.enableButton(component, event, helper); 
	},

	onChangePicklist : function(component, event, helper) { 
		helper.onChangePicklist(component, event, helper); 
	},

	onChangeFilterWorktype : function(component, event, helper) { 
		helper.onChangeFilterWorktype(component, event, helper); 
	},
	
	onChangeTableWorktype : function(component, event, helper) { 
        	helper.onChangeTableWorktype(component, event, helper); 
	},

	onChangeTableZipCode : function(component, event, helper) { 
        	helper.onChangeTableZipCode(component, event, helper); 
	},

	operation : function(component, event, helper) { 
        helper.operation(component, event, helper); 
	}, 

	onChangeTableProvince : function(component, event, helper) { 
		helper.onChangeTableProvince(component, event, helper); 
	},

	onChangeTableZipCodeAdd : function(component, event, helper) { 
		helper.onChangeTableZipCodeAdd(component, event, helper); 
	},

	onChangeFilterZipCode : function(component, event, helper) { 
		helper.onChangeFilterZipCode(component, event, helper); 
	}, 

	onChangeFilterProvince : function(component, event, helper) { 
		helper.onChangeFilterProvince(component, event, helper); 
	}, 

	onChangeFilterZipCodeAdd : function(component, event, helper) { 
		helper.onChangeFilterZipCodeAdd(component, event, helper); 
	},

	onSelectedDestinationPartner: function(component, event, helper) { 
		helper.onSelectedDestinationPartner(component, event, helper); 
	}

})