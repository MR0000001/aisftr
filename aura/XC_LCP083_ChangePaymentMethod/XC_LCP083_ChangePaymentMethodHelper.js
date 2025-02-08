({
    init: function (component, event, helper) {



        let action = component.get("c.checkToChangePaymentMethod");
        console.log('@@' + action);
        action.setParams({
            "recordId": component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            let res = response.getReturnValue();
            if (state === "SUCCESS" && res.success) {
                let billProfInfo = JSON.parse(res.objectInfo);

                // if (billProfInfo['Zuora_Account_Id__c']) {
                //     component.set("v.zuoraAccountId", billProfInfo['Zuora_Account_Id__c']);
                // }
                if (billProfInfo['Country__c']) {
                    component.set("v.accountCountry", billProfInfo['Country__c']);
                }
                if (billProfInfo['AffectedBpli']) {
                    let bplis = billProfInfo['AffectedBpli']
                    component.set("v.bplis", bplis);
                }
                if (billProfInfo['AccountId']) {
                    component.set("v.accountForSIA", billProfInfo['AccountId']);
                }
                if (billProfInfo['ContactId']) {
                    component.set("v.primaryContactId", billProfInfo['ContactId']);
                }
                if (billProfInfo['currentMandate']) {
                    component.set("v.mandateType", billProfInfo['currentMandate']);
                }
                if (billProfInfo['SEPAMandates']) {
                    let mandateOpts = [];
                    let values = billProfInfo['SEPAMandates'];
                    for(let k in values){
                        mandateOpts.push({label : k  , value : values[k]});
                    }
                    component.set("v.mandateOpts", mandateOpts);
                }

                if (billProfInfo['NE__Payment__c']) {

                    component.set("v.payment", billProfInfo['NE__Payment__c']);

                    if(billProfInfo['NE__Payment__c']===$A.get("$Label.c.XC_CL_Commodity_Bill")){
                        component.set("v.electronicMethod",false);
                        component.set("v.currentMethod",$A.get("$Label.c.XC_CL_Commodity_Bill"));

                        if(billProfInfo['commodityContract'] && billProfInfo['commodityCUPS']){
                            component.set("v.contractId",billProfInfo['commodityContract']);
                            component.set("v.cupsId",billProfInfo['commodityCUPS']);
                        }
                    } if(billProfInfo['NE__Payment__c']===$A.get("$Label.c.XC_CL_DirectDebt")){
                        component.set("v.oldValue",billProfInfo['NE__Iban__c']);
                    }
                }

                helper.initPaymentValues(component, event);
                helper.initBplisTableColumns(component, event, helper);


            } else {

                if (response.getState() === "ERROR") {
                    console.log("ERROR ON INIT : " + response.getError()[0].message);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": response.getError()[0].message,
                        "type": "error"
                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire();

                } else {
                    helper.showMessage(component, event, helper, res.resultMessage, "error");
                    $A.get("e.force:closeQuickAction").fire();
                }
            }
        });
        $A.enqueueAction(action);
    },

    initPaymentValues: function (component, event) {

        let pickAction = component.get("c.getPaymentMethodsPicklist");
        pickAction.setCallback(this, function (response) {

            if (response.getState() === "SUCCESS") {

                let resultArray = response.getReturnValue();
                let currentMop = component.get("v.payment");

                let payment = []


                //COMMODITY BILL CAN BE SUBSTITUTED ONLY WITH DIRECT DEBT
                if(currentMop=='Commodity Bill'){
                    payment.push({
                        label: $A.get("$Label.c.XC_CL_DirectDebt"),
                        value: "Direct Debt"
                    });
                    payment.push({
                        label: $A.get("$Label.c.XC_CL_Commodity_Bill"),
                        value: "Commodity Bill"
                    });
                }else{
                    // for (let i = 0; i < resultArray.length; i++) {
                    //     payment.push({
                    //         label: resultArray[i],
                    //         value: resultArray[i]
                    //     });
                    // }
                    for(let k in resultArray){
                        payment.push({label : k , value : resultArray[k]});
                    }
                }
                component.set("v.paymentList", payment);

            } else {
                let msg = response.getError()[0].message;
                console.log("ERROR ON GET PICK VALUES::: " + msg);
            }

        });

        $A.enqueueAction(pickAction);
    },

    initCardTypeValues: function (component, event) {
        let cardType = [{
                label: $A.get('$Label.c.XC_CL_Visa'),
                value: 'Visa'
            },
            {
                label: $A.get('$Label.c.XC_CL_Master_Card'),
                value: 'MasterCard'
            },
            {
                label: $A.get('$Label.c.XC_XL_American_Express'),
                value: 'AmericanExpress'
            }
        ];

        component.set("v.cardType", cardType);
    },


    retrieveNewToken: function (component, event, helper) {

        let paymentMethodType = component.get("v.valueMap.payment");
        console.log('Payment type = ' + paymentMethodType);
        let billingProfId = component.get("v.recordId");
        let action = component.get("c.manageOperationBeforeCallSia");
        action.setParams({
            "contactId": component.get("v.primaryContactId"),
            "lang": '',
            "paymentMethod": paymentMethodType,
            "billingProfileId": billingProfId
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            let res = response.getReturnValue();
            if (state === "SUCCESS") {

                if (res.success) {

                    console.log("SIA DEBTOR CODE RESPONSE::: " + JSON.stringify(res));
                    let siaResponse = JSON.parse(res.objectInfo);
                    let debtorCode = siaResponse.debtorCode;
                    component.set("v.debtorCode", debtorCode);


                    if (paymentMethodType === "Direct Debt") {
                        helper.createPaymentMethodMultipleEntity(component, event, helper);
                    } else if (paymentMethodType === "Credit Card") {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "message": $A.get("$Label.c.XC_CL_CreditCardUpdateSuccess"),
                            "type": "success"
                        });
                        toastEvent.fire();
                        $A.get("e.force:closeQuickAction").fire();
                    }

                    // helper.updateCurrentBillingProfile(component, event, helper);

                    // if (paymentMethodType === 'Direct Debt') {
                    //     helper.createPaymentMethod(component, event, helper, valueMap, entityName);
                    // } else {
                    //     helper.showMessage(component, event, helper, 'Billing Profile correctly updated', 'success');
                    // }
                } else {
                    let message = $A.get("$Label.c.XC_CL_ErrorsOccurred") + ':\n';
                    message += $A.get("$Label.c.XC_CL_ResubmitRequest") + '\n';
                    helper.showMessage(component, event, helper, message, 'error');
                }
            } else {
                helper.showMessage(component, event, helper, '404: Server SIA not available', 'error');
            }

        });
        $A.enqueueAction(action);
    },


    updateCurrentBillingProfile: function (component, event, helper) {

        let paymentMethod = component.get("v.valueMap.payment");
        let bic = component.get("v.valueMap.bic");
        let accountNum = component.get("v.valueMap.accountNumber")
        let updateBpAction = component.get("c.updateCurrentBillingProfile");
        let mandateType = component.get("v.mandateType");
        let paramsInfo = {
            "bpId": component.get("v.recordId"),
            "mop": paymentMethod,
            "accountNumber": accountNum,
            "bic": bic,
            "mandateType" : mandateType
        }

        updateBpAction.setParams({
            paramsInfo: paramsInfo
        });
        updateBpAction.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {

                let res = response.getReturnValue();

                if (res.success) {
                    console.log("SUCCESSFUL UPDATE ON CURRENT BP");
                    if(res.mandateID && res.mandateDate){
                        component.set("v.newMandateID",res.mandateID);
                        component.set("v.newMandateDate",res.mandateDate);
                    }

                    helper.retrieveNewToken(component, event, helper);

                    // if (paymentMethod === "Direct Debt") {
                    //     helper.createPaymentMethodMultipleEntity(component, event, helper);
                    // } else if (paymentMethod === "Credit Card") {
                    //     var toastEvent = $A.get("e.force:showToast");
                    //     toastEvent.setParams({
                    //         "title": "Success!",
                    //         "message": $A.get("$Label.c.XC_CL_CreditCardUpdateSuccess"),
                    //         "type": "success"
                    //     });
                    //     toastEvent.fire();
                    //     $A.get("e.force:closeQuickAction").fire();
                    // }


                } else {
                    console.log('ERROR ON UPDATE CURRENT BP ' + res);
                }

            } else {
                let errorMsg = response.getError()[0].message;
                console.log('EXCEPTION ON UPDATE CURRENT BP ' + errorMsg);

                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": errorMsg,
                    "type": "error"
                });
                toastEvent.fire();
                component.set("v.showSpinner", false);

            }
        });
        $A.enqueueAction(updateBpAction);
    },

    createPaymentMethodMultipleEntity: function (component, event, helper) {

        let paymentMethodType = component.get("v.valueMap.payment");
        let billingProfId = component.get("v.recordId");
        console.log('@@' + paymentMethodType);
        let action;
        let paymentMethod = {};
        if (paymentMethodType === 'Direct Debt') {
            let accountNumber = component.find("accountNumber").get("v.value");
            paymentMethod = {
                "AccountId": "",
                "Type": "BankTransfer",
                "BankTransferType": "SEPA",
                "BankTransferAccountNumber": component.get("v.debtorCode"),
                "MandateID": component.get("v.newMandateID"),
                "MandateCreationDate": component.get("v.newMandateDate"),
                "IBAN": component.get("v.valueMap.accountNumber"),
                "AuthGateway" : "SIA PH SDD"
            }
        }
        let paymentMethodBody = JSON.stringify(paymentMethod);
        action = component.get("c.updatePaymentMethod");
        action.setParams({
            "paymentMethod": paymentMethodBody,
            "billingProfId": billingProfId
        });

        action.setCallback(this, function (response) {
            let state = response.getState();
            let serverRes = response.getReturnValue();
            if (state === "SUCCESS") {

                console.log('SUCCESS RESPONSE:::: ' + JSON.stringify(serverRes));

                for (let entity in serverRes) {
                    let updatePaymentResponse = JSON.parse(serverRes[entity]);
                    if (updatePaymentResponse.Success === "true") {
                        helper.linkPaymentMethodToAccount(component, event, helper, updatePaymentResponse.ZuoraAccountId, updatePaymentResponse.Id, entity,paymentMethodType);
                    } else {
                        let message = $A.get("$Label.c.XC_CL_ErrorsOccurred") + ':\n';
                        for (let index = 0; index < updatePaymentResponse.Errors.length; index++) {
                            message += updatePaymentResponse.Errors[index].Message + '\n';
                        }
                        message += $A.get("$Label.c.XC_CL_ResubmitRequest") + '\n';
                        helper.showMessage(component, event, helper, message, 'error');
                    }
                }

                // for (let i in serverRes) {
                //     let res = JSON.parse(serverRes[i]);
                //     if (res.Success === "true") {
                //         //helper.linkPaymentMethodToAccount(component, event, helper, res.ZuoraAccountId, res.Id, entityName);
                //     } else {
                //         let message = $A.get("$Label.c.XC_CL_ErrorsOccurred") + ':\n';
                //         for (let index = 0; index < res.Errors.length; index++) {
                //             message += res.Errors[index].Message + '\n';
                //         }
                //         message += $A.get("$Label.c.XC_CL_ResubmitRequest") + '\n';
                //         helper.showMessage(component, event, helper, message, 'error');
                //     }
                // }
            } else {
                let errorRes = response.getError()[0].message;
                console.log('ERROR ON UPDATE MOP ' + errorRes);
            }
        });
        $A.enqueueAction(action);
    },

    linkPaymentMethodToAccount: function (component, event, helper, zuoraAccountId, paymentMethodId, entityName,paymentMethodType) {
        let action = component.get("c.linkPaymentMethodToAccount");
        let gateWay = paymentMethodType == 'Direct Debt' ? "SIA PH SDD" : "";
        action.setParams({
            "zuoraAccountId": zuoraAccountId,
            "paymentMethodId": paymentMethodId,
            "entityName": entityName,
            "gateWay" : gateWay
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            let res = JSON.parse(response.getReturnValue());
            if (state === "SUCCESS") {
                if (res.Success === "true") {
                    component.set("v.showSpinner", false);
                    helper.showMessage(component, event, helper, $A.get("$Label.c.XC_CL_BillingAccountUpdated"), 'success');
                } else {
                    let message = $A.get("$Label.c.XC_CL_ErrorsOccurred") + ':\n';
                    if (res.Errors) {
                        for (let i = 0; i < res.Errors.length; i++) {
                            message += res.Errors[i].Message + '\n';
                        }
                    }
                    message += $A.get("$Label.c.XC_CL_ResubmitRequest") + '\n';
                    helper.showMessage(component, event, helper, message, 'error');
                }
                helper.createCase(component, event, helper);
            }
        });
        $A.enqueueAction(action);
    },

    createCase: function (component, event, helper) {

        let action = component.get("c.createChangePaymentMethodCase");
        action.setParams({
            "recordId": component.get("v.recordId"),
            "oldValue": component.get("v.oldValue")
        });
        action.setCallback(this, function (response) {
            let state = response.getState();

            if (state === 'SUCCESS') {
                $A.get('e.force:refreshView').fire();
                $A.get("e.force:closeQuickAction").fire();
            } else {
                let errorMsg = response.getError()[0].message;
                console.log("ERROR ON CREATE CASE ::: " + errorMsg);
            }
        });
        $A.enqueueAction(action);

    },

    checkValues: function (component, event, helper) {
        helper.checkNumericFieldsLength(component);

        let paymentMethodType = component.get("v.payment");
        component.set("v.valueMap.payment", paymentMethodType);

        if (paymentMethodType === 'Credit Card') {
            // component.set('v.showCreditCard', true);
            // component.set('v.showSEPA', false);

            // let cardNumber = component.find("cardNumber").get("v.value");
            // let month = component.find("month").get("v.value");
            // let year = component.find("year").get("v.value");
            // let cvv = component.find("cvv").get("v.value");
            // let cardholderName = component.find("cardholderName").get("v.value");
            // if(cardNumber === undefined || month === undefined || year === undefined || cvv === undefined || cardholderName === undefined ){
            //     component.set("v.disabledSubmit",true);
            // }else{
            component.set("v.disabledSubmit", false);
            // }

        } else if (paymentMethodType === 'Direct Debt') {
            component.set('v.showCreditCard', false);
            component.set('v.showSEPA', true);
            let accountnumber = component.find("accountNumber").get("v.value");
            if (accountnumber === undefined) {
                component.set("v.disabledSubmit", true);
            } else {
                component.set("v.disabledSubmit", false);
            }
        } else {
            component.set('v.showCreditCard', false);
            component.set('v.showSEPA', false);
        }
    },

    checkNumericFieldsLength: function (component) {
        if (component.find("cvv")) {
            let val = component.find("cvv").get('v.value');
            if (val && val.length > 3) {
                let compCVV = component.find("cvv");
                compCVV.set('v.value', val.substring(0, 3));
            }
        }
    },

    showMessage: function (component, event, helper, message, type) {
        component.set("v.showSpinner", false);
        component.find('notifLib').showToast({
            "title": message,
            "message": '',
            "variant": type
        });


        // setTimeout(function () {
        //     $A.get("e.force:closeQuickAction").fire();
        //     $A.get('e.force:refreshView').fire();
        // }, 1000);
    },


    initBplisTableColumns: function (component, event, helper) {

        component.set("v.bplisColumn", [{
                label: $A.get("$Label.c.XC_CL_ChangePaymentTable1"),
                fieldName: 'Name'
            },
            {
                label: $A.get("$Label.c.XC_CL_ChangePaymentTable2"),
                fieldName: 'XC_LegalEntity__c'
            },
            {
                label: $A.get("$Label.c.XC_CL_ChangePaymentTable3"),
                fieldName: 'XC_ZuoraId__c'
            },
            {
                label: $A.get("$Label.c.XC_CL_ChangePaymentTable4"),
                fieldName: 'XC_CustomerAccount__r.Name'
            }
        ]);


    },

})