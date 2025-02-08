/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 05/09/2019
* @description XC_LCP146_BookAppointmentCustom – Component for Book Appointment
*/

({
	doInit : function(component, event, helper) {
		console.log('@@@ Init XC_LCP146_BookAppointmentCustom');
		let showRetry = component.get('v.showRetry');
		if(showRetry) {
			component.set('v.showRetry', false);
			component.set('v.retryMessage', '');
		}
		component.set("v.spinnerControl", true);
	
		let action = component.get("c.checkAvailability");
		action.setParams({ 
			'idWorkOrder' : component.get('v.recordId')
		});
		action.setCallback(this, function(a) { 
			let state = a.getState();
			console.log('@@@ State init ---> ' + state);
			component.set("v.spinnerControl", false);
			if(state === "SUCCESS") {
				let resultWrapper = a.getReturnValue();
				if(resultWrapper.success) {
					let urlString;
					if(resultWrapper.isCommunity) {
					//	urlString = '/partner/apex/FSL__AppointmentBookingVf?id=';
							if(resultWrapper.segment=='B2C'){
							urlString = '/partner/apex/FSL__AppointmentBookingVf?id=';	
						}else{  
							urlString = '/apex/FSL__AppointmentBookingVf?id=';
						}
					} else {
						urlString = '/apex/FSL__AppointmentBookingVf?id=';
					}
					component.set('v.urlComponent', urlString + component.get('v.recordId'));
					component.set('v.showBookApp', true);
				}
				else {
					component.set('v.showRetry', true);
					component.set('v.retryMessage', resultWrapper.message);
				}
			} else {
				component.set('v.showRetry', true);
				component.set('v.retryMessage', $A.get("$Label.c.XC_CL_BookAppointment_ErrorShow"));
                let errorresp = a.getError()[0].message;
                console.log('ERROR ON INIT ' + errorresp);
			}            
		});
		$A.enqueueAction(action); 
	}

})