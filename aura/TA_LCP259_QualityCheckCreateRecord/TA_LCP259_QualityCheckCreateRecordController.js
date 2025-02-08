({
    handleInitialize : function(component, event, helper) {
        console.log('TA_LCP259_QualityCheckCreateRecord >> Controller >> handleInitialize >> Start');
        helper.initialize(component, event, helper);
        console.log('TA_LCP259_QualityCheckCreateRecord >> Controller >> handleInitialize >> End');
    },

    handleManageActions : function(component, event, helper) {
        console.log('TA_LCP259_QualityCheckCreateRecord >> Controller >> handleManageActions >> Start');
        if(event.currentTarget.name == 'new') {
            component.set('v.recordSubmit', null);
            component.set('v.showQualityCheckModal', true);
        } else if (event.currentTarget.name == 'edit') {
            let records = component.get('v.records');
            let recordSubmit = {};
            records.forEach(function(record) {
                if(record.id == event.currentTarget.id) recordSubmit = record;
            })
            component.set('v.recordSubmit', recordSubmit);
            component.set('v.showQualityCheckModal', true);
        } else if (event.currentTarget.name == 'delete') {
            helper.deleteRecord(component, event.currentTarget.id);
        } else if (event.currentTarget.name == 'validate') { //ENCXRM-151 HSEQ BGO
            helper.openModalQualityCheckValidation(component, component.get("v.custom"), event.currentTarget.id);
        }
        console.log('TA_LCP259_QualityCheckCreateRecord >> Controller >> handleManageActions >> End');
    },

    handleSubmitForm: function(component, event, helper) {
        console.log('TA_LCP259_QualityCheckCreateRecord >> Controller >> handleSubmit >> Start');
        helper.fireToggleSpinnerEvent(component, true);
        helper.submitForm(component, event);
        console.log('TA_LCP259_QualityCheckCreateRecord >> Controller >> handleSubmit >> End');
    },

    handleFormError: function(component, event, helper) {
        console.log('TA_LCP259_QualityCheckCreateRecord >> Controller >> handleFormError >> Start');
        console.log('>_> Error : ' + JSON.stringify(event.getParam('output')));
        let errors = event.getParam('output').errors;
        let errorMessage  = "";
        for (const i in errors) {
            errorMessage += errors[i].message;
        }
        component.set("v.showToastMessage", true);
        component.set("v.isError", true);
        component.set("v.toastMessage", errorMessage);
        
        helper.fireToggleSpinnerEvent(component, false);
        console.log('TA_LCP259_QualityCheckCreateRecord >> Controller >> handleFormError >> End');
    },

    handleFormSuccess: function(component, event, helper) {
        console.log('TA_LCP259_QualityCheckCreateRecord >> Controller >> handleFormSuccess >> Start');
        // var record = event.getParam("response");
        // var recordSubmit =  {};
        // recordSubmit['Id'] = record.id;
        // recordSubmit['Name'] = record.fields.Name.value;
        // recordSubmit['XC_Status__c'] = record.fields.XC_Status__c.value;
        
        // component.set("v.recordSubmit", recordSubmit);
        helper.getCurrentRecords(component);
        component.set('v.showQualityCheckModal', false);
        console.log('TA_LCP259_QualityCheckCreateRecord >> Controller >> handleFormSuccess >> End');
    },
    
    handleCloseModalCloseService: function(component, event, helper) {
        console.log('TA_LCP259_QualityCheckCreateRecord >> Controller >> handleCloseModalCloseService >> Start');
        component.set('v.showQualityCheckModal', false);
        console.log('TA_LCP259_QualityCheckCreateRecord >> Controller >> handleCloseModalCloseService >> End');
    },

    handleCloseModalQualityCheckValidation  : function(component, event, helper) {
        console.log('TA_LCP259_QualityCheckCreateRecord >> Controller >> handleCloseModalQualityCheckValidation >> Start');
        helper.closeModalQualityCheckValidation(component, event, helper);
        console.log('TA_LCP259_QualityCheckCreateRecord >> Controller >> handleCloseModalQualityCheckValidation >> End');
    },

    handleStatusChange : function(component,event,helper){
        console.log('TA_LCP259_QualityCheckCreateRecord >> Controller >> handleStatusChange >> Start');
      
        console.log('event status: '+event.getParam('status'));
        // if (event.getParam('status') === "FINISHED") {
        //     component.set('v.showComponentFlow', !component.get('v.showComponentFlow'));
        //     helper.fireToggleSpinnerEvent(component, true, 'TA_LCP217_Interventions');
        //     helper.init(component,event,helper, true, null);
        // }
        //helper.closeModalQualityCheckValidation(component, event, helper);
        window.location.reload();
        console.log('TA_LCP259_QualityCheckCreateRecord >> Controller >> handleStatusChange >> End');
    },

    handleResponseLayout : function(component, event, helper) {
        console.log('TA_LCP259_QualityCheckCreateRecord >> Controller >> handleResponseLayout >> Start');
        helper.responseLayout(component, event);
        console.log('TA_LCP259_QualityCheckCreateRecord >> Controller >> handleResponseLayout >> End');
    },
    handleChangeRecordSubmit : function(component, event, helper) {
        console.log('TA_LCP259_QualityCheckCreateRecord >> Controller >> handleChangeRecordSubmit >> Start');
        component.set("v.recordSubmitChange", !component.get("v.recordSubmitChange"));
        console.log('TA_LCP259_QualityCheckCreateRecord >> Controller >> handleChangeRecordSubmit >> End');
    },
})