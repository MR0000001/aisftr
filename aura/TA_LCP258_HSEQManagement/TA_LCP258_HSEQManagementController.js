({
	handleInitialize : function(component, event, helper) {
        console.log('TA_LCP258_HSEQManagement >> Controller >> handleInitialize >> Start');
        helper.initialize(component);
        console.log('TA_LCP258_HSEQManagement >> Controller >> handleInitialize >> End');
    },

    handleCloseModal : function(component, event, helper) {
        console.log('TA_LCP258_HSEQManagement >> Controller >> handleCloseModal >> Start');
        helper.fireToggleSpinnerEvent(component, true);
        helper.closeModal(component, event, helper);
        helper.fireToggleSpinnerEvent(component, false);
        console.log('TA_LCP258_HSEQManagement >> Controller >> handleCloseModal >> End');
    },

    handleCardClick : function(component, event, helper) {
        console.log('TA_LCP258_HSEQManagement >> Controller >> handleCardClick >> Start');
        helper.fireToggleSpinnerEvent(component, true);
        helper.cardClick(component, event, helper);
        console.log('TA_LCP258_HSEQManagement >> Controller >> handleCardClick >> End');
    },

    handleFilter : function(component, event, helper) {
        console.log('TA_LCP258_HSEQManagement >> Controller >> handleFilter >> Start');
        helper.changeFilterValue(component);
        console.log('TA_LCP258_HSEQManagement >> Controller >> handleFilter >> End');
    },
})