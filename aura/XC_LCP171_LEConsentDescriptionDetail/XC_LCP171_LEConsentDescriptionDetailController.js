/**
    *@author Francesco Imperioli - fimperioli@deloitte.it
    *@date 13/5/2020
    *@Modified by Salvatore Agrillo - salvatore.agrillo@nttdata.com - 27/10/2020
    *@description XC_LCP171_LEConsentDescriptionDetailController - Controller Javascript for component LCP171
*/

({
    init : function(component, event, helper) {
        helper.doInit(component, event, helper);
    },

    onSuccessSave : function(component,event,helper){
        let toastEv = $A.get("e.force:showToast");
        toastEv.setParams({
            "title" : "Success",
            "message" : $A.get("$Label.c.XC_CL_Consent_Save"),
            "type" : "success"
        });
        toastEv.fire();
        component.set("v.readOnly", true);
    },

    edit : function(component,event,helper){
        component.set("v.readOnly", false);
    },

    handleCancel : function(component,event,helper){
        component.set("v.readOnly", true);
    }
    
})