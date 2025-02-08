({
	doInit : function(component, event, helper) {
	    var action = component.get("c.checkProvvisioning");
        action.setParams({'recordId':  component.get("v.recordId") });
        console.log('@@@ ' + component.get("v.recordId"));
        action.setCallback(this, function(response) {
        var result = response.getReturnValue();
        var state = response.getState();
        if(state === 'SUCCESS') {
              // component.set("v.spinnerControl",true);
               if(!result.success /*!= 'OK'*/){
                   //return helper.showToastError(component,'error','ERROR', 'Error:  ' +result);
                   helper.showToastError(component, result.resultMessage, result.typeMessage, false);
                   } else{
                    helper.showToastSuccess(component,'success',$A.get("$Label.c.XC_CL_OperationCompleted"),$A.get("$Label.c.XC_CL_PPM_PROJECT_CREATE"));
                }

               }
            


         });
          $A.enqueueAction(action);
		
	}
})