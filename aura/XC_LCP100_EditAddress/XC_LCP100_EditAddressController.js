({
	handleSuccess : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");

        helper.showToast(component, event, helper, 'Address correctly updated', 'success');
        workspaceAPI.getFocusedTabInfo().then(function(response) {

            var focusedTabId = response.tabId;

            workspaceAPI.closeTab({tabId: focusedTabId});

       });
		
	}
})