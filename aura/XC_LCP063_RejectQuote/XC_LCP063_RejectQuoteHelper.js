({
	doInit : function(component, event, helper) {
		var action = component.get("c.retriveCategoryValues");
        action.setCallback(this, function(response) {
            var state = response.getState();
            var retValue = response.getReturnValue();
            if (state === "SUCCESS" && retValue) {
                var opts = [];
                for (var i = 0; i < retValue.length; i++) {
    				opts.push({
      
      				value: retValue[i].fieldValue,
      				label: retValue[i].fieldLabel
    				});
                }
        		component.set('v.reasonOptions', opts);
            }
             }); 
        $A.enqueueAction(action); 
    
    },
    
    rejectQuote : function(component, event, helper) {
      var action = component.get("c.rejectQuote");
        action.setParams({ 'recordId' : component.get("v.recordId"),
                          'lossReason' : component.get("v.reasonValue") });
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS"){
                var result = a.getReturnValue();
                if(result.success){
                   helper.showToast(component, event, helper, result.resultMessage, 'success');
                   $A.get("e.force:closeQuickAction").fire();
                   setTimeout(function(){
                      $A.get('e.force:refreshView').fire();
                      }, 1000);
                   }
                else{
                     helper.showToast(component, event, helper, result.resultMessage, 'error');
                     $A.get("e.force:closeQuickAction").fire();
                  
                }
            }
        });
        $A.enqueueAction(action);  
    },
    
    
     showToast : function(component, event, helper, message, type) {
        component.find('notifLib').showToast({
            "title": message,
            "message": '',
            "variant": type
        });
    }
	
})