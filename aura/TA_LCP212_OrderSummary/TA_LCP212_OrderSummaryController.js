({
    handleInitialize: function (component, event, helper) {
        console.log('TA_LCP212_OrderSummary >> Controller >> handleInitialize >> Start');
        helper.initialize(component, event, helper);
        console.log('TA_LCP212_OrderSummary >> Controller >> handleInitialize >> End');
    },

    handleShowOrderItems : function(component, event, helper) {
        console.log('TA_LCP212_OrderSummary >> Controller >> handleShowOrderItems >> Start');
        component.set('v.showOrderItems', !component.get('v.showOrderItems'));
        console.log('TA_LCP212_OrderSummary >> Controller >> handleShowOrderItems >> End');
    },

    handleShowOrderItemDetails : function(component, event, helper) {
        console.log('TA_LCP212_OrderSummary >> Controller >> handleShowOrderItems >> Start');
        let index = event.currentTarget.dataset.value;
        let orderItemSelected = component.get("v.infoBag.orderItemsBundle")[index];
        let orderItemToShow = [];
        orderItemToShow.push(orderItemSelected.orderItemFields);
        orderItemToShow = orderItemToShow.concat(orderItemSelected.childOrderItems)
        component.set("v.orderItemToShow", orderItemToShow);
        component.set('v.showOIDetailModal', !component.get('v.showOIDetailModal'));
        console.log('TA_LCP212_OrderSummary >> Controller >> handleShowOrderItems >> End');
    },

    handleCloseOrderItemDetails : function(component, event, helper) {
        console.log('TA_LCP212_OrderSummary >> Controller >> handleShowOrderItems >> Start');
        component.set("v.orderItemToShow", []);
        component.set('v.showOIDetailModal', !component.get('v.showOIDetailModal'));
        console.log('TA_LCP212_OrderSummary >> Controller >> handleShowOrderItems >> End');
    },
})