({
	  getAccountId : function (component, event, helper) {
       
        let action = component.get("c.getAccountId");
        action.setParams({ "bpliId": component.get("v.recordId") });
        action.setCallback(this, function (response) {
            
            let res = response.getReturnValue();
            console.log('getListAddress res='+res);
            if (res != null || res.fieldName != '') {
                  component.set("v.accountId", res.fieldName);
                 component.set("v.showAddress", true);
                
            }
            
          
        });
        
        $A.enqueueAction(action);
    },
})