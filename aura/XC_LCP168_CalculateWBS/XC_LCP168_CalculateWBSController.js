({
	doInit : function(component, event, helper) {
	    var action = component.get("c.submit");
        action.setParams({ "recordId":  component.get("v.recordId") });  
        console.log('@@@ ' + component.get("v.recordId"));
        action.setCallback(this, function(response) {
        var result = response.getReturnValue();
        var state = response.getState();
        if(state === 'SUCCESS') {
               component.set("v.spinnerControl",true);
               
               if(result != 'OK'){
                   //return helper.handleShowNotice(component,'error','ERROR', 'Error:  ' +result);
                   return helper.showToastError(component,result,'ERROR');
               } else{
                    //helper.handleShowNotice(component,'success',$A.get("$Label.c.XC_CL_OperationCompleted"), $A.get("$Label.c.XC_CL_WBE_OK"));
                    helper.showToastSuccess(component,$A.get("$Label.c.XC_CL_OperationCompleted"),$A.get("$Label.c.XC_CL_WBE_OK"));
               }

        }
            


        });
          $A.enqueueAction(action);
		
	}
})