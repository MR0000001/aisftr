({
    doInit : function(component, event, helper) {
        helper.init(component, event);
    },
    
    executeAptNavigation : function(component, event, helper) {
        helper.executeAptNavigation(component, event, helper);
    },

    navigateTo : function(component, event, helper) {
        helper.navigateTo(component, event);
    },

	openTabNavigation : function(component, event, helper) {
        helper.openDetailTab(component, event);
    },
    
    openDetailSubTab : function(component, event, helper) {
        helper.openDetailSubTab(component, event);
    }
})