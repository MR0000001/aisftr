({
    handleInitialize : function(component, event, helper) {
        console.log('TA_LCP226_CartContainer >> Controller >> handleInitialize >> Start');
        helper.initialize(component, event, helper);
        console.log('TA_LCP226_CartContainer >> Controller >> handleInitialize >> End');
    },

    handleCartStepEvt : function(component, event, helper) {
        console.log('TA_LCP226_CartContainer >> Controller >> handleCartStepEvt >> Start');
        if(event.getParam('handlerCmpName') == 'TA_LCP226_CartContainer') {
            if(event.getParam('actionName') == 'refreshCartSummary') {
                helper.refreshCartEvt(component.get('v.cartContext'));
            } else {
                helper.fireToggleSpinnerEvent(component, true);
                helper.prepareNextAction(component, event, helper);
            }
        }
        console.log('TA_LCP226_CartContainer >> Controller >> handleCartStepEvt >> End');
    },

    handleManageUpdateContext : function(component, event, helper) {
        console.log('TA_LCP226_CartContainer >> Controller >> handleManageUpdateContext >> Start');
        console.log(JSON.parse(JSON.stringify(event.getParams())));
        helper.manageUpdateContext(component, event, helper);
        console.log('TA_LCP226_CartContainer >> Controller >> handleManageUpdateContext >> End');
    },

    handleManageCartEvent : function(component, event, helper) {
        console.log('TA_LCP226_CartContainer >> Controller >> handleManageCartEvent >> Start');
        console.log(JSON.parse(JSON.stringify(event.getParams())));
        if(event.getParam("bitwinMap")) {
            helper.manageBitwinMap(component, event, helper);
        }
        console.log('TA_LCP226_CartContainer >> Controller >> handleManageCartEvent >> End');
    },

    handleManageLoadingEvent : function(component, event, helper) {
        console.log('TA_LCP226_CartContainer >> Controller >> handleManageLoadingEvent >> Start');
        console.log(JSON.parse(JSON.stringify(event.getParams())));        
        console.log('TA_LCP226_CartContainer >> Controller >> handleManageLoadingEvent >> End');
    },

    handleManageChangeComponent : function(component, event, helper) {
        console.log('TA_LCP226_CartContainer >> Controller >> handleManageChangeComponent >> Start');
        console.log(JSON.parse(JSON.stringify(event.getParams())));
        console.log('TA_LCP226_CartContainer >> Controller >> handleManageChangeComponent >> End');
    },

    handleError: function(cmp, event) {
        console.log('TA_LCP226_CartContainer >> Controller >> handleError >> Start');
        component.set("v.showToastMessage", true);
        component.set("v.isError", true);
        component.set("v.toastMessage", JSON.stringify(event.getParams()));
        console.log('TA_LCP226_CartContainer >> Controller >> handleError >> End');
    }
})