({
    handleInitialize : function(component, event, helper) {
        console.log('TA_LCP227_CartConfiguration >> Controller >> handleInitialize >> Start');
        helper.initialize(component, event, helper);
        console.log('TA_LCP227_CartConfiguration >> Controller >> handleInitialize >> End');
    },

    handleShowProducts : function(component, event, helper) {
        console.log('TA_LCP227_CartConfiguration >> Controller >> handleShowProducts >> Start');
        component.set("v.showProducts", !component.get("v.showProducts"));
        console.log('TA_LCP227_CartConfiguration >> Controller >> handleShowProducts >> End');
    },

    handlePressButton : function(component, event, helper) {
        console.log('TA_LCP227_CartConfiguration >> Controller >> handlePressButton >> Start');
        helper.managePressButton(component, event, helper);
        console.log('TA_LCP227_CartConfiguration >> Controller >> handlePressButton >> End');
    },

    handleManageB2WResponse : function(component, event, helper) {
        console.log('TA_LCP227_CartConfiguration >> Controller >> handleB2WResponse >> Start');
        if(event.getParam('handlerCmpName') == 'TA_LCP227_CartConfiguration') {
            helper.manageB2WResponse(component, event, helper);
        }
        console.log('TA_LCP227_CartConfiguration >> Controller >> handleB2WResponse >> End');
    }
})