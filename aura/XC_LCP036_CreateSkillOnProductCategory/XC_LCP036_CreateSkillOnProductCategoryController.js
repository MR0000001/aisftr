({
    init: function (component, event, helper) {
        helper.fetchData(component);
    },
    newRecord: function(component, event, helper){ 
        helper.initializeRecord(component);     
    }, 
    handleClickCancel: function(component, event, helper) {
        helper.handleClickCancelHelper(component);
    },
    handleClickSave: function(component, event, helper) {
        helper.handleSaveRecord(component); 
    },
    handleRowAction: function (component, event, helper) {
        helper.handleRowActionHelper(component,event);
    }
})