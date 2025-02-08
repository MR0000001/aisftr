({
	handleInitialize : function(component, event, helper) {
        console.log('TA_LCP254_HomepageHeader >> Controller >> handleInitialize >> Start');
        helper.initialize(component);
        console.log('TA_LCP254_HomepageHeader >> Controller >> handleInitialize >> End');
    },

    handleOnClick : function(component, event, helper) {
        console.log('TA_LCP254_HomepageHeader >> Controller >> handleManageRedirect >> Start');
        let actionOnClick = event.currentTarget.dataset.action;
        let param = event.currentTarget.dataset.param;

        if (param && actionOnClick) {
            if (actionOnClick == "redirect" ) {
                helper.redirectToPage(component, param, true);
            } 
            
            if (actionOnClick == "openModal") {
                if (component.get("v." + param) != undefined) {
                    let index = event.currentTarget.dataset.index;
                    component.set("v.selectedTab", component.get('v.custom').tabs[index]);
                    component.set("v." + param, true);
                }
            } 
        }
        console.log('TA_LCP254_HomepageHeader >> Controller >> handleManageRedirect >> End');
    },

    handleCloseModal : function(component, event, helper) {
        console.log('TA_LCP254_HomepageHeader >> Controller >> handleCloseModal >> Start');
        helper.closeModal(component, event, helper);
        console.log('TA_LCP254_HomepageHeader >> Controller >> handleCloseModal >> End');
    },
})