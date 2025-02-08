({
    doInit : function(component,event,helper) {

        let opportunityRetrieved = component.get("v.optyRecord");
        console.log('OPPORTUNITY RECORD RETRIEVED BY BUTTON SECTION ' + JSON.stringify(opportunityRetrieved));
        component.set("v.showButtons",true);
        component.set("v.spinnerControl",false);
        component.set("v.orderOptions",{});


    },

    openEditOrder : function(component,event,helper){
        let opts = component.get("v.orderOptions");

        component.set("v.openModal", true);
        let modaltargetext = component.find('ExtModal');
        let backdroptargetext = component.find('Modalbackdrop');
        $A.util.addClass(modaltargetext, 'slds-fade-in-open');
        $A.util.addClass(backdroptargetext, 'slds-backdrop--open');

        opts['mode']='edit';
        component.set("v.orderOptions",opts);
        component.set("v.openOrderCmp", true);



    },

    completeChildOrder : function(component,event,helper){

        let opts = component.get("v.orderOptions");

        component.set("v.openModal", true);
        let modaltargetext = component.find('ExtModal');
        let backdroptargetext = component.find('Modalbackdrop');
        $A.util.addClass(modaltargetext, 'slds-fade-in-open');
        $A.util.addClass(backdroptargetext, 'slds-backdrop--open');

        opts['mode']='child_order';
        component.set("v.orderOptions",opts);
        component.set("v.openOrderCmp", true);

    }

})