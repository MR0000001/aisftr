({
    handleInitialize : function(component, event, helper) {
        console.log('XC_LCP216_GeneratedReport >> Controller >> handleInitialize >> Start');
        helper.initialize(component, event, helper);
        console.log('XC_LCP216_GeneratedReport >> Controller >> handleInitialize >> End');
    },

    handleManageGeneratedReportModal : function(component, event, helper) {
        console.log('XC_LCP216_GeneratedReport >> Controller >> handleManageGeneratedReportModal >> Start');
        helper.manageGeneratedReportModal(component, event, helper);
        console.log('XC_LCP216_GeneratedReport >> Controller >> handleManageGeneratedReportModal >> End');
    },

    handleSubmitSignedReportModal : function(component, event, helper) {
        console.log('XC_LCP216_GeneratedReport >> Controller >> handleSubmitSignedReportModal >> Start');
        helper.manageSubmitSignedReportModal(component, event, helper);
        console.log('XC_LCP216_GeneratedReport >> Controller >> handleSubmitSignedReportModal >> End');
    },

    handleSubmitReport : function(component, event, helper) {
        console.log('XC_LCP216_GeneratedReport >> Controller >> handleSubmitReport >> Start');
        helper.submitReport(component, event, helper);
        console.log('XC_LCP216_GeneratedReport >> Controller >> handleSubmitReport >> End');
    }
})