({
    handleInitialize : function(component, event, helper) {
        console.log('TA_LCP234_PaymentMethod >> Controller >> handleInitialize >> Start');
        helper.initialize(component, event, helper, false);
        console.log('TA_LCP234_PaymentMethod >> Controller >> handleInitialize >> End');
    },

    handleSelectPaymentMethod: function (component, event, helper) { 
        console.log('TA_LCP234_PaymentMethod >> Controller >> handleSelectPaymentMethod >> Start'); 
        helper.selectPaymentMethod(component,event,helper); 
        console.log('TA_LCP234_PaymentMethod >> Controller >> handleSelectPaymentMethod >> End'); 
    },

    // handleInvoicePreferences: function (component, event, helper) {
    //     console.log('TA_LCP234_PaymentMethod >> Controller >> handleInvoicePreferences >> Start');
    //     console.log('TA_LCP234_PaymentMethod >> invoicePreference: ' + component.get("v.invoicePreference"));
    // },

    handleRadioModalPreferences: function (component, event, helper) {
        console.log('TA_LCP234_PaymentMethod >> Controller >> handleRadioModalPreferences >> Start');
        let radioModalPreference = event.getParam("value");
        component.set("v.radioModalPreference",radioModalPreference);
        console.log('TA_LCP234_PaymentMethod >> radioModalPreference: ' + radioModalPreference );
    },

    handleCardChecked: function (component, event, helper) {
        console.log('TA_LCP234_PaymentMethod >> Controller >> handleCardChecked >> Start');
        helper.cardChecked(component, event, helper);
        console.log('TA_LCP234_PaymentMethod >> Controller >> handleCardChecked >> End');
    },

    handleShowNewPaymentModal: function (component, event, helper) {
        console.log('TA_LCP234_PaymentMethod >> Controller >> handleShowNewPaymentModal >> Start');
        helper.showNewPaymentModal(component, event, helper);
        console.log('TA_LCP234_PaymentMethod >> Controller >> handleShowNewPaymentModal >> End');
    },

    handleModalIban: function (component, event, helper) {
        console.log('TA_LCP234_PaymentMethod >> Controller >> handleModalIban >> Start');
        helper.modalIban(component,event,helper);     
        console.log('TA_LCP234_PaymentMethod >> Controller >> handleModalIban >> End');
    },

    handleModalBic: function (component, event, helper) {
        console.log('TA_LCP234_PaymentMethod >> Controller >> handleModalBic >> Start');
        helper.modalBic(component,event,helper);
        console.log('TA_LCP234_PaymentMethod >> Controller >> handleModalBic >> End');
    },

    handleUpperCase: function (component, event, helper) {
        let value = event.getSource().get('v.value'); 
        if(event.getSource().get('v.name') == 'iban'){
            component.set("v.iban",value.toUpperCase());
        }
        if(event.getSource().get('v.name') == 'bic'){
            component.set("v.bic",value.toUpperCase());
        }       
    },

    handleModalButton: function (component, event, helper) {
        console.log('TA_LCP234_PaymentMethod >> Controller >> handleModalButton >> Start');
        helper.modalButton(component,event,helper);
        console.log('TA_LCP234_PaymentMethod >> Controller >> handleModalButton >> End');
    },
    
    handleUpdateOrderItemBillingProfile: function (component, event, helper) {
        console.log('TA_LCP234_PaymentMethod >> Controller >> handleUpdateOrder >> Start');
        if(event.getParam('handlerCmpName') == 'TA_LCP234_PaymentMethod') {
            helper.updateOrderItemBillingProfile(component, event, helper);
        }
        console.log('TA_LCP234_PaymentMethod >> Controller >> handleUpdateOrder >> End');
    },

    closeZuoraComponent: function (component, event, helper) {
        console.log('TA_LCP234_PaymentMethod >> Controller >> closeZuoraComponent >> Start');
        component.set('v.showZuora',false);
        component.set('v.showNewPaymentModal',false);
        component.set('v.disabledNewPaymentMethod', true);
        console.log('TA_LCP234_PaymentMethod >> Controller >> closeZuoraComponent >> End');
    },

    handleSelectBillingAddress : function (component, event, helper) {
        console.log('TA_LCP234_PaymentMethod >> Controller >> handleSelectBillingAddress >> Start');
        helper.fireToggleSpinnerEvent(component, true);
        helper.selectBillingAddress(component, event, helper);
        console.log('TA_LCP234_PaymentMethod >> Controller >> handleSelectBillingAddress >> End');
    }
})