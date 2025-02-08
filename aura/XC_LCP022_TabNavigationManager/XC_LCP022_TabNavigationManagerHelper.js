({
    init : function(component, event) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.isConsoleNavigation().then(function(response) {
            console.log('isConsoleNavigation='+response);
            component.set("v.isConsoleNavigation", response);
            component.set("v.needsCreateComponent", false);
        }).catch(function(error) {
            console.log(error);
        });

      
    },

	navigateTo : function(component, event) {
        var navService = component.find("navService");
        var targetPageReference = component.get("v.targetPageReference");
        event.preventDefault();
        navService.navigate(targetPageReference);
    },
    
    openTabNavigation : function(component, event){
        var workspaceAPI = component.find("workspace");
        var targetPageReference = component.get("v.targetPageReference");
        var title = component.get("v.tabTitle");
        console.log('Title Component='+title);
        workspaceAPI.openTab({
            pageReference : targetPageReference,
            title: title,
            focus: true
        }).then(function(response) {
            workspaceAPI.setTabLabel({tabId: response, label: component.get("v.tabLabel")});
            if(component.get("v.tabIcon")){
                workspaceAPI.setTabIcon({
                    tabId: response,
                    icon: component.get("v.tabIcon")
                });
            }
        });
    },

    openTabNavigationAndCloseOldTab : function(component, event){
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response){
            var oldTabId = response.tabId;
            var targetPageReference = component.get("v.targetPageReference");
            workspaceAPI.openTab({
                pageReference : targetPageReference,
                focus: true
            }).then(function(response) {
                workspaceAPI.closeTab({tabId: oldTabId});
            });
        });
    },
    
    openDetailSubTab : function(component, event){
        var workspaceAPI = component.find("workspace");
        var targetPageReference = component.get("v.targetPageReference");
        var title = component.get("v.tabTitle");
        workspaceAPI.getFocusedTabInfo().then(function(response){
            var parentTabId = response.tabId;
            workspaceAPI.openSubtab({
                parentTabId: parentTabId,
                pageReference : targetPageReference,
                title:title,
                focus: false
            }).then(function(response) {
                workspaceAPI.setTabIcon({
                    tabId: response,
                    icon: component.get("v.tabIcon")
                });
                workspaceAPI.setTabLabel({tabId: response, label: component.get("v.tabLabel")});
 				workspaceAPI.focusTab({tabId : response});
            })
        });
    },
    
    closeComponent : function(component, event, helper) {
        if(component.get("v.isConsoleNavigation")){
           this.closeAndReopenCurrentTab(component, event, component.get('v.recordId'));
        }else{
                    var windowRedirect = window.location.href;
                    window.location.href = windowRedirect;   
                    //this.refreshSubTabs(component);
                   
        }

    },

     closeAndReopenCurrentTab : function(component, event, toRedirect) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log(error);
        });
         var navigateEvent = $A.get("e.force:navigateToSObject");
         navigateEvent.setParams({ "recordId": toRedirect, "slideDevName": "detail", "isredirect": true });    
         navigateEvent.fire();
         //location.reload(true);
    },


    executeAptNavigation : function(component, event, helper) {
        console.log('@@@@ TabNavigation > executeAptNavigation: isConsoleNavigation='+component.get("v.isConsoleNavigation")+', '+
                    'isMobile='+component.get("v.isMobile")+', isCommunity='+component.get("v.isCommunity")+', needsCreateComponent='+component.get("v.needsCreateComponent"));
        var isConsoleNavigation = component.get("v.isConsoleNavigation");
        var targetPageReference = component.get("v.targetPageReference");
        var recordId, closeSource = true, openSubTab = false;
        if(targetPageReference && targetPageReference.state){
            recordId = targetPageReference.state.c__recordId;
            closeSource = targetPageReference.state.c__closeSource;
            openSubTab = targetPageReference.state.c__openSubTab;
        }
        if(isConsoleNavigation){
            (closeSource) ? helper.openTabNavigationAndCloseOldTab(component, event)
                          : ((!openSubTab) ? helper.openTabNavigation(component,event)
                                           : helper.openDetailSubTab(component,event));
        } 
        else if(component.get("v.isMobile")){
            helper.navigateTo(component, event);
        }
        else{
            console.log('isCommunity= ' + component.get("v.isCommunity"));
            if(recordId){
                console.log('recordId for navigation='+recordId);
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                  "recordId": recordId,
                  "slideDevName": "detail"
                });
                navEvt.fire();
                
                /*if(component.get('v.isCommunity')){
                    location.reload();
                }*/
            }
        }
    },

    openNewObjectPage: function(component, event, helper) {
        console.log('@@@@ TabNavigation > openNewObjectPage: isConsoleNavigation='+component.get("v.isConsoleNavigation")+', '+
                    'isMobile='+component.get("v.isMobile")+', isCommunity='+component.get("v.isCommunity"));
        
        helper.navigateTo(component, event);
    }
})