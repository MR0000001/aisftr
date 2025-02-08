({
	init : function(component, event, helper) {
        component.set("v.spinnerControl", true);
		var action = component.get("c.initPaymentPage");
        action.setParams({
            "opportunityId": component.get("v.recordId")
        });
        
        action.setCallback(this, function (response) {
            var state = response.getState();
            var res = response.getReturnValue();
            if (state === "SUCCESS" && res) {

                var resultMap = JSON.parse(res);

                var valueMap = component.get("v.valueMap");

                valueMap['accountId'] = resultMap['accountId'];
                valueMap['contactId'] = resultMap['contactId'];
                valueMap['legalEntity'] = resultMap['legatEntity'];
                valueMap['docCountry'] = resultMap['XC_DocumentCountry__c'];
                valueMap['docdentityType'] = resultMap['IdentityType__c'];
                valueMap['docIdentityNumber'] = resultMap['IdentityNumber__c'];
                valueMap['showContactExtraFields'] = resultMap['showContactExtraFields'];
                component.set("v.contactExtraFields", resultMap['contactExtraFields']);
                valueMap['showDocumentExtraFields'] = resultMap['showDocumentExtraFields'];
                component.set("v.documentExtraFields", resultMap['documentExtraFields']);
                component.set("v.accountRecordId", resultMap['accountId']);
                component.set("v.recordTypeName", resultMap['recordTypeName']);
                component.set("v.getContractBy", resultMap['getContractBy']);
                
                var addressList = [];
                var contactList = [];
                var paymentList = [];
                var invoiceDeliveryPreferencesOpts = [];
                var doxeeOpt = [];
                var mandateOpts = [];
                var documentOpts = [];
                var paymentMethodCatOpts = [];

                if (resultMap.paymentMethodCatOpts) {
                    (resultMap.paymentMethodCatOpts).forEach(function (entry) {
                        paymentMethodCatOpts.push({
                            value: entry,
                            label: entry
                        });
                    })
                    component.set("v.paymentMethodCatOpts", paymentMethodCatOpts);
                }
                
                if (resultMap.addressRow) {
                    //(resultMap.addressRow).forEach(function (entry) {
                        addressList.push({
                            value: resultMap.addressRow['key'],
                            label: resultMap.addressRow['value']
                        });
                    //})
                    component.set("v.addressList", addressList);
                    valueMap['billingAddress'] = addressList[0].value;
                    valueMap['soldAddress'] = addressList[0].value;
                }
                
                if (resultMap.contactRow) {
                    //(resultMap.contactRow).forEach(function (entry) {
                        contactList.push({
                            value: resultMap.contactRow['key'],
                            label: resultMap.contactRow['value']
                        });
                    //})
                    component.set("v.contactList", contactList);
                }

                var credit = [];
                var external = [];
                var direct = [];
                var commodity = [];
                var bank = [];
                
                if (resultMap.mopData) {
                    (resultMap.mopData).forEach(function (entry) {
                        var key = entry['key'];
                        paymentList.push({
                            value: entry['key'],
                            label: entry['value']
                        });
                    })
                }

                if (resultMap['Credit Card']) {
                    (resultMap['Credit Card']).forEach(function (entry) {
                        credit.push({
                            value: entry['Id'],
                            label: entry['XC_BillingProfileName__c']
                        });
                    })
                }

                if (resultMap['External Financing']) {
                    (resultMap['External Financing']).forEach(function (entry) {
                        external.push({
                            value: entry['Id'],
                            label: entry['XC_BillingProfileName__c']
                        });
                    })
                }

                if (resultMap['Direct Debt']) {
                    (resultMap['Direct Debt']).forEach(function (entry) {
                        direct.push({
                            value: entry['Id'],
                            label: entry['XC_BillingProfileName__c']
                        });
                    })
                }

                if (resultMap['Commodity Bill']) {
                    (resultMap['Commodity Bill']).forEach(function (entry) {
                        commodity.push({
                            value: entry['Id'],
                            label: entry['XC_BillingProfileName__c']
                        });
                    })
                }

                if (resultMap['Bank Transfer']) {
                    (resultMap['Bank Transfer']).forEach(function (entry) {
                        bank.push({
                            value: entry['Id'],
                            label: entry['XC_BillingProfileName__c']
                        });
                    })
                }

                component.set("v.credit", credit);
                component.set("v.external", external);
                component.set("v.direct", direct);
                component.set("v.bank", bank);
                component.set("v.commodity", commodity);
                component.set("v.payment", paymentList);
                
                if (resultMap.invoiceDeliveryPreferencesPick) {
                    (resultMap.invoiceDeliveryPreferencesPick).forEach(function (entry) {
                        invoiceDeliveryPreferencesOpts.push({
                            value: entry['key'],
                            label: entry['value']
                        });
                    })
                    component.set("v.invoiceDeliveryPreferencesPick", invoiceDeliveryPreferencesOpts);
                }
                
                if (resultMap.doxeeLanguages) {
                    if (resultMap.isB2BLE &&  (resultMap.legalEntity == 'EnelX' || resultMap.legalEntity== 'Codensa' || resultMap.legalEntity== 'EnelDistribution')) {
                        (resultMap.doxeeLanguages).forEach(function (entry) {
                            console.log('valueMap.doxeeLanguages' + JSON.stringify(resultMap.doxeeLanguages));
                            if (entry['key'] == 'ESP') {
                                doxeeOpt.push({
                                    value: entry['key'],
                                    label: entry['value']
                                });
                            }
                        })
                    } else {
                        (resultMap.doxeeLanguages).forEach(function (entry) {
                            doxeeOpt.push({
                                value: entry['key'],
                                label: entry['value']
                            });
                        })
                    }
                    component.set("v.doxeeLanguages", doxeeOpt);
                }
                
                component.set("v.valueMap", valueMap);

                if (resultMap.sepaMandateValues) {
                    (resultMap.sepaMandateValues).forEach(function (pVal) {
                        mandateOpts.push({
                            value: pVal,
                            label: pVal
                        })
                    });
                    component.set("v.mandateOpts", mandateOpts);
                    if (resultMap.defaultMandateTypeVal) {
                    	component.set("v.mandateType", resultMap.defaultMandateTypeVal);
                    } else {
                        component.set("v.mandateType", mandateOpts[0].value);
                    }
                }

                if (resultMap.sohoDocument) {
                        component.set("v.sohoDocument", valueMap.sohoDocument);
                }
                var countryOpts = [];
                var taxExemptOpts = [];

			}
            component.set("v.spinnerControl", false);
		});
        $A.enqueueAction(action);
	},
    
    checkNumericFieldsLength: function (component) {
        if (component.find("cvv")) {
            var val = component.find("cvv").get('v.value');
            if (val && val.length > 3) {
                var compCVV = component.find("cvv");
                compCVV.set('v.value', val.substring(0, 3));
            }
        }
    },
    
    checkValue: function (component, event, helper) {

        //validate data and send data event to main component once all data are valid
        var createSectionValid = true;

        if(component.get("v.showCreateSection")) {
            if(component.get("v.showExtFinancing")) {
                if(!component.get("v.institutePickVal") || component.get("v.institutePickVal") == ""){
                    createSectionValid = false;
                }else if(component.get("v.institutePickVal") && component.get("v.showOtherExtFinancing") && (!component.get("v.otherInsituteVal") || component.get("v.otherInsituteVal")=="")){
                    createSectionValid = false;
                }
            }
            
            var doxeeSelectedLanguage = component.find("comboboxdoxee").get("v.value");
            if($A.util.isEmpty(doxeeSelectedLanguage)){
                createSectionValid = false;
            }
    
            var invoiceDeliveryPreferences = component.find("invoiceDeliveryPreferencesPick").get("v.value");
            if($A.util.isEmpty(invoiceDeliveryPreferences)){
                createSectionValid = false;
            }
    
            var paymentMethod = component.find('comboboxpayment').get("v.value");
            if(paymentMethod === 'Direct Debt') {
                var accountIban = component.find('accountIban');
                var mandateT = component.find('mandateT');
                if(accountIban.get("v.required") && $A.util.isEmpty(accountIban.get("v.value"))){
                    createSectionValid = false;
                }
                if(mandateT.get("v.required") && $A.util.isEmpty(mandateT.get("v.value"))){
                    createSectionValid = false;
                }            
            }

            if (paymentMethod === 'Commodity Bill') {
                if(component.get("v.getContractBy") === 'POS') {
                    var contractId = component.find("contractId") ? component.find("contractId").get("v.value") : '';
                    var cupsId = component.get("v.choosenContractCup"); //component.get("v.cupsList[0].value");
                }else {
                    var contractId = component.get("v.valueMap.contractId");
                    var cupsId = component.get("v.choosenContractCup");
                }
                console.log('@@@@@contractId' + contractId);
                console.log('@@@@@cupsId' + cupsId);
                if (contractId === '' || contractId == undefined || cupsId === '' || cupsId == undefined) {
                    createSectionValid = false;
                }
            }
        }
        
        var selectSectionValid = !$A.util.isEmpty(component.get("v.valueMap.billingProfileLineItem"));

        console.log('CHECK FIELD VALIDITY ' + createSectionValid + ' ' + selectSectionValid);

        if((createSectionValid && component.get("v.showCreateSection")) || selectSectionValid){
            console.log('Section is valid');
            component.set("v.disabledSubmit", false);
            //send parent component event with all data
            helper.sendValidEventData(component,event,helper);
        }else{
            console.log('Section is not valid');
            component.set("v.disabledSubmit", true);
            helper.invalidateSection(component,event,helper);
        }

    },
    
    getPaymentMethodCategory: function (component, event, helper) {

        /*Get dependent picklist values in order to identify external methods*/
        var currentChosenMop = component.find("comboboxpayment").get("v.value");
        var getDependencyAction = component.get('c.getPaymentCategoryDependency');
        console.log(getDependencyAction);
        getDependencyAction.setParams({
            paymentMethod: currentChosenMop
        });
        getDependencyAction.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.paymentMethodCategoryVal", result);
            } else {
                console.log(response.getError()[0].message);
            }
        });
        $A.enqueueAction(getDependencyAction);
    },
    
    retrieveCups: function (component, event, helper) {
        component.set("v.showSpinner", true);
        var selectedOptionValue = event.getParam("value");
        var continueRetrieve = false;
        if (component.find("docNumber")) {
            continueRetrieve = true;
        }
        if (continueRetrieve) {
            if (selectedOptionValue && selectedOptionValue != '') { //selectedOptionValue != 'undefined'
                var action = component.get("c.retrieveCups");
                action.setParams({
                    "addressId": selectedOptionValue,
                    "documentNumber": component.find("docNumber").get("v.value")

                });
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    var retValue = response.getReturnValue();

                    if (state === "SUCCESS" && retValue != null) {
                        var cupslist = retValue.cups;
                        var cupsLight = retValue.cupsLight;
                        var cupsGas = retValue.cupsGas;

                        //console.log('@@@ is B2B  ' + retValue.isB2B);
                        var opts = [];
                        var l = (cupslist) ? cupslist.length : 0;
                        if (l == 0 && component.get("v.valueMap.payment") === 'Commodity Bill') {
                            var toastEvent = $A.get("e.force:showToast");
                            var title = $A.get("$Label.c.XC_CL_ErrorsOccurred");
                            var message = $A.get("$Label.c.XC_CL_NoPODfound");
                            toastEvent.setParams({
                                "title": title,
                                "message": message,
                                "type": 'error'
                            });
                            toastEvent.fire();
                            component.set("v.showSpinner", false);
                            component.set("v.disabledSubmit", true);
                            return;
                        }
                        if(l>1){
                            for (var i = 0; i < cupsLight.length; i++) {
                                opts.push({
                                    value: cupsLight[i],
                                    label: 'Electric - '+cupsLight[i]
                                });
                            }
                            for (var i = 0; i < cupsGas.length; i++) {
                                opts.push({
                                    value: cupsGas[i],
                                    label: 'Gas - '+cupsGas[i]
                                });
                            }
                            component.set('v.selectedPOS', null);
                        }else if(l===1){
                            opts.push({
                                value: cupslist[0],
                                label: cupslist[0]
                            });
                            component.set('v.selectedPOS', cupslist[0]);
                            component.set('v.choosenContractCup', cupslist[0]);
                        }
                        component.set('v.showCUPS', true);
                        component.set('v.cupsList', opts);
                        component.set('v.isB2B', retValue.isB2B);
                        //console.log('CUPS LIST = ' + JSON.stringify(opts));
                        if ((retValue.contract == null || retValue.contract === '') && component.get("v.valueMap.payment") === 'Commodity Bill' && l<2) {
                            var toastEvent = $A.get("e.force:showToast");
                            var title = $A.get("$Label.c.XC_CL_ErrorsOccurred");
                            var message = $A.get("$Label.c.XC_CL_NoContractForDoc");
                            toastEvent.setParams({
                                "title": title,
                                "message": message,
                                "type": 'error'
                            });
                            toastEvent.fire();
                            component.set('v.contractValue', null);
                            component.set("v.valueMap.contractId", null);
                            component.set("v.showSpinner", false);
                            component.set("v.disabledSubmit", true);
                            return;
                        }
                        component.set('v.contractValue', retValue.contract);
                        if(retValue.contract!=''){
                            component.set("v.valueMap.contractId", retValue.contract);
                        }
                        //console.log('CONTRACT = ' + component.get('v.contractValue'));
                        if (l == 1) {
                            component.set('v.valueMap.cupsId', opts[0].label);
                        } else {
                            component.set('v.onlyOneCup', false);
                        }
                    }
                    component.set("v.showSpinner", false);
                });
                $A.enqueueAction(action);
            }
        } else {
            component.set("v.showSpinner", false);
        }
    },

    sendValidEventData : function(component,event,helper){

        var mapObj = component.get("v.valueMap");
        delete mapObj["countries"];
        delete mapObj["soldAddresses"];
        delete mapObj["billingContacts"];
        delete mapObj["billingAddresses"];
        delete mapObj["soldContacts"];
        mapObj['invoiceDeliveryPreferencesPick'] = component.get("v.invoiceDelValue");
        mapObj['paymentMethodCategory'] = component.get("v.paymentMethodCategoryVal");
        mapObj['lang'] = component.get("v.valueMap.doxeeLanguage");
        if(component.get("v.showCreateSection")){
            if(component.get("v.showDirectDebt")) {
                mapObj['accountIban'] = component.find('accountIban').get('v.value');  
                mapObj['bic'] = component.find('bic').get('v.value');
                mapObj['mandateT'] = component.find('mandateT').get('v.value');
            }
            
            if(component.get("v.showExtFinancing")) {
                mapObj['financialInstitute'] = component.find('finInstitute').get('v.value');
            }
            if(component.get("v.showOtherExtFinancing")) {
                mapObj['otherFinancialInstitute'] = component.find('otherFinInstitute').get('v.value');
            }
        }
        if (component.get("v.choosenContractCup")) {
            mapObj['cupsId'] = component.get("v.choosenContractCup");
        } else if (component.get("v.cupsList[0].value")) {
            mapObj['cupsId'] = component.get("v.cupsList[0].value");
        }

        if (component.find("contractId") != undefined) {
            mapObj['contractId'] = component.find("contractId").get("v.value");
        }else if(component.get("v.valueMap.contractId")){
            mapObj['contractId'] = component.get("v.valueMap.contractId");
        }

        if(component.get("v.choosenContractStatus")){
            mapObj['commodityContractStatus'] = component.get("v.choosenContractStatus");
        }

        if(component.get("v.choosenContractType")){
            mapObj['contractType'] = component.get("v.choosenContractType");
        }

        mapObj['contractBatch'] = component.get("v.contractBatch");
        mapObj['getContractBy'] = component.get("v.getContractBy");
        mapObj['commodityAccountId'] = component.get("v.commodityAccountId");
        mapObj['commodityBillingCycleFrequency'] = component.get("v.commodityBillingCycleFrequency");

        mapObj['opportunityId'] = component.get("v.recordId");

        var newMap = JSON.stringify(mapObj);
        console.log('new map is ' + newMap);

        var eventObj = {
            "validate" : true,
            "step" : 'BillingProfileManagement',
            "stepDataMap" : newMap,
            "accountId" : component.get("v.accountRecordId"),
            "paymentMethod" : component.get("v.valueMap.payment")
        }

        helper.fireAMPEvent(component,eventObj);
        
        /*
        var action = component.get("c.createOrSelectBillingProfile");
        console.log('newMap -->' + newMap);
        action.setParams({
            "accountId": component.get("v.accountRecordId"),
            "mapValues": newMap
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            var res = response.getReturnValue();
            console.log('state -->' + state);
            console.log('res -->' + res);
            if (state === "SUCCESS" && !$A.util.isEmpty(res)) {
                //var valueMap = JSON.parse(res);
                if(res.success) {

                }else {
                    var message = $A.get('$Label.c.XC_CL_LCP116_Errors_Occured_P1') + '\n';
                    message += res.resultMessage + '\n';
                    message += $A.get('$Label.c.XC_CL_LCP116_Errors_Occured_P2');
                    helper.showToast(component, event, helper, message, 'error');
                }
            }else {
                var message = $A.get('$Label.c.XC_CL_LCP116_Errors_Occured_P1') + '\n';
                message += $A.get('$Label.c.XC_CL_LCP116_Errors_Occured_P2');
                helper.showToast(component, event, helper, message, 'error');
            }
        });
        $A.enqueueAction(action);
        */
        
    },

    invalidateSection : function(component,event,helper){
        var eventObj = {
            "step" : 'BillingProfileManagement',
            "stepDataMap" : {},
            "validate" : false,
            "accountId" : component.get("v.accountRecordId")
        }
        helper.fireAMPEvent(component,eventObj);
    },

    getB2CCommodityContract : function(component,event,helper){
        component.set("v.showSpinner",true);
        var valueMap = component.get("v.valueMap");
        var docType = valueMap['docdentityType'];
        var docNum = valueMap['docIdentityNumber'];
        var docCountry = valueMap['docCountry'];
        var accountId = valueMap['accountId'];
        var paramsMap = {
            'documentType' : docType,
            'documentNumber' : docNum,
            'docCountry' : docCountry,
            'accountId' : accountId
        };

        var action = component.get("c.getCommodityContract");
        action.setParams({params : paramsMap});
        action.setCallback(this,function(response){
            if(response.getState()==="SUCCESS"){
                component.set("v.showSpinner",false);
                var result= response.getReturnValue();
                if(result.length>0){
                    var pickListOptions = [];
                    var contractMap = {};
                    for(var i=0;i<result.length;i++){
                        var label = result[i].pickValue;
                        var value = result[i].key;
                        pickListOptions.push({'label':label,'value':value});
                        contractMap[result[i].key]=result[i];
                    }
                    component.set("v.commodityContractMap",contractMap);
                    component.set("v.contractOpts",pickListOptions);
                    component.set("v.showCommodity",true);
                    component.set("v.showCUPS",true);

                }else{
                    var toastEvent = $A.get("e.force:showToast");
                    var title = $A.get("$Label.c.XC_CL_ErrorsOccurred");
                    var message = $A.get("$Label.c.XC_CL_LCP116_NOCommodityForNIF");
                    toastEvent.setParams({
                        "title": title,
                        "message": message,
                        "type": 'error'
                    });
                    toastEvent.fire();
                }
            }else{
                var msg = response.getError()[0].message;
                console.log('ERROR IN GET CONTRACT COMMODITY B2C::: ' + msg);
            }
            component.set("v.showSpinner",false);
        });
        $A.enqueueAction(action);
    },

    onChooseCommodityContract : function (component,event,helper){

        //retrieving contract info from map
        var chosenContractKey = event.getParam("value");
        var contractObj = component.get("v.commodityContractMap")[chosenContractKey];
        console.log('CHOSEN CONTRACT:: ' + JSON.stringify(contractObj));

        component.set("v.valueMap.contractId",contractObj.contractId);
        component.set("v.choosenContractCup",contractObj.cups);
        component.set("v.choosenContractType",contractObj.contractTypeCode);
        component.set("v.contractBatch",contractObj.billingBatch);
        component.set("v.choosenContractStatus",contractObj.contractStatus);
        component.set("v.commodityAccountId",contractObj.commodityAccountId);
        component.set("v.commodityBillingCycleFrequency",contractObj.commodityBillCyleFreqOrig);
        
        console.log('CHOSEN CONTRACT:: CUPS ' + component.get("v.choosenContractCup") + " ID " + component.get("v.valueMap.contractId"));
    },

    showToast: function (component, event, helper, message, type) {
        component.find('notifLib').showToast({
            "title": "Success!",
            "message": message,
            "variant": type
        });
        setTimeout(function () {
            $A.get("e.force:closeQuickAction").fire();
        }, 1200);
    },
})