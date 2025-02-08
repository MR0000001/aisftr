({
    
    
    doInit : function (component, event, helper){
        console.log('MAP confItem-billing = '+JSON.stringify(component.get("v.mapbillingIds")));
        console.log('CONTACTID = '+component.get("v.contactId"));
        console.log('isComfy = '+component.get("v.isComfy"));
        // console.log('PAYMENT OPTS::: ' + component.get("v.paymentOptions"));
    
        let recordId = component.get("v.recordId");
        let mopList = component.get("v.availableMopsMap")[recordId];
        let paymentOptsList = [];
        let paymentFilter = $A.get("$Label.c.XC_CL_DueUponReceipt");
        if( component.get("v.paymentTermFilter") !== undefined){
            paymentFilter = component.get("v.paymentTermFilter");
            }
        for(let i=0; i<mopList.length; i++){
            paymentOptsList.push({"label" : mopList[i].mopLabel, "value" : mopList[i].mopValue});
        }
        component.set("v.paymentOptions",paymentOptsList);
        
        if(recordId in component.get("v.mapbillingIds")){
             component.set("v.billingId", component.get("v.mapbillingIds")[recordId]);
             if(recordId in component.get("v.mapOrderItemPayment")){
                let p = component.get("v.mapOrderItemPayment")[recordId];
                component.set("v.auraPaymentValue",p);
                if(!component.get("v.isBillToPartner")){
                    if(component.get("v.isB2B") && component.get("v.isItaly")){
                        if(component.get("v.isBillingAccountFilter")){
                            component.set("v.filter2", "XC_LegalEntity__c='"+component.get("v.legalEntityId")+"" 
                            +"' AND XC_PaymentMethod__c='"+p+"" 
                            +"' AND XC_BillToAddress__c='"+component.get("v.addressId")
                            +"' AND XC_PaymentTerm__c ='" + paymentFilter							 
                            +"' AND (XC_Status__c='"+ $A.get("$Label.c.XC_CL_Billing_Active") +"' OR XC_Status__c= '" +$A.get("$Label.c.XC_CL_Billing_WaitingExt") + "' OR XC_Status__c= 'Sent To Zuora' "  + ")");
                        } else {
                              component.set("v.filter2", "XC_SoldToContactId__c='"+component.get("v.contactId")+
                              "' AND XC_LegalEntity__c='"+component.get("v.legalEntityId")+"" 
                              +"' AND XC_PaymentMethod__c='"+p+"" 
                              +"' AND XC_BillToAddress__c='"+component.get("v.addressId")
                              +"' AND XC_SoldToAddress__c ='"+component.get("v.soldAddressId")
							  // [ BEGIN, mridul.b.jain@accenture.com, 06/01/2022, ID-1 Select Payment Method, NR2073, ENEL X - r12 ] -->      
							  +"' AND XC_PaymentTerm__c ='" + paymentFilter
							  // [ END, mridul.b.jain@accenture.com, 06/01/2022, ID-1 Select Payment Method, NR2073, ENEL X - r12 ] 
							  +"' AND (XC_Status__c='"+ $A.get("$Label.c.XC_CL_Billing_Active") +"' OR XC_Status__c= '" +$A.get("$Label.c.XC_CL_Billing_WaitingExt") + "' OR XC_Status__c= 'Sent To Zuora' "  + ")");
                        }
                    }else if(component.get("v.isB2B")){
                        if(component.get("v.isBillingAccountFilter")){
                            component.set("v.filter2", "XC_LegalEntity__c='"+component.get("v.legalEntityId")+"" 
                            +"' AND XC_PaymentMethod__c='"+p+"" 
                            +"' AND XC_BillToAddress__c='"+component.get("v.addressId")    
                            +"' AND (XC_Status__c='"+ $A.get("$Label.c.XC_CL_Billing_Active") +"' OR XC_Status__c= '" +$A.get("$Label.c.XC_CL_Billing_WaitingExt") + "' OR XC_Status__c= 'Sent To Zuora' "  + ")");
                        } else {
                              component.set("v.filter2", "XC_SoldToContactId__c='"+component.get("v.contactId")+
                              "' AND XC_LegalEntity__c='"+component.get("v.legalEntityId")+"" 
                              +"' AND XC_PaymentMethod__c='"+p+"" 
                              +"' AND XC_BillToAddress__c='"+component.get("v.addressId")
                              +"' AND XC_SoldToAddress__c ='"+component.get("v.soldAddressId")							 
							  +"' AND (XC_Status__c='"+ $A.get("$Label.c.XC_CL_Billing_Active") +"' OR XC_Status__c= '" +$A.get("$Label.c.XC_CL_Billing_WaitingExt") + "' OR XC_Status__c= 'Sent To Zuora' "  + ")");
                        }
                    }else{
                        if(component.get("v.isBillingAccountFilter")){
                            component.set("v.filter2", "XC_LegalEntity__c='"+component.get("v.legalEntityId")+"" 
                            +"' AND XC_PaymentMethod__c='"+p+"" 
                            +"' AND XC_BillToAddress__c='"+component.get("v.addressId")						 
                            +"' AND (XC_Status__c='"+ $A.get("$Label.c.XC_CL_Billing_Active") +"' OR XC_Status__c= '" +$A.get("$Label.c.XC_CL_Billing_WaitingExt") + "' OR XC_Status__c= 'Sent To Zuora' "  + ")");
                        } else {
                        component.set("v.filter2", "XC_SoldToContactId__c='"+component.get("v.contactId")+
                                "' AND XC_LegalEntity__c='"+component.get("v.legalEntityId")+"" 
                                +"' AND XC_PaymentMethod__c='"+p+"" 
                                +"' AND XC_BillToAddress__c='"+component.get("v.addressId")
                                +"' AND XC_SoldToAddress__c ='"+component.get("v.soldAddressId")
                                +"' AND (XC_Status__c='"+ $A.get("$Label.c.XC_CL_Billing_Active") +"' OR XC_Status__c= '" +$A.get("$Label.c.XC_CL_Billing_WaitingExt") + "' OR XC_Status__c= 'Sent To Zuora' "  + ")");
                        }
                    }
                }else{
                    component.set("v.filter2", 
                            " XC_LegalEntity__c='"+component.get("v.legalEntityId")+""
                            +"' AND XC_PaymentMethod__c='"+p+"" 
                            +"' AND XC_BillToAddress__c='"+component.get("v.addressId")
                            +"' AND (XC_Status__c='"+ $A.get("$Label.c.XC_CL_Billing_Active") +"' OR XC_Status__c= '" +$A.get("$Label.c.XC_CL_Billing_WaitingExt") + "' OR XC_Status__c= 'Sent To Zuora' "  + ")");
                }
                console.log('Filtro in init = '+component.get("v.filter2"));
                component.set("v.secondStrike", true);
				// [ BEGIN, mridul.b.jain@accenture.com, 06/01/2022, ID-1 Select Payment Method, NR2073, ENEL X - r12 ] -->      
                component.set("v.billingpaymentTerm", component.get("v.paymentTermFilter"));
                // [ END, mridul.b.jain@accenture.com, 06/01/2022, ID-1 Select Payment Method, NR2073, ENEL X - r12 ] -->      
            }
        }
            helper.checkPrepayment(component, event, helper);
            helper.checkOrderStatus(component, event, helper);
            helper.checkImpliedInterest(component, event, helper);
            //[START, gaurav.tejpal@accenture.com, 04/05/2022,Enel X - NR2187] -->
            if(component.get("v.isB2B") && component.get("v.isItaly")){
                helper.setFieldOfAttributes(component, event, helper);
            }
            //[ END, gaurav.tejpal@accenture.com, 04/05/2022,Enel X - NR2187] -->
        if(component.find('billModel').get('v.value') && (component.find('billModel').get('v.value')== 'Installment plan' ||  component.find('billModel').get('v.value')== 'Billing Plan')){
            component.set('v.showInstallmentPlan',true);

            //set default value 0.0 to installment rate
            let install_rate = component.find("installmentRate").get("v.value");

            if(install_rate === null){
                component.find("installmentRate").set("v.value","0.0");
            }
             
            //  if(component.get("v.isB2B") && component.get("v.isItaly")){
            //     component.find("installmentTax").set("v.value","No");
            //     }
                
        }else{
            component.set('v.showInstallmentPlan',false);
        }
    },
    
    //[ BEGIN, mridul.b.jain@accenture.com, 06/01/2022, ID-1 Select Payment Method, NR2073, ENEL X - r12 ]
    changePickValPayterm : function (component, event, helper){
        let selectedOptionValue = event.getParam("value");       
        let billingIdPaymentTerm = component.get("v.billingpaymentTerm"); 
        if(selectedOptionValue!=undefined && selectedOptionValue!=''){
            component.set("v.paymentTermFilter", selectedOptionValue);
            console.log("billingIdPaymentTerm :: "+ billingIdPaymentTerm);
            console.log('selectedOptionValue------> '+selectedOptionValue);           
            console.log('FILTRO CON contactId = '+component.get("v.contactId")+' E');
            console.log('legalEntity = '+component.get("v.legalEntityId") );

            if(billingIdPaymentTerm == selectedOptionValue){
                let recordId = component.get("v.recordId");
                component.set("v.billingId", component.get("v.mapbillingIds")[recordId]);
            }
            else{
                component.set("v.billingId",'');
            }   
            let c = component.get("v.contactId");
            let l = component.get("v.legalEntityId");
            let p = component.get("v.auraPaymentValue");
            let a = component.get("v.addressId");
            let filtroFinal
            
            if(!component.get("v.isBillToPartner")){
                if(component.get("v.isB2B")){
                    if(component.get("v.isBillingAccountFilter")){
                        filtroFinal= "XC_LegalEntity__c='"+l+"" 
                        +"' AND XC_PaymentMethod__c='"+p+"" 
                        +"' AND XC_BillToAddress__c='"+a
                        +"' AND XC_PaymentTerm__c ='" + component.get("v.paymentTermFilter")
                        +"' AND (XC_Status__c='"+ $A.get("$Label.c.XC_CL_Billing_Active") +"' OR XC_Status__c = '"+$A.get("$Label.c.XC_CL_Billing_WaitingExt") + "' OR XC_Status__c= 'Sent To Zuora' " + ")";
                    } else {
                        filtroFinal= "XC_SoldToContactId__c='"+c
                        +"' AND XC_LegalEntity__c='"+l+"" 
                        +"' AND XC_PaymentMethod__c='"+p+"" 
                        +"' AND XC_BillToAddress__c='"+a
                        +"' AND XC_SoldToAddress__c ='"+component.get("v.soldAddressId")
                        // [ BEGIN, mridul.b.jain@accenture.com, 06/01/2022, ID-1 Select Payment Method, NR2073, ENEL X - r12 ]
                        +"' AND XC_PaymentTerm__c ='" + component.get("v.paymentTermFilter")
                        // [ END, mridul.b.jain@accenture.com, 06/01/2022, ID-1 Select Payment Method, NR2073, ENEL X - r12 ]
                        +"' AND (XC_Status__c='"+ $A.get("$Label.c.XC_CL_Billing_Active") +"' OR XC_Status__c = '"+$A.get("$Label.c.XC_CL_Billing_WaitingExt") + "' OR XC_Status__c= 'Sent To Zuora' " + ")";
                    }
                }else{
                    if(component.get("v.isBillingAccountFilter")){
                        filtroFinal= "XC_LegalEntity__c='"+l+"" 
                        +"' AND XC_PaymentMethod__c='"+p+"" 
                        +"' AND XC_BillToAddress__c='"+a
                        +"' AND (XC_Status__c='"+ $A.get("$Label.c.XC_CL_Billing_Active") +"' OR XC_Status__c = '"+$A.get("$Label.c.XC_CL_Billing_WaitingExt") + "' OR XC_Status__c= 'Sent To Zuora' " + ")";
                    } else {
                        filtroFinal= "XC_SoldToContactId__c='"+c
                        +"' AND XC_LegalEntity__c='"+l+"" 
                        +"' AND XC_PaymentMethod__c='"+p+"" 
                        +"' AND XC_BillToAddress__c='"+a
                        +"' AND XC_SoldToAddress__c ='"+component.get("v.soldAddressId")
                        +"' AND (XC_Status__c='"+ $A.get("$Label.c.XC_CL_Billing_Active") +"' OR XC_Status__c = '"+$A.get("$Label.c.XC_CL_Billing_WaitingExt") + "' OR XC_Status__c= 'Sent To Zuora' " + ")";
                    }
                }
            }else{
                 filtroFinal = 
            " XC_LegalEntity__c='"+l+"" 
            +"' AND XC_PaymentMethod__c='"+p+"" 
            +"' AND XC_BillToAddress__c='"+a
            +"' AND (XC_Status__c='"+ $A.get("$Label.c.XC_CL_Billing_Active") +"' OR XC_Status__c = '"+$A.get("$Label.c.XC_CL_Billing_WaitingExt") + "' OR XC_Status__c= 'Sent To Zuora' "  + ")";
            }
            //TODO: change filter for recurring SEPA
            //Start EA TPB 13/10/2021
            if(p == 'Commodity Bill'){
                var attValue = component.get("v.partnerCode");
                console.log('EA NE__Value__c  = '+attValue) ;
                if(attValue == ''){
                    filtroFinal = "XC_TPBCode__c ="+null+" AND "+ filtroFinal;
                }
                else{
                    filtroFinal = "XC_TPBCode__c = '"+attValue +"' AND "+ filtroFinal;
                }
            }
            //<End EA TPB 13/10/2021

            if(component.find('billModel').get('v.value')){
                let billModel = component.find('billModel').get('v.value');
                if(p == 'Direct Debt'){

                    if(billModel == 'Recurring'){
                        filtroFinal = "XC_MandateType__c = 'RECURRENT' AND "+ filtroFinal;
                    }
                }
            }
            console.log('Filtro in changePickVal = '+filtroFinal) ;
            component.set("v.filter3", filtroFinal);
            component.set("v.secondStrike", false);
            helper.sendEvent(component, event, helper);
        }
    },       
    //[ End, mridul.b.jain@accenture.com, 06/01/2022, ID-1 Select Payment Method, NR2073, ENEL X - r12 ]
   
	changePickVal : function (component, event, helper){
        
        let selectedOptionValue = event.getParam("value");
        if(selectedOptionValue!=undefined && selectedOptionValue!=''){
            component.set("v.payment", selectedOptionValue);
            console.log('FILTRO CON contactId = '+component.get("v.contactId")+' E');
            console.log('legalEntity = '+component.get("v.legalEntityId") );
            let c = component.get("v.contactId");
            let l = component.get("v.legalEntityId");
            let p = component.get("v.payment");
            let a = component.get("v.addressId");
            let filtroFinal 
            
            if(!component.get("v.isBillToPartner")){
                if(component.get("v.isB2B") && component.get("v.isItaly")){
                    let paymentFilter = $A.get("$Label.c.XC_CL_DueUponReceipt");
                    if( component.get("v.paymentTermFilter") !== undefined){
                        paymentFilter = component.get("v.paymentTermFilter");
                    }
                    if(component.get("v.isBillingAccountFilter")){
                        filtroFinal= "XC_LegalEntity__c='"+l+"" 
                                       +"' AND XC_PaymentMethod__c='"+p+"" 
                                       +"' AND XC_BillToAddress__c='"+a
                                       +"' AND XC_PaymentTerm__c ='" + paymentFilter
                                       +"' AND (XC_Status__c='"+ $A.get("$Label.c.XC_CL_Billing_Active") +"' OR XC_Status__c = '"+$A.get("$Label.c.XC_CL_Billing_WaitingExt") + "' OR XC_Status__c= 'Sent To Zuora' " + ")";
                    } else {
                    filtroFinal= "XC_SoldToContactId__c='"+c
                                       +"' AND XC_LegalEntity__c='"+l+"" 
                                       +"' AND XC_PaymentMethod__c='"+p+"" 
                                       +"' AND XC_BillToAddress__c='"+a
                                       +"' AND XC_PaymentTerm__c ='" + paymentFilter
                                       +"' AND (XC_Status__c='"+ $A.get("$Label.c.XC_CL_Billing_Active") +"' OR XC_Status__c = '"+$A.get("$Label.c.XC_CL_Billing_WaitingExt") + "' OR XC_Status__c= 'Sent To Zuora' " + ")";
                    }
                        
                }else if(component.get("v.isB2B")){
                    if(component.get("v.isBillingAccountFilter")){
                        filtroFinal= "XC_LegalEntity__c='"+l+"" 
                        +"' AND XC_PaymentMethod__c='"+p+"" 
                        +"' AND XC_BillToAddress__c='"+a                   
                        +"' AND (XC_Status__c='"+ $A.get("$Label.c.XC_CL_Billing_Active") +"' OR XC_Status__c = '"+$A.get("$Label.c.XC_CL_Billing_WaitingExt") + "' OR XC_Status__c= 'Sent To Zuora' " + ")";
                    }else{
                        filtroFinal= "XC_SoldToContactId__c='"+c
                        +"' AND XC_LegalEntity__c='"+l+"" 
                        +"' AND XC_PaymentMethod__c='"+p+"" 
                        +"' AND XC_BillToAddress__c='"+a
                        +"' AND XC_SoldToAddress__c ='"+component.get("v.soldAddressId")                    
                        +"' AND (XC_Status__c='"+ $A.get("$Label.c.XC_CL_Billing_Active") +"' OR XC_Status__c = '"+$A.get("$Label.c.XC_CL_Billing_WaitingExt") + "' OR XC_Status__c= 'Sent To Zuora' " + ")";
                    }
                }else{
                    if(component.get("v.isBillingAccountFilter")){
                        filtroFinal= "XC_LegalEntity__c='"+l+"" 
                        +"' AND XC_PaymentMethod__c='"+p+"" 
                        +"' AND XC_BillToAddress__c='"+a
                        +"' AND (XC_Status__c='"+ $A.get("$Label.c.XC_CL_Billing_Active") +"' OR XC_Status__c = '"+$A.get("$Label.c.XC_CL_Billing_WaitingExt") + "' OR XC_Status__c= 'Sent To Zuora' " + ")";        
                    } else {
                        filtroFinal= "XC_SoldToContactId__c='"+c
                        +"' AND XC_LegalEntity__c='"+l+"" 
                        +"' AND XC_PaymentMethod__c='"+p+"" 
                        +"' AND XC_BillToAddress__c='"+a
                        +"' AND XC_SoldToAddress__c ='"+component.get("v.soldAddressId")
                        +"' AND (XC_Status__c='"+ $A.get("$Label.c.XC_CL_Billing_Active") +"' OR XC_Status__c = '"+$A.get("$Label.c.XC_CL_Billing_WaitingExt") + "' OR XC_Status__c= 'Sent To Zuora' " + ")";
                    }
                }
            }else{
                filtroFinal = 
                " XC_LegalEntity__c='"+l+"" 
                +"' AND XC_PaymentMethod__c='"+p+"" 
                +"' AND XC_BillToAddress__c='"+a
                +"' AND (XC_Status__c='"+ $A.get("$Label.c.XC_CL_Billing_Active") +"' OR XC_Status__c = '"+$A.get("$Label.c.XC_CL_Billing_WaitingExt") + "' OR XC_Status__c= 'Sent To Zuora' "  + ")";
            }
            //TODO: change filter for recurring SEPA

            if(component.find('billModel').get('v.value')){
                let billModel = component.find('billModel').get('v.value');
                if(p == 'Direct Debt'){

                    if(billModel == 'Recurring'){
                        filtroFinal = "XC_MandateType__c = 'RECURRENT' AND "+ filtroFinal;
                    }
                }
            }
            console.log('Filtro in changePickVal = '+filtroFinal) ;
            component.set("v.filter3", filtroFinal);
            component.set("v.secondStrike", false);
            helper.sendEvent(component, event, helper);
        }
        
    },
    
    sendEvent : function (component, event, helper){
        helper.sendEvent(component, event, helper);
    },

    onBillToAddressChange : function(component,event,helper){

        if(component.get("v.filter3") && component.get("v.payment")){
            
            console.log('CHANGE ON BILL TO ADDRESS');

            let c = component.get("v.contactId");
            let l = component.get("v.legalEntityId");
            let p = component.get("v.payment");
            let a = component.get("v.addressId");
            let filtroFinal = 
            "XC_SoldToContactId__c='"+c
            +"' AND XC_LegalEntity__c='"+l+"" 
            +"' AND XC_PaymentMethod__c='"+p+"" 
            +"' AND XC_BillToAddress__c='"+a
            +"' AND XC_SoldToAddress__c ='"+component.get("v.soldAddressId")            
            +"' AND (XC_Status__c='"+ $A.get("$Label.c.XC_CL_Billing_Active") +"' OR XC_Status__c = '"+$A.get("$Label.c.XC_CL_Billing_WaitingExt") + "' OR XC_Status__c= 'Sent To Zuora' "  + ")";

            if(component.get("v.isB2B") && component.get("v.isItaly")){
                if(component.get("v.isBillingAccountFilter")){
                    filtroFinal = "XC_LegalEntity__c='"+l+"" 
                    +"' AND XC_PaymentMethod__c='"+p+"" 
                    +"' AND XC_BillToAddress__c='"+a
                    +"' AND (XC_Status__c='"+ $A.get("$Label.c.XC_CL_Billing_Active") +"' OR XC_Status__c = '"+$A.get("$Label.c.XC_CL_Billing_WaitingExt") + "' OR XC_Status__c= 'Sent To Zuora' "  + ")";
                } else {
                    filtroFinal ="XC_SoldToContactId__c='"+c
                    +"' AND XC_LegalEntity__c='"+l+"" 
                    +"' AND XC_PaymentMethod__c='"+p+"" 
                    +"' AND XC_BillToAddress__c='"+a
                    +"' AND XC_SoldToAddress__c ='"+component.get("v.soldAddressId")
                    // [ BEGIN, mridul.b.jain@accenture.com, 06/01/2022, ID-1 Select Payment Method, NR2073, ENEL X - r12 ]
                    +"' AND XC_PaymentTerm__c ='" + component.get("v.paymentTermFilter")
                    // [ END, mridul.b.jain@accenture.com, 06/01/2022, ID-1 Select Payment Method, NR2073, ENEL X - r12 ]
                    +"' AND (XC_Status__c='"+ $A.get("$Label.c.XC_CL_Billing_Active") +"' OR XC_Status__c = '"+$A.get("$Label.c.XC_CL_Billing_WaitingExt") + "' OR XC_Status__c= 'Sent To Zuora' "  + ")";
                }
                    
            }
            
            if(component.find('billModel').get('v.value')){
                let billModel = component.find('billModel').get('v.value');
                if(p == 'Direct Debt'){

                        if(billModel == 'Recurring'){
                            filtroFinal = "XC_MandateType__c = 'RECURRENT' AND "+ filtroFinal;
                        }
                    }
                }
                console.log('Filtro in changePickVal onchangebillto = '+filtroFinal) ;
                component.set("v.filter3", filtroFinal);
                component.set("v.secondStrike", false);

        
        }
    }
    
})