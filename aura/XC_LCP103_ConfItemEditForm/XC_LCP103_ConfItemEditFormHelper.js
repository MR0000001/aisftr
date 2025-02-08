({
	 sendEvent : function (component, event, helper){
       if( component.get("v.billingId")!=undefined && component.get("v.billingId") != "" ){
        	component.set("v.setReadOnly", true);
       }else{
            component.set("v.setReadOnly", false);
       }
          if(component.find("auraPayment") && component.find("auraPayment").get("v.value")!=undefined){
             component.set("v.payment" , component.find("auraPayment").get("v.value"));
          }else if( component.get("v.showCustomPaymentMethod")){
              component.set("v.payment" ,  component.get("v.auraPaymentValue"));
          }
        let cmpEvent = $A.get("e.c:XC_LCE002_SendConfigurationItemValues");
        var payment = component.get("v.payment");

        let installmentType = component.find("installmentType");
        let installmentTax = component.find("installmentTax");
        let installmentFreq = component.find("installmentFreq");
        let installmentNum = component.find("installmentNum");
        let installmentRate = component.find("installmentRate");
        let interestIndex = component.find("interestIndex");

        let impliedInterest = component.find("impliedInterest");


        let installmentPlanFields = component.get("v.installmentPlanFields");
        if(installmentType && installmentTax && installmentFreq && installmentNum && installmentRate){
            var value = installmentRate.get("v.value");
            var regexp = /^\d+\.\d{0,2}$/;
            if(value && !value.match(regexp)) {
                $A.util.addClass(installmentRate, 'slds-has-error');
                return;
            }else{
                $A.util.removeClass(installmentRate, 'slds-has-error');
            }
            installmentPlanFields['installmentType'] = installmentType.get("v.value");
            installmentPlanFields['installmentTax'] = installmentTax.get("v.value");
            installmentPlanFields['installmentFreq'] = installmentFreq.get("v.value");
            installmentPlanFields['installmentNum'] = installmentNum.get("v.value");
            installmentPlanFields['installmentRate'] = installmentRate.get("v.value");
            installmentPlanFields['interestIndex'] = interestIndex.get("v.value");
            //alert(JSON.stringify(installmentPlanFields));
        }
        if(impliedInterest){
            installmentPlanFields['impliedInterest'] = impliedInterest.get("v.value");
        }


       if(payment!= undefined){
            cmpEvent.setParams({
                "recordId" : component.get("v.recordId"),
                "paymentMethod" : payment,
                "billingProfile" :  component.get("v.billingId"),
                "installmentPlanFields" : JSON.stringify(installmentPlanFields)
            });
            cmpEvent.fire();
        }    
        
    },

    //[START, gaurav.tejpal@accenture.com, 04/05/2022,Enel X - NR2187] -->
  setFieldOfAttributes: function (component, event, helper) {
    var action = component.get("c.getFieldOfAttributes");
    action.setParams({
      confItemId: component.get("v.recordId"),
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      var res = response.getReturnValue();
      if (res != null) {
        var fieldAttributes = JSON.parse(res);
        component.find("installmentTax").set("v.value", "no");
        component
          .find("installmentType")
          .set("v.value", fieldAttributes.Installment_Plan_Type);
        component
          .find("installmentFreq")
          .set("v.value", fieldAttributes.Installment_Frequency);
        component
          .find("installmentNum")
          .set("v.value", fieldAttributes.Number_Of_Installments);
      } else {
        console.log("Error: couldn't retrive Order Attribute");
      }
    });
    $A.enqueueAction(action);
  },
  //[END, gaurav.tejpal@accenture.com, 04/05/2022,Enel X - NR2187] -->
    
     checkPrepayment : function (component, event, helper){
        let recordId = component.get("v.recordId");
        let action = component.get("c.checkPrepayment");
        action.setParams( {
            'confItemId' : recordId
            
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            let retValue = response.getReturnValue();
            if (state === "SUCCESS" && retValue!==null) {
                if(!retValue.success){
                    console.log('PrePayment = 0');
                    component.set("v.showSpinner",false);
                }
                else{
                    // component.set("v.showCustomPaymentMethod", true);
                    // var opts = [];
                    // var paymentOptions = JSON.parse(retValue.fieldName);
                    // for (var i = 0; i < paymentOptions.length; i++) {
                    //     opts.push({
                            
                    //         value: paymentOptions[i],
                    //         label: paymentOptions[i]
                    //     });
                    // }
                    // component.set('v.paymentOptions', opts);
                    // if(paymentOptions.length==1){
                    //     component.set('v.auraPaymentValue', opts[0].value);  
                    //     component.set('v.onlyOnePickValue', true); 
                    // }
                    component.set("v.showSpinner",false);
                    
                   
                    
                }
            }
        });       
        $A.enqueueAction(action);   
        
        
    },
    
    checkOrderStatus : function (component, event, helper){
        var action = component.get("c.checkOrderStatus");       
        action.setParams({
            'confItemId': component.get("v.recordId")
        }); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            var res = response.getReturnValue();
            
            if(state=='SUCCESS'){               
                component.set("v.paymentMethodReadOnly", res);               
            } else {
                console.log("Error: couldn't retrive the Order Status");	
            }
        });
        
        $A.enqueueAction(action);  
    },

    checkImpliedInterest : function (component, event, helper){
            var action = component.get("c.checkImpliedInterest");
            action.setParams({
                'confItemId': component.get("v.recordId")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                var res = response.getReturnValue();

                if(state=='SUCCESS'){
                    component.set("v.showImpliedInterest", res);
                } else {
                    console.log("Error: couldn't retrive Impied Interest");
                }
            });

            $A.enqueueAction(action);
        },

        //Start EA TPB 13/10/2021
        checkPartnerCode : function (component, event, helper){
            console.log("EA checkPartnerCode");
            var action = component.get("c.checkPartnerCode");
            action.setParams({
                'confItemId': component.get("v.recordId")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                var res = response.getReturnValue();

                if(state=='SUCCESS'){
                    component.set("v.partnerCode", res);
                } else {
                    console.log("Error: couldn't retrive Order Attribute");
                }
            });

            $A.enqueueAction(action);
        }
        //End EA TPB 13/10/2021
})