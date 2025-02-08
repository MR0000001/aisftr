({
	init : function(component, event, helper) {

        if(component.get("v.address")){
            var mapField = component.get("v.address");
            for(let i in mapField){ 
                let cmpTarget = component.find(i); 
                if(cmpTarget){
                    cmpTarget.set("v.value",mapField[i]);
                } 
            }
        }

        if(component.get("v.address.account")){
            let action = component.get("c.retrieveAccountRecordTypeName");
            action.setParams({ 
                'accountId': component.get("v.address.account")
            });
            action.setCallback(this, function(response) {
                let state = response.getState();
                let retValue = response.getReturnValue(); 
                if (state === "SUCCESS" && retValue !== null){
                    if(retValue.typeMessage === $A.get("$Label.c.XC_CL_Account_Partner")){
                        component.set("v.address.isAccountPartner", true);
                    }
                }
            });
            $A.enqueueAction(action);      
        }

        if(component.get("v.addressToUpdate")){
            helper.disableAllField(component, true);
            component.find('country').set('v.disabled', true);
            component.find('saveButton').set('v.disabled', true);
        } 

	},

	saveAddress: function(component, event, helper) {
        let address = component.get("v.address");

        let action = component.get("c.saveAddressApex");

        action.setParams( {
            'inputAddress' : JSON.stringify(address)
        });
        
        action.setCallback(this, function(response) {
            let state = response.getState();
            let retValue = response.getReturnValue();
            if (state === "SUCCESS" && retValue ) {
                if(retValue.success){
                    helper.showMessage(component, "info", "Success!", "Address created");
                    
                    if(component.get("v.source")=='052'||component.get("v.source")=='102'){
                        let cmpEvent = component.getEvent("XC_LCE004_closeNewAddress");
                        cmpEvent.fire();

                    } else {
                        setTimeout(function(){
                            $A.get('e.force:refreshView').fire();
                        }, 10); 
                        $A.get("e.force:closeQuickAction").fire();
                    }

                } else { 
                    this.showMessage(component, "error", "Warning", retValue.resultMessage);
                }
            }
        });       
        $A.enqueueAction(action); 
	}, 

	updateAddress : function(component, event, helper){
        let address = component.get("v.address");

        var action = component.get("c.updateAddressByLead");

        action.setParams( {
            'inputFields' : JSON.stringify(address)
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            let retValue = JSON.parse(response.getReturnValue());
            if (state === "SUCCESS" && retValue ) {
                if(retValue.success){
                    this.showMessage(component, "info", "Success!", "Address updated");
                    component.set("v.recordId", retValue.recordId);

                } else { 
                    this.showMessage(component, "error", "Warning", retValue.errorMessage);
                }
            }
        });       
        $A.enqueueAction(action); 
    },

    handleSaveButtonClick : function(component, event, helper){
        if(component.get("v.addressToUpdate")){
            helper.updateAddress(component, event, helper);
            helper.disableAllField(component, true);
            component.find('country').set('v.disabled', true);
            component.find('editButton').set('v.disabled', false);
            component.find('saveButton').set('v.disabled', true);

        } else {
            helper.saveAddress(component, event, helper);
            component.set("v.addressToUpdate", true);

        }
    },

    cancel : function(component, event,helper) {
        if(component.get("v.source")=='052'||component.get("v.source")=='102'){
            let cmpEvent =component.getEvent("XC_LCE004_closeNewAddress");
            cmpEvent.fire();
        } else {
            $A.get('e.force:closeQuickAction').fire();
        }
    },
    
    setPickCountry : function(component, selectedOptionValue){
        let ev = component.getEvent("XC_LCE018_ChangeAddressCountry");
		ev.setParams({
			"country" : selectedOptionValue
		}); 
        ev.fire();
    }, 

    checkMandatory : function(component){
        let fieldToCheck = component.get("v.mandatoryFields");
        for(let i in fieldToCheck){ 
            let field = component.find(fieldToCheck[i]);
            if(!field.get("v.value")){
                return false;
            }
        }
        return true;
    }, 

    showMessage : function(component, variante, title, mess){
        component.find('notifLib').showNotice({
            "variant": variante,
            "header": title,
            "message": mess, 
        });
    }, 

    showErrorOnField : function(component, event, helper){   
        let fieldToCheck = component.get("v.mandatoryFields");
        for(let i in fieldToCheck){ 
            let field = component.find(fieldToCheck[i]);
            if(!field.get("v.disabled")&&!field.get("v.value")){
                $A.util.addClass( field, 'slds-has-error'); 
            } else {
                $A.util.removeClass( field, 'slds-has-error');
            }
        }
    },
    
    removeErrorOnField : function(component, event) {
        let fieldToCheck = component.get("v.mandatoryFields");
        for(let i in fieldToCheck){ 
            let field = component.find(fieldToCheck[i]);
            if(!field.get("v.disabled")&&field.get("v.value")){
                $A.util.removeClass( field, 'slds-has-error'); 
            }
        }
    },

    sendAddressToMain : function(component) {
        let address = component.get("v.address");
        let cmpEvent = component.getEvent("XC_LCE013_SetAddressObject");
        cmpEvent.setParams({
            "address" : address,
            "withoutValidate" : true,
            "checkValue" : component.get("v.mandatoryFields")
        });
        cmpEvent.fire();
    }, 

	setDeelay : function(component, helper){

        var int = 1000;

		if(component.get("v.timer")){
			helper.clearDeelay(component, helper)
		}

        component.set("v.timer", setTimeout(function(){ 
            helper.sendAddressToMain(component); 
        }, int));

	},

	clearDeelay : function(component, helper) {
	    component.set("v.timer", clearTimeout(component.get("v.timer")));
    }, 

    clearAddress : function(component, event, helper){
        component.find("city").set("v.value", "");
        component.find("streetType").set("v.value", "");
        component.find("streetNumber").set("v.value", "");
        component.find("floor").set("v.value", "");
        component.find("door").set("v.value", "");
        component.find("stair").set("v.value", "");
        component.find("category").set("v.value", "");
        component.find("province").set("v.value", "");
        component.find("address").set("v.value", "");
        component.find("postalCode").set("v.value", "");
        component.find("electricCUP").set("v.value", "");
        component.find("gasCUP").set("v.value", "");
    }, 

    disableAllField : function(component, enable){
        component.find("city").set('v.disabled', enable);
        component.find("streetType").set('v.disabled', enable);
        component.find("streetNumber").set('v.disabled', enable);
        component.find("floor").set('v.disabled', enable);
        component.find("door").set('v.disabled', enable);
        component.find("stair").set('v.disabled', enable);
        component.find("category").set('v.disabled', enable);
        component.find("province").set('v.disabled', enable);
        component.find("address").set('v.disabled', enable);
        component.find("postalCode").set('v.disabled', enable);
        component.find("electricCUP").set('v.disabled', enable);
        component.find("gasCUP").set('v.disabled', enable);
    }, 

	onModify : function(component, event, helper){
        helper.disableAllField(component, false);
        component.find('country').set('v.disabled', false);
        component.find('editButton').set('v.disabled', true);
        component.find('saveButton').set('v.disabled', false);
    }

})