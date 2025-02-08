({
    handleInitialize : function(component, event, helper) {
        console.log('TA_LCP242_DynamicCreateRecord >> Controller >> handleInitialize >> Start');
        helper.initialize(component, event, helper);
        console.log('TA_LCP242_DynamicCreateRecord >> Controller >> handleInitialize >> End');
    },

    handleManageShowFormModal : function(component, event, helper) {
        console.log('TA_LCP242_DynamicCreateRecord >> Controller >> handleOpenFormModal >> Start');
        component.set('v.showFormModal', !component.get('v.showFormModal'));
        if(component.get('v.showFormModal')) document.getElementById('scroll-div').scrollIntoView();
        console.log('TA_LCP242_DynamicCreateRecord >> Controller >> handleOpenFormModal >> End');
    },

    handleSubmitForm : function(component, event, helper) {
        console.log('TA_LCP242_DynamicCreateRecord >> Controller >> handleSubmitForm >> Start');
        helper.fireToggleSpinnerEvent(component, true);
        helper.submitForm(component, event);
        console.log('TA_LCP242_DynamicCreateRecord >> Controller >> handleSubmitForm >> End');
    },

    handleSuccess : function(component, event, helper) {
        console.log('TA_LCP242_DynamicCreateRecord >> Controller >> handleSuccess >> Start');
        helper.success(component, event);
        console.log('TA_LCP242_DynamicCreateRecord >> Controller >> handleSuccess >> End');
    },

    handleResponseLayout : function(component, event, helper) {
        console.log('TA_LCP242_DynamicCreateRecord >> Controller >> handleResponseLayout >> Start');
        helper.responseLayout(component, event);
        console.log('TA_LCP242_DynamicCreateRecord >> Controller >> handleResponseLayout >> End');
    },

    /*handleManageRecordSubmit : function(component, event, helper) {
        console.log('TA_LCP242_DynamicCreateRecord >> Controller >> handleManageRecordSubmit >> Start');
        if(event.currentTarget.name == 'delete') helper.deleteRecord(component); 
        console.log('TA_LCP242_DynamicCreateRecord >> Controller >> handleManageRecordSubmit >> End');
    },*/

    handleChangeRecordSubmit : function(component, event, helper) {
        console.log('TA_LCP242_DynamicCreateRecord >> Controller >> handleChangeRecordSubmit >> Start');
        // START FIX [ADC23-06-2021] ENXCRM-159 
        //helper.fireEvts(component, component.get('v.recordSubmit') == null ? [$A.get("$Label.c.TA_TechnicalSheetRequired")] : []);
        if(component.get('v.isRequired')){                   
            helper.fireEvts(component, component.get('v.recordSubmit') == null ? [component.get('v.isRequiredErrorLabel')] : []);  
        }
        // END FIX [ADC23-06-2021] ENXCRM-159
        console.log('TA_LCP242_DynamicCreateRecord >> Controller >> handleChangeRecordSubmit >> End');
    },

    handleChangeRecordTypeId : function(component, event, helper) {
        console.log('TA_LCP242_DynamicCreateRecord >> Controller >> handleChangeRecordTypeId >> Start');
        helper.changeRecordTypeId(component);
        console.log('TA_LCP242_DynamicCreateRecord >> Controller >> handleChangeRecordTypeId >> End');
    },

    handleManageActions : function(component, event, helper) {
        console.log('TA_LCP242_DynamicCreateRecord >> Controller >> handleManageActions >> Start');
        if(event.currentTarget.name == 'new') {
            component.set('v.recordSubmit', null);
            component.set('v.showFormModal', !component.get('v.showFormModal'));
        } else if (event.currentTarget.name == 'edit') {
            let records = component.get('v.records');
            let recordSubmit = {};
            records.forEach(function(record) {
                if(record.id == event.currentTarget.id) recordSubmit = record;
            })
            component.set('v.recordSubmit', recordSubmit);
            component.set('v.showFormModal', !component.get('v.showFormModal'));
        } else if (event.currentTarget.name == 'delete') {
            helper.deleteRecord(component, event.currentTarget.id);
        } 
        console.log('TA_LCP242_DynamicCreateRecord >> Controller >> handleManageActions >> End');
    },

    handleError : function(component, event, helper) {
        console.log('TA_LCP242_DynamicCreateRecord >> Controller >> handleError >> Start');
        helper.error(component, event);
        console.log('TA_LCP242_DynamicCreateRecord >> Controller >> handleError >> End');
    }, 

})