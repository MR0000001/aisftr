({
    doInit: function (component, event, helper) {
        let commodityGlobalMessage = component.get("v.commodityGlobalMessage");
        if (commodityGlobalMessage) {
            //helper.showToast(component, commodityGlobalMessage, 'error');
            return;
        }
        let recordId = component.get("v.recordId");
        let sobjectType = component.get("v.sobjecttype");
        let caseCommodityObj = component.get("v.caseCommodityObj");
        let contractCommodityObj = component.get("v.contractCommodityObj");
        let invoiceCommodityObj = component.get("v.invoiceCommodityObj");
        let accountDocCountry = component.get("v.accountDocCountry");
		/*component.set('v.spinnerControl',true);
		let action = component.get("c.callCommodityNew");
		action.setParams({
			'recordId': recordId,
			'sobjectType': sobjectType
		});
		action.setCallback(this, function(response) {
			let state = response.getState();
			if (component.isValid() && state === "SUCCESS") {
                var responseResult = response.getReturnValue();*/

        let responseResult = component.get("v.accountCommodityObj");
        let sectionProgr = 1;

        if (responseResult && responseResult.success && responseResult.accountsResulWrappers) {
            for (let accIndex in responseResult.accountsResulWrappers) {

                    let labelAcc = "Account ";
                    console.log('lcc130  ' + JSON.stringify(responseResult.accountsResulWrappers[accIndex]));
                    let accountType = component.get("v.AccountType");
                    $A.createComponents([
                        ["c:XC_LCP005_AccountCallToCommodity", {
                            "recordId": recordId,
                            "sobjecttype": sobjectType,
                            "accIndex": accIndex,
                            "mainTitle": labelAcc,
                            "commodityAccData": responseResult.accountsResulWrappers[accIndex],
                            "caseCommodityObj": caseCommodityObj,
                            "contractCommodityObj": contractCommodityObj,
                            "invoiceCommodityObj": invoiceCommodityObj,
                            "accountDocCountry" : accountDocCountry,
                            "AccountType": accountType
                        }]
                    ],
                        function (components, status, errorMessage) {
                            let accountBox = components[0];
                            let div1 = component.get('v.body0');
                            div1.push(accountBox);
                            component.set('v.body0', div1);
                        });
                    if(sobjectType == "Account"){
                        let accountInfo = JSON.stringify(responseResult.accountsResulWrappers[accIndex]);
                        let action = component.get("c.saveConsents");
                        action.setParams({'recordId' : recordId, 'accountInfo' : accountInfo});
                        $A.enqueueAction(action);
                    }
                    sectionProgr = sectionProgr + 1;
                
            }
        } /*else { 
            helper.showToast(component, $A.get("$Label.c.XC_CL_NoAccountForDoc"), 'error');
        }*/

        /*}
        component.set('v.spinnerControl',false);
    });
    $A.enqueueAction(action);*/
    },


    saveSectionEvent: function (component, event, helper) {

        component.set('v.spinnerControl', true);
        let recordId = component.get("v.recordId");
        let sobjecttype = component.get("v.sobjecttype");
        let serverSystem = component.get("v.serverSystem");
        let action;
        if (event.getParam("objectType") == "Address" || event.getParam("objectType") == "Dirección") {
            let values = event.getParam("values");
            let subvalues = event.getParam("subvalues");
            action = component.get("c.importAddressFromCommodity");
            action.setParams({
                'inputDataToSave': { 'recordId': recordId, 'sobjecttype': sobjecttype },
                'addressValues': JSON.parse(values),
                'posValues': JSON.parse(subvalues)
            });
        } else {
            let values = event.getParam("values");
            action = component.get("c.importContactFromCommodity")
            action.setParams({
                'inputDataToSave': { 'recordId': recordId, 'sobjecttype': sobjecttype, 'serverSystem': serverSystem },
                'contactValues': JSON.parse(values)
            });

        }
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                let responseResult = response.getReturnValue();
                console.log('responseResult.resultMessage ' + responseResult.resultMessage);
                if (responseResult.success) {
                    helper.showToast(component, responseResult.resultMessage, 'success');
                } else {
                    helper.showToast(component, responseResult.resultMessage, 'error');
                }
            } else {
                helper.showToast(component, $A.get("$Label.c.XC_CL_ErrorsOccurred"), 'error');
            }
            component.set('v.spinnerControl', false);
        });
        $A.enqueueAction(action);
    },

    showToast: function (component, message, type) {
        //var typeValue = type | 'warning';
        console.log('@#@#@#@#@#@ AccountCallToCommodity message: ' + message);
        component.find('notifLib').showToast({
            "title": message,
            "message": '',
            "variant": type
        });
    }
})