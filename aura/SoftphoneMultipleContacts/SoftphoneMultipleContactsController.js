({
    onPageReferenceChange: function(cmp, evt, helper) {
        var myPageRef = cmp.get("v.pageReference");
        var PhoneCTI = myPageRef.state.c__PhoneCTI;
        var finalComponent = myPageRef.state.c__finalComponent;
        var tabToClose = myPageRef.state.c__tabToClose;
        var mystery = myPageRef.state.c__mystery;
        cmp.set("v.PhoneCTI", PhoneCTI);
        cmp.set("v.finalComponent", finalComponent);
        cmp.set("v.tabToClose", tabToClose);
        cmp.set("v.mystery", mystery);
        var flow = cmp.find("flowData");
        var inputVariables = [
            {
                name : "PhoneCTI",
                type : "Number",
                value : PhoneCTI
            }
        ];
        flow.startFlow("MultipleRecordCTI",inputVariables);
        var workspaceAPI = cmp.find("workspace");
        workspaceAPI.getEnclosingTabId()
            .then(function(myTab) {
                if (mystery=== false) {
                    workspaceAPI.closeTab({tabId: tabToClose});
                }
                workspaceAPI.setTabLabel({
                    tabId: myTab,
                    label: "Gestione Chiamata"
                });
                workspaceAPI.setTabIcon({
                    tabId: myTab,
                    icon: "utility:agent_session",
                    iconAlt: "Selezione Contatto"
                });
            })
            .catch(function(error) {
                console.log(error);
            });
    },

})