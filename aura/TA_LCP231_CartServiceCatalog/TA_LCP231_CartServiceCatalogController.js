({
    handleInitialize : function(component, event, helper) {
        console.log('TA_LCP231_CartServiceCatalaog >> Controller >> handleInitialize >> Start');
        helper.initialize(component, event, helper);
        console.log('TA_LCP231_CartServiceCatalaog >> Controller >> handleInitialize >> Finish');
    },

    handleManageAddCartModal : function(component, event, helper) {
        console.log('TA_LCP231_CartServiceCatalaog >> Controller >> handleManageAddCartModal >> Start');
        if(!component.get('v.showAddCartModal')) {
            helper.prepareModal(component, event.currentTarget.id);
        } else {
            component.set('v.showAddCartModal', !component.get('v.showAddCartModal'));
        }
        console.log('TA_LCP231_CartServiceCatalaog >> Controller >> handleManageAddCartModal >> Finish');
    },

    handleAddToCart : function(component, event, helper) {
        console.log('TA_LCP231_CartServiceCatalaog >> Controller >> handleAddToCart >> Start');
        helper.addToCart(component, event, helper);
        console.log('TA_LCP231_CartServiceCatalaog >> Controller >> handleAddToCart >> Finish');
    },

    handleManageB2WResponse : function(component, event, helper) {
        console.log('TA_LCP231_CartServiceCatalaog >> Controller >> handleManageB2WResponse >> Start');
        if(event.getParam('handlerCmpName') == 'TA_LCP231_CartServiceCatalog') {
            helper.manageB2WResponse(component, event, helper);
        }
        console.log('TA_LCP231_CartServiceCatalaog >> Controller >> handleManageB2WResponse >> End');
    },

    handleRemoveService : function(component, event, helper) {
        console.log('TA_LCP231_CartServiceCatalaog >> Controller >> handleRemoveService >> Start');
        if(event.currentTarget.name == 'remove') {
            helper.removeFromCart(component, event);
        }
        console.log('TA_LCP231_CartServiceCatalaog >> Controller >> handleRemoveService >> End');
    },

    handleManageQuantity : function(component, event, helper) {
        console.log('TA_LCP231_CartServiceCatalaog >> Controller >> handleManageQuantity >> Start');
        helper.manageQuantity(component, event.currentTarget.name, event.currentTarget.id);
        console.log('TA_LCP231_CartServiceCatalaog >> Controller >> handleManageQuantity >> End');
    },
})