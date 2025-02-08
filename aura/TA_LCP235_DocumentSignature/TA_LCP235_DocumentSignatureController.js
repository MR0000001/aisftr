({
    handleInitialize: function (component, event, helper) {
        console.log('TA_LCP235_DocumentSignature >> Controller >> handleInitialize >> Start');
        helper.getInitInformation(component,event, helper, false);
        console.log('TA_LCP235_DocumentSignature >> Controller >> handleInitialize >> End');
    },

    openUrl: function (component, event, helper) {
        console.log('TA_LCP235_DocumentSignature >> Controller >> openUrl >> Start');   
        const url = event.currentTarget.id;
        component.set('v.iframeUrl', url)
        component.set('v.showModal', true)
        console.log('TA_LCP235_DocumentSignature >> Controller >> openUrl >> End');
    },

    switchModal: function (component, event, helper) {
        component.set('v.showModal', !component.get('v.showModal'))
    },

    refreshView: function (component, event, helper) {
        helper.fireToggleSpinnerEvent(component, true);
        helper.getInitInformation(component, event, helper, true);
    },

    handleManageShowDetails : function(component, event, helper) {
        component.set('v.showDetails', !component.get('v.showDetails'));
    }
})