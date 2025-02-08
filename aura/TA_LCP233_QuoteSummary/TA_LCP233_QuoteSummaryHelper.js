({
    initialize : function(component, event, helper) {
        console.log('TA_LCP233_QuoteSummary >> Helper >> initialize >> Start');
        component.set('v.general', JSON.parse(component.get('v.fieldSet')).general);
        component.set('v.custom', JSON.parse(component.get('v.fieldSet')).custom);
        component.set('v.customerCardBg', $A.get('$Resource.TA_Images') + '/imgs/' + component.get('v.general.bgImage'));

        let recordType = component.get("v.custom").showAcceptedQuote == "true" ? "quote" : "opty";
        let taParameters = component.get('v.workOrder').TA_Parameters__c != null ? JSON.parse(component.get('v.workOrder').TA_Parameters__c) : null;
        let quoteToAccept = taParameters != null && taParameters.quoteToAccept ? taParameters.quoteToAccept : null;

        let getQuotes = component.get("c.getQuotes");
        getQuotes.setParams({
                                'workOrder' : component.get('v.workOrder'),
                                'recordType' : recordType,
                                'quoteToAccept' : quoteToAccept
                            });
        getQuotes.setCallback(this, function (response) {
            console.log('TA_LCP233_QuoteSummary >> Helper >> getQuotesCallback >> Start');
            if(response.getState() == "SUCCESS") {
                component.set('v.quotes', response.getReturnValue());

                if(component.get("v.workOrder").TA_Parameters__c) {
                    let taParameters = JSON.parse(component.get("v.workOrder").TA_Parameters__c);
                    if(taParameters.selectedQuote) {
                        let quoteId = taParameters.selectedQuote;

                        let quotes = component.get('v.quotes');
                        quotes.forEach(function(quote) {
                            if(quote.id == quoteId) {
                                quote.show = true;
                            }
                        });

                        helper.quoteSelection(component, event, helper, quoteId);
                    }
                }

                component.set('v.isInitialized', true);
                helper.fireSendInitStateEvt(component, true);
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
            console.log('TA_LCP233_QuoteSummary >> Helper >> getQuotesCallback >> End');
        });
        $A.enqueueAction(getQuotes);

        console.log('TA_LCP233_QuoteSummary >> Helper >> initialize >> End');
    },

    quoteSelection : function(component, event, helper, quoteId) {
        console.log('TA_LCP233_QuoteSummary >> Helper >> quoteSelection >> Start');
        let quotes = component.get('v.quotes');
        quotes.forEach(function(quote) {
            if(quote.id == quoteId) {
                component.set('v.selectedQuotationId', quote.id);
                component.set('v.selectedQuotationOpptyId', quote.opptyId);
            }
        });
        component.set('v.quotes', quotes);
        console.log('TA_LCP233_QuoteSummary >> Helper >> quoteSelection >> End');
    },

    manageVisibility : function(component, event, helper, field) {
        console.log('TA_LCP233_QuoteSummary >> Helper >> manageVisibility >> Start');
        let quoteId = event.currentTarget.id;
        let quotes = component.get('v.quotes');

        quotes.forEach(function(quote) {
            if(quote.id == quoteId) {
                quote[field] = !quote[field];
            }
        });
        component.set('v.quotes', quotes);
        console.log('TA_LCP233_QuoteSummary >> Helper >> manageVisibility >> End');
    },

    manageEdit : function(component, event, helper) {
        console.log('TA_LCP233_QuoteSummary >> Helper >> manageEdit >> Start');

        let updateToPhaseEvaluation = component.get('c.updateToPhaseEvaluation');
        let buttonName = (event.currentTarget.name == 'button-edit') ? 'edit' : 'addMore';
        let quoteId = event.currentTarget.id;
        let parameters = {
                            "quoteToModify" : quoteId,
                            "actionModify" : buttonName
                        };

        updateToPhaseEvaluation.setParams({
                                            'workOrder' : component.get('v.workOrder'),
                                            'parameters' : JSON.stringify(parameters)
                                        });
        updateToPhaseEvaluation.setCallback(this, function(response) {
            console.log('TA_LCP233_QuoteSummary >> Helper >> manageEditCallback >> Start');
            if(response.getState() == "SUCCESS") {
                location.reload();
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
            console.log('TA_LCP233_QuoteSummary >> Helper >> manageEditCallback >> End');
        });
        helper.fireToggleSpinnerEvent(component, true);
        $A.enqueueAction(updateToPhaseEvaluation);

        console.log('TA_LCP233_QuoteSummary >> Helper >> manageEdit >> End');
    },

    manageGoToNextPhase : function(component, event, helper) {
        console.log('TA_LCP233_QuoteSummary >> Helper >> manageGoToNextPhase >> Start');
        component.set('v.nextStepCallback', event.getParam('params').callback);
        let moveOrdersToMainOppty = component.get('c.moveOrdersToMainOppty');

        moveOrdersToMainOppty.setParam('workOrder', component.get('v.workOrder'));

        moveOrdersToMainOppty.setCallback(this, function(response) {
            console.log('TA_LCP233_QuoteSummary >> Helper >> moveOrdersToMainOpptyCallback >> Start');
            if(response.getState() == "SUCCESS") {
                helper.changeOrderRecordType(component, event, helper);
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
            console.log('TA_LCP233_QuoteSummary >> Helper >> moveOrdersToMainOpptyCallback >> End');
        });

        $A.enqueueAction(moveOrdersToMainOppty);
        console.log('TA_LCP233_QuoteSummary >> Helper >> manageGoToNextPhase >> End');
    },

    changeOrderRecordType : function(component, event, helper) {
        console.log('TA_LCP233_QuoteSummary >> Helper >> changeOrderRecordType >> Start');
        let changeOrderRecordType = component.get("c.changeOrderRecordType");
        changeOrderRecordType.setParams({
            'workOrder' : component.get('v.workOrder'),
            'selectedQuote' : component.get('v.selectedQuotationId')
        });

        changeOrderRecordType.setCallback(this, function(response) {
            console.log('TA_LCP233_QuoteSummary >> Helper >> changeOrderRecordTypeCallback >> Start');
            if(response.getState() == "SUCCESS") {
                if(response.getReturnValue().quoteToAccept) {
                    helper.manageUpdateAllQuote(component, event, helper, response.getReturnValue().quoteToAccept);
                } else if(response.getReturnValue().error) {
                    component.set("v.showToastMessage", true);
                    component.set("v.isError", true);
                    component.set("v.toastMessage", response.getReturnValue().error);
                }
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
            console.log('TA_LCP233_QuoteSummary >> Helper >> changeOrderRecordTypeCallback >> End');
        });

        $A.enqueueAction(changeOrderRecordType);
        console.log('TA_LCP233_QuoteSummary >> Helper >> changeOrderRecordType >> End');
    },

    manageUpdateAllQuote : function(component, event, helper, quoteToAccept) {
        console.log('TA_LCP233_QuoteSummary >> Helper >> manageUpdateAllQuote >> Start');
        let updateQuote = component.get("c.updateQuote");

        updateQuote.setParams({
            'workOrder' : component.get('v.workOrder'),
            'quoteStatus' : event.getParam('params').status,
            'quoteToAccept' : quoteToAccept
        });

        updateQuote.setCallback(this, function(response) {
            console.log('TA_LCP233_QuoteSummary >> Helper >> updateQuoteCallback >> Start');
            if(response.getState() == "SUCCESS") {
                if(!response.getReturnValue().error) {
                    helper.manageQuoteSummaryEvt('TA_LCP199_ButtonSection', component.get("v.nextStepCallback").action, component.get("v.nextStepCallback").params);
                } else {
                    component.set("v.showToastMessage", true);
                    component.set("v.isError", true);
                    component.set("v.toastMessage", response.getReturnValue().error);
                }
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
            console.log('TA_LCP233_QuoteSummary >> Helper >> updateQuoteCallback >> End');
        });

        $A.enqueueAction(updateQuote);
        console.log('TA_LCP233_QuoteSummary >> Helper >> manageUpdateAllQuote >> End');
    },

    fireSendInitStateEvt : function(component, isInitialized) {
        console.log('TA_LCP233_QuoteSummary >> Helper >> fireSendInitStateEvt >> Start');
        let sendInitStateEvt = component.getEvent("sendInitStateEvt");
        sendInitStateEvt.setParams({
            "componentName" : "TA_LCP233_QuoteSummary",
            "initState" : isInitialized
        });
        sendInitStateEvt.fire();
        console.log('TA_LCP233_QuoteSummary >> Helper >> fireSendInitStateEvt >> End');
    },

    fireToggleSpinnerEvent : function(component, toggleSpinner) {
        console.log('TA_LCP233_QuoteSummary >> Helper >> fireToggleSpinnerEvent >> Start');
        let toggleSpinnerEvent = component.getEvent("toggleSpinnerEvent");
        toggleSpinnerEvent.setParams({
            "sourceComponent" : "TA_LCP233_QuoteSummary",
            "toggleSpinner" : toggleSpinner
        });
        toggleSpinnerEvent.fire();
        console.log('TA_LCP233_QuoteSummary >> Helper >> fireToggleSpinnerEvent >> End');
    },

    manageQuoteSummaryEvt : function(handlerCmpName, action, params) {
        console.log('TA_LCP233_QuoteSummary >> Helper >> manageQuoteSummaryEvt >> Start');
        let fireCreateOrderEvent = $A.get("e.c:TA_LCE233_QuoteSummary");
        fireCreateOrderEvent.setParams({
            'handlerCmpName' : handlerCmpName,
            'action' : action,
            'params' : params
        });
        fireCreateOrderEvent.fire();
        console.log('TA_LCP233_QuoteSummary >> Helper >> manageQuoteSummaryEvt >> End');
    },

    changeSelectedQuoteOppty : function(component, event, helper) {
        console.log('TA_LCP233_QuoteSummary >> Helper >> changeSelectedQuoteOppty >> Start');
        let selectedQuotationOpptyId = component.get('v.selectedQuotationOpptyId');
        helper.manageQuoteSummaryEvt('TA_LCP199_ButtonSection', 'changeSelectedQuoteOppty', selectedQuotationOpptyId);
        console.log('TA_LCP233_QuoteSummary >> Helper >> changeSelectedQuoteOppty >> End');
    }
})