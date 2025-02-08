({
    doInit: function (component, event, helper) {
        let action = component.get("c.selectAvaibleContact");
        action.setParams({
            'recordId': component.get("v.recordId"),
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            let result = response.getReturnValue();
            let objInfo = [];
            let contactData = [];
            let addressData = [];
            if (state === "SUCCESS" && result) {
                objInfo = JSON.parse(result.objectInfo);
                //Account List (1 value readonly)
                contactData = objInfo['contactData'];
                let optsAcc = [];
                optsAcc.push({
                    value: component.get("v.recordId"),
                    label: objInfo['accountName']
                });
                component.set('v.categoryOptions', optsAcc);
                component.set("v.categoryValue", optsAcc[0].value);
                component.set("v.accountid", optsAcc[0].value);

                //Contact List
                contactData = objInfo['contactData'];
                let optsContact = [];
                contactData.forEach(function (entry) {
                    optsContact.push({
                        value: entry['key'],
                        label: entry['value']
                    });
                });
                component.set('v.contactOptions', optsContact);

               
               
            }
            
            component.set('v.showContactOpt', true);
        });
        $A.enqueueAction(action);
	},
	
	handleSubmit :   function(component, event, helper) {
        component.set('v.showSpinner', true);
        let action = component.get("c.updateContactOnAccount");
        action.setParams({
            'accountId': component.get("v.recordId"),
            'contactId': component.get("v.contactValue")
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            let retValue = response.getReturnValue();
            if (state === "SUCCESS") {
                if (retValue.success) {
                    helper.showToast(component, $A.get("$Label.c.XC_CL_OperationPerformed"), 'success');
                    component.set('v.showSpinner', false);
                } else {
                    helper.showToast(component, retValue.resultMessage, 'error');
                }
            } else {
                helper.showToast(component, $A.get("$Label.c.XC_CL_ErrorsOccurred"), 'error');
                component.set('v.spinnerControl', false);
            }
        });
        $A.enqueueAction(action);
    }, 

    showToast: function (component, message, type) {
        component.find('notifLib').showToast({
            "title": message,
            "message": '',
            "variant": type
        });
        $A.get("e.force:closeQuickAction").fire();
    }
})