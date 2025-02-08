({
    onPageReferenceChange: function(cmp, evt, helper) {
        var myPageRef = cmp.get("v.pageReference");
        //var myPageRef2 = cmp.get("v.pageReference_mystery");
        console.log('myPageRef ->', myPageRef);
        //console.log('myPageRef2 ->', myPageRef2);
        //helper.logToBrowserConsole(cmp, 'cmp loaded', myPageRef , ' and ',myPageRef2);
        var mystery = myPageRef.state.c__mystery;
        console.log('mystery -> ', mystery);
        cmp.set("v.mystery", mystery);
        if(mystery === false) {
            var tabToClose = myPageRef.state.c__tabToClose;
            console.log('chiudo il tab');
            cmp.set("v.tabToClose", tabToClose);
        }
        var workspaceAPI = cmp.find("workspace");
        workspaceAPI.getEnclosingTabId()
            .then(function(myTab) {
                if (mystery === false) {
                    workspaceAPI.closeTab({tabId: tabToClose});
                }
                console.log('dentro getEnclosingTabId');
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
                console.log('@@@ error -> ', error);
            });

        var flow = cmp.find("flowData");
        var inputVariables = null;
        console.log('richiamo il flow');
        flow.startFlow("NoMatchingRecordsCTI");
    },
})