({
    handleInitialize : function(component, event, helper) {
        console.log('TA_LCP201_DynamicLayoutContainer >> Controller >> handleInitialize >> Start');
        helper.initialize(component);
        console.log('TA_LCP201_DynamicLayoutContainer >> Controller >> handleInitialize >> End');
    },

    handleCatchReceiveInitStateEvt : function(component, event, helper) {
        console.log('TA_LCP201_DynamicLayoutContainer >> Controller >> handleCatchReceiveInitStateEvt >> Start');
        helper.catchReceiveInitStateEvt(component, event);
        console.log('TA_LCP201_DynamicLayoutContainer >> Controller >> handleCatchReceiveInitStateEvt >> End');
    }
})