({
    doInit: function (component, event, helper) {
        console.log('TA_LCP218_DynamicRemind >> Controller >> doInit >> Start');
        helper.init(component);
        console.log('TA_LCP218_DynamicRemind >> Controller >> doInit >> End');
    },

    handleManageAccordion : function(component, event, helper) {
        console.log('TA_LCP218_DynamicRemind >> Controller >> handleManageAccordion >> Start');
        helper.manageAccordion(component, event);
        console.log('TA_LCP218_DynamicRemind >> Controller >> handleManageAccordion >> End');
    }
})