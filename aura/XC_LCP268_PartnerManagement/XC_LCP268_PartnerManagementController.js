({
    doInit: function(cmp, evt, helper) {
        setTimeout(() => { 
            var workspaceAPI = cmp.find("workspace");
            workspaceAPI.getFocusedTabInfo().then(function(response) {
                var focusedTabId = response.tabId;
                workspaceAPI.setTabLabel({
                    tabId: focusedTabId,
                    label: "Partner Management",
                    icon: "standard:service_crew",
                    iconAlt: "serviceCrew"
                });
                workspaceAPI.setTabIcon({
                    tabId: focusedTabId,
                    icon: "standard:service_crew",
                    iconAlt:"Partner Management"
                })
            })
            .catch(function(error) {
                alert(error);
            });
        }, 2000);
    }
})