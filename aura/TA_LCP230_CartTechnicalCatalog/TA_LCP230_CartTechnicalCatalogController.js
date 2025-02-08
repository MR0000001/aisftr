({
    handleInitialize : function(component, event, helper) {
        console.log('TA_LCP230_CartTechnicalCatalog >> Controller >> handleInitialize >> Start');
        helper.initialize(component, event, helper);
        console.log('TA_LCP230_CartTechnicalCatalog >> Controller >> handleInitialize >> Finish');
    },
    
    handleToggleCardModal : function(component, event, helper) {
        console.log("TA_LCP230_CartTechnicalCatalog >> Controller >> handleToggleCardModal >> Start");
        helper.toggleCardModal(component, event, helper);
        console.log("TA_LCP230_CartTechnicalCatalog >> Controller >> handleToggleCardModal >> Finish");
    },

    handleToggleCatalogModal : function(component, event, helper) {
        console.log("TA_LCP230_CartTechnicalCatalog >> Controller >> handleToggleCatalogModal >> Start");
        helper.toggleCatalogModal(component, event, helper);
        console.log("TA_LCP230_CartTechnicalCatalog >> Controller >> handleToggleCatalogModal >> Finish");
    },

    handleToggleGenericTechnicalCatalog : function(component, event, helper) {
        console.log("TA_LCP230_CartTechnicalCatalog >> Controller >> handleToggleGenericTechnicalCatalog >> Start");
        helper.toggleGenericTechnicalCatalog(component, event, helper);
        console.log("TA_LCP230_CartTechnicalCatalog >> Controller >> handleToggleGenericTechnicalCatalog >> Finish");
    },

    handleDecrementQuantity : function(component, event, helper) {
        console.log("TA_LCP230_CartTechnicalCatalog >> Controller >> handleDecrementQuantity >> Start");
        helper.decrementQuantity(component, event, helper);
        console.log("TA_LCP230_CartTechnicalCatalog >> Controller >> handleDecrementQuantity >> Finish");
    },

    handleIncrementQuantity : function(component, event, helper) {
        console.log("TA_LCP230_CartTechnicalCatalog >> Controller >> handleIncrementQuantity >> Start");
        helper.incrementQuantity(component, event, helper);
        console.log("TA_LCP230_CartTechnicalCatalog >> Controller >> handleIncrementQuantity >> Finish");
    },

    handleAddProduct : function(component, event, helper) {
        console.log("TA_LCP230_CartTechnicalCatalog >> Controller >> handleAddProduct >> Start");
        helper.addProduct(component, event, helper);
        console.log("TA_LCP230_CartTechnicalCatalog >> Controller >> handleAddProduct >> Finish");
    },

    handleRemoveProduct : function(component, event, helper) {
        console.log("TA_LCP230_CartTechnicalCatalog >> Controller >> handleRemoveProduct >> Start");
        helper.fireToggleSpinnerEvent(component, true);
        helper.removeProduct(component, event, helper);
        console.log("TA_LCP230_CartTechnicalCatalog >> Controller >> handleRemoveProduct >> Finish");
    },

    handleSearchProduct : function(component, event, helper) {
        console.log("TA_LCP230_CartTechnicalCatalog >> Controller >> handleSearchProduct >> Start");
        helper.searchProduct(component, event, helper);
        console.log("TA_LCP230_CartTechnicalCatalog >> Controller >> handleSearchProduct >> Finish");
    },

    handleDecrementGenericTechnicalProductQuantity : function(component, event, helper) {
        console.log("TA_LCP230_CartTechnicalCatalog >> Controller >> handleDecrementGenericTechnicalProduct >> Start");
        helper.decrementGenericTechnicalProductQuantity(component, event, helper);
        console.log("TA_LCP230_CartTechnicalCatalog >> Controller >> handleDecrementGenericTechnicalProduct >> Finish");
    },

    handleIncrementGenericTechnicalProductQuantity : function(component, event, helper) {
        console.log("TA_LCP230_CartTechnicalCatalog >> Controller >> handleIncrementGenericTechnicalProductQuantity >> Start");
        helper.incrementGenericTechnicalProductQuantity(component, event, helper);
        console.log("TA_LCP230_CartTechnicalCatalog >> Controller >> handleIncrementGenericTechnicalProductQuantity >> Finish");
    },

    handleAddGenericTechnicalProductToCart : function(component, event, helper) {
        console.log("TA_LCP230_CartTechnicalCatalog >> Controller >> handleAddGenericTechnicalProductToCart >> Start");
        helper.addGenericTechnicalProductToCart(component, event, helper);
        console.log("TA_LCP230_CartTechnicalCatalog >> Controller >> handleAddGenericTechnicalProductToCart >> Finish");
    },

    handleManageB2WResponse : function(component, event, helper) {
        console.log('TA_LCP230_CartTechnicalCatalog >> Controller >> handleManageB2WResponse >> Start');
        if(event.getParam('handlerCmpName') == 'TA_LCP230_CartTechnicalCatalog') {
            helper.manageB2WResponse(component, event, helper);
        }
        console.log('TA_LCP230_CartTechnicalCatalog >> Controller >> handleManageB2WResponse >> End');
    },

    handleAddSelectedProductsToCart : function(component, event, helper) {
        console.log('TA_LCP230_CartTechnicalCatalog >> Controller >> handleAddSelectedProductsToCart >> Start');
        helper.addSelectedProductsToCart(component, event, helper, true);
        console.log('TA_LCP230_CartTechnicalCatalog >> Controller >> handleAddSelectedProductsToCart >> End');
    }
    
})