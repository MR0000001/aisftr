({
	invoke : function(component, event, helper) {
        console.log('entro in ivoke');
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
            var toastEvent = $A.get("e.force:showToast");
        		toastEvent.setParams({
             "title": 'Successo',
             "message": 'La sua riassegnazione è avvenuta con successo',
             "type": 'Success',
         });
        toastEvent.fire();  
        })
        .catch(function(error) {
            console.log(error);
        });
                         
    }
      
})