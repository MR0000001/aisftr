({
    doInit : function(component, event, helper) {
        let modaltarget = component.find("ExtModal");
        let backdroptarget = component.find("Modalbackdrop");

        if(component.get("v.openModal")){
            $A.util.addClass(modaltarget, 'slds-fade-in-open');
        }else{
            $A.util.removeClass(backdroptarget, 'slds-backdrop--open');
        }

        if(component.get("v.openBackDrop")){
            $A.util.addClass(backdroptarget, 'slds-backdrop--open');
        }else{
            $A.util.removeClass(backdroptarget, 'slds-backdrop--open');
        }

        helper.doInit(component,event,helper);


    },

    quoteClick : function(component,event,helper){
        component.set("v.quoteSelected",true);
        component.set("v.rtSelected","Quote");
        component.set("v.showCapexError",false);
    },

    orderClick : function(component,event,helper){
        component.set("v.orderSelected",true);
        component.set("v.rtSelected","Order");
        component.set("v.showCapexError",false);
    },

    closeFirstModal : function(component,event,helper){
        //TODO:SEND EVENT TO FATHER COMPONENT
        let modaltarget = component.find('ExtModal');
        let backdroptarget = component.find('Modalbackdrop');

        $A.util.removeClass(modaltarget, 'slds-fade-in-open');
        $A.util.removeClass(backdroptarget, 'slds-backdrop--open');
        let ev = component.getEvent("XC_LCE019_CloseChildComponent");
        ev.fire();

    },

    processNextStep : function(component,event,helper){
        helper.processNextStep(component,event,helper);
    },

    undoSelection : function(component,event,helper){
        if(component.get("v.quoteSelected")){
            component.set("v.quoteSelected",false);
        }else if(component.get("v.orderSelected")){
            component.set("v.orderSelected",false);
        }
        component.set("v.showCapexError",false);
    }

})