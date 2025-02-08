({
	
    handleInitialize: function (component, event, helper) {
        console.log('TA_LCP261_WorkOrderChildView >> Controller >> handleInitialize >> Start');
        helper.initialize(component);
        console.log('TA_LCP261_WorkOrderChildView >> Controller >> handleInitialize >> End');
    },

    handleManageDetails : function(component, event, helper) {
        console.log('TA_LCP261_WorkOrderChildView >> Controller >> handleManageAccordion >> Start');
        if(component.get('v.general.show') == 'true') component.set('v.general.show', 'false');
        else component.set('v.general.show', 'true');
        console.log('TA_LCP261_WorkOrderChildView >> Controller >> handleManageAccordion >> End');
    },

    handleRedirectToObject : function(component, event, helper) {
        console.log('TA_LCP261_WorkOrderChildView >> Controller >> handleRedirectToObject >> Start');
        helper.redirectToObject(component, event, helper);
        console.log('TA_LCP261_WorkOrderChildView >> Controller >> handleRedirectToObject >> End');
    },

    handleManageAccordion : function(component, event, helper) {
        console.log('TA_LCP261_WorkOrderChildView >> Controller >> handleManageAccordion >> Start');
        helper.manageAccordion(component, event);
        console.log('TA_LCP261_WorkOrderChildView >> Controller >> handleManageAccordion >> End');
    }

})