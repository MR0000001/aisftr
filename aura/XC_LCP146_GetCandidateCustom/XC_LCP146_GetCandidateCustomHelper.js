/*
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 04/05/2020
* @description XC_LCP146_GetCandidateCustom – Component for Get Candidate
*/

({
	doInit : function(component, event, helper) {
		console.log('@@@ Init XC_LCP146_GetCandidateCustom');
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
						console.log('iscommunityNic');
						//isPrd is equals to true for SandBox Environment and false for Production Envinroment
						console.log('isSandbox '+resultWrapper.isProd);
						if(resultWrapper.segment=='B2C'){
							urlString = '/partner/apex/FSL__GetCandidates?id=';							
						}else if(resultWrapper.isProd) {
							console.log('segment'+' '+resultWrapper.segment);
							urlString = '/apex/FSL__AppointmentBookingVf?id=';
						 }else if(!resultWrapper.isProd){
							console.log('segment'+' '+resultWrapper.segment);
							urlString = '/partnercommunity/apex/FSL__AppointmentBookingVf?id=';
						 }
					} else {
					      urlString = '/apex/FSL__GetCandidates?id=';
					    }
					component.set('v.urlComponent', urlString + component.get('v.recordId'));
					component.set('v.showGetCandidate', true);
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