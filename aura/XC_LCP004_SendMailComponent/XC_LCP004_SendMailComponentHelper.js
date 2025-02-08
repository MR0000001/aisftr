({
    sendMailHelper : function(component, event) {
        console.log('@@@ in helperSendMail');
        let action = component.get("c.sendMailtoCustomer");
        // Modifica Salvatore Agrillo (06/05/2019)
        let mapCustomer = {
            'emailId' : component.get('v.emailId'),
            'to' : component.get('v.toField'),
            'fromMail' : component.get('v.fromField'),
            'bcc' : component.get('v.bccField'),
            'subj' : component.get('v.subjField'),
            'body' : component.get('v.bodyField'),
            'retatedToId' : component.get('v.recordId')
        }
        console.log('@@@ emailId ---> ', component.get('v.emailId'));
        console.log('@@@ mapCustomer ---> ', mapCustomer);
        let mapCustomerString = JSON.stringify(mapCustomer);
        action.setParams({
            'mapCustomerString': mapCustomerString
        });

        action.setCallback(this, function(response){
            let result =  response.getReturnValue();
            console.log('@@@ result sendMailtoCustomer ---> ', result);
            if(result == 'OK'){
                component.set('v.toField', component.get('v.accountAddress'));
                component.set('v.subjField', "");
                component.set('v.bccField', "");
                component.set('v.bodyField', "");
                
                let toastEvent = $A.get("e.force:showToast");
                console.log('result:' + result)
                toastEvent.setParams({
                message: $A.get("$Label.c.XC_CL_EmailSentMessage"),
                type: "success"
                });
                toastEvent.fire();
                

            }
             else{
               let toastEventCustomMail = $A.get("e.force:showToast");
                console.log('@@@toastEvent@@@:' + toastEvent)
                toastEventCustomMail.setParams({
                message: $A.get("$Label.c.XC_CL_InsertCustomerEmailMessage"),
                type: "error"
                });
                toastEventCustomMail.fire();
                }
        });
        $A.enqueueAction(action);
        
    },
    
    
    doInit : function(component, event) {
        console.log('@@@ in helperSendMail');
        let action = component.get("c.insertEmailMessage");
         action.setParams({ 
            "relatedToObj"		:  component.get('v.recordId')
        });
        action.setCallback(this, function(response){
            let result =  JSON.parse(response.getReturnValue());
            console.log('@@@ result init ---> ' + response.getReturnValue());
            component.set('v.emailId', result["id"]);
            component.set('v.toField', result["ToAddress"]);
            component.set('v.accountAddress', result["ToAddress"]);
        });
        $A.enqueueAction(action);
        
    }
})