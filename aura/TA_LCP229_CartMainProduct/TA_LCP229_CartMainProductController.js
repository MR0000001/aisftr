({
    handleInitialize : function(component, event, helper) {
        console.log('TA_LCP229_CartMainProduct >> Controller >> handleInitialize >> Start');
        helper.initialize(component, event, helper);
        console.log('TA_LCP229_CartMainProduct >> Controller >> handleInitialize >> End');
    },

    handleManageMainProductDetails : function(component, event, helper) {
        console.log('TA_LCP229_CartMainProduct >> Controller >> handleManageMainProductDetails >> Start');
        helper.fireToggleSpinnerEvent(component, true);
        helper.manageMainProductDetails(component, event, helper);
        console.log('TA_LCP229_CartMainProduct >> Controller >> handleManageMainProductDetails >> End');
    },

    handleAddMainProductToCart : function(component, event, helper) {
        console.log('TA_LCP229_CartMainProduct >> Controller >> handleAddMainProductToCart >> Start');
        helper.fireToggleSpinnerEvent(component, true);
        // let checkAttribute = helper.checkAttribute(component, event, helper);
        // if(checkAttribute) {
        helper.addMainProductToCart(component, event, helper);
        // } else {
        //     helper.fireToggleSpinnerEvent(component, false);
        // }
        console.log('TA_LCP229_CartMainProduct >> Controller >> handleAddMainProductToCart >> End');
    },

    handleManageFilterModal : function(component, event, helper) {
        console.log('TA_LCP229_CartMainProduct >> Controller >> handleManageFilterModal >> Start');
        helper.manageFilterModal(component, event, helper);
        console.log('TA_LCP229_CartMainProduct >> Controller >> handleManageFilterModal >> End');
    },

    handleApplyFilters : function(component, event, helper) {
        console.log('TA_LCP229_CartMainProduct >> Controller >> handleApplyFilters >> Start');
        helper.fireToggleSpinnerEvent(component, true);
        helper.applyFilters(component, event, helper);
        console.log('TA_LCP229_CartMainProduct >> Controller >> handleApplyFilters >> End');
    },

    handleClearAllFilters : function(component, event, helper) {
        console.log('TA_LCP229_CartMainProduct >> Controller >> handleClearAllFilters >> Start');
        helper.fireToggleSpinnerEvent(component, true);
        helper.clearAllFilters(component, event, helper);
        console.log('TA_LCP229_CartMainProduct >> Controller >> handleClearAllFilters >> End');
    },

    handleGoToPreviousPage : function(component, event, helper) {
        console.log('TA_LCP229_CartMainProduct >> Controller >> handleGoToPreviousPage >> Start');
        helper.fireToggleSpinnerEvent(component, true);
        window.scrollTo(0, 0);
        component.set('v.currentPageNumber', component.get('v.currentPageNumber') - 1);
        helper.retriveApexInfo(component, event, helper);
        console.log('TA_LCP229_CartMainProduct >> Controller >> handleGoToPreviousPage >> End');
    },

    handleGoToNextPage : function(component, event, helper) {
        console.log('TA_LCP229_CartMainProduct >> Controller >> handleGoToNextPage >> Start');
        helper.fireToggleSpinnerEvent(component, true);
        window.scrollTo(0, 0);
        component.set('v.currentPageNumber', component.get('v.currentPageNumber') + 1);
        helper.retriveApexInfo(component, event, helper);
        console.log('TA_LCP229_CartMainProduct >> Controller >> handleGoToNextPage >> End');
    },

    handleManageB2WResponse : function(component, event, helper) {
        console.log('TA_LCP229_CartMainProduct >> Controller >> handleManageB2WResponse >> Start');
        if(event.getParam('handlerCmpName') == 'TA_LCP229_CartMainProduct') {
            helper.manageB2WResponse(component, event, helper);
        }
        console.log('TA_LCP229_CartMainProduct >> Controller >> handleManageB2WResponse >> End');
    },

    handleChangeProductSelectedIds : function(component, event, helper) {
        console.log('TA_LCP229_CartMainProduct >> Controller >> handleChangeProductSelectedIds >> Start');
        helper.changeProductSelectedIds(component);
        console.log('TA_LCP229_CartMainProduct >> Controller >> handleChangeProductSelectedIds >> End');
    },

    handleRemoveMainProductFromCart : function(component, event, helper) {
        console.log('TA_LCP229_CartMainProduct >> Controller >> handleRemoveMainProductFromCart >> Start');
        helper.fireToggleSpinnerEvent(component, true);
        helper.removeMainProductFromCart(component, event, helper);
        console.log('TA_LCP229_CartMainProduct >> Controller >> handleRemoveMainProductFromCart >> End');
    },

    onRender : function(component, event, helper) {
        console.log('TA_LCP229_CartMainProduct >> Controller >> onRender >> Start');
        if(component.get('v.renderPriceSlider') && component.get('v.showFilters')) {
            helper.createSlider(component, event, helper);
        }
        console.log('TA_LCP229_CartMainProduct >> Controller >> onRender >> End');
    },

    handleEditAttribute : function(component, event, helper) {
        console.log('TA_LCP229_CartMainProduct >> Controller >> handleEditAttribute >> Start');
        helper.modifyMainProductFromCart(component, event, helper);
        console.log('TA_LCP229_CartMainProduct >> Controller >> handleEditAttribute >> End');
    },

    handleSaveAttribute : function(component, event, helper) {
        console.log('TA_LCP229_CartMainProduct >> Controller >> handleSaveAttribute >> Start');
        helper.saveAttribute(component, event, helper);
        console.log('TA_LCP229_CartMainProduct >> Controller >> handleSaveAttribute >> End');
    }
})