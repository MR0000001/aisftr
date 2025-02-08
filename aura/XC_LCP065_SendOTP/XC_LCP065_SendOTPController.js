({
	change : function(component, event, helper) {
       var selectedOptionValue = event.getParam("value");
        
        component.set("v.disabledSubmit", false );
        if(selectedOptionValue=='SMS'){
            component.set("v.customerTypeValue", 'Order_OTP_SMS' );
            helper.populateSMS(component, event, helper);
        }else if(selectedOptionValue=='Email'){
            component.set("v.customerTypeValue", 'Order_OTP_Email' );
            helper.populateEmail(component, event, helper);
        }else{}
		
	},
    disableMail :  function(component, event, helper) {
        var selectedOptionValue = event.getParam("value");
         if(selectedOptionValue==""){
             component.set("v.disabledSubmit", true );
         }else{
             component.set("v.disabledSubmit", false );
         }
        
    },
    
     closeModal :  function(component, event, helper) {
         $A.get("e.force:closeQuickAction").fire();
    },
    
     create :  function(component, event, helper) {
         helper.createCustomer(component, event, helper);
    }
    
})