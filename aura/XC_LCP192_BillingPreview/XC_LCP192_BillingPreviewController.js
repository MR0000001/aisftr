/**
 * Created by dpalamides on 10/06/2020.
 */
({
	doInit : function(component, event, helper) {
	    var action = component.get("c.refreshBillingPreview");
        action.setParams({ "recordId":  component.get("v.recordId") });
        console.log('@@@ ' + component.get("v.recordId"));
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            var state = response.getState();
            if(state === 'SUCCESS') {
               component.set("v.spinnerControl",true);

               if(result != 'OK'){
                  return helper.showToastError(component,result,'ERROR');
               } else{
                  helper.showToastSuccess(component,"",$A.get("$Label.c.XC_CL_BillingPreviewSubmitted"));
               }
            }

        });
        $A.enqueueAction(action);

	}
})