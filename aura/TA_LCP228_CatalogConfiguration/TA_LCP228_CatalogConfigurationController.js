({
    handleInitialize : function(component, event, helper) {
        console.log('TA_LCP228_CatalogConfiguration >> Controller >> handleInitialize >> Start');
        helper.initialize(component, event, helper);
        console.log('TA_LCP228_CatalogConfiguration >> Controller >> handleInitialize >> End');
    },

    handleCatalogPicklist : function(component, event, helper) {
        console.log('TA_LCP228_CatalogConfiguration >> Controller >> handleCatalogPicklist >> Start');
        helper.manageCatalogPicklist(component, event, helper);        
        console.log('TA_LCP228_CatalogConfiguration >> Controller >> handleCatalogPicklist >> End');
    }
})