({
    doInit: function (component, event, helper) {

        helper.init(component, event, helper);
    },
    create: function (component, event, helper) {
        component.set("v.showSpinner", true);
        helper.retriveContactsForZuora(component, event, helper, '');
    },

    showDocumentSection: function (component, event, helper) {
        component.set("v.showDocument", true);

        setTimeout(function () {
            helper.checkValue(component, event, helper);
        }, 1200);
         //[ START, gaurav.tejpal@accenture.com, 15/07/2022,Enel X - Get Contract] -->
        if(component.get("v.valueMap.payment") === 'Commodity Bill' && JSON.stringify(component.get("v.valueMap.billingAddresses")).includes('Brazil'))
        {
            if(!$A.util.isEmpty(component.get("v.electricCUP")))
            {
                helper.retrieveCups(component, event, helper); //gaurav.tejpal@accenture.com, 14/07/2022,Enel X - Get Contract
            }
            else
            {
                helper.getB2CCommodityContract(component,event,helper);
            }
        } 
        //[ END, gaurav.tejpal@accenture.com, 15/07/2022,Enel X - Get Contract] -->
    },

    closeModal: function (component, event, helper) {
        //     var workspaceAPI = component.find("workspace");
        //     var res = component.get("v.fromOrderComponent");
        //     if (res) {
        //         var b = true;
        //         var closeAll = false;
        //         if (component.get("v.sobjecttype") === 'NE__Billing_Profile__c') {
        //             closeAll = true;
        //         }
        //         var cmpEvent = $A.get("e.c:XC_LCE016_RefreshView");
        //         cmpEvent.setParams({
        //             "refreshView": b,
        //             "closeAll": closeAll
        //         });
        //         cmpEvent.fire();
        //         /*
        //          workspaceAPI.getFocusedTabInfo().then(function(response) {
        // 		 var focusedTabId = response.tabId;
        // 		 workspaceAPI.closeTab({tabId: focusedTabId});

        //    })  */

        //     } else {
        //         $A.get("e.force:closeQuickAction").fire();
        //     }
        let ev = component.getEvent("XC_LCE019_CloseChildComponent");
        ev.fire();

    },

    invoiceDeliveryPreferencesChange: function (component, event, helper) {
        var selectedValues = component.get("v.boolCheck");
        console.log('selectedValues INIZIO =' + selectedValues);

        if (!selectedValues) {
            console.log('entrato in include');
            component.set("v.valueCheck", "Print");
            component.set("v.boolCheck", true);
        } else {
            component.set("v.valueCheck", "Email");
            component.set("v.boolCheck", false);
        }

        console.log('selectedValues FINE=' + component.get("v.boolCheck"));
    },

    checkValuePayment: function (component, event, helper) {
        var selectedOptionValue = event.getParam("value");
        if (selectedOptionValue === 'Commodity Bill') {
            //component.set("v.showPreferences", false);
            component.set("v.valueCheck", 'Email'); 
            //if(component.get("v.isB2BLE")){
         //[ START, gaurav.tejpal@accenture.com, 15/07/2022,Enel X - Get Contract] -->
            if((component.get("v.valueMap.payment") === 'Commodity Bill' && component.get("v.getContractBy") === 'POS') && !(JSON.stringify(component.get("v.valueMap.billingAddresses")).includes('Brazil') && $A.util.isEmpty(component.get("v.electricCUP")))){
                helper.retrieveCups(component, event, helper);
            }else if(component.get("v.valueMap.payment") === 'Commodity Bill' &&  component.get("v.getContractBy") === 'AccountDocAndPOD'){
                helper.retrieveCupsByDocAndPOS(component, event, helper);
            }else if((component.get("v.recordTypeName")=='XC_GLO_Account_Soho' || component.get("v.recordTypeName")=='XC_GLO_Account_Condominium') && //!component.get("v.isB2BLE")){
                      component.get("v.valueMap.payment") === 'Commodity Bill' && component.get("v.getContractBy") === 'IdentityDoc'){
                helper.getB2CCommodityContract(component,event,helper);
            }
             //[ END, gaurav.tejpal@accenture.com, 15/07/2022,Enel X - Get Contract] -->
        }
        helper.checkValue(component, event, helper);
    },

    checkCUPS: function (component, event, helper) {

        var selected_value = event.getParam("value");
        var mapTypeOfContract = component.get("v.mapContractIdContractType");
        console.log('selectedValue =' + selected_value);
        for (let i = 0; i < mapTypeOfContract.length; i++) {
            if (mapTypeOfContract[i].key == selected_value) {
                console.log('gas ' + $A.get("$Label.c.XC_CL_ContractTypeGAS"));

                if ((mapTypeOfContract[i].value).includes($A.get("$Label.c.XC_CL_ContractTypeGAS"))) {
                    component.set("v.valueMap.cupsId", component.get("v.gasCUP"));
                } else {
                    component.set("v.valueMap.cupsId", component.get("v.electricCUP"));
                }

                helper.checkValue(component, event, helper);
            }

        }


    },
    onCheckTax: function (component, event, helper) {

        var isChecked = component.get('v.taxExemptStatus');

        if (isChecked != null && isChecked != 'undefined') {
            var newVal = isChecked == "false" ? "true" : "false";
            component.set("v.taxExemptStatus", newVal);
        }
    },

    checkValue: function (component, event, helper) {
        helper.checkValue(component, event, helper);
    },

    onChooseCommodityPOS : function(component, event, helper) {
        helper.onChooseCommodityPOS(component, event, helper);
    },

    /*commodityPosChanged : function(component, event, helper) {
        helper.commodityPosChanged(component, event, helper);
    },*/

    updateAccount: function (component, event, helper) {
        if (component.find("comboboxdoxee")) {
            var doxeeSelectedLanguage = component.find("comboboxdoxee").get("v.value");
            //alert('selectedValues -->'+doxeeSelectedLanguage);
            if (doxeeSelectedLanguage && doxeeSelectedLanguage != null) {
                var mapValues = {
                    PreferredLanguage__c: doxeeSelectedLanguage
                };
                helper.updateAccount(component, event, helper, JSON.stringify(mapValues));
            }
        }
        helper.checkValue(component, event, helper);
    },

    retrieveContractAndCups: function (component, event, helper) {
        component.set("v.showStrikeModal", true);
        helper.retrieveCupsAndContract(component, event, helper);
    },

    setLegalEntity: function (component, event, helper) {
        var selectedOptionValue = event.getParam("value");
        if (selectedOptionValue != 'undefined' && selectedOptionValue != '') {
            component.set("v.valueMap.legal", selectedOptionValue);
        }
        helper.checkValue(component, event, helper);
    },

    updateSelectedText: function (component, event, helper) {
        var selectedRows = event.getParam('selectedRows');
        selectedRows = selectedRows[0];
        helper.populateAllField(component, event, helper, selectedRows);

    },
    handlePrimaryButtonClick: function (component, event, helper) {
        component.set("v.showStrikeModal", false);
    },

    retrieveCupsId: function (component, event, helper) {
        helper.retrieveCups(component, event, helper);
    },

    onChangePayTerm: function (component, event, helper) {
        let selectedPayTerm = event.getParam("value");
        if (selectedPayTerm) {
            component.set("v.paymentTerm", selectedPayTerm);
        }
    },

    checkContact: function (component, event, helper) {
        if (component.get("v.invoiceDelValue") == 'Email' || component.get("v.invoiceDelValue") == 'SmartInvoice') {
            var actionCheckContact = component.get("c.checkContactEmail");
            var contactId = component.get(" v.valueMap.soldContact ");
            actionCheckContact.setParams({
                "contactId": contactId
            });
            actionCheckContact.setCallback(this, function (response) {
                var state = response.getState();
                var res = response.getReturnValue();
                if (state === "SUCCESS" && !res) {
                    var toastEvent = $A.get("e.force:showToast");
                    var title = $A.get("$Label.c.XC_CL_ErrorsOccurred");
                    var message = $A.get("$Label.c.XC_CL_BillingProfile_ContactWithoutEmail");
                    toastEvent.setParams({
                        "title": title,
                        "message": message,
                        "type": 'error'
                    });
                    toastEvent.fire();
                    //component.set("v.disabledSubmit", true);
                    component.set("v.validInvoiceChannel", false);
                } else {
                    component.set("v.disabledSubmit", false);
                    component.set('v.notExistsEmail', false);
                    component.set("v.validInvoiceChannel", true);
                    helper.checkValue(component, event, helper);
                }
            });

            $A.enqueueAction(actionCheckContact);
        }
        else {
            //component.set("v.disabledSubmit", false);
            component.set("v.validInvoiceChannel", true);
            helper.checkValue(component, event, helper);
        }

        // Disable button Save:
        if((component.get('v.invoiceDelValue')=='Email' || component.get('v.invoiceDelValue').includes('Smart'))) {
            if(component.get('v.contactHasEmail') == true) {
                component.set('v.notExistsEmail', false);
            } else {
                component.set('v.notExistsEmail', true);
            }
        } else {
            component.set('v.notExistsEmail', false);
        }
    },

    checkCommodity: function (component, event, helper) {
        //if (!component.get('v.isB2BLE')) {
        if (component.get("v.getContractBy") === 'IdentityDoc' && component.get('v.valueMap.payment') === 'Commodity Bill') {
            helper.getB2CCommodityContract(component, event, helper);
        }
        //}
    },


    onChooseCommodityContract: function (component, event, helper) {
        helper.onChooseCommodityContract(component, event, helper);
    },

    checkExternalFinancing : function(component,event,helper){
        if(component.get("v.institutePickVal")){
            if(component.get("v.institutePickVal") === 'Other'){
                component.set("v.showOtherExtFinancing",true);
            }else{
                component.set("v.showOtherExtFinancing",false);
            }
        }
        helper.checkValue(component,event,helper);
    }


})