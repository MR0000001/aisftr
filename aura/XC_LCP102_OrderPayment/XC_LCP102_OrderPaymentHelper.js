({
    doInit: function (component, event, helper) {
        console.log('inDoInit');
        //component.set("v.spinnerControl", true);
        component.set("v.spinnerControl", false);
        component.set("v.showSpinner", true);
        helper.getTableData(component, event, helper);
        helper.populateAddressPick(component, event, helper);
        helper.getDeliveryAddress(component, event, helper);
        helper.getLegendaText(component,event,helper);
        helper.checkCASurvey(component,event,helper);
        helper.isBillToPartner(component,event,helper);
        helper.checkBillingAccount(component,event,helper);


    },

    checkBillingAccount : function (component, event, helper){
        var action = component.get("c.checkBillingAccount");       
        action.setParams({
            'orderId': component.get("v.recordId")
        }); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            var res = response.getReturnValue();
            
            if(state=='SUCCESS'){               
                component.set("v.isBillingAccountFilter", res);               
            }
        });
        
        $A.enqueueAction(action);  
    },

    populateAddressPick: function (component, event, helper) {
        let recordId = component.get("v.recordId");
        let action = component.get("c.populateAddressPick");
        action.setParams({
            "recordId": recordId
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            let retValue = response.getReturnValue();

            if (state === "SUCCESS" && retValue) {

                let opts = [];
                if (retValue.BillingAddressPickList != null) {
                    (retValue.BillingAddressPickList).forEach(function (entry) {
                        opts.push({
                            value: entry['key'],
                            label: entry['value']
                        });
                    })
                    component.set('v.categoryOptions', opts);
                    if (!$A.util.isEmpty(retValue.BillingAddress)) {
                        let selectedOptionValue = (retValue.BillingAddress).key;
                        component.set('v.billValue', selectedOptionValue);
                        component.set("v.addressId", selectedOptionValue);
                        component.set("v.addressOK", true);
                        component.set("v.disablePayment", false);
                    }
                }
            }

        });
        $A.enqueueAction(action);

    },

    getTableData: function (component, event, helper) {

        helper.getConfItemsList(component, event, helper);

    },


    getConfItemsList: function (component, event, helper) {
        let recordId = component.get("v.recordId");

        let action = component.get("c.getListConfItem");
        action.setParams({
            "recordId": recordId
        });
        action.setCallback(this, function (response) {

            let res = JSON.parse(response.getReturnValue());
            console.log('getListAddress res=' + res);

            if (!res.success && res.errorMessage) {

                component.set("v.showSpinner", false);
                component.find('notifLib').showToast({
                    "title": 'Error',
                    "message": res.errorMessage,
                    "variant": 'error'
                });
                $A.get("e.force:closeQuickAction").fire();

            }

            if (res.mapIdOrderItem === null || $A.util.isEmpty(res.mapIdOrderItem)) {

                helper.showToast(component, event, helper, $A.get("$Label.c.XC_CL_NoConfItem"), 'success');
                $A.get("e.force:closeQuickAction").fire();

            } else {
                let mappa = res.mapIdOrderItem;
                console.log('MAPPA = ' + JSON.stringify(mappa));
                let orderItemId = [];
                orderItemId = Object.keys(mappa);
                component.set("v.orderItemId", orderItemId);
                console.log('ID ORDER ITEMS = ' + JSON.stringify(orderItemId));

                // let filteredMops = res.filteredMopList;
                // //setting up filtered mops for child components
                // let paymentOpts = [];
                // for(let k in filteredMops){
                //     paymentOpts.push({"label":k,"value":filteredMops[k]});
                // }
                // component.set('v.paymentOptions',paymentOpts);
                // console.log('FILTERED MOP LIST::: ' + JSON.stringify(paymentOpts));

                component.set("v.accountId", res.accountId);
                component.set("v.paymentMapFiltered",res.mapIdPaymentMethod);

                let map = {};
                let mapOrderItemPayment = {};
                for (let i = 0; i < orderItemId.length; i++) {
                    let orderItem = mappa[orderItemId[i]];
                    // let opts = [];
                    // let paymentList = res.mapIdPaymentMethod[orderItemId[i]];
                    // for (let j = 0; j < paymentList.length; j++) {
                    //     opts.push({
                    //         value: paymentList[j],
                    //         label: paymentList[j]
                    //     });
                    // }
                    // //component.set('v.categoryOptions', opts);
                    // component.set('v.paymentOptions', opts);
                    // console.log('PaymentOptions:: ' + opts);
                    console.log('order item ' + i + ' = ' + JSON.stringify(orderItem));



                    if (orderItem.XC_BillingProfileLineItem__c !== null) {
                        map[orderItem.Id] = orderItem.XC_BillingProfileLineItem__c;
                        // [ BEGIN, mridul.b.jain@accenture.com, 06/01/2022, ID-1 Select Payment Method, NR2073, ENEL X - r12 ] 
                        if(orderItem.XC_BillingProfileLineItem__c != undefined){
						    component.set("v.paymentTermFilter",orderItem.XC_BillingProfileLineItem__r.XC_PaymentTerm__c);
                        }
                        // [ END, mridul.b.jain@accenture.com, 06/01/2022, ID-1 Select Payment Method, NR2073, ENEL X - r12 ]
                    } else {
                        map[orderItem.Id] = '';
                    }
                    if (orderItem.XC_PaymentMethod__c !== null) {
                        mapOrderItemPayment[orderItem.Id] = orderItem.XC_PaymentMethod__c;

                    } else {
                        mapOrderItemPayment[orderItem.Id] = '';
                    }



                }

                component.set("v.contactId", res.contactId);
                component.set("v.legalEntityId", res.legalEntityId);
                component.set("v.legalEnt", res.legalEntityName);
                component.set("v.orderItemPayment", mapOrderItemPayment);
                component.set("v.appoggio", mapOrderItemPayment);
                component.set("v.testvalue", map);
                console.log('MAPPA confItem-billing  POPOLATA = ' + JSON.stringify(component.get("v.testvalue")));
                console.log('MAPPA confItem-payment  POPOLATA = ' + JSON.stringify(component.get("v.orderItemPayment")));
                component.set("v.start", true);
            }
            component.set("v.showSpinner", false);
        });

        $A.enqueueAction(action);
    },

    getColumn: function (component, event, helper) {
        let columns = [{
                label: $A.get("$Label.c.XC_CL_Name"),
                fieldName: 'Name',
                type: 'text'
            },
            {
                label: $A.get("$Label.c.XC_CL_Type"),
                fieldName: 'NE__Payment__c',
                type: 'text'
            },
            {
                label: $A.get("$Label.c.XC_CL_CreationDate"),
                fieldName: 'CreatedDate',
                type: 'date-local'
            }

        ];

        component.set("v.columns", columns);
    },

    closeQuickAndErrorMessage: function (component, event, message) {
        $A.get("e.force:closeQuickAction").fire();
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: $A.get("$Label.c.XC_CL_Warning"),
            message: message,
            key: 'info_alt',
            type: 'error',
            mode: 'dismissible',
            mode: 'pester'
        });
        toastEvent.fire();
    },



    updateConfItem: function (component, event, helper) {
        let action = component.get("c.updateConfItem");
        let recordId = component.get("v.recordId");

        action.setParams({
            'confBillingMap': component.get("v.totalMap"),
            'orderId': recordId,
            'billingAddressId': component.get("v.billValue")
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            let retValue = response.getReturnValue();
            if (state === "SUCCESS" && retValue !== null) {
                if (retValue.success) {

                    helper.showToast(component, event, helper, retValue.resultMessage, 'success');
                    $A.get("e.force:closeQuickAction").fire();

                } else {
                    component.set("v.showSpinner", false);
                    component.set("v.documentChoise", retValue.resultMessage);
                    if (retValue.typeMessage === 'noDocument') {
                        component.set("v.showInsertDocument", true);
                    } else {
                        helper.showToast(component, event, helper, retValue.resultMessage, 'error');
                    }

                }
            }
        });
        $A.enqueueAction(action);


    },

    populateBillingTable: function (component, event, helper) {
        helper.getColumn(component, event, helper);
        helper.getListBillingProfile(component, event, helper);


    },

    createPersonalDoc: function (component, event, helper) {

        let action = component.get("c.newPersonalDocument");
        let accountId = component.get("v.accountId");
        let country = component.get("v.docCountry");
        let docType = component.get("v.docType");
        let docNumber = component.get("v.docNumber");
        let docInfo = {
            docCountry: country,
            docType: docType,
            docNumber: docNumber
        };
        let docInfoJSON = JSON.stringify(docInfo);
        action.setParams({
            'orderId': component.get("v.recordId"),
            'personalDocValues': docInfoJSON
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            let retValue = response.getReturnValue();

            if (state === "SUCCESS" && retValue.success) {

                component.set("v.showInsertDocument", false);
                helper.showToast(component, event, helper, $A.get("$Label.c.XC_CL_DocumentCreationOK"), 'success');

            } else {
                helper.showToast(component, event, helper, 'Warning: ' + retValue.resultMessage, 'error');
            }

        });

        $A.enqueueAction(action);



    },

    getListBillingProfile: function (component, event, helper) {

        let action = component.get("c.retrieveBillingProfile");
        let recordId = component.get("v.recordId");

        action.setParams({
            'recordId': recordId
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            let retValue = response.getReturnValue();

            let modaltarget = component.find('ExtModal');
            let backdroptarget = component.find('Modalbackdrop');

            $A.util.addClass(modaltarget, 'slds-fade-in-open');
            $A.util.addClass(backdroptarget, 'slds-backdrop--open');


            component.set("v.showTable", true);
            if (state === "SUCCESS" && !$A.util.isEmpty(retValue)) {
                component.set("v.data", retValue);

            } else {
                helper.showToast(component, event, helper, $A.get('$Label.c.XC_CL_LCP102_NoBPFound') , 'error');
            }
        });
        $A.enqueueAction(action);
    },

    showToast: function (component, event, helper, message, type) {
        component.set("v.showSpinner", false);
        component.find('notifLib').showToast({
            "title": message,
            "message": '',
            "variant": type
        });
    },

    retrieveDisplayDensity: function (component, event, helper) {

        let action = component.get("c.retrieveDisplayDensity");
        action.setCallback(this, function (response) {
            let state = response.getState();
            let retValue = response.getReturnValue();
            console.log('DisplayDensity @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ = ' + JSON.stringify(retValue));
            if (state === "SUCCESS") {
                if (retValue.density === 'ViewOne') {
                    component.set("v.isComfy", true);
                } else {
                    component.set("v.isComfy", false);
                }


            }
        });
        $A.enqueueAction(action);
    },

    showNotice: function (component, event, helper, header, message) {
        component.find('notifLib').showNotice({
            "variant": "error",
            "header": header,
            "message": message

        });
    },

    getDeliveryAddress: function (component, event, helper) {

        let delAddrAction = component.get('c.getSoldToAddress');
        delAddrAction.setParams({
            recordId: component.get('v.recordId')
        });
        delAddrAction.setCallback(this, function (response) {

            if (response.getState() === "SUCCESS") {

                let result = JSON.parse(response.getReturnValue());
                component.set("v.shippingAddress", result);

            } else {
                let msg = response.getError()[0].message;
                console.log('ERROR ON RETRIEVING SHIPPING ADDRESS FROM ORDER ' + msg);
            }


        });
        $A.enqueueAction(delAddrAction);
    },

    getLegendaText: function(component,event,helper){
        let action = component.get("c.getSearchLegendaText");
        action.setParams({"recordId":component.get("v.recordId")});
        action.setCallback(this,function(response){
            if(response.getState()==="SUCCESS"){
                let result = response.getReturnValue();
                component.set("v.legendaText",result);
            }else{
                console.log("ERROR ON GETTING LEGENDA " + response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    },


    checkCASurvey : function(component,event,helper){
        let action = component.get("c.checkIfCASurveyHasToBeExecuted");
        action.setParams({"recordId" : component.get("v.recordId")});
        action.setCallback(this,function(response){
            if(response.getState()==="SUCCESS"){
                let result = response.getReturnValue();
                if(result.surveyToBeDone){
                    let message = result.message;
                    component.find('notifLib').showToast({
                        "title": 'Warning',
                        "message": message,
                        "variant": 'warning',
                        "mode" : 'sticky'
                    });
                }
            }else{
                console.log("ERROR ON GETTING SURVEY EXECUTION " + response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    },

    isBillToPartner:  function(component,event,helper){
        let action = component.get("c.isBillToPartner");
        action.setParams({"recordId" : component.get("v.recordId")});
        action.setCallback(this,function(response){
            let result = response.getReturnValue();
            if(result.isBillToPartner){
                component.set("v.isBillToPartner", result.isBillToPartner);
            }
            // [ BEGIN, mridul.b.jain@accenture.com, 06/01/2022, ID-1 Select Payment Method, NR2073, ENEL X - r12 ] 
            if(result.stream == 'B2B' || result.stream == 'B2G'){
                component.set("v.isB2B", true);
            }
            if(result.country == 'Italy'){
                component.set("v.isItaly",true);
            }
            // [ END, mridul.b.jain@accenture.com, 06/01/2022, ID-1 Select Payment Method, NR2073, ENEL X - r12 ] 
        });
        $A.enqueueAction(action);
    }

})