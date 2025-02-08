({
	populateEmail : function(component, event, helper) {
        
        var action = component.get("c.retrieveEmail");
        action.setParams({
            'recordId' : component.get("v.recordId")
            });
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS"){
                var result = a.getReturnValue();
                if(result!=''){
                    component.set("v.emailValue", result );
                    
                   }
                component.set("v.showPhone",false);
                component.set("v.showEmail",true);
                
            }
        });
        $A.enqueueAction(action);
        
    },
		
	
    
    
    populateSMS : function(component, event, helper) {
        var action = component.get("c.retrievePhoneNumber");
        action.setParams({
            'recordId' : component.get("v.recordId")
            });
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS"){
                var result = a.getReturnValue();
                if(result!=''){
                    component.set("v.phoneValue", result );
                }
                component.set("v.showPhone",true);
                component.set("v.showEmail",false);
                
            }
        });
        $A.enqueueAction(action);
        
		
	},
    
    
    createCustomer :  function(component, event, helper) {
        if(component.get("v.showPhone") && component.get("v.phoneValue") == undefined){
            helper.showErrorOnField(component,'phone');
        }
        if(component.get("v.showEmail") && component.get("v.emailValue") == undefined){
             helper.showErrorOnField(component,'email');
        }
         component.set("v.customerInteraction", {    		
                                              customerType : component.get("v.customerTypeValue"),
         									  orderId : component.get("v.recordId"),
         									  skipComunication : false,
         									  isAccountRequired : true,
             								  isSMS : component.get("v.showPhone"),
             								  newMobilePhone : component.get("v.phoneValue"),
             								  newEmail : component.get("v.emailValue")
                                              } )
         
        var action = component.get("c.newEmailForCustomer");
        var customerInteraction = component.get("v.customerInteraction");
         action.setParams({
                'interactionValues' : JSON.stringify(customerInteraction)
            });
            action.setCallback(this, function(a) {
                var state = a.getState();
                  if (state === "SUCCESS"){
                    var result = a.getReturnValue();
                      if(result.success){
                           helper.showToast(component, event, helper, result.resultMessage, "success");
                      }else{ 
                          if(result.resultMessage == $A.get("$Label.c.XC_CL_CustomerInt_MobilePhone")){
                              helper.showErrorOnField(component,'phone');
                          }
                           helper.showToast(component, event, helper, result.resultMessage, "error");
                      }
         
        
        
                  }
                    
                      });
            $A.enqueueAction(action); 
    },
    
    showErrorOnField : function(component, fieldName){  
        
        var cmpTarget = component.find(fieldName);
        console.log('result.fieldName->' + fieldName);
        $A.util.addClass(cmpTarget, 'slds-has-error ');
    },
    
     showToast : function(component, event, helper, message, type) {
        component.find('notifLib').showToast({
            "title": message,
            "message": '',
            "variant": type
        });
         if(type=="success"){
         $A.get("e.force:closeQuickAction").fire();
         }
    }
    
})