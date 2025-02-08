({
	init : function(component, event, helper) {
        
        let action = component.get("c.setTypeAndReason");
        action.setParams({
            'configurationId' : component.get("v.recordId")
        });
        action.setCallback(this, function(a) {
            let state = a.getState();
            if (state === "SUCCESS"){
                let result = a.getReturnValue();
                console.log('result='+result.success);              
                if(result.success){
                    var opts = [];
                    var opts2 = [];
                    var availableReason = JSON.parse(result.fieldName);
                    var availableType = JSON.parse(result.fieldName2);
                    var contactSelectionDisabled = JSON.parse(result.fieldName3);
                    for (var i = 0; i < availableReason.length; i++) {
                        opts.push({
                        value: availableReason[i],
                        label: availableReason[i]
                        });
                    }
                    for (var i = 0; i < availableType.length; i++) {
                        opts2.push({
                        value: availableType[i],
                        label: availableType[i]
                        });
                    }
        		component.set('v.typeOptions', opts2);
                component.set('v.reasonOptions', opts);
                component.set("v.showSpinner" , false);
                component.set('v.contactSelectionDisabled', contactSelectionDisabled == true);
                } else {
                    console.log('result error='+result.resultMessage);
                    helper.showToast(component, event, helper, result.resultMessage, 'error');
                    $A.get("e.force:closeQuickAction").fire();
                } 
                   
                
            }
        });            
        $A.enqueueAction(action);
		
	},
    
    changeOwner :  function(component, event, helper) {
        if(component.find('relatedContact')){
            component.set("v.showSpinner" , true);
            let action = component.get("c.changeOwnerAndContactOnOrder");
            action.setParams({
                'configurationId' : component.get("v.recordId"),
                'accountId' : component.get("v.accountId"),
                'reason' : component.get("v.reasonValue"),
                'type' :  component.get("v.typeValue"),
                'contactId': component.find("relatedContact").get("v.value")
            });
            action.setCallback(this, function(a) {
                let state = a.getState();
                if (state === "SUCCESS"){
                    let result = a.getReturnValue();
                    console.log('result='+result.success);              
                    if(result.success){
                        helper.showToast(component, event, helper, result.resultMessage, 'success');
                        $A.get('e.force:refreshView').fire();
                    }else {
                        console.log('result error='+result.resultMessage);
                        helper.showToast(component, event, helper, result.resultMessage, 'error');
                    }
                    $A.get("e.force:closeQuickAction").fire();              
                }else if(state === "ERROR"){
                    let errors = a.getError();
                    if(errors && Array.isArray(errors) && errors.length>0){
                        helper.showToast(component,event,helper,errors[0].message,'error');
                        $A.get("e.force:closeQuickAction").fire();              

                    }

                }
            });            
            $A.enqueueAction(action);
        }else{
            component.set("v.showSpinner" , true);
            let action = component.get("c.changeOwnerOnOrder");
            action.setParams({
                'configurationId' : component.get("v.recordId"),
                'accountId' : component.get("v.accountId"),
                'reason' : component.get("v.reasonValue"),
                'type' :  component.get("v.typeValue")
            });
            action.setCallback(this, function(a) {
                let state = a.getState();
                if (state === "SUCCESS"){
                    let result = a.getReturnValue();
                    console.log('result='+result.success);              
                    if(result.success){
                        helper.showToast(component, event, helper, result.resultMessage, 'success');
                        $A.get('e.force:refreshView').fire();
                    }else {
                        console.log('result error='+result.resultMessage);
                        helper.showToast(component, event, helper, result.resultMessage, 'error');
                    }
                    $A.get("e.force:closeQuickAction").fire();              
                }else if(state === "ERROR"){
                    let errors = a.getError();
                    if(errors && Array.isArray(errors) && errors.length>0){
                        helper.showToast(component,event,helper,errors[0].message,'error');
                        $A.get("e.force:closeQuickAction").fire();              

                    }

                }
            });            
            $A.enqueueAction(action);
        }
        
    },
    
     showToast: function (component, event, helper, message, type) {
         
         let title = type=="error" ? "Error" : "Success";
         let msg = title=="Success" ? "Ownership successfully changed!":message;
         
        component.find('notifLib').showToast({
            "title": title,
            "message":msg ,
            "variant": type
        });
    },

    getAccountRelatedContact: function (component, event, helper){
        var actionContact = component.get("c.getContactLists");
        //var accountId = component.get("v.accountId");
        var accountId = component.find("relatedAccount").get("v.value")[0];
        actionContact.setParams({
                'selectedAccount' : accountId
            });
            actionContact.setCallback(this, function(response) {
                let state = response.getState();
                if (state === "SUCCESS"){
                    let objInfo = [];
                    let result = JSON.parse(response.getReturnValue());    
                        if(result){
                            let optsContact = [];
                            objInfo = result['contactList'];
                            console.log(JSON.stringify(objInfo));
                            objInfo.forEach(function (entry) {
                                optsContact.push({
                                    value: entry['key'],
                                    label: entry['value']
                                });
                            });
                            component.set("v.contactOptions", optsContact);
                            console.log(JSON.stringify(optsContact));
                        }
                }
            });
            $A.enqueueAction(actionContact);

    }
    
})