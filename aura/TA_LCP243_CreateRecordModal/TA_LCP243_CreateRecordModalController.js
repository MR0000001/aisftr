({
    handleInitialize : function(component, event, helper) {
        console.log('TA_LCP243_CreateRecordModal >> Controller >> handleInitialize >> Start');
        helper.initialize(component, event, helper);
        console.log('TA_LCP243_CreateRecordModal >> Controller >> handleInitialize >> End');
    },

    handleChangeRecordTypeId : function(component, event, helper) {
        console.log('TA_LCP243_CreateRecordModal >> Controller >> handleChangeRecordTypeId >> Start');
        helper.changeRecordTypeId(component);
        console.log('TA_LCP243_CreateRecordModal >> Controller >> handleChangeRecordTypeId >> End');
    },

    handleResponseLayout : function(component, event, helper) {
        console.log('TA_LCP243_CreateRecordModal >> Controller >> handleResponseLayout >> Start');
        helper.responseLayout(component, event);
        console.log('TA_LCP243_CreateRecordModal >> Controller >> handleResponseLayout >> End');
    },

    handleManageShowComponent : function(component, event, helper) {
        console.log('TA_LCP243_CreateRecordModal >> Controller >> handleManageShowComponent >> Start');
        component.set('v.showComponent', !component.get('v.showComponent'));        
        console.log('TA_LCP243_CreateRecordModal >> Controller >> handleManageShowComponent >> End');
    },

    handleManageShowFormModal : function(component, event, helper) {
        console.log('TA_LCP243_CreateRecordModal >> Controller >> handleManageShowFormModal >> Start');
        helper.manageShowFormModal(component,event,helper);
        console.log('TA_LCP243_CreateRecordModal >> Controller >> handleManageShowFormModal >> End');
    },

    handleSubmitForm : function(component, event, helper) {
        console.log('TA_LCP243_CreateRecordModal >> Controller >> handleSubmitForm >> Start');
        helper.fireToggleSpinnerEvent(component, true);
        helper.submitForm(component, event);
        console.log('TA_LCP243_CreateRecordModal >> Controller >> handleSubmitForm >> End');
    },

    handleSuccess : function(component, event, helper) {
        console.log('TA_LCP243_CreateRecordModal >> Controller >> handleSuccess >> Start');
        helper.success(component, event);
        console.log('TA_LCP243_CreateRecordModal >> Controller >> handleSuccess >> End');
    },
    handleError : function(component,event,helper){
        console.log('TA_LCP243_CreateRecordModal >> Controller >> handleError >> Start');
        console.log(JSON.stringify(event.getParams().error));
        component.set("v.showToastMessage", true);
        component.set("v.isError", true);
        let output = event.getParams().output;
        console.log(JSON.stringify(output.fieldErrors));
        if(output && output.fieldErrors){

        }
        component.set("v.toastMessage", JSON.stringify(event.getParams().error));
        helper.fireToggleSpinnerEvent(component, false);
        console.log('TA_LCP243_CreateRecordModal >> Controller >> handleError >> End');
    }

})