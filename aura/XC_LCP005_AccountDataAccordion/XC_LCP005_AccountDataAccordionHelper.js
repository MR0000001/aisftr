({
	doInit : function(component, event, helper) {
		let action = component.get("c.firstCallCommodityContinuation");
        action.setParams({
            'recordId': component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            let identityNumber;
            if (component.isValid() && state === "SUCCESS") {
                let firstContinuationResult = response.getReturnValue();
                if(!firstContinuationResult.success){
                    component.set("v.commodityGlobalMessage",firstContinuationResult.message);
                    return;
                }
                component.set("v.accountCommodityObj",firstContinuationResult.commodityAccountResult);
                component.set("v.contractCommodityObj",firstContinuationResult.commodityContractResult);
                component.set("v.sobjecttype",firstContinuationResult.sobjectTypeName);
                identityNumber = firstContinuationResult.identityNumber;
            }
            
            let action2 = component.get("c.secondCallCommodityContinuation");
            action2.setParams({
                'recordId': component.get("v.recordId"),
                'identityNumber': identityNumber
            });
            action2.setCallback(this, function(response) {
                let state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
                    let secondContinuationResult = response.getReturnValue();
                    component.set("v.caseCommodityObj",secondContinuationResult.commodityCaseResult);
                    component.set("v.invoiceCommodityObj",secondContinuationResult.commodityInvoiceResult);
                }
            });
            $A.enqueueAction(action2);
        });
        $A.enqueueAction(action);
	}

    /* New Inint without the continuation */
    /*doInit : function(component, event, helper) {
		let action = component.get("c.callToCommodity");
        action.setParams({
            'recordId': component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                let result = response.getReturnValue();
                if(!result.success){
                    component.set("v.commodityGlobalMessage",result.message);
                    return;
                }
                component.set("v.accountCommodityObj",result.commodityAccountResult);
                component.set("v.contractCommodityObj",result.commodityContractResult);
                component.set("v.caseCommodityObj",result.commodityCaseResult);
                component.set("v.invoiceCommodityObj",result.commodityInvoiceResult);
            }

        });
        $A.enqueueAction(action);
    }*/
})