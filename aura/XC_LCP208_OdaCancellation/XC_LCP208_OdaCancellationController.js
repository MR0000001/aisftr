({
	doInit : function(component, event, helper) {
	    /*var action = component.get("c.submit");
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
                    helper.showToastSuccess(component,$A.get("$Label.c.XC_CL_OperationCompleted"),$A.get("$Label.c.XC_CL_WOLI_Oda_Cacellation_OK"));

                    }

               }
            


         });
          $A.enqueueAction(action);*/
		
	},
	closeModal: function(component, event, helper) {
          // for Hide/Close Model,set the "isOpen" attribute to "Fasle"
          component.set("v.isOpen", false);
          var dismissActionPanel = $A.get("e.force:closeQuickAction");
          dismissActionPanel.fire();
    },
    onConfirm: function(component, event, helper) {
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
                      helper.showToastSuccess(component,$A.get("$Label.c.XC_CL_OperationCompleted"),$A.get("$Label.c.XC_CL_WOLI_Oda_Cacellation_OK"));

                      }

                 }



           });
          $A.enqueueAction(action);
    }
})