({
    init : function(component, event, helper) {
        helper.doInit(component,event,helper);
    },

    handleNext: function(component,event,helper){
        let pageNumber = component.get("v.pageNumber");
        component.set("v.pageNumber",pageNumber+1);
        helper.doInit(component,event,helper);
    },

    handlePrev: function(component,event,helper){
        let pageNumber = component.get("v.pageNumber");
        component.set("v.pageNumber",pageNumber-1);
        helper.doInit(component,event,helper);
    },

    caseSelected: function(component,event,helper){
        helper.onCaseSelected(component,event,helper);
    },

    createCase: function(component,event,helper){
        helper.handleCreateCase(component,event,helper);
    }


})