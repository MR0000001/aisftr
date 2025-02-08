({
   
    /*init : function(component, event, helper){
        helper.doInit(component, event, helper);
    },*/

    addNewRow : function(component, event, helper){
        let ev = component.getEvent("XC_LCE_RowEvt");
        ev.setParams({"operation" : "Add"});
        ev.fire();
    },

    removeRow : function(component, event, helper){
        let ev = component.getEvent("XC_LCE_RowEvt");
        ev.setParams({"operation" : "Delete", "indexVar" : component.get("v.rowIndex") });
        ev.fire();
    },

    onConsentsChange : function(component){
        let ev = component.getEvent("XC_LCE_SetLEConsents");
        ev.fire();
        //fire component LE event
        let cmpEv = component.getEvent("XC_LCE111_SetLegalEntityConsents");
        cmpEv.fire();
    },

    onCountryChange : function(component, event, helper){
        helper.onCountryChange(component, event, helper);
    },
})