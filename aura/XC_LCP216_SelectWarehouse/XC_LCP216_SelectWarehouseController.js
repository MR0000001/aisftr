({
	doInit : function(component, event, helper) {    	
		helper.doSearchHelper(component, event, helper);      
	},
    doSearch : function(component, event, helper) {    	
		helper.doSearchHelper(component, event, helper);      
	},
    onPicklistChange : function(component, event, helper) {
		helper.setWarehouseHelper(component, event, helper);       
	},
    checkLegalEntityFilter: function (component, event, helper) {
        let b = component.get("v.warehouseLegalEntityFilter");
        component.set("v.warehouseLegalEntityFilter",!b);        
    }
})