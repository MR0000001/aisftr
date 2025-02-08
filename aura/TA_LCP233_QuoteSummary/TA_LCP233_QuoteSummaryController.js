({
    handleInitialize : function(component, event, helper) {
        console.log('TA_LCP233_QuoteSummary >> Controller >> handleInitialize >> Start');
        helper.initialize(component, event, helper);
        console.log('TA_LCP233_QuoteSummary >> Controller >> handleInitialize >> End');
    },

    handleShowDetails : function(component, event, helper) {
        console.log('TA_LCP233_QuoteSummary >> Controller >> handleShowDetails >> Start');
        helper.fireToggleSpinnerEvent(component, true);
        helper.manageVisibility(component, event, helper, 'show');
        helper.fireToggleSpinnerEvent(component, false);
        console.log('TA_LCP233_QuoteSummary >> Controller >> handleShowDetails >> End');
    },

    handleManageEdit : function(component, event, helper) {
        console.log('TA_LCP233_QuoteSummary >> Controller >> handleManageEdit >> Start');
        helper.manageEdit(component, event, helper);
        console.log('TA_LCP233_QuoteSummary >> Controller >> handleManageEdit >> End');
    },

    handleQuoteSelection : function(component, event, helper) {
        console.log('TA_LCP233_QuoteSummary >> Controller >> handleQuoteSelection >> Start');
        let quoteId = event.currentTarget.id;
        helper.quoteSelection(component, event, helper, quoteId);
        console.log('TA_LCP233_QuoteSummary >> Controller >> handleQuoteSelection >> End');
    },

    handleQuoteSummaryEvt : function(component, event, helper) {
        console.log('TA_LCP233_QuoteSummary >> Controller >> handleQuoteSummaryEvt >> Start');
        if(event.getParam('handlerCmpName') == 'TA_LCP233_QuoteSummary') {
            helper.manageGoToNextPhase(component, event, helper);
        }
        console.log('TA_LCP233_QuoteSummary >> Controller >> handleQuoteSummaryEvt >> End');
    },

    handleChangeSelectedQuoteOppty :function(component, event, helper) {
        console.log('TA_LCP233_QuoteSummary >> Controller >> handleChangeSelectedQuote >> Start');
        helper.changeSelectedQuoteOppty(component, event, helper);
        console.log('TA_LCP233_QuoteSummary >> Controller >> handleChangeSelectedQuote >> End');
    }
})