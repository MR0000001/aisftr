({
    init : function(component, event, helper) {
        helper.doInit(component,event,helper);
    },
    
    editDraftOrder : function(component,event,helper){
        helper.openEditOrder(component,event,helper);
    },

    closeOrderModal : function(component,event,helper){

        component.set("v.openOrderCmp", false);
        let modaltargetext = component.find('ExtModal');
        let backdroptargetext = component.find('Modalbackdrop');
        $A.util.removeClass(modaltargetext, 'slds-fade-in-open');
        $A.util.removeClass(backdroptargetext, 'slds-backdrop--open');
    },

    completeChildOrder : function(component,event,helper){
        helper.completeChildOrder(component,event,helper);
    }


})