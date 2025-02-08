/**
 * Created by FMARCHEGIA00 on 03/03/2021.
 */
({
     closetab: function(component, event) {

            console.log('chiudo il tab da aura');
            var closetab = event.getParam('close');

            var workspaceAPI = component.find("workspaceToClose");
            workspaceAPI.getFocusedTabInfo().then(function(response) {
                var focusedTabId = response.tabId;
                workspaceAPI.closeTab({tabId: focusedTabId});
            })
            .catch(function(error) {
                console.log(error);
            });
        },
})