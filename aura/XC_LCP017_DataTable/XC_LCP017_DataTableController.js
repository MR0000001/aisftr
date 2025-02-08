({
    cancel : function(component,event,helper){
        helper.cancel(component,event);
    },
    
    sendEvent : function(component, event, helper) {
        helper.sendEvent(component, event);
    },
    
    updateSelectedRows : function(component, event, helper) {
        helper.updateSelectedRowsHelper(component, event);
    }
    
})