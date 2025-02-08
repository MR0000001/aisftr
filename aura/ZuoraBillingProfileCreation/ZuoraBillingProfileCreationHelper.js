({

    init: function (component, event, helper) {

        helper.initCardTypeValues(component, event);

        component.set("v.valueCheck", "Email");
        var action = component.get("c.initPaymentPage");

        action.setParams({
            "accountId": component.get("v.recordId"),
            "objectName": component.get("v.sobjecttype")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            var res = response.getReturnValue();
            if (state === "SUCCESS" && res) {

                var valueMap = JSON.parse(res);

                component.set("v.valueMap", valueMap);
                var countryOpts = [];
                var contactOpts1 = [];
                var contactOpts2 = [];
                var addressOpts1 = [];
                var addressOpts2 = [];
                var doxeeOpt = [];
                var documentOpts = [];
                var mandateOpts = [];
                var taxExemptOpts = [];
                var invoiceDeliveryPreferencesOpts = [];
                if (component.get("v.valueMap.isB2BG") == "B2G" && component.find("recCode") ) {
                     component.find("recCode").set("v.value","000000");
                     component.find("pec").set("v.value",component.get("v.valueMap.pec"));
                }else if(component.get("v.valueMap.isB2BG") == "B2B" && component.find("recCode") ) {
                     component.find("recCode").set("v.value","0000000");
                     component.find("pec").set("v.value",component.get("v.valueMap.pec"));

                 }



                if (valueMap.invoiceDeliveryPreferencesPick) {
                    (valueMap.invoiceDeliveryPreferencesPick).forEach(function (entry) {
                        invoiceDeliveryPreferencesOpts.push({
                            value: entry['key'],
                            label: entry['value']
                        });
                    })
                    component.set("v.invoiceDeliveryPreferencesPick", invoiceDeliveryPreferencesOpts);
                }




                if (valueMap.taxExemptOpts) {
                    (valueMap.taxExemptOpts).forEach(function (entry) {
                        taxExemptOpts.push({
                            value: entry['key'],
                            label: entry['value']
                        });
                    })
                    
                    component.set("v.taxExemptOpts", taxExemptOpts);
                }
                if (valueMap.countries) {
                    (valueMap.countries).forEach(function (entry) {
                        countryOpts.push({
                            value: entry['key'],
                            label: entry['value']
                        });
                    })
                    component.set("v.country", countryOpts);
                }
                if (valueMap.billingContacts) {
                    (valueMap.billingContacts).forEach(function (entry) {
                        contactOpts1.push({
                            value: entry['key'],
                            label: entry['value']
                        });
                    })
                    component.set("v.contact1", contactOpts1);
                }

                if (valueMap.soldContacts) {
                    (valueMap.soldContacts).forEach(function (entry) {
                        contactOpts2.push({
                            value: entry['key'],
                            label: entry['value']
                        });
                    })
                    component.set("v.contact2", contactOpts2);
                }
                if (valueMap.billingAddresses) {
                    (valueMap.billingAddresses).forEach(function (entry) {
                        addressOpts1.push({
                            value: entry['key'],
                            label: entry['value']
                        });
                    })
                    component.set("v.address1", addressOpts1);
                }
                if (valueMap.soldAddresses) {
                    (valueMap.soldAddresses).forEach(function (entry) {
                        addressOpts2.push({
                            value: entry['key'],
                            label: entry['value']
                        });
                    })
                    component.set("v.address2", addressOpts2);
                }

                if (valueMap.doxeeLanguages) {
                    if (valueMap.isB2BLE &&  (valueMap.legalEntity == 'EnelX' || valueMap.legalEntity== 'Codensa' || valueMap.legalEntity== 'EnelDistribution')) {
                        (valueMap.doxeeLanguages).forEach(function (entry) {
                            console.log('valueMap.doxeeLanguages' + JSON.stringify(valueMap.doxeeLanguages));
                            if (entry['key'] == 'ESP') {
                                doxeeOpt.push({
                                    value: entry['key'],
                                    label: entry['value']
                                });
                            }
                        })
                    } else {
                        (valueMap.doxeeLanguages).forEach(function (entry) {
                            doxeeOpt.push({
                                value: entry['key'],
                                label: entry['value']
                            });
                        })
                    }
                    component.set("v.doxeeLanguages", doxeeOpt);
                }

                if (valueMap.legalEntity) {
                    component.set("v.legalEnt", valueMap.legalEntity);
                    component.set("v.valueMap.legal", valueMap.legalEntity);
                }
				
                if( (valueMap.stream == "B2B" || valueMap.stream == "B2G") &&  component.get("v.valueMap.legal") == "EndesaX" ){
                    component.set("v.valueMap.taxExempt", taxExemptOpts[0].value);
                }
				
                if (valueMap.paymentType) {
                    component.set("v.paymentType", valueMap.paymentType)
                }
                if (valueMap.payment) {
                    component.set("v.payment", valueMap.payment)
                }
                if (valueMap.paymentMethodCategory) {
                    component.set("v.paymentMethodCategoryVal", valueMap.paymentMethodCategory)
                }
                if (valueMap.sepaMandate) {
                    component.set("v.sepaMandate", valueMap.sepaMandate)
                }
                if (valueMap.mandateDate) {
                    component.set("v.mandateDate", valueMap.mandateDate)
                }
                if (valueMap.debtorCode) {
                    component.set("v.debtorCode", valueMap.debtorCode)
                }
                if (valueMap.creditCardLastFourNumber) {
                    component.set("v.creditCardLastFourNumber", valueMap.creditCardLastFourNumber)
                }
                if (valueMap.expirationMonth) {
                    component.set("v.expirationMonth", valueMap.expirationMonth)
                }
                if (valueMap.expirationYear) {
                    component.set("v.expirationYear", valueMap.expirationYear)
                }
                if (valueMap.payPalUsername) {
                    component.set("v.payPalUsername", valueMap.payPalUsername)
                }
                if (valueMap.creditCardType) {
                    component.set("v.creditCardType", valueMap.creditCardType)
                }
                if (valueMap.iban) {
                    component.set("v.iban", valueMap.iban)
                }
                if (valueMap.docCountry) {
                    component.set("v.docCountry", valueMap.docCountry)
                }
                if (valueMap.isB2BLE) {
                    component.set("v.isB2BLE", valueMap.isB2BLE);
                }
                if (valueMap.sepaMandateValues) {

                    (valueMap.sepaMandateValues).forEach(function (pVal) {
                        mandateOpts.push({
                            value: pVal,
                            label: pVal
                        })
                    });
                    component.set("v.mandateOpts", mandateOpts);
                    component.set("v.mandateType", mandateOpts[0]);

                }
                
                component.set("v.getContractBy", valueMap.getContractBy);
                component.set("v.recordTypeName", valueMap.recordTypeName);
                console.log('recordTypeName = ' + component.get("v.recordTypeName"));
                let accountrecordTypeName = component.get("v.recordTypeName");
                if (component.get("v.recordTypeName") == 'XC_GLO_Account_Residential') {
                    component.set("v.showDocumentCombo", true);
                    if (valueMap.listPersonalDocument) {
                        (valueMap.listPersonalDocument).forEach(function (entry) {
                            documentOpts.push({
                                value: entry['key'],
                                label: entry['value']
                            });
                        })
                        component.set("v.documentList", documentOpts);


                    }

                } else if (component.get("v.recordTypeName") == 'XC_GLO_Account_Soho' || component.get("v.recordTypeName") == 'XC_GLO_B2B' || component.get("v.recordTypeName") == 'XC_GLO_B2G') {
                    if (valueMap.sohoDocument) {
                        component.set("v.sohoDocument", valueMap.sohoDocument);
                    }
                    if(component.get("v.recordTypeName") == 'XC_GLO_B2B' || component.get("v.recordTypeName") == 'XC_GLO_B2G' && component.get("v.docCountry") != 'Chile' && component.get("v.docCountry") != 'Colombia'){
                        component.set("v.showMultipicklistLE", true);
                    }
                }


                if (component.get("v.closeStrikeModal")) {
                    component.set("v.valueMap.soldContact", component.get("v.contactId"));
                    component.set("v.valueMap.billingAddress", component.get("v.addressId"));
                    component.set("v.valueMap.legal", component.get("v.legalEnt"));
                    component.set("v.showContact", true);
                }

                helper.initPaymentValues(component, event);


            } else {

                let errorMsg = response.getError()[0].message;
                console.log('ERROR ON INIT : ' + errorMsg);

            }
        });


        $A.enqueueAction(action);


    },

    updateAccount: function (component, event, helper, mapValues) {


        var action = component.get("c.updateSalesforceAccount");
        action.setParams({
            "accountId": component.get("v.recordId"),
            "mapValuesJSON": mapValues
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            var res = JSON.parse(response.getReturnValue());
            if (state === "SUCCESS") {

            }


        });
        $A.enqueueAction(action);
    },
    initPaymentValues: function (component, event) {

        //f.imp-->changed to retrieve values dynamically
        let pickAction = component.get('c.getPaymentMethodsPicklist');
        let LE = component.get("v.valueMap.legal");
        let stream = component.get("v.valueMap.stream");
        console.log('SEARCHING MOPS FOR LE: ' + LE);
        console.log('SEARCHING MOPS FOR STREAM: ' + stream);

        pickAction.setParams({
            legalEntity: LE,
            stream: stream
        });

        pickAction.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {

                let resultArray = response.getReturnValue();
                let payment = []
                for (var key of Object.keys(resultArray)) {
                    payment.push({

                        label: key,
                        value: resultArray[key]

                    });
                    console.log('payment LE: ' + resultArray[key]);
                }

                //init payment category pick
                let paymentCatAction = component.get('c.getPaymentMethodCategoryPickList');

                paymentCatAction.setCallback(this, function (response) {

                    if (response.getState() === "SUCCESS") {

                        let result = response.getReturnValue();
                        console.log('paymentMethodCatOpts result' + result);
                        let paymentCats = [];
                        for (let i = 0; i < result.length; i++) {
                            paymentCats.push({
                                label: result[i],
                                value: result[i]
                            });
                            console.log('paymentMethodCatOpts FOR ' + result[i]);
                        }
                        console.log('paymentMethodCatOpts' + paymentCats);
                        component.set("v.paymentMethodCatOpts", paymentCats);

                    } else {
                        console.log('ERROR: ' + response.getError()[0].message);
                    }

                });

                $A.enqueueAction(paymentCatAction);

                component.set("v.payment", payment);

            } else {
                let msg = response.getError()[0].message;
                console.log("ERROR ON GET PICK VALUES FOR PAYMENT::: " + msg);
            }
        });

        $A.enqueueAction(pickAction);
    },
    initCardTypeValues: function (component, event) {
        var cardType = [{
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
    retriveContactsForZuora: function (component, event, helper, paymentMethodId) {


        var mapObj = component.get("v.valueMap");
        delete mapObj["countries"];
        delete mapObj["soldAddresses"];
        delete mapObj["billingContacts"];
        delete mapObj["billingAddresses"];
        delete mapObj["soldContacts"];
        var newMap = JSON.stringify(mapObj);
        var action = component.get("c.retriveContactsForZuora");
        console.log('newMap -->' + newMap);
        action.setParams({
            "accountId": component.get("v.recordId"),
            "mapValues": newMap
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            var res = response.getReturnValue();
            console.log('state -->' + state);
            console.log('res -->' + res);
            if (state === "SUCCESS" && !$A.util.isEmpty(res)) {
                var valueMap = JSON.parse(res);
                // if(mapObj.payment ==='CreditCardSIA' || mapObj.payment ==='SEPA'){
                //   console.log('ENTRATO IN CREDIT CARD SIA');
                // helper.createSiaToken(component, event, helper, valueMap, paymentMethodId, mapObj);    
                //}else{
                helper.createZuoraAccount(component, event, helper, valueMap, paymentMethodId, mapObj, 'createZuoraCustomer', '');
                // }
            }
        });
        $A.enqueueAction(action);
    },




    createZuoraAccount: function (component, event, helper, valueMap, paymentMethodId, mapObj, siaPayment, interactionId) {
        var accountId = component.get("v.recordId");
        var paymentMethodType = component.get("v.valueMap.payment");
        var legalEntity = component.get("v.valueMap.legal");
        if (component.find("invoiceDeliveryPreferencesPick") != undefined) {
            var invoiceDel = component.find("invoiceDeliveryPreferencesPick").get("v.value");
        }
        if (component.find("cardNumber") != undefined) {
            var cardNumber = component.find("cardNumber").get("v.value");
        }
        if (component.find("month") != undefined) {
            var month = component.find("month").get("v.value");
        }
        if (component.find("year") != undefined) {
            var year = component.find("year").get("v.value");
        }
        var fromBillingProfile = false;
        var billingProfileId;

        if (component.get("v.sobjecttype") == 'NE__Billing_Profile__c') {
            billingProfileId = component.get("v.recordId");
            fromBillingProfile = true;
        }

        var billTo = JSON.stringify(valueMap.billTo);
        var soldTo = JSON.stringify(valueMap.soldTo);
        var billAddress = valueMap.billAddress;
        var soldAddress = valueMap.soldAddress;

        if (component.find("accountNumber") != undefined) {
            var accountNumber = component.find("accountNumber").get("v.value");
        }
        if (component.find("comboboxdoxee") != undefined) {
            var lang = component.find("comboboxdoxee").get("v.value");
        }
        if (component.find("bic") != undefined) {
            var bic = component.find("bic").get("v.value");
        }
        if (component.find("contractId") != undefined) {
            var contractId = component.find("contractId").get("v.value");
        }else if(component.get("v.valueMap.contractId")){
            var contractId = component.get("v.valueMap.contractId");
        }

        /*20220402 NicoloFodera correctly ingest CommodityBP [start]*/
	    if(component.get("v.commodityAccountId")){
            var commodityAccountId = component.get("v.commodityAccountId");
        }
		/*20220402 NicoloFodera correctly ingest CommodityBP [end]*/

        if(component.get("v.choosenContractCup")){
            var cupsId = component.get("v.choosenContractCup");
        }else if (component.get("v.cupsList[0].value")) {
            var cupsId = component.get("v.cupsList[0].value");
        }
        if (component.find("taxExemptId") != undefined) {
            var taxPick = component.find("taxExemptId").get("v.value");
        }
        if (component.find("mandateT") != undefined) {
            var mandateType = component.find("mandateT").get("v.value");
            if (mandateType == 'One Time') {
                mandateType = 'ONE_SHOT';
            } else {
                mandateType = 'RECURRENT';
            }
        }
        if (component.get("v.paymentTerm") && component.find("payTerm")) {
            var paymentTerm = component.find("payTerm").get("v.value");
        }
        /*let taxString = taxPick;
        if(taxPick == 'Tax-free'){
          taxString = '{"exemptStatus": "Yes", "exemptCertificateId":"7"}';
         }else{
          taxString = '{"exemptStatus": "No", "exemptCertificateId":""}';
         }*/

        let documentType = '';
        let documentNumber = '';


        if (component.get("v.valueMap.docNif")) {
            documentType = component.get("v.valueMap.docNif");
        }
        if (component.get("v.valueMap.docNumber")) {
            documentNumber = component.get("v.valueMap.docNumber");
        }
        var docCountryVal = null;
        if (component.find("docCountry") != undefined) {
            docCountryVal = component.find("docCountry").get("v.value");
        } else {
            docCountryVal = component.get("v.docCountry");
        }

        let pec = "";
        let recipientCode = "";

        //electronic invoice info
        if (component.find("pec")) {
            pec = component.find("pec").get("v.value");
        }

        if (component.find("recCode")) {
            recipientCode = component.find("recCode").get("v.value");
        }

        if(component.get("v.choosenContractType")){
            var contractType = component.get("v.choosenContractType");
        }

        if(component.get("v.choosenContractStatus")){
            var contractStatus = component.get("v.choosenContractStatus");
        }

        //external financing info
        if(component.get("v.institutePickVal")){
            var financialInstitute = component.get("v.institutePickVal");
        }

        if(component.get("v.otherInsituteVal")){
            var otherFinancialInstitute = component.get("v.otherInsituteVal");
        }

        let isB2BG = '';
        if (component.get("v.valueMap.isB2BG")) {
            isB2BG = component.get("v.valueMap.isB2BG");
        }

        var info = {
            accountId: accountId,
            paymentMethodType: paymentMethodType,
            cardNumber: cardNumber,
            month: month,
            year: year,
            accountNumber: accountNumber,
            bic: bic,
            contractId: contractId,            
			commodityAccountId: commodityAccountId, /*20220402 NicoloFodera correctly ingest CommodityBP*/
            cupsId: cupsId,
            legal: legalEntity,
            fromBillingProfile: fromBillingProfile,
            billingProfileId: billingProfileId,
            siaPayment: siaPayment,
            interactionId: interactionId,
            lang: lang,
            sepaMandateType: mandateType,
            invoiceDel: invoiceDel,
            taxInfo: taxPick,
            paymentTerm: paymentTerm,
            docNif: documentType,
            docNumber: documentNumber,
            pec : pec,
            recipientCode : recipientCode,
            contractType : contractType,
            commodityContractStatus : contractStatus,
            docCountry : docCountryVal,
            financialInstitute : financialInstitute,
            otherFinancialInstitute : otherFinancialInstitute,
            isB2BG : isB2BG
        };
        var infoJSON = JSON.stringify(info);
        console.log('INFOJSON ', infoJSON);
        var action = component.get("c.createBillingProfile");
        action.setParams({
            "billTo": soldTo,
            "soldTo": soldTo,
            "billAddress": billAddress,
            "soldAddress": soldAddress,
            "info": infoJSON
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            var res = response.getReturnValue();
            if (state === "SUCCESS") {

                if (res.success && res.objectInfo != null && res.objectInfo != '') {
                    var billingProfInfo = JSON.parse(res.objectInfo);
                    component.set("v.sepaMandate", billingProfInfo.XC_SepaMandate__c);
                    component.set("v.mandateDate", billingProfInfo.XC_SepaMandateDate__c);
                    component.set("v.createdBPLIId",res.recordId);

                    if (fromBillingProfile == false && (mapObj.payment === 'Credit Card' || mapObj.payment === 'Direct Debt')) {
                        console.log('CHIAMO createSiaToken con ' + mapObj.payment);
                        helper.createSiaToken(component, event, helper, valueMap, paymentMethodId, mapObj, res.fieldName2, mapObj.payment, res.fieldName, res.recordId);
                    } else {
                        console.log('CHIAMO createUnlinkedZuora con ' + mapObj.payment);
                        helper.createUnlinkedZuora(component, event, helper, valueMap, paymentMethodId, mapObj, res.recordId);
                    }

                } else if (res.success && siaPayment != 'createZuoraCustomer') {
                    helper.showMessage(component, event, helper, $A.get('{!$Label.c.XC_CL_BillingProfileCreated}'), 'success');
                } else {
                    if(res.typeMessage == 'BPLI error') {
                        component.set("v.showSpinner", false);
                        let toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "message": res.resultMessage,
                            "type": 'error'
                        });
                        toastEvent.fire();
                    } else {
                        helper.showMessage(component, event, helper, res.resultMessage, 'error');
                    }
                }
            }

        });
        $A.enqueueAction(action);
    },

    createUnlinkedZuora: function (component, event, helper, valueMap, paymentMethodId, mapObj, bpliId) {
        var accountId = component.get("v.recordId");
        var paymentMethodType = component.get("v.valueMap.payment");
        var legalE = component.get("v.valueMap.legal");
        var account = JSON.stringify(valueMap.account);
        var billTo = JSON.stringify(valueMap.billTo);
        var soldTo = JSON.stringify(valueMap.soldTo);
        //alert('entityName -->'+component.get("v.entityName"));
        var entityName = valueMap.entityName; //component.get("v.entityName"); //
        //alert('entityName -->'+entityName);
        console.log('NEW ENTITY NAME ' + entityName);
        console.log("createUnlinkedZuora HELPER");


        var selectedValues = component.find("invoiceDeliveryPreferencesPick").get("v.value");
        console.log('selectedValues ' + selectedValues);


        var paymentTerm = 'Due Upon Receipt';
        
        if (component.get("v.paymentTerm") && component.find("payTerm")) { //se B2B il payment term è selezionato manualmente
            
            let selectedTerm = component.get("v.paymentTerm");
            paymentTerm = selectedTerm;
            console.log('paymentTerm ' + paymentTerm);
            
        } else { // ST -->
            
            if(legalE=='EnelXItalia'){
                
                switch (paymentMethodType) {
                    case "Direct Debt": paymentTerm = 'Net 15';
                    case "Bank Transfer": paymentTerm = 'Net 30';
                    default: break;
                }
                
            } else if(legalE=='EnelXRomania'){
                
                switch (paymentMethodType) {
                    case "Commodity Bill": paymentTerm = 'Net 60';
                    case "Direct Debt": paymentTerm = 'Net 15';
                    case "Bank Transfer": paymentTerm = 'Net 5';
                    case "External Financing": paymentTerm = 'Net 5';
                    default: break;
                }
                
            } else {
                
                switch (paymentMethodType) {
                    case "Direct Debt": paymentTerm = 'Net 7';
                    default: break;
                }
                
            }
                      
        } // <-- ST

        var fromBillingProfile = false;
        if (component.get("v.sobjecttype") == 'NE__Billing_Profile__c') {
            fromBillingProfile = true;
        }
        var lang = component.get("v.valueMap.doxeeLanguage");
        var correctLanguage = helper.adjustLanguage(lang);
        var docNif = component.get("v.valueMap.docNif");
        var docNumber = component.get("v.valueMap.docNumber")==null?component.get("v.valueMap.commodityIdentityNumber"):component.get("v.valueMap.docNumber");   //gaurav.tejpal@accenture.com, 17/05/2022,Enel X - Get Contract
        var expedition = component.get("v.valueMap.expedition");
        var expiration = component.get("v.valueMap.expiration");
        var recordType = component.get("v.recordTypeName");
        var contractId = component.get("v.valueMap.contractId");
        var personTypeCode = 'J';
        if (recordType === 'XC_GLO_Account_Residential') {
            personTypeCode = 'F';
        }
        var options;

        if (paymentMethodType === 'Direct Debt') {

            options = {

                invoiceDeliveryPrefsEmail: (selectedValues.includes("Smart") || selectedValues.includes("smart")) ? true : selectedValues.includes("Email"),
                invoiceDeliveryPrefsPrint: (selectedValues.includes("Smart") || selectedValues.includes("smart")) ? false : selectedValues.includes("Print"),
                // invoiceDeliveryPrefsSMS :  selectedValues.includes("SMS"),
                paymentTerm: paymentTerm,
                // billCycleDay: 1,
                paymentGateway: "SIA PH SDD",
                XC_SplitPayment__c : component.get("v.valueMap.splitPayment")

            };
        } else if(paymentMethodType == 'Commodity Bill' && component.get("v.contractBatch")  && component.get("v.getContractBy") === 'IdentityDoc') { //
            
            if(component.get("v.commodityBillingCycleFrequency")){

                options = {

                    invoiceDeliveryPrefsEmail: (selectedValues.includes("Smart") || selectedValues.includes("smart")) ? true : selectedValues.includes("Email"),
                    invoiceDeliveryPrefsPrint: (selectedValues.includes("Smart") || selectedValues.includes("smart")) ? false : selectedValues.includes("Print"),
                    // invoiceDeliveryPrefsSMS :  selectedValues.includes("SMS"),
                    paymentTerm: paymentTerm,
                    // billCycleDay: 1,
                    batch : component.get("v.contractBatch"),
                    XC_SplitPayment__c : component.get("v.valueMap.splitPayment"),
                    XC_CommodityAccountId__c : component.get("v.commodityAccountId"),
                    XC_CommodityFrequency__c : component.get("v.commodityBillingCycleFrequency")
                };

            }else{

                    options = {
                        invoiceDeliveryPrefsEmail: (selectedValues.includes("Smart") || selectedValues.includes("smart")) ? true : selectedValues.includes("Email"),
                        invoiceDeliveryPrefsPrint: (selectedValues.includes("Smart") || selectedValues.includes("smart")) ? false : selectedValues.includes("Print"),
                        // invoiceDeliveryPrefsSMS :  selectedValues.includes("SMS"),
                        paymentTerm: paymentTerm,
                        // billCycleDay: 1,
                        batch : component.get("v.contractBatch"),
                        XC_SplitPayment__c : component.get("v.valueMap.splitPayment"),
                        XC_CommodityAccountId__c : component.get("v.commodityAccountId"),
                    };
            }




        }else if(paymentMethodType == 'Commodity Bill' && (component.get("v.recordTypeName") == 'XC_GLO_B2B' || component.get("v.recordTypeName") == 'XC_GLO_B2G') && component.get("v.getContractBy") === 'AccountDocAndPOD'){
            options = {

                invoiceDeliveryPrefsEmail: (selectedValues.includes("Smart") || selectedValues.includes("smart")) ? true : selectedValues.includes("Email"),
                invoiceDeliveryPrefsPrint: (selectedValues.includes("Smart") || selectedValues.includes("smart")) ? false : selectedValues.includes("Print"),
                paymentTerm: paymentTerm,
                XC_SplitPayment__c : component.get("v.valueMap.splitPayment"),
                XC_CommodityAccountId__c : component.get("v.commodityAccountId")
            };
        } else {
            options = {

                invoiceDeliveryPrefsEmail: (selectedValues.includes("Smart") || selectedValues.includes("smart")) ? true : selectedValues.includes("Email"),
                invoiceDeliveryPrefsPrint: (selectedValues.includes("Smart") || selectedValues.includes("smart")) ? false : selectedValues.includes("Print"),
                // invoiceDeliveryPrefsSMS :  selectedValues.includes("SMS"),
                paymentTerm: paymentTerm,
                // billCycleDay: 1,
                XC_SplitPayment__c : component.get("v.valueMap.splitPayment")


            };
        }

        if (component.find("taxExemptId") != undefined) {
            var taxPick = component.find("taxExemptId").get("v.value");
        }

        var docCountryVal = null;
        if (component.find("docCountry") != undefined) {
            docCountryVal = component.find("docCountry").get("v.value");
        } else {
            docCountryVal = component.get("v.docCountry");
        }

        var VatGroupSequenceSetId = (valueMap.VatGroupSequenceSetId) ? valueMap.VatGroupSequenceSetId : null;
        console.log('VAT GROUP TYPE SEQUENCE :' + VatGroupSequenceSetId);
        
        var ZuoraSequenceSetId = (valueMap.ZuoraSequenceSetId) ? valueMap.ZuoraSequenceSetId : null;
        console.log('ZUORA SEQUENCE :' + ZuoraSequenceSetId);
        
        var zuoraPayment = {
            bpId: accountId,
            language: correctLanguage,
            fromBillingProfile: fromBillingProfile,
            docNif: docNif,
            docNumber: docNumber,
            expedition: expedition,
            expiration: expiration,
            personTypeCode: personTypeCode,
            contractId: contractId,
            legalE: legalE,
            smartInvoice: selectedValues,
            docCountry: docCountryVal,
            taxInfo: taxPick,
            vatGroupSequenceSetId: VatGroupSequenceSetId,
            zuoraSequenceSetId: ZuoraSequenceSetId
        };


        var zuoraPaymentJSON = JSON.stringify(zuoraPayment);
        var optionsJSON = JSON.stringify(options);
        var action = component.get("c.createUnlinkedZuoraAccount");
        action.setParams({
            "account": account,
            "billingContact": billTo,
            "soldContact": soldTo,
            "entityName": entityName,
            "options": optionsJSON,
            "billingProfLineItemId": bpliId,
            "zuoraPayment": zuoraPaymentJSON,
            "doRollback": true
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            var res = JSON.parse(response.getReturnValue());
            if (state === "SUCCESS") {
                console.log("RESPOSNE createUnlinkedZuora" + JSON.stringify(res.integrationLog))
                let logs = [res.integrationLog];
                if (res.success == "true") {
                    var message = $A.get('{!$Label.c.XC_CL_BillingProfileCreated}');
                    var cmpEvent = $A.get("e.c:XC_LCE016_RefreshView");
                    message += 'accountId: ' + res.accountId + '\n';
                    message += 'accountNumber: ' + res.accountNumber + '\n';
                    
                    if (component.get("v.sobjecttype") == 'Account' && mapObj.payment != 'Credit Card') {
                        helper.createPaymentMethod(component, event, helper, mapObj, res.accountId, entityName, bpliId);
                    } else {
                        // helper.showMessage(component, event, helper, 'Billing Profile correctly created', 'success');
                        console.log("IN ELSE")
                        helper.createPaymentMethod(component, event, helper, mapObj, res.accountId, entityName, bpliId);
                    }
                    if (component.get("v.closeStrikeModal")) {

                        var cmpEvent = $A.get("e.c:XC_LCE003_CloseStrikeModal");
                        cmpEvent.setParams({
                            "closeStrikeModal": true
                        });
                        cmpEvent.fire();
                    }
                } else {

                    var message = $A.get('$Label.c.XC_CL_LCP116_Errors_Occured_P1') + '\n';

                    for (var i = 0; i < res.reasons.length; i++) {
                        message += res.reasons[i].message + '\n';
                    }
                    message += $A.get('$Label.c.XC_CL_LCP116_Errors_Occured_P2');
                    helper.showMessage(component, event, helper, message, 'error');
                }

                helper.saveIntegrationLog(component,event,helper,logs);

            }
        });
        $A.enqueueAction(action);
    },

    adjustLanguage: function (l) {
        if (l == 'CA') {
            return 'CAT'
        } else if (l == 'ESP') {
            return 'SPA'
        } else if (l == 'DE') {
            return 'DEU'
        } else {
            return l
        }

    },

    createPaymentMethod: function (component, event, helper, valueMap, zuoraAccountId, entityName, bpliId) {

        console.log('ENTRATO IN createPaymentMethod');

        var paymentMethodType = component.get("v.valueMap.payment");
        console.log('payment: ' + paymentMethodType);

        let paymentMethodCategory = component.get("v.paymentMethodCategoryVal");
        console.log('paymentMethodCategoryVal: ' + paymentMethodCategory);

        console.log('v.sobjecttype: ' + component.get("v.sobjecttype"));
        var fromBillingProfile = false;
        if (component.get("v.sobjecttype") == 'NE__Billing_Profile__c') {
            fromBillingProfile = true;
        }

        console.log('ENTRATO IN CreatePaymentMethod con ' + paymentMethodType + " CATEGORY OF MOP::: " + paymentMethodCategory);
        var action;
        //Se si tratta di un pagamento di tipo esterno
        if (paymentMethodCategory === "External") {
            action = component.get("c.linkAccountToExternalPaymentMethod");
            action.setParams({
                "accountId": zuoraAccountId,
                "externalPaymentMethodType": paymentMethodType,
                "entityName": entityName
            });
        } else {
            var paymentMethod = {};
            if (paymentMethodType === 'Direct Debt') {
                var accountNumber = null
                if(component.find("accountNumber") != undefined) {
                    accountNumber = component.find("accountNumber").get("v.value");
                } else {
                    accountNumber = component.get("v.iban");
                }
                paymentMethod = {
                    "AccountId": zuoraAccountId,
                    "Type": "BankTransfer",
                    "BankTransferType": "SEPA",
                    "BankTransferAccountNumber": component.get("v.debtorCode"),
                    "TokenId": component.get("v.debtorCode"),
                    "MandateID": component.get("v.sepaMandate"),
                    "MandateCreationDate": component.get("v.mandateDate"),
                    "IBAN": accountNumber,
                    "paymentGateway": "SIA PH SDD"
                }

            } else if (paymentMethodType === 'Credit Card' && component.get("v.creditCardType") === 'PayPal') {
                paymentMethod = {
                    "AccountId": zuoraAccountId,
                    "Type": "CreditCardReferenceTransaction",
                    "TokenId": component.get("v.debtorCode"),
                    "SecondTokenId": component.get("v.payPalUsername")
                }
            } else if(paymentMethodType === 'Credit Card') {
                paymentMethod = {
                    "AccountId": zuoraAccountId,
                    "Type": "CreditCardReferenceTransaction",
                    "TokenId": component.get("v.debtorCode"),
                    "CreditCardType": component.get("v.creditCardType"),
                    "CreditCardNumber": component.get("v.creditCardLastFourNumber"),
                    //"CreditCardHolderName": component.get("v.creditCardHolder"),
                    "CreditCardExpirationMonth": component.get("v.expirationMonth"),
                    "CreditCardExpirationYear": component.get("v.expirationYear"),
                }
            }

            var paymentMethodBody = JSON.stringify(paymentMethod);
            action = component.get("c.createPaymentMethod");
            action.setParams({
                "paymentMethod": paymentMethodBody,
                "entityName": entityName,
                "billingProfLineItemId": bpliId,
                "doRollback": true,
                "fromBillingProfile": fromBillingProfile
            });
        }

        action.setCallback(this, function (response) {
            var state = response.getState();
            var res = typeof(response.getReturnValue()) === 'object' ? response.getReturnValue() : JSON.parse(response.getReturnValue());
            if (state === "SUCCESS") {

                let logs = [];

                if (paymentMethodCategory === "External") {
                    res.integrationLog['XC_BillingProfileLineItem__c'] = component.get("v.createdBPLIId");
                    logs.push(res.integrationLog);

                    component.set("v.showSpinner", false);
                    helper.showMessage(component, event, helper, $A.get('{!$Label.c.XC_CL_BillingAccountCreated}'), 'success');
                    $A.get("e.force:closeQuickAction").fire();

                } else if (res.Success === "true") {
                    var paymentMethodId = res.Id;
                    console.log('USCITO DA CreatePaymentMethod CON PaymentId = ' + res.Id);

                    res.integrationLog['XC_BillingProfileLineItem__c'] = component.get("v.createdBPLIId");
                    logs.push(res.integrationLog);

                    helper.linkPaymentMethodToAccount(component, event, helper, zuoraAccountId, paymentMethodId, entityName);
                } else {
                    var message = $A.get('$Label.c.XC_CL_LCP116_Errors_Occured_P1') + '\n';
                    for (var i = 0; i < res.Errors.length; i++) {
                        message += res.Errors[i].Message + '\n';
                    }
                    res.integrationLog['XC_BillingProfileLineItem__c'] = component.get("v.createdBPLIId");
                    logs.push(res.integrationLog);

                    message += $A.get('$Label.c.XC_CL_LCP116_Errors_Occured_P2');
                    helper.showMessage(component, event, helper, message, 'error');

                }

                if(logs.length>0){
                    helper.saveIntegrationLog(component,event,helper,logs);
                }

            }
        });
        $A.enqueueAction(action);

    },
    linkPaymentMethodToAccount: function (component, event, helper, zuoraAccountId, paymentMethodId, entityName) {
        console.log('ENTRATO IN linkPaymentMethodToAccount');
        var action = component.get("c.linkPaymentMethodToAccount");
        action.setParams({
            "zuoraAccountId": zuoraAccountId,
            "paymentMethodId": paymentMethodId,
            "entityName": entityName
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            var res = JSON.parse(response.getReturnValue());
            if (state === "SUCCESS") {

                let logs = [];

                if (res.Success === "true") {

                    res.integrationLog['XC_BillingProfileLineItem__c'] = component.get("v.createdBPLIId");
                    logs.push(res.integrationLog);

                    component.set("v.showSpinner", false);
                    message += 'paymentMethodId: ' + paymentMethodId + '\n';
                    //alert(message);
                    helper.showMessage(component, event, helper, $A.get('{!$Label.c.XC_CL_BillingAccountCreated}'), 'success');
                    var fromOr = component.get("v.fromOrderComponent");
                    if (fromOr) {
                        var b = true;
                        var cmpEvent = $A.get("e.c:XC_LCE016_RefreshView");
                        cmpEvent.setParams({
                            "refreshView": b
                        });
                        cmpEvent.fire();
                    }
                    console.log('ESCO DA linkPaymentMethodToAccount CON SUCCESS = ' + res.Success);

                } else {

                    res.integrationLog['XC_BillingProfileLineItem__c'] = component.get("v.createdBPLIId");
                    logs.push(res.integrationLog);
                    
                    var message = $A.get('$Label.c.XC_CL_LCP116_Errors_Occured_P1') + '\n';
                    for (var i = 0; i < res.Errors.length; i++) {
                        message += res.Errors[i].Message + '\n';
                    }
                    message += $A.get('$Label.c.XC_CL_LCP116_Errors_Occured_P2');

                    helper.showMessage(component, event, helper, message, 'error');
                }

                if(logs.length>0) {
                    helper.saveIntegrationLog(component,event,helper,logs);
                }
            }

            $A.get("e.force:closeQuickAction").fire();

        });
        $A.enqueueAction(action);
    },

    checkPayment: function (component, event, helper) {

        var action = component.get("c.getSoldAddressofAccountPicklist");
        action.setParams({
            "accountId": component.get("v.recordId"),
            "isCommodity": true
        });
        action.setCallback(this, function (response) {
            var addressOpts2 = [];
            var state = response.getState();
            var res = response.getReturnValue();
            if (state === "SUCCESS") {
                res.forEach(function (entry) {
                    addressOpts2.push({
                        value: entry['key'],
                        label: entry['value']
                    });
                })
                component.set("v.address2", addressOpts2);
            }

            helper.checkValue(component, event, helper);

        });
        $A.enqueueAction(action);
    },


    checkValue: function (component, event, helper) {
        helper.checkNumericFieldsLength(component);
        if (component.find("comboboxpayment") != undefined) {
            helper.checkValueForAccount(component, event, helper);
        } else {
            helper.checkValueForBilling(component, event, helper);
        }
    },


    checkValueForAccount: function (component, event, helper) {

        //get dependent payment category value based on choosen mop
        helper.getPaymentMethodCategory(component, event, helper);

        var paymentMethodType = component.find("comboboxpayment").get("v.value");
        console.log('paymentMethodType' + paymentMethodType);
        var nif;
        var docNumber;
        var expiration;
        var expedition;
        var recordTypeName = component.get("v.recordTypeName");
        var recipientCode;
        var pec;

        if (recordTypeName == 'XC_GLO_Account_Residential' && component.find("selectDocument").get("v.value") == undefined) {
            component.set("v.disabledSubmit", true);
            return;
        }
        if (component.find("docNif")) {
            nif = component.find("docNif").get("v.value");
        }
        if (component.find("docNumber")) {
            docNumber = component.find("docNumber").get("v.value");
        }
        if (component.find("expiration")) {
            expiration = component.find("expiration").get("v.value");
        }
        if (component.find("expedition")) {
            expedition = component.find("expedition").get("v.value");
        }

        if (component.find("pec")&& !(component.get("v.valueMap.isB2BG") == "B2B" || component.get("v.valueMap.isB2BG") == "B2G")) {
            pec = component.find("pec").get("v.value");
            if (pec != undefined && pec != "" && component.find("recCode")) {
                component.set("v.requiredRecCode", false);
                component.set("v.disableRecCode", true);
                component.find("recCode").set("v.value", "");
                $A.util.addClass(component.find("recCode"), 'slds-hide');
            } else if (pec == "" && component.find("recCode").get("v.value") == "") {
                component.set("v.disableRecCode", false);
                component.set("v.requiredRecCode", true);
                $A.util.removeClass(component.find("recCode"), 'slds-hide');

            }
        }
        if (component.find("recCode") && !(component.get("v.valueMap.isB2BG") == "B2B" || component.get("v.valueMap.isB2BG") == "B2G")) {
            recipientCode = component.find("recCode").get("v.value");
            if (recipientCode != undefined && recipientCode != "" && component.find("pec")) {
                component.set("v.requiredPec", false);
                component.set("v.disablePec", true);
                component.find("pec").set("v.value", "");
                $A.util.addClass(component.find("pec"), 'slds-hide');
            } else if (recipientCode == "" && pec == "")  {
                component.set("v.disablePec", false);
                component.set("v.requiredPec", true);
                $A.util.removeClass(component.find("pec"), 'slds-hide');
            }
        }
        if (expedition != null && expedition != '') {
            component.set("v.valueMap.expedition", expedition);
        } else {
            component.set("v.valueMap.expedition", '');
        }
        if (expiration != null && expiration != '') {
            component.set("v.valueMap.expiration", expiration);
        } else {
            component.set("v.valueMap.expiration", '');
        }
        if (nif != null && nif != '') {
            component.set("v.valueMap.docNif", nif);
        } else {
            component.set("v.valueMap.docNif", '');
        }
        if (docNumber != null && docNumber != '') {
            component.set("v.valueMap.docNumber", docNumber);
        } else {
            component.set("v.valueMap.docNumber", '');
        }
        if (paymentMethodType === 'Credit Card') {
            helper.inizializeSEPAFields(component);
            helper.inizializeCommodityFields(component);
            // component.set('v.showCreditCard', true);
            component.set('v.showSEPA', false);
            component.set('v.showCommodity', false);
        } else if (paymentMethodType === 'Direct Debt') {
            //helper.inizializeCreditCardFields(component);
            helper.inizializeCommodityFields(component);
            component.set('v.showCreditCard', false);
            component.set('v.showSEPA', true);
            component.set('v.showCommodity', false);
        } else if (paymentMethodType === 'Commodity Bill') {
            helper.inizializeSEPAFields(component);
            //helper.inizializeCreditCardFields(component);
            component.set('v.showCreditCard', false);
            component.set('v.showSEPA', false);
            component.set('v.showCommodity', true);
        }else if(paymentMethodType === 'External Financing'){
            component.set("v.showExtFinancing",true);
        }else if (paymentMethodType != 'Credit Card' && paymentMethodType != 'Direct Debt' && paymentMethodType != 'Commodity Bill') {
            //helper.inizializeCreditCardFields(component);
            helper.inizializeSEPAFields(component);
            helper.inizializeCommodityFields(component);
            component.set('v.showCreditCard', false);
            component.set('v.showSEPA', false);
            component.set('v.showCommodity', false);
        }

        if (component.get("v.valueMap.payment") && component.get("v.valueMap.legal") != undefined &&
            component.get("v.valueMap.billingAddress") && component.get("v.valueMap.soldContact") &&
            component.get("v.valueMap.soldAddress")) {

            var selectedDoxeeLanguage = component.find("comboboxdoxee").get("v.value");
            if (component.get("v.validInvoiceChannel") && component.get("v.validInvoiceChannel") == false) {
                component.set("v.disabledSubmit", true);
                return;
            }

            if (component.find("taxExemptId") && !component.get("v.valueMap.taxExempt")) {
                component.set("v.disabledSubmit", true);
                return;
            } 
            if (component.find("comboboxdoxee") && (component.find("comboboxdoxee").get("v.value") == undefined || component.find("comboboxdoxee").get("v.value") == '')) {
                component.set("v.disabledSubmit", true);
                return;
            }

            if(component.find("pec") && component.find("recCode")){
                if(
                    (!component.find("pec").get("v.value") ||component.find("pec").get("v.value") == "") &&
                    (!component.find("recCode").get("v.value") ||component.find("recCode").get("v.value") == "") 
                ){
                    component.set("v.disabledSubmit",true);
                    return;
                }else{
                    component.set("v.disabledSubmit",false);
                }
            }
            
            if(component.find("recCode") && (component.get("v.valueMap.isB2BG") == "B2B" || component.get("v.valueMap.isB2BG") == "B2G")){
                if(
                    (!component.find("recCode").get("v.value") ||component.find("recCode").get("v.value") == "")
                ){
                    component.set("v.disabledSubmit",true);
                    return;
                }else{
                    component.set("v.disabledSubmit",false);

                }
                if(component.find("recCode") && (component.get("v.valueMap.isB2BG") == "B2B")){
                var recCodeRegex = component.find("recCode");
                            var regexp = /^([a-zA-Z0-9_-]){7,7}$/
                            if(!recCodeRegex.get("v.value").match(regexp)) {
                                $A.util.addClass(recCodeRegex, 'slds-has-error');
                                component.set("v.disabledSubmit",true);
                                return;
                            }else{
                                $A.util.removeClass(recCodeRegex, 'slds-has-error');
                            }
                    }
                    else if (component.find("recCode") && (component.get("v.valueMap.isB2BG") == "B2G")){
                        var recCodeRegex = component.find("recCode");
                        var regexp = /^([a-zA-Z0-9_-]){6,6}$/
                        if(!recCodeRegex.get("v.value").match(regexp)) {
                            $A.util.addClass(recCodeRegex, 'slds-has-error');
                            component.set("v.disabledSubmit",true);
                            return;
                        }else{
                            $A.util.removeClass(recCodeRegex, 'slds-has-error');
                        }

                    }
                }



            if(component.find("invoiceDeliveryPreferencesPick") && (component.get("v.invoiceDelValue") == undefined 
            ||  component.get("v.invoiceDelValue")== "" )){
                component.set("v.disabledSubmit",true);
                return;
            }else{
                component.set("v.disabledSubmit",false);
            }

            //            if(selectedDoxeeLanguage != undefined){
            if (paymentMethodType === 'Direct Debt') {
                var accountNumber = component.find("accountNumber").get("v.value");
                if (accountNumber === undefined) {
                    component.set("v.disabledSubmit", true);
                } else {
                    component.set("v.disabledSubmit", false);
                }
            } else if (paymentMethodType === 'Credit Card') {
                component.set("v.disabledSubmit", false);
                // var cardNumber = component.find("cardNumber").get("v.value");
                // var month = component.find("month").get("v.value");
                // var year = component.find("year").get("v.value");
                // var cvv = component.find("cvv").get("v.value");
                // var cardholderName = component.find("cardholderName").get("v.value");
                // if (cardNumber === undefined || month === undefined || year === undefined || cvv === undefined || cardholderName === undefined) {
                //     component.set("v.disabledSubmit", true);
                // } else {
                //     component.set("v.disabledSubmit", false);
                // }
            }else if(paymentMethodType === 'External Financing'){
                if(component.get("v.sobjecttype")==='Account'){

                    if(!component.get("v.institutePickVal") || component.get("v.institutePickVal") == ""){
                        component.set("v.disabledSubmit",true);
                    }else if(component.get("v.institutePickVal") && component.get("v.showOtherExtFinancing") && (!component.get("v.otherInsituteVal") || component.get("v.otherInsituteVal")=="")){
                        component.set("v.disabledSubmit",true);
                    }else{
                        component.set("v.disabledSubmit",false);
                    }
                }
            }else if (paymentMethodType === 'Commodity Bill') {

                if(component.get("v.getContractBy") === 'POS'){ //component.get("v.isB2BLE") /*TODO > Implementare combo nel caso di + di un cups*/
                    var contractId = component.find("contractId") ? component.find("contractId").get("v.value") : '';
                    var cupsId = component.get("v.choosenContractCup"); //component.get("v.cupsList[0].value");
                }else{
                    var contractId = component.get("v.valueMap.contractId");
                    var cupsId = component.get("v.choosenContractCup");
                }
                console.log('@@@@@contractId' + contractId);
                console.log('@@@@@cupsId' + cupsId);
                if (contractId === '' || contractId == undefined /*|| cupsId === '' || cupsId == undefined*/) {
                    component.set("v.disabledSubmit", true);
                } else {
                    component.set("v.disabledSubmit", false);
                }
            } else {
                component.set("v.disabledSubmit", false);
            }

            // } else {
            //  component.set("v.disabledSubmit",true);
            //}
        }
        component.set("v.showSpinner", false);
    },

    checkValueForBilling: function (component, event, helper) {
        var leg = component.get("v.legalEnt");
        if (component.find("legal") &&
            leg != undefined && leg != '' &&
            component.get("v.valueMap.billingAddress") && component.get("v.valueMap.soldContact") &&
            component.get("v.valueMap.soldAddress")) //&& component.find("comboboxdoxee") && component.find("comboboxdoxee").get("v.value")!=undefined )
        {

            component.set("v.disabledSubmit", false);
        } else {
            component.set("v.disabledSubmit", true);
        }

        component.set("v.showSpinner", false);
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

    inizializeSEPAFields: function (componet) {
        componet.set("v.valueMap.accountNumber", "");
    },

    inizializeCreditCardFields: function (componet) {
        componet.set("v.valueMap.cardNumber", "");
        componet.set("v.valueMap.month", "");
        componet.set("v.valueMap.year", "");
        componet.set("v.valueMap.cvv", "");
        componet.set("v.valueMap.cardholderName", "");
    },
    inizializeCommodityFields: function (componet) {
        componet.set("v.valueMap.contractId", "");
        componet.set("v.valueMap.cupsId", "");
    },

    populateAllField: function (component, event, helper, selectedRows) {
        component.set("v.valueMap.contractId", selectedRows.Name);
        component.set("v.valueMap.cupsId", selectedRows.XC_PoD__c);
    },

    retrieveCups: function (component, event, helper) {
        component.set("v.showSpinner", true);
        let selectedOptionValue = event.getParam("value");
        let continueRetrieve = false;
        let segment = component.get("v.segmentofCountry");
        if (component.find("docNumber")) {
            continueRetrieve = true;
        }
        if (continueRetrieve) {
            if (selectedOptionValue && selectedOptionValue != '') { //selectedOptionValue != 'undefined'
                let action = component.get("c.retrieveCups");
                action.setParams({
                    "addressId": selectedOptionValue,
                    "documentNumber": component.find("docNumber").get("v.value"),
                    //14-02-2022 alag@deloitte.es Add Segment to distinguish ServerSystem in API - START 
                    "segmentofCountry": segment.XC_SegmentOfCountry__c
                    //14-02-2022 alag@deloitte.es Add Segment to distinguish ServerSystem in API - END
                });
                action.setCallback(this, function (response) {
                    let state = response.getState();
                    let retValue = response.getReturnValue();
                    //[ START, gaurav.tejpal@accenture.com, 13/04/2022,Enel X - Get Contract] -->
                    if(state === "SUCCESS" &&  retValue.contract == "" 
                      && component.find('docNumber') != "" 
                      && component.find('docCountry').get('v.value') == "Brazil" 
                      &&  retValue.isB2B == false 
                      && retValue.cups == null 
                      &&  retValue.cupsLight == null 
                      && retValue.cupsGas == null){ 
                       helper.getB2CCommodityContract(component,event,helper); 
                    }
                    //[ END, gaurav.tejpal@accenture.com, 13/04/2022,Enel X - Get Contract] -->
                    else if (state === "SUCCESS" && retValue != null) {
                        let cupslist = retValue.cups;
                        let cupsLight = retValue.cupsLight;
                        let cupsGas = retValue.cupsGas;
                    //[ START, gaurav.tejpal@accenture.com, 17/05/2022,Enel X - Get Contract] -->
                        let cCustomerName= retValue.commodityCustomerName;
                        let cIdentityNumber= retValue.commodityIdentityNumber;
                    if(component.find('docCountry').get('v.value') == "Brazil" && component.get("v.valueMap.stream")=='B2C'){
                        if(cCustomerName!=null && cCustomerName!="")
                        {
                            component.set('v.valueMap.commodityCustomerName', cCustomerName);
                        }
                        if(cIdentityNumber!=null && cIdentityNumber!="")
                        {
                            component.set('v.valueMap.commodityIdentityNumber', cIdentityNumber);
                        }
                    }
                    //[ END, gaurav.tejpal@accenture.com, 17/05/2022,Enel X - Get Contract] -->
                        //console.log('@@@ is B2B  ' + retValue.isB2B);
                        let opts = [];
                        let l = (cupslist) ? cupslist.length : 0;
                        if (l == 0 && component.get("v.valueMap.payment") === 'Commodity Bill') {
                            let toastEvent = $A.get("e.force:showToast");
                            let title = $A.get("$Label.c.XC_CL_ErrorsOccurred");
                            let message = $A.get("$Label.c.XC_CL_NoPODfound");
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
                            for (let i = 0; i < cupsLight.length; i++) {
                                opts.push({
                                    value: cupsLight[i],
                                    label: 'Electric - '+cupsLight[i]
                                });
                            }
                            for (let i = 0; i < cupsGas.length; i++) {
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
                            let toastEvent = $A.get("e.force:showToast");
                            let title = $A.get("$Label.c.XC_CL_ErrorsOccurred");
                            let message = $A.get("$Label.c.XC_CL_NoContractForDoc");
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
                    //14-02-2022 alag@deloitte.es Errors control - START
                    }else if(state === "ERROR"){
                        var errors = response.getError();
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: "¡Error!",
                            message: errors,
                            type: "error"
                        });
                        toastEvent.fire();
                        console.error(errors);
                    }
                    //14-02-2022 alag@deloitte.es Errors control - END
                    component.set("v.showSpinner", false);
                });
                $A.enqueueAction(action);
            }
        } else {
            component.set("v.showSpinner", false);
        }
    },
    retrieveCupsByDocAndPOS: function (component, event, helper) {
        component.set("v.showSpinner", true);
        let selectedOptionValue = event.getParam("value");
        let continueRetrieve = false;
        if (component.find("docNumber")) {
            continueRetrieve = true;
        }
        if (continueRetrieve) {
            if (selectedOptionValue && selectedOptionValue != '') { //selectedOptionValue != 'undefined'
                let action = component.get("c.retrieveCupsByDocAccountAndPOD");
                action.setParams({
                    "addressId": selectedOptionValue,
                    "documentNumber": component.find("docNumber").get("v.value")

                });
                action.setCallback(this, function (response) {
                    let state = response.getState();
                    let retValue = response.getReturnValue();

                    if (state === "SUCCESS" && retValue != null) {
                        let cupslist = retValue.cups;
                        let cupsLight = retValue.cupsLight;
                        let cupsGas = retValue.cupsGas;

                        //console.log('@@@ is B2B  ' + retValue.isB2B);
                        let opts = [];
                        let l = (cupslist) ? cupslist.length : 0;
                        if (l == 0 && component.get("v.valueMap.payment") === 'Commodity Bill') {
                            let toastEvent = $A.get("e.force:showToast");
                            let title = $A.get("$Label.c.XC_CL_ErrorsOccurred");
                            let message = $A.get("$Label.c.XC_CL_NoPODfound");
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
                            for (let i = 0; i < cupsLight.length; i++) {
                                opts.push({
                                    value: cupsLight[i],
                                    label: 'Electric - '+cupsLight[i]
                                });
                            }
                            for (let i = 0; i < cupsGas.length; i++) {
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
                            let toastEvent = $A.get("e.force:showToast");
                            let title = $A.get("$Label.c.XC_CL_ErrorsOccurred");
                            let message = $A.get("$Label.c.XC_CL_NoContractForDoc");
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
                        component.set('v.commodityAccountId', retValue.commodityAccountId);
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
    getTableData: function (component, event, helper, list) {
        helper.getColumn(component, event, helper);
        component.set("v.data", list);

    },
    getColumn: function (component, event, helper) {
        let column = [{
                label: 'Cups',
                fieldName: 'XC_PoD__c',
                type: 'text'
            },
            {
                label: 'Contract ',
                fieldName: 'Name',
                type: 'type'
            }
        ];
        component.set("v.columns", column);
    },

    showMessage: function (component, event, helper, message, type) {
        component.set("v.showSpinner", false);
        if (type === 'info') {
            type = 'success';
        }

        let toastEvent = $A.get("e.force:showToast");
        //$A.get("e.force:closeQuickAction").fire();


        toastEvent.setParams({
            message: message,
            type: type,
            mode: "pester"
        });
        toastEvent.fire();
        //$A.get("e.force:closeQuickAction").fire();


        // component.find('notifLib').showNotice({
        //     "header": message,
        //     "message": '',
        //     "variant": type
        // }); 


        // var fromOrder = component.get("v.fromOrderComponent");
        // if(!fromOrder){
        // setTimeout(function(){
        //      $A.get("e.force:closeQuickAction").fire();


        // }, 3000);

        // setTimeout(function(){
        //      $A.get("e.force:closeQuickAction").fire();


        // }, 2000);
        // }
        helper.closeModalZuora(component, event, helper);
    },

    createSiaToken: function (component, event, helper, valueMap, paymentMethodId, mapObj, contactId, paymentMethod, billingProfileId, bpLineItemId) {


        var lang = component.find("comboboxdoxee").get("v.value");
        var action = component.get("c.manageOperationBeforeCallSia");
        action.setParams({
            "contactId": contactId,
            "lang": lang,
            "paymentMethod": paymentMethod,
            "billingProfileId": billingProfileId
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            var res = response.getReturnValue();
            if (state === "SUCCESS") {
                console.log('SIA RESPONSE = ' + JSON.stringify(res));
                if (res.success) {
                    var siaResponse = JSON.parse(res.objectInfo);
                    console.log('SIA RESPONSE = ' + JSON.stringify(siaResponse));
                    var debtorCode = siaResponse.debtorCode;

                    //error management
                    if(!debtorCode){
                        let errorMessage = siaResponse.details;
                        let errorCode = siaResponse.code;

                        var toastEvent = $A.get("e.force:showToast");
                        var title = errorCode;
                        var message = errorMessage;
                        toastEvent.setParams({
                            "title": title,
                            "message": message,
                            "type": 'error'
                        });
                        toastEvent.fire();
                        component.set("v.showSpinner",false);
                        $A.get("e.force:closeQuickAction").fire();
                        return;

                    }

                    component.set("v.debtorCode", debtorCode);
                    // helper.createZuoraAccount(component,event,helper,valueMap, paymentMethodId, mapObj, res.paymentMethodSIA ,res.interactionRecordId);  //

                    if (mapObj.payment !== 'Credit Card') {
                        helper.createUnlinkedZuora(component, event, helper, valueMap, paymentMethodId, mapObj, bpLineItemId);
                    } else {
                        var message = $A.get('{!$Label.c.XC_CL_BIllProfCCCreated}');
                        helper.showMessage(component, event, helper, message, 'success');
                    }
                } else {

                    var message = res.resultMessage;
                    component.set("v.showSpinner", false);
                    helper.showMessage(component, event, helper, message, 'error');
                }
            } else {
                component.set("v.showSpinner", false);
                let msg = response.getError()[0].message;
                console.log('ERROR:: ' + msg);
                helper.showMessage(component, event, helper, 'Error', 'error');
            }
        });
        $A.enqueueAction(action);
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

    closeModalZuora: function (component, event, helper) {
        var ev = $A.get("e.c:XC_LCE015_ModalClosed");
        if (ev) {
            ev.setParams({
                "modalName": $A.get("$Label.c.XC_CL_ZuoraBillingCreationClosedEvent")
            });
            ev.fire();
        }
        let dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },

    getPaymentMethodCategory: function (component, event, helper) {

        /*Get dependent picklist values in order to identify external methods*/

        let currentChosenMop = component.find("comboboxpayment").get("v.value");
        let getDependencyAction = component.get('c.getPaymentCategoryDependency');
        console.log(getDependencyAction);
        getDependencyAction.setParams({
            paymentMethod: currentChosenMop
        });
        getDependencyAction.setCallback(this, function (response) {

            if (response.getState() === "SUCCESS") {
                let result = response.getReturnValue();
                component.set("v.paymentMethodCategoryVal", result);
            } else {
                console.log(response.getError()[0].message);
            }
        });
        $A.enqueueAction(getDependencyAction);
    },


    getB2CCommodityContract : function(component,event,helper){

        component.set("v.showSpinner",true);
        let docNif = component.find('docNif').get('v.value');
        let docNum = component.find('docNumber').get('v.value');
        let docCountry = component.find('docCountry').get('v.value');
        let accountId = component.get('v.recordId');

        let paramsMap = {
            'documentType' : docNif,
            'documentNumber' : docNum,
            'docCountry' : docCountry,
            'accountId' : accountId
        };

        let action = component.get("c.getCommodityContract");
        action.setParams({params : paramsMap});
        action.setCallback(this,function(response){
            if(response.getState()==="SUCCESS"){
                component.set("v.showSpinner",false);
                let result= response.getReturnValue();

                if(result.length>0){
                    let pickListOptions = [];
                    let contractMap = {};
                    for(let i=0;i<result.length;i++){
                        let label = result[i].pickValue;
                        let value = result[i].key;
                        pickListOptions.push({'label':label,'value':value});
                        contractMap[result[i].key]=result[i];
                    }
                    component.set("v.commodityContractMap",contractMap);
                    component.set("v.contractOpts",pickListOptions);
                    component.set("v.showCommodity",true);
                    component.set("v.showCUPS",true);
                    if (component.find('docCountry').get('v.value') == 'Brazil' && component.get("v.recordTypeName") == 'XC_GLO_Account_Residential'){
                        component.set("v.getContractBy","IdentityDoc");
                    }

                }
                //[ START, gaurav.tejpal@accenture.com, 13/04/2022,Enel X - Get Contract] -->
                else if(component.get("v.recordTypeName") == 'XC_GLO_Account_Residential' && component.find('docCountry').get('v.value') == 'Brazil')
                    {
                    var toastEvent = $A.get("e.force:showToast");
                    var title = $A.get("$Label.c.XC_CL_ErrorsOccurred");
                    var message = $A.get("$Label.c.XC_CL_NoContractForDoc");
                    toastEvent.setParams({
                             "title": title,
                            "message": message,
                            "type": 'error'
                     });
                     toastEvent.fire();
                     }
                 //[ END, gaurav.tejpal@accenture.com, 13/04/2022,Enel X - Get Contract] -->
                else{
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



            }
            
            else{
                component.set("v.showSpinner",false);
                let msg = response.getError()[0].message;
                console.log('ERROR IN GET CONTRACT COMMODITY B2C::: ' + msg);
            }



        });
        $A.enqueueAction(action);

    },

    onChooseCommodityPOS : function(component, event, helper) {
        component.set("v.showSpinner",true);
        component.set("v.choosenContractCup",component.get("v.selectedPOS"));
        var actionGetContr = component.get("c.getContractByPOS");
            actionGetContr.setParams({
                "pos": component.get("v.selectedPOS"),
                "addressId": component.get("v.valueMap.soldAddress") 
            });
            actionGetContr.setCallback(this, function (response) {
                var state = response.getState();
                var res = response.getReturnValue();
                if (state === "SUCCESS" && res ) {
                    if(res.contract!=null && res.contract!=''){
                        component.set("v.valueMap.contractId", res.contract);
                        helper.checkValue(component, event, helper);
                    }else{
                        let toastEvent = $A.get("e.force:showToast");
                        let title = $A.get("$Label.c.XC_CL_ErrorsOccurred");
                        let message = $A.get("$Label.c.XC_CL_NoContractForDoc");
                        toastEvent.setParams({
                            "title": title,
                            "message": message,
                            "type": 'error'
                        });
                        toastEvent.fire();
                        component.set('v.contractValue', null);
                        component.set("v.valueMap.contractId", null);
                        component.set("v.disabledSubmit", true);
                    }
                }
                component.set("v.showSpinner",false);
            });
            $A.enqueueAction(actionGetContr);
    },

    onChooseCommodityContract : function (component,event,helper){

        //retrieving contract info from map
        let chosenContractKey = event.getParam("value");
        let contractObj = component.get("v.commodityContractMap")[chosenContractKey];
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

    saveIntegrationLog : function(component,event,helper,logs){

        return new Promise((resolve,reject)=>{
            let saveLogAction = component.get("c.saveIntegrationLog");
            saveLogAction.setParams({integrationLogList : JSON.stringify(logs)});
            saveLogAction.setCallback(this,function(response){
                if(response.getState()==="SUCCESS"){
                    let result = response.getReturnValue();
                    if(result){
                        resolve(result);
                        console.log('INTEGRATION LOGS SAVED');
                    }else{
                        reject(result);
                        console.log('CANNOT SAVE INTEGRATION LOGS');
                    }
                }else{
                    reject(response.getError()[0]);
                    console.log('CANNOT SAVE LOGS ' + JSON.stringify(response.getError()[0]));
                }
            });
            $A.enqueueAction(saveLogAction);

        });

    },
    
     retrieveLegalEntities  : function (component,event,helper){

        if(component.get("v.recordTypeName") == 'XC_GLO_B2B' || component.get("v.recordTypeName") == 'XC_GLO_B2G' ){
            var contactId = component.get(" v.valueMap.soldContact ");
            var actionCheckContact = component.get("c.getContactLegalEntities");
            actionCheckContact.setParams({
                "contactId": contactId
            });
            actionCheckContact.setCallback(this, function (response) {
                var state = response.getState();
                var res = response.getReturnValue();
                if (state === "SUCCESS" && res ) {
                    var valueMap = JSON.parse(res);
                    console.log(' contact legal entities: ' + valueMap);
                    var legalEntityOpt = [];
                    if (valueMap) {
                        (valueMap).forEach(function (entry) {
                            legalEntityOpt.push({
                                value: entry['key'],
                                label: entry['value']
                            });
                        })
                        component.set("v.showMultipicklistLE", legalEntityOpt);
                    }
                }
            });
            $A.enqueueAction(actionCheckContact);
        }

    }

})