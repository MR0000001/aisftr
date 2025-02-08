({
    handleInitialize : function(component, event, helper) {
        console.log('TA_LCP232_CartSummary >> Controller >> handleInitialize >> Start');
        helper.initialize(component);
        console.log('TA_LCP232_CartSummary >> Controller >> handleInitialize >> Finish');
    },

    handleManageCartSummary : function(component, event, helper) {
        console.log('TA_LCP232_CartSummary >> Controller >> handleInitialize >> Start');
        if(component.get("v.isEditAttributeModal")) {
            component.set("v.isEditAttributeModal", false);
        } else {
            component.set('v.openCartSummary', !component.get('v.openCartSummary'));
        }
        console.log('TA_LCP232_CartSummary >> Controller >> handleInitialize >> Finish');
    },

    handleRefreshCart : function(component, event, helper) {
        console.log('TA_LCP232_CartSummary >> Controller >> handleRefreshCart >> Start');
        if(event.getParam("action") == 'refresh-cart') helper.refreshCart(component, event.getParam("params"));
        console.log('TA_LCP232_CartSummary >> Controller >> handleRefreshCart >> Finish');
    },

    handleOpenEditAttribute : function(component, event, helper) {
        console.log('TA_LCP232_CartSummary >> Controller >> handleOpenEditAttribute >> Start');
        component.set("v.isEditAttributeModal", true);
        let itemId = event.currentTarget.id;
        let cartItems = component.get("v.cartItems");
        cartItems.forEach(function(item) {
            if(itemId == item.id) {
                component.set("v.selectedCartItem", item);
            }
        });

        let listAttributeDynamicLookup = [];
        let productAttributes = component.get("v.selectedCartItem").listOfAttributes;
        let productName = component.get("v.selectedCartItem").fields.LicProductName;
        
        productAttributes.forEach(function(attribute) {
            if(attribute.fields.hidden == "false" && attribute.fields.type == "Dynamic Lookup") listAttributeDynamicLookup.push(attribute);
        });

        if(listAttributeDynamicLookup.length) helper.getDynamicLookupValue(component, event, helper, listAttributeDynamicLookup, productName);

        console.log('TA_LCP232_CartSummary >> Controller >> handleOpenEditAttribute >> End');
    },

    handleCloseEditAttribute : function(component, event, helper) {
        console.log('TA_LCP232_CartSummary >> Controller >> handleCloseEditAttribute >> Start');
        component.set("v.isEditAttributeModal", false);
        console.log('TA_LCP232_CartSummary >> Controller >> handleCloseEditAttribute >> End');
    },

    handleSaveAttribute : function(component, event, helper) {
        console.log('TA_LCP232_CartSummary >> Controller >> handleSaveAttribute >> Start');
        helper.fireToggleSpinnerEvent(component, true);
        helper.saveAttribute(component, event, helper);
        console.log('TA_LCP232_CartSummary >> Controller >> handleSaveAttribute >> End');
    },

    handleManageB2WResponse : function(component, event, helper) {
        console.log('TA_LCP232_CartSummary >> Controller >> handleManageB2WResponse >> Start');
        if(event.getParam('handlerCmpName') == 'TA_LCP232_CartSummary') {
            helper.manageB2WResponse(component, event, helper);
        }
        console.log('TA_LCP232_CartSummary >> Controller >> handleManageB2WResponse >> End');
    }
})