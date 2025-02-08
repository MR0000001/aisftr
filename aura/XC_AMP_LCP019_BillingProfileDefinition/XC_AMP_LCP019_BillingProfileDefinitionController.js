({
	init : function(component, event, helper) {
		helper.init(component, event, helper);
	},

    checkValue :  function(component, event, helper) {
        helper.checkValue(component, event, helper);
    },

    displayCreateSection :  function(component, event, helper) {
        var button = event.getSource();
        button.set('v.disabled',true);
        component.set("v.disabledSubmit", true);
        component.set("v.showCreateSection",true);
        component.set("v.valueMap.billingProfileLineItem",undefined);
    },

    selectBillingProfileLineItem :  function(component, event, helper) {
        component.set("v.showCreateSection",false);
        helper.checkValue(component, event, helper);
    },
    
    checkPayment : function(component, event, helper) {

        component.set("v.showDirectDebt", false);
        component.set("v.showCommodity", false);
        component.set("v.showCreditCard", false);
        component.set("v.showExtFinancing",false);
        component.set("v.valueMap.billingProfileLineItem",undefined);
        component.set("v.paymentMethodTypeSelected",true);
        component.set("v.showCreateSection",false);
        component.set("v.disabledSubmit", true);

        var selectedOptionValue = event.getParam("value");
        if(selectedOptionValue && selectedOptionValue === 'Commodity Bill'){
            component.set("v.billingProfiles", component.get("v.commodity"));
            component.set("v.showCommodity", true);
            if(component.get("v.getContractBy") === 'IdentityDoc'){
                helper.getB2CCommodityContract(component,event,helper);
            }else if(component.get("v.getContractBy") === 'POS'){
                helper.retrieveCups(component, event, helper);
            }

        }else if(selectedOptionValue==='Direct Debt') {
            component.set("v.billingProfiles", component.get("v.direct"));
            component.set("v.showDirectDebt", true);
        }else if(selectedOptionValue==='External Financing') {
            component.set("v.billingProfiles", component.get("v.external"));
            component.set("v.showExtFinancing",true);
        }else if(selectedOptionValue==='Credit Card') {
            component.set("v.billingProfiles", component.get("v.credit"));
        }else if(selectedOptionValue==='Bank Transfer') {
            component.set("v.billingProfiles", component.get("v.bank"));
        }

        var availBillProfiles = component.get("v.billingProfilesMap")[selectedOptionValue];
        component.set("v.availableBillProfiles", availBillProfiles);
        
        //get dependent payment category value based on choosen mop
        helper.getPaymentMethodCategory(component, event, helper);

        helper.checkValue(component, event, helper);
    },

    checkExternalFinancing : function(component,event,helper){
        if(component.get("v.institutePickVal")){
            if(component.get("v.institutePickVal") === 'Other') {
                component.set("v.showOtherExtFinancing",true);
            }else{
                component.set("v.showOtherExtFinancing",false);
            }
        }
        helper.checkValue(component,event,helper);
    },

    onChooseCommodityContract : function(component,event,helper) {
        helper.onChooseCommodityContract(component,event,helper);
    }
    
})