({
	generate : function(component,event) {
        
        var actionConvert = component.get("c.generateScored");
        actionConvert.setParams({"recordId" : component.get("v.recordId")});
        actionConvert.setCallback(this, function(response) {
        var stateConvert = response.getState();
        var retValueConvert = response.getReturnValue();
        if (component.isValid() && stateConvert === "SUCCESS" && retValueConvert){
         	
            console.log('@@@ return @@@:' + retValueConvert);
            var spinner = component.find("mySpinner");
                           var delay=1000; //4 seconds
                    setTimeout(function() {
                    $A.util.toggleClass(spinner, "slds-hide");
                    $A.get("e.force:closeQuickAction").fire();
                    $A.get('e.force:refreshView').fire();
			
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
              "recordId": component.get("v.recordId")
            });
            navEvt.fire();

                                }, delay);
         }
              }); 
            $A.enqueueAction(actionConvert); 
           
		
	}
})