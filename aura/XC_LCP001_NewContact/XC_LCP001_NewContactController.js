({
	init : function(component, event, helper) {
		helper.doInit(component, helper);
	},

	onSubmit : function(component, event, helper) {
		helper.onSubmitHelper(component, event);
	},

	assignLeadChecked : function(component, event, helper) {
	},

	controlMandatoryFields : function(component, event, helper) {
		let fieldToCont = component.get('v.fieldToControl');
		helper.fieldFilledControl(component, event, fieldToCont);
	}, 

	canInsertField : function(component, event, helper) {
		helper.onSubmitHelper(component, event);
	}, 

	

	goBack : function(component, event, helper) { 
       console.log('entrato');
       let workspaceAPI = component.find("workspace");
                    workspaceAPI.getFocusedTabInfo().then(function(response) {
                        let focusedTabId = response.tabId;
                        workspaceAPI.closeTab({tabId: focusedTabId});
                    })
	}
})