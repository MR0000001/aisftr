({
  init: function (component, event, helper) {
    helper.doInit(component, event, helper);
    let actionShowPopUp = component.get("c.areConsentsGiven");
    actionShowPopUp.setParams({'recordId': component.get("v.recordId")});
    actionShowPopUp.setCallback(this, function(response){
    let state = response.getState();
    if (component.isValid() && state === "SUCCESS") {
        let result = response.getReturnValue();
            component.set("v.ShowModule", result);
        }
    })
    $A.enqueueAction(actionShowPopUp);
  },

  btnClose: function(component, event, helper){
    //$A.get("e.force:closeQuickAction").fire()
    //
    location.reload();

    component.set("v.ShowModule", false);
    //$A.get('e.force:refreshView').fire()
    //$A.enqueueAction($A.get("e.force:closeQuickAction").fire() );
    //$A.enqueueAction($A.get('e.force:refreshView').fire());
    //component.destroy();
    
    //$A.enqueueAction($A.get('e.force:refreshView').fire());
  },

  btnCancel: function(component){
    component.set("v.getConsentsFromCommodity", "false");
  },

    btnCloseWithConsents: function(component){
      let actionShowPopUp = component.get("c.areConsentsGiven");
      actionShowPopUp.setParams({'recordId': component.get("v.recordId")});
      actionShowPopUp.setCallback(this, function(response){
      let state = response.getState();
      if (component.isValid() && state === "SUCCESS") {
          let result = response.getReturnValue();
              if(!result){
                location.reload();
              }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "It is necessary to confirm the consents and save",
                    "type":"error"
                });
                
                toastEvent.fire();
              }
          }
      })
      $A.enqueueAction(actionShowPopUp);
  },
  createComponent: function (component, event, helper) {

        let action = component.get("c.callToCommoditySecondPart");
        let selectedAccount  =  component.get("v.accountCommodityObj");
        let accountIndex =  event.getSource().get("v.value");
        console.log('@@@@ selectedAccount: ' + JSON.stringify(selectedAccount[accountIndex]));
        let selectedAccountJSON =  JSON.stringify(selectedAccount[accountIndex]);
        action.setParams({
            'recordId': component.get("v.recordId"),
            'selectedAccount': selectedAccountJSON,
        });
        action.setCallback(this, function (response) {

            let state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                let result = response.getReturnValue();
                console.log('@@@@ result ' + JSON.stringify(result.commodityAccountResult));
                if (!result.success) {
                    component.set("v.commodityGlobalMessage", result.message);
                    return;
                }
                component.set("v.accountCommodityObj2", result.commodityAccountResult);
                component.set("v.contractCommodityObj", result.commodityContractResult);
                console.log('@@@ Account Contract Result ' + JSON.stringify(component.get("v.contractCommodityObj")));
                component.set("v.caseCommodityObj", result.commodityCaseResult);
                component.set("v.invoiceCommodityObj", result.commodityInvoiceResult);
                component.set("v.accountDocCountry", result.accountDocCountry);
                component.set("v.selectedAccount", event.getSource().get("v.value"));
                component.set("v.showCard", false);
            }
            
        });
        $A.enqueueAction(action);
      },
      
      // this function automatic call by aura:waiting event  
      showSpinner: function(component, event, helper) {
       // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
     },
      
     // this function automatic call by aura:doneWaiting event 
      hideSpinner : function(component,event,helper){
       // make Spinner attribute to false for hide loading spinner    
       component.set("v.Spinner", false);
      }
  
}
)