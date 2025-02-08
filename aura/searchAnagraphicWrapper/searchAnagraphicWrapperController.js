({

//    onInit: function (component, event, helper) {
//        let valRecId = component.get("v.recordId");
//        if ( valRecId == undefined ) {
//            var workspaceAPI = component.find("workspaceAnagrafica");
//            workspaceAPI.getFocusedTabInfo().then(function(response) {
//                var focusedTabId = response.tabId;
//                workspaceAPI.setTabLabel({
//                    tabId: focusedTabId,
//                    label: $A.get("$Label.c.searchAccount_Title")
//                });
//                workspaceAPI.setTabIcon({
//                    tabId: focusedTabId,
//                    icon: "utility:user",
//                    iconAlt: $A.get("$Label.c.searchAccount_Title")
//
//                });
//            })
//            .catch(function(error) {
//                console.log(error);
//            });
//        }
//        //component.set("v.showSpinner", true);
//    },

	closeQA : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        var response = event.getSource().getLocalId();
        component.set("v.value", response);
        var navigate = component.get("v.navigateFlow");
        navigate("NEXT"); //FINISH
	}

//  doneRendering: function(cmp, event, helper) {
//    if(!cmp.get("v.isDoneRendering")){
//      cmp.set("v.isDoneRendering", true);
//        component.set("v.showSpinner", false);
//    }
//  },

});