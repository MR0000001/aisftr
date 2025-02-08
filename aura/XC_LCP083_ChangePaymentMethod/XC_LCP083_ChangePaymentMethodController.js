({
	doInit : function(component, event, helper) {
		helper.init(component, event, helper);
	},

    checkValues : function(component, event, helper) {
        helper.checkValues(component, event, helper);
    },
    
    create :  function(component, event, helper) {
        component.set("v.showSpinner", true);
        let paymentMethodType = component.get("v.payment");
        let valueMap = component.get("v.valueMap");
        valueMap['payment'] = paymentMethodType;


        console.log('@@@@ CALL createPaymentMethod > ' + JSON.stringify(valueMap));
        // let zuoraAccountId = component.get("v.zuoraAccountId");
        // console.log('@@@@ zuoraAccountId = ' + zuoraAccountId);
        // let accountCountry = component.get("v.accountCountry");
        //console.log('@@@@ accountCountry => ' + accountCountry);
        helper.updateCurrentBillingProfile(component, event, helper);
    },
    
    closeModal : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();                    
    },
    
    onChangeMOP : function(component,event,helper){

        let choosenMop = component.find("comboboxpayment").get("v.value");

        if(choosenMop!="Direct Debt"){
            component.set("v.showSEPA",false);
        }

    }
})