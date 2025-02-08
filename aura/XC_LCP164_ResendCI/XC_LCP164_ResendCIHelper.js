({
	doInit: function (component, event, helper) {
		let action = component.get("c.getEmails");
		action.setParams({ 
			'idCI': component.get("v.recordId")
		});
		action.setCallback(this, function(response) {
			let state = response.getState();
			if (state === "SUCCESS"){
				let resMap = response.getReturnValue();
				if(resMap.channel=='SMS'){
					component.set("v.emailValue", "#sms");
					helper.send(component, event, helper);
				} else {
					let opt = [];

					let ciEmail = {};
					ciEmail.label = resMap.ciEmail;
					ciEmail.value = resMap.ciEmail;
					opt.push(ciEmail);

                    if(resMap.contactEmail&&resMap.contactEmail!=resMap.ciEmail){
                        let contactEmail = {};
						contactEmail.label = resMap.contactEmail;
						contactEmail.value = resMap.contactEmail;
						opt.push(contactEmail);
                    }

                    if(resMap.leadEmail&&resMap.leadEmail!=resMap.ciEmail&&resMap.leadEmail!=resMap.contactEmail){
					    let leadEmail = {};
					    leadEmail.label = resMap.leadEmail;
					    leadEmail.value = resMap.leadEmail;
					    opt.push(leadEmail);
					}

					component.set("v.emailOptions", opt);
				}
			}
		});
		$A.enqueueAction(action);     

		component.set("v.loading",false);
	},

	setEmail: function (component, event, helper) {
		if(event.getSource().getLocalId()!='newEmail'){
			let e = event.getSource().get("v.label");
			component.set("v.emailValue", e);
			component.find("newEmailinputField").set('v.disabled', true)
			component.find("newEmailinputField").set('v.required', false)
			component.find("newEmailinputField").reportValidity();
		} else {
			component.set("v.emailValue", "#newEmail");
			component.find("newEmailinputField").set('v.disabled', false)
			component.find("newEmailinputField").set('v.required', true)
		}
	},

	send: function (component, event, helper) {
		let recordId = component.get("v.recordId");
		let email = component.get("v.emailValue");
		if(component.get("v.emailValue")=="#newEmail"){
			if(!component.find("newEmailinputField").checkValidity()||!component.get("v.typingEmail")){
				component.find("newEmailinputField").reportValidity();
				return;
			}
			email = component.get("v.typingEmail")
		} else if(component.get("v.emailValue")=="#sms"){
			email = null;
		}

		let action = component.get("c.resend");
		action.setParams({ 
			'idCI': recordId,
			'email': email,
		});
		action.setCallback(this, function(response) {
			let state = response.getState();
			let retValue = response.getReturnValue();
			component.set("v.loading",false); 
			if (state === "SUCCESS" && retValue !== null) {
				console.log('success');
				helper.showMessage(component, "info", $A.get('$Label.c.XC_CL_Success'), $A.get('$Label.c.XC_CL_NotificationInProgress'));
			} else {
				helper.showMessage(component, "error", $A.get('$Label.c.XC_CL_Warning'), $A.get('$Label.c.XC_CL_NotificationError'));
			}
			$A.get("e.force:closeQuickAction").fire();
		});
		$A.enqueueAction(action);  
		component.set("v.loading",true);   
	},

	showMessage : function(component, variante, title, mess){
        component.find('notifLib').showNotice({
            "variant": variante,
            "header": title,
            "message": mess, 
        });
    }
})