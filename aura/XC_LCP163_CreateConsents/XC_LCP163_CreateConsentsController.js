/**
 * Created by dpalamides on 14/10/2019.
 */
({
    doInit : function(component, event, helper) {
         helper.init(component, event, helper);
    },
    saveLegalEntityConsent : function(component, event, helper) {
        helper.save(component, event, helper);
    }
    ,
    saveLegalEntityConsentThirdParty : function(component, event, helper) {
        helper.saveThirdParty(component, event, helper);
    },
    onChangeNewObject : function(component, event, helper) {
        helper.onChangeNewObject(component, event, helper);
    },
    onChangeAddLegalEntityWrapper : function(component, event, helper) {
        helper.onChangeAddLegalEntityWrapper(component, event, helper);
    },
    removeLegalEntityConsent : function(component, event, helper) {
            helper.removeLegalEntityConsent(component, event, helper);
    },
    showHideSelection : function(component, event, helper) {
        let arr = component.get("v.optionsLE");
        if(arr.length>=1){
            component.set("v.showLeSelection",!component.get("v.showLeSelection"));
        }
    },
    changeConfirmationByTheCustomer : function(component, event, helper) {
        let confirmationByTheCustomerVar = !(component.get("v.legalEntitiesList"))[0].confirmationByTheCustomer;
        let list = component.get("v.legalEntitiesList");
        if(confirmationByTheCustomerVar!=null && confirmationByTheCustomerVar!=undefined){
            list.forEach(function(element) {
              element.confirmationByTheCustomer = confirmationByTheCustomerVar;
            });
            component.set("v.legalEntitiesList",list); 
        }

    }
})