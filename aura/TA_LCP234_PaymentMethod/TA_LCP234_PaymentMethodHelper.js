({
    initialize : function(component, event, helper, isRefresh) {
        console.log('TA_LCP234_PaymentMethod >> Helper >> initialize >> Start');
        component.set('v.general', JSON.parse(component.get('v.fieldSet')).general);
        component.set('v.custom', JSON.parse(component.get('v.fieldSet')).custom);
        component.set('v.customerCardBg', $A.get('$Resource.TA_Images') + '/imgs/' + component.get('v.general.bgImage'));

        let paymentMethodBackup = '';

        if(event.currentTarget) {
            isRefresh = event.currentTarget.name == 'refresh' ? true : false;
            this.fireToggleSpinnerEvent(component, true);
        }

        if(isRefresh) paymentMethodBackup = component.get('v.selectedPaymentMethod');

        let action = component.get('c.initialize');
        action.setParams({
            'workOrderSerialized' : JSON.stringify(component.get("v.workOrder"))
        });

        action.setCallback(this, function(response) {
            console.log('TA_LCP234_PaymentMethod >> Helper >> initializeCallback >> Start');
            if(response.getState() == "SUCCESS") {
                let infoBag = JSON.parse(response.getReturnValue());
                component.set("v.infoBag", infoBag);
                component.set("v.billingAddressList", infoBag.billingAddressList);
                component.set("v.paymentsAllowedList", infoBag.paymentsAllowedList);
                component.set("v.billingProfileWrapper", infoBag.billingProfileWrapper);
                component.set("v.billingProfileLineItemMap", infoBag.billingProfileLineItemMap);

                if(paymentMethodBackup != '') {
                    component.set('v.selectedPaymentMethod', paymentMethodBackup);
                    let payments = component.get('v.paymentsAllowedList');
                    payments.forEach(function(payment) {
                        if(payment.name == paymentMethodBackup) payment.selected = true;
                        else payment.selected = false;
                    });
                    component.set('v.paymentsAllowedList', payments);
                }

                let selectedPaymentMethod = component.get("v.selectedPaymentMethod");
                let billingProfileLineItemMap = component.get("v.billingProfileLineItemMap");
                let selectedBillingProfileLineItemList = [];
                if(selectedPaymentMethod) {
                    for(let billingProfileName in billingProfileLineItemMap) {
                        if(selectedPaymentMethod == billingProfileName) {
                            selectedBillingProfileLineItemList = billingProfileLineItemMap[billingProfileName];
                        }
                    }
                }

                let disabledNewPaymentMethod = false;
                selectedBillingProfileLineItemList.forEach(function(billingProfileLineItem) {
                    billingProfileLineItem.isChecked = false;
                    if((selectedPaymentMethod == 'Bank Transfer' || selectedPaymentMethod == 'External Financing') && billingProfileLineItem.XC_BillingProfile__r.NE__Payment__c == selectedPaymentMethod) {
                        disabledNewPaymentMethod = true;
                    }
                });
                component.set("v.selectedBillingProfileLineItemList", selectedBillingProfileLineItemList);
                component.set("v.disabledNewPaymentMethod", disabledNewPaymentMethod);
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }

            if(isRefresh) {
                this.fireToggleSpinnerEvent(component, false);
            } else {
                this.fireSendInitStateEvt(component, true);
            }
            console.log('TA_LCP234_PaymentMethod >> Helper >> initializeCallback >> End');
        });

        $A.enqueueAction(action);
        let invoicePreferencesList = [
            {'label': $A.get("$Label.c.TA_Print"), 'value': 'Print'},
            {'label': $A.get("$Label.et4ae5.email"), 'value': 'Email'}
            ];
        component.set("v.invoicePreferencesList",invoicePreferencesList);
        component.set("v.invoicePreference", component.get("v.selectedPaymentMethod") != 'Credit Card' ? 'Print' : 'Email');

        let radioModalList = [
            {'label': $A.get("$Label.c.XC_CL_BillingModel_Recurring"), 'value': 'Recurring'},
            {'label': $A.get("$Label.c.XC_CL_BillingModel_OneShot"), 'value': 'One Time'}
            ];
        component.set("v.radioModalList",radioModalList); 
        component.set("v.radioModalPreference",'One Time');
        console.log('TA_LCP234_PaymentMethod >> Helper >> initialize >> End');
    },

    selectPaymentMethod : function(component, event, helper) {
        console.log('TA_LCP234_PaymentMethod >> Helper >> selectPaymentMethod >> Start');
        let selectedPaymentMethod = component.get("v.selectedPaymentMethod");
        component.set("v.billingProfileLineItemIdSelected", '');
        component.set("v.iban", '');
        component.set("v.bic", '');

        let billingProfileLineItemMap = component.get("v.billingProfileLineItemMap");
        let selectedBillingProfileLineItemList = [];
        if(selectedPaymentMethod) {
            for(let billingProfileName in billingProfileLineItemMap) {
                if(selectedPaymentMethod == billingProfileName) {
                    selectedBillingProfileLineItemList = billingProfileLineItemMap[billingProfileName];
                }
            }
        }

        let disabledNewPaymentMethod = false;
        selectedBillingProfileLineItemList.forEach(function(billingProfileLineItem) {
            billingProfileLineItem.isChecked = false;
            if((selectedPaymentMethod == 'Bank Transfer' || selectedPaymentMethod == 'External Financing') && billingProfileLineItem.XC_BillingProfile__r.NE__Payment__c == selectedPaymentMethod) {
                disabledNewPaymentMethod = true;
            }
        });
        component.set("v.selectedBillingProfileLineItemList", selectedBillingProfileLineItemList);
        component.set("v.disabledNewPaymentMethod", disabledNewPaymentMethod);
        console.log('TA_LCP234_PaymentMethod >> Helper >> selectedPaymentMethod >> End');
    },

    cardChecked : function(component, event, helper) {
        console.log('TA_LCP234_PaymentMethod >> Helper >> cardChecked >> Start');
        let billingProfileLineItemId = event.currentTarget.id;
        let selectedBillingProfileLineItemList = component.get('v.selectedBillingProfileLineItemList');
        selectedBillingProfileLineItemList.forEach(function(billingProfileLineItem) {
            if(billingProfileLineItem.Id == billingProfileLineItemId) {
                billingProfileLineItem.isChecked = !billingProfileLineItem.isChecked;
                if(billingProfileLineItem.isChecked) {
                    component.set("v.billingProfileLineItemIdSelected", billingProfileLineItemId);
                } else {
                    component.set("v.billingProfileLineItemIdSelected", '');
                }
            } else {
                billingProfileLineItem.isChecked = false;
            }
        });

        component.set("v.selectedBillingProfileLineItemList", selectedBillingProfileLineItemList);
        console.log('TA_LCP234_PaymentMethod >> Helper >> cardChecked >> End');
    },

    showNewPaymentModal_old: function (component, event, helper) {
        console.log('TA_LCP234_PaymentMethod >> Controller >> showNewPaymentModal >> Start');
        let imgId = event.currentTarget.id;
        let selectedPaymentMethod = component.get("v.selectedPaymentMethod");
        // gestione inserimento billing profile che non richiedono il modale
        if(imgId == 'add') {
            if(selectedPaymentMethod == 'Credit Card') {
                let billingProfileWrapper = component.get("v.billingProfileWrapper");
                billingProfileWrapper.IBAN = null;
                billingProfileWrapper.SEPABIC = null;
                billingProfileWrapper.PaymentMethod = component.get("v.selectedPaymentMethod");
                billingProfileWrapper.InvoiceDeliveryPref = component.get("v.invoicePreference");
                billingProfileWrapper.SEPAMandateType = 'Recurring';
                helper.insertBillingProfile(component, event, helper, billingProfileWrapper);
            } else if(selectedPaymentMethod == 'External Financing') {
                let billingProfileWrapper = component.get("v.billingProfileWrapper");
                billingProfileWrapper.IBAN = null;
                billingProfileWrapper.SEPABIC = null;
                billingProfileWrapper.PaymentMethod = component.get("v.selectedPaymentMethod");
                billingProfileWrapper.InvoiceDeliveryPref = component.get("v.invoicePreference");
                billingProfileWrapper.SEPAMandateType = null;

                //STAR FIX [20210706AL] - Manage External Financing
                billingProfileWrapper.BillingAddressID = component.get('v.billingAddressSelected');
                billingProfileWrapper.SoldAddressID = component.get('v.workOrder').XC_Address__c;
                let billingProfiles = component.get('v.infoBag').billingProfiles;
                billingProfiles.forEach(function(bp) {
                    if(bp.NE__Payment__c == 'External Financing') billingProfileWrapper.BillingProfileId = bp.Id;
                });
                //END FIX [20210706AL] - Manage External Financing

                helper.insertBillingProfile(component, event, helper, billingProfileWrapper);
            } else if(selectedPaymentMethod == 'Direct Debt' || selectedPaymentMethod == 'Commodity Bill') {
                component.set("v.showNewPaymentModal", true);
            } else if(selectedPaymentMethod == 'Bank Transfer') {
                //STAR FIX [20210706AL] - Manage Bank Transfer
                let billingProfiles = component.get('v.infoBag').billingProfiles;
                billingProfiles.forEach(function(bp) {
                    if(bp.NE__Payment__c == 'Bank Transfer') component.set('v.billingProfile', bp);
                });
                component.set('v.soldToAddrFromParent', {'deliveryAddressId' : component.get('v.workOrder.XC_Address__c'), 'deliveryAddressName' : component.get('v.workOrder.XC_Address__r.Name')})
                //END FIX [20210706AL] - Manage Bank Transfer
                
                component.set("v.showNewPaymentModal", true);
                component.set('v.showZuora',true);
            }
        } else if(imgId == 'close') {
            component.set("v.showNewPaymentModal", false);
        }
        console.log('TA_LCP234_PaymentMethod >> Controller >> showNewPaymentModal >> End');
    },

    showNewPaymentModal : function(component, event, helper) {
        console.log('TA_LCP234_PaymentMethod >> Controller >> showNewPaymentModal >> Start');
        if(event.currentTarget.id == 'add') {
            let billingProfiles = component.get('v.infoBag').billingProfiles;
            billingProfiles.forEach(function(bp) {
                if(bp.NE__Payment__c == component.get("v.selectedPaymentMethod")) component.set('v.billingProfile', bp);
            });

            component.set('v.soldToAddrFromParent', {'deliveryAddressId' : component.get('v.workOrder.XC_Address__c'), 'deliveryAddressName' : component.get('v.workOrder.XC_Address__r.Name')})
            component.set("v.showNewPaymentModal", true);
            component.set('v.showZuora',true);

        } else if(event.currentTarget.id == 'close') {
            component.set("v.showNewPaymentModal", false);
        }
        console.log('TA_LCP234_PaymentMethod >> Controller >> showNewPaymentModal >> End');
    },

    modalIban : function(component, event, helper) {
        console.log('TA_LCP234_PaymentMethod >> Helper >> modalIban >> Start');
        let iban = event.getSource().get('v.value'); 
        console.log('iban: ' + iban);     
        // check if iban is valid    
        let ibanValidation = helper.isValidIBANNumber(iban,helper); 
        if(ibanValidation && ibanValidation == 1){
            console.log('IBAN IS VALID');            
        }
        else{
            console.log('IBAN IS NOT VALID');
            component.set("v.toastMessage",'Invalid IBAN');
            component.set("v.isError",true);
            component.set("v.showToastMessage",true);
        }
        
        console.log('TA_LCP234_PaymentMethod >> Helper >> modalIban >> Finish');
    },

    modalBic : function(component, event, helper) {
        console.log('TA_LCP234_PaymentMethod >> Helper >> modalBic >> Start');
        let bic = event.getSource().get('v.value'); 
        console.log('bic: ' + bic); 

        // check if BIC is valid
        let patt = new RegExp('^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$');
        let isBicValid = patt.test(bic);          
        console.log('isBicValid: ' + isBicValid);       
        if(!isBicValid){
            console.log('BIC IS NOT VALID');
            component.set("v.toastMessage",'Invalid BIC');
            component.set("v.isError",true);
            component.set("v.showToastMessage",true);
        }  
        console.log('TA_LCP234_PaymentMethod >> Helper >> modalBic >> Finish');
    },

    modalButton : function(component, event, helper) {
        console.log('TA_LCP234_PaymentMethod >> Helper >> modalButton >> Start'); 

        let buttonType = event.getSource().get('v.name');
        // inserimento di billing profile dopo compilazione form
        if(buttonType == 'continue'){
            let billingProfileWrapper = component.get("v.billingProfileWrapper");
            billingProfileWrapper.IBAN = component.get("v.iban");
            billingProfileWrapper.SEPABIC = component.get("v.bic");
            billingProfileWrapper.PaymentMethod = component.get("v.selectedPaymentMethod");
            billingProfileWrapper.InvoiceDeliveryPref = component.get("v.invoicePreference");
            billingProfileWrapper.SEPAMandateType = component.get("v.radioModalPreference");
            component.set("v.showToastMessage",false);
            console.log('billingProfileWrapper: ' + JSON.stringify(billingProfileWrapper));
            helper.insertBillingProfile(component, event, helper, billingProfileWrapper);      
        }
        else component.set("v.showNewPaymentModal", false);
        console.log('TA_LCP234_PaymentMethod >> Helper >> modalButton >> Finish');
    },

    insertBillingProfile : function(component, event, helper, billingProfileWrapper) {
        console.log('TA_LCP234_PaymentMethod >> Helper >> selectPaymentMethod callback >> Start');
        
        let action = component.get('c.insertBillingProfile');
        action.setParams({
            'bpWrapper' : JSON.stringify(billingProfileWrapper)            
        });

        action.setCallback(this, function(response) {
            
            let result = JSON.parse(response.getReturnValue());
            if(response.getState() == "SUCCESS") {                
                console.log('wrReq: ' + JSON.stringify(result));
                let resultMessage = result.Result.Message;
                
                helper.fireToggleSpinnerEvent(component, false);
                if(billingProfileWrapper.PaymentMethod == 'Credit Card'){
                    component.set("v.showNewPaymentModal", true);
                }
                else{
                    component.set("v.showNewPaymentModal", false);
                    if(result.Result.ErrorCode != '0'){                   
                        console.log('resultMessage: ' + resultMessage);
                        component.set("v.toastMessage",resultMessage);
                        component.set("v.isError",true);
                        component.set("v.showToastMessage",true);
                    }
                    else {                   
                        console.log('resultMessage: ' + resultMessage);
                        component.set("v.toastMessage",resultMessage);
                        component.set("v.isError",false);
                        component.set("v.showToastMessage",true);
                    };       
                } 
                helper.initialize(component,event,helper, true);        
            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }
            console.log('TA_LCP234_PaymentMethod >> Helper >> selectPaymentMethod callback >> Finish');                      
        });    
        helper.fireToggleSpinnerEvent(component, true);
        $A.enqueueAction(action);        
    },

    updateOrderItemBillingProfile_old : function(component, event, helper) {
        console.log('TA_LCP234_PaymentMethod >> Helper >> updateOrderItemBillingProfile callback >> Start');
        let infoBag = component.get("v.infoBag");
        let billingProfileWrapper = component.get("v.billingProfileWrapper");
        let billingProfileId = component.get("v.billingProfileIdSelected");
        let paymentType = component.get("v.selectedPaymentMethod");
        let workOrderId = component.get("v.workOrder").Id;
        let action = component.get('c.updateOrderItemBillingProfile');
        let billingProfileLineItemIdSelected = component.get("v.billingProfileLineItemIdSelected");
        let parameters = event.getParam('params');
        
        if(!component.get("v.billingProfileLineItemIdSelected")) {
            console.log('NON VALIDATO');
            component.set("v.toastMessage",$A.get("$Label.c.TA_PaymentMethodRequired"));
            component.set("v.isError",true);
            component.set("v.showToastMessage",true);            
        }
        else {
            console.log('VALIDATO');
            action.setParams({
                'workOrderId' : workOrderId,
                'orderId' : billingProfileWrapper.OrderID,
                'orderItemId' : infoBag.orderItemId,
                // 'billingProfileId' : billingProfileId,
                'billingProfileLineItemId' : billingProfileLineItemIdSelected,
                'paymentType' :  paymentType,
                'parameters' : parameters
            });

            action.setCallback(this, function(response) {
                
                let result = JSON.parse(response.getReturnValue());
                if(response.getState() == "SUCCESS") {               
                    let resultMessage = result.Result.Message;                
                    if(result.Result.ErrorCode != '0'){                   
                        console.log('KO resultMessage: ' + resultMessage);
                        component.set("v.toastMessage",resultMessage);
                        component.set("v.isError",true);
                        component.set("v.showToastMessage",true);
                        helper.fireToggleSpinnerEvent(component, false);
                    }
                    else {                   
                        console.log('OK resultMessage: ' + resultMessage); 
                        //start fix [ADC] 08-02-2021
                        /*let manageNextPhaseEvt = $A.get("e.c:TA_LCE233_QuoteSummary");                            
                        manageNextPhaseEvt.setParams({
                            'action': 'goToNextPhase',
                            'params': {"buttonName": "Continue", "updateNextPhase": "true"},
                            'handlerCmpName' : 'TA_LCP199_ButtonSection'
                        });   
                        manageNextPhaseEvt.fire();                   
                        };                     
                        helper.fireToggleSpinnerEvent(component, false);  */ 

                        let createDocAction = component.get('c.createDoc'); 
                        console.log('@@@@ call createDoc');                        
                        createDocAction.setParams({                               
                                'orderId' : billingProfileWrapper.OrderID
                            });
                        createDocAction.setCallback(this, function(response) {
                            
                            if(response.getState() == "SUCCESS") {
                                console.log('@@@@ call createDoc SUCCESS');                                
                                console.log('@@@@ call createDoc docResult: ' + response.getReturnValue());                                
                            } else if(response.getState() == "ERROR") {
                                component.set("v.showToastMessage", true);
                                component.set("v.isError", true);
                                component.set("v.toastMessage", JSON.stringify(response.getError()));
                            }
                            let manageNextPhaseEvt = $A.get("e.c:TA_LCE233_QuoteSummary");                            
                                manageNextPhaseEvt.setParams({
                                    'action': 'goToNextPhase',
                                    'params': {"buttonName": "Continue", "updateNextPhase": "true"},
                                    'handlerCmpName' : 'TA_LCP199_ButtonSection'
                                });   
                            manageNextPhaseEvt.fire(); 
                            //helper.fireToggleSpinnerEvent(component, false); //ENXCRM-57 benjamin.geronimo 03/05/2021
                        });  
                        $A.enqueueAction(createDocAction);
                        //end fix [ADC] 08-02-2021                                       
                    };              
                          
                } else if(response.getState() == "ERROR") {
                    component.set("v.showToastMessage", true);
                    component.set("v.isError", true);
                    component.set("v.toastMessage", JSON.stringify(response.getError()));
                    helper.fireToggleSpinnerEvent(component, false);
                }
                console.log('TA_LCP234_PaymentMethod >> Helper >> updateOrderItemBillingProfile callback >> Finish');                      
            });    
            helper.fireToggleSpinnerEvent(component, true);
            $A.enqueueAction(action); 
        }       
    },

    updateOrderItemBillingProfile : function(component, event, helper) {
        console.log('TA_LCP234_PaymentMethod >> Helper >> updateOrderItemBillingProfile callback >> Start');
        let infoBag = component.get("v.infoBag");
        let billingProfileWrapper = component.get("v.billingProfileWrapper");
        let billingProfileId = component.get("v.billingProfileIdSelected");
        let paymentType = component.get("v.selectedPaymentMethod");
        let workOrderId = component.get("v.workOrder").Id;
        let updateOrderItemBillingProfile = component.get('c.updateOrderItemBillingProfile');
        let billingProfileLineItemIdSelected = component.get("v.billingProfileLineItemIdSelected");
        let parameters = event.getParam('params');
        
        if(!component.get("v.billingProfileLineItemIdSelected")) {
            component.set("v.toastMessage", $A.get("$Label.c.TA_PaymentMethodRequired"));
            component.set("v.isError", true);
            component.set("v.showToastMessage", true);            
        }
        else {
            updateOrderItemBillingProfile.setParams({
                'workOrderId' : workOrderId,
                'orderId' : billingProfileWrapper.OrderID,
                'orderItemId' : infoBag.orderItemId,
                'billingProfileLineItemId' : billingProfileLineItemIdSelected,
                'paymentType' : paymentType
            });

            updateOrderItemBillingProfile.setCallback(this, function(response) {     
                let result = JSON.parse(response.getReturnValue()).wrResp;
                if(response.getState() == "SUCCESS") {               
                    if(result.Result.ErrorCode != '0'){                  
                        component.set("v.toastMessage", result.Result.Message);
                        component.set("v.isError",true);
                        component.set("v.showToastMessage",true);
                        helper.fireToggleSpinnerEvent(component, false);
                    }
                    else {                   
                        let updateOrderItemBillingProfile_step2 = component.get('c.updateOrderItemBillingProfile_step2');                      
                        updateOrderItemBillingProfile_step2.setParams({ 
                            'wrRespSerialized' : JSON.stringify(JSON.parse(response.getReturnValue()).wrResp),
                            'wrReqSerialized' : JSON.stringify(JSON.parse(response.getReturnValue()).wrReq),
                            'workOrderId' : workOrderId,
                            'parameters' : parameters 
                        });
                        updateOrderItemBillingProfile_step2.setCallback(this, function(response) {  
                            if(response.getState() == "SUCCESS") {
                                let result = JSON.parse(response.getReturnValue());
                                if(result.Result.ErrorCode != '0'){                  
                                    component.set("v.toastMessage", result.Result.Message);
                                    component.set("v.isError",true);
                                    component.set("v.showToastMessage",true);
                                    helper.fireToggleSpinnerEvent(component, false);
                                } else {
                                    let createDocAction = component.get('c.createDoc');                        
                                    createDocAction.setParams({'orderId' : billingProfileWrapper.OrderID });
                                    createDocAction.setCallback(this, function(response) {
                                        if(response.getState() == "SUCCESS") {                      
                                            console.log('@@@@ SUCCESS - call createDoc docResult: ' + response.getReturnValue());                                
                                        } else if(response.getState() == "ERROR") {
                                            component.set("v.showToastMessage", true);
                                            component.set("v.isError", true);
                                            component.set("v.toastMessage", JSON.stringify(response.getError()));
                                        }
                                        let manageNextPhaseEvt = $A.get("e.c:TA_LCE233_QuoteSummary");                            
                                        manageNextPhaseEvt.setParams({
                                            'action': 'goToNextPhase',
                                            'params': {"buttonName": "Continue", "updateNextPhase": "true"},
                                            'handlerCmpName' : 'TA_LCP199_ButtonSection'
                                        });   
                                        manageNextPhaseEvt.fire(); 
                                    });  
                                    $A.enqueueAction(createDocAction);
                                }      
                            } else if(response.getState() == "ERROR") {
                                component.set("v.showToastMessage", true);
                                component.set("v.isError", true);
                                component.set("v.toastMessage", JSON.stringify(response.getError()));
                            }
                        });  
                        $A.enqueueAction(updateOrderItemBillingProfile_step2);                                 
                    };              
                          
                } else if(response.getState() == "ERROR") {
                    component.set("v.showToastMessage", true);
                    component.set("v.isError", true);
                    component.set("v.toastMessage", JSON.stringify(response.getError()));
                    helper.fireToggleSpinnerEvent(component, false);
                }
                console.log('TA_LCP234_PaymentMethod >> Helper >> updateOrderItemBillingProfile callback >> Finish');                      
            });    
            helper.fireToggleSpinnerEvent(component, true);
            $A.enqueueAction(updateOrderItemBillingProfile); 
        }       
    },

    fireSendInitStateEvt : function(component, isInitialized) {
        console.log('TA_LCP234_PaymentMethod >> Helper >> fireSendInitStateEvt >> Start');        
        let sendInitStateEvt = component.getEvent("sendInitStateEvt");
        sendInitStateEvt.setParams({
            "componentName" :  "TA_LCP234_PaymentMethod",
            "initState"   :  isInitialized
        });
        sendInitStateEvt.fire();
        console.log('TA_LCP234_PaymentMethod >> Helper >> fireSendInitStateEvt >> End');
    },

    fireToggleSpinnerEvent : function(component, toggleSpinner) {
        console.log('TA_LCP234_PaymentMethod >> Helper >> fireToggleSpinnerEvent >> Start');

        let toggleSpinnerEvent = component.getEvent("toggleSpinnerEvent");
        toggleSpinnerEvent.setParams({
            "sourceComponent" : "TA_LCP234_PaymentMethod",
            "toggleSpinner" : toggleSpinner
        });

        toggleSpinnerEvent.fire();
        console.log('TA_LCP234_PaymentMethod >> Helper >> fireToggleSpinnerEvent >> End');
    },

    isValidIBANNumber : function(input,helper) {
        /*
        * Returns 1 if the IBAN is valid 
        * Returns 0 if the IBAN's length is not as should be (for CY the IBAN Should be 28 chars long starting with CY )
        * Returns any other number (checksum) when the IBAN is invalid (check digits do not match)
        */
        console.log('isValidIBANNumber');
        let CODE_LENGTHS = {
            AD: 24, AE: 23, AT: 20, AZ: 28, BA: 20, BE: 16, BG: 22, BH: 22, BR: 29,
            CH: 21, CR: 21, CY: 28, CZ: 24, DE: 22, DK: 18, DO: 28, EE: 20, ES: 24,
            FI: 18, FO: 18, FR: 27, GB: 22, GI: 23, GL: 18, GR: 27, GT: 28, HR: 21,
            HU: 28, IE: 22, IL: 23, IS: 26, IT: 27, JO: 30, KW: 30, KZ: 20, LB: 28,
            LI: 21, LT: 20, LU: 20, LV: 21, MC: 27, MD: 24, ME: 22, MK: 19, MR: 27,
            MT: 31, MU: 30, NL: 18, NO: 15, PK: 24, PL: 28, PS: 29, PT: 25, QA: 29,
            RO: 24, RS: 22, SA: 24, SE: 24, SI: 19, SK: 24, SM: 27, TN: 24, TR: 26
        };
        let iban = String(input).toUpperCase().replace(/[^A-Z0-9]/g, ''), // keep only alphanumeric characters
                code = iban.match(/^([A-Z]{2})(\d{2})([A-Z\d]+)$/), // match and capture (1) the country code, (2) the check digits, and (3) the rest
                digits;
        console.log('iban: ' + iban);        
        // check syntax and length
        if (!code || iban.length !== CODE_LENGTHS[code[1]]) {
            console.log('false');   
            return false;
        }
        // rearrange country code and check digits, and convert chars to ints
        digits = (code[3] + code[1] + code[2]).replace(/[A-Z]/g, function (letter) {
            return letter.charCodeAt(0) - 55;
        });
        // final check
        return helper.mod97(digits);
    },
    mod97 : function(string) {
        console.log('mod97');
        let checksum = string.slice(0, 2), fragment;
        for (let offset = 2; offset < string.length; offset += 7) {
            fragment = String(checksum) + string.substring(offset, offset + 7);
            checksum = parseInt(fragment, 10) % 97;
        }       
        return checksum;
    },

    selectBillingAddress : function(component, event, helper) {
        console.log('TA_LCP234_PaymentMethod >> Helper >> selectBillingAddress >> Start');
        let action = component.get('c.selectBillingAddress');
        action.setParams({
            'infoBagSerialized' : JSON.stringify(component.get("v.infoBag")),
            'addressId' : component.get("v.billingAddressSelected")
        });

        action.setCallback(this, function(response) {
            console.log('TA_LCP234_PaymentMethod >> Helper >> selectBillingAddressCallback >> Start');
            if(response.getState() == "SUCCESS") {
                let infoBag = JSON.parse(response.getReturnValue());
                component.set("v.infoBag", infoBag);

                //START FIX [20210709AL]
                let paymentsAllowedList = infoBag.paymentsAllowedList;
                if(paymentsAllowedList) {
                    paymentsAllowedList.forEach(function(payment) {
                        if(payment.name == null) payment.selected = true;
                        else payment.selected = false;
                    });
                    infoBag.paymentsAllowedList = paymentsAllowedList;
                }
                //END FIX [20210709AL]

                component.set("v.billingAddressList", infoBag.billingAddressList);
                component.set("v.paymentsAllowedList", infoBag.paymentsAllowedList);
                component.set("v.billingProfileWrapper", infoBag.billingProfileWrapper);
                component.set("v.billingProfileLineItemMap", infoBag.billingProfileLineItemMap);
                //component.set("v.billingAddressSelected", '');
                component.set("v.selectedPaymentMethod", '');
                component.set("v.selectedBillingProfileLineItemList", []);
                component.set("v.billingProfileLineItemIdSelected", '');

            } else if(response.getState() == "ERROR") {
                component.set("v.showToastMessage", true);
                component.set("v.isError", true);
                component.set("v.toastMessage", JSON.stringify(response.getError()));
            }

            this.fireToggleSpinnerEvent(component, false);
            console.log('TA_LCP234_PaymentMethod >> Helper >> selectBillingAddressCallback >> End');
        });

        $A.enqueueAction(action);
        console.log('TA_LCP234_PaymentMethod >> Helper >> selectBillingAddress >> End');
    }
})