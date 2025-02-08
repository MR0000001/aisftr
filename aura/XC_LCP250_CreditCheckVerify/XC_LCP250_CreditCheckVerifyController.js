({
	doInit : function(component, event, helper) {
	    var action = component.get("c.submit");
	    component.set("v.spinnerControl",true);
        action.setParams({ "recordId":  component.get("v.recordId") });  
        console.log('@@@ ' + component.get("v.recordId"));
        action.setCallback(this, function(response) {
        //var result = response.getReturnValue();

        var state = response.getState();
        let result = response.getReturnValue();
        //Console.log(result);
        if(state === 'SUCCESS') {
               component.set("v.spinnerControl",false);
               component.set("v.showModal",false);


               if(result.success){
                   helper.showToastSuccess(component, result.resultMessage, $A.get("$Label.c.XC_CL_OperationCompleted"));
               }else if (!result.success){
                   helper.showToastError(component,result.resultMessage,'ERROR');
               }


             /*  if(result != 'OK'){

                   //return helper.handleShowNotice(component,'error','ERROR', 'Error:  ' +result);
                   $A.get("e.force:closeQuickAction").fire();
                    helper.showToastError(component,result,'ERROR');
                   } else if(result == '1'){
                    //helper.handleShowNotice(component,'success',$A.get("$Label.c.XC_CL_OperationCompleted"), $A.get("$Label.c.XC_CL_WBE_OK"));
                    helper.showToastSuccess(component,$A.get("$Label.c.XC_CL_OperationCompleted"),$A.get("$Label.c.XC_CL_WBE_OK"));

                    }*/

               }
            


         });
          $A.enqueueAction(action);
		
	},
	closeModal : function(component, event, helper){
	    $A.get("e.force:closeQuickAction").fire();
 }
})