({ 
    doInit:function(component, event, helper) {
    var action = component.get("c.inizio");
    action.setParams({"recordId" : component.get("v.recordId")});
    action.setCallback(this, function(response) {
        var state = response.getState();
        var res =response.getReturnValue();
        console.log('result'+' '+res);
        if(state === "SUCCESS"){
            component.set("v.projStartDate",res);
            console.log('date'+' '+component.get("v.projStartDate"));
        }
    });
    $A.enqueueAction(action);     
    },
    CreateProject : function(component, event, helper) {
		 var action = component.get("c.createMainProject");
         action.setParams({"recordId" : component.get("v.recordId"), 
                           "projStartDate" : component.get("v.projStartDate")});
        action.setCallback(this, function(response) {
        var state = response.getState();
        var res =response.getReturnValue();    
        if (state === "SUCCESS") {
            if(res!='Project Task created'){
                helper.toastError(component,res);
                $A.get("e.force:closeQuickAction").fire();
            }else{
                // Alert the user with the value returned 
                // from the server
               helper.ToastSuccess(component,res);
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
            }
           }
        })
        $A.enqueueAction(action);         

	}
})