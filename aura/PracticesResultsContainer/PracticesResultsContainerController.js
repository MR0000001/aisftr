({
    init: function(cmp, evt, helper) {
        var workspaceAPI = cmp.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {}).then(function(subtabId) {
            // the subtab has been created, use the Id to set the label
            workspaceAPI.setTabLabel({
                tabId: subtabId,
                label: $A.get("$Label.c.SchoolConsultation_TitleShort")
            });

            workspaceAPI.setTabIcon({
                tabId: subtabId, 
                icon: "standard:activity"
            });
            
            workspaceAPI.focusTab({tabId : subtabId});                                
        }).catch(function(error) {
            console.log("error in container");
            console.log(error);
        });

        var myPageRef = cmp.get("v.pageReference");
        //var PaginationList = myPageRef.state.c__PaginationList;
        var practices = myPageRef.state.c__practices;
        var practiceCodeIndicated = myPageRef.state.c__practiceCodeIndicated;
        var startPage = myPageRef.state.c__startPage;
        var endPage = myPageRef.state.c__endPage;
        var totalrecords = myPageRef.state.c__totalrecords;
        var totalPages = myPageRef.state.c__totalPages;
        var fiscalCode = myPageRef.state.c__fiscalCode;

        
        cmp.set("v.practices", practices);
        cmp.set("v.practiceCodeIndicated", practiceCodeIndicated);
        cmp.set("v.startPage", startPage);
        cmp.set("v.endPage", endPage);
        cmp.set("v.totalrecords", totalrecords);
        cmp.set("v.totalPages", totalPages);
        cmp.set("v.fiscalCode", fiscalCode);


    }
})