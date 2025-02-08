({
	init: function (component, event, helper){
		var action = component.get("c.showNewComponent");
		action.setParams({
            'recordId' : component.get("v.recordId")  
		});
		 var submitAsset=$A.get("$Label.c.XC_CL_SubmitAsset");
        component.set("v.submitAsset", submitAsset);
		action.setCallback(this, function(response){
			var result = response.getReturnValue() 
			if(response.getReturnValue() == true){
				helper.initFunc2(component, event,helper);
				component.set('v.showNewComponent', true)
			}else{
				helper.initFunc(component, event,helper);
			}
		})
		$A.enqueueAction(action);
	}, 
     submit : function (component, event, helper){
		helper.updateSubmit(component, event, helper)
	},
	filteredSearch : function (component, event, helper){
		helper.filteredSearch(component, event, helper)
	},
	checkSelection: function (component, event, helper){
		component.set ("v.selectedRows2", []);
		component.set("v.isLogical", false);
		component.set('v.showForceWorkOrder', false);
        component.set('v.disableButton', false);
	},
	checkSelection2: function (component, event, helper){
		component.set ("v.selectedRows", []);
		component.set("v.isLogical", true);
		var dataTable = component.find('datatableIDLogicalAsset');
        var  selectedRows = dataTable.getSelectedRows(0);
		var contract = selectedRows[0].TAM_PartnerContract__c;
		if((contract == undefined || contract == null) && !component.get("v.showCaseForceWorkOrder")){
			component.set('v.showForceWorkOrder', true);
            component.set('v.disableButton', true); 
		}
	},
	//DeAv 08.07.2022 - NR2330 START	
	checkSelectionNetwork: function (component, event, helper){
		component.set ("v.selectedRows2", []);
		component.set("v.isNetwork", true);
		component.set("v.isLogical", false);
		component.set('v.showForceWorkOrder', false);
        component.set('v.disableButton', false);
	},
	//DeAv 08.07.2022 - NR2330 END
    onCheck: function(component, event, helper){
        var checkCmp = component.find("checkbox");
    	component.set('v.disableButton', !checkCmp.get("v.value")); 
	}
    
})