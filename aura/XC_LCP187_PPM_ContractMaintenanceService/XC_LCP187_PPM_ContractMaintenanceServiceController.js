({
	doInit : function(component, event, helper) {
    component.set("v.spinnerControl",true);
      var action = component.get("c.createProject");
      
        action.setParams({"recordId" : component.get("v.recordId")});
                          // "prjName": component.get("v.prjName")});
        action.setCallback(this, function(response) {
        var state = response.getState();
         var res=response.getReturnValue();
        if (state === "SUCCESS") {
            component.set("v.spinnerControl",false);
            if(res=='Project is created'){
                helper.ToastSuccess(component,res);
                $A.get("e.force:closeQuickAction").fire();            
               // window.location.reload(); 
            }else{                
              helper.toastError(component,res);
             $A.get("e.force:closeQuickAction").fire();
            }
         }
        })
        $A.enqueueAction(action);         
    }
})