({
    handleInitialize: function(component, event, helper) {
        console.log('TA_LCC208_Modal >> Controller >> handleInitialize >> Start');
        component.set('v.isSpinnerVisible', true);
        helper.initialize(component);
        console.log('TA_LCC208_Modal >> Controller >> handleInitialize >> End');
    },

    handleActionButton : function(component, event, helper) {
        console.log('TA_LCC208_Modal >> Controller >> handleActionButton >> Start');
        helper.invokeActionButton(component, event);
        console.log('TA_LCC208_Modal >> Controller >> handleActionButton >> End');
    }
})