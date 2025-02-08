({

    doInit: function (component) {


        ////////
        let action = component.get("c.callToCommodity");
        action.setParams({
            'recordId': component.get("v.recordId")
        });
        action.setCallback(this, function (response) {

            let state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                let result = JSON.parse(response.getReturnValue());
                if (!result.success) {
                    component.set("v.commodityGlobalMessage", result.message);
                    return;
                }

                let accountList = result.commodityAccountResult;
                console.log("accountList: " + JSON.stringify(accountList));
                console.log("accountList: " + result);

                component.set("v.accountCommodityObj", result.commodityAccountResult);
                console.log("v.accountCommodityObj " + JSON.stringify(component.get("v.accountCommodityObj")));
                //component.set("v.contractCommodityObj", result.commodityContractResult);
                //component.set("v.caseCommodityObj", result.commodityCaseResult);
                //component.set("v.invoiceCommodityObj", result.commodityInvoiceResult);
                component.set("v.serverSystem", result.serverSystem);
            }
        });
        $A.enqueueAction(action);
    },
    createSecondSection: function (component, event) {
        let action = component.get("c.callToCommoditySecondPart");
        action.setParams({
            'recordId': component.get("v.recordId")
        });
        action.setCallback(this, function (response) {

            let state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                let result = response.getReturnValue();
                if (!result.success) {
                    component.set("v.commodityGlobalMessage", result.message);
                    console.log('@@@@ fail');
                    return;
                }
                component.set("v.accountCommodityObj2", result.commodityAccountResult);
                component.set("v.contractCommodityObj", result.commodityContractResult);
                component.set("v.caseCommodityObj", result.commodityCaseResult);
                component.set("v.invoiceCommodityObj", result.commodityInvoiceResult);
                component.set("v.accountDocCountry", result.accountDocCountry);
                component.set("v.showCard", "false")
            }
            
        });
        $A.enqueueAction(action);
    }
}

)