/*
* @author Monica Cutillo - monicaa.cutillo@nttdata.com
* @date Creation 16/01/2019
* @date Modification 25/10/2019 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description XC_LCP028_CreateOppFromContact – Helper class for component for Redirect to Create Opportunity
**/

({

    doInit: function (component, event, helper) {
        component.set("v.spinnerControl", true);
        console.log('@@@ In XC_LCP053_RedirectOpportunityHelper with recordId = ', component.get('v.recordId'));
        let action = component.get("c.retrieveInfoForRedirect");
        action.setParams({
            "userId": $A.get("$SObjectType.CurrentUser.Id"),
            "idSobject": component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                let result = response.getReturnValue();
                console.log('@@@ result -> ', result);

                if(!result.documentExists){
                    let toastEvent = $A.get("e.force:showToast");
				    toastEvent.setParams({
				    	title: "Error",
				    	message: $A.get("$Label.c.XC_CL_NoDocForAccountMess") ,
				    	key: 'info_alt',
				    	type: 'error',
				    	mode: 'dismissible'
				    });
                    toastEvent.fire();
                }else{
                    if (result.typeObject == 'WorkOrder') {
                        component.set('v.fromContact', result.canCreateOpp);
                        component.set("v.contactId", result.contactId);
                        component.set("v.accountId", result.accountId);
                        component.set("v.workOrderId", result.workOrderId);
                        component.set("v.stageName", result.stageName);
                        component.set("v.closeDate", result.closeDate);
                        component.set("v.addressId", result.addressId);
                        component.set("v.productCategory", result.productCategory);
                    }
                    component.set('v.receivingChannel', result.channelUser);
                    component.set('v.initRedirect', true);
                }

                
                component.set("v.spinnerControl", false);
            }
        });
        $A.enqueueAction(action);
    }

})