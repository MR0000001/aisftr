/**
  * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
  * @date 24/03/2021
  * @description XC_LCP246_DocumentManagementController - Javascript Controller for LCP246
*/

({
    init : function(component, event, helper) {
        console.log('@@@ In XC_LCP246_DocumentManagement');
        helper.doInit(component, event, helper, true);
    },

    refreshTable : function(component, event, helper) {
        console.log('@@@ In XC_LCP246_DocumentManagement');
        helper.refreshTable(component, event, helper);
    },

    documentFiltered : function(component, event, helper) {
        console.log('@@@ In XC_LCP246_DocumentManagement');
        helper.documentFiltered(component, event, helper);
    },

    createEventDocumentOk : function(component, event, helper) {
        console.log('@@@ In XC_LCP246_DocumentManagement');
        helper.createEventDocumentOk(component, event, helper);
    },

    sendDocument : function(component, event, helper) {
        console.log('@@@ In XC_LCP246_DocumentManagement');
        helper.sendDocument(component, event, helper);
    },

    digitalSignature : function(component, event, helper) {
        console.log('@@@ In XC_LCP246_DocumentManagement');
        helper.digitalSignature(component, event, helper);
    },

    vocalOrderSign : function(component, event, helper) {
        console.log('@@@ In XC_LCP246_DocumentManagement');
        helper.vocalOrderSign(component, event, helper);
    },

    onVocalScript : function(component, event, helper) {
        console.log('@@@ In XC_LCP246_DocumentManagement');
        helper.onVocalScript(component, event, helper);
    },

    onSetURL : function(component, event, helper) {
        let setUrlOption = component.get('v.showSetURL');
        component.set('v.showSetURL', !setUrlOption);
    },

    onSaveURL : function(component, event, helper) {
        console.log('@@@ In XC_LCP246_DocumentManagement');
        helper.onSaveURL(component, event, helper);
    },

})