({
	checkPromocodeApplication : function(component, event, helper) {
		let action = component.get("c.checkPromocodeApplication");
        action.setParams({
            'configurationId' : component.get("v.recordId")
        });

        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let result = response.getReturnValue();
                if(result.success) {
					component.set("v.isPromocodeApplicationWarning", true);
					console.log('Promocode application case');
				} else {
					console.log('No Promocode application case');
					this.initNextStep(component, event, helper);
				}
			} else {
                console.debug('@@@@@ NextStepOrderToProvisioning - Error on checkPromocodeApplication call');
                $A.get("e.force:closeQuickAction").fire();
            }
		});
        $A.enqueueAction(action);
	},

	initNextStep : function(component, event, helper) {
		let action = component.get("c.implementFirstNextStep");
        action.setParams({
            'configurationId' : component.get("v.recordId")
        });

        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS"){
                let result = response.getReturnValue();
                if(result.success) {
                	if(result.executeNextStep){
                		if(result.resultMessage!=null && result.resultMessage!=''){
                			helper.showToast(component, result.resultMessage, result.typeMessage, false);
                		}
                		let action2 = component.get("c.implementSecondNextStep");
	                    action2.setParams({
	                        'configurationId' : component.get("v.recordId")
	                    });
	                    action2.setCallback(this, function(response) {
	                        let state = response.getState();
	                        if (state === "SUCCESS"){
	                            let result = response.getReturnValue();
	                            if(result.success && result.executeNextStep) {

	                            	let action3 = component.get("c.implementThirdNextStep");
						            action3.setParams({
						                'configurationId' : component.get("v.recordId")
						            });
						            action3.setCallback(this, function(response) {
						                let state = response.getState();
						                if (state === "SUCCESS"){
						                    let result = response.getReturnValue();
						                    console.log('result='+result.success);
						                    if(result.success){
						                        helper.showToast(component, result.resultMessage, 'success', true);
						                    } else {
						                        console.log('result error='+result.resultMessage);
						                        helper.showToast(component, result.resultMessage, 'error', true);
						                    }
						                }
						            });            
						            $A.enqueueAction(action3);
	                            }
	                            else{
                                    console.log('@@1406@A result error='+result.resultMessage);
	                    			helper.showToast(component, result.resultMessage, result.typeMessage, true);
	                            }
	                        }
				        });
				        $A.enqueueAction(action2); 	
                	}else{
                        console.log('@@1406@B result error='+result.resultMessage);
	                    helper.showToast(component, result.resultMessage, result.typeMessage, true);
                	}
                }
                else{
					console.log('@@1406@C result error='+result.resultMessage);
	                helper.showToastLonger(result.resultMessage,  true, 10000);
                }
            }
            else{
                console.debug('@@@@@ NextStepOrderToProvisioning - Error on implementFirstNextStep call');
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action); 
	},

	showToast : function(component, message, type, closeComponent) {
		let typeValue = type | 'warning';
		console.log('@#@#@#@#@#@ NextStepOrderToProvisioning message: '+message);
		component.find('notifLib').showToast({
            "title": message,
            "message": '',
            "variant": typeValue
        });

		if(closeComponent){
	        $A.get("e.force:closeQuickAction").fire();
	        $A.get('e.force:refreshView').fire();
		}
	},
	
	showToastLonger : function(message, closeComponent, duration) {
		console.log('@#@#@#@#@#@ NextStepOrderToProvisioning message: '+message);
		var toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
			title : $A.get("$Label.XC_CL_Warning"),
			mode: 'dismissible',//20211111_DD_PROV_22 - start
			type:'error',
            //20211111_DD_PROV_22 - start
            //mode: 'dismissible',
			//mode: 'pester',
            //20211111_DD_PROV_22 - end
			duration : duration,
			message: message
		});
		toastEvent.fire();

		if(closeComponent){
	        $A.get("e.force:closeQuickAction").fire();
	        $A.get('e.force:refreshView').fire();
		}
    }
})